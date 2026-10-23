from __future__ import annotations

import csv
import io
from dataclasses import dataclass
from html import escape
from typing import Any
from urllib.parse import quote

import requests

from gnostakes.secrets import get_google_sheets_api_key


SHEETS_API_URL = "https://sheets.googleapis.com/v4/spreadsheets"


@dataclass(frozen=True)
class GoogleSheetRef:
    spreadsheet_id: str
    sheet_name: str


TAROT_TABLE_SHEET = GoogleSheetRef(
    spreadsheet_id="1b6wk5AJfQ7ooa-zgk0gZcclUUBDrwRwfn6HNozuUrhE",
    sheet_name="tarot table",
)

# Alias kept for callers that still import DEFAULT_CARDS_SHEET.
DEFAULT_CARDS_SHEET = TAROT_TABLE_SHEET

HTML_BY_COLUMN_KEY = "_html"


def resolve_sheets_api_key() -> str | None:
    return get_google_sheets_api_key()


def sheet_csv_url(ref: GoogleSheetRef) -> str:
    # Works for public sheets without auth.
    # Format: https://docs.google.com/spreadsheets/d/<id>/gviz/tq?tqx=out:csv&sheet=<name>
    return (
        "https://docs.google.com/spreadsheets/d/"
        f"{ref.spreadsheet_id}/gviz/tq?tqx=out:csv&sheet={quote(ref.sheet_name)}"
    )


def plain_text_to_html(text: str) -> str:
    if not text:
        return ""
    return escape(text).replace("\n", "<br>")


def _run_style(fmt: dict[str, Any]) -> tuple[bool, bool, bool]:
    text_format = fmt.get("textFormat") if isinstance(fmt.get("textFormat"), dict) else fmt
    if not isinstance(text_format, dict):
        text_format = {}
    return (
        bool(text_format.get("bold")),
        bool(text_format.get("italic")),
        bool(text_format.get("underline")),
    )


def rich_text_to_html(text: str, runs: list[dict[str, Any]] | None) -> str:
    """
    Convert a cell's text + Sheets API textFormatRuns into minimal HTML.

  Only bold, italic, and underline are preserved; font family/size/color are ignored.
    """
    if not text:
        return ""
    if not runs:
        return plain_text_to_html(text)

    sorted_runs = sorted(runs, key=lambda run: int(run.get("startIndex", 0)))
    cut_points = sorted(
        {
            0,
            len(text),
            *(
                int(run.get("startIndex", 0))
                for run in sorted_runs
                if 0 <= int(run.get("startIndex", 0)) <= len(text)
            ),
        }
    )

    parts: list[str] = []
    for idx in range(len(cut_points) - 1):
        start, end = cut_points[idx], cut_points[idx + 1]
        if start >= end:
            continue

        active_format: dict[str, Any] = {}
        for run in sorted_runs:
            if int(run.get("startIndex", 0)) <= start:
                fmt = run.get("format")
                active_format = fmt if isinstance(fmt, dict) else {}
            else:
                break

        segment = escape(text[start:end]).replace("\n", "<br>")
        bold, italic, underline = _run_style(active_format)
        if underline:
            segment = f"<u>{segment}</u>"
        if italic:
            segment = f"<i>{segment}</i>"
        if bold:
            segment = f"<b>{segment}</b>"
        parts.append(segment)

    return "".join(parts)


def _cell_plain_text(cell: dict[str, Any] | None) -> str:
    if not cell:
        return ""

    entered = cell.get("userEnteredValue")
    if isinstance(entered, dict):
        if "stringValue" in entered:
            return str(entered["stringValue"])
        if "numberValue" in entered:
            value = entered["numberValue"]
            if isinstance(value, (int, float)) and float(value).is_integer():
                return str(int(value))
            return str(value)
        if "boolValue" in entered:
            return str(entered["boolValue"])

    formatted = cell.get("formattedValue")
    return "" if formatted is None else str(formatted)


def _fetch_rows_via_api(
    ref: GoogleSheetRef,
    api_key: str,
    *,
    timeout_s: float,
) -> list[dict[str, Any]]:
    params = {
        "includeGridData": "true",
        "ranges": f"'{ref.sheet_name}'",
        "fields": "sheets.data.rowData.values(formattedValue,userEnteredValue,textFormatRuns)",
        "key": api_key,
    }
    resp = requests.get(f"{SHEETS_API_URL}/{ref.spreadsheet_id}", params=params, timeout=timeout_s)
    resp.raise_for_status()

    sheets = resp.json().get("sheets") or []
    if not sheets:
        return []

    data_blocks = sheets[0].get("data") or []
    if not data_blocks:
        return []

    row_data = data_blocks[0].get("rowData") or []
    if not row_data:
        return []

    header_cells = row_data[0].get("values") or []
    headers: list[str] = []
    for idx, cell in enumerate(header_cells):
        header = _cell_plain_text(cell).strip()
        headers.append(header or f"col_{idx}")

    rows: list[dict[str, Any]] = []
    for raw_row in row_data[1:]:
        values = raw_row.get("values") or []
        row: dict[str, Any] = {}
        html_by_column: dict[str, str] = {}

        for idx, cell in enumerate(values):
            header = headers[idx] if idx < len(headers) else f"col_{idx}"
            plain = _cell_plain_text(cell)
            row[header] = plain
            html_by_column[header] = rich_text_to_html(plain, cell.get("textFormatRuns"))

        if row:
            row[HTML_BY_COLUMN_KEY] = html_by_column
            rows.append(row)

    return rows


def fetch_sheet_rows(ref: GoogleSheetRef = DEFAULT_CARDS_SHEET, timeout_s: float = 30) -> list[dict[str, Any]]:
    url = sheet_csv_url(ref)
    resp = requests.get(url, timeout=timeout_s)
    resp.raise_for_status()

    # Google sometimes includes a UTF-8 BOM; csv handles it if we strip via utf-8-sig decode.
    text = resp.content.decode("utf-8-sig")
    f = io.StringIO(text)
    reader = csv.DictReader(f)
    return [dict(row) for row in reader]


def fetch_sheet_rows_with_formatting(
    ref: GoogleSheetRef = DEFAULT_CARDS_SHEET,
    *,
    api_key: str | None = None,
    timeout_s: float = 30,
) -> tuple[list[dict[str, Any]], str]:
    """
    Fetch sheet rows, preserving bold/italic/underline when a Sheets API key is available.

    Returns (rows, mode) where mode is one of: "api", "csv".
    """
    resolved_key = api_key or resolve_sheets_api_key()
    if resolved_key:
        return _fetch_rows_via_api(ref, resolved_key, timeout_s=timeout_s), "api"
    return fetch_sheet_rows(ref, timeout_s=timeout_s), "csv"

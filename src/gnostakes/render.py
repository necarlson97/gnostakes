from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, select_autoescape

from gnostakes.sources.google_sheets import (
    HTML_BY_COLUMN_KEY,
    TAROT_TABLE_SHEET,
    fetch_sheet_rows,
    fetch_sheet_rows_with_formatting,
    plain_text_to_html,
)


def _env(templates_dir: Path) -> Environment:
    return Environment(
        loader=FileSystemLoader(str(templates_dir)),
        autoescape=select_autoescape(enabled_extensions=("html", "xml")),
    )

def _norm(s: str) -> str:
    return "".join(ch.lower() for ch in s.strip() if ch.isalnum())


def _row_key_map(row: dict[str, Any]) -> dict[str, str]:
    return {_norm(k): k for k in row.keys() if isinstance(k, str)}


def _get_ci(row: dict[str, Any], *candidates: str) -> str:
    if not row:
        return ""
    norm_map = _row_key_map(row)
    for cand in candidates:
        k = norm_map.get(_norm(cand))
        if k is None:
            continue
        v = row.get(k, "")
        return "" if v is None else str(v).strip()
    return ""


def _get_ci_html(row: dict[str, Any], *candidates: str) -> str:
    plain = _get_ci(row, *candidates)
    if not plain:
        return ""

    html_by_column = row.get(HTML_BY_COLUMN_KEY)
    if isinstance(html_by_column, dict):
        norm_map = _row_key_map(row)
        for cand in candidates:
            k = norm_map.get(_norm(cand))
            if k is None:
                continue
            html = html_by_column.get(k)
            if isinstance(html, str) and html:
                return html

    return plain_text_to_html(plain)


def _art_filename(art_value: str) -> str:
    v = (art_value or "").strip()
    if not v:
        return ""
    # Sheet values tend to be like "venus" while the asset is "venus.png"
    if "." not in Path(v).name:
        v = f"{v}.png"
    return v


def canonicalize_cards(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    cards: list[dict[str, Any]] = []
    for r in rows:
        name = _get_ci(r, "Name", "Card Name", "Title")
        inv_name = _get_ci(r, "Inverted Name", "InvertedName", "Name Inverted")
        rule = _get_ci(r, "Rule", "Rules", "Text")
        inv_rule = _get_ci(r, "Inverted Rule", "InvertedRule", "Rule Inverted")
        on_pickup = _get_ci(r, "On Pickup", "OnPickup", "Pickup", "Pickup Rule")
        art = _get_ci(r, "Art?", "Art", "Artwork", "Image")

        cards.append(
            {
                "name": name,
                "name_html": _get_ci_html(r, "Name", "Card Name", "Title"),
                "inverted_name": inv_name or name,
                "inverted_name_html": _get_ci_html(r, "Inverted Name", "InvertedName", "Name Inverted")
                or _get_ci_html(r, "Name", "Card Name", "Title"),
                "rule": rule,
                "rule_html": _get_ci_html(r, "Rule", "Rules", "Text"),
                "inverted_rule": inv_rule or rule,
                "inverted_rule_html": _get_ci_html(r, "Inverted Rule", "InvertedRule", "Rule Inverted")
                or _get_ci_html(r, "Rule", "Rules", "Text"),
                "on_pickup": on_pickup,
                "on_pickup_html": _get_ci_html(r, "On Pickup", "OnPickup", "Pickup", "Pickup Rule"),
                "art": art,
                "art_filename": _art_filename(art),
                "raw": r,
            }
        )
    return cards


def build_site(
    templates_dir: str | Path = "templates",
    out_dir: str | Path = "site",
    *,
    cache_dir: str | Path = "data/cache",
    sheet_timeout_s: float = 10,
) -> dict[str, Any]:
    templates_dir = Path(templates_dir)
    out_dir = Path(out_dir)
    cache_dir = Path(cache_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    cache_dir.mkdir(parents=True, exist_ok=True)

    cache_path = cache_dir / "cards_rows.json"
    rows: list[dict[str, Any]]
    source: str
    error: str | None = None

    formatting_mode = "csv"
    try:
        try:
            rows, formatting_mode = fetch_sheet_rows_with_formatting(
                TAROT_TABLE_SHEET,
                timeout_s=sheet_timeout_s,
            )
            source = "google_sheets_api" if formatting_mode == "api" else "google_sheets"
        except Exception:
            rows = fetch_sheet_rows(TAROT_TABLE_SHEET, timeout_s=sheet_timeout_s)
            source = "google_sheets"
        cache_path.write_text(json.dumps(rows, indent=2), encoding="utf-8")
    except Exception as e:
        error = str(e)
        if cache_path.exists():
            rows = json.loads(cache_path.read_text(encoding="utf-8"))
            source = "cache"
        else:
            rows = []
            source = "empty"

    cards = canonicalize_cards(rows)

    env = _env(templates_dir)
    (out_dir / "index.html").write_text(
        env.get_template("index.html.j2").render(cards=cards),
        encoding="utf-8",
    )
    (out_dir / "tarot_cards.html").write_text(
        env.get_template("tarot_cards.html.j2").render(cards=cards),
        encoding="utf-8",
    )
    (out_dir / "game_cards.html").write_text(
        env.get_template("game_cards.html.j2").render(cards=cards),
        encoding="utf-8",
    )

    return {
        "cards_count": len(cards),
        "out_dir": str(out_dir),
        "source": source,
        "formatting_mode": formatting_mode,
        "error": error,
    }

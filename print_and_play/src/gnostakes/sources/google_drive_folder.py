from __future__ import annotations

import html
import re
import time
from dataclasses import dataclass
from html.parser import HTMLParser
from pathlib import Path
from typing import Iterable

import requests

from gnostakes.sources.google_drive_public import GoogleDriveFile, download_public_drive_file


DEFAULT_ASSETS_FOLDER_ID = "1frliVdndeMC56NSqDPbwn7OA7yk6sGRp"


def embedded_folder_view_url(folder_id: str) -> str:
    # This endpoint is used by tools like gdown to list all items in a public folder.
    return f"https://drive.google.com/embeddedfolderview?id={folder_id}#list"


_FILE_ID_PATTERNS: list[re.Pattern[str]] = [
    re.compile(r"/file/d/([^/]+)/"),
    re.compile(r"[?&]id=([^&]+)"),
]


def _extract_file_id(href: str) -> str | None:
    for pat in _FILE_ID_PATTERNS:
        m = pat.search(href)
        if m:
            return m.group(1)
    return None


@dataclass(frozen=True)
class PublicDriveItem:
    file_id: str
    name: str
    href: str


class _EmbeddedFolderViewParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=False)
        self._in_a = False
        self._href: str | None = None
        self._text_parts: list[str] = []
        self.items: list[PublicDriveItem] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag.lower() != "a":
            return
        self._in_a = True
        self._href = None
        self._text_parts = []
        for k, v in attrs:
            if k.lower() == "href" and v:
                self._href = v

    def handle_data(self, data: str) -> None:
        if self._in_a:
            self._text_parts.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() != "a" or not self._in_a:
            return

        href = self._href or ""
        name = html.unescape("".join(self._text_parts)).strip()
        self._in_a = False
        self._href = None
        self._text_parts = []

        if not href or not name:
            return
        file_id = _extract_file_id(href)
        if not file_id:
            return

        self.items.append(PublicDriveItem(file_id=file_id, name=name, href=href))


def list_public_folder_items(folder_id: str, *, timeout_s: float = 30) -> list[PublicDriveItem]:
    url = embedded_folder_view_url(folder_id)
    resp = requests.get(url, timeout=timeout_s)
    resp.raise_for_status()

    p = _EmbeddedFolderViewParser()
    p.feed(resp.text)
    return p.items


def _safe_filename(name: str) -> str:
    # Avoid path traversal or accidental subfolders in names.
    name = name.replace("\\", "/").split("/")[-1]
    return name.strip()


def sync_public_drive_folder(
    folder_id: str,
    out_dir: str | Path,
    *,
    redownload_all: bool = True,
    timeout_s: float = 60,
) -> dict[str, int]:
    """
    Download public files from a Drive folder into out_dir.

    Note: Without auth/API metadata, detecting "changed but same filename" is hard.
    For constant flux, set redownload_all=True (default) to keep assets fresh.
    """
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    items = list_public_folder_items(folder_id, timeout_s=timeout_s)

    downloaded = 0
    skipped = 0
    errors = 0

    for it in items:
        fn = _safe_filename(it.name)
        if not fn:
            continue
        out_path = out_dir / fn
        if not redownload_all and out_path.exists():
            skipped += 1
            continue

        try:
            # Write into a temp filename then swap to reduce partial files while serving.
            tmp = out_dir / f".{fn}.tmp.{int(time.time() * 1000)}"
            file = GoogleDriveFile(file_id=it.file_id, filename=tmp.name)
            tmp_path = download_public_drive_file(file, out_dir=out_dir, timeout_s=timeout_s)
            tmp_path.replace(out_path)
            downloaded += 1
        except Exception:
            errors += 1

    return {"listed": len(items), "downloaded": downloaded, "skipped": skipped, "errors": errors}


def iter_items_by_extension(items: Iterable[PublicDriveItem], *exts: str) -> list[PublicDriveItem]:
    exts_norm = tuple(e.lower() if e.startswith(".") else f".{e.lower()}" for e in exts)
    out: list[PublicDriveItem] = []
    for it in items:
        n = it.name.lower()
        if any(n.endswith(e) for e in exts_norm):
            out.append(it)
    return out


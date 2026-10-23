from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import requests


@dataclass(frozen=True)
class GoogleDriveFile:
    file_id: str
    filename: str


def drive_download_url(file_id: str) -> str:
    # Public file direct download endpoint.
    return f"https://drive.google.com/uc?export=download&id={file_id}"


def download_public_drive_file(file: GoogleDriveFile, out_dir: str | Path, timeout_s: float = 60) -> Path:
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / file.filename

    resp = requests.get(drive_download_url(file.file_id), stream=True, timeout=timeout_s)
    resp.raise_for_status()
    with out_path.open("wb") as f:
        for chunk in resp.iter_content(chunk_size=1024 * 256):
            if chunk:
                f.write(chunk)
    return out_path

from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path
from typing import Any

import yaml


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def secrets_path() -> Path:
    return project_root() / "secrets.yml"


@lru_cache(maxsize=1)
def load_secrets() -> dict[str, Any]:
    path = secrets_path()
    if not path.is_file():
        return {}

    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    return data if isinstance(data, dict) else {}


def get_google_sheets_api_key() -> str | None:
    for env_key in ("GOOGLE_SHEETS_API_KEY", "GOOGLE_API_KEY"):
        value = os.environ.get(env_key)
        if value and value.strip():
            return value.strip()

    value = load_secrets().get("google_sheets_api_key")
    if isinstance(value, str) and value.strip():
        return value.strip()
    return None

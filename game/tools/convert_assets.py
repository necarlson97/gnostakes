"""Convert the print-ready assets into files Godot can load.

    python game/tools/convert_assets.py

- game/assets/*.stl -> game/assets/models/*.obj (mm -> cm, recentred):
    vial_body, vial_cork            die centred on its long axis (local Z), length -10..10 mm
    face_<value>                    face inserts in die space, on the +Y side
                                    (value: blank, 1..9, E, W, F, A, Q)
    token_<E|W|F|A|Q>               loose tokens, centred, lying flat (thin along Y)
- print_and_play/export/game_cards/*.png -> game/assets/cards/<tarot id>.png (768 px),
  matched to data/cards.json by the same name slug the exporter uses.
"""

from __future__ import annotations

import json
import re
import struct
from pathlib import Path

import numpy as np
from PIL import Image

GAME = Path(__file__).resolve().parents[1]
ROOT = GAME.parent
ASSETS = GAME / "assets"
MODELS = ASSETS / "models"
CARDS_OUT = ASSETS / "cards"
CARDS_IN = ROOT / "print_and_play" / "export" / "game_cards"
SCALE = 0.1  # mm -> cm (the GUI works in centimetres)
CARD_PX = 768

ELEM = {"earth": "E", "water": "W", "fire": "F", "air": "A", "quintessence": "Q"}
NUM = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9}


def load_stl(path: Path) -> np.ndarray:
    b = path.read_bytes()
    n = struct.unpack("<I", b[80:84])[0]
    assert 84 + n * 50 == len(b), f"{path.name}: not a binary STL"
    dt = np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")])
    return np.frombuffer(b[84:], dtype=dt, count=n)["v"].astype(np.float64)  # (n, 3, 3)


def write_obj(tris: np.ndarray, path: Path) -> None:
    flat = np.round(tris.reshape(-1, 3), 4)
    verts, idx = np.unique(flat, axis=0, return_inverse=True)
    idx = idx.reshape(-1, 3)
    nrm = np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0])
    ln = np.linalg.norm(nrm, axis=1, keepdims=True)
    nrm = np.where(ln > 0, nrm / np.maximum(ln, 1e-12), [0, 1, 0])
    lines = [f"# {path.stem}"]
    lines += [f"v {x:.4f} {y:.4f} {z:.4f}" for x, y, z in verts]
    lines += [f"vn {x:.4f} {y:.4f} {z:.4f}" for x, y, z in nrm]
    # STL winding is counter-clockwise seen from outside; OBJ uses the same convention.
    lines += [f"f {a+1}//{i+1} {b+1}//{i+1} {c+1}//{i+1}" for i, (a, b, c) in enumerate(idx)]
    path.write_text("\n".join(lines) + "\n")


def convert_models() -> None:
    MODELS.mkdir(parents=True, exist_ok=True)
    die_shift = np.array([0.0, 0.0, -5.0])  # vial spans z -5..15 mm
    for f in sorted(ASSETS.glob("*.stl")):
        name = f.stem
        t = load_stl(f)
        if name == "vial dice - vial bottom":
            out, t = "vial_body", t + die_shift
        elif name == "vial dice - vial cork":
            out, t = "vial_cork", t + die_shift
        elif name.startswith("vial dice - crystal - "):
            key = name.rsplit(" - ", 1)[1]
            val = "blank" if key == "blank" else ELEM.get(key) or str(NUM[key])
            mn, mx = t.reshape(-1, 3).min(0), t.reshape(-1, 3).max(0)
            shift = np.array([-(mn[0] + mx[0]) / 2, 0.0, -mn[2]]) + die_shift
            out, t = f"face_{val}", t + shift
        elif name.startswith("tokens - token - "):
            key = name.rsplit(" - ", 1)[1]
            mn, mx = t.reshape(-1, 3).min(0), t.reshape(-1, 3).max(0)
            out, t = f"token_{ELEM[key]}", t - (mn + mx) / 2
        else:
            continue  # screw, nut, vial-insert tokens: not used on the table
        write_obj(t * SCALE, MODELS / f"{out}.obj")
        print(f"{f.name:45s} -> models/{out}.obj")


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-") or "card"


def convert_cards() -> None:
    CARDS_OUT.mkdir(parents=True, exist_ok=True)
    rows = json.loads((GAME / "data" / "cards.json").read_text(encoding="utf-8"))
    pngs = {re.sub(r"^\d+_", "", p.stem): p for p in CARDS_IN.glob("*.png")}
    missing = []
    for r in rows:
        p = pngs.get(slug(r["name"]))
        if p is None:
            missing.append(r["name"])
            continue
        im = Image.open(p).convert("RGB").resize((CARD_PX, CARD_PX), Image.LANCZOS)
        im.quantize(48, dither=Image.Dither.NONE).save(CARDS_OUT / f"{r['id']}.png", optimize=True)
    print(f"cards: {len(rows) - len(missing)}/{len(rows)} written to assets/cards/")
    if missing:
        print("  no PNG for:", ", ".join(missing))


if __name__ == "__main__":
    convert_models()
    convert_cards()

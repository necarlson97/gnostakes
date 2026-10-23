"""Export each card on a rendered card page as its own PNG.

Drives a headless browser (Playwright, using the installed Microsoft Edge) so
the output matches the browser layout exactly, including the JS text fitting
and art-contour wrapping on the experimental page.

    ./env/Scripts/python -m tools.export_pngs              # experimental cards, 300 DPI
    ./env/Scripts/python -m tools.export_pngs --dpi 600 --out export/hi-res
    ./env/Scripts/python -m tools.export_pngs --no-build    # use docs/ as already built
"""

from __future__ import annotations

import argparse
import functools
import http.server
import io
import math
import re
import sys
import threading
from pathlib import Path

from PIL import Image
from playwright.sync_api import sync_playwright

_ROOT = Path(__file__).resolve().parents[1]
_SRC = _ROOT / "src"
if str(_SRC) not in sys.path:
    sys.path.insert(0, str(_SRC))

from gnostakes.render import build_site

CSS_PX_PER_INCH = 96

# Hide page chrome and cut lines, and show one card at a time pinned to the
# page origin, so each PNG is exactly the card face at a whole-pixel size
# (cards in the grid sit at fractional pixel positions).
_EXPORT_CSS = """
  header { display: none !important; }
  body { margin: 0 !important; }
  .deck { display: block !important; border: none !important; padding: 0 !important; background: none !important; }
  .card { border: none !important; outline: none !important; }
  .card:not(.export-current) { display: none !important; }
"""

MM_PER_INCH = 25.4


def _slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-") or "card"


def _serve(directory: Path) -> http.server.ThreadingHTTPServer:
    handler = functools.partial(_QuietHandler, directory=str(directory))
    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    return httpd


class _QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args) -> None:
        pass


def export_cards(page_name: str, out_dir: Path, dpi: int, site_dir: Path) -> list[Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    httpd = _serve(site_dir)
    written: list[Path] = []
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(channel="msedge")
            page = browser.new_page(
                device_scale_factor=dpi / CSS_PX_PER_INCH,
                viewport={"width": 1400, "height": 1000},
            )
            page.goto(f"http://127.0.0.1:{httpd.server_port}/{page_name}", wait_until="load")
            # The experimental page reports fitting results once masks and fonts are done.
            if page.locator("#fit-status").count():
                page.wait_for_function("document.getElementById('fit-status').textContent !== ''")
            status = page.locator("#fit-status")
            if status.count():
                print(f"[export] {status.text_content()}", flush=True)

            # Exact card size from the page's CSS (mm), in output pixels and CSS px.
            card_mm = page.evaluate(
                """() => {
                  const css = getComputedStyle(document.querySelector('.card'));
                  const mm = (v) => parseFloat(v) * 25.4 / 96;  // computed values are CSS px
                  return [mm(css.width), mm(css.height)];
                }"""
            )
            scale = dpi / CSS_PX_PER_INCH
            out_px = [round(v / MM_PER_INCH * dpi) for v in card_mm]
            # The browser snaps clips to whole CSS px, so capture a little extra
            # and crop to the exact card size afterwards.
            clip = {
                "x": 0,
                "y": 0,
                "width": math.ceil(out_px[0] / scale),
                "height": math.ceil(out_px[1] / scale),
            }

            page.add_style_tag(content=_EXPORT_CSS)
            cards = page.locator(".card")
            total = cards.count()
            used: set[str] = set()
            for i in range(total):
                card = cards.nth(i)
                card.evaluate(
                    "(el) => { document.querySelectorAll('.export-current')"
                    ".forEach((c) => c.classList.remove('export-current'));"
                    " el.classList.add('export-current'); }"
                )
                name = (card.locator(".line.name").first.text_content() or "").strip()
                stem = f"{i + 1:02d}_{_slug(name)}"
                while stem in used:
                    stem += "_"
                used.add(stem)
                path = out_dir / f"{stem}.png"
                png = page.screenshot(clip=clip)
                with Image.open(io.BytesIO(png)) as im:
                    im.crop((0, 0, out_px[0], out_px[1])).save(path, dpi=(dpi, dpi))
                written.append(path)
            print(f"[export] card size {card_mm[0]:.1f}x{card_mm[1]:.1f}mm -> {out_px[0]}x{out_px[1]}px", flush=True)
            browser.close()
    finally:
        httpd.shutdown()
    return written


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--page", default="experimental_cards.html", help="page in docs/ to export")
    ap.add_argument("--out", type=Path, default=Path("export/experimental_cards"))
    ap.add_argument("--dpi", type=int, default=300)
    ap.add_argument("--no-build", action="store_true", help="skip rebuilding docs/ from the sheet")
    args = ap.parse_args()

    site_dir = _ROOT / "docs"
    if not args.no_build:
        info = build_site(_ROOT / "templates", site_dir)
        print(f"[build] ok (cards={info['cards_count']}, source={info['source']})", flush=True)

    out_dir = args.out if args.out.is_absolute() else _ROOT / args.out
    written = export_cards(args.page, out_dir, args.dpi, site_dir)
    print(f"[export] wrote {len(written)} PNGs at {args.dpi} DPI to {out_dir}", flush=True)


if __name__ == "__main__":
    main()

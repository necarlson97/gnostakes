from __future__ import annotations

import http.server
import socketserver
import threading
import time
from dataclasses import dataclass
from pathlib import Path

import sys

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer

_ROOT = Path(__file__).resolve().parents[1]
_SRC = _ROOT / "src"
if str(_SRC) not in sys.path:
    sys.path.insert(0, str(_SRC))

from gnostakes.render import build_site
from gnostakes.sources.google_drive_folder import DEFAULT_ASSETS_FOLDER_ID, sync_public_drive_folder


@dataclass(frozen=True)
class DevConfig:
    templates_dir: Path = Path("templates")
    src_dir: Path = Path("src")
    out_dir: Path = Path("docs")
    assets_dir: Path = Path("docs/assets/images")
    drive_folder_id: str = DEFAULT_ASSETS_FOLDER_ID
    host: str = "127.0.0.1"
    port: int = 8000


class _RebuildHandler(FileSystemEventHandler):
    def __init__(self, cfg: DevConfig):
        self.cfg = cfg
        self._last_build = 0.0

    def on_any_event(self, event):
        # Simple debounce to avoid double-build storms.
        now = time.time()
        if now - self._last_build < 0.25:
            return

        p = getattr(event, "src_path", "") or ""
        if "/__pycache__/" in p or p.endswith((".pyc", ".pyo")):
            return

        self._last_build = now
        try:
            info = build_site(self.cfg.templates_dir, self.cfg.out_dir)
            print(f"[build] ok (cards={info['cards_count']})", flush=True)
        except Exception as e:
            print(f"[build] failed: {e}", flush=True)


def _serve(cfg: DevConfig) -> None:
    cfg.out_dir.mkdir(parents=True, exist_ok=True)
    handler = lambda *args, **kwargs: http.server.SimpleHTTPRequestHandler(  # noqa: E731
        *args, directory=str(cfg.out_dir), **kwargs
    )
    with socketserver.TCPServer((cfg.host, cfg.port), handler) as httpd:
        print(f"[serve] http://{cfg.host}:{cfg.port}/ (serving {cfg.out_dir})", flush=True)
        httpd.serve_forever()


def _sync_drive_assets(cfg: DevConfig) -> None:
    cfg.assets_dir.mkdir(parents=True, exist_ok=True)
    try:
        info = sync_public_drive_folder(cfg.drive_folder_id, cfg.assets_dir, redownload_all=False)
        if info["listed"] > 0:
            print(
                "[assets] "
                f"listed={info['listed']} downloaded={info['downloaded']} "
                f"skipped={info['skipped']} errors={info['errors']}",
                flush=True,
            )
    except Exception as e:
        print(f"[assets] failed: {e}", flush=True)


def main() -> None:
    cfg = DevConfig()

    # Sync images once, then build before serving.
    _sync_drive_assets(cfg)

    try:
        info = build_site(cfg.templates_dir, cfg.out_dir)
        src = info.get("source", "?")
        print(f"[build] ok (cards={info['cards_count']}, source={src})", flush=True)
        if info.get("error"):
            print(f"[build] warning: {info['error']}", flush=True)
    except Exception as e:
        print(f"[build] failed: {e}", flush=True)

    # Serve in background thread.
    t = threading.Thread(target=_serve, args=(cfg,), daemon=True)
    t.start()

    # Watch templates + src for changes.
    observer = Observer()
    handler = _RebuildHandler(cfg)
    observer.schedule(handler, str(cfg.templates_dir), recursive=True)
    observer.schedule(handler, str(cfg.src_dir), recursive=True)
    observer.start()

    try:
        while True:
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("\n[dev] stopping...", flush=True)
    finally:
        observer.stop()
        observer.join(timeout=5)


if __name__ == "__main__":
    main()


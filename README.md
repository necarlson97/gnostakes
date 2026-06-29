# gnostakes (print-and-play)

Local Jinja2-based pipeline for a print-and-play card game:

- Pull card data from a **public** Google Sheet
- Auto-discover and download images from a **public** Google Drive folder (on dev startup)
- Render HTML from `templates/` into `docs/`
- Watch for changes and serve locally for quick iteration

## Setup

Create a virtualenv and install deps:

```bash
python3 -m venv env
./env/bin/python -m pip install -U pip
./env/bin/pip install -r pip-reqs.txt
cp secrets.yml.example secrets.yml
```

Optional: set `google_sheets_api_key` in `secrets.yml` to preserve bold/italic/underline from the sheet (env vars `GOOGLE_SHEETS_API_KEY` / `GOOGLE_API_KEY` override it).

## Dev (watch + build + serve)

```bash
./env/bin/python -m tools.dev
```

Then open `http://127.0.0.1:8000/`.

## Notes

- Template input lives in `templates/`
- Rendered output goes to `docs/`
- Google Sheet source is configured in `src/gnostakes/sources/google_sheets.py`
- Optional `secrets.yml` (see `secrets.yml.example`) enables bold/italic/underline from the sheet; without a key, card text is plain
- Google Drive folder auto-discovery + syncing lives in `src/gnostakes/sources/google_drive_folder.py`

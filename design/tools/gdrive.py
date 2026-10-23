"""Service-account access to the Gnostakes Google sources.

Key file: repo-root my-claude-*.json (gitignored), or GNOSTAKES_SA_KEY env var.
"""
import glob, os
from google.oauth2 import service_account
from googleapiclient.discovery import build

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RULES_DOC_ID = '1F1VmcLg27afFEdpl4rDSsd0a8nGG4ncYzk4tfvq3J1U'
CARDS_SHEET_ID = '1b6wk5AJfQ7ooa-zgk0gZcclUUBDrwRwfn6HNozuUrhE'
CARDS_TAB = 'Tarot Table'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/documents',
          'https://www.googleapis.com/auth/drive']


def creds():
    key = os.environ.get('GNOSTAKES_SA_KEY') or (glob.glob(os.path.join(ROOT, 'my-claude-*.json')) or [None])[0]
    if not key:
        raise FileNotFoundError('No service-account key found (set GNOSTAKES_SA_KEY)')
    return service_account.Credentials.from_service_account_file(key, scopes=SCOPES)


def sheets():
    return build('sheets', 'v4', credentials=creds(), cache_discovery=False).spreadsheets()


def docs():
    return build('docs', 'v1', credentials=creds(), cache_discovery=False).documents()


def card_rows():
    """Return (header, rows) of the cards tab as raw strings."""
    vals = sheets().values().get(spreadsheetId=CARDS_SHEET_ID, range=CARDS_TAB).execute().get('values', [])
    return vals[0], vals[1:]


def col_letter(i):
    s = ''
    i += 1
    while i:
        i, r = divmod(i - 1, 26)
        s = chr(65 + r) + s
    return s

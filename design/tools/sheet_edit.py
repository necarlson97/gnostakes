"""Apply exact substring edits to card-sheet cells, preserving rich-text runs (italics mark costs).

python sheet_edit.py EDITS.py          # dry run: print before/after per cell
python sheet_edit.py EDITS.py --apply  # write to the sheet

EDITS.py defines EDITS = [(cell, old, new), ...] with cell like 'G27'. Each `old` must occur in the cell;
every occurrence is replaced. A replaced span takes the formatting of the first character it replaces.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gdrive as g


def parse_cell(a1):
    m = re.fullmatch(r'([A-Z]+)(\d+)', a1)
    col = 0
    for ch in m.group(1):
        col = col * 26 + ord(ch) - 64
    return int(m.group(2)) - 1, col - 1


def expand(text, runs):
    fmt = [{}] * len(text)
    for k, r in enumerate(runs or []):
        s = r.get('startIndex', 0)
        e = runs[k + 1]['startIndex'] if k + 1 < len(runs) else len(text)
        for i in range(s, min(e, len(text))):
            fmt[i] = r.get('format', {})
    return fmt


def compress(fmt):
    runs = []
    for i, f in enumerate(fmt):
        if not runs or runs[-1]['format'] != f:
            runs.append({'startIndex': i, 'format': f})
    return runs


def replace(text, fmt, old, new):
    out_t, out_f, i, n = [], [], 0, 0
    while True:
        j = text.find(old, i)
        if j < 0:
            break
        out_t.append(text[i:j]); out_f.extend(fmt[i:j])
        f0 = fmt[j] if j < len(fmt) else {}
        out_t.append(new); out_f.extend([f0] * len(new))
        i = j + len(old); n += 1
    out_t.append(text[i:]); out_f.extend(fmt[i:])
    return ''.join(out_t), out_f, n


def main():
    ns = {}
    exec(open(sys.argv[1], encoding='utf-8').read(), ns)
    edits, apply = ns['EDITS'], '--apply' in sys.argv
    sh = g.sheets()
    meta = sh.get(spreadsheetId=g.CARDS_SHEET_ID, ranges=[g.CARDS_TAB], includeGridData=True,
                  fields='sheets.properties.sheetId,sheets.data.rowData.values(formattedValue,textFormatRuns)').execute()
    sheet = meta['sheets'][0]
    sheet_id, rows = sheet['properties']['sheetId'], sheet['data'][0]['rowData']
    cells = {}
    for a1, old, new in edits:
        r, c = parse_cell(a1)
        if a1 not in cells:
            v = rows[r]['values'][c]
            t = v.get('formattedValue', '')
            cells[a1] = dict(r=r, c=c, orig=t, text=t, fmt=expand(t, v.get('textFormatRuns')),
                             rich='textFormatRuns' in v)
        cell = cells[a1]
        cell['text'], cell['fmt'], n = replace(cell['text'], cell['fmt'], old, new)
        if n == 0:
            sys.exit(f'ABORT: {a1}: {old!r} not found in {cell["text"]!r}')
    reqs = []
    for a1, cell in cells.items():
        print(f'--- {a1}\n  - {cell["orig"]!r}\n  + {cell["text"]!r}')
        val = {'userEnteredValue': {'stringValue': cell['text']}}
        fields = 'userEnteredValue'
        if cell['rich']:
            val['textFormatRuns'] = compress(cell['fmt'])
            fields += ',textFormatRuns'
        reqs.append({'updateCells': {
            'range': {'sheetId': sheet_id, 'startRowIndex': cell['r'], 'endRowIndex': cell['r'] + 1,
                      'startColumnIndex': cell['c'], 'endColumnIndex': cell['c'] + 1},
            'rows': [{'values': [val]}], 'fields': fields}})
    print(f'{len(cells)} cells, {len(edits)} edits')
    if apply:
        sh.batchUpdate(spreadsheetId=g.CARDS_SHEET_ID, body={'requests': reqs}).execute()
        print('APPLIED')


if __name__ == '__main__':
    main()

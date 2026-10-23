"""Export the card sheet snapshot to game/data/cards.json.

Also derives signed strategy features per face (tools/card_features.py) and writes the
audit table design/card_features.md.

Source: design/source_snapshot/cards.csv (re-pull it from Google first; the sheet is the
source of truth). Card ids come from tarot identity, which survives renames:
major_00..major_21, and <element>_01..10 / _princess / _prince / _queen / _king.

    python game/tools/sync_cards.py
"""
import csv, json, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import card_features

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, 'design', 'source_snapshot', 'cards.csv')
DST = os.path.join(ROOT, 'game', 'data', 'cards.json')
ROMAN = {r: i for i, r in enumerate('0 I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX XX XXI'.split())}


def card_id(row):
    num, element = row['Numeral'].strip(), row[''].strip()
    if element == 'Major Arcana':
        return 'major_%02d' % ROMAN[num]
    return '%s_%s' % (element.lower(), '%02d' % int(num) if num.isdigit() else num.lower())


def main():
    with open(SRC, encoding='utf-8') as f:
        rows = [r for r in csv.DictReader(f) if r['Name'].strip()]
    out = []
    for r in rows:
        clean = lambda s: re.sub(r'[ \t]+\n', '\n', s.replace('\r', '')).strip()
        out.append({'id': card_id(r), 'suit': r['Suit'], 'element': r[''], 'rank': r['Rank'],
                    'name': r['Name'].strip(), 'rule': clean(r['Rule']),
                    'inv_name': r['Inverted Name'].strip(), 'inv_rule': clean(r['Inverted Rule'])})
    assert len({c['id'] for c in out}) == len(out), 'duplicate card ids'
    overrides = card_features.load_overrides()
    for c in out:
        c['features'] = card_features.features_for(c, overrides)
    card_features.report(out, os.path.join(ROOT, 'design', 'card_features.md'))
    os.makedirs(os.path.dirname(DST), exist_ok=True)
    with open(DST, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
    print('wrote %d cards to %s' % (len(out), DST))


if __name__ == '__main__':
    main()

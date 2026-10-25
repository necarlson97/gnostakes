"""Ability-economy statistics and document, from league results with the ability meter.

Every ability line (a triggered hook, a replacement, or an activated ability: one method on
a card face script) is listed, including lines that never fired. An *activation* means the
line actually did something (gained, paid, moved a die, buried, claimed...), not merely that
its trigger came up. Rates are per game the card was held, split by winners and others.

Used by league.py (writes design/sim_abilities.md); also runnable on saved results:
    python game/tools/abilities.py game/sim/results/<run>
"""
import json, os, re, sys, time
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
GAME = os.path.dirname(HERE)
ROOT = os.path.dirname(GAME)
DOC = os.path.join(ROOT, 'design', 'sim_abilities.md')
LINE = re.compile(r'^\tfunc ((?:on|act|replace)_[a-z_]+)\(', re.M)
MIN_HELD = 30          # rate tables only for cards held at least this many times


def script_lines(path, cid):
    """face id -> [ability line methods] declared in one card script (Top = upright, Inv = :inv)."""
    out = {}
    src = open(path, encoding='utf-8').read()
    parts = re.split(r'^class (Top|Inv) extends Ability:.*$', src, flags=re.M)
    for i in range(1, len(parts) - 1, 2):
        fid = cid if parts[i] == 'Top' else cid + ':inv'
        out[fid] = sorted(set(LINE.findall(parts[i + 1])))
        if re.search(r"relinquish = \{", parts[i + 1]) and 'act_relinquish' not in out[fid]:
            out[fid].append('act_relinquish')   # provided by Ability, declared via acts()
    return out


def code_lines(variant=''):
    """face id -> [ability line methods] for every card (a variant's scripts replace the base)."""
    out = {}
    for f in os.listdir(os.path.join(GAME, 'cards')):
        if not f.endswith('.gd'): continue
        cid = f[:-3]
        vp = os.path.join(GAME, 'cards', 'variants', variant, f) if variant else ''
        out.update(script_lines(vp if vp and os.path.exists(vp) else os.path.join(GAME, 'cards', f), cid))
    return out


def rel(p):
    try: return os.path.relpath(p, ROOT).replace(os.sep, '/')
    except ValueError: return p


def label(m):
    if m.startswith('act_'): return 'activated: ' + m[4:]
    if m.startswith('replace_'): return 'instead of ' + m[8:].replace('_', ' ')
    if m.startswith('on_any_'): return 'when anyone ' + m[7:].replace('_', ' ')
    return 'on ' + m[3:].replace('_', ' ')


def stats(games, cards):
    held = defaultdict(lambda: [0, 0.0])          # card id -> [seats holding it, wins among them]
    A = defaultdict(lambda: {'n': 0, 'n_win': 0.0, 'keys': 0, 'tokens': defaultdict(int), 'spent': defaultdict(int),
                             'teeth_self': 0, 'teeth_other': 0, 'teeth_gained': 0})
    for g in games:
        for s in g['seats']:
            for cid in set(s['claims']):
                held[cid][0] += 1
                held[cid][1] += s['win']
            for fid, lines in s.get('abilities', {}).items():
                for m, r in lines.items():
                    a = A[(fid, m)]
                    a['n'] += r['n']; a['n_win'] += r['n'] * s['win']; a['keys'] += r['keys']
                    for t, n in r['tokens'].items(): a['tokens'][t] += n
                    for t, n in r['spent'].items(): a['spent'][t] += n
                    a['teeth_self'] += r['teeth_self']; a['teeth_other'] += r['teeth_other']; a['teeth_gained'] += r['teeth_gained']
    return held, A


def write(games, path=DOC, run_dir='', meta=None):
    cards = {c['id']: c for c in json.load(open(os.path.join(GAME, 'data', 'cards.json'), encoding='utf-8'))}
    face_name = lambda fid: cards[fid.split(':')[0]]['inv_name' if fid.endswith(':inv') else 'name']
    face_text = lambda fid: cards[fid.split(':')[0]]['inv_rule' if fid.endswith(':inv') else 'rule']
    held, A = stats(games, cards)
    lines = code_lines()
    for fid, ms in lines.items():           # every line in code appears, even if it never fired
        for m in ms: A[(fid, m)]
    total_keys = sum(a['keys'] for a in A.values()) or 1
    total_n = sum(a['n'] for a in A.values()) or 1

    def rates(fid, m):
        a = A[(fid, m)]
        h, hw = held[fid.split(':')[0]]
        per = a['n'] / h if h else 0.0
        per_w = a['n_win'] / hw if hw else 0.0
        per_o = (a['n'] - a['n_win']) / (h - hw) if h - hw > 0 else 0.0
        return h, per, per_w, per_o

    rows = []
    for (fid, m), a in A.items():
        if fid.split(':')[0] not in cards: continue
        h, per, per_w, per_o = rates(fid, m)
        rows.append({'fid': fid, 'm': m, 'held': h, 'per': per, 'per_w': per_w, 'per_o': per_o,
                     'lift': per_w / per_o if per_o > 0 else (float('inf') if per_w > 0 else 0.0), **a})

    L = []
    add = L.append
    add('# Gnostakes ability economy')
    add('')
    add('*Overwritten after every finished league run, alongside [sim_report.md](sim_report.md). Written %s.*' % time.strftime('%Y-%m-%d %H:%M'))
    add('')
    add('From %d games%s. One **ability line** is one triggered effect, replacement, or activated ability on a card face '
        '(one method in its script). An **activation** is a time it actually did something: gained, paid, moved or '
        'discarded a die, buried, claimed, incinerated. It is not counted just because its trigger came up. '
        'Rates are **per game the card was held**: "winners" means games where the holder won, "others" means games where they didn\'t. '
        '**Lift** = winners\' rate / others\' rate; above 1 means winners fire it more.' % (
            len(games), (' (`%s`)' % rel(run_dir)) if run_dir else ''))
    add('')
    add('Lines that only change rules ("While this is active...", "You can now score...") have no activations to count. '
        'Their effect shows in the card\'s holder win rate in sim_report.md.')
    add('')

    live = [r for r in rows if r['held'] >= MIN_HELD]
    fmt_tok = lambda d: ' '.join('%s%g' % (t, d[t]) for t in sorted(d, key=lambda t: -d[t]) if d[t]) or ''
    per_act = lambda d, n: {t: round(v / n, 1) for t, v in d.items()} if n else {}

    add('## Busiest lines')
    add('')
    add('| Card face | Line | Per game held | Winners | Others | Lift | Keys/act | Tokens/act | Spent/act |')
    add('|---|---|---:|---:|---:|---:|---:|---|---|')
    for r in sorted(live, key=lambda r: -r['per'])[:20]:
        add('| %s | %s | %.2f | %.2f | %.2f | %s | %.2f | %s | %s |' % (face_name(r['fid']), label(r['m']), r['per'], r['per_w'], r['per_o'],
            '%.2f' % r['lift'] if r['lift'] != float('inf') else 'winners only', r['keys'] / r['n'] if r['n'] else 0,
            fmt_tok(per_act(r['tokens'], r['n'])), fmt_tok(per_act(r['spent'], r['n']))))
    add('')

    quiet = [r for r in live if r['per'] < 0.2]
    add('## Quiet lines (fewer than 0.2 activations per game held)')
    add('')
    add('%d of %d ability lines on cards held at least %d times. Never fired: **%d**.' % (
        len(quiet), len(live), MIN_HELD, sum(1 for r in live if r['n'] == 0)))
    add('')
    add('| Card face | Line | Activations | Per game held | Card held |')
    add('|---|---|---:|---:|---:|')
    for r in sorted(quiet, key=lambda r: r['per']):
        add('| %s | %s | %d | %.3f | %d |' % (face_name(r['fid']), label(r['m']), r['n'], r['per'], r['held']))
    add('')

    add('## Key economy by line')
    add('')
    add('Lines that produced keys, by share of all keys in the run.')
    add('')
    add('| Card face | Line | Keys | Share | Keys/act | Activations per game held | Winners | Others |')
    add('|---|---|---:|---:|---:|---:|---:|---:|')
    for r in sorted((r for r in rows if r['keys']), key=lambda r: -r['keys'])[:30]:
        add('| %s | %s | %d | %.1f%% | %.2f | %.2f | %.2f | %.2f |' % (face_name(r['fid']), label(r['m']), r['keys'],
            100 * r['keys'] / total_keys, r['keys'] / max(1, r['n']), r['per'], r['per_w'], r['per_o']))
    add('')

    add('## Token economy by line')
    add('')
    for t in 'EWFAQ':
        src = sorted((r for r in rows if r['tokens'].get(t)), key=lambda r: -r['tokens'][t])
        snk = sorted((r for r in rows if r['spent'].get(t)), key=lambda r: -r['spent'][t])
        made, used = sum(r['tokens'][t] for r in src), sum(r['spent'][t] for r in snk)
        add('**%s**: produced %d, spent through card abilities %d.' % (t, made, used))
        add('- Sources: ' + ('; '.join('%s (%s) %d' % (face_name(r['fid']), label(r['m']), r['tokens'][t]) for r in src[:6]) or 'none'))
        add('- Sinks: ' + ('; '.join('%s (%s) %d' % (face_name(r['fid']), label(r['m']), r['spent'][t]) for r in snk[:6]) or 'none'))
        add('')

    add('## Every card, every line')
    add('')
    add('Per activation: keys, tokens gained, tokens spent, teeth lost by the holder, teeth taken from others, teeth regained.')
    add('')
    by_card = defaultdict(list)
    for r in rows: by_card[r['fid'].split(':')[0]].append(r)
    for cid in sorted(by_card, key=lambda c: (cards[c]['suit'], c)):
        h, hw = held[cid]
        add('### %s / %s (`%s`), held %d times, holder won %.0f%%' % (cards[cid]['name'], cards[cid]['inv_name'], cid, h, 100 * hw / h if h else 0))
        add('')
        for fid in (cid, cid + ':inv'):
            rs = sorted((r for r in by_card[cid] if r['fid'] == fid), key=lambda r: r['m'])
            add('**%s**%s: %s' % (face_name(fid), ' (inverted)' if fid.endswith(':inv') else '', ' / '.join(l for l in face_text(fid).split('\n') if l.strip())))
            add('')
            if not rs:
                add('*Rules-only face: nothing to count.*')
                add('')
                continue
            add('| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |')
            add('|---|---:|---:|---:|---:|---:|---|---|---|')
            for r in rs:
                n = r['n'] or 1
                add('| %s | %d | %.2f | %.2f | %.2f | %.2f | %s | %s | %.2f / %.2f / %.2f |' % (
                    label(r['m']), r['n'], r['per'], r['per_w'], r['per_o'], r['keys'] / n, fmt_tok(per_act(r['tokens'], r['n'])),
                    fmt_tok(per_act(r['spent'], r['n'])), r['teeth_self'] / n, r['teeth_other'] / n, r['teeth_gained'] / n))
            add('')
    with open(path, 'w', encoding='utf-8') as fh: fh.write('\n'.join(L) + '\n')
    if run_dir:
        with open(os.path.join(run_dir, 'abilities.md'), 'w', encoding='utf-8') as fh: fh.write('\n'.join(L) + '\n')
    print('ability report written to %s' % path)
    return rows


if __name__ == '__main__':
    sys.path.insert(0, HERE)
    import league
    d = sys.argv[1]
    write(league.load(d), run_dir=d)

"""Derive signed strategy features from card text.

Each face gets a sparse dict of feature -> float. The sign is the face's attitude:
  straight +1   "You can now score straights with a gap" / "On scoring a straight: gain a key"
  straight -1   "You cannot score any straights" / "Whenever you score a straight: incinerate this card"

How it works: the text is split into statements. A statement with a condition and an
effect ("Whenever you score a straight: incinerate this card") gives the condition's
features the *polarity* of the effect. The effect's own contents (gain 2F, spend 3W,
lose a tooth, ...) are features too. Anything the regexes get wrong is fixed in
data/feature_overrides.json. Audit the output in design/card_features.md.
"""
import json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
OVERRIDES = os.path.join(HERE, '..', 'data', 'feature_overrides.json')

FEATURES = (
    ['straight', 'kind', 'color', 'pairs', 'nothing']
    + ['gain_' + t for t in 'EWFAQ'] + ['use_' + t for t in 'EWFAQ'] + ['crystal_' + t for t in 'EWFA']
    + ['keys', 'teeth', 'teeth_cost', 'teeth_payoff', 'teeth_guard', 'aggro', 'relinquish', 'burn_payoff', 'burn_cost',
       'discard_payoff', 'dice_control', 'bonus_die', 'open_slots', 'potency', 'win']
)

SET_FAMILIES = {
    'straight': r'straight',
    'kind': r'triplet|quadruplet|quadruple',
    'color': r'of a color|of fire|four (?:earth|water|fire|air)|five [af] dice|all colors|x of a color',
    'pairs': r'color-pairs|four pairs',
    'nothing': r'score(?:d)? nothing|did not score|score anything else',
}
ELEMENT_WORDS = {'earth': 'E', 'water': 'W', 'fire': 'F', 'air': 'A'}

POSITIVE = r'\bgain|\bbury\b|regain|\bclaim|you win|\brotate|uncommit|undiscard|double|score a set again|can now|instead you may|get them all back|copies|\bget\b'
NEGATIVE = (r'incinerate this(?! card to)(?: card)?(?!,? and gain| to)|lose (?:a|1|one|two|2|3|all)? ?(?:tooth|teeth)'
            r'|lose (?:1 |a )?key|cannot|get 0 keys|discard 1 die|must incinerate')
TOKEN = r'(?<![A-Za-z])([EWFAQ])(?![a-z])(?!\.g)'
# Things done TO opponents read as good for you, not as your own losses.
AT_OPPONENT = r'(?:force|make)s? [^.:]*?lose (?:a|1|one)? ?tooth|opponents? (?:to )?loses?[^.:]*|they lose[^.:]*'
# "spend 2F to gain a key": only the part after " to " is the payoff.
COST_TO = r'^(?:you may )?(?:spend|lose|pay|incinerate|discard|expend)\b.*? to:? (.+)$'


def statements(text):
    """Split rule text into logical statements, re-joining wrapped lines."""
    out = []
    for raw in text.replace('\r', '').split('\n'):
        line = raw.strip()
        if not line:
            if out and out[-1] != '': out.append('')
            continue
        prev = out[-1] if out else ''
        cont = prev and (prev.endswith((':', ',', ' or', ' to', '-')) or line.startswith(('*', '(', 'to ', 'or '))
                         or line[0].islower())
        if cont:
            out[-1] = prev + ' ' + line
        else:
            out.append(line)
    return [s for s in out if s]


def polarity(effect):
    m = re.match(COST_TO, effect.strip(), re.I)
    if m: effect = m.group(1)
    if re.search(AT_OPPONENT, effect, re.I): return 1.0
    pos = re.search(POSITIVE, effect, re.I) is not None
    neg = re.search(NEGATIVE, effect, re.I) is not None
    if pos and neg: return 0.5   # a cash-out: "gain a key and incinerate this card"
    if neg: return -1.0
    return 1.0 if pos else 0.0


def add(f, k, v):
    if v: f[k] = round(f.get(k, 0.0) + v, 3)


def token_mentions(clause, f, sign=1.0):
    """Classify each token letter by the nearest verb before it."""
    for m in re.finditer(TOKEN, clause):
        before = clause[max(0, m.start() - 45):m.start()].lower()
        verbs = {
            'use': max(before.rfind(w) for w in ('spend', 'pay ', 'expend', 'spending')),
            'gain': max(before.rfind(w) for w in ('gain', 'get ', 'bury', 'convert all')),
            'crystal': max(before.rfind(w) for w in ('rolling', 'roll ', 'show', 'set with', 'without', 'commit', 'crystal', 'face', 'die of', 'die that is', 'faces', 'rotate it to', 'all e')),
        }
        kind, at = max(verbs.items(), key=lambda kv: kv[1])
        t = m.group(1)
        if at < 0: continue
        if kind == 'crystal':
            if t == 'Q': continue
            neg = 'without' in before[at:]
            add(f, 'crystal_' + t, -sign if neg else sign)
        else:
            add(f, '%s_%s' % (kind, t), 1.0)


def face_features(text):
    f = {}
    if not text.strip(): return f
    for st in statements(text):
        low = st.lower()
        cond, effect = (st.split(':', 1) + [''])[:2] if ':' in st else ('', st)
        lc = cond.lower()
        pol = polarity(effect) if cond else 0.0

        # set families: in the condition they take the effect's polarity; in static rules
        # "can now" is +, "cannot" is -.
        banned = re.search(r'cannot score|can only score', low)
        for fam, rx in SET_FAMILIES.items():
            if banned and re.search(rx, low): add(f, fam, -1.0)
            elif cond and re.search(rx, lc): add(f, fam, pol or 0.5)
            elif not cond and re.search(rx, low):
                add(f, fam, -1.0 if re.search(r'cannot|can only', low) else 1.0)
        for word, t in ELEMENT_WORDS.items():
            if re.search(r'(?:four|five) (?:of )?' + word, low): add(f, 'crystal_' + t, 1.0)
        # "a set with(out) F", "rolling an E" etc. are crystal preferences signed by the effect
        token_mentions(cond, f, sign=pol if pol else 1.0)
        token_mentions(effect, f)

        if re.search(r'gain (?:1 |2 |a |an additional |one )?keys?\b|gain (?:that many|1|2) keys?|you get [12] keys?|take a key', low): add(f, 'keys', 1.0)
        if re.search(r'lose (?:1 |a )?key\b', low): add(f, 'keys', -0.5)
        if re.search(r':\s*you win', low): add(f, 'win', 1.0)
        if re.search(r'would lose a tooth|cannot lose teeth|cannot make you lose teeth|instead (?:you may )?pay', low): add(f, 'teeth_guard', 1.0)
        elif re.search(r'lose (?:a )?tooth', lc) and not re.search(r'opponent|another player|they', lc):
            add(f, 'teeth_payoff', 1.0)   # "Whenever you lose a tooth: <reward>" pays off tooth loss
        elif re.search(r'(?<!opponent )(?<!they )(?<!player )lose (?:a|1|one|two|2|3|all)? ?(?:tooth|teeth)', low) \
                and not re.search(r'opponent[s]? (?:to )?lose|force', low):
            # "lose a tooth ... to <reward>" / "spend 1 tooth to" is a one-off optional cost;
            # anything else ("whenever ...: lose 1 tooth") is a recurring drain.
            is_cost = re.search(r'lose (?:a|1|one|two|2|3)? ?(?:tooth|teeth)[^.:]*?\bto\b|spend 1 tooth', low)
            add(f, 'teeth_cost' if is_cost else 'teeth', -1.0)
        if re.search(r'regain|gain a tooth|gain a tooth|get them all back|regain 2 teeth|they gain a tooth', low): add(f, 'teeth', 1.0)
        if re.search(r'opponents? (?:to )?loses?|force (?:a player|all opponents|an opponent)|they lose|must incinerate an additional', low): add(f, 'aggro', 1.0)
        if 'relinquish' in low: add(f, 'relinquish', 1.0)
        if re.search(r'whenever (?:you|a player) incinerates? a card|if you incinerated|incinerate two cards in a single', low): add(f, 'burn_payoff', 1.0)
        if re.search(r'incinerate (?:a|two|all your) cards?(?! in)|incinerate two other', low): add(f, 'burn_cost', 1.0)
        if re.search(r'whenever you discard|discard (?:a|two) (?:potency )?dic?e? to|discard that die', low): add(f, 'discard_payoff', 1.0)
        if re.search(r'rotate|uncommit|undiscard|reroll|swap any two|swap in|swap all|replace a crystal|replace any crystal|only need to commit', low): add(f, 'dice_control', 1.0)
        if re.search(r'bonus (?:potency )?die|gain another (?:elemental|potency) die|gain an? [EWFA] face|face of any color', st, re.I): add(f, 'bonus_die', 1.0)
        if re.search(r'empty card slot|only 2 other active', low): add(f, 'open_slots', 1.0)
        if re.search(r'potency by|in a 6 for|a 1 with a 9|for a single number', low): add(f, 'potency', 1.0)
    return f


def load_overrides():
    if not os.path.exists(OVERRIDES): return {}
    with open(OVERRIDES, encoding='utf-8') as fh:
        return {k: v for k, v in json.load(fh).items() if not k.startswith('_')}


def features_for(card, overrides):
    out = {}
    for face, key in (('top', 'rule'), ('inv', 'inv_rule')):
        f = face_features(card[key])
        for k, v in overrides.get('%s.%s' % (card['id'], face), {}).items():
            if v == 0: f.pop(k, None)
            else: f[k] = v
        bad = set(f) - set(FEATURES)
        assert not bad, (card['id'], bad)
        out[face] = dict(sorted((k, v) for k, v in f.items() if v))
    return out


def report(cards, path):
    """Markdown audit table: one row per face."""
    rows = ['# Card features (generated by game/tools/card_features.py)', '',
            'Signed features parsed from card text, plus `game/data/feature_overrides.json`. '
            'Positive means the face likes it; negative means the face punishes it.', '',
            '| Card | Face | Features |', '|---|---|---|']
    for c in cards:
        for face, name in (('top', c['name']), ('inv', c['inv_name'])):
            fs = c['features'][face]
            txt = ' · '.join('%s %+g' % (k, v) for k, v in fs.items()) or '(none)'
            rows.append('| %s | %s%s | %s |' % (c['id'], name, ' (inv)' if face == 'inv' else '', txt))
    with open(path, 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(rows) + '\n')

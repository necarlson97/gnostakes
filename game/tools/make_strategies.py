"""Generate game/ai/strategies/*.json: the strategy definitions bots read.

Strategies are data built from small templates, so a family (every token, every token
pair) stays consistent. Edit here and re-run; don't hand-edit the JSON.

    python game/tools/make_strategies.py

Fields (see ai/strategy.gd): features = weights on card features (tools/card_features.py),
sets = multipliers per set family, tokens = multipliers on token prices, teeth = tooth
fear, cadre = preferred cadre size. Learned numbers (viability) live in ai/data/, not here.
"""
import itertools, json, os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'ai', 'strategies')
ELEMENT = {'E': 'earth', 'W': 'water', 'F': 'fire', 'A': 'air'}
KEYS = 0.4   # every strategy still likes keys a little: they win the game


def strat(doc, features, sets=None, tokens=None, teeth=1.0, cadre=4):
    return {'doc': doc, 'features': {**features, 'keys': features.get('keys', KEYS)},
            'sets': sets or {}, 'tokens': tokens or {}, 'teeth': teeth, 'cadre': cadre}


def token_strategy(ts, weight=0.8):
    """Gain and spend these tokens; elements also like their crystal faces."""
    f, tok = {}, {}
    for t in ts:
        f['gain_' + t] = weight
        f['use_' + t] = weight
        if t in ELEMENT: f['crystal_' + t] = weight / 2
        tok[t] = 1.0 + weight * 0.75
    names = '+'.join(ELEMENT.get(t, 'quintessence') for t in ts)
    return strat('Token economy: gain and spend %s.' % names, f, tokens=tok)


S = {
    # --- generalists
    'balanced': strat('No preference: takes whatever is strong. The adaptive bot\'s baseline.',
                      {'keys': 0.6, 'teeth_guard': 0.2, 'teeth': 0.2, 'dice_control': 0.2, 'bonus_die': 0.2}),
    # --- set families
    'straights': strat('Loves straights: Potency control, gap and short-straight rules.',
                       {'straight': 1.0, 'potency': 0.5, 'dice_control': 0.3, 'kind': -0.3}, {'straight': 1.6, 'kind': 0.6}),
    'kinds': strat('Loves triplets and quadruplets.',
                   {'kind': 1.0, 'potency': 0.4, 'dice_control': 0.3, 'straight': -0.3}, {'kind': 1.6, 'straight': 0.6}),
    'colors': strat('Loves colour sets: Four/Five of a Color, Four Air, All Colors.',
                    {'color': 1.0, 'crystal_E': 0.2, 'crystal_W': 0.2, 'crystal_F': 0.2, 'crystal_A': 0.3, 'dice_control': 0.3},
                    {'color': 1.6, 'pairs': 1.1}),
    'pairs': strat('Loves pair sets: Two Color-Pairs and Four Pairs.',
                   {'pairs': 1.0, 'color': 0.3, 'dice_control': 0.3}, {'pairs': 1.8, 'color': 1.1}),
    'high_roller': strat('Chases the hardest sets (two requests each) and instant wins.',
                         {'win': 1.0, 'dice_control': 0.5, 'bonus_die': 0.5, 'straight': 0.3, 'kind': 0.3, 'color': 0.3},
                         {'straight': 1.4, 'kind': 1.4, 'color': 1.4, 'pairs': 0.8}),
    'nihilist': strat('Scores nothing on purpose: Tosspot, Lethean Elder, Glass-Eyed Alchemist, Ayahuascite.',
                      {'nothing': 1.2, 'discard_payoff': 0.4}, {'straight': 0.4, 'kind': 0.4, 'color': 0.4, 'pairs': 0.4}),
    # --- dice and cards
    'sculptor': strat('Builds better dice: face edits, Potency shifts, bonus dice.',
                      {'potency': 1.0, 'bonus_die': 0.8, 'dice_control': 0.6}),
    'discarder': strat('Discard engine: Branded Protégé, Pot-Licking Friar, Sinuous Acolyte, Spagyric Physician.',
                       {'discard_payoff': 1.0, 'dice_control': 0.3}),
    'open_slots': strat('Keeps a small cadre: Hollowhead, Promethean Pyro, Faustian Scholar.',
                        {'open_slots': 1.2, 'keys': 0.6, 'burn_cost': 0.3}, cadre=2),
    'burner': strat('Incineration engine: cards that pay off when cards burn.',
                    {'burn_payoff': 1.0, 'burn_cost': 0.5}),
    # --- tempo and conflict
    'key_rusher': strat('Cashes out for keys as fast as possible; doesn\'t build an engine.',
                        {'keys': 1.2, 'use_E': 0.2, 'use_W': 0.2, 'use_F': 0.2, 'use_A': 0.2, 'use_Q': 0.2}, teeth=0.8),
    'attrition': strat('Gets ahead, then burns teeth to end the game (Putrescence) while leading.',
                       {'keys': 0.8, 'aggro': 0.6, 'teeth': -0.3, 'teeth_payoff': 0.5}, teeth=0.4),
    'saboteur': strat('Hurts opponents: relinquished curses and tooth attacks.',
                      {'aggro': 1.0, 'relinquish': 0.8, 'teeth_guard': 0.4, 'keys': 0.3}, teeth=0.7),
    'tooth_miser': strat('Protects teeth and drags the game out.',
                         {'teeth_guard': 1.0, 'teeth': 0.8, 'teeth_cost': 0.5}, teeth=2.0),
    # --- token economies
    'economist': strat('Uses every token type: wants income and sinks for all of them.',
                       {**{'gain_' + t: 0.4 for t in 'EWFAQ'}, **{'use_' + t: 0.4 for t in 'EWFAQ'}},
                       tokens={t: 1.25 for t in 'EWFAQ'}),
    'quintessence': token_strategy('Q', 1.0),
}
for t, name in ELEMENT.items():
    S[name] = token_strategy(t)
for a, b in itertools.combinations('EWFA', 2):
    S['%s_%s' % (ELEMENT[a], ELEMENT[b])] = token_strategy(a + b, 0.6)

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.endswith('.json'): os.remove(os.path.join(OUT, f))
    for name, d in sorted(S.items()):
        with open(os.path.join(OUT, name + '.json'), 'w', encoding='utf-8') as fh:
            json.dump({'name': name, **d}, fh, indent=1, ensure_ascii=False)
    print('wrote %d strategies: %s' % (len(S), ', '.join(sorted(S))))

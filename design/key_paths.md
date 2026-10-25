# Every way to get a key (2026-10-24)

Card data: `design/source_snapshot` as pulled 2026-10-24 02:03 (synced into `game/data/cards.json`).

Two measurements:
1. **Dice odds (exact).** These come from `design/tools/smartplay.py`. The model is the base kit (5 Potency d6 + 5 Elemental E,E,W,W,F,A), with at least 5 dice committed per roll. It gives the chance per Swig of hitting the key condition when you play only for it. It covers no cards and no face edits.
2. **League (empirical).** League run `game/sim/results/20261024-020959`: 1,600 four-player games with all 28 bots and `win_keys=7`.
   - **Keys/claim:** keys the card produced per time it was claimed.
   - **P(key):** the share of player-games holding the card in which it produced at least one key.
   - **Win-key share:** the share of all winners' keys that came from this card.
   - Keys from multipliers (Hollowhead, Butcher, Prophet) are credited to the multiplier.

Overall: 41 faces grant keys and 5 more deny or reprice them. Average card: 0.31 keys/claim (all 78 cards).

---

## 1. Score a set → key (dice-gated)

| Face (card) | Condition | Cost / side effect | Repeats? | P per Swig, targeted | Swigs to hit | League keys/claim | P(key) |
|---|---|---|---|---:|---:|---:|---:|
| Lethean Elder (6 Cups) | score nothing | burn **all** your cards; **+2 keys** | once | ~100%¹ | 1 | 1.03 | 52% |
| Gout-Ridden Glutton (9 Cups) | no discarded dice at Scry start | lose all W/E, burn | once | ~100%¹ | 1 | 0.83 | 82% |
| Pilfered Penname (2 Cups) | any straight | burn | once | 77% | 1.3 | 0.69 | 69% |
| Sun-Blinded Prismist (Ace Swords) | a set with an A | burn | once | 65% | 1.5 | 0.67 | 67% |
| Active Assistant (2 Disks) | Triplet | burn | once | 54% | 1.8 | 0.69 | 69% |
| Charitable Ciderist (Ace Disks) | Four Earth | burn | once | 27% | 3.8 | 0.41 | 41% |
| Bacchus Host (Ace Cups) | Four Water | burn | once | 27% | 3.8 | 0.42 | 42% |
| Fleabitten Penitent (8 Cups) | Five Straight | **lose a tooth on every other Scry** | yes | 13% | 7.7 | 0.03 | 3% |
| Promising Pugilist (Chariot) | chosen: Quadruplet / Five Straight / Five of a Color / Four Air | lose a tooth (if >1) | yes | 13 / 13 / 9 / 3% | 8–30 | 0.03 | 3% |
| Nubile Nymph (Princess Cups) | "could score" Four/Five Straight, 3 times | uncommit a die each time | once | 41% (×3) | ~7 | 0.00 | 0% |
| Doomed Pandorite (Ace Wands) | Four Fire | burn | once | **3.3%** | 30 | 0.03 | 3% |
| Expendable Assistant (2 Wands) | Four Fire | burn | once | **3.3%** | 30 | 0.03 | 3% |
| Bloodstained Recluse (9 Wands) | Four Fire | burn all; +2 keys | once | **3.3%** | 30 | 0.04 | 2% |
| Candid Jester (2 Swords) | Four Air | burn | once | **3.3%** | 30 | 0.02 | 2% |

¹ Discarding is always allowed, so you can score nothing on purpose. Glutton only needs you to discard nothing.

Face edits that move the odds:
- **Jar Dweller (F↔A):** Four Fire / Four Air go from 3.3% to 26%.
- **Patient Confidant (E↔W):** Four Earth / Four Water go from 27% to 90%.
- **A 6th elemental die** (Kismet Syzygyst, Barefoot Pilgrim): Four Fire goes to 11%, Four Earth to 55%.
- **Post-Fate Oblate** (fire counts as Four Air): either one hits 5.8%.

## 2. Pay tokens → key

| Face (card) | Price | Burns? | Repeats? | Self-funding on the same face | League keys/claim | P(key) |
|---|---|---|---|---|---:|---:|
| Brawny Striker (10 Disks) | every Scheme start: 2 teeth **or** burn 2 cards **or** 8E **or** 4Q | no | **every round** | none needed (teeth/cards) | **3.49** | 88% |
| Overworked Gravedigger (5 Swords) | 5A | no | yes | +1A every Swig | 1.09 | 56% |
| Lash-Blessed Monk (4 Swords) | 2A, **or free** when another player gains a key | yes | once | the free path is reactive | 0.86 | 84% |
| Powder Miller (4 Wands) | 2F | yes | once | +1F every Scry → key in 2 rounds | 0.82 | 81% |
| Dependable Tosspot (3 Cups) | 2W | yes | once | +3W on scoring nothing → key next round | 0.78 | 77% |
| Socratic Self-Slayer (King Cups) | lose 2 teeth + burn | yes | once | steals a key from the leader (a 2-key swing) | 0.74 | 74% |
| Pot-Licking Friar (4 Cups) | 2W | yes | once | +1W per discard | 0.33 | 33% |
| Craven Cannoneer (3 Wands) | 2F | yes | once | none | 0.32 | 32% |
| Burn-Scarred Glasswright (3 Disks) | 2E | yes | once | +1E per 5-die set | 0.26 | 26% |
| Psychotic Christ (3 Swords) | 2A | yes | once | none | 0.23 | 23% |
| Discarded Follower (5 Disks) | 7 of one type | no | yes | none | 0.21 | 11% |
| Sadistic Shepherd (4 Disks) | 2E | yes | once | none (its E is buried, not spendable) | 0.15 | 15% |
| Wrathful Sovern (Devil) | 3F when an opponent loses a tooth | no | yes | none | 0.07 | 5% |
| Self-Sacrificant (Hanged Man) | 3 of one type, in place of a swap | no | yes | none | 0.07 | 5% |
| Finger-Bone Forager (7 Swords) | 2Q | yes | once | none | 0.05 | 5% |
| Paid Mourner (5 Cups) | 6W | no | yes | none | 0.05 | 3% |
| Powder Monkey (5 Wands) | 5F | no | yes | none | 0.00 | 0% |

Token context from the same league: the median player gains **5 tokens a game** in total (90th percentile 21). The rates for single tokens are 0 at the median: E 0/2, W 0/3, F 0/8, A 0/12, Q 0/2 (p50/p90). So any price above 2 that the face doesn't fund itself is out of reach in practice.

## 3. Counters and accumulators

| Face (card) | Trigger | Key | League keys/claim | P(key) |
|---|---|---|---:|---:|
| Bird-Fouled Hagia (Hermit) | 1Q buried per Scheme; at 5 → burn | 1 after ~5 rounds | 0.61 | 61% |
| Corrupted Inquisitor (7 Wands) | burn 2+ cards in a round | 1, **repeatable** | 0.48 | 36% |
| Pious Parishioner (Priest) | burn 2 cards in a round | 1, then burns itself | 0.25 | 25% |
| Lithiated Assayer (Queen Wands) | 10F buried (burn / discard / lose tooth) | 1 | 0.00 | 0% |
| Mercurial Monomaniac (10 Swords) | 5 cards burned | 1 | 0.00 | 0% |
| Ayahuascite (9 Swords) | rotate dice, then score nothing to gain 5A | 1 | 0.03 | 3% |

## 4. Multipliers and leeches (ride on other key gains)

| Face (card) | Effect | League keys/claim | P(key) |
|---|---|---:|---:|
| Tarred Prophet (Queen Cups) | attach to an opponent; whenever they gain a key, so do you | 1.01 | 44% |
| Back-Alley Butcher (Prince Swords) | every key +1; costs all your tokens, or a tooth | 0.85 | 45% |
| Hollowhead (Fool) | every key +1 while you have exactly 2 other active cards | 0.39 | 29% |
| Vivisectionist (King Wands) | each key becomes a die roll: 0 / 1 / 2 keys | 0.01 | 1% |

Key denial (no keys given): Lockpicking Archon (the target can't gain keys), Unshakable Empiricist (the target's keys become teeth), Insane Incandescent (+1 key to win), Haphazard Herbalist (lose a key for 2 teeth), Feverish Scribe (rewrites the win threshold).

---

## Ranking (league keys/claim, blended with the dice odds)

| Tier | Paths | Keys/claim |
|---|---|---|
| **Broken** | Brawny Striker | 3.5. Holders win 64% of the time, and the card supplies 33% of all winners' keys. |
| **Easy (≈1 round, near-certain)** | Lethean Elder (2 keys), Gravedigger (repeatable), Tarred Prophet, Lash-Blessed Monk, Gout-Ridden Glutton, Powder Miller, Dependable Tosspot, Back-Alley Butcher, Socratic Self-Slayer | 0.75–1.1 |
| **Fair (1–2 rounds of dice luck)** | Penname, Prismist, Active Assistant, Hagia, Corrupted Inquisitor | 0.5–0.7 |
| **Hard (a coin flip, or needs outside tokens)** | Ciderist, Bacchus Host, Hollowhead, Friar, Cannoneer, Glasswright, Parishioner, Psychotic Christ, Discarded Follower, Shepherd | 0.15–0.45 |
| **Dead (≈0 in practice)** | all four Four Fire / Four Air faces (Pandorite, Expendable Assistant, Bloodstained Recluse, Candid Jester), Fleabitten Penitent, Pugilist, Nymph, Assayer, Monomaniac, Ayahuascite, Paid Mourner, Powder Monkey, Forager, Self-Sacrificant, Wrathful Sovern, Vivisectionist | < 0.1 |

## Caveat: league numbers measure the bots, not the cards

Playtesting flagged Powder Monkey as a runaway winner, and the league scored it 0. A forced-hold probe (`game/run.sh probe`; seat 0 is dealt Fingerless Sapper upright at game start, against 3 adaptive bots, 200 games each) gave:

| Seat 0 plays | Win % (even = 25%) | Keys/game | F/game | Swigs with Sapper live | Median round to 7 keys |
|---|---:|---:|---:|---:|---:|
| adaptive bot | 23% | 3.1 | 7 | 1.0 | 13 (16% reach it) |
| `fire` strategy bot | 27% | 3.6 | 15 | 1.8 | 11 (21%) |
| scripted Sapper → Monkey | **72%** | 6.6 | 79 | 8.2 | **8** (71%) |

The script farms with Sapper. It commits the Potency dice and keeps the elementals rolling. On each F it discards the highest Potency, then pays 2F to undiscard everything. That makes about 10F per Swig. It flips to Monkey once its F covers the keys it still needs, then cashes 5F per key. The bots flip to Monkey at the first Scheme and burn it for the "opponents lose a tooth" effect. So any card whose payoff needs a few rounds of building on its other face is undervalued here. That includes self-funded token→key pairs, accumulators and two-face engines. Read the "Dead" tier as "the bots can't play it" until it has been probed.

## Takeaways

1. **Brawny Striker is one card in a league of its own.** No other card goes past 1.1 keys/claim. It pays out every round, and two of its four prices are teeth or cards, which every player has. Burning 2 cards is free fuel with Witch Drowner, Corrupted Inquisitor and Solifactory Smith.
2. **The key conditions use the wrong fire and air numbers.** With one F face and one A face per elemental die, Four Fire and Four Air hit 3.3% of Swigs (about one in 30). Four Earth and Four Water hit 27%. Four faces sit on the 3.3% condition, so those cards are blanks unless you also hold Jar Dweller or a 6th die. The menu prices Four Air as tier 3, and that fits, but the key cards treat Four Fire like Four Earth. Options:
   - make those faces "Three Fire / Three Air", which sits near Four Earth's rate;
   - or make them trigger on any Four of a Color that includes fire.
3. **"Score nothing" and "discard nothing" are free.** Discarding is unrestricted, so Lethean Elder (2 keys) and Gout-Ridden Glutton are guaranteed keys the round after you flip them. Lethean costs your cadre, but that's cheap late in the game.
4. **"Pay 2X: key + burn" sorts by whether the face funds itself.**
   - Powder Miller and Tosspot (self-funded): 0.8.
   - Friar and Glasswright (partly funded): 0.3.
   - Cannoneer, Christ, Shepherd and Forager (unfunded): 0.05–0.3.
   - Prices of 5–7 (Mourner, Monkey, Follower) almost never pay off. Gravedigger's +1A per Swig is the exception.
5. **Zero-key faces may be bot blind spots, not design failures.** The bots never complete Nubile Nymph, Lithiated Assayer or Mercurial Monomaniac. The dice say the Nymph should pay off in about 7 Swigs, and the Assayer in about 2 rounds of heavy discarding. These need a targeted check before anyone judges the cards.
6. **The spread is wide.** The top 10 paths give about 0.8–3.5 keys/claim and the bottom 17 give under 0.1. With `win_keys=7`, a game is mostly decided by who draws Striker, Lethean, Gravedigger or Prophet.

Repro scripts (not in the repo): `key_dice.py` (smartplay odds) and `key_league.py` (per-card key attribution from a run folder's `part*.jsonl`).

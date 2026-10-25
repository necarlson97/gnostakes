# Token economy: flat-income proposal (2026-10-24)

The question: what if income stops being a bolus ("discard a Potency die to gain that much F") and becomes flat ("discard it to gain 1F")? How much does each income card make now, and what should it pay so that payout × trigger rate lands around one token per round?

Sources:
- **Realized income:** league run `game/sim/results/20261024-033622`. That's 650 four-player games, rules as written, all bots, 14.8 rounds on average. "Per game held" counts every game where the player ever claimed the card, whichever face was up.
- **Trigger odds:** `design/tools/smartplay.py`, exact. The model is the base kit (5 Potency + 5 Elemental E,E,W,W,F,A), committing at least 5 per roll, with no cards. **Natural** means you play for the best claim value and the trigger fires on the side. **Targeted** means you play only for the trigger. One Swig and one Scheme happen per round, so per-Swig and per-Scheme rates are both per-round rates.
- Scratch scripts: `odds.py` and `income.py` in the session scratchpad.

---

## 1. Where tokens come from today

Players gain **9.9 tokens per game on average** (median 5, p90 21). The sources are very lopsided:

| Source | Share of all tokens | Tokens per activation | Note |
|---|---:|---:|---|
| **Dubious Demonologist** (A on roll, bolus) | **24.7%** | 5.2 | 21 A per game held. Holder wins 48%. |
| Overworked Gravedigger (+1A per Swig) | 14.2% | 1.0 | Flat. It's the reference engine. |
| Doomed Pandorite (+1F per Scheme) | 10.0% | 1.0 | Flat. |
| Driveling Chemist (EWFA when you have the fewest keys) | 8.1% | 4.0 | Catch-up. |
| Lithiated Assayer (bury F on incinerate, discard or tooth loss) | 5.9% | 1.2 | Discards are unbounded. |
| Dependable Tosspot (score nothing: 3W) | 4.1% | 3.0 | |
| Every other bolus line (Eulogist, Bezoar, Fire-Drake, Sapper, Saint, Flagellant, Reeking Husk, Lead Drinker, Pomologist, Glass-Eyed) | ~6.5% | 3–6 | |
| Everything else | ~27% | ~1 | |

**The bolus lines produce about 31% of all tokens, and one card produces most of that.** Each bolus activation paid 4.7–5.2 tokens, which matches the expected best Potency left in the pool. The bots under-use them. Played on purpose, a bolus face makes about **5–7 tokens a round**: roughly 1.5 F/A rolls per Swig, each paying about 4.5. Sapper's undiscard loop makes about **10F per Swig** (key_paths.md). The flat engines (Gravedigger, Pandorite, Powder Miller) make **1 per round**. So today one card type is out-earning the rest of the game by 5–10×. That's why balancing has been hard.

## 2. The yardstick

What a token buys:
- **3 tokens buy a villager request** (Town Square). This is the main universal sink, so **1 token ≈ ⅓ of a claim**.
- **2 tokens buy a burn key** (Tosspot, Friar, Miller, Cannoneer, Glasswright, Christ, Shepherd, Monk).
- **5 tokens buy a repeatable key** (Gravedigger, Monkey).

Proposed target: **a dedicated income face earns about 1–1.3 tokens per round it's active.** That means:
- Miller-style "earn 2, burn for a key" takes 2 rounds, which is what Miller already does.
- A repeatable 5-cost key fires every 4–5 rounds from its own face.
- An engine pays for a villager every ~3 rounds.

Payout rule (your curve, with a small premium for risk): **payout ≈ ⌈1 / p⌉**, where p is the per-round trigger rate. Use the targeted p for build-around cards and the natural p for incidental ones.

| p per round | Payout | EV per round |
|---|---:|---|
| ≥ 0.75 | 1 | 0.75–1.0 |
| 0.45–0.75 | 2 | 0.9–1.5 |
| 0.30–0.45 | 3 | 0.9–1.35 |
| 0.18–0.30 | 4–5 | 0.7–1.5 |
| < 0.18 | make it a key or an accumulator, not income | |

Some triggers have a **real cost**: score nothing, incinerate a card, lose a tooth. Those are priced against that cost, not against p. Choosing to score nothing is ~100% available, but it gives up the round's claims, which are worth roughly 3 tokens.

## 3. Trigger odds per round (base kit)

| Trigger | Natural | Targeted | Single raw roll |
|---|---:|---:|---:|
| Roll at least one F (or A) during the Swig | ~60% | ~84% | 60% |
| Expected F (or A) faces rolled per Swig | 0.83 | **~1.5** | 0.83 |
| Expected E (or W) faces rolled per Swig | 1.7 | **~2.8** | 1.7 |
| Roll at least one E (or W) during the Swig | 87% | ~96% | 87% |
| Two W committed (Lead Drinker) | 55% | 87% | 54% |
| Any straight (3+) | 63% | 77% | 45% |
| Two Color-Pairs | 54% | 79% | 47% |
| Two Color-Pairs or Triplet+ (Sower) | 69% | 90% | 58% |
| Triplet+ | 33% | 54% | 21% |
| Set with F (Scholar) | 40% | 65% | 33% |
| All Colors | 23% | 45% | 19% |
| Four of a Color | 18% | 42% | 10% |
| 5-die set (Glasswright) | 15% | 21% | 4% |
| Quadruplet | 9% | 13% | 2% |
| Five of a Color | 5% | 9% | 1% |
| Four Fire / Four Air | 0.3% | 3.3% | 0.3% |
| Score nothing | ~0% | ~100% (discard everything) | 9% |
| Incinerate a card | about 1 per round once your cadre is full (analysis_v0) | | |

The roll counts are capped because a 10-die Swig has at most 2 rolls. That's why "on roll" triggers top out near 1.5 (F/A) or 2.8 (E/W) per round without undiscard tricks.

## 4. Card-by-card proposals

"Now EV" is per round when played on purpose. "League" is tokens per game held.

### 4a. The bolus cards → flat 1 per die

**Template for F/A: "On rolling an F, you may discard that die to gain 1F."** That's 0.8–1.5 per round. The discarded die is a rare F/A face, so it costs little score (All Colors, Four Air). That sits right on target.

**Template for E/W: same, plus "once per Swig".** E and W show up twice as often (1.7–2.8 per Swig). Uncapped, the card makes ~2–2.8 per round while gutting your color sets. With the cap it fires 87–96% of the time and pays 1.

| Card (face) | Now | Now EV/round | League | Proposed | New EV/round |
|---|---|---:|---:|---|---:|
| **Dubious Demonologist** (King Swords) | A roll → discard a Potency, gain A = Potency | 5–7 | **21.4** | On rolling an A, you may discard that die to gain 1A. | 0.8–1.5 |
| Flayed Flagellant (4 Swords) | same, A | 5–7 | 0.26 | same as Demonologist | 0.8–1.5 |
| Fire-Drake (4 Wands) | same, F | 5–7 | 0.64 | On rolling an F, you may discard that die to gain 1F. | 0.8–1.5 |
| Fingerless Sapper (5 Wands) | same, F, plus 2F undiscard-all | ~10 (loop) | 0.53 | On rolling an F, discard it to gain 1F. The undiscard loop then nets ~0, which is fine. | ~1.5 |
| Bezoar Seeker (4 Disks) | same, E | 6–10 | 0.94 | On rolling an E, you may discard that die to gain 1E. Once per Swig. | 0.9 |
| Hollow-Bellied Saint (4 Cups) | same, W | 6–10 | 0.43 | Once-per-Swig W version | 0.9 |
| Enthralling Eulogist (5 Cups) | same, W | 6–10 | 1.19 | Once-per-Swig W version | 0.9 |
| Reeking Husk (5 Disks) | E/A roll: discard it and a Potency, gain = Potency | 5–8 | 0.05 | On rolling an E or A, you may discard that die to gain 1E (A: 1A or 1E). Once per Swig. | ~1 |
| Lead Drinker (Ace Cups) | commit 2W: discard a Potency, gain W = Potency | ~4 | 0.01 | On committing two W: gain 1W. | 0.55–0.87 |
| Primed Pomologist (Ace Disks) | Scry start: gain E = highest discarded Potency (6 → 2Q) | ~4–5 | 0.02 | On Scry start, if you discarded a Potency die: gain 1E. If it was a 6, you may gain 1Q instead. | ~1 (costs a die) |
| Glass-Eyed Alchemist (Ace Swords) | score nothing: A = highest discarded Potency | ~6 | 0.04 | If you score nothing: gain 3A. Matches Tosspot. | cost-priced |

### 4b. Set-triggered income → ⌈1/p⌉

| Card (face) | Trigger p (nat / targeted) | Now | Now EV | Proposed | New EV |
|---|---|---|---:|---|---:|
| Hopeful Sower (Princess Disks) | 69% / 90% | 2E | 1.4–1.8 | **1E** (keep the bury option) | 0.7–0.9 |
| Footnoted Scholar (8 Swords) | 40% / 65% | 1F, or opponent loses 3 | 0.4–0.65 | **2F**, or an opponent loses **1** token. Losing 3 is brutal when income is low. | 0.8–1.3 |
| Reliquary Larcenist (7 Swords) | 4oaC 18% / 42%; 5oaC 5% / 9% | 3A / 6A | 0.7–1.5 | **3A / 4A** | 0.6–1.4 |
| Burn-Scarred Glasswright (3 Disks) | 15% / 21% | 1E | 0.2 | **2E**, so one 5-die set funds its own 2E key | 0.3–0.4, but it's a key path |
| Oathkeeper (9 Disks) | 33% / 54% | 1Q | 0.3–0.5 Q | keep 1Q (Q is wild) | — |
| Gout-Ridden Glutton (9 Cups) | ~70–100% (no discards) | 2W | 1.4–2 | **1W** | 0.7–1 |
| Sulfurous Sage (King Cups) | 23% / 45% | 1 of each | 0.9–1.8 | keep | — |

### 4c. Already flat: leave as the reference

Overworked Gravedigger (+1A per Swig), Doomed Pandorite (+1F per Scheme), Powder Miller (+1F per Scry), Shunned Executioner (+1Q, costs a card). The incinerate-for-1 lines: Noble Ghostwriter W, Solifactory Smith E, Timeless Warrior-Poet F, Witch Drowner Q, Bodysnatcher A. All sit at 1 per round. **No change.**

### 4d. Unbounded "per event" lines → cap them

Discarding is free and unlimited, so "whenever you discard" is a hidden bolus: you can discard 10 dice in one Swig.

| Card | Now | Proposed |
|---|---|---|
| Pot-Licking Friar (4 Cups) | 1W per discard | 1W per discard, **once per Swig**. Its 2W key then takes 2 rounds, like Miller. |
| Branded Protégé (2 Wands) | 1F per discard | same cap |
| Lithiated Assayer (Queen Wands) | bury F on incinerate / **discard** / tooth loss; key at 10 | drop "discard a die", key at **6** |
| Spagyric Physician (Queen Disks) | bury 1 per elemental discarded; pay out on Triplet | bury **once per roll** |
| Venomous Vessel (8 Disks) | AA **doubles** buried E | AA buries **2 more** E (doubling is a bolus) |
| Driveling Chemist (Princess Swords) | fewest keys: +E,W,F,A (4 tokens) | fewest keys: **gain 2 of any one type**. Still a strong catch-up, since it lets a trailing player cash a 2-cost burn key every round. |

### 4e. Multipliers get much stronger

Gin-Soaked Gutter-Sweeper (+1W), Academic Artillerist (+1F), Persecuted Paranoiac (+1A), Charitable Ciderist (+1 E/W), Epileptic Metallurgist (+1 A/F) and Brooding Composer (copy E/W) all add **+1 per gain event**. Today that turns a 5-token bolus into 6 (+20%). Under flat income, **each one doubles an engine** (+100%).

I think that's healthy: it gives them a clear, constant job. But watch **Gravedigger + Paranoiac**: that's 2A per round, so a repeatable key every 2.5 rounds. If it runs away, add "once per round".

## 5. Sinks to reprice

With income at ~1 per round, prices above ~4 that the face doesn't fund itself are dead. Today they're already dead at the median (key_paths.md: median player income is 5 tokens per game).

| Card | Now | Proposed |
|---|---|---|
| Powder Monkey (5 Wands) | 5F per key, repeatable | **3F** (Sapper funds ~1.5 per round, flip to cash) |
| Paid Mourner (5 Cups) | 6W per key | **4W** |
| Discarded Follower (5 Disks) | 7 of one type per key | **4** |
| Haphazard Herbalist (7 Disks) | 8E to regain 2 teeth | **3E** |
| Oathbreaker (9 Disks) | 5E to prevent a tooth loss | **2E** |
| Viscera Monger (Queen Swords) | 4E → 4A on incinerate | **2E → 2A** (or drop it; conversion is fine) |
| Brawny Striker (10 Disks) | 8E or 4Q route | leave. Its problem is the teeth/burn routes (3.49 keys per claim, holder wins 65%), not tokens. |
| Gravedigger 5A, Town Square 3 tokens | — | keep. These are the anchors. |

## 6. Expected effect

Rough estimate, holding bot behaviour fixed: bolus lines drop from 31% of income to ~6%. Chemist halves, Sower halves, the discard caps bite a little. Mean income goes from **9.9 to ~6.5–7 tokens per player-game**, and the spread narrows a lot. Today p90 is 21, driven almost entirely by Demonologist.

The bigger change is the **variance between cards**. The best income face goes from ~6× the reference engine to ~1.5×. So token-cost tuning (2-cost burns, 3-token requests, 5-cost repeatables) stops depending on whether someone drew Demonologist.

Side effects to watch:
- **Wagers shrink.** Ties get more common, and holding just 1–2 tokens decides contested claims. That's probably good.
- **Combo cards lose their bolus spike.** Corpse-Like Pauper's 9-face and the bonus Potency die no longer feed income. That's fine, since they still help scoring.
- **Q stays under-sunk** (1,562 made, 83 spent). Separate issue.

## 7. How to test

`game/tools/variants.py` already runs card variants on identical seeds. Plan:
1. Put §4 and §5 into `game/cards/variants/flat_income/*.gd`.
2. Run 650 games against "as written".
3. Compare tokens per player (p50/p90), Demonologist and Sapper holder win %, Gravedigger keys per claim, and game length and endings.

Splitting it into two variants, **flat_bolus** (§4a only) and **flat_all** (§4–5), would show how much of the shift comes from the bolus change alone.

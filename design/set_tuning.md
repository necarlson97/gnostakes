# Set tuning

## ★ Current recommendation (2026-10-21, v2: designed against smart play)

**Smart-play targets (D6 v2):** nothing 1–5% · ≥easy ~95% · ≥medium ~80% · hard ~25%. Raw-roll numbers are kept as a secondary check.
**Dice: 5 Potency + 5 Elemental (E, E, W, W, F, A). Commit at least 5 per roll**, which means 2 rolls: roll 10, keep ≥ 5, reroll the rest, keep all.

Solver: [tools/smartplay.py](tools/smartplay.py), an exact optimal-commit DP compiled with numba that takes about 0.05s per evaluation. It matches the old solver to the decimal. Searches: [tools/exact_search.py](tools/exact_search.py) and [tools/menu_search.py](tools/menu_search.py).
Each "smart" number is the best rate achievable *when playing for that tier*, so each is an upper bound for its own threshold.

### R1: "Straight ladder" (recommended; reuses mostly current set names)
| Tier | Sets (smart / raw, each alone) |
|---|---|
| Easy (slots 1–4) | Three High (three dice ≥ 5) 60/21 · Three Earth 60/21 · Three Water 60/21 · Fire and Air 65/33 |
| Medium (any 1) | Four Straight 41/15 · Triplet 54/21 · Four of a Color 42/10 |
| Hard (any 2) | Five Straight 13/3 · Three Air 17/4 |
| **Smart** | **≥easy 99.0% · ≥medium 82.6% · hard 25.6% · nothing 1.0%** |
| Raw | ≥easy 86.4% · ≥medium 44.9% · hard 6.5% · nothing 13.6% |

### R3: Laddered easy slots (user direction, 2026-10-22)
Easy slots climb in difficulty: Three Straight 77/45 → Two Pairs 56/27 → Triplet 54/21 → Four of a Color 42/10 (smart/raw). A ~100% smart ≥easy is acceptable.
| Medium option | Smart easy / med / hard | Raw easy / med / hard |
|---|---|---|
| 4 Straight, Color Full House, All Colors | 99.7 / 81.2 / 25.6 | 89.8 / 45.5 / 6.5 |
| 4 Straight, All Colors, Two Fire | 99.6 / 81.5 / 25.6 | 90.3 / 48.0 / 6.5 |
| 4 Straight, Color Full House, Two Fire | 99.6 / 79.6 / 25.6 | 89.3 / 43.6 / 6.5 |
| 4 Straight, Color Full House | 99.5 / 71.1 / 25.6 | 86.4 / 29.9 / 6.5 |
Hard tier is Five Straight + Three Air in all rows. Caveat: Four of a Color (42%) is as hard as the medium sets (41–49%), so the last easy slot overlaps the medium tier.

### R4: User's easy tier + 4 medium / 4 hard (2026-10-22; script `tools/r4_search.py`)
Easy: Three Straight 77/45, Two Color-Pairs 79/47, Triplet 54/21, Four of a Color 42/10 (smart/raw). Any easy: 98.8 / 84.0.
Pool, each alone (smart/raw): Two Earth 87/54 · Three Earth 60/21 · Two Ones 48/20 · All Colors 45/19 · Four Straight 41/15 · Four Earth 27/5 · Three Air 17/4 · Three Ones 17/4 · Quadruplet 13/2 · Five Straight 13/3 · Five of a Color 9/1 · Four Air 3/0.3 · Four Ones 3/0.3 · Quintuplet 1/0.1 · **Six Straight and Six of a Color are impossible** with 5+5 dice.

| Menu | Medium | Hard | Smart easy/med/hard | Raw |
|---|---|---|---|---|
| **R4a "ladder" (hand-picked)** | 4 Straight, Three Earth, Three Air, Three Ones | 5 Straight, Quadruplet, Five of a Color, Four Air | **99.3 / 80.2 / 28.8** | 88.6 / 40.5 / 6.2 |
| R4b (search best) | 4 Straight, Three Earth, Four Earth, Three Air | Quadruplet, Four Air, Three Ones, Four Ones | 99.3 / 79.6 / 24.9 | 88.6 / 40.1 / 5.5 |
| R4c | 4 Straight, Three Earth, Four Earth, Three Air | 5 Straight, Quintuplet, Three Ones, Four Ones | 99.3 / 78.5 / 24.6 | 88.6 / 38.9 / 6.7 |
| R4d | 4 Straight, Three Earth, Four Earth, Three Air | 5 Straight, Quadruplet, Five of a Color, Four Air | 99.3 / 78.4 / 28.8 | 88.6 / 38.0 / 6.2 |
| R4e | 4 Straight, All Colors, Four Earth, Three Air | 5 Straight, Quadruplet, Five of a Color, Four Ones | 99.6 / 76.8 / 27.4 | 91.6 / 39.7 / 5.9 |

### R5: User's pick (2026-10-22)
Easy: Three Straight, Two Color-Pairs, Triplet, Four of a Color. Medium: Four Straight, Three Ones, All Colors, Three Earth. Hard: Five Straight, Three Sixes, Quadruplet, Four Air, Five of a Color.
**Smart: ≥easy 99.8 · ≥medium 89.0 · hard 36.2.** Raw: 94.7 / 54.5 / 9.4. Medium and hard are both above target. Three Ones (medium) and Three Sixes (hard) have identical odds (17.1%).
Tweaks (smart easy/med/hard):
- Drop Three Sixes: 99.8 / 88.0 / 28.8.
- Drop Three Sixes and Three Earth: 99.5 / 72.8 / 28.8.
- Drop Three Sixes, Three Earth → Four Earth: 99.5 / 76.9 / 28.8.
- Move Three Sixes to medium, drop Three Earth: 99.5 / 75.3 / 28.8.

### R5b: R5 with Three Earth → Four Earth (2026-10-22)
Four Earth alone: smart 26.5% / raw 4.5%. Medium tier: Four Straight, Three Ones, All Colors, Four Earth.
| Hard tier | Smart easy/med/hard | Raw |
|---|---|---|
| All 5 (keep Three Sixes) | 99.5 / 79.0 / 36.2 | 90.9 / 42.0 / 9.4 |
| Drop Three Sixes | 99.5 / 76.9 / 28.8 | 90.9 / 39.5 / 6.2 |

### R5c: R5 with Three Earth → "Four Earth or Water" (2026-10-22)
Four Earth or Water alone: smart 40.6% / raw 9.1%. Medium: Four Straight, Three Ones, All Colors, Four Earth or Water.
| Hard tier | Smart easy/med/hard | Raw |
|---|---|---|
| All 5 (keep Three Sixes) | 99.5 / 82.1 / 36.2 | 90.9 / 45.1 / 9.4 |
| Drop Three Sixes | 99.5 / **80.2 / 28.8** | 90.9 / 42.8 / 6.2 |

### R6: Four Pairs menu (2026-10-22)
Easy: Three Straight 77/45, Two Color-Pairs 79/47, Triplet 54/21, Four of a Color 42/10.
Medium: Four Straight 41/15, Three Ones 17/3.5, All Colors 45/19, Four Pairs 44/13. Four Pairs counts number and element pairs together; with 5+5 dice it always means 2 number pairs + 2 element pairs.
Hard: Five Straight 13/3, Quadruplet 13/2, Four Air 3/0.3, Five of a Color 9/0.8.
**Smart: ≥easy 99.5 · ≥medium 83.4 · hard 28.8.** Raw: 90.9 / 48.7 / 6.2. Easy tier alone 98.8 / 84.0; medium tier alone 82.1 / 46.4.

### R2: Best numeric fit
Easy: Three High, Three Earth, Three Water, Fire and Air. Medium: Two Pairs, Color Full House (a 3-of-a-color plus a pair of another color). Hard: Quadruplet, Three Air.
**Smart: 98.8 / 80.0 / 24.4, nothing 1.2%.** Raw: 85.3 / 41.1 / 5.5.

### Why this shape
- **Commit rule matters most.** With 10 dice, commit ≥ 3 gives up to 4 rolls (10 → 7 → 4 → 1). Hitting the targets then requires bizarre sets like Four Fire, Quintuplet and All Even. Commit ≥ 4 (3 rolls) overshoots the hard tier (≥ 37%). **Commit ≥ 5 (2 rolls) is the sweet spot.**
- **The four easy sets each have about a 60–65% smart chance**, so the four Town Square slots are about equally reachable. Three Low can replace Three High with the same numbers.
- **Nothing sits at the low end of your range (about 1%).** To push it toward 3–5%, swap one easy set for something narrower. Section 2b has more options.
- **Moving variants (all 5P+5E, commit ≥ 5; smart easy / medium / hard):**
  - Medium = 4 Straight + Color Full House: 98.6 / 72.7 / 24.4 (medium too low).
  - Medium = 4 Straight + Triplet + Color Full House: 99.1 / 84.9.
  - Medium = 4 Straight + Color Full House + Two Fire: 99.2 / 79.6.
  - Three Straight in easy instead of Three High: easy rises to 99.7%.

### What changes vs the current mat
- 5th Potency die and 5th Elemental die. Commit minimum goes from 3 to 5.
- **Gargoyle Mother** ("only need to commit 3") becomes meaningful again under this rule.
- Easy slot sets change completely. Medium keeps Four Straight and Four of a Color and adds Triplet. Hard keeps Five Straight and Three Air and drops Three Sixes and Quadruplet.
- The Town Square mat is a Google Drawing. The Drive API can't edit drawing contents, so the user updates it by hand.

## 2b. Earlier v1 work (raw-roll targets): kept for reference

Targets were for a **single raw roll** of all base dice, with no rerolls and no cards: P(nothing) ≈ 30%, P(≥easy) ≈ 70%, P(≥medium) ≈ 40%, P(hard) ≈ 15%.
Tools: [tools/set_explorer.py](tools/set_explorer.py) (`table` lists every candidate set; `search NP NE` finds menus) and [tools/menu_dp.py](tools/menu_dp.py) (exact smart-play numbers for a menu).
All numbers use the current Elemental faces (E, E, W, W, F, A).

## 1. Per-set raw-roll probability by dice count

`P` = potency dice and `E` = elemental dice.

| Set | 4P+4E (now) | 5P+4E | 4P+5E | 5P+5E | 6P+4E |
|---|---|---|---|---|---|
| Two Earth / Two Water | 40.7% | 40.7% | 53.9% | 53.9% | 40.7% |
| Three Straight | 27.8% | 44.8% | 27.8% | 44.8% | 59.4% |
| Two Pairs | 6.9% | 27.0% | 6.9% | 27.0% | 55.6% |
| Three of a Color | 25.5% | 25.5% | 49.1% | 49.1% | 25.5% |
| Triplet | 9.7% | 21.3% | 9.7% | 21.3% | 36.7% |
| Three Low (three dice ≤ 2) / Three High (≥ 5) | 11.1% | 21.0% | 11.1% | 21.0% | 32.0% |
| Two Ones / Two Sixes | 13.2% | 19.6% | 13.2% | 19.6% | 26.3% |
| All Colors | 7.4% | 7.4% | 18.5% | 18.5% | 7.4% |
| Four Straight | 5.6% | 15.4% | 5.6% | 15.4% | 27.0% |
| Three Earth / Three Water | 11.1% | 11.1% | 21.0% | 21.0% | 11.1% |
| Four of a Color | 2.6% | 2.6% | 9.7% | 9.7% | 2.6% |
| Full House | 0% | 3.9% | 0% | 3.9% | 17.0% |
| Three Ones / Three Sixes | 1.6% | 3.5% | 1.6% | 3.5% | 6.2% |
| Three Fire / Three Air | 1.6% | 1.6% | 3.5% | 3.5% | 1.6% |
| Five Straight | **0%** | 3.1% | 0% | 3.1% | 9.3% |
| Quadruplet | 0.5% | 2.0% | 0.5% | 2.0% | 5.2% |

What drives these numbers:
- **Adding a potency die** makes number sets much easier (Two Pairs goes from 7% to 27%) and makes Five Straight possible.
- **Adding an elemental die** mostly boosts Earth and Water, because each has 2 faces out of 6.
- **Earth and Water pairs are too common to be scoring sets** at any dice count. Fire and Air are the scarce elements.

## 2. Can the current set list hit the targets?

**No.** I tried every dice count with only today's 13 set names, sorted by difficulty and cut into easy / medium / hard. The best result misses the targets by about 20 points in total. **The medium tier is always too thin**, because the current list has almost no sets in the 10–20% band. A few new sets are needed. Fortunately, they're natural ones like Three Earth, Two Sixes and Three Low.

## 3. Candidate menus

These are from the search. Easy has exactly 4 sets, one per Town Square slot. Every tier mixes number and element sets, and each set is individually rarer than every set in the tier below.

### Candidate A: 5 potency + 4 elemental (one extra potency die). *Closest to the current game.*
| Tier | Sets (raw-roll P each) |
|---|---|
| Easy (slot 1–4) | Triplet 21% · Two Ones 20% · Three Low 21% · Three of a Color 25% |
| Medium (any 1) | Four Straight 15% · Three Earth 11% · Three Water 11% |
| Hard (any 2) | Five Straight 3% · Quadruplet 2% · Four of a Color 3% · All Colors 7% |
| **Cumulative** | **≥easy 71.0% · ≥medium 42.0% · hard 14.6% · nothing 29.0%** |

This keeps 7 of the current sets and makes Five Straight possible. Three Straight, Two Pairs and Two Earth are dropped as too easy. Two Earth becomes Three Earth. Three Air and Three Sixes are dropped (Three Sixes could replace All Colors in hard). A mirror variant swaps in Two Sixes and Three High for Two Ones and Three Low.

### Candidate B: 4 potency + 5 elemental. *Closest to the targets (error 0.002).*
| Tier | Sets |
|---|---|
| Easy | Two Sixes 13% · Two Air 20% · All Colors 19% · Fire and Air 33% |
| Medium | Two Ones 13% · Three High 11% · Four of a Color 10% |
| Hard | Two Pairs 7% · Three Ones 2% · Three Fire 4% · Three Air 4% |
| **Cumulative** | **≥easy 70.1% · ≥medium 40.0% · hard 15.1%** |

This leans heavily on element sets. Straights disappear entirely.

### Candidate C: 6 potency + 4 elemental. *Also on target (error 0.003).*
| Tier | Sets |
|---|---|
| Easy | Two Ones 26% · Two Fire 13% · Fire and Air 23% · Two Color Pairs 15% |
| Medium | Five Straight 9% · Two Air 13% · All Colors 7% |
| Hard | Three Ones 2% · Three Sixes 6% · Four Earth 1% · Three Fire 2% |

### Candidate D: keep 4+4 and change only the sets (error 0.039)
| Tier | Sets |
|---|---|
| Easy | Two Color Pairs 15% · Two Ones 13% · Two Sixes 13% · Three Earth 11% |
| Medium | Three Water 11% · Triplet 10% · All Colors 7% |
| Hard | Two Pairs 7% · Four Straight 6% · Four of a Color 3% · Three Air 2% |
| **Cumulative** | ≥easy 68% · ≥medium 39% · hard 16% |

No dice change is needed, but every easy set is individually rare (11–15%), so easy sets *feel* hard.

## 4. Smart play vs raw roll (Candidate A, 5P+4E)

These are exact optimal commit decisions with no cards, computed by `menu_dp.py`. Each column is the best achievable rate *when playing for that tier*. The thresholds are individual upper bounds, not one strategy hitting all three at once.

| Rule | ≥ easy | ≥ medium | hard | nothing |
|---|---|---|---|---|
| Raw single roll (the D6 target) | 71.0% | 42.0% | 14.6% | 29.0% |
| Commit ≥ 3 per roll (current rule; up to 3 rolls) | **99.0%** | **92.1%** | **62.9%** | 1.0% |
| Commit ≥ 4 per roll (9 → 5 → 1) | 97.7% | 86.0% | 55.9% | 2.3% |
| Commit ≥ 5 per roll (9 → 4: 2 rolls) | 94.9% | 79.4% | 44.2% | 5.1% |

**Takeaway:** the commit-and-reroll loop is far stronger than the set menu. Even a hard set that only 15% of raw rolls show is reachable about 45–63% of the time with deliberate play. Tightening the commit minimum barely helps. Unless D6 is meant purely as "how the dice feel before decisions", the targets should be restated for **smart play**, and the menu tuned against those numbers instead. Possible levers, all untested:
- Fewer rerolls: one roll plus a single partial reroll.
- "Commit at least half".
- Rerolls that cost something: a token or a tooth.
- Harder sets throughout: tune raw-roll rates to about 5% / 15% / 35% so that smart play lands near 70% / 40% / 15%.


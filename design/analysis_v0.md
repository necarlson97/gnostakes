# Gnostakes — State of the Game, v0 audit

Pulled 2026-10-21 from the three published sources (rules doc, card sheet tab `gid=1397729182`, Town Square drawing).
Raw snapshots are in [source_snapshot/](source_snapshot/) so the next pull can be diffed against this one.
The probability numbers come from [tools/swig_dp.py](tools/swig_dp.py), an exact dynamic program for optimal play with no cards. Run it with `python design/tools/swig_dp.py` (about 2 minutes).

This file only reports what the sources say and where they fall short. Fixes belong in the Google sources. The **Proposals** are suggestions only.

---

## 1. The game loop as currently written

**Setup.** Each player has 4 Potency dice (1–6) and 4 Elemental dice (Earth, Earth, Water, Water, Fire, Air). Shuffle the deck and deal 4 cards into the Town Square. The sandbox tracker starts players at 10 teeth and 0 of everything else. The rules never mention teeth.

**Round** (all players appear to act at the same time):

1. **Swig.** Roll all uncommitted dice and commit at least 3 (or all, if fewer than 3 remain). Repeat until every die is committed. Dice may be discarded instead of committed. With 8 dice there are at most 3 rolls (8 → ≥3 kept → ≤5 → ≥3 kept → ≤2).
2. **Scry.** Check the committed dice against the scoring hands:
   - **Tier 1** claims the card in one specific slot: Three Straight → slot 1, Triplet → 2, Two Pairs → 3, Three of a Color → 4. The mat adds that each slot can also be bought for 3 tokens of one element (W / E / F / A).
   - **Tier 2** claims any 1 card: Four Straight, Two Ones, Four of a Color, All Colors, Two Earth.
   - **Tier 3** claims any 2 cards: Five Straight, Three Sixes, Quadruplet, Three Air.
   - A taken card is replaced right away. When two players want the same card, they resolve it with a blind fist-wager of tokens.
   - After everyone has claimed, the row slides left: slot 1 is incinerated and slot 4 is a fresh draw.
3. **Scheme.** Choose each card's orientation: the upright side is active, the inverted side is not. Incinerate down to 4 cards. Edit die faces where a card allows it.

**End.** The first player to 10 keys wins (the mat says "10 enlightenment"). If the deck runs out, the most keys wins. Keys come only from card abilities.

---

## 2. Contradictions between the sources

| # | Rules doc | Mat / cards | Notes |
|---|---|---|---|
| C1 | Tier 1 lists 3 hands: Three Straight, Triplet, Two Pair | The mat has 4, adding **Three of a Color** | The mat is probably newer. |
| C2 | Nothing about buying | The mat lets you "buy with 3W/3E/3F/3A" per slot, and exchange "5 of any token → 2Q" | Q and buying are defined only on the mat. |
| C3 | Win at "10 keys" | The mat says "10 enlightenment" | Same thing? Pick one word. |
| C4 | Pyre discard pile goes "next to the deck" | A later line says discards go "face down in the center of the table" | Bodysnatcher ("top card of the discard pile") and Pact Proctor ("any incinerated card") need to know whether the pile is face up and searchable. |
| C5 | Scheme ends with "proceed to the next **Scry** Phase" | — | Almost certainly a typo for **Swig**. |
| C6 | Elements are Earth, Water, Fire, Air | Cards say "Three **White**" (Pugilist, Post-Fate Oblate). The mat writes Earth as **G** ("G,G") and colors it green | Is White = Air? Fix one naming scheme and one color per element. |
| C7 | **Separate dice**: a Potency die has only numbers, an Elemental die has only elements | Many cards assume **one die face has both a number and an element**: "On rolling an E, discard that die and gain E equal to the Potency" (Bezoar Seeker), "gain W equal to the face's value" (Hollow-Bellied Saint, Fire-Drake, Flayed Flagellant…), "a hand of all **A6s**" (Driveling Chemist), Lead Drinker's W reroll "rolls a 1", Spagyric Physician's "token matching that face's color" | **The biggest structural question.** Reeking Husk ("discard that die *and a Potency die*, gain E equal to the Potency") is written for separate dice. The rest look like leftovers from a combined-face design. |
| C8 | The default commit minimum is already 3 | Gargoyle Mother: "you only need to commit 3 dice per roll" | As written, this card does nothing. The default must once have been higher. |
| C9 | All dice are committed before scoring | Primed Pomologist ("highest Potency among **uncommitted** dice on scoring") and Gout-Ridden Glutton ("if you have **no uncommitted dice** when scoring") | Under current rules there are never uncommitted dice at scoring, so Pomologist never fires and Glutton always does. This implies an older rule that let you stop rolling early. |
| C10 | Hands are built from 4 potency dice | Five Straight is a base hand, and Perennial Pruner says "score 6 (or more) dice in a hand" | Five Straight is **impossible** without a bonus potency die. "Hand size" is undefined (see M2). |
| C11 | `render.py` requires an `On Pickup` column for a card to count as `is_finished` | The current sheet has no such column, in either the published link or the `tarot table` tab the pipeline reads. The content is otherwise the same. | The committed sandbox (43/80 finished) was built from an older sheet. **The next rebuild will show 0 cards in the digital sandbox.** "On pickup" rules have also vanished from the game. Intentional? This is a pipeline issue, not a rules issue. |

---

## 3. Missing or undefined mechanics

These must be decided before a Godot version can run. They are roughly ordered by how much else depends on them.

**M1. Die model (see C7).** Separate dice or combined faces? Every "face", "crystal", "Potency", "rotate" and "swap in" depends on this.
→ *Proposal:* keep separate dice, but define a die as 6 **face slots**, each holding either a Potency (number) or a Crystal (element), or nothing (an "empty" face). Then "swap in a W crystal" means replacing a slot's content, and "bonus die that starts empty" works naturally. Rewrite the combined-face cards (Bezoar, Saint, Eulogist, Fire-Drake, Sapper, Flagellant, Demonologist, Driveling Chemist, Lead Drinker, Spagyric) to the Reeking Husk pattern.

**M2. What is a "hand", and how many do you score?**
- Do you score **one** hand (your best) or **every** satisfied hand, using disjoint dice? Can one die count toward two hands?
- Is a "hand" the specific dice in the set, or all your committed dice? Voiceless Accused ("cannot score a hand with less than 5 dice"), Perennial Pruner ("6+ dice") and Wailing Confessor all depend on this.
- Card triggers like "on scoring a straight" and "on scoring a hand without F" need to know which hand was declared.
- Pairs ("Haphazard Herbalist", "Hopeful Sower: pair, two-pair…") are referenced, but a pair isn't a scoring hand.
→ *Proposal:* after Swig, each player **declares** one hand (a named subset of committed dice). "Scoring X" triggers refer to the declared hand. "Hand size" is the number of dice in it. Allow a second declaration only through cards.

**M3. Scry ordering and simultaneity.** Claims are effectively simultaneous, since Academic Artillerist lets you "choose before other players". But tier-3 players take 2 cards, and each taken card is replaced right away, so the timing of claims and reveals matters:
- Is there a reveal-all-claims step? Do tier-3 players pick their second card after first claims resolve?
- Who sees the replacement first? "Let your opponent take it, then see what replaces it" suggests a sequential sub-step that doesn't exist yet.
- How does buying a slot with 3 tokens interact with wagers?
→ *Proposal:* simultaneous secret first claims → reveal → resolve wagers → replace → next claim pass, in descending tier. Artillerist acts first within a pass.

**M4. Tokens.** Base income is **zero**: nothing in the rules grants tokens. Wagers, slot-buying and most key engines need them, so a player with no token-generating cards has no way into that economy. Also:
- Is Q (Quintessence) a token that can be wagered?
- Is "Spend 2Q" from one pool?
- Can token counts go negative? (Footnoted Scholar: "opponent loses 3 tokens of their choice" when they have fewer.)

**M5. Teeth.** These appear on ~20 cards but have no rule. What is the starting count (the sandbox uses 10), and what happens at 0: elimination, inability to pay, or nothing? Is "lose a tooth" mandatory when you have 0? Several cards use teeth as a cost ("spend 1 tooth"), so they're both life and currency.

**M6. Keys.**
- When is a win checked: immediately, or at end of round? Who wins ties?
- Can keys be lost? (Haphazard Herbalist: "lose 1 key to regain 2 teeth".)
- Lockpicking Archon / Insane Incandescent raise the target by one. Does that stack, and does it last while the card is active or forever?

**M7. Time units.** The cards use *roll, hand, turn, round, Scry, Scheme start, before rolling, start of every turn, after each round, end of a round* interchangeably.
→ *Proposal:* define **Round** = Swig + Scry + Scheme. **Roll** = one throw within Swig. Drop "turn" and "hand" as time units (keep "hand" for M2). Then define fixed hook points: `round_start`, `before_roll`, `on_roll`, `on_commit`, `swig_end`, `on_score`, `on_claim`, `scry_end`, `scheme_start`, `scheme_end`, `round_end`.

**M8. Orientation.** Is it free to re-choose every Scheme? If so, every card's "spend 2X: gain 1 key, incinerate this" side is always available, and each card becomes a key coupon. Do both sides' "While this is active" text count only while that side is upright? Hollowhead's "only 2 other **active** cards" needs a meaning for "active": in play, or upright?

**M9. Vocabulary.** Define: *bury / unbury* (tokens stored on a card; do they leave with it when it's incinerated?), *rotate* (move a die to an adjacent face? "one face over" implies a face ordering) vs *manually rotate* vs *swap* vs *swap in*, *uncommit*, *discard a die* (gone for this round only?), *claim* vs *request*, *incinerate* (from your area, from the Town Square, or both?), "send" (= spend), *italicized section* (which text is italic? The CSV export loses formatting, so this needs to be explicit in the sheet).

**M10. Die-face inventory.** Cards like "Gain a W face. Next Scheme, you may swap it in." imply an inventory of loose faces. Where are they kept, and do they expire?

**M11. Card limit.** "By default only 4 villagers." Faustian Scholar turns itself into a permanent extra empty slot, and Promethean Pyro counts "empty card slots". Do slots exist as objects? Can the 5th card held during Scry trigger anything before the trim?

**M12. Trigger chains.** Several rotate effects say "this **does** trigger another 'on roll'". That allows loops (rotate → on-roll trigger → rotate…). It needs a rule like "each card triggers at most once per die per roll", or explicit once-per limits.

**M13. Wager edge cases.** Can you wager 0? Can you wager with only one player wanting the card? Does a player who has already spent tokens this phase lose them?

---

## 4. Card-level issues

**Blank or TODO sides (14):** Stonefaced Stoic (VIII inv), Bird-Fouled Hagia (IX inv), Orgasmic Musician (TODO) / Brooding Composer, Tarred Prophet, Sulfurous Sage / Socratic Self-Slayer (both blank), Staunch Stoker, Esteemed Burgher, Unshakable Empiricist, Persecuted Paranoiac (half TODO), Placenta Purloiner / Viscera Monger (both blank), Failed Exorcist. Row 79 has a stray "Hirudotherapist" inverted name with no card.

**Identical text (probably copy-paste):**
- Lockpicking Archon (I inv) = Insane Incandescent (XVIII inv)
- Hollow-Bellied Saint (Cups 4) = Enthralling Eulogist (Cups 5)
- Flaming Heretic (Wands P inv) = Burnt Effigy (Wands Pr inv)
- Burn-Scarred Glasswright = Sadistic Shepherd ("Spend 2E: key + incinerate")
- Expendable Assistant = Doomed Pandorite; Sun-Blinded Prismist = Candid Jester

**Broken as written:**
- Gargoyle Mother: no effect (C8).
- Primed Pomologist and Gout-Ridden Glutton: see C9.
- Driveling Chemist ("all A6s, you win"): impossible with separate dice. With combined faces it's an instant-win lottery.
- Promising Pugilist: offers 5-Straight, which is impossible in the base game.
- Venemous Vessel: "roll two A" is rare (1 A face per die). Is "discard to bury" optional?
- Knower of True Names: "swap in a W crystal", but onto which die and which face?
- Toothless Grinner ("any 'or' may become 'and' for 2Q"): an open-ended text-rewrite. In code it needs every card's "or" points marked explicitly.
- Self-Sacrificant: a "swap" opportunity isn't a defined thing.
- Shunned Executioner: "at start of every turn, incinerate a card". Mandatory? Which card? Can it be itself?
- Haphazard Herbalist / Hopeful Sower: reference "pair", which isn't a hand.
- Twofold Widow: buries **E** on a Cups (Water) card. Possibly meant W.

**Implies values outside 1–6:** Corpse-Like Pauper (a 9 face), Vivisectionist and Primed Pomologist ("6+"). That's fine if intended, but straights and "all ≥ 4" then need defining for values above 6.

**Typos / encoding:** "converta", "burried", "perminiently", "ressurect", "Examanor"/"swap of any two", "Hermet", "Chose", "Whenver", "Whenevere", "a W" vs "an W", "1w", and "Branded Prot�g�" / "gunner�s" (a mojibake problem with the CSV encoding).

**Print-and-play art mismatches:** `pilar` (file is `pillar.png`), `venus` (file is `venus fly.png`). `quarryman`, `nun`, `insane` and `homunculus` have no file.

---

## 5. Napkin math: base Swig phase (no cards, 4 potency + 4 elemental dice)

"Optimal" means the best possible commit choice at every roll when chasing that single goal. These are exact values, not simulations.

| Hand | Tier | Single throw of all 8 | Optimal play chasing it |
|---|---|---|---|
| Three Straight | 1 | 27.8% | 77.0% |
| Triplet | 1 | 9.7% | 50.5% |
| Two Pairs | 1 | 6.9% | 32.3% |
| Three of a Color | 1 | 25.5% | 81.1% |
| Four Straight | 2 | 5.6% | 33.8% |
| Two Ones | 2 | 13.2% | 49.0% |
| Four of a Color | 2 | 2.6% | 34.2% |
| All Colors | 2 | 7.4% | 37.6% |
| **Two Earth** | 2 | **40.7%** | **87.9%** |
| Five Straight | 3 | 0% | **0% (impossible)** |
| Three Sixes | 3 | 1.6% | 18.2% |
| Quadruplet | 3 | 0.5% | 10.2% |
| Three Air | 3 | 1.6% | 18.2% |

**Thresholds under optimal play:**

| Goal | P |
|---|---|
| Score anything (tier ≥ 1) | **99.7%**. Scoring nothing happens about 1 round in 300. |
| Tier ≥ 2 ("pick any card") | **96.5%** |
| Tier ≥ 2 without Two Earth | 78.7% |
| Tier ≥ 2 without Two Earth and All Colors | 73.7% |
| Tier 3 (two cards) | 30.1% |
| Max expected cards per round (T1=1, T2=1, T3=2) | 1.26 |

**What this means:**
1. **The tier ladder is inverted.** Two Earth (tier 2) is the easiest hand in the game, easier than every tier-1 hand. Even without it, tier 2 is reached about 79% of the time, because the 5 tier-2 hands span both dice pools and a player can chase several at once.
2. **Tier 1 is almost never the best option.** Restricting a claim to one slot rarely matters, since a competent player picks any card about 97% of the time.
3. **"Score nothing" triggers almost never happen in base play.** Glass-Eyed Alchemist, Ayahuascite, Fleabitten Penitent, Worm-Brained Absinthard, Oathkeeper and God-Struck Fool rely on them, so those cards are weak or do nothing unless discards or penalties push players into empty hands.
4. **Element hands are much easier than number hands**, because the elemental die has duplicate faces (E and W are each 1/3). Three of a Color (81%) is mostly "three Earth or three Water".
5. **Pace.** Expect about 1.26 claims per player per round. Players reach the 4-card cap in about 3 rounds, so after that **about one incinerate per player per round is routine**. That makes "whenever you incinerate" cards steady engines rather than rare triggers. The deck loses about 1 + 1.26×N cards per round: roughly 21 rounds at 2 players, 15 at 3 and 12 at 4 before the deck runs out. Reaching 10 keys in 12 rounds means nearly one key per round, which pushes the design toward repeatable "spend 5–6 tokens: gain 1 key" engines.

**Cards that change the probabilities a lot (worth modelling next):** Hard-Tack Baker (a triplet counts as a quadruplet, so tier 3 goes from about 10% to about 50%), Binger and Hairshirt Bearer (easier straights), Pillar-top Hermit (bonus all-6 die makes Three Sixes trivial), the bonus-die cards (a 5th potency die makes Five Straight possible), and Mooncalf Mother ("rotate any die to any face once per roll").

---

## 6. Implications for a Godot implementation

To be data-driven, each card side should become a list of **(trigger, condition, cost, effect, limit)** records. The current text already implies this vocabulary:

- **Triggers:** static while-active · `on_roll(face)` · `on_commit(set)` · `on_score(hand)` · `on_score_nothing` · `on_claim(self|opponent)` · `on_incinerate(self|any|this)` · `on_gain_token(type)` · `on_gain_key` (an augment/replace effect) · `on_lose_tooth` (replacement: "instead you may") · `on_discard_die` · `on_swap` · `on_rotate` · `on_opponent_{gain_key,lose_tooth,incinerate}` · `scheme_start` · `round_start` · `before_roll` · `round_end`
- **Activated abilities:** "Spend X to Y" at any time, or within a phase.
- **Effects:** gain/spend/convert token, bury/unbury, gain/lose key or tooth, incinerate (self, own card, square card), claim (square, top of deck, discard pile), rotate/swap/edit face, add bonus die, uncommit/reroll/discard die, modify scoring (hand substitution, gap straights, fewer dice), modify win threshold.
- **Limits:** once per roll/Scry/round, plus a loop guard (M12).
- **Replacement effects** ("whenever you would…, instead") need their own resolution layer, separate from triggers.
- **Simultaneous decisions** (Swig, Scry claims, wagers) need a pending-choice queue. When several triggers fire at once, the controller orders them, with an active-player order defined between players.

Two things would make the sheet machine-readable: a `trigger` column and an explicit `once_per` column. The free text can stay for print.

---

## 7. Decisions to make first, at the source

1. Die model: separate dice or combined faces (C7 / M1).
2. What a hand is: one declared hand or many, and what "hand size" means (M2).
3. Scry claim order, replacement visibility and tier-3 double picks (M3).
4. Rebalance the tier ladder: at least move Two Earth, and decide whether Five Straight stays as a card-enabled hand (section 5).
5. Teeth: starting count and what happens at 0 (M5). Base token income (M4).
6. A fixed time-unit glossary (M7) and a vocabulary glossary (M9).
7. Whether orientation can be re-chosen freely every Scheme (M8).
8. Fill in the 14 blank sides and de-duplicate the copies.

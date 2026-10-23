# Card & rules issue sweep v3 (2026-10-22, fifth pull)

Snapshot: [source_snapshot/](source_snapshot/). Supersedes [issues_v2.md](issues_v2.md). All 156 faces are still filled.

**Big rules changes this pull:** dice are now Ready / Commit / Discard, and you must commit *or discard* ≥5 per roll. You may score multiple sets, with each die in one set. Scoring is automatic. "Additional" doesn't retrigger. "Incinerate/Invert a card" means your own card. Undiscard is a reroll. Unscored committed dice aren't "scored". Teeth are capped at 10.

## ✅ Resolved since v2
Hollowhead / Back-Alley Butcher loops and Haunted Mind cascade (the "additional" rule) · whose card "incinerate a card" means · multiple sets · Paid Mourner "score twice" · empty faces (parenthetical on Incandescent and Alembic) · "manually set at Swig start" (now "rotate and commit a ready die") · turn → round on Parishioner and Executioner · Pomologist and Glutton now use discarded dice · Passive Puffer (5+) · Carrier of the Droplet (own card) · timing on Idealist, Homunculus, Kismet and Tumorous · Pruner "may" · stale set names on Herbalist, Sower, Spagyric, Pugilist and Larcenist (the menu now says "Five of a Color") · Pedagogue/Jester duplicate · Follower/Acolyte duplicate · Archon/Incandescent duplicate · Fleabitten, Powder Miller and Hard-Tack Baker rebalanced · typos: Hermit, Apostate, Pyro · Rules: "< 5", "next Swig", "cadre".

## A. Exploits (highest priority)
| Card(s) | Problem | Suggested fix |
|---|---|---|
| **Sun-Blinded Prismist** (still open, now worse) | Discards count toward the ≥5 minimum, so you can discard all 10 dice. "All your committed dice show A or 6" is then vacuously true: **a guaranteed win on any Swig**. Even if a nonzero count is required, committing a single 6 and discarding the rest wins. | "If you have **8+ committed dice** and all show A or 6: you win." |
| **"Per discarded die" income: Branded Protégé (1F), Pot-Licking Friar (1W), Lithiated Assayer (1F buried)** | Discarding is now free and satisfies the minimum, so discarding all 10 dice gives ~10 tokens per Swig. Protégé + Powder Monkey (5F → key, repeatable) = **2 keys per round**. Friar + Paid Mourner (6W → key) or Discarded Follower is the same. Add Fingerless Sapper (2F: undiscard all, then discard again) and it's ~4 keys per round. | "Once per roll, when you discard one or more dice: gain 1F", or "the first die you discard each Swig". |
| **Lethean Elder** | Scoring nothing is now trivially chosen (discard everything), so this is **on-demand: wipe your cadre → 2 keys**. Also gives free value to Tosspot (3W), Glass-Eyed Alchemist (A = highest discarded Potency, so 6A), Ayahuascite and God-Struck Fool. | Either accept that "score nothing" is a deliberate play, or require "…while you have 5+ committed dice". |
| **Brawny Striker** (still open) | On every E rolled: lose 2 teeth / 8E / 4Q / 2 cards → key. Undiscard rerolls (Lead Drinker, Sapper, Leech Catcher) and rotations to E add even more triggers. | "Once per round". |

## B. Rules questions still open
1. **One request per set scored?** With multiple sets allowed, does Three Straight + Triplet let you request slot 1 *and* slot 3? Paid Mourner's "allows you to make another villager request" implies one request per Scry normally. State it in the Scry section.
2. **Does a replaced tooth loss still pay a cost?** This is more urgent now that **Lockpicking Archon** exists. Attach it to *your own* card ("any player's card"): "cannot lose teeth". Can you then pay Brawny Striker's or Pact Proctor's "lose a tooth" costs for free? The same question applies to Stoic, Boxer, Oathbreaker, Archaeologist, Mummy Grinder and Craven Cannoneer.
3. **Voluntary incineration** is only implied ("typically… by having a full cadre"). One sentence would settle it: "You may not incinerate your own villagers except when a rule or card tells you to."
4. **"Invert"**: does the free Scheme orientation choice count as inverting? It matters for Pedantic Pedagogue ("when they invert a card, they lose 1 tooth"), which would otherwise hit every Scheme.
5. **"Rotate" with no target.** "Rotate and commit a ready die" (Discarded Follower, Pruner, Sinuous Acolyte, Mummy Grinder) doesn't say "to any face". Bezoar's version is "one face over". Define a bare "rotate" as "to any face" in the rules, or spell it out on each card.
6. **Undiscard after the Swig ends.** The Swig ends when no dice are ready. Can Lead Drinker, Sapper or Leech Catcher undiscard after that to start another roll?
7. **"3 Tokens" to request**: three of one type, or any mix?
8. **Italics = cost** is still not in the rules (Strawman, Apostate and Anesthetist depend on it).
9. **Scheme-start / Scry-start trigger order** (needed for Godot): suggest "owner chooses order".
10. **Tooth swap counts as a loss?** This matters for Doomed Romantic with Craven, Placenta, Sovern and Stoic. Esteemed Burgher "placing" a tooth raises the same question.
11. **"Round"** is still never defined in the rules, but cards use it. Rules line 81 says "final turn".

## C. Card-specific (still open from v2 unless marked NEW)
- **Lockpicking Archon** (NEW): it can be attached to any player's card, including your own. On an opponent it's a key lock (similar to Empiricist); on yourself it's tooth immunity. Intended? Also "any players card" → "any player's card".
- **Discarded Follower** (NEW): "rotate and commit a ready die" has no "may", so it's mandatory.
- **Fleabitten Penitent** (NEW): it now triggers only on Five Straight (~13% smart), and you lose a tooth on any *other* scored set. Scoring Five Straight plus a second set does both. That's probably too punishing now.
- **Oathkeeper** (NEW with multi-set): if you score Triplet *and* something else in the same Scry, do both lines fire (gain Q, then incinerate)?
- **Barefoot Pilgrim**: still the old wording. Match Kismet Syzygyst: "On Scheme start: incinerate this card to permanently gain another elemental die with only W faces."
- **Knower of True Names**: "swap in a W crystal". Onto which face?
- **Stonefaced Stoic**: do buried teeth count toward your total (Putrescence, Doomed Romantic)? What happens when it's incinerated by trimming to 4?
- **The Tallyman**: bury one of *your* Potency dice, or a new die?
- **Esteemed Burgher**: does the tooth stay on the slot or slide with the villager? Does the owner pay too? Once only?
- **Bacchus Host**: "win all wagers". Can it wager 0? With Perennial Pruner (win a wager → tooth) it's a tooth engine.
- **Overworked Gravedigger**: "name a set… you can only score that set" is still mandatory. Note that scoring is now automatic: does a non-named set then simply not count?
- **Broken Martyr**: mandatory each Scry start. With Stoic it nets +1 tooth per round. With Mercury-Blooded it's free 4E per round, and with Expendable Assistant free 1Q per round. Each round it also feeds opponents' Wrathful Sovern (3F → key) and Placenta Purloiner. A Martyr owner with Craven Cannoneer is still hit, because the loss is self-inflicted.
- **Socratic Self-Slayer**: "the player with the most keys" could be you. Should be "an opponent with the most keys".
- **Sulfurous Sage**: "0 of any E, W, F or A" can be read two ways.
- **Fairy-Chaser**: is "exactly 5" checked before or after gaining?
- **Failed Exorcist**: cadre order is undefined, and so is the leftmost case. Can it copy an attached card or another copier?
- **Mummy Grinder**: which sets count as "'x of a color'": Two Color-Pairs, Four of a Color, Five of a Color, Four Air?
- **Feverish Scribe**: when the threshold equals the buried A, does Insane Incandescent's +1 still add on top?
- **Toothless Grinner**: Godot needs a list of which "or"s qualify.
- **Faustian Scholar**: "lay this card upside down" collides with upside-down meaning inverted. Use "face down".
- **Primed Pomologist** (NEW, balance): discarding a single 6 now reliably pays 2Q or 6E every Scry.

## D. Duplicates still present
Virgin Pure = Bloodless Somnambulist (W face) · Flaming Heretic = Burnt Effigy (F face) · Hollow-Bellied Saint = Enthralling Eulogist.
Near-duplicates: Bloodstained Recluse (all-F set → wipe → 2 keys) vs Lethean Elder (score nothing → wipe → 2 keys). Lethean's condition is now fully under your control, so Recluse is almost always the worse of the two.

## E. Wording / typos
- **Branded Protégé**: the cell still contains replacement characters ("Prot�g�").
- Kismet "perminently", Tumorous Magi "perminiently" → permanently.
- Incandescent and Alembic "comitted" → committed. Alembic has a stray comma after "empty,".
- Feverish Scribe "threshhold" → threshold.
- Hard-Tack Baker "Quadruples" → Quadruplets.
- Gout-Ridden Glutton "On Scry start, If" → "if".
- Spagyric "Triplet or Quadruplet gain" → add a comma.
- Incorruptible Judge "If you get 0" → "have".
- Twofold Widow "spend 1E on this card" → "1 buried E".
- Driveling Chemist "scheme" → Scheme.
- Bloodless Somnambulist has a trailing space in its name.
- Capitalization: "four earth / four water / four fire" vs "Four Air"; Hairshirt "Three straight".
- **Rules doc:**
  - "chose to" → choose.
  - "not an opponentsunless" → "an opponent's, unless".
  - "considered "scored'." has mismatched quotes.
  - The Question Solvers example says "Four of a Kind (fire)", which isn't a set name; the set is Four of a Color.

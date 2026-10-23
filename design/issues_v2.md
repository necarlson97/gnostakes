# Card & rules issue sweep (2026-10-22, fourth pull)

Snapshot: [source_snapshot/](source_snapshot/). **All 156 faces are filled; no TODOs.**

## A. Infinite loops / instant wins (fix first)
| Card | Problem | Suggested fix |
|---|---|---|
| **Hollowhead** | "When you gain a key … gain an additional key." The extra key is also a key gain, so it re-triggers forever. | Global rule: *"Keys gained from an ability don't trigger 'when you gain a key' abilities."* Or "once per round". |
| **Back-Alley Butcher** | Same loop. Each extra key re-triggers: lose all tokens, then lose a tooth per loop until 0 teeth. The first key becomes ~10 keys. | Same global rule. |
| **Haunted Mind** | "Whenever that opponent incinerates a card, they must incinerate another." The forced incineration re-triggers it, so one incineration wipes their whole cadre. | "…they must incinerate one other card (this does not re-trigger)." |
| **Sun-Blinded Prismist** | "If all your committed dice show A or 6: you win." You may discard instead of committing, so a first roll with 4+ A/6 among 10 dice (~7% raw) wins outright. Rotators (Mooncalf, Flagellant, Traitor, Jar Dweller), Hermit's all-6 die, Confessor's all-A die, and Quarryman push it near-certain. | Require a count: "If you have **8 or more** committed dice and all show A or 6." |
| **Brawny Striker** | Can be used every time you roll an E (2/6 of faces, ~1.7 per roll). "Lose 2 teeth → key" turns 10 teeth into ~5 keys in two rounds. Rotating to E re-triggers on-roll (per Question Solvers). | "Once per round". |

## B. Rule questions the cards depend on (need a Rules-doc answer)
1. **Can you incinerate your own villager voluntarily?** The rules only allow incinerating down to 4. Without voluntary incineration, attachments (Empiricist, Headshrinker, Haunted Mind, Prophet, Composer, Examiner) are permanent. Cards that say "incinerate a card" as a cost would also need a target rule.
2. **"Incinerate a card": whose card?** Shepherd, Furnace Keeper, Leech Catcher, Executioner, Gourmand and Brawny Striker don't say. Only your own cadre? Town Square too?
3. **Can you choose to score nothing?** If yes, Lethean Elder becomes on-demand "wipe your cadre → 2 keys". It also matters for Tosspot, Glass-Eyed Alchemist, Ayahuascite, God-Struck Fool and Fleabitten.
4. **Does replacing a tooth loss still pay a cost?** Stoic, Boxer, Oathbreaker, Archaeologist and Mummy Grinder replace tooth losses. If a card's *cost* is "lose a tooth" (Pact Proctor, Purger, Brawny Striker, Psychotic Christ), does the replacement still count as paying it?
5. **How many sets per Scry, and can one die count twice?** (Still open from D2.) Oathkeeper ("anything else") and Paid Mourner ("score a set twice") depend on it. "Score a set twice" also needs a meaning: claim twice, or trigger twice?
6. **Empty die faces.** Archon and Incandescent ("starts empty") and Alembic Servitor ("must remain empty") need rules for rolling an empty face, committing it, and whether it counts toward the commit minimum.
7. **"Manually set a die face" at Swig start** (Perennial Pruner, Mummy Grinder). The die is about to be rolled. Does it skip the roll, or is it committed as set?
8. **"Turn" vs "round".** Pious Parishioner ("single turn") and Shunned Executioner ("every turn") use "turn"; other cards use round, Swig, Scry or Scheme. Define one, or reword.
9. **Scheme-start trigger order.** Many cards fire "On Scheme start". Godot needs an order, e.g. the owner chooses.
10. **"3 Tokens" to request.** Three of one type, or any mix? (The mat used to say 3 of one element.)
11. **Italics = cost** still isn't stated in the rules, and Strawman, Closeted Apostate and Autoerotic Anesthetist depend on it.
12. **Does a tooth swap count as losing teeth?** For example Doomed Romantic, which matters for Craven Cannoneer, Placenta Purloiner, Wrathful Sovern and Stoic. Does placing a tooth count as losing one? That matters for Esteemed Burgher.

## C. Cards that never or always trigger under the current rules
- **Primed Pomologist**: "highest Potency among *uncommitted* dice on scoring". Every die is committed or discarded before scoring, so it never fires.
- **Gout-Ridden Glutton**: "if you have *no uncommitted dice* when scoring". Always true.
- **Passive Puffer**: "commit 4 dice at once". Exactly 4, or 4+? With a minimum commit of 4, it fires almost every roll either way.

## D. Ambiguities on individual cards
- **Carrier of the Droplet**: "invert a card". Any player's card? Inverting opponents' cards is far stronger.
- **Knower of True Names**: "swap in a W crystal". Onto which face?
- **Hardnosed Idealist, Beloved Homunculus, Kismet Syzygyst, Barefoot Pilgrim, Tumorous Magi**: one-shot effects with no timing. Scheme only?
- **Stonefaced Stoic**: "incinerated by another card". What about trimming down to 4 villagers in Scheme, or voluntary incineration? Do buried teeth count toward your tooth total (Putrescence, Doomed Romantic)?
- **The Tallyman**: "Bury a Potency die". One of your own (losing it meanwhile), or a new one?
- **Esteemed Burgher**: does the tooth stay on the slot or move with the villager as the row slides? Does the owner pay too? Once, or repeatable?
- **Bacchus Host**: "You win all wagers". Can it wager 0 and still win? Combined with Perennial Pruner (win a wager → gain a tooth), it becomes a tooth engine.
- **Overworked Gravedigger**: "name a set … you can only score that set" reads as mandatory. Probably should be "you may".
- **Perennial Pruner**: "you spend 2E" is missing "may".
- **Broken Martyr**: no "may", so it's mandatory each Scry. It also triggers opponents' Wrathful Sovern and Placenta Purloiner. Combined with Stoic, the loss is buried and then a tooth is gained, a net +1 per Scry. Combined with Mercury-Blooded, it gives free 4E per Scry, and with Expendable Assistant, free 1Q per Scry.
- **Socratic Self-Slayer**: "the player with the most keys" could be you. Should be "an opponent with the most keys".
- **Sulfurous Sage**: "if you have 0 of any E, W, F or A" can mean at least one at zero, or all at zero.
- **Fairy-Chaser**: is "W is exactly 5" checked before or after gaining?
- **Failed Exorcist**: needs a cadre order. What if it's leftmost? Can it copy an attached card or another Exorcist?
- **Mummy Grinder**: "'x of a color'". Does that include Two Color-Pairs and Five of Any Color?
- **Feverish Scribe**: "'10 keys'" should say "the Enlightenment threshold" so it stacks with Archon and Incandescent.
- **Toothless Grinner** ("or" → "and"): Godot needs an explicit list of which "or"s qualify. Brawny Striker, Lithiated Assayer, Intrepid Archaeologist, Oathbreaker and Footnoted Scholar all have one.
- **Faustian Scholar**: "lay this card upside down" collides with upside-down meaning inverted. Use "face down".

## E. Stale set names
- **Haphazard Herbalist, Hopeful Sower**: "pair, two-pair, triplet, quadruplet". "Pair" and "two-pair" aren't sets; the current ones are Two Color-Pairs and Four Pairs.
- **Spagyric Physician**: "two-pair or triplet".
- **Reliquary Larcenist**: "Five of a Color" (menu: Five of Any Color).
- **Hairshirt Bearer**: "'3 straight'" (menu: Three Straight).
- Capitalization is inconsistent: "four earth / four water / four fire" vs "Four Air". These aren't menu sets either (except Four Air). Fine as conditions, but capitalize consistently.

## F. New duplicates / dominance since the last audit
- **Virgin Pure = Bloodless Somnambulist** (both "gain a W face"). New identical pair.
- **Flaming Heretic = Burnt Effigy** (now both "gain an F face"). Still identical.
- **Pedantic Pedagogue** is exactly Candid Jester's first line, so Jester strictly dominates it.
- **Discarded Follower**'s first line is word-for-word Sinuous Acolyte.
- Still identical: Saint = Eulogist, Archon = Incandescent.

## G. Balance flags (not bugs)
- **Fleabitten Penitent**: a key on every straight scored (Three Straight is ~77% under smart play, near-certain with Binger or Hairshirt). That's about 1 key per round from a single card.
- **Powder Miller**: "Scheme start: gain 2F" funds its own 2F cash-out, so it's a free key one round after you claim it.
- **Hard-Tack Baker**: Triplet (~54%, easy tier) scores as Quadruplet (hard tier: claim 2).
- **Unshakable Empiricist**: shuts off all of an opponent's keys while attached. How strong it is depends on B1.

## H. Typos / data
- **Branded Protégé**: the sheet cell literally contains replacement characters ("Prot�g�"). Retype the é.
- Pillar-top **Hermet** → Hermit.
- Closeted Apostate: "perform **and** italicized" → "an".
- Promethean Pyro: "a A" → "an A".
- Incorruptible Judge: "If you **get** 0 non-E tokens" → "have".
- Twofold Widow: "spend 1E on this card" → "spend 1 buried E".
- Driveling Chemist: "scheme" → "Scheme".
- Bloodless Somnambulist has a trailing space in its name.
- Rules doc: "Or all, if there were **< 3** remaining" → < 4. "proceed to the next **Scry** Phase" → Swig. "cabal" vs "cadre" (pick one).

# Gnostakes design decisions log

These are decisions made in conversation. Each one still needs to be **written into the Google sources**, which are the single source of truth. When a decision lands in the source, mark it ✅.

## D1. Die model: separate dice (resolves C7 / M1), 2026-10-21
Potency dice carry numbers and Elemental dice carry elements. A face never has both.
Cards that assumed combined faces get rewritten in this pattern: *"On rolling an E, you may discard a Potency die to gain E equal to that Potency."*
Affected cards: Bezoar Seeker, Hollow-Bellied Saint, Enthralling Eulogist, Fire-Drake, Fingerless Sapper, Flayed Flagellant, Dubious Demonologist, Lead Drinker, Spagyric Physician, Driveling Chemist ("all A6s").
- [x] ✅ Cards rewritten in the sheet 2026-10-21 (see [sheet_edits/CHANGELOG.md](sheet_edits/CHANGELOG.md)). Driveling Chemist's wording still needs review.

## D2. Retire the word "hand" (resolves M2 in part), 2026-10-21
| Term | Meaning |
|---|---|
| **Set** | One satisfied scoring condition, e.g. a single Two Pairs. "Scoring a set" means satisfying it. |
| **Committed dice** | All dice committed this Swig, both scoring and non-scoring. |
| **Scoring dice** | The committed dice used to satisfy the sets you scored. |
| **Non-scoring dice** | Committed dice that aren't scoring dice. |
| **Discarded dice** | Dice removed this Swig. They are neither committed nor scoring. |

Still open: how many sets a player may score per round, and whether one die can count toward two sets.
- [x] ✅ Cards updated in the sheet 2026-10-21. "Once per hand" became "Once per round".
- [ ] Rules doc updated (the user is doing this by hand)

## D3. Teeth, ✅ in rules (pulled 2026-10-21)
The rules now give 10 starting teeth. The game ends at the end of the next Scheme after any of: **Enlightenment** (someone reaches 10 keys), **Putrescence** (someone has 0 teeth), or **Conflagration** (the deck runs out). The most keys wins.
Still open: tiebreak when keys are equal.

## D4. Tokens vs faces, needs terminology
Tokens are E / W / F / A, plus Q (Quintessence, which can be spent as any token).
*Proposal:* **Token** = the currency. **Crystal** = the element printed on an Elemental die face. **Potency** = the number on a Potency die face. The cards already say "swap in a W crystal" and "replace a crystal face", so this only formalizes current usage. In card text: "gain 2 W" means tokens, and "a W crystal" means a die face.
- [ ] Adopted at source. Quintessence added to the rules.

## D5. Scry contention, as worded
A taken card is always replaced immediately. Players either wager for the same villager or wait to see the replacement. For implementation, this still needs a reveal order (who claims first; when tier-3 players make their second pick).

## D6. Set difficulty targets: design against SMART play (revised 2026-10-21)
| Outcome | Smart-play target | (v1 raw-roll target, kept as a check) |
|---|---|---|
| Score nothing | 1–5% | ~30% |
| Easy set or better | ~95% | ~70% |
| Medium or better | ~80% | ~40% |
| Hard | ~25% | ~15% |

The user expects these to shift after playtesting. Pace target: just over 1 card per player per round.
**Proposed (not yet adopted):** 5 Potency + 5 Elemental dice, commit ≥ 5 per roll (2 rolls), and the R1 "straight ladder" menu, which scores 99.0 / 82.6 / 25.6 under smart play. See [set_tuning.md](set_tuning.md).
- [ ] Dice count, commit rule and mat sets updated at source (the mat is a Drawing, so the user edits it)

## D7. Blank / TODO cards
Brainstorm about 40 candidate abilities, then choose by evocativeness, fun, and the balance gaps they fill. Not started.

## D8. Italics mark costs (observed 2026-10-21)
In the sheet, every italic span is a cost or sacrifice: lose a tooth, spend tokens, incinerate, lose a key. That's what Strawman, Closeted Apostate and Autoerotic Anesthetist mean by "italicized section". Any edit must preserve italic runs (`sheet_edit.py` does). The Godot data model should carry an explicit `cost` field.
- [ ] Say this explicitly in the rules doc

## D9. Engine rulings, 2026-10-22 (user answers; implemented in game/)
- First player rotates each round.
- Town Square slot token prices are slot-specific: 3W / 3E / 3F / 3A. Unlimited paid requests per Scry, for now.
- A wager is a specific handful of tokens; the winner spends exactly that.
- Teeth lost as a cost CAN be prevented/replaced (Archon's key lock is the counterweight).
- Scheme re-orientation counts as inverting. Rules now say "You (usually) only invert cards during Scheme."
- God-Struck Fool: "...if you did not score any Potency dice". Stoic: buried teeth leave your count.
- Trigger order: seat order, then cadre left-to-right.
- Sun-Blinded Prismist: "If all your dice are committed and show either A or 6: you win."
- [ ] Sheet still has: Prismist old text; Silent Companion cell overwritten with God-Struck Fool text; "Potecny" typo on God-Struck Fool.

## D10. Death by Putrescence, 2026-10-22 (rules doc)
Players with no teeth at game end die and cannot win; most keys among the living wins. Teeth regained before the final Scheme ends count. The 10-key end condition is renamed **Edification**.
- Engine: `Game.finish` ignores toothless players; nobody wins if all are dead. Teeth floor at 0.
- Bots: teeth are priced by position. The last tooth is worth LAST_TOOTH (3) plus all your keys; regaining a tooth at 0 is worth the same.
- Context: under the old rules, 33% of 1,209 simulated games were won by a toothless player.

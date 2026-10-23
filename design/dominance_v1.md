# Fill check & dominance audit (2026-10-22, second pull)

Snapshot: [source_snapshot/](source_snapshot/). Rules doc unchanged since the first pull today.

## Fill check
All **78 cards / 156 faces have rule text**. No TODO lines remain. The "Hirudotherapist" row is gone; its rule now lives on Placenta Purloiner. The two empty rows at the bottom of the tab have no Gill Word or name, so they aren't cards. The last two rows hold the gender tally.

## Definitions
- **Identical**: same text on two faces.
- **Strictly worse (card)**: every line of face A is matched or beaten by face B, and B has nothing worse. A player would never prefer A, except for things the card's mere existence triggers (incinerating it, for example).
- **Strictly worse (line)**: one ability is dominated by an ability on another card, but the cards differ elsewhere. This is informational only.
- Abilities that differ only in token type (2E vs 2W) are **not** counted as dominance. E and W appear on 2/6 die faces each, F and A on 1/6, so they aren't equivalent, but neither is strictly better.

## Identical faces (9 pairs)
| Faces | Text |
|---|---|
| Burn-Scarred Glasswright = Sadistic Shepherd | Spend 2E: key, incinerate |
| Dependable Tosspot = Pot-Licking Friar | Spend 2W: key, incinerate |
| Craven Cannoneer = Powder Miller | Spend 2F: key, incinerate |
| Psychotic Christ = Lash-Blessed Monk | Spend 2A: key, incinerate |
| Sun-Blinded Prismist = Candid Jester | Set with an A: key, incinerate |
| Doomed Pandorite = Expendable Assistant | Set with an F: key, incinerate |
| Hollow-Bellied Saint = Enthralling Eulogist | Roll W → discard Potency for W; Scheme −1 |
| Lockpicking Archon = Insane Incandescent | Empty bonus die; +1 key to win for everyone |
| Flaming Heretic = Burnt Effigy | Swap a crystal for F, incinerate |

Note: two Archon/Incandescent faces both active could stack to +2 keys to win.

## Strictly worse — whole face
| Worse | Better | Why |
|---|---|---|
| **Shrewd Quaker** (Scheme −1 only) | Dreaded Abacist, Hollow-Bellied Saint, Enthralling Eulogist, Witch Drowner, Closeted Apostate, Epileptic Metallurgist | Each has the same "may decrease a Potency by −1" line, plus more. Quaker is dominated by 6 faces. |
| **Paid Mourner** (6W: key) | Discarded Follower (6 of any one type: key) | Follower can always pay with W. |
| **Arsenic Apothecary** (E face on incinerate) | Mocking Recluse (any-color face) | Recluse can pick E. |
| **Bloodless Somnambulist** (W face on incinerate) | Mocking Recluse | Same reason. |
| **Confessional Magistrate** (swap two Potencys, after each round) | Clamp-Turning Examanor (swap any two faces, Scheme start) | Same timing in practice; "any two faces" includes two Potencys. |
| **Finger-Bone Forager** (3A: crystal → Q) | Dubious Demonologist | Demonologist has that exact line, plus an A-income line. |
| **Bloodstained Recluse** (all-F set: incinerate *all* your cards, key) | Doomed Pandorite / Expendable Assistant (set with *an* F: key, incinerate this) | The trigger is narrower and the cost bigger. The one exception: mass incineration feeds Pious Parishioner, Corrupted Inquisitor, Witch Drowner and similar, so it's "strictly worse unless comboing". |

## Strictly worse — single line (card differs elsewhere)
| Dominated line | Dominating line | Notes |
|---|---|---|
| Noble Ghost-Writer: once/round, W → rotate one face over | Tongueless Traitor: once/round, 1W → rotate to **any** face | |
| Gin-Soaked Gutter-Sweeper: once/round, W → rotate to match a rolled face | Tongueless Traitor (same) | |
| Covert Degenerate: 1F → uncommit a die | Timeless Warrior-Poet: identical line, plus F on incinerate | Degenerate has two other lines. |
| Reeking Husk: roll E → discard *that die and* a Potency, gain E | Bezoar Seeker: roll E → discard a Potency, gain E | Husk also has an A line. |
| Persecuted Paranoiac: +1A on gaining A | Epileptic Metallurgist: +1 on gaining A **or F** | Paranoiac has a Town-Square refresh line. |
| Oathbreaker: tooth → 5E instead | Intrepid Archaeologist: tooth → 4E instead | Oathbreaker can also incinerate itself instead. |
| Bodysnatcher: 4A → claim top of pyre | Staunch Stoker: 1Q → claim most recently incinerated | Probably the same card. Different tokens, but 1Q versus 4A is lopsided. |

## Close calls (not strict, but worth a look)
- **Repeatable "5–6 tokens: key"**: Powder Monkey (5F) and Overworked Gravedigger (5A) are cheaper than Paid Mourner (6W) and Discarded Follower (6 any). There is no E version.
- **Pilfered Penname** (any straight: key, incinerate) vs **Active Assistant** (triplet: key, incinerate). Same reward, but straights are much easier (Three Straight is ~77% smart vs Triplet ~54%).
- **Unshakable Empiricist** (on pair sets, 3E → 2F) and **Viscera Monger** (on incinerate, 4E → 4A). Both are conditional converters that are weaker than The Tallyman's unconditional 2 any → 1Q. They aren't strict, because the output is a specific token versus Q.
- **Self-Sacrificant** (3 of one token: key, whenever you may swap) is half the price of Discarded Follower (6 of one), but needs a swap permission.

## Wording issues spotted (not asked, flagged for the source)
- Esteemed Burgher, line 3: "those this reserving tooth" is garbled. Probably "lose this reserving tooth".
- Socratic Self-Slayer: "Lose two teeth to take a key from the leader" has no frequency limit. Is it repeatable at will?
- Failed Exorcist "copies the card to the left": undefined if it is leftmost, or if the left card is another Exorcist.
- Sulfurous Sage: "if you have 0 of any E,W,F or A" could mean "0 of at least one" or "0 of all". The first reading makes sense with "gain 1 of each".
- Brooding Composer: "Whenever that opponent gains a key, they gain a tooth instead" can shut down an opponent until the host card dies. It is likely the strongest card in the deck.
- Stale set names are still present: Famed Freemason ("Two Pairs", "Three of a Color"), Promising Pugilist ("Three Sixes", "Three Air"), Post-Fate Oblate ("Three Air").
- Typos: Sheme, burried, oponnent, ressurect, incincerate, "perform and italicized".

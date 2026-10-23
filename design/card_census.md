# Card census & new-rule candidates (2026-10-22)

Source: fresh API pull of the Tarot Table tab and Rules doc, saved to [source_snapshot/](source_snapshot/). Tags were assigned by hand, one row per card face, in [tools/card_tally.py](tools/card_tally.py). Re-run that script after editing the tags.

78 cards = 156 faces. **12 faces are blank** (Stonefaced Stoic, Bird-Fouled Hagia, Brooding Composer, Tarred Prophet, Sulfurous Sage, Socratic Self-Slayer, Staunch Stoker, Esteemed Burgher, Unshakable Empiricist, Placenta Purloiner, Viscera Monger, Failed Exorcist). **2 have a TODO line** (Orgasmic Musician, Persecuted Paranoiac). There are also 3 extra rows: one holds only the name "Hirudotherapist", the other two are empty. That leaves about 14–20 faces to fill.

## 1. Set interactions (faces that reference a set type)

| Set family | Faces | Which |
|---|---|---|
| Straights | 9 | Freemason, Pugilist, Binger, Penname, Twofold Widow, Absinthard, Hairshirt, Fleabitten, Nymph |
| X-of-a-kind (pair/triplet/quad) | 8 | Freemason, Pugilist, Hard-Tack Baker, Herbalist, Acolyte, Oathkeeper, Sower, Spagyric |
| X-of-a-color (named color sets) | 5 | Freemason, Pugilist, Post-Fate Oblate, Mummy Grinder, Reliquary Larcenist |
| Element content ("a set with/without/all X") | 16 | Knower, Judge, Confessor, Ciderist, Smith, Bacchus, Gourmand, Pandorite, Expendable, Bloodstained, Prismist, Jester, Pedagogue, Headshrinker, Haunted Mind, Driveling Chemist |
| Specific Potency (Ones / Sixes / ≥4) | 3 | Pugilist, Smith, Driveling Chemist |
| Generic (any set / nothing / set size) | 9 | God-Struck Fool, Voiceless, Pomologist, Pruner, Oathkeeper, Lethean, Fleabitten, Glass-Eyed, Ayahuascite |
| **Two Color-Pairs, Four Pairs, All Colors, Three Ones, Five of Any Color** | **0** | Nothing references these menu sets by name |

## 2–3. Token income vs spending

| Token | Income | Spend |
|---|---|---|
| E | 13 | **7** |
| W | 10 | 10 |
| F | 12 | 8 |
| A | 11 | 11 |
| Q | 8 | 7 |
| "any one type" | 1 (Spagyric) | 4 (Boxer, Self-Sacrificant, Discarded Follower, Tallyman) |

Pillar-top Hermit reduces income (−1 per gain).

## 4–6. Keys and teeth

| Effect | Faces |
|---|---|
| Key income | **36** (8 are "spend 2X: key + incinerate", 4 are "spend 5–6X: key", 6 are "score a set with an X: key + incinerate") |
| Key loss | 2 (Herbalist, Vivisectionist), plus 2 that raise the win threshold (Archon, Incandescent) |
| Tooth loss (self) | **15** (Judge, Romantic, Pugilist, Purger, Pact Proctor, Faustian, Tumorous, Confessor, Brawny Striker, Lead Drinker, Fleabitten, Broken Martyr, Strawman, Haunted Mind, Back-Alley Butcher) |
| Tooth loss (forced on opponent) | 2 (Pedagogue, Haunted Mind) |
| Tooth protection | 4 (Boxer, Oathbreaker, Mummy Grinder, Archaeologist) |
| Tooth income | **3** (Herbalist, Fairy-Chaser, Broken Martyr, which nets zero) |

## Gaps these numbers show
- **Tooth income: 3 vs 15 loss.** Putrescence is a one-way ratchet.
- **Pair-family and rainbow sets are orphaned.** Two Color-Pairs, Four Pairs, All Colors, Three Ones, and Five of Any Color have no card support.
- **E is the least spendable token** (7 spend vs 13 income).
- **Key income is 25% of all faces, and it's samey.** 18 are near-identical "pay/score X → key (+incinerate)".
- **Opponent interaction is thin.** About 8 faces touch other players at all.
- **Stale set names:** Freemason ("Three of a Color", "Two Pairs"), Pugilist ("Three Sixes", "Three Air"), and Post-Fate Oblate ("Three Air") name sets that aren't on the current menu. Separately, the rules say "commit at least 4 … or all, if there were < 3 remaining" (should be < 4).

## Candidate rules (30)

Tags: [gap filled] · *suggested home* (blank face or TODO). Italics = cost, per D8.

### Teeth come back (tooth income)
1. **Stonefaced Stoic** *(Strength inv.)*: Whenever you would lose a tooth, bury it on this card instead. If 3 teeth are buried here, *incinerate this and lose them all*. If this card is incinerated any other way, regain every buried tooth. [tooth bank; combos with Witch Drowner, Inquisitor]
2. **Hirudotherapist** *(new row)*: Whenever another player loses a tooth, bury 1Q on this card (a leech, fattening). On Scheme start, *spend 2 buried Q* to regain a tooth. [tooth income from others' pain]
3. **Viscera Monger** *(Reason Queen inv.)*: Teeth are now tradeable. During Scry, any player may buy one of your teeth by paying you 3 tokens of your choice. You may refuse only by *losing a tooth*. [player-to-player market]
4. **Placenta Purloiner** *(Reason Queen)*: When an opponent's card is incinerated, you may tuck it face down under this card instead of the pyre (max 3). *Discard a tucked card* to regain a tooth. If this card is incinerated, the tucked cards go with it. [tooth income; starves Pact Proctor and Bodysnatcher]
5. **Grave-Dentist**: Whenever another player loses a tooth, you may *spend 2 of any one token* to take that tooth yourself. [tooth income, interaction]

### Orphaned sets
6. **Brooding Composer** *(Creativity Prince inv.)*: When you score Two Color-Pairs or Four Pairs, bury 1W here per pair ("harmonies"). At 4W: incinerate this, gain a key, and each opponent must commit 1 extra die per roll next Swig (the music keeps them up). [pair sets]
7. **Sulfurous Sage** *(Inspiration King)*: When you score All Colors, gain 1 of each token. If you already held at least 1 of each, gain 1 key instead: the four humours are balanced. [All Colors]
8. **Failed Exorcist** *(Intuition King inv.)*: When you score Three Ones, the demon jumps hosts: choose an opponent's active card and flip it. When you score nothing, the demon returns: *lose a tooth*. [Three Ones, interaction]
9. **Ark-Wright**: When you score Four Pairs, claim one Town Square villager *and* the top card of the pyre: two of every kind. [Four Pairs]
10. **Wedding Officiant**: When you score Two Color-Pairs, wed yourself to an opponent until either of you loses a tooth. Whenever one of you gains a key, the other gains 1Q. [pair sets, alliance]
11. **Lunar Calendarist**: Your 1s may also count as 7s in straights, so the week wraps: 5-6-1 is a Three Straight. [straights, machine-simple]
12. **Prism-Eyed Glazier**: Five of Any Color may be scored with one off-color die, but then *discard that die*. Afterwards, gain 1 token of the off color. [Five of Any Color]

### Somewhere to spend E
13. **Esteemed Burgher** *(Oppression 10 inv.)*: *Spend 3E* to reserve a Town Square slot. No one else may request it this Scry: the guild has spoken. [E spend, contest control]
14. **Plague-Pit Digger**: *Spend 4E* to bury an opponent's card: turn it sideways, inactive, until its owner pays 4E to dig it out. [E spend, lockdown]
15. **Staunch Stoker** *(Speed 8 inv.)*: Once per Swig, *spend 2E* to return a discarded die to your pool and roll it. The furnace never goes out. [E spend; feeds discard cards]
16. **Unshakable Empiricist** *(Innovation King)*: Before a roll, predict one die's face aloud. If it lands, gain 2Q. If not, you may *spend 1E* to "adjust your instruments" and rotate it there anyway. [E spend, flavor]

### Keys with a twist (not "pay X, get key")
17. **Forger of Keys**: *Spend 3Q* to gain a forged key, kept face down with your real ones (keys become two-sided tokens). Any player may *lose a tooth* to flip one of your keys: if forged, it is destroyed and you lose a tooth. If real, the accuser loses another. [bluffing, social deduction]
18. **Tarred Prophet** *(Contemplation Queen inv.)*: At Scheme end, name a set aloud. If no player scores it next Scry, gain a key. If you score it yourself, *lose a tooth*: a prophet mustn't fulfil their own prophecy. [prediction]
19. **Socratic Self-Slayer** *(Inspiration King inv.)*: Hemlock. Once per game, *lose all your teeth but one*, then gain 1 key per 3 teeth lost. [all-in finisher; flirts with Putrescence]
20. **Gilded Cutpurse**: When you score Four Straight, take a key from the player with the most keys. They regain 2 teeth as consolation. [catch-up]
21. **Ouroboric Monk**: Whenever you would gain a key, you may gain 2 teeth instead. Whenever you would lose a tooth, you may *lose a key* instead. [key/tooth exchange]

### Cadre position & table geometry (new axis)
22. **Bird-Fouled Hagia** *(Hermit inv.)*: Each Scheme start, bury 1Q here (droppings). You may take all of it whenever you gain Q elsewhere. If 4+ Q sit here at Scheme start, the roof collapses: *incinerate this and the cards on either side of it*. [introduces cadre adjacency]
23. **Mirror-Kissing Narcissist**: This card has the text of the active card to its left in your cadre. [adjacency, copy]
24. **Rat-Bitten Foundling**: When you claim this, you may place it in an opponent's cadre, inverted side up. They cannot incinerate it voluntarily. *Inverted:* Lose a tooth each Scheme start. [curse gifting]

### Wagers, information, timing
25. **Persecuted Paranoiac**, TODO line: When you lose a wager, keep your wager *and* gain 2A. They were plotting against you all along. [wager]
26. **Loaded-Fist Gambler**: In a wager, you may also hide one die in your fist. Its Potency adds to your wager, and that die sits out your next Swig. [wager, dice-as-currency]
27. **Veiled Hierophant**: Your committed dice stay hidden until all other players have declared their requests. [information; needs D5 reveal order]
28. **Ash-Reader**: Once per round, look at the top 3 deck cards. Put them back in any order, or *incinerate one* to gain 1F. [deck control; speeds Conflagration]
29. **Arsonist Abbot**: *Spend 2F* to incinerate a Town Square villager (not from a cadre). A leader can burn the village down to end the game. [Conflagration lever]

### Dice & sets bending
30. **Orgasmic Musician**, TODO line: Crescendo. If each commit this Swig has more dice than the one before, gain 1W per commit. If you commit everything on the first roll, gain a key and incinerate this. [commit pacing]
31. **Two-Headed Calf**: One die may count toward two sets this Scry, but *lose a tooth* for it. [card-level answer to the open D2 question]

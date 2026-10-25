# Gnostakes ability economy

*Overwritten after every finished league run, alongside [sim_report.md](sim_report.md). Written 2026-10-24 05:54.*

From 650 games (`game/sim/results/20261024-033622`). One **ability line** is one triggered effect, replacement, or activated ability on a card face (one method in its script). An **activation** is a time it actually did something: gained, paid, moved or discarded a die, buried, claimed, incinerated. It is not counted just because its trigger came up. Rates are **per game the card was held**: "winners" means games where the holder won, "others" means games where they didn't. **Lift** = winners' rate / others' rate; above 1 means winners fire it more.

Lines that only change rules ("While this is active...", "You can now score...") have no activations to count. Their effect shows in the card's holder win rate in sim_report.md.

## Busiest lines

| Card face | Line | Per game held | Winners | Others | Lift | Keys/act | Tokens/act | Spent/act |
|---|---|---:|---:|---:|---:|---:|---|---|
| Sinuous Acolyte | on roll | 10.47 | 5.59 | 12.17 | 0.46 | 0.00 |  |  |
| Patient Confidant | on roll | 9.66 | 7.36 | 10.75 | 0.68 | 0.00 |  |  |
| Mooncalf Mother | activated: rotate | 8.20 | 8.25 | 8.18 | 1.01 | 0.00 |  |  |
| Overworked Gravedigger | on swig start | 7.74 | 6.35 | 8.30 | 0.77 | 0.00 | A1 |  |
| Doomed Pandorite | on scheme start | 6.09 | 5.69 | 6.27 | 0.91 | 0.00 | F1 |  |
| Sinuous Acolyte | on swig start | 4.62 | 2.52 | 5.35 | 0.47 | 0.00 |  |  |
| Jar Dweller | on roll | 4.61 | 3.85 | 4.97 | 0.77 | 0.00 |  |  |
| Brawny Striker | on scheme start | 4.61 | 4.33 | 5.12 | 0.85 | 0.72 |  |  |
| Sane Sorrowful | on commit | 4.46 | 2.41 | 5.14 | 0.47 | 0.00 |  |  |
| Bird-Fouled Hagia | on scheme start | 4.25 | 4.38 | 4.19 | 1.05 | 0.15 |  |  |
| Dubious Demonologist | on roll | 4.10 | 5.19 | 3.08 | 1.69 | 0.00 | A5.2 |  |
| Lithiated Assayer | activated: take | 3.64 | 3.60 | 3.66 | 0.98 | 0.00 | F1.2 |  |
| Venomous Vessel | on roll | 3.32 | 5.01 | 2.73 | 1.83 | 0.00 | E0.7 |  |
| Knower of True Names | on score set | 2.96 | 2.75 | 3.04 | 0.91 | 0.00 |  |  |
| Covert Degenerate | on scheme start | 2.84 | 2.01 | 3.13 | 0.64 | 0.00 |  |  |
| Shrewd Quaker | on scheme start | 2.64 | 1.96 | 2.89 | 0.68 | 0.00 |  |  |
| Orgasmic Musician | on scheme start | 2.62 | 1.47 | 3.01 | 0.49 | 0.00 |  |  |
| Grain Hoarder | on scheme start | 2.60 | 1.55 | 3.09 | 0.50 | 0.00 |  |  |
| Mercurial Monomaniac | on incinerate | 2.56 | 3.03 | 2.37 | 1.27 | 0.00 |  |  |
| Orgasmic Musician | on score set | 2.56 | 1.18 | 3.03 | 0.39 | 0.00 |  |  |

## Quiet lines (fewer than 0.2 activations per game held)

107 of 228 ability lines on cards held at least 30 times. Never fired: **13**.

| Card face | Line | Activations | Per game held | Card held |
|---|---|---:|---:|---:|
| Sun-Blinded Prismist | on scored | 0 | 0.000 | 467 |
| Mummy Grinder | instead of lose tooth | 0 | 0.000 | 349 |
| Intrepid Archaeologist | instead of lose tooth | 0 | 0.000 | 349 |
| Passive Puffer | on commit | 0 | 0.000 | 451 |
| Haphazard Herbalist | on score set | 0 | 0.000 | 306 |
| The Tallyman | on incinerate | 0 | 0.000 | 271 |
| Covert Degenerate | activated: rotate | 0 | 0.000 | 335 |
| Esteemed Burgher | on leave | 0 | 0.000 | 335 |
| God-Struck Fool | on scored | 0 | 0.000 | 444 |
| Promising Pugilist | on scheme start | 0 | 0.000 | 289 |
| Tumorous Magi | activated: die | 0 | 0.000 | 253 |
| Silent Companion | on scheme start | 0 | 0.000 | 302 |
| Noble Ghostwriter | activated: nudge | 0 | 0.000 | 465 |
| Sulfurous Sage | on score set | 1 | 0.002 | 457 |
| Nubile Nymph | on pre score | 1 | 0.003 | 340 |
| Viscera Monger | on incinerate | 1 | 0.003 | 311 |
| Dubious Demonologist | on commit | 1 | 0.003 | 296 |
| Dubious Demonologist | on tooth lost | 1 | 0.003 | 296 |
| Marooned Wanderer | on incinerate | 1 | 0.004 | 269 |
| Solifactory Smith | on score set | 2 | 0.004 | 502 |
| Epicurean Gourmand | on score set | 2 | 0.004 | 472 |
| Bodysnatcher | activated: snatch | 2 | 0.004 | 470 |
| Primed Pomologist | on scry start | 2 | 0.004 | 463 |
| Lead Drinker | on commit | 2 | 0.004 | 455 |
| Finger-Bone Forager | activated: quint | 2 | 0.005 | 391 |
| Tongueless Traitor | activated: rotate | 2 | 0.006 | 362 |
| Bloodstained Recluse | on score set | 2 | 0.006 | 342 |
| Glass-Eyed Alchemist | on score nothing | 3 | 0.006 | 467 |
| Shrewd Quaker | on score set | 2 | 0.006 | 308 |
| Bruised Boxer | instead of lose tooth | 2 | 0.007 | 289 |
| Shuar Headshrinker | when anyone scheme start | 3 | 0.007 | 410 |
| Pact Proctor | activated: resurrect | 3 | 0.007 | 406 |
| Carrier of the Droplet | activated: invert | 2 | 0.008 | 261 |
| Gin-Soaked Gutter-Sweeper | activated: mimic | 4 | 0.008 | 485 |
| Lead Drinker | activated: undiscard | 4 | 0.009 | 455 |
| Sadistic Shepherd | on scheme start | 4 | 0.009 | 447 |
| Perennial Pruner | on swig start | 3 | 0.010 | 306 |
| Reeking Husk | on roll | 5 | 0.012 | 422 |
| Covert Degenerate | activated: uncommit | 4 | 0.012 | 335 |
| Shuar Headshrinker | activated: relinquish | 6 | 0.015 | 410 |
| Virgin Pure | on leave | 5 | 0.015 | 340 |
| Esteemed Burgher | instead of lose tooth | 5 | 0.015 | 335 |
| Glass-Eyed Alchemist | activated: uncommit | 7 | 0.015 | 467 |
| Persecuted Paranoiac | on token gained | 7 | 0.015 | 452 |
| Powder Monkey | activated: key | 6 | 0.016 | 367 |
| Plate-Plundering Deacon | on claim | 8 | 0.017 | 461 |
| Psychotic Christ | on score set | 8 | 0.018 | 452 |
| Vivisectionist | instead of gain keys | 5 | 0.019 | 270 |
| Doomed Pandorite | on score set | 8 | 0.019 | 426 |
| Promethean Pyro | on roll | 8 | 0.019 | 426 |
| Flayed Flagellant | activated: rotate | 9 | 0.020 | 458 |
| Fingerless Sapper | activated: undiscard | 8 | 0.022 | 367 |
| Persecuted Paranoiac | activated: purge | 12 | 0.027 | 452 |
| Reservoir of Sunshine | activated: bury | 7 | 0.029 | 243 |
| Candid Jester | on score set | 11 | 0.030 | 362 |
| Gin-Soaked Gutter-Sweeper | on token gained | 15 | 0.031 | 485 |
| Promising Pugilist | on score set | 9 | 0.031 | 289 |
| Worm-Brained Absinthard | on score nothing | 9 | 0.032 | 279 |
| Solifactory Smith | on incinerate | 21 | 0.042 | 502 |
| Expendable Assistant | on score set | 15 | 0.043 | 348 |
| Hairshirt Bearer | on pre score | 15 | 0.050 | 302 |
| Timeless Warrior-Poet | activated: uncommit | 16 | 0.050 | 318 |
| Finger-Bone Forager | activated: key | 20 | 0.051 | 391 |
| Flayed Flagellant | on roll | 24 | 0.052 | 458 |
| Iatrochemist | on commit | 15 | 0.052 | 286 |
| Fairy-Chaser | activated: drink | 15 | 0.054 | 279 |
| Staunch Stoker | activated: stoke | 14 | 0.056 | 251 |
| Academic Artillerist | on token gained | 24 | 0.057 | 421 |
| Stonefaced Stoic | on leave | 18 | 0.059 | 303 |
| Fire-Drake | when anyone incinerate | 27 | 0.061 | 444 |
| Wailing Confessor | on score set | 16 | 0.063 | 253 |
| Faustian Scholar | activated: slot | 18 | 0.071 | 253 |
| Closeted Apostate | on paid | 16 | 0.077 | 207 |
| Branded Protégé | activated: q | 27 | 0.078 | 348 |
| Haunted Mind | activated: relinquish | 33 | 0.085 | 389 |
| Hollow-Bellied Saint | on roll | 39 | 0.086 | 455 |
| Fleabitten Penitent | on score nothing | 26 | 0.086 | 302 |
| Venomous Vessel | on rolled | 30 | 0.088 | 340 |
| Bird-Fouled Hagia | on token gained | 43 | 0.090 | 478 |
| Paid Mourner | activated: again | 33 | 0.093 | 354 |
| Hard-Weathered Quarryman | on scheme start | 29 | 0.096 | 303 |
| Purger | on scheme start | 24 | 0.098 | 244 |
| Iatrochemist | activated: rotate | 29 | 0.101 | 286 |
| Esteemed Burgher | activated: reserve | 36 | 0.107 | 335 |
| Wrathful Sovern | when anyone tooth lost | 44 | 0.108 | 406 |
| Paid Mourner | activated: key | 39 | 0.110 | 354 |
| Fingerless Sapper | on roll | 41 | 0.112 | 367 |
| Spagyric Physician | on score set | 31 | 0.119 | 261 |
| Epileptic Metallurgist | on token gained | 40 | 0.119 | 335 |
| Noble Ghostwriter | on incinerate | 56 | 0.120 | 465 |
| Oathbreaker | instead of lose tooth | 32 | 0.121 | 264 |
| Witch Drowner | on incinerate | 59 | 0.123 | 479 |
| Self-Sacrificant | instead of face swap | 45 | 0.126 | 358 |
| Fire-Drake | on roll | 56 | 0.126 | 444 |
| Brooding Composer | when anyone token gained | 39 | 0.127 | 308 |
| Pilfered Penname | on scheme start | 63 | 0.135 | 465 |
| Branded Protégé | on discard | 48 | 0.138 | 348 |
| Esteemed Burgher | when anyone claim | 47 | 0.140 | 335 |
| Mocking Recluse | on leave | 41 | 0.143 | 287 |
| Intrepid Archaeologist | on token gained | 52 | 0.149 | 349 |
| Twofold Widow | activated: earth | 66 | 0.149 | 442 |
| Twofold Widow | on score set | 66 | 0.149 | 442 |
| Purger | instead of claim | 37 | 0.152 | 244 |
| Reliquary Larcenist | on score set | 72 | 0.184 | 391 |
| Haunted Mind | when anyone incinerate | 72 | 0.185 | 389 |
| Lash-Blessed Monk | activated: key | 88 | 0.192 | 458 |
| Doomed Romantic | on leave | 48 | 0.194 | 247 |

## Key economy by line

Lines that produced keys, by share of all keys in the run.

| Card face | Line | Keys | Share | Keys/act | Activations per game held | Winners | Others |
|---|---|---:|---:|---:|---:|---:|---:|
| Brawny Striker | on scheme start | 1657 | 19.5% | 0.72 | 4.61 | 4.33 | 5.12 |
| Overworked Gravedigger | activated: key | 523 | 6.1% | 0.86 | 1.29 | 1.46 | 1.22 |
| Tarred Prophet | when anyone key gained | 478 | 5.6% | 1.00 | 1.06 | 1.44 | 0.85 |
| Lethean Elder | on score nothing | 434 | 5.1% | 2.00 | 0.49 | 0.64 | 0.42 |
| Back-Alley Butcher | on key gained | 434 | 5.1% | 1.00 | 0.93 | 1.60 | 0.54 |
| Gout-Ridden Glutton | on scry start | 393 | 4.6% | 0.89 | 0.94 | 1.00 | 0.91 |
| Powder Miller | activated: key | 386 | 4.5% | 0.96 | 0.91 | 0.91 | 0.91 |
| Dependable Tosspot | activated: key | 358 | 4.2% | 0.93 | 0.79 | 0.81 | 0.78 |
| Pilfered Penname | on score set | 335 | 3.9% | 0.93 | 0.78 | 0.80 | 0.77 |
| Socratic Self-Slayer | activated: key | 332 | 3.9% | 0.92 | 0.79 | 0.78 | 0.79 |
| Lash-Blessed Monk | when anyone key gained | 315 | 3.7% | 0.95 | 0.72 | 0.64 | 0.76 |
| Active Assistant | on score set | 302 | 3.5% | 0.90 | 0.75 | 0.77 | 0.74 |
| Bird-Fouled Hagia | on scheme start | 301 | 3.5% | 0.15 | 4.25 | 4.38 | 4.19 |
| Sun-Blinded Prismist | on score set | 299 | 3.5% | 0.87 | 0.74 | 0.81 | 0.71 |
| Charitable Ciderist | on score set | 210 | 2.5% | 0.92 | 0.49 | 0.54 | 0.47 |
| Corrupted Inquisitor | on round end | 204 | 2.4% | 1.00 | 0.43 | 0.74 | 0.32 |
| Bacchus Host | on score set | 186 | 2.2% | 0.91 | 0.45 | 0.47 | 0.44 |
| Pot-Licking Friar | activated: key | 175 | 2.1% | 0.94 | 0.41 | 0.51 | 0.37 |
| Discarded Follower | activated: key | 171 | 2.0% | 0.85 | 0.47 | 1.22 | 0.20 |
| Hollowhead | on key gained | 155 | 1.8% | 1.00 | 0.35 | 0.63 | 0.23 |
| Craven Cannoneer | activated: key | 140 | 1.6% | 0.97 | 0.34 | 0.50 | 0.29 |
| Psychotic Christ | activated: key | 117 | 1.4% | 0.97 | 0.27 | 0.43 | 0.20 |
| Pious Parishioner | on incinerate | 116 | 1.4% | 0.94 | 0.27 | 0.39 | 0.22 |
| Burn-Scarred Glasswright | activated: key | 103 | 1.2% | 0.98 | 0.23 | 0.38 | 0.17 |
| Sadistic Shepherd | activated: key | 85 | 1.0% | 0.92 | 0.21 | 0.33 | 0.16 |
| Lash-Blessed Monk | activated: key | 83 | 1.0% | 0.94 | 0.19 | 0.29 | 0.14 |
| Self-Sacrificant | instead of face swap | 45 | 0.5% | 1.00 | 0.13 | 0.25 | 0.08 |
| Wrathful Sovern | when anyone tooth lost | 43 | 0.5% | 0.98 | 0.11 | 0.15 | 0.09 |
| Paid Mourner | activated: key | 37 | 0.4% | 0.95 | 0.11 | 0.14 | 0.10 |
| Finger-Bone Forager | activated: key | 19 | 0.2% | 0.95 | 0.05 | 0.07 | 0.04 |

## Token economy by line

**E**: produced 2885, spent through card abilities 732.
- Sources: Venomous Vessel (on roll) 780; Hopeful Sower (on score set) 592; Driveling Chemist (on scheme start) 516; Bezoar Seeker (on roll) 418; Burn-Scarred Glasswright (on score set) 217; Short-Lived Brute (activated: cash) 130
- Sinks: Discarded Follower (activated: key) 196; Burn-Scarred Glasswright (activated: key) 184; Sadistic Shepherd (activated: key) 156; Bezoar Seeker (on roll) 54; Self-Sacrificant (instead of face swap) 45; Active Assistant (activated: q) 44

**W**: produced 2862, spent through card abilities 1433.
- Sources: Dependable Tosspot (on score nothing) 1041; Driveling Chemist (on scheme start) 516; Enthralling Eulogist (on roll) 420; Pot-Licking Friar (on discard) 394; Hollow-Bellied Saint (on roll) 195; Charitable Ciderist (on token gained) 69
- Sinks: Dependable Tosspot (activated: key) 756; Pot-Licking Friar (activated: key) 338; Paid Mourner (activated: key) 192; Paid Mourner (activated: again) 64; Discarded Follower (activated: key) 49; Active Assistant (activated: q) 14

**F**: produced 6764, spent through card abilities 1552.
- Sources: Doomed Pandorite (on scheme start) 2564; Lithiated Assayer (activated: take) 1504; Powder Miller (on scry start) 780; Driveling Chemist (on scheme start) 516; Furnace Keeper (on roll) 380; Timeless Warrior-Poet (on incinerate) 296
- Sinks: Powder Miller (activated: key) 796; Craven Cannoneer (activated: key) 270; Wrathful Sovern (when anyone tooth lost) 105; Discarded Follower (activated: key) 98; Active Assistant (activated: q) 79; Branded Protégé (activated: q) 52

**A**: produced 11565, spent through card abilities 5233.
- Sources: Dubious Demonologist (on roll) 6320; Overworked Gravedigger (on swig start) 3639; Driveling Chemist (on scheme start) 516; Ayahuascite (on score nothing) 331; Reliquary Larcenist (on score set) 261; Bodysnatcher (on incinerate) 176
- Sinks: Overworked Gravedigger (activated: key) 2980; Discarded Follower (activated: key) 1057; Dubious Demonologist (activated: quint) 456; Psychotic Christ (activated: key) 220; Active Assistant (activated: q) 214; Lash-Blessed Monk (activated: key) 164

**Q**: produced 1562, spent through card abilities 83.
- Sources: Expendable Assistant (on wager lost) 570; Shunned Executioner (on scheme start) 308; Active Assistant (activated: q) 185; Expendable Assistant (on tooth lost) 169; Oathkeeper (on score set) 143; Bird-Fouled Hagia (on token gained) 95
- Sinks: Finger-Bone Forager (activated: key) 26; Active Assistant (activated: q) 19; Brawny Striker (on scheme start) 16; Staunch Stoker (activated: stoke) 11; Reservoir of Sunshine (activated: bury) 7; Plate-Plundering Deacon (on claim) 4

## Every card, every line

Per activation: keys, tokens gained, tokens spent, teeth lost by the holder, teeth taken from others, teeth regained.

### Lead Drinker / Bacchus Host (`water_01`), held 455 times, holder won 41%

**Lead Drinker**: On committing two W, you may discard a Potency die / to gain W equal to that Potency. / Spend 1W to take a discarded die, undiscard it and reroll. / If that die rolls 1: lose a tooth

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: undiscard | 4 | 0.01 | 0.00 | 0.01 | 0.00 |  | W1 | 0.25 / 0.00 / 0.00 |
| on commit | 2 | 0.00 | 0.00 | 0.01 | 0.00 | W1.5 |  | 0.00 / 0.00 / 0.00 |

**Bacchus Host** (inverted): You win all wagers. / On scoring four water: gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 205 | 0.45 | 0.47 | 0.44 | 0.91 |  |  | 0.00 / 0.00 / 0.00 |

### Noble Ghostwriter / Pilfered Penname (`water_02`), held 465 times, holder won 35%

**Noble Ghostwriter**: Whenever you incinerate a card: gain 1W / Once per round, spend W to rotate a die one face over in either direction / (this does trigger another 'on roll' to the new face)

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: nudge | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on incinerate | 56 | 0.12 | 0.19 | 0.08 | 0.00 | W1 |  | 0.00 / 0.00 / 0.00 |

**Pilfered Penname** (inverted): On Scheme start, you may look at the top card of the draw deck. / You may incinerate Pilfered Penname to take it. / On scoring a straight: gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 63 | 0.14 | 0.15 | 0.12 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 362 | 0.78 | 0.80 | 0.77 | 0.93 |  |  | 0.00 / 0.00 / 0.00 |

### Gin-Soaked Gutter-Sweeper / Dependable Tosspot (`water_03`), held 485 times, holder won 35%

**Gin-Soaked Gutter-Sweeper**: Whenever you gain W, you may gain +1W / Once per round, spend W to rotate 1 die to match another face that was rolled / (this does trigger another 'on roll' to the new face)

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: mimic | 4 | 0.01 | 0.01 | 0.01 | 0.00 |  | W1 | 0.00 / 0.00 / 0.00 |
| on token gained | 15 | 0.03 | 0.04 | 0.03 | 0.00 | W1 |  | 0.00 / 0.00 / 0.00 |

**Dependable Tosspot** (inverted): If you score nothing: gain 3W. / Spend 2W to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 383 | 0.79 | 0.81 | 0.78 | 0.93 |  | W2 | 0.00 / 0.00 / 0.00 |
| on score nothing | 347 | 0.72 | 0.70 | 0.72 | 0.00 | W3 |  | 0.00 / 0.00 / 0.00 |

### Hollow-Bellied Saint / Pot-Licking Friar (`water_04`), held 455 times, holder won 28%

**Hollow-Bellied Saint**: On rolling a W, you may discard a Potency die to gain W equal to that Potency. / On Scheme start, you may decrease a Potency by -1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 39 | 0.09 | 0.01 | 0.11 | 0.00 | W5 |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 234 | 0.51 | 0.49 | 0.53 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Pot-Licking Friar** (inverted): Whenever you discard a die, gain 1W. / Spend 2W to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 186 | 0.41 | 0.51 | 0.37 | 0.94 |  | W1.8 | 0.00 / 0.00 / 0.00 |
| on discard | 394 | 0.87 | 1.05 | 0.79 | 0.00 | W1 |  | 0.00 / 0.00 / 0.00 |

### Enthralling Eulogist / Paid Mourner (`water_05`), held 354 times, holder won 27%

**Enthralling Eulogist**: On rolling a W, you may discard a Potency die to gain W equal to that Potency. / On Scheme start, you may decrease a Potency by -1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 89 | 0.25 | 0.28 | 0.24 | 0.00 | W4.7 |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 186 | 0.53 | 0.40 | 0.57 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Paid Mourner** (inverted): Once per Scry, spend 2W to score a set again. / (Retriggers on-score, and allows you to make another villager request) / Spend 6 W to gain 1 key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: again | 33 | 0.09 | 0.09 | 0.09 | 0.00 |  | W1.9 | 0.06 / 0.00 / 0.00 |
| activated: key | 39 | 0.11 | 0.14 | 0.10 | 0.95 |  | W4.9 A0.1 | 0.05 / 0.00 / 0.00 |

### Twofold Widow / Lethean Elder (`water_06`), held 442 times, holder won 32%

**Twofold Widow**: Whenever you score a straight: bury 1E on this card / During Scheme, you may spend 1E on this card / to swap in an E for any face

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: earth | 66 | 0.15 | 0.06 | 0.19 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 66 | 0.15 | 0.06 | 0.19 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Lethean Elder** (inverted): On scoring nothing: / incinerate all your cards, including this, to gain 2 keys.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score nothing | 217 | 0.49 | 0.64 | 0.42 | 2.00 |  |  | 0.00 / 0.00 / 0.00 |

### Worm-Brained Absinthard / Fairy-Chaser (`water_07`), held 279 times, holder won 27%

**Worm-Brained Absinthard**: Whenever you score a straight: / * Bury 2 W on this card / Whenever you score a non-straight or nothing: / * Remove 1 W from this card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score nothing | 9 | 0.03 | 0.00 | 0.04 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 272 | 0.97 | 0.62 | 1.11 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Fairy-Chaser** (inverted): Gain all W buried on this card. / If W is exactly 5: gain a tooth and incinerate this card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: drink | 15 | 0.05 | 0.04 | 0.06 | 0.00 | W3.3 |  | 0.00 / 0.00 / 0.00 |

### Hairshirt Bearer / Fleabitten Penitent (`water_08`), held 302 times, holder won 27%

**Hairshirt Bearer**: When scoring, spend 1 A to: / score a straight with 1 fewer dice than normal. / E.g.: 1,2 could score as Three straight

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on pre score | 15 | 0.05 | 0.02 | 0.06 | 0.00 |  | A1 | 0.00 / 0.00 / 0.00 |

**Fleabitten Penitent** (inverted): Whenever you score a Five Straight: gain 1 key / Whenever you score anything else, or score nothing: / lose 1 tooth

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score nothing | 26 | 0.09 | 0.01 | 0.11 | 0.00 |  |  | 1.00 / 0.00 / 0.00 |
| on score set | 436 | 1.44 | 1.26 | 1.51 | 0.03 |  |  | 0.97 / 0.00 / 0.00 |

### Epicurean Gourmand / Gout-Ridden Glutton (`water_09`), held 472 times, holder won 33%

**Epicurean Gourmand**: After scoring a set with one or more W, you must: / * incinerate a card / * and gain 2Q.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 2 | 0.00 | 0.00 | 0.01 | 0.00 | Q2 |  | 0.00 / 0.00 / 0.00 |

**Gout-Ridden Glutton** (inverted): On Scry start, If you have no discarded dice, choose 1: / * gain 2W / * lose all W and E tokens, incinerate this card, and gain 1 key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scry start | 442 | 0.94 | 1.00 | 0.91 | 0.89 | W0.1 |  | 0.00 / 0.00 / 0.00 |

### Leech Catcher / Bloodless Somnambulist (`water_10`), held 268 times, holder won 29%

**Leech Catcher**: On Swig start, you may incinerate a card. If you do: / * Bury 3 F on this card / * During this Swig, you may expend buried F to undiscard dice / (or save it to expend next round)

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: leech | 102 | 0.38 | 0.16 | 0.47 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on swig start | 150 | 0.56 | 0.38 | 0.63 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Bloodless Somnambulist** (inverted): When you incinerate this, gain a W face. / During Scheme, you may swap it in.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 67 | 0.25 | 0.22 | 0.26 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Sulfurous Sage / Socratic Self-Slayer (`water_king`), held 457 times, holder won 36%

**Sulfurous Sage**: When you score All Colors, if you have 0 of any E,W,F or A: / gain 1 of each E,W,F and A

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 1 | 0.00 | 0.00 | 0.00 | 0.00 | A1 E1 F1 W1 |  | 0.00 / 0.00 / 0.00 |

**Socratic Self-Slayer** (inverted): Lose two teeth and incinerate this card / to take a key from the player with the most keys.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 359 | 0.79 | 0.78 | 0.79 | 0.92 |  |  | 1.86 / 0.00 / 0.00 |

### Orgasmic Musician / Brooding Composer (`water_prince`), held 308 times, holder won 26%

**Orgasmic Musician**: On Scheme start, you may increase a Potency by +1 / Whenever you score Two Color-Pairs or Four Pairs, / bury a W on this card. / Spend 1 buried W to uncommit a die.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: uncommit | 688 | 2.23 | 0.94 | 2.68 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 806 | 2.62 | 1.47 | 3.01 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 787 | 2.56 | 1.18 | 3.03 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Brooding Composer** (inverted): Relinquish this card, attaching it to an opponent's card. / Whenever that opponent gains an E or W, you gain one as well. / When the attached card is incinerated, this card is incinerated too.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: relinquish | 71 | 0.23 | 0.20 | 0.24 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| when anyone token gained | 39 | 0.13 | 0.15 | 0.12 | 0.00 | E0.7 W0.3 |  | 0.00 / 0.00 / 0.00 |

### Nubile Nymph / Virgin Pure (`water_princess`), held 340 times, holder won 28%

**Nubile Nymph**: Whenever you could score a Four or Five Straight, you may instead: / * Uncommit a die / * Bury 1W on this card / If you have 3W on this card: incinerate it and gain 1 key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on pre score | 1 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Virgin Pure** (inverted): When you incinerate this, gain a W face. / During Scheme, you may swap it in.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 5 | 0.01 | 0.00 | 0.02 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Broken Martyr / Tarred Prophet (`water_queen`), held 449 times, holder won 36%

**Broken Martyr**: On Scry start: lose a tooth, then, gain a tooth / On Scheme start, you may increase a Potency by +1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 344 | 0.77 | 0.71 | 0.80 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on scry start | 241 | 0.54 | 0.39 | 0.62 | 0.00 |  |  | 0.98 / 0.00 / 1.00 |

**Tarred Prophet** (inverted): Relinquish this card, attaching it to an opponent's card. / Whenever that opponent gains a key, you gain one as well. / When the attached card is incinerated, this card is incinerated too.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: relinquish | 408 | 0.91 | 0.96 | 0.88 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| when anyone key gained | 478 | 1.06 | 1.44 | 0.85 | 1.00 |  |  | 0.00 / 0.00 / 0.00 |

### Primed Pomologist / Charitable Ciderist (`earth_01`), held 463 times, holder won 27%

**Primed Pomologist**: On Scry start, look at the highest Potency among discarded dice: / gain that many E. / If it is 6+, you may instead gain 2Q.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scry start | 2 | 0.00 | 0.00 | 0.01 | 0.00 | E4 |  | 0.00 / 0.00 / 0.00 |

**Charitable Ciderist** (inverted): Any time you gain E, or W, you may gain one more / On scoring four earth: gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 228 | 0.49 | 0.54 | 0.47 | 0.92 |  |  | 0.00 / 0.00 / 0.00 |
| on token gained | 163 | 0.35 | 0.37 | 0.35 | 0.00 | E0.6 W0.4 |  | 0.00 / 0.00 / 0.00 |

### Passive Puffer / Active Assistant (`earth_02`), held 451 times, holder won 35%

**Passive Puffer**: Whenever you commit 5 or more dice at once, / you may uncommit another die. / On Scheme start, you may increase a Potency by +1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on commit | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 220 | 0.49 | 0.51 | 0.47 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Active Assistant** (inverted): You may now spend 2 of any token to get 1Q / On scoring a triplet: gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: q | 185 | 0.41 | 0.75 | 0.23 | 0.00 | Q1 | A1.2 F0.4 E0.2 Q0.1 W0.1 | 0.00 / 0.00 / 0.00 |
| on score set | 337 | 0.75 | 0.77 | 0.74 | 0.90 |  |  | 0.00 / 0.00 / 0.00 |

### Alembic Servitor / Burn-Scarred Glasswright (`earth_03`), held 455 times, holder won 30%

**Alembic Servitor**: While this is active, you get a bonus die that must remain empty, / (can't really score - but it can be committed, discarded, etc)

*Rules-only face: nothing to count.*

**Burn-Scarred Glasswright** (inverted): Whenever you have 5 dice scoring the same set: gain 1 E. / Spend 2E to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 105 | 0.23 | 0.38 | 0.17 | 0.98 |  | E1.8 | 0.06 / 0.00 / 0.00 |
| on score set | 217 | 0.48 | 0.52 | 0.46 | 0.00 | E1 |  | 0.00 / 0.00 / 0.00 |

### Bezoar Seeker / Sadistic Shepherd (`earth_04`), held 447 times, holder won 27%

**Bezoar Seeker**: On rolling an E, you may discard a Potency die to gain E equal to that Potency. / On rolling a W, F or A, you may spend 1 E / to rotate a ready die one face over in either direction.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 143 | 0.32 | 0.62 | 0.21 | 0.00 | E2.9 | E0.4 | 0.00 / 0.00 / 0.00 |

**Sadistic Shepherd** (inverted): Incinerate a card to bury 1E on this card. / On Scheme start, spend 5 buried E to gain an E face. / Spend 2E to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: feed | 350 | 0.78 | 0.66 | 0.83 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| activated: key | 92 | 0.21 | 0.33 | 0.16 | 0.92 |  | E1.7 | 0.00 / 0.00 / 0.00 |
| on scheme start | 4 | 0.01 | 0.00 | 0.01 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Reeking Husk / Discarded Follower (`earth_05`), held 422 times, holder won 27%

**Reeking Husk**: On rolling an E, you may discard that die and a Potency die, and gain E equal to the Potency / On rolling an A, you may discard that die and a Potency die, and gain A or E equal to the Potency

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 5 | 0.01 | 0.00 | 0.02 | 0.00 | E2.8 A1.6 |  | 0.00 / 0.00 / 0.00 |

**Discarded Follower** (inverted): Whenever you commit a triplet or quadruplet, / rotate and commit a ready die. / Spend 7 of any one token type to gain 1 key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 200 | 0.47 | 1.22 | 0.20 | 0.85 |  | A5.3 E1 F0.5 W0.2 | 0.00 / 0.00 / 0.00 |
| on commit | 609 | 1.44 | 1.17 | 1.54 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Shrewd Quaker / Hard-Tack Baker (`earth_06`), held 308 times, holder won 28%

**Shrewd Quaker**: On Scheme start, you may decrease a Potency by -1 / Whenever you score Two Color-Pairs or Four Pairs, / you may spend 3E to get 2F or 2A

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 812 | 2.64 | 1.96 | 2.89 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 2 | 0.01 | 0.02 | 0.00 | 0.00 | F2 | E3 | 0.00 / 0.00 / 0.00 |

**Hard-Tack Baker** (inverted): You can now score Triplets as Quadruples. / You cannot score any straights.

*Rules-only face: nothing to count.*

### Perennial Pruner / Haphazard Herbalist (`earth_07`), held 306 times, holder won 27%

**Perennial Pruner**: On Swig start, you may spend 2E to rotate and commit a ready die. / Whenever you win a wager, gain a tooth.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on swig start | 3 | 0.01 | 0.02 | 0.00 | 0.00 |  | E2 | 0.00 / 0.00 / 0.00 |
| on wager won | 105 | 0.34 | 0.29 | 0.36 | 0.00 |  |  | 0.00 / 0.00 / 1.00 |

**Haphazard Herbalist** (inverted): Whenever you score a Two Color-Pairs, Triplet, or Quadruplet, choose: / spend 8E or lose 1 key to regain 2 teeth

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Venomous Vessel / Sinuous Acolyte (`earth_08`), held 340 times, holder won 26%

**Venomous Vessel**: Whenever you roll an E, discard that die to bury 1E on this card / Whenever you roll two As, discard those dice to double the E on this card / Whenever you roll a W, discard that die to gain the E buried on this card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 1128 | 3.32 | 5.01 | 2.73 | 0.00 | E0.7 |  | 0.00 / 0.00 / 0.00 |
| on rolled | 30 | 0.09 | 0.18 | 0.06 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Sinuous Acolyte** (inverted): Whenever you roll an E, discard that die to bury 1E on this card / On Swig start, spend 1 buried E to rotate and commit a ready die.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 3560 | 10.47 | 5.59 | 12.17 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on swig start | 1571 | 4.62 | 2.52 | 5.35 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Oathbreaker / Oathkeeper (`earth_09`), held 264 times, holder won 26%

**Oathbreaker**: Whenever you would lose a tooth, instead you may: / spend 5E or incinerate this card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| instead of lose tooth | 32 | 0.12 | 0.04 | 0.15 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Oathkeeper** (inverted): Whenever you score a Triplet, or Quadruplet: gain 1Q / Whenever you score a straight: incinerate this card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 162 | 0.61 | 0.92 | 0.51 | 0.00 | Q0.9 |  | 0.00 / 0.00 / 0.00 |

### Solifactory Smith / Brawny Striker (`earth_10`), held 502 times, holder won 65%

**Solifactory Smith**: Whenever you incinerate a card: gain 1E / If you score a set of all E, or a set of all >= 4: gain 1Q

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on incinerate | 21 | 0.04 | 0.06 | 0.01 | 0.00 | E1 |  | 0.00 / 0.00 / 0.00 |
| on score set | 2 | 0.00 | 0.00 | 0.01 | 0.00 | Q1 |  | 0.00 / 0.00 / 0.00 |

**Brawny Striker** (inverted): On Scheme Start: / lose 2 teeth or spend 8E or spend 4Q or incinerate two cards / to gain 1 key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 2314 | 4.61 | 4.33 | 5.12 | 0.72 |  |  | 0.53 / 0.00 / 0.00 |

### Iatrochemist / Mercury-Blooded (`earth_king`), held 286 times, holder won 22%

**Iatrochemist**: If you commit 7 dice at once, you may bury an E on this card. / Spend 1E buried on this card to rotate a committed die to any face.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: rotate | 29 | 0.10 | 0.00 | 0.13 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on commit | 15 | 0.05 | 0.00 | 0.07 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Mercury-Blooded** (inverted): Anytime you lose a tooth: bury 4E on this card / Spend 1E buried on this card to rotate a committed die to any face.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: rotate | 609 | 2.13 | 2.45 | 2.04 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on tooth lost | 162 | 0.57 | 0.62 | 0.55 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### The Tallyman / Dreaded Abacist (`earth_prince`), held 271 times, holder won 25%

**The Tallyman**: Bury a Potency die on The Tallyman, starting on 1. / Whenever you incinerate a card, increment that die. / When the die reaches 6 - you get that die as a bonus Potency die, / as long as Tallyman remains active.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on incinerate | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Dreaded Abacist** (inverted): On Scheme start, you may increase a Potency by +1 / On Scheme start, you may decrease a Potency by -1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 512 | 1.89 | 0.77 | 2.27 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Hopeful Sower / Grain Hoarder (`earth_princess`), held 276 times, holder won 32%

**Hopeful Sower**: Whenever you score Two Color-Pairs, Triplet, or Quadruplet, choose one: / * gain 2E / * bury one of any token type on any card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 296 | 1.07 | 1.26 | 0.98 | 0.00 | E2 |  | 0.00 / 0.00 / 0.00 |

**Grain Hoarder** (inverted): On Scheme start, you may replace any crystal with an E

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 717 | 2.60 | 1.55 | 3.09 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Spagyric Physician / Arsenic Apothecary (`earth_queen`), held 261 times, holder won 30%

**Spagyric Physician**: Whenever you discard an Elemental die, bury 1 token matching its face's element on this card. / Whenever you score Triplet or Quadruplet gain this card's buried tokens.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on discard | 148 | 0.57 | 0.31 | 0.68 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 31 | 0.12 | 0.18 | 0.09 | 0.00 | E2 W0.9 A0.3 F0.2 |  | 0.00 / 0.00 / 0.00 |

**Arsenic Apothecary** (inverted): When you incinerate this, gain an E face. / During Scheme, you may swap it in.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 153 | 0.59 | 0.48 | 0.63 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Hollowhead / God-Struck Fool (`major_00`), held 444 times, holder won 29%

**Hollowhead**: When you gain a key: / if you have only 2 other active cards: gain an additional key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on key gained | 155 | 0.35 | 0.63 | 0.23 | 1.00 |  |  | 0.00 / 0.00 / 0.00 |

**God-Struck Fool** (inverted): While this is active, you get a bonus die that is all 1s. / On Scry, if you did not score any Potency dice: incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scored | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Knower of True Names / Lockpicking Archon (`major_01`), held 282 times, holder won 25%

**Knower of True Names**: Any time you score a set without F: bury a W on this card. / On Scheme start, if there is W buried: / you must swap in a W crystal, then unbury all W on this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 569 | 2.02 | 1.78 | 2.10 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 836 | 2.96 | 2.75 | 3.04 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Lockpicking Archon** (inverted): Relinquish this card, attaching it to any players card. / When the attached card is incinerated, this card is incinerated too. / That player cannot lose teeth, and cannot gain keys.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: attach | 159 | 0.56 | 0.51 | 0.58 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Mooncalf Mother / Carrier of the Droplet (`major_02`), held 261 times, holder won 32%

**Mooncalf Mother**: Once per roll, you may discard a die to rotate a die to any face.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: rotate | 2141 | 8.20 | 8.25 | 8.18 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Carrier of the Droplet** (inverted): At any time, you may spend 3W to invert a card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: invert | 2 | 0.01 | 0.00 | 0.01 | 0.00 |  | W3 | 0.00 / 0.00 / 0.00 |

### Incorruptible Judge / Hardnosed Idealist (`major_04`), held 247 times, holder won 30%

**Incorruptible Judge**: While this is active, you get a bonus die that is all E / Any time you score a set without E: / convert all of a non-E token to E / If you get 0 non-E tokens: lose a tooth

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 135 | 0.55 | 0.37 | 0.63 | 0.00 |  |  | 0.67 / 0.00 / 0.00 |

**Hardnosed Idealist** (inverted): On Scheme start, incinerate this card to: / choose a die, swap all its crystals for a single color of your choice.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 159 | 0.64 | 0.49 | 0.71 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Plate-Plundering Deacon / Pious Parishioner (`major_05`), held 461 times, holder won 26%

**Plate-Plundering Deacon**: Whenever you claim a card, you may spend 2Q to claim any other. / (this claim automatically loses against wagers)

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on claim | 8 | 0.02 | 0.03 | 0.01 | 0.00 |  | Q0.5 A0.2 | 0.25 / 0.00 / 0.00 |

**Pious Parishioner** (inverted): If you incinerate two cards in a single round: / gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on incinerate | 123 | 0.27 | 0.39 | 0.22 | 0.94 |  |  | 0.00 / 0.00 / 0.00 |

### Doomed Romantic / Kismet Syzygyst (`major_06`), held 247 times, holder won 26%

**Doomed Romantic**: When you incinerate this card: / swap tooth count with another player then lose 1 tooth

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 48 | 0.19 | 0.36 | 0.14 | 0.00 |  |  | 0.94 / 0.00 / 0.00 |

**Kismet Syzygyst** (inverted): On Scheme start: incinerate this card to: / permanently gain another elemental die, starting with only F faces

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 166 | 0.67 | 0.52 | 0.73 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Promising Pugilist / Bruised Boxer (`major_07`), held 289 times, holder won 31%

**Promising Pugilist**: Choose one of the following scoring sets: / Quadruplet (bury E), Five Straight (bury W), / Five of a Color(bury F),  Four Air (bury A) / When you score that set: / gain a key and if you have >1 tooth lose a tooth

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on claim | 289 | 1.00 | 1.00 | 1.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score set | 9 | 0.03 | 0.03 | 0.03 | 1.00 |  |  | 1.00 / 0.00 / 0.00 |

**Bruised Boxer** (inverted): Whenever you would lose a tooth, instead you may: / spend all tokens of 1 type and incinerate two other cards

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| instead of lose tooth | 2 | 0.01 | 0.00 | 0.01 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Hard-Weathered Quarryman / Stonefaced Stoic (`major_08`), held 303 times, holder won 31%

**Hard-Weathered Quarryman**: On Scheme start, you may spend 1A to swap in a 6 for any Potency

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 29 | 0.10 | 0.06 | 0.11 | 0.00 |  | A0.7 | 0.14 / 0.00 / 0.00 |

**Stonefaced Stoic** (inverted): Whenever you would lose a tooth, / bury it on this card instead. / If 3 teeth are buried here, incinerate this and lose all 3. / If this card is incinerated by another card, you get them all back.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 18 | 0.06 | 0.08 | 0.05 | 0.00 |  |  | 0.00 / 0.00 / 1.50 |
| instead of lose tooth | 65 | 0.21 | 0.21 | 0.22 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Pillar-top Hermit / Bird-Fouled Hagia (`major_09`), held 478 times, holder won 33%

**Pillar-top Hermit**: While this is active, you get a bonus die that is all 6s. / Whenever you would gain tokens, gain 1 less

*Rules-only face: nothing to count.*

**Bird-Fouled Hagia** (inverted): On Scheme Start, bury 1Q here. / Whenever you gain Q from anything else, gain all Q buried here. / If 5 or more Q are buried here, incinerate this card and gain 1 key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 2031 | 4.25 | 4.38 | 4.19 | 0.15 |  |  | 0.00 / 0.00 / 0.00 |
| on token gained | 43 | 0.09 | 0.18 | 0.04 | 0.00 | Q2.2 |  | 0.00 / 0.00 / 0.00 |

### Barefoot Pilgrim / Marooned Wanderer (`major_10`), held 269 times, holder won 27%

**Barefoot Pilgrim**: On Scheme start: incinerate this card to: / permanently gain another elemental die, starting with only W faces

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 236 | 0.88 | 0.77 | 0.92 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Marooned Wanderer** (inverted): Whenever you incinerate a card, you may: / spend 1Q to draw and claim the top card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on incinerate | 1 | 0.00 | 0.00 | 0.01 | 0.00 |  | A1 | 0.00 / 0.00 / 0.00 |

### Clamp-Turning Examiner / Confessional Magistrate (`major_11`), held 238 times, holder won 32%

**Clamp-Turning Examiner**: Relinquish this card, attaching it to an opponent's card. / When the attached card is incinerated, this card is incinerated too. / Whenever they gain a new card, you may choose to incinerate / the new card and Clamp-Turning Examiner.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: relinquish | 132 | 0.55 | 0.44 | 0.61 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| when anyone claim | 98 | 0.41 | 0.36 | 0.44 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Confessional Magistrate** (inverted): On Scheme start, you may swap any two faces on your dice.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 224 | 0.94 | 0.88 | 0.97 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Self-Sacrificant / Post-Fate Oblate (`major_12`), held 358 times, holder won 26%

**Self-Sacrificant**: Whenever you are allowed to make a swap, you may instead: / pay 3 of any one token color to gain 1 key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| instead of face swap | 45 | 0.13 | 0.25 | 0.08 | 1.00 |  | A1.3 E1 F0.7 W0.1 | 0.00 / 0.00 / 0.00 |

**Post-Fate Oblate** (inverted): You can now score Four Air with four fire faces

*Rules-only face: nothing to count.*

### Toothless Grinner / Corpse-Like Pauper (`major_13`), held 221 times, holder won 31%

**Toothless Grinner**: When a card reads "or", you may spend 2Q to substitute "and"

*Rules-only face: nothing to count.*

**Corpse-Like Pauper** (inverted): On Scheme start, you may replace a 1 with a 9 on a Potency die

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 117 | 0.53 | 0.19 | 0.68 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Binger / Purger (`major_14`), held 244 times, holder won 25%

**Binger**: You can now score straights with one gap of 1 / (E.g., 1,2,4 scores as a Three Straight)

*Rules-only face: nothing to count.*

**Purger** (inverted): On Scheme start, you may decrease a Potency by -1 / Whenever an opponent claims a card, you may: / lose a tooth and incinerate this card / to claim that card yourself instead

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 24 | 0.10 | 0.00 | 0.13 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| instead of claim | 37 | 0.15 | 0.03 | 0.19 | 0.00 |  |  | 1.00 / 0.00 / 0.00 |

### Pact Proctor / Wrathful Sovern (`major_15`), held 406 times, holder won 28%

**Pact Proctor**: Spend 2Q and lose one tooth to resurrect any incinerated card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: resurrect | 3 | 0.01 | 0.00 | 0.01 | 0.00 |  | A0.3 | 1.33 / 0.00 / 0.00 |

**Wrathful Sovern** (inverted): Whenever an opponent loses a tooth, / you may spend 3F to gain a key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| when anyone tooth lost | 44 | 0.11 | 0.15 | 0.09 | 0.98 |  | F2.4 | 0.27 / 0.00 / 0.00 |

### Faustian Scholar / Tumorous Magi (`major_16`), held 253 times, holder won 26%

**Faustian Scholar**: Spend 1 tooth to lay this card upside down: / it permanently becomes a new empty card slot

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: slot | 18 | 0.07 | 0.00 | 0.10 | 0.00 |  |  | 1.06 / 0.00 / 0.00 |

**Tumorous Magi** (inverted): Spend 1Q and lose a tooth and incinerate this card / to permanently gain another Potency die.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: die | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Silent Companion / Patient Confidant (`major_17`), held 302 times, holder won 32%

**Silent Companion**: On Scheme start: you may spend 2Q to / replace an elemental face with Q - which can be counted as any color

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Patient Confidant** (inverted): On rolling an E, you may rotate it to a W / On rolling a W, you may rotate it to an E

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 2918 | 9.66 | 7.36 | 10.75 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Sane Sorrowful / Insane Incandescent (`major_18`), held 220 times, holder won 25%

**Sane Sorrowful**: While this is active, you get a bonus die of all W / Any time you commit one or more W dice: discard 1 die

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on commit | 981 | 4.46 | 2.41 | 5.14 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Insane Incandescent** (inverted): While you have this active, you get a bonus die that starts empty. / (empty faces don't really score - but can be committed, discarded, etc) / All players now require one extra key to win.

*Rules-only face: nothing to count.*

### Reservoir of Sunshine / Beloved Homunculus (`major_19`), held 243 times, holder won 25%

**Reservoir of Sunshine**: You may discard a die and spend 1Q to bury any token on any card

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: bury | 7 | 0.03 | 0.00 | 0.04 | 0.00 |  | Q1 | 0.00 / 0.00 / 0.00 |

**Beloved Homunculus** (inverted): On Scheme start, choose one of your dice: / swap all its crystals for a single number of your choice / and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 152 | 0.63 | 0.51 | 0.67 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Wailing Confessor / Voiceless Accused (`major_20`), held 253 times, holder won 24%

**Wailing Confessor**: While this is active, you get a bonus die of all A / Any time you score a set without A: / if you have more teeth than discarded dice, lose a tooth

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 16 | 0.06 | 0.00 | 0.08 | 0.00 |  |  | 1.00 / 0.00 / 0.00 |

**Voiceless Accused** (inverted): While this is active, you get a bonus die of all E / You cannot score a set with fewer than 5 dice.

*Rules-only face: nothing to count.*

### Mocking Recluse / Jar Dweller (`major_21`), held 287 times, holder won 32%

**Mocking Recluse**: When you incinerate this, gain a face of any color. / During Scheme, you may swap it in.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 41 | 0.14 | 0.25 | 0.09 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Jar Dweller** (inverted): On rolling an F, you may rotate it to an A / On rolling an A, you may rotate it to an F

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 1324 | 4.61 | 3.85 | 4.97 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Glass-Eyed Alchemist / Sun-Blinded Prismist (`air_01`), held 467 times, holder won 28%

**Glass-Eyed Alchemist**: If you score nothing, gain A equal to your highest discarded Potency. / Spend 1A to uncommit 2 dice.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: uncommit | 7 | 0.01 | 0.00 | 0.02 | 0.00 |  | A1 | 0.00 / 0.00 / 0.00 |
| on score nothing | 3 | 0.01 | 0.00 | 0.01 | 0.00 | A6 |  | 0.00 / 0.00 / 0.00 |

**Sun-Blinded Prismist** (inverted): If all your dice are committed and show either A or 6: you win. / On scoring a set with an A: gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 344 | 0.74 | 0.81 | 0.71 | 0.87 |  |  | 0.00 / 0.00 / 0.00 |
| on scored | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Tongueless Traitor / Candid Jester (`air_02`), held 362 times, holder won 29%

**Tongueless Traitor**: Whenever you swap a crystal or Potency, gain 2A / Once per round, spend 1 W to rotate a die to any face / (this does trigger another 'on roll' to the new face)

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: rotate | 2 | 0.01 | 0.00 | 0.01 | 0.00 |  | W1 | 0.00 / 0.00 / 0.00 |
| on face swap | 74 | 0.20 | 0.10 | 0.25 | 0.00 | A2 |  | 0.00 / 0.00 / 0.00 |

**Candid Jester** (inverted): On scoring five A dice or five F dice: / force a player to lose a tooth / On scoring Four Air: you may incinerate this card to gain 1 key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 11 | 0.03 | 0.04 | 0.03 | 0.82 |  |  | 0.00 / 0.18 / 0.00 |

### Persecuted Paranoiac / Psychotic Christ (`air_03`), held 452 times, holder won 29%

**Persecuted Paranoiac**: Whenever you gain A, you may gain +1A. / Spend 1F to incinerate and redraw a villager in the Town Square.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: purge | 12 | 0.03 | 0.00 | 0.04 | 0.00 |  | F0.9 | 0.17 / 0.00 / 0.00 |
| on token gained | 7 | 0.02 | 0.02 | 0.01 | 0.00 | A1 |  | 0.00 / 0.00 / 0.00 |

**Psychotic Christ** (inverted): On scoring a set with an F: / lose a tooth to force an opponent to lose a tooth / Spend 2A to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 121 | 0.27 | 0.43 | 0.20 | 0.97 |  | A1.8 | 0.00 / 0.00 / 0.00 |
| on score set | 8 | 0.02 | 0.01 | 0.02 | 0.00 |  |  | 1.00 / 1.00 / 0.00 |

### Flayed Flagellant / Lash-Blessed Monk (`air_04`), held 458 times, holder won 36%

**Flayed Flagellant**: On rolling an A, you may discard a Potency die to gain A equal to that Potency. / Once per round, spend 1 A to rotate a die to any face.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: rotate | 9 | 0.02 | 0.03 | 0.01 | 0.00 |  | A1 | 0.00 / 0.00 / 0.00 |
| on roll | 24 | 0.05 | 0.08 | 0.04 | 0.00 | A4.9 |  | 0.00 / 0.00 / 0.00 |

**Lash-Blessed Monk** (inverted): Whenever another player gains a key, you may incinerate this card to gain a key. / Spend 2A to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 88 | 0.19 | 0.29 | 0.14 | 0.94 |  | A1.9 | 0.00 / 0.00 / 0.00 |
| when anyone key gained | 330 | 0.72 | 0.64 | 0.76 | 0.95 |  |  | 0.00 / 0.00 / 0.00 |

### Bodysnatcher / Overworked Gravedigger (`air_05`), held 470 times, holder won 28%

**Bodysnatcher**: Whenever you incinerate a card: gain 1A. / Spend 4A to claim the top card of the discard pile.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: snatch | 2 | 0.00 | 0.00 | 0.01 | 0.00 |  | A4 | 0.00 / 0.00 / 0.00 |
| on incinerate | 176 | 0.37 | 0.75 | 0.23 | 0.00 | A1 |  | 0.00 / 0.00 / 0.00 |

**Overworked Gravedigger** (inverted): At the start of a Swig, name a set and gain 1A. / You can only score that set this Swig / Scry. / Spend 5A to gain 1 key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 607 | 1.29 | 1.46 | 1.22 | 0.86 |  | A4.9 | 0.00 / 0.00 / 0.00 |
| on swig start | 3639 | 7.74 | 6.35 | 8.30 | 0.00 | A1 |  | 0.00 / 0.00 / 0.00 |

### Mummy Grinder / Intrepid Archaeologist (`air_06`), held 349 times, holder won 24%

**Mummy Grinder**: Whenever you score an 'x of a color': bury 2A on this card / On Swig start, you may spend 1 buried A / to rotate and commit a die. / On losing a tooth, if this card has 6 or more buried A: / Do not lose the tooth and Incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 160 | 0.46 | 0.28 | 0.52 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on swig start | 229 | 0.66 | 0.40 | 0.74 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| instead of lose tooth | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Intrepid Archaeologist** (inverted): When you gain W or F, convert all your A to E. / Whenever you would lose a tooth, you may instead pay 4 E

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on token gained | 52 | 0.15 | 0.04 | 0.19 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| instead of lose tooth | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Reliquary Larcenist / Finger-Bone Forager (`air_07`), held 391 times, holder won 27%

**Reliquary Larcenist**: Whenever you score Four of a Color: gain 3A / Whenever you score Five of a Color: gain 6A

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 72 | 0.18 | 0.20 | 0.18 | 0.00 | A3.6 |  | 0.00 / 0.00 / 0.00 |

**Finger-Bone Forager** (inverted): Spend 2Q to gain 1 key and incinerate this card. / During Scheming, you may spend 3A to replace a crystal face with Q / (can be counted as any crystal color)

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 20 | 0.05 | 0.07 | 0.04 | 0.95 |  | Q1.3 | 0.10 / 0.00 / 0.00 |
| activated: quint | 2 | 0.01 | 0.02 | 0.00 | 0.00 |  | A3 | 0.00 / 0.00 / 0.00 |

### Footnoted Scholar / Pedantic Pedagogue (`air_08`), held 251 times, holder won 30%

**Footnoted Scholar**: On scoring a set with F, choose one: / * You gain 1 F / * An opponent loses 3 tokens of their choice

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 115 | 0.46 | 0.55 | 0.42 | 0.00 | F1 |  | 0.00 / 0.00 / 0.00 |

**Pedantic Pedagogue** (inverted): Relinquish this card, attaching it to an opponent's card. / When they invert a card, they lose 1 tooth. / After the attached card is incinerated, this card is incinerated too.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: relinquish | 149 | 0.59 | 0.52 | 0.62 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| when anyone invert | 298 | 1.19 | 0.86 | 1.33 | 0.00 |  |  | 0.00 / 1.00 / 0.00 |

### Shuar Headshrinker / Ayahuascite (`air_09`), held 410 times, holder won 29%

**Shuar Headshrinker**: Relinquish this card, attaching it to an opponent's card. / On Scheme start, that opponent loses 1 tooth. / When the attached card is incinerated, this card is incinerated too.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: relinquish | 6 | 0.01 | 0.00 | 0.02 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| when anyone scheme start | 3 | 0.01 | 0.00 | 0.01 | 0.00 |  |  | 0.00 / 1.00 / 0.00 |

**Ayahuascite** (inverted): Every time you manually rotate a die, bury 1A on this card. / Whenever you score nothing, you must gain all A buried on this card. / If you gain 5A, incinerate this card, and gain a key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on rotate | 397 | 0.97 | 0.84 | 1.02 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on score nothing | 134 | 0.33 | 0.28 | 0.34 | 0.11 | A2.5 |  | 0.00 / 0.00 / 0.00 |

### Mercurial Monomaniac / Haunted Mind (`air_10`), held 389 times, holder won 28%

**Mercurial Monomaniac**: Whenever you incinerate a card, bury 1 F on this card. / If you have 5F on this card, incinerate it, and gain a key. / Spend 1 buried F on this card to rotate a die to any face

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: rotate | 869 | 2.23 | 2.53 | 2.12 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on incinerate | 994 | 2.56 | 3.03 | 2.37 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Haunted Mind** (inverted): Relinquish this card, attaching it to an opponent's card. / Whenever that opponent incinerates a card, / they must incinerate an additional card. / After the attached card is incinerated, this card is incinerated too.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: relinquish | 33 | 0.08 | 0.06 | 0.10 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| when anyone incinerate | 72 | 0.19 | 0.11 | 0.21 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Dubious Demonologist / Failed Exorcist (`air_king`), held 296 times, holder won 48%

**Dubious Demonologist**: On rolling an A, you may discard a Potency die to gain A equal to that Potency. / During Scheming, you may spend 3A to replace a crystal face with Q / (can be counted as any crystal color)

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: quint | 154 | 0.52 | 0.60 | 0.45 | 0.00 |  | A3 | 0.03 / 0.00 / 0.00 |
| on roll | 1214 | 4.10 | 5.19 | 3.08 | 0.00 | A5.2 |  | 0.00 / 0.00 / 0.00 |

**Failed Exorcist** (inverted): This card copies the ability of the card to the left.

*Rules-only face: nothing to count.*

### Autoerotic Anesthetist / Back-Alley Butcher (`air_prince`), held 467 times, holder won 37%

**Autoerotic Anesthetist**: When performing an italic section of any card, / you may substitute it with incinerate Autoerotic Anesthetist

*Rules-only face: nothing to count.*

**Back-Alley Butcher** (inverted): Whenever you gain a key: / * if you have tokens, you must lose them all, and gain an additional key / * if you do not, you must lose a tooth, and gain an additional key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on key gained | 434 | 0.93 | 1.60 | 0.54 | 1.00 |  |  | 0.56 / 0.00 / 0.00 |

### Driveling Chemist / Feverish Scribe (`air_princess`), held 276 times, holder won 32%

**Driveling Chemist**: On scheme start, if you have the fewest keys, gain an E, W, F and A

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 516 | 1.87 | 1.25 | 2.16 | 0.00 | A1 E1 F1 W1 |  | 0.00 / 0.00 / 0.00 |

**Feverish Scribe** (inverted): Discard two dice to bury 1A on this card. / If >7A buried, 'X keys' enlightenment threshold to end the game / becomes equal to the A on this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: scribble | 56 | 0.20 | 0.00 | 0.30 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Placenta Purloiner / Viscera Monger (`air_queen`), held 311 times, holder won 29%

**Placenta Purloiner**: Whenever another player loses a tooth, bury 1Q here. / On Scheme start, spend 2 buried Q to regain a tooth.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| when anyone tooth lost | 603 | 1.94 | 1.22 | 2.24 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 106 | 0.34 | 0.22 | 0.39 | 0.00 |  |  | 0.00 / 0.00 / 1.00 |

**Viscera Monger** (inverted): Whenever you incinerate a card, / you may spend 4E to get 4A

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on incinerate | 1 | 0.00 | 0.00 | 0.00 | 0.00 | A4 |  | 2.00 / 0.00 / 0.00 |

### Promethean Pyro / Doomed Pandorite (`fire_01`), held 426 times, holder won 30%

**Promethean Pyro**: On rolling an A: / * If you have 1 empty card slot, gain W / * If you have 2 empty card slots, gain W and E / * If you have 3 empty card slots, gain W, E and F

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 8 | 0.02 | 0.00 | 0.03 | 0.00 | W1 E0.6 |  | 0.00 / 0.00 / 0.00 |

**Doomed Pandorite** (inverted): On Scheme start: incinerate the top card of the village deck and gain 1F. / On scoring four fire: gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 2596 | 6.09 | 5.69 | 6.27 | 0.00 | F1 |  | 0.00 / 0.00 / 0.00 |
| on score set | 8 | 0.02 | 0.02 | 0.02 | 1.00 |  |  | 0.00 / 0.00 / 0.00 |

### Branded Protégé / Expendable Assistant (`fire_02`), held 348 times, holder won 38%

**Branded Protégé**: Whenever you discard a die, gain 1F. / You may now spend 2F to get 1Q.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: q | 27 | 0.08 | 0.00 | 0.12 | 0.00 | Q1 | F1.9 | 0.00 / 0.00 / 0.00 |
| on discard | 48 | 0.14 | 0.00 | 0.22 | 0.00 | F1 |  | 0.00 / 0.00 / 0.00 |

**Expendable Assistant** (inverted): When you lose a tooth, or lose a wager: gain 1Q. / On scoring four fire: gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 15 | 0.04 | 0.05 | 0.04 | 0.93 |  |  | 0.00 / 0.00 / 0.00 |
| on tooth lost | 169 | 0.49 | 0.66 | 0.38 | 0.00 | Q1 |  | 0.00 / 0.00 / 0.00 |
| on wager lost | 570 | 1.64 | 1.49 | 1.73 | 0.00 | Q1 |  | 0.00 / 0.00 / 0.00 |

### Academic Artillerist / Craven Cannoneer (`fire_03`), held 421 times, holder won 28%

**Academic Artillerist**: Any time you gain F, you may gain +1F. / When scoring, you always choose before other players.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on token gained | 24 | 0.06 | 0.06 | 0.06 | 0.00 | F1 |  | 0.00 / 0.00 / 0.00 |

**Craven Cannoneer** (inverted): Opponents cannot make you lose teeth. / Spend 2F to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 145 | 0.34 | 0.50 | 0.29 | 0.97 |  | F1.9 | 0.00 / 0.00 / 0.00 |

### Fire-Drake / Powder Miller (`fire_04`), held 444 times, holder won 41%

**Fire-Drake**: On rolling an F, you may discard a Potency die to gain F equal to that Potency. / Whenever a player incinerates a card, you may spend 2F to claim that card instead

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| when anyone incinerate | 27 | 0.06 | 0.07 | 0.05 | 0.00 |  | F1.9 | 0.07 / 0.00 / 0.00 |
| on roll | 56 | 0.13 | 0.17 | 0.09 | 0.00 | F5.1 |  | 0.00 / 0.00 / 0.00 |

**Powder Miller** (inverted): On Scry start: gain 1F. / Spend 2F to gain 1 key and incinerate this card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: key | 403 | 0.91 | 0.91 | 0.91 | 0.96 |  | F2 | 0.00 / 0.00 / 0.00 |
| on scry start | 780 | 1.76 | 1.73 | 1.78 | 0.00 | F1 |  | 0.00 / 0.00 / 0.00 |

### Fingerless Sapper / Powder Monkey (`fire_05`), held 367 times, holder won 32%

**Fingerless Sapper**: On rolling an F, you may discard a Potency die to gain F equal to that Potency. / Once per round, you may spend 2F to undiscard all discarded dice

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: undiscard | 8 | 0.02 | 0.03 | 0.02 | 0.00 |  | F1.8 | 0.00 / 0.00 / 0.00 |
| on roll | 41 | 0.11 | 0.14 | 0.10 | 0.00 | F4.8 |  | 0.00 / 0.00 / 0.00 |

**Powder Monkey** (inverted): Incinerate this card to force all opponents to lose a tooth. / Spend 5F to gain 1 key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: blast | 318 | 0.87 | 0.72 | 0.94 | 0.00 |  |  | 0.00 / 2.59 / 0.00 |
| activated: key | 6 | 0.02 | 0.03 | 0.01 | 1.00 |  | F5 | 0.00 / 0.00 / 0.00 |

### Short-Lived Brute / Timeless Warrior-Poet (`fire_06`), held 318 times, holder won 27%

**Short-Lived Brute**: On rolling a W, you may bury a W on this card. / On rolling a F, you may bury a F on this card. / Incinerate this card: Gain E equal to whichever is lower: this card's W or F. / ('None' is indeed 'lower')

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: cash | 103 | 0.32 | 0.25 | 0.35 | 0.00 | E1.3 |  | 0.00 / 0.00 / 0.00 |
| on roll | 493 | 1.55 | 1.23 | 1.67 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Timeless Warrior-Poet** (inverted): Whenever you incinerate a card: gain 1F / Spend 1F to uncommit a die

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: uncommit | 16 | 0.05 | 0.00 | 0.07 | 0.00 |  | F0.7 A0.2 | 0.12 / 0.00 / 0.00 |
| on incinerate | 296 | 0.93 | 0.92 | 0.93 | 0.00 | F1 |  | 0.00 / 0.00 / 0.00 |

### Witch Drowner / Corrupted Inquisitor (`fire_07`), held 479 times, holder won 26%

**Witch Drowner**: Whenever you incinerate a card: gain 1Q / On Scheme start, you may decrease a Potency by -1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on incinerate | 59 | 0.12 | 0.23 | 0.09 | 0.00 | Q1 |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 242 | 0.51 | 0.54 | 0.49 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Corrupted Inquisitor** (inverted): At the end of a round, if you incinerated 2 or more cards: / * gain 1 key

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on round end | 204 | 0.43 | 0.74 | 0.32 | 1.00 |  |  | 0.00 / 0.00 / 0.00 |

### Furnace Keeper / Staunch Stoker (`fire_08`), held 251 times, holder won 26%

**Furnace Keeper**: On rolling an F, you may incinerate a card to gain 2 F / On Scheme start, you may increase a Potency by +1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on roll | 191 | 0.76 | 0.54 | 0.84 | 0.00 | F2 |  | 0.02 / 0.00 / 0.00 |
| on scheme start | 558 | 2.22 | 1.68 | 2.41 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Staunch Stoker** (inverted): Spend 1Q to resurrect and gain the most recently incinerated card.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: stoke | 14 | 0.06 | 0.02 | 0.07 | 0.00 |  | Q0.8 | 0.43 / 0.00 / 0.00 |

### Shunned Executioner / Bloodstained Recluse (`fire_09`), held 342 times, holder won 28%

**Shunned Executioner**: On Scheme start: incinerate a card and gain 1Q

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 312 | 0.91 | 0.75 | 0.98 | 0.00 | Q1 |  | 0.00 / 0.00 / 0.00 |

**Bloodstained Recluse** (inverted): On scoring Four of Fire: / incinerate all your cards, including this, to gain 2 keys.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on score set | 2 | 0.01 | 0.00 | 0.01 | 2.00 |  |  | 0.00 / 0.00 / 0.00 |

### Covert Degenerate / Esteemed Burgher (`fire_10`), held 335 times, holder won 26%

**Covert Degenerate**: Spend 1F to: Uncommit a die / Spend 2E to: Rotate a die to any face, once per round / On Scheme start, you may increase a Potency by +1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: rotate | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| activated: uncommit | 4 | 0.01 | 0.04 | 0.00 | 0.00 |  | F1 | 0.00 / 0.00 / 0.00 |
| on scheme start | 951 | 2.84 | 2.01 | 3.13 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Esteemed Burgher** (inverted): Place 1 tooth upon a Town Square slot. / When players request this slot, they must pay you 2 of any token. / The next time you lose a tooth, lose this reserving tooth.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: reserve | 36 | 0.11 | 0.11 | 0.11 | 0.00 |  |  | 0.97 / 0.00 / 0.00 |
| when anyone claim | 47 | 0.14 | 0.22 | 0.11 | 0.00 |  | A0.1 | 0.00 / 0.00 / 0.00 |
| on leave | 0 | 0.00 | 0.00 | 0.00 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| instead of lose tooth | 5 | 0.01 | 0.03 | 0.01 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Unshakable Empiricist / Vivisectionist (`fire_king`), held 270 times, holder won 35%

**Unshakable Empiricist**: Relinquish this card, attaching it to an opponent's card. / Whenever that opponent gains a key, they gain a tooth instead. / When the attached card is incinerated, this card is incinerated too.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: relinquish | 227 | 0.84 | 0.71 | 0.91 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| instead of gain keys | 647 | 2.40 | 2.35 | 2.42 | 0.00 |  |  | 0.00 / 0.00 / 0.54 |

**Vivisectionist** (inverted): Whenever you gain a key, you must instead choose one of your dice to roll: / 1-2 = you get 0 keys / 3-5 = you get 1 key / 6+ = you get 2 keys

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| instead of gain keys | 5 | 0.02 | 0.01 | 0.03 | 0.40 |  |  | 0.00 / 0.00 / 0.00 |

### Strawman / Burnt Effigy (`fire_prince`), held 256 times, holder won 23%

**Strawman**: While this is active, replace all italicized sections on your cards with: / spend 1A - if you cannot, lose two teeth

*Rules-only face: nothing to count.*

**Burnt Effigy** (inverted): When you incinerate this, gain a F face. / During Scheme, you may swap it in.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 203 | 0.79 | 0.86 | 0.77 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Closeted Apostate / Flaming Heretic (`fire_princess`), held 207 times, holder won 28%

**Closeted Apostate**: Whenever you perform an italicized section of a card, gain 1F / On Scheme start, you may decrease a Potency by -1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on paid | 16 | 0.08 | 0.03 | 0.09 | 0.00 | F1 |  | 0.00 / 0.00 / 0.00 |
| on scheme start | 153 | 0.74 | 0.41 | 0.87 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

**Flaming Heretic** (inverted): When you incinerate this, gain a F face. / During Scheme, you may swap it in.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on leave | 139 | 0.67 | 0.68 | 0.67 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |

### Epileptic Metallurgist / Lithiated Assayer (`fire_queen`), held 335 times, holder won 35%

**Epileptic Metallurgist**: Any time you gain A, or F, you may gain one more / On Scheme start, you may decrease a Potency by -1

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| on scheme start | 166 | 0.50 | 0.39 | 0.55 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on token gained | 40 | 0.12 | 0.07 | 0.15 | 0.00 | F0.8 A0.2 |  | 0.00 / 0.00 / 0.00 |

**Lithiated Assayer** (inverted): Whenever you: / incinerate a card OR discard a die OR lose a tooth / bury an F on this card. / Whenever you like, you can gain F off of this card. / If you have 10F on this card, incinerate it, and gain 1 key.

| Line | Activations | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act | Teeth (own / others / regained) per act |
|---|---:|---:|---:|---:|---:|---|---|---|
| activated: take | 1218 | 3.64 | 3.60 | 3.66 | 0.00 | F1.2 |  | 0.00 / 0.00 / 0.00 |
| on discard | 662 | 1.98 | 1.88 | 2.03 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on incinerate | 734 | 2.19 | 2.03 | 2.28 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |
| on tooth lost | 205 | 0.61 | 0.66 | 0.59 | 0.00 |  |  | 0.00 / 0.00 / 0.00 |


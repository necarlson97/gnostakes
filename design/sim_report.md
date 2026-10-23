# Gnostakes simulation report

*Overwritten after every finished league run; this file always holds the most recent results.*

| | |
|---|---|
| Run | `20261023-093118` (game/sim/results/20261023-093118) |
| Games | 1300 (4 players each) |
| Bots | all |
| Rule overrides | win_keys=7, start_teeth=7, max_teeth=7 |
| Card data | design/source_snapshot, synced 2026-10-22 23:29 |
| Learned card power | 2026-10-23 09:31 |
| Written | 2026-10-23 09:43 |

## Headlines

- **Game length:** 15.3 rounds on average (half of games end by round 15, 90% by round 23).
- **How games end:** edification 58%, conflagration 37%, putrescence 4%.
- **Deaths:** 1.2% of players finish with no teeth; 0.0% of games have no living winner.
- **Winning score:** the winner holds 7 keys at the median (p10 4, p90 8).
- **Strongest bots:** adaptive 1.45x, burner 1.43x, fire 1.42x.
- **Weakest bots:** tooth_miser 0.76x, sculptor 0.75x, open_slots 0.67x.
- **Best key cards (keys per claim):** Solifactory Smith / Brawny Striker 3.27, Twofold Widow / Lethean Elder 1.00, Bodysnatcher / Overworked Gravedigger 0.95. Average card: 0.30.
- **Tokens:** the median player gains 5 tokens a game (90th percentile 23); 22% of players gain none.
- **Most tooth loss to its holder (per claim):** Solifactory Smith / Brawny Striker 2.45, Sulfurous Sage / Socratic Self-Slayer 1.41, Hairshirt Bearer / Fleabitten Penitent 1.41.

## Bots

"vs even" is win share divided by an even share at the table (1.00x = average). The 95% interval is on the win rate; differences smaller than it are noise.

| Bot | Seats | Win % | ±95% | vs even | Keys/game | Teeth left | Dead % |
|---|---:|---:|---:|---:|---:|---:|---:|
| adaptive | 171 | 36.2% | 7.2% | 1.45x | 3.67 | 5.4 | 0.6% |
| burner | 190 | 35.7% | 6.8% | 1.43x | 3.65 | 5.5 | 0.5% |
| fire | 177 | 35.6% | 7.1% | 1.42x | 4.02 | 5.4 | 0.6% |
| air | 189 | 35.0% | 6.8% | 1.40x | 3.78 | 5.9 | 0.0% |
| discarder | 176 | 31.6% | 6.9% | 1.27x | 3.60 | 5.6 | 0.0% |
| fire_air | 168 | 31.4% | 7.0% | 1.26x | 3.73 | 5.8 | 0.6% |
| earth_fire | 203 | 30.5% | 6.3% | 1.22x | 3.38 | 5.5 | 1.5% |
| nihilist | 179 | 30.4% | 6.7% | 1.21x | 3.53 | 6.0 | 0.0% |
| kinds | 163 | 28.4% | 6.9% | 1.14x | 3.27 | 5.7 | 0.0% |
| water_air | 183 | 28.2% | 6.5% | 1.13x | 3.22 | 5.8 | 0.0% |
| quintessence | 196 | 27.6% | 6.3% | 1.11x | 3.26 | 6.0 | 1.0% |
| pairs | 186 | 25.5% | 6.3% | 1.02x | 3.02 | 5.9 | 1.6% |
| water_fire | 180 | 25.5% | 6.4% | 1.02x | 3.49 | 5.3 | 0.6% |
| economist | 168 | 25.2% | 6.6% | 1.01x | 3.17 | 5.9 | 1.8% |
| saboteur | 181 | 23.5% | 6.2% | 0.94x | 3.05 | 5.8 | 0.0% |
| attrition | 161 | 23.1% | 6.5% | 0.92x | 3.06 | 4.5 | 6.8% |
| earth_water | 172 | 23.1% | 6.3% | 0.92x | 3.08 | 5.5 | 0.0% |
| earth_air | 166 | 23.0% | 6.4% | 0.92x | 2.90 | 5.7 | 1.2% |
| high_roller | 180 | 23.0% | 6.1% | 0.92x | 3.13 | 5.7 | 1.1% |
| balanced | 146 | 22.5% | 6.8% | 0.90x | 2.83 | 5.9 | 1.4% |
| straights | 172 | 22.4% | 6.2% | 0.90x | 2.81 | 5.6 | 0.6% |
| colors | 180 | 21.2% | 6.0% | 0.85x | 3.19 | 5.5 | 0.0% |
| water | 190 | 21.0% | 5.8% | 0.84x | 2.93 | 5.7 | 0.5% |
| earth | 175 | 19.4% | 5.9% | 0.78x | 2.83 | 5.2 | 0.6% |
| key_rusher | 196 | 19.2% | 5.5% | 0.77x | 2.93 | 5.1 | 6.6% |
| tooth_miser | 211 | 18.9% | 5.3% | 0.76x | 2.61 | 6.6 | 0.5% |
| sculptor | 188 | 18.8% | 5.6% | 0.75x | 2.58 | 5.7 | 0.0% |
| open_slots | 174 | 16.9% | 5.6% | 0.67x | 2.38 | 5.7 | 0.6% |
| random | 179 | 2.4% | 2.3% | 0.10x | 0.71 | 4.9 | 7.8% |

**adaptive** ends committed to: key_rusher 82, earth_air 17, economist 14, earth_fire 13, fire_air 9, water_air 7, burner 6, air 5.

## Game length and endings

| Rounds | min | p10 | p50 | mean | p90 | max |
|---|---:|---:|---:|---:|---:|---:|
| | 3 | 8 | 15 | 15.3 | 23 | 33 |

| Ending | Games | Share |
|---|---:|---:|
| edification | 760 | 58.5% |
| conflagration | 482 | 37.1% |
| putrescence | 58 | 4.5% |

## Tokens

Per player. "Per game" percentiles are over player-games; peaks are the most held at one time.

| Token | Per round | Per game p50 | p90 | mean | Spent/game | None gained | Peak p50 | Peak p90 | Peak max |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| E | 0.07 | 0 | 2 | 1.1 | 0.9 | 80% | 0 | 2 | 39 |
| W | 0.07 | 0 | 3 | 1.1 | 0.8 | 74% | 0 | 3 | 54 |
| F | 0.19 | 0 | 10 | 2.9 | 2.0 | 55% | 0 | 6 | 75 |
| A | 0.21 | 0 | 13 | 3.3 | 2.6 | 68% | 0 | 5 | 53 |
| Q | 0.04 | 0 | 2 | 0.6 | 0.3 | 76% | 0 | 1 | 12 |
| all | 0.58 | 5 | 23 | 8.9 |  | 22% | 3 | 11 | 92 |

### Top 5 producers per token

Share of all income of that token, total produced in this run, and per claim of the card.

- **E** (8 cards give at least 1%): Venomous Vessel 32% (1824, 3.0/claim); Hopeful Sower 27% (1574, 2.8/claim); Driveling Chemist 20% (1151, 1.8/claim); Burn-Scarred Glasswright 10% (556, 0.6/claim); Reeking Husk 4% (204, 0.2/claim)
- **W** (8 cards give at least 1%): Dependable Tosspot 45% (2499, 2.6/claim); Driveling Chemist 21% (1151, 1.8/claim); Pot-Licking Friar 16% (858, 0.9/claim); Gout-Ridden Glutton 6% (322, 0.3/claim); Charitable Ciderist 3% (150, 0.2/claim)
- **F** (7 cards give at least 1%): Doomed Pandorite 33% (4908, 5.9/claim); Lithiated Assayer 20% (3030, 4.2/claim); Furnace Keeper 16% (2337, 4.6/claim); Powder Miller 14% (2086, 2.2/claim); Driveling Chemist 8% (1151, 1.8/claim)
- **A** (5 cards give at least 1%): Overworked Gravedigger 51% (8729, 9.3/claim); Dubious Demonologist 34% (5756, 9.5/claim); Driveling Chemist 7% (1151, 1.8/claim); Ayahuascite 5% (802, 1.0/claim); Tongueless Traitor 2% (263, 0.4/claim)
- **Q** (7 cards give at least 1%): Expendable Assistant 52% (1646, 2.2/claim); Shunned Executioner 20% (636, 0.9/claim); Oathkeeper 8% (266, 0.5/claim); Bird-Fouled Hagia 7% (217, 0.2/claim); Active Assistant 7% (209, 0.2/claim)

## Cards

Per claim of the card (either face). Teeth lost (holder) = teeth the card's own effects cost its holder; (others) = teeth it took from opponents. Win/dead % are for players who held the card at some point (baseline win share per seat: 25.0%).

| Card (upright / inverted) | Claims | Keys/claim | Teeth lost (holder) | Teeth taken (others) | Teeth regained | Tokens/claim | Main tokens | Holder win % | Holder dead % |
|---|---:|---:|---:|---:|---:|---:|---|---:|---:|
| Solifactory Smith / Brawny Striker | 1033 | 3.27 | 2.45 | 0.00 | 0.00 | 0.0 | E0.0 Q0.0 | 62% | 2% |
| Twofold Widow / Lethean Elder | 912 | 1.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 30% | 1% |
| Bodysnatcher / Overworked Gravedigger | 935 | 0.95 | 0.01 | 0.00 | 0.00 | 9.4 | A9.4 | 22% | 1% |
| Broken Martyr / Tarred Prophet | 947 | 0.91 | 0.89 | 0.00 | 0.92 | 0.0 |  | 34% | 1% |
| Flayed Flagellant / Lash-Blessed Monk | 947 | 0.84 | 0.00 | 0.00 | 0.00 | 0.0 |  | 36% | 0% |
| Epicurean Gourmand / Gout-Ridden Glutton | 958 | 0.84 | 0.00 | 0.00 | 0.00 | 0.4 | W0.3 Q0.0 | 38% | 1% |
| Fire-Drake / Powder Miller | 951 | 0.83 | 0.00 | 0.00 | 0.00 | 2.2 | F2.2 | 35% | 1% |
| Autoerotic Anesthetist / Back-Alley Butcher | 954 | 0.82 | 0.51 | 0.00 | 0.00 | 0.0 |  | 33% | 1% |
| Gin-Soaked Gutter-Sweeper / Dependable Tosspot | 948 | 0.76 | 0.00 | 0.00 | 0.00 | 2.7 | W2.7 | 35% | 1% |
| Sulfurous Sage / Socratic Self-Slayer | 911 | 0.72 | 1.41 | 0.00 | 0.00 | 0.0 |  | 38% | 1% |
| Passive Puffer / Active Assistant | 941 | 0.69 | 0.00 | 0.00 | 0.00 | 0.2 | Q0.2 | 36% | 1% |
| Noble Ghostwriter / Pilfered Penname | 957 | 0.68 | 0.00 | 0.00 | 0.00 | 0.1 | W0.1 | 35% | 1% |
| Glass-Eyed Alchemist / Sun-Blinded Prismist | 981 | 0.68 | 0.00 | 0.00 | 0.00 | 0.0 | A0.0 | 32% | 1% |
| Pillar-top Hermit / Bird-Fouled Hagia | 923 | 0.62 | 0.00 | 0.00 | 0.00 | 0.2 | Q0.2 | 35% | 1% |
| Witch Drowner / Corrupted Inquisitor | 966 | 0.46 | 0.00 | 0.00 | 0.00 | 0.1 | Q0.1 | 27% | 2% |
| Primed Pomologist / Charitable Ciderist | 962 | 0.43 | 0.00 | 0.00 | 0.00 | 0.4 | E0.2 W0.2 Q0.0 | 30% | 1% |
| Lead Drinker / Bacchus Host | 949 | 0.41 | 0.01 | 0.00 | 0.00 | 0.0 | W0.0 | 40% | 1% |
| Hollowhead / God-Struck Fool | 950 | 0.41 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Hollow-Bellied Saint / Pot-Licking Friar | 928 | 0.36 | 0.00 | 0.00 | 0.00 | 1.0 | W1.0 | 28% | 1% |
| Academic Artillerist / Craven Cannoneer | 920 | 0.30 | 0.00 | 0.00 | 0.00 | 0.1 | F0.1 | 28% | 1% |
| Alembic Servitor / Burn-Scarred Glasswright | 892 | 0.30 | 0.00 | 0.00 | 0.00 | 0.6 | E0.6 | 30% | 1% |
| Persecuted Paranoiac / Psychotic Christ | 894 | 0.26 | 0.02 | 0.01 | 0.00 | 0.0 | A0.0 | 26% | 1% |
| Plate-Plundering Deacon / Pious Parishioner | 879 | 0.24 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Reeking Husk / Discarded Follower | 893 | 0.17 | 0.00 | 0.00 | 0.00 | 0.3 | E0.2 A0.0 | 27% | 1% |
| Bezoar Seeker / Sadistic Shepherd | 885 | 0.17 | 0.01 | 0.00 | 0.00 | 0.1 | E0.1 | 28% | 1% |
| Pact Proctor / Wrathful Sovern | 814 | 0.08 | 0.01 | 0.00 | 0.00 | 0.0 |  | 30% | 1% |
| Reliquary Larcenist / Finger-Bone Forager | 806 | 0.07 | 0.00 | 0.00 | 0.00 | 0.0 | A0.0 | 28% | 1% |
| Self-Sacrificant / Post-Fate Oblate | 737 | 0.07 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Hairshirt Bearer / Fleabitten Penitent | 557 | 0.05 | 1.41 | 0.00 | 0.00 | 0.0 |  | 29% | 4% |
| Shuar Headshrinker / Ayahuascite | 788 | 0.05 | 0.00 | 0.07 | 0.00 | 1.0 | A1.0 | 30% | 0% |
| Shunned Executioner / Bloodstained Recluse | 710 | 0.05 | 0.00 | 0.00 | 0.00 | 0.9 | Q0.9 | 36% | 1% |
| Promising Pugilist / Bruised Boxer | 633 | 0.04 | 0.04 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Enthralling Eulogist / Paid Mourner | 731 | 0.04 | 0.00 | 0.00 | 0.00 | 0.2 | W0.2 | 29% | 1% |
| Branded Protégé / Expendable Assistant | 753 | 0.03 | 0.00 | 0.00 | 0.00 | 2.4 | Q2.3 F0.1 | 35% | 1% |
| Promethean Pyro / Doomed Pandorite | 834 | 0.03 | 0.00 | 0.00 | 0.00 | 5.9 | F5.9 W0.0 E0.0 | 33% | 1% |
| Tongueless Traitor / Candid Jester | 728 | 0.02 | 0.01 | 0.00 | 0.00 | 0.4 | A0.4 | 29% | 2% |
| Fingerless Sapper / Powder Monkey | 717 | 0.02 | 0.01 | 2.37 | 0.00 | 0.0 | F0.0 | 34% | 1% |
| Unshakable Empiricist / Vivisectionist | 555 | 0.01 | 0.00 | 0.00 | 1.04 | 0.0 |  | 32% | 2% |
| Dubious Demonologist / Failed Exorcist | 605 | 0.00 | 0.00 | 0.00 | 0.00 | 9.5 | A9.5 F0.0 E0.0 | 35% | 1% |
| Knower of True Names / Lockpicking Archon | 549 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Mooncalf Mother / Carrier of the Droplet | 590 | 0.00 | 0.01 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Gargoyle Mother / Famed Freemason | 464 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 32% | 1% |
| Incorruptible Judge / Hardnosed Idealist | 520 | 0.00 | 0.56 | 0.00 | 0.00 | 0.0 |  | 29% | 2% |
| Doomed Romantic / Kismet Syzygyst | 437 | 0.00 | 0.16 | 0.00 | 0.00 | 0.0 |  | 33% | 1% |
| Hard-Weathered Quarryman / Stonefaced Stoic | 632 | 0.00 | 0.03 | 0.00 | 0.10 | 0.0 |  | 26% | 2% |
| Barefoot Pilgrim / Marooned Wanderer | 554 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 34% | 3% |
| Clamp-Turning Examiner / Confessional Magistrate | 493 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 2% |
| Toothless Grinner / Corpse-Like Pauper | 478 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 27% | 1% |
| Binger / Purger | 493 | 0.00 | 0.11 | 0.00 | 0.00 | 0.0 |  | 33% | 1% |
| Faustian Scholar / Tumorous Magi | 538 | 0.00 | 0.05 | 0.00 | 0.00 | 0.0 |  | 28% | 1% |
| Silent Companion / Patient Confidant | 613 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Sane Sorrowful / Insane Incandescent | 418 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 2% |
| Reservoir of Sunshine / Beloved Homunculus | 500 | 0.00 | 0.01 | 0.00 | 0.00 | 0.0 |  | 29% | 2% |
| Wailing Confessor / Voiceless Accused | 467 | 0.00 | 0.11 | 0.00 | 0.00 | 0.0 |  | 28% | 1% |
| Mocking Recluse / Jar Dweller | 606 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 31% | 1% |
| Shrewd Quaker / Hard-Tack Baker | 613 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 | F0.0 | 26% | 1% |
| Perennial Pruner / Haphazard Herbalist | 603 | 0.00 | 0.00 | 0.00 | 0.33 | 0.0 |  | 28% | 1% |
| Venomous Vessel / Sinuous Acolyte | 617 | 0.00 | 0.00 | 0.00 | 0.00 | 3.0 | E3.0 | 28% | 2% |
| Oathbreaker / Oathkeeper | 520 | 0.00 | 0.01 | 0.00 | 0.00 | 0.5 | Q0.5 | 28% | 2% |
| Hopeful Sower / Grain Hoarder | 569 | 0.00 | 0.00 | 0.00 | 0.00 | 2.8 | E2.8 | 31% | 1% |
| The Tallyman / Dreaded Abacist | 514 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 2% |
| Spagyric Physician / Arsenic Apothecary | 574 | 0.00 | 0.00 | 0.00 | 0.00 | 0.3 | E0.1 W0.1 A0.0 | 31% | 1% |
| Iatrochemist / Mercury-Blooded | 509 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 3% |
| Worm-Brained Absinthard / Fairy-Chaser | 570 | 0.00 | 0.00 | 0.00 | 0.00 | 0.2 | W0.2 | 26% | 1% |
| Leech Catcher / Bloodless Somnambulist | 589 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Nubile Nymph / Virgin Pure | 711 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 27% | 1% |
| Orgasmic Musician / Brooding Composer | 669 | 0.00 | 0.00 | 0.00 | 0.00 | 0.1 | W0.1 E0.0 | 24% | 1% |
| Short-Lived Brute / Timeless Warrior-Poet | 663 | 0.00 | 0.01 | 0.00 | 0.00 | 1.1 | F1.1 E0.0 | 33% | 2% |
| Furnace Keeper / Staunch Stoker | 513 | 0.00 | 0.02 | 0.00 | 0.00 | 4.6 | F4.6 | 32% | 2% |
| Covert Degenerate / Esteemed Burgher | 695 | 0.00 | 0.08 | 0.00 | 0.00 | 0.0 |  | 30% | 2% |
| Closeted Apostate / Flaming Heretic | 469 | 0.00 | 0.00 | 0.00 | 0.00 | 0.1 | F0.1 | 31% | 2% |
| Strawman / Burnt Effigy | 499 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 4% |
| Epileptic Metallurgist / Lithiated Assayer | 716 | 0.00 | 0.00 | 0.00 | 0.00 | 4.3 | F4.3 A0.0 | 33% | 1% |
| Mummy Grinder / Intrepid Archaeologist | 739 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 27% | 1% |
| Footnoted Scholar / Pedantic Pedagogue | 497 | 0.00 | 0.00 | 1.04 | 0.00 | 0.5 | F0.5 | 31% | 2% |
| Mercurial Monomaniac / Haunted Mind | 754 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 26% | 1% |
| Driveling Chemist / Feverish Scribe | 624 | 0.00 | 0.01 | 0.00 | 0.00 | 7.4 | A1.8 E1.8 F1.8 | 36% | 1% |
| Placenta Purloiner / Viscera Monger | 659 | 0.00 | 0.00 | 0.00 | 0.25 | 0.0 | A0.0 | 30% | 2% |

---
Generated by `game/tools/league.py`. Re-create from saved games: `python game/tools/league.py --from game/sim/results/20261023-093118`.

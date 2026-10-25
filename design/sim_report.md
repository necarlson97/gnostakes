# Gnostakes simulation report

*Overwritten after every finished league run; this file always holds the most recent results.*

| | |
|---|---|
| Run | `20261024-020959` (game/sim/results/20261024-020959) |
| Games | 1300 (4 players each) |
| Bots | all |
| Rule overrides | none (rules as written) |
| Card data | design/source_snapshot, synced 2026-10-24 02:03 |
| Learned card power | 2026-10-23 10:07 |
| Written | 2026-10-24 03:18 |

## Headlines

- **Game length:** 14.7 rounds on average (half of games end by round 15, 90% by round 22).
- **How games end:** edification 63%, conflagration 31%, putrescence 5%.
- **Deaths:** 1.4% of players finish with no teeth; 0.0% of games have no living winner.
- **Winning score:** the winner holds 7 keys at the median (p10 4, p90 8).
- **Strongest bots:** adaptive 1.38x, nihilist 1.37x, fire_air 1.32x.
- **Weakest bots:** attrition 0.77x, straights 0.69x, sculptor 0.33x.
- **Best key cards (keys per claim):** Solifactory Smith / Brawny Striker 3.49, Bodysnatcher / Overworked Gravedigger 1.09, Twofold Widow / Lethean Elder 1.03. Average card: 0.31.
- **Tokens:** the median player gains 5 tokens a game (90th percentile 21); 22% of players gain none.
- **Most tooth loss to its holder (per claim):** Solifactory Smith / Brawny Striker 2.67, Hairshirt Bearer / Fleabitten Penitent 1.48, Sulfurous Sage / Socratic Self-Slayer 1.45.

## Bots

"vs even" is win share divided by an even share at the table (1.00x = average). The 95% interval is on the win rate; differences smaller than it are noise.

| Bot | Seats | Win % | ±95% | vs even | Keys/game | Teeth left | Dead % |
|---|---:|---:|---:|---:|---:|---:|---:|
| adaptive | 161 | 34.6% | 7.3% | 1.38x | 3.54 | 5.7 | 0.6% |
| nihilist | 188 | 34.1% | 6.8% | 1.37x | 3.69 | 6.0 | 0.0% |
| fire_air | 195 | 32.9% | 6.6% | 1.32x | 3.72 | 5.6 | 0.5% |
| air | 200 | 32.5% | 6.5% | 1.30x | 3.60 | 5.6 | 0.5% |
| kinds | 182 | 31.3% | 6.7% | 1.25x | 3.25 | 5.7 | 1.6% |
| saboteur | 176 | 30.8% | 6.8% | 1.23x | 3.43 | 5.3 | 1.7% |
| quintessence | 159 | 30.5% | 7.2% | 1.22x | 3.38 | 5.8 | 0.6% |
| economist | 166 | 29.5% | 6.9% | 1.18x | 3.34 | 5.7 | 1.2% |
| discarder | 156 | 29.4% | 7.2% | 1.18x | 3.63 | 5.9 | 0.0% |
| water_air | 190 | 29.1% | 6.5% | 1.16x | 3.52 | 5.6 | 0.5% |
| earth_water | 189 | 28.7% | 6.5% | 1.15x | 3.16 | 5.5 | 0.5% |
| water_fire | 191 | 28.4% | 6.4% | 1.14x | 3.49 | 5.5 | 0.0% |
| fire | 193 | 28.2% | 6.3% | 1.13x | 3.66 | 5.6 | 0.0% |
| colors | 170 | 26.9% | 6.7% | 1.07x | 3.38 | 5.5 | 0.6% |
| burner | 191 | 26.3% | 6.2% | 1.05x | 3.06 | 5.9 | 0.0% |
| high_roller | 177 | 26.2% | 6.5% | 1.05x | 3.28 | 5.5 | 1.1% |
| earth_fire | 179 | 26.1% | 6.4% | 1.04x | 3.31 | 5.4 | 2.2% |
| earth | 168 | 23.0% | 6.4% | 0.92x | 2.89 | 5.6 | 0.0% |
| tooth_miser | 181 | 22.8% | 6.1% | 0.91x | 2.96 | 6.6 | 0.0% |
| water | 196 | 22.7% | 5.9% | 0.91x | 3.19 | 5.5 | 1.5% |
| pairs | 162 | 21.7% | 6.3% | 0.87x | 3.03 | 6.0 | 0.6% |
| earth_air | 180 | 21.4% | 6.0% | 0.86x | 2.97 | 5.9 | 0.0% |
| key_rusher | 196 | 21.2% | 5.7% | 0.85x | 3.18 | 4.9 | 6.1% |
| balanced | 166 | 20.9% | 6.2% | 0.84x | 3.12 | 5.9 | 0.6% |
| open_slots | 188 | 19.9% | 5.7% | 0.80x | 2.72 | 5.5 | 0.5% |
| attrition | 179 | 19.3% | 5.8% | 0.77x | 2.95 | 4.4 | 11.2% |
| straights | 152 | 17.3% | 6.0% | 0.69x | 2.72 | 5.9 | 0.0% |
| sculptor | 185 | 8.2% | 4.0% | 0.33x | 1.99 | 5.8 | 1.1% |
| random | 184 | 0.8% | 1.3% | 0.03x | 0.59 | 5.0 | 6.5% |

**adaptive** ends committed to: key_rusher 83, fire_air 13, earth_fire 11, earth_air 11, economist 9, earth_water 6, earth 6, air 5.

## Game length and endings

| Rounds | min | p10 | p50 | mean | p90 | max |
|---|---:|---:|---:|---:|---:|---:|
| | 3 | 7 | 15 | 14.7 | 22 | 35 |

| Ending | Games | Share |
|---|---:|---:|
| edification | 825 | 63.5% |
| conflagration | 407 | 31.3% |
| putrescence | 68 | 5.2% |

## Tokens

Per player. "Per game" percentiles are over player-games; peaks are the most held at one time.

| Token | Per round | Per game p50 | p90 | mean | Spent/game | None gained | Peak p50 | Peak p90 | Peak max |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| E | 0.07 | 0 | 2 | 1.1 | 0.8 | 78% | 0 | 2 | 29 |
| W | 0.06 | 0 | 3 | 0.9 | 0.8 | 75% | 0 | 3 | 31 |
| F | 0.17 | 0 | 8 | 2.5 | 1.7 | 56% | 0 | 5 | 36 |
| A | 0.21 | 0 | 12 | 3.1 | 2.5 | 67% | 0 | 5 | 31 |
| Q | 0.04 | 0 | 2 | 0.6 | 0.3 | 77% | 0 | 1 | 15 |
| all | 0.56 | 5 | 21 | 8.2 |  | 22% | 3 | 11 | 90 |

### Top 5 producers per token

Share of all income of that token, total produced in this run, and per claim of the card.

- **E** (9 cards give at least 1%): Venomous Vessel 35% (1986, 3.3/claim); Hopeful Sower 20% (1154, 2.1/claim); Driveling Chemist 20% (1144, 2.0/claim); Burn-Scarred Glasswright 9% (512, 0.6/claim); Short-Lived Brute 5% (290, 0.4/claim)
- **W** (9 cards give at least 1%): Dependable Tosspot 40% (1968, 2.2/claim); Driveling Chemist 23% (1144, 2.0/claim); Pot-Licking Friar 17% (841, 0.9/claim); Gout-Ridden Glutton 5% (236, 0.3/claim); Enthralling Eulogist 4% (219, 0.3/claim)
- **F** (7 cards give at least 1%): Doomed Pandorite 40% (5135, 6.0/claim); Lithiated Assayer 23% (2958, 4.1/claim); Powder Miller 15% (1893, 2.0/claim); Driveling Chemist 9% (1144, 2.0/claim); Timeless Warrior-Poet 6% (774, 1.2/claim)
- **A** (5 cards give at least 1%): Overworked Gravedigger 52% (8320, 8.9/claim); Dubious Demonologist 33% (5225, 9.1/claim); Driveling Chemist 7% (1144, 2.0/claim); Ayahuascite 5% (808, 1.0/claim); Tongueless Traitor 2% (295, 0.4/claim)
- **Q** (7 cards give at least 1%): Expendable Assistant 51% (1555, 2.2/claim); Shunned Executioner 20% (608, 0.9/claim); Active Assistant 8% (255, 0.3/claim); Oathkeeper 7% (222, 0.4/claim); Bird-Fouled Hagia 6% (192, 0.2/claim)

## Cards

Per claim of the card (either face). Teeth lost (holder) = teeth the card's own effects cost its holder; (others) = teeth it took from opponents. Win/dead % are for players who held the card at some point (baseline win share per seat: 25.0%).

| Card (upright / inverted) | Claims | Keys/claim | Teeth lost (holder) | Teeth taken (others) | Teeth regained | Tokens/claim | Main tokens | Holder win % | Holder dead % |
|---|---:|---:|---:|---:|---:|---:|---|---:|---:|
| Solifactory Smith / Brawny Striker | 1039 | 3.49 | 2.67 | 0.00 | 0.00 | 0.1 | E0.0 Q0.0 | 64% | 3% |
| Bodysnatcher / Overworked Gravedigger | 934 | 1.09 | 0.00 | 0.00 | 0.00 | 9.0 | A9.0 | 26% | 1% |
| Twofold Widow / Lethean Elder | 924 | 1.03 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Broken Martyr / Tarred Prophet | 936 | 1.01 | 0.72 | 0.00 | 0.74 | 0.0 |  | 38% | 1% |
| Flayed Flagellant / Lash-Blessed Monk | 914 | 0.86 | 0.00 | 0.00 | 0.00 | 0.1 | A0.1 | 34% | 1% |
| Autoerotic Anesthetist / Back-Alley Butcher | 949 | 0.85 | 0.51 | 0.00 | 0.00 | 0.0 |  | 35% | 1% |
| Epicurean Gourmand / Gout-Ridden Glutton | 932 | 0.83 | 0.00 | 0.00 | 0.00 | 0.3 | W0.3 Q0.0 | 36% | 1% |
| Fire-Drake / Powder Miller | 939 | 0.82 | 0.01 | 0.00 | 0.00 | 2.0 | F2.0 | 39% | 1% |
| Gin-Soaked Gutter-Sweeper / Dependable Tosspot | 915 | 0.78 | 0.00 | 0.00 | 0.00 | 2.2 | W2.2 | 34% | 1% |
| Sulfurous Sage / Socratic Self-Slayer | 880 | 0.74 | 1.45 | 0.00 | 0.00 | 0.0 | A0.0 E0.0 F0.0 | 38% | 1% |
| Passive Puffer / Active Assistant | 917 | 0.69 | 0.00 | 0.00 | 0.00 | 0.3 | Q0.3 | 33% | 1% |
| Noble Ghostwriter / Pilfered Penname | 941 | 0.69 | 0.00 | 0.00 | 0.00 | 0.1 | W0.1 | 36% | 1% |
| Glass-Eyed Alchemist / Sun-Blinded Prismist | 918 | 0.67 | 0.00 | 0.00 | 0.00 | 0.0 |  | 30% | 1% |
| Pillar-top Hermit / Bird-Fouled Hagia | 925 | 0.61 | 0.00 | 0.00 | 0.00 | 0.2 | Q0.2 | 33% | 1% |
| Witch Drowner / Corrupted Inquisitor | 930 | 0.48 | 0.00 | 0.00 | 0.00 | 0.1 | Q0.1 | 28% | 1% |
| Lead Drinker / Bacchus Host | 907 | 0.42 | 0.00 | 0.00 | 0.00 | 0.0 | W0.0 | 38% | 1% |
| Primed Pomologist / Charitable Ciderist | 926 | 0.41 | 0.00 | 0.00 | 0.00 | 0.4 | E0.2 W0.2 Q0.0 | 29% | 1% |
| Hollowhead / God-Struck Fool | 919 | 0.39 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 1% |
| Hollow-Bellied Saint / Pot-Licking Friar | 891 | 0.33 | 0.00 | 0.00 | 0.00 | 1.0 | W1.0 | 27% | 1% |
| Academic Artillerist / Craven Cannoneer | 894 | 0.32 | 0.01 | 0.00 | 0.00 | 0.1 | F0.1 | 25% | 1% |
| Alembic Servitor / Burn-Scarred Glasswright | 889 | 0.26 | 0.00 | 0.00 | 0.00 | 0.6 | E0.6 | 29% | 1% |
| Plate-Plundering Deacon / Pious Parishioner | 884 | 0.25 | 0.01 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Persecuted Paranoiac / Psychotic Christ | 888 | 0.23 | 0.01 | 0.01 | 0.00 | 0.0 | A0.0 | 26% | 1% |
| Reeking Husk / Discarded Follower | 869 | 0.21 | 0.00 | 0.00 | 0.00 | 0.2 | E0.1 A0.0 | 26% | 1% |
| Bezoar Seeker / Sadistic Shepherd | 852 | 0.15 | 0.01 | 0.00 | 0.00 | 0.1 | E0.1 | 26% | 2% |
| Pact Proctor / Wrathful Sovern | 821 | 0.07 | 0.01 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Self-Sacrificant / Post-Fate Oblate | 711 | 0.07 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 2% |
| Reliquary Larcenist / Finger-Bone Forager | 774 | 0.05 | 0.01 | 0.00 | 0.00 | 0.0 | A0.0 | 26% | 1% |
| Enthralling Eulogist / Paid Mourner | 741 | 0.05 | 0.00 | 0.00 | 0.00 | 0.3 | W0.3 | 27% | 1% |
| Shunned Executioner / Bloodstained Recluse | 664 | 0.04 | 0.00 | 0.00 | 0.00 | 0.9 | Q0.9 | 33% | 1% |
| Hairshirt Bearer / Fleabitten Penitent | 568 | 0.03 | 1.48 | 0.00 | 0.00 | 0.0 |  | 29% | 6% |
| Branded Protégé / Expendable Assistant | 700 | 0.03 | 0.00 | 0.00 | 0.00 | 2.5 | Q2.3 F0.2 | 34% | 2% |
| Shuar Headshrinker / Ayahuascite | 794 | 0.03 | 0.00 | 0.05 | 0.00 | 1.0 | A1.0 | 30% | 1% |
| Promising Pugilist / Bruised Boxer | 602 | 0.03 | 0.03 | 0.00 | 0.00 | 0.0 |  | 32% | 2% |
| Promethean Pyro / Doomed Pandorite | 856 | 0.03 | 0.00 | 0.00 | 0.00 | 6.0 | F6.0 W0.0 E0.0 | 32% | 1% |
| Tongueless Traitor / Candid Jester | 764 | 0.02 | 0.00 | 0.00 | 0.00 | 0.4 | A0.4 | 28% | 2% |
| Unshakable Empiricist / Vivisectionist | 585 | 0.01 | 0.00 | 0.00 | 1.13 | 0.0 |  | 36% | 3% |
| Fingerless Sapper / Powder Monkey | 683 | 0.00 | 0.00 | 2.31 | 0.00 | 0.0 | F0.0 | 36% | 1% |
| Knower of True Names / Lockpicking Archon | 573 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 26% | 2% |
| Mooncalf Mother / Carrier of the Droplet | 536 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 30% | 1% |
| Gargoyle Mother / Famed Freemason | 492 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 1% |
| Incorruptible Judge / Hardnosed Idealist | 455 | 0.00 | 0.44 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Doomed Romantic / Kismet Syzygyst | 470 | 0.00 | 0.15 | 0.00 | 0.00 | 0.0 |  | 34% | 2% |
| Hard-Weathered Quarryman / Stonefaced Stoic | 596 | 0.00 | 0.03 | 0.00 | 0.09 | 0.0 |  | 29% | 2% |
| Barefoot Pilgrim / Marooned Wanderer | 541 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 27% | 1% |
| Clamp-Turning Examiner / Confessional Magistrate | 494 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 27% | 1% |
| Toothless Grinner / Corpse-Like Pauper | 482 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Binger / Purger | 446 | 0.00 | 0.11 | 0.00 | 0.00 | 0.0 |  | 27% | 2% |
| Faustian Scholar / Tumorous Magi | 520 | 0.00 | 0.08 | 0.00 | 0.00 | 0.0 |  | 24% | 1% |
| Silent Companion / Patient Confidant | 601 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 27% | 1% |
| Sane Sorrowful / Insane Incandescent | 452 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 0% |
| Reservoir of Sunshine / Beloved Homunculus | 448 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 25% | 1% |
| Wailing Confessor / Voiceless Accused | 483 | 0.00 | 0.09 | 0.00 | 0.00 | 0.0 |  | 27% | 2% |
| Mocking Recluse / Jar Dweller | 586 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 2% |
| Shrewd Quaker / Hard-Tack Baker | 601 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 1% |
| Perennial Pruner / Haphazard Herbalist | 610 | 0.00 | 0.00 | 0.00 | 0.33 | 0.0 |  | 29% | 1% |
| Venomous Vessel / Sinuous Acolyte | 609 | 0.00 | 0.00 | 0.00 | 0.00 | 3.3 | E3.3 | 23% | 1% |
| Oathbreaker / Oathkeeper | 529 | 0.00 | 0.03 | 0.00 | 0.00 | 0.4 | Q0.4 | 29% | 1% |
| Hopeful Sower / Grain Hoarder | 556 | 0.00 | 0.00 | 0.00 | 0.00 | 2.1 | E2.1 | 28% | 1% |
| The Tallyman / Dreaded Abacist | 511 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 24% | 1% |
| Spagyric Physician / Arsenic Apothecary | 568 | 0.00 | 0.00 | 0.00 | 0.00 | 0.4 | E0.2 W0.1 A0.0 | 29% | 1% |
| Iatrochemist / Mercury-Blooded | 544 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 23% | 2% |
| Worm-Brained Absinthard / Fairy-Chaser | 557 | 0.00 | 0.00 | 0.00 | 0.00 | 0.2 | W0.2 | 28% | 3% |
| Leech Catcher / Bloodless Somnambulist | 590 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 33% | 1% |
| Nubile Nymph / Virgin Pure | 701 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 1% |
| Orgasmic Musician / Brooding Composer | 639 | 0.00 | 0.00 | 0.00 | 0.00 | 0.1 | W0.0 E0.0 | 27% | 1% |
| Short-Lived Brute / Timeless Warrior-Poet | 669 | 0.00 | 0.01 | 0.00 | 0.00 | 1.6 | F1.2 E0.4 | 25% | 2% |
| Furnace Keeper / Staunch Stoker | 491 | 0.00 | 0.04 | 0.00 | 0.00 | 1.0 | F1.0 | 31% | 1% |
| Covert Degenerate / Esteemed Burgher | 651 | 0.00 | 0.07 | 0.00 | 0.00 | 0.0 |  | 30% | 1% |
| Closeted Apostate / Flaming Heretic | 450 | 0.00 | 0.00 | 0.00 | 0.00 | 0.1 | F0.1 | 26% | 2% |
| Strawman / Burnt Effigy | 508 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 29% | 4% |
| Epileptic Metallurgist / Lithiated Assayer | 715 | 0.00 | 0.00 | 0.00 | 0.00 | 4.2 | F4.2 A0.0 | 35% | 1% |
| Mummy Grinder / Intrepid Archaeologist | 697 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 28% | 0% |
| Footnoted Scholar / Pedantic Pedagogue | 500 | 0.00 | 0.00 | 1.10 | 0.00 | 0.5 | F0.5 | 33% | 1% |
| Mercurial Monomaniac / Haunted Mind | 747 | 0.00 | 0.00 | 0.00 | 0.00 | 0.0 |  | 30% | 1% |
| Driveling Chemist / Feverish Scribe | 586 | 0.00 | 0.00 | 0.00 | 0.00 | 7.8 | A2.0 E2.0 F2.0 | 39% | 1% |
| Placenta Purloiner / Viscera Monger | 624 | 0.00 | 0.00 | 0.00 | 0.23 | 0.0 | A0.0 | 29% | 2% |
| Dubious Demonologist / Failed Exorcist | 574 | 0.00 | 0.02 | 0.00 | 0.00 | 9.1 | A9.1 W0.0 F0.0 | 40% | 1% |

Which ability lines fire, how often, and what each produces: see [sim_abilities.md](sim_abilities.md).

---
Generated by `game/tools/league.py`. Re-create from saved games: `python game/tools/league.py --from game/sim/results/20261024-020959`.

# Card variant experiments

*Overwritten by each variants run. Written 2026-10-24 05:53.*

650 games per run, 4 players, bots: all, same seeds for every run. Cards under test: Fingerless Sapper / Powder Monkey, Hollow-Bellied Saint / Pot-Licking Friar.

Each run varies only the card text. With these game counts, per-card holder win rates are good to about ±5 points, so look for big or consistent moves.

## Variants

- **cheap_keys**, Powder Monkey: "Incinerate this card to force all opponents to lose a tooth. / Spend 4F to gain 1 key." (was: "Incinerate this card to force all opponents to lose a tooth. / Spend 5F to gain 1 key.")
- **cheap_keys**, Pot-Licking Friar: "Whenever you discard a die, gain 1W. / Spend 3W to gain 1 key." (was: "Whenever you discard a die, gain 1W. / Spend 2W to gain 1 key and incinerate this card.")
- **fuel**, Powder Monkey: "Spend 3F and incinerate this card to force all opponents to lose a tooth. / Spend 5F to gain 1 key." (was: "Incinerate this card to force all opponents to lose a tooth. / Spend 5F to gain 1 key.")
- **fuel**, Pot-Licking Friar: "Whenever you discard a die, gain 2W. / Spend 2W to gain 1 key and incinerate this card." (was: "Whenever you discard a die, gain 1W. / Spend 2W to gain 1 key and incinerate this card.")
- **engine**, Fingerless Sapper: "On rolling an F, you may discard a Potency die to gain F equal to that Potency. / Once per round, you may spend 1F to undiscard all discarded dice" (was: "On rolling an F, you may discard a Potency die to gain F equal to that Potency. / Once per round, you may spend 2F to undiscard all discarded dice")
- **engine**, Powder Monkey: "Incinerate this card to force all opponents to lose a tooth. / Spend 4F to gain 1 key." (was: "Incinerate this card to force all opponents to lose a tooth. / Spend 5F to gain 1 key.")
- **engine**, Pot-Licking Friar: "Whenever you discard a die or score nothing, gain 1W. / Spend 2W to gain 1 key and incinerate this card." (was: "Whenever you discard a die, gain 1W. / Spend 2W to gain 1 key and incinerate this card.")

## The game overall

| Run | Rounds | Edification | Conflagration | Putrescence | Dead % | Winner keys p50 | Tokens/player p50 / p90 |
|---|---:|---:|---:|---:|---:|---:|---|
| as written | 14.8 | 63% | 33% | 4% | 1.0% | 7 | 5 / 25 |
| cheap_keys | 14.5 | 69% | 28% | 3% | 0.9% | 7 | 5 / 26 |
| fuel | 14.7 | 66% | 32% | 2% | 0.7% | 7 | 5 / 25 |
| engine | 14.5 | 67% | 30% | 4% | 0.9% | 7 | 6 / 26 |

## Fingerless Sapper / Powder Monkey

| Run | Claims | Keys/claim | Tokens/claim | Teeth lost/claim | Holder win % | Holder dead % |
|---|---:|---:|---:|---:|---:|---:|
| as written | 367 | 0.02 | 0.5 | 0.00 | 32% | 1% |
| cheap_keys | 362 | 0.02 | 0.6 | 0.00 | 32% | 1% |
| fuel | 365 | 0.15 | 0.5 | 0.01 | 30% | 1% |
| engine | 364 | 0.03 | 0.6 | 0.00 | 31% | 1% |

Ability lines: activations per game held (winners / others), keys and tokens per activation.

| Run | Face | Line | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act |
|---|---|---|---:|---:|---:|---:|---|---|
| as written | Fingerless Sapper | activated: undiscard | 0.02 | 0.03 | 0.02 | 0.00 |  | F1.8 |
| as written | Fingerless Sapper | on roll | 0.11 | 0.14 | 0.10 | 0.00 | F4.8 |  |
| as written | Powder Monkey | activated: blast | 0.87 | 0.72 | 0.94 | 0.00 |  |  |
| as written | Powder Monkey | activated: key | 0.02 | 0.03 | 0.01 | 1.00 |  | F5.0 |
| cheap_keys | Fingerless Sapper | activated: undiscard | 0.02 | 0.02 | 0.03 | 0.00 |  | F1.8 |
| cheap_keys | Fingerless Sapper | on roll | 0.12 | 0.15 | 0.11 | 0.00 | F4.8 |  |
| cheap_keys | Powder Monkey | activated: blast | 0.85 | 0.68 | 0.93 | 0.00 |  |  |
| cheap_keys | Powder Monkey | activated: key | 0.02 | 0.03 | 0.02 | 1.00 |  | F4.0 |
| fuel | Fingerless Sapper | activated: undiscard | 0.03 | 0.02 | 0.04 | 0.00 |  | F1.8 |
| fuel | Fingerless Sapper | on roll | 0.10 | 0.15 | 0.08 | 0.00 | F4.8 |  |
| fuel | Powder Monkey | activated: blast | 0.01 | 0.00 | 0.02 | 0.00 |  | F1.5 A0.2 |
| fuel | Powder Monkey | activated: key | 0.15 | 0.19 | 0.14 | 0.96 |  | F4.3 A0.0 |
| engine | Fingerless Sapper | activated: undiscard | 0.06 | 0.10 | 0.05 | 0.00 |  | F1.0 |
| engine | Fingerless Sapper | on roll | 0.12 | 0.17 | 0.10 | 0.00 | F4.8 |  |
| engine | Powder Monkey | activated: blast | 0.87 | 0.72 | 0.94 | 0.00 |  |  |
| engine | Powder Monkey | activated: key | 0.03 | 0.03 | 0.03 | 1.00 |  | F4.0 |

## Hollow-Bellied Saint / Pot-Licking Friar

| Run | Claims | Keys/claim | Tokens/claim | Teeth lost/claim | Holder win % | Holder dead % |
|---|---:|---:|---:|---:|---:|---:|
| as written | 456 | 0.38 | 1.3 | 0.00 | 28% | 1% |
| cheap_keys | 451 | 0.83 | 2.9 | 0.00 | 32% | 0% |
| fuel | 461 | 0.42 | 2.0 | 0.00 | 27% | 0% |
| engine | 453 | 0.77 | 3.4 | 0.00 | 37% | 0% |

Ability lines: activations per game held (winners / others), keys and tokens per activation.

| Run | Face | Line | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act |
|---|---|---|---:|---:|---:|---:|---|---|
| as written | Hollow-Bellied Saint | on roll | 0.09 | 0.01 | 0.11 | 0.00 | W5.0 |  |
| as written | Hollow-Bellied Saint | on scheme start | 0.51 | 0.49 | 0.53 | 0.00 |  |  |
| as written | Pot-Licking Friar | activated: key | 0.41 | 0.51 | 0.37 | 0.94 |  | W1.8 |
| as written | Pot-Licking Friar | on discard | 0.87 | 1.05 | 0.79 | 0.00 | W1.0 |  |
| cheap_keys | Hollow-Bellied Saint | on roll | 0.11 | 0.17 | 0.08 | 0.00 | W5.1 |  |
| cheap_keys | Hollow-Bellied Saint | on scheme start | 0.51 | 0.47 | 0.54 | 0.00 |  |  |
| cheap_keys | Pot-Licking Friar | activated: key | 0.92 | 1.66 | 0.56 | 0.91 |  | W2.9 |
| cheap_keys | Pot-Licking Friar | on discard | 2.35 | 4.43 | 1.35 | 0.00 | W1.0 |  |
| fuel | Hollow-Bellied Saint | on roll | 0.10 | 0.02 | 0.14 | 0.00 | W5.1 |  |
| fuel | Hollow-Bellied Saint | on scheme start | 0.51 | 0.52 | 0.51 | 0.00 |  |  |
| fuel | Pot-Licking Friar | activated: key | 0.45 | 0.62 | 0.38 | 0.94 |  | W1.9 |
| fuel | Pot-Licking Friar | on discard | 0.75 | 1.11 | 0.61 | 0.00 | W2.0 |  |
| engine | Hollow-Bellied Saint | on roll | 0.09 | 0.02 | 0.13 | 0.00 | W5.0 |  |
| engine | Hollow-Bellied Saint | on scheme start | 0.52 | 0.49 | 0.54 | 0.00 |  |  |
| engine | Pot-Licking Friar | activated: key | 0.82 | 0.89 | 0.78 | 0.95 |  | W2.0 |
| engine | Pot-Licking Friar | on discard | 2.77 | 3.12 | 2.56 | 0.00 | W1.0 |  |
| engine | Pot-Licking Friar | on score nothing | 0.21 | 0.19 | 0.22 | 0.00 | W1.0 |  |

## Strongest and weakest bots per run

- **as written**: top discarder 1.86x, fire_air 1.48x, kinds 1.40x, burner 1.40x; bottom key_rusher 0.73x, straights 0.66x, sculptor 0.52x
- **cheap_keys**: top discarder 1.84x, fire_air 1.64x, burner 1.40x, water_air 1.32x; bottom open_slots 0.71x, straights 0.68x, key_rusher 0.65x
- **fuel**: top discarder 1.92x, fire_air 1.76x, colors 1.44x, water_air 1.34x; bottom key_rusher 0.63x, open_slots 0.62x, sculptor 0.46x
- **engine**: top discarder 1.88x, fire_air 1.46x, burner 1.44x, colors 1.33x; bottom earth 0.71x, straights 0.64x, sculptor 0.43x

Run folders: as written `game/sim/results/20261024-033622`; cheap_keys `game/sim/results/20261024-041121`; fuel `game/sim/results/20261024-044514`; engine `game/sim/results/20261024-051941`

# Gnostakes: Godot engine (headless core) and 3D table

Godot 4.2, pure GDScript, with no scenes and no Node dependencies in `core/`. The same `Game` object runs bot simulations and runs behind the 3D table (`gui/`, the project's main scene).

```
core/
  gk.gd          constants, enums, tunable defaults (cfg)
  die.gd         Die: mutable faces, zone (ready/committed/discarded)
  player.gd      Player: teeth, keys, tokens, dice, cadre
  card.gd        Card: two Abilities (upright/inverted), buried tokens, location, attachment
  ability.gd     Ability: base class for a card face, hook conventions, phrase helpers
  scoring.gd     set menu (data) + search for legal maximal arrangements
  choice.gd      Choice: one decision a player must make
  controller.gd  Controller (bot base), Controller.Async (GUI), Controller.Replay
  random_bot.gd  baseline bot / fuzzer
  card_db.gd     loads data/cards.json and binds res://cards/<id>.gd
  game.gd        Game: state + rules + hook dispatch
cards/<id>.gd    one file per tarot card: inner classes Top and Inv
data/cards.json  generated from the sheet snapshot by tools/sync_cards.py
gui/             the diegetic 3D table (see "3D table" below)
assets/          STLs (print files), models/*.obj and cards/*.png made from them by tools/convert_assets.py
tests/           headless tests
sim/             batch simulations
```

## Running

```bash
game/run.sh tests
```
```bash
game/run.sh sim games=200 players=3 seed=1
```
```bash
game/run.sh sim games=150 players=3 fuzz=1
```
`run.sh` wraps the Godot calls and **fails if any `SCRIPT ERROR` is printed**. Godot doesn't fail a script on a runtime error, so a bare test run can report "0 failures" while errors scroll past. `fuzz=1` gives each player 4 random villagers in random orientations, makes the bots trigger-happy, and prints which card hooks never ran.
```bash
python game/tools/sync_cards.py
```
That regenerates `data/cards.json` (text plus parsed features) and `design/card_features.md`.
Run that last one after re-pulling the sheet into `design/source_snapshot/`. On this machine `godot` is `F:\godot\Godot_v4.2.1-stable_win64.exe\Godot_v4.2.1-stable_win64_console.exe`. Use the `_console` build, or nothing prints. Run `godot --headless --path game --editor --quit` once after adding a new `class_name` script, so the class cache is rebuilt.

## 3D table (`gui/`)

```bash
game/run.sh gui
```
```bash
game/run.sh guitest
```
The first opens the table: you against three `AdaptiveBot`s. The second plays your seat through synthetic mouse input (clicks and drags on real objects) at 4× speed, and fails on any script error or if no game finishes. Add `games=N` or `seed=N` to either. `autoplay` seats a bot in your chair as well. `shot=<png> shot_after=S shots=N` saves screenshots, which is handy for checking layout without watching.

You sit at head height over your seat. In front of you are your cadre, a dice tray, the commit row nearest you, and the discard pile on the left. Your teeth and keys are on the left, and your token piles on the right. The Town Square mat is in the middle, with the village deck on its right and the pyre on its left. Opponents sit left, across and right. Units are centimetres (gravity is set to 981).

| Phase | What you do |
|---|---|
| Swig | Drag upward and release (or press Space) to throw your dice. Click a die to commit it and right-click to discard it, or drag it to the commit row or the discard pile. The sets you could form are ringed in colour, listed on the left and lit on the mat. Click a listed set to commit its dice. **Advise me** asks the AdaptiveBot's dice solver. |
| Scry | Your committed dice are laid out in their scoring groups. Drag dice between groups, or to the back row to leave them out, or browse the legal arrangements with ◀ ▶. |
| Requests | Town Square cards you may request glow. Drag one to your cadre, or click it. Right-click to choose between a set right and paying tokens. |
| Wagers | Drag tokens into the brass dish (click one to take it back). |
| Scheme | Click your villagers to spin them, then confirm. |
| Abilities | A villager glows when its ability can be used now. Click it. |
| Other choices | Card and die targets glow when they're on the table. Everything else is a pop-up list; hover a card name to inspect it. |

Hovering any face-up card shows it large, with both faces' text. Right-drag looks around, the wheel leans in, 1–4 look at a seat, and holding Tab fast-forwards.

How it hooks into the engine (the engine itself is untouched apart from one hook):
- **Your seat** is a `Controller.Async`. `Interaction` turns each `Choice` (by `kind` and `tag`) into a table mode, and the result goes back through `submit()`.
- **Bots** are wrapped in `PacedController`, which waits a beat before any answer that does something, so you can follow along.
- **Dice:** `Game.roller` is the one engine hook. When it's set, `Game.toss()` (used by `roll()` and Vivisectionist) awaits it instead of `rng`. `DiceRoller` throws the physical vials, waits for them to settle (cocked dice get nudged), and reads the face pointing up. Headless sims never set it, so seeds and replays are unchanged. A GUI game can't be replayed from its seed, because the faces came from physics. While fast-forwarding (Tab, or `fast=4` and up), bots' dice land without physics. Your own dice are always thrown.
- **Views follow state.** Each engine event marks the table dirty. `Table._sync()` then works out where every card, die, token, tooth and key belongs and glides it there. No view changes game state.

`tools/convert_assets.py` turns the STLs into OBJ meshes (mm → cm, recentred into die space) and copies `print_and_play/export/game_cards` into `assets/cards/<tarot id>.png`. Re-run it after re-exporting cards or editing the STLs, then let Godot re-import (open the editor, or `godot --headless --path game --editor --quit`).

## Design

**One engine, decisions as awaits.** Rules and card code are written straight-line: `if await may("Spend 2F?"): ...`. When the engine needs input it calls `await controller.decide(game, choice)`.
- Bots return immediately, so a headless game never suspends. It runs as a plain loop, about 150 ms per 3-player game with all hooks live.
- `Controller.Async` suspends until the UI calls `submit(answer)`.
- Every answer is recorded in `game.answers`. Seed plus answers replays the game exactly (tested).

**Four hook channels** cover every mechanism on the 156 faces. Hooks are found by method name, so a card defines only what it uses:

| Channel | Card wording | Method |
|---|---|---|
| Triggered | "On rolling an F…", "Whenever you discard…", "On Scheme start…" | `on_<event>(ev)` (your events), `on_any_<event>(ev)` (anyone's), `on_leave(ev)` (this card burns) |
| Static | "While this is active…", "You can now score…", "All players require one extra key" | `mod_<query>(p, value, ctx) -> value` |
| Replacement | "Whenever you would lose a tooth, instead…", "claim that card yourself instead" | `replace_<event>(ev) -> bool` |
| Activated | "Spend 2E to gain 1 key and incinerate this card", "Once per round, spend W to…" | `acts()` + `can_<id>()` + `act_<id>()` |

**Costs are data** (decision D8: italics mean cost). An act declares `cost = {W = 2, burn = true}`. Cost keys: `E W F A Q any one_type teeth keys burn burn_card inc discard`. The engine checks affordability and pays through one path, `Game.pay`. That path is where Strawman (`mod_cost`), Autoerotic Anesthetist (`mod_cost_alts`) and Closeted Apostate (`on_paid`) hook in.

**"Additional" never retriggers.** Gains carry `additional = true`, and hooks that grant "an additional…" ignore those.

**Failed Exorcist** works through `Ability.resolve()`: it returns a fresh copy of the left card's ability, bound to the Exorcist card. The engine always dispatches to `card.ability.resolve()`.

**Determinism.** All randomness goes through `game.rng`, seeded in `setup()`. Bots have their own RNG.

## Bots (`ai/`)

```
Controller            core/controller.gd   answers Choices (base: safe defaults)
└─ RandomBot          core/random_bot.gd   legal random play; fallback for any unhandled tag
   └─ Bot             ai/bot.gd            shared tactics, driven by a strategy mix + Valuer
      └─ AdaptiveBot  ai/adaptive_bot.gd   re-weights its strategy mix from its cadre
Strategy              ai/strategy.gd       what a bot wants, as data (ai/strategies/*.json)
Valuer                ai/valuer.gd         prices everything in expected keys
DiceSolver            ai/dice_solver.gd    expectimax commit decisions (port of smartplay.py)
Bots                  ai/bots.gd           factory: "random" | "adaptive" | "<strategy>" | "a+b"
```

**Dice solver.** `Bot.choose_assign` uses `DiceSolver`, an in-game port of `design/tools/smartplay.py`:
- It solves forward from the actual roll: every distinct commit choice, then the exact expectation over the reroll.
- Number sets and crystal sets live on separate faces, so the expectation splits into one distribution per part. Those distributions are cached across decisions and bots.
- It is exact for the base game (10 dice, commit ≥ 5). With extra rolls (bonus dice, Gargoyle Mother) it treats the next roll as the last one.
- It handles any dice: bonus dice, edited faces, Q, blanks.
- `run.sh validate` checks it against smartplay's exact probabilities for all 11 menu sets; it agrees within sampling noise.
- It takes about 40 ms per first-roll decision once warm.

**Strategies (27)** are generated by `tools/make_strategies.py`; don't hand-edit the JSON.
- Generalist: balanced.
- Set families: straights, kinds, colors, pairs, high_roller, nihilist.
- Dice and cards: sculptor, discarder, open_slots, burner.
- Tempo and conflict: key_rusher, attrition, saboteur, tooth_miser.
- Tokens: earth, water, fire, air, quintessence, economist, plus all six element pairs (earth_water … fire_air).

Learned numbers live in `ai/data/` (`card_power.json`, `viability.json`), so regenerating strategies never erases learning.

**Leagues** (`tools/league.py`) run many Godot processes in parallel.
- In pool mode each game seats a random sample of bots, and every game is saved as a JSON line under `sim/results/`.
- The report gives each bot's win share against an even share (1.00× = average), with a 95% interval.
- `--learn` re-derives card power and strategy viability from the saved games. Learn, then run again.
```bash
python game/tools/league.py --games 1200 --players 4 --pool all --jobs 12 --learn
```
`--tokens` adds the token economy report:
- income and spending per round and per game, for each type;
- peak holdings (average, 90th percentile, max);
- each token's income sources, labelled by the face that produced them.

After every run, **`design/sim_report.md` is overwritten** with the full findings, and a copy is kept in the run folder. It includes:
- headlines;
- every bot's win share, keys and death rate;
- game length and endings;
- each token's 50th/90th-percentile income per game, per-round rate, peaks, and top 5 producers;
- a row per card: keys, teeth lost or taken, teeth regained and tokens per claim, and holders' win and death rates.

Read it while the next run goes. `--no-doc` skips it; `--from <run>` regenerates it from saved games.

`--card <id>` shows how that card's costs were paid and how many keys it produced. Either flag also works on saved results with `--from sim/results/<run>`.

**Strategies are data, tactics are shared.** A strategy JSON holds feature weights (card fit), set-family multipliers, token multipliers, tooth fear and preferred cadre size. `Bot` holds no per-strategy code. `Bot.new([Strategy.named("straights")])` is a straights bot, and `AdaptiveBot` is the same class with a changing mix.

**Routing.** `Bot.decide()` sends each Choice to `choose_<tag>()` (assign, rotate_die, arrangement, request, wager, orient, trim, act, may, cost, target…). Any tag without a method falls back to `RandomBot`, so new engine prompts never break a bot. Adding a smarter tactic means writing one method.

**Everything is priced in expected keys** (`Valuer`):
- tokens: a baseline price times the strategy's multiplier. Conversions on your own cards raise it ("6W → key" makes W worth about ⅙ key), and big piles lower it.
- teeth: urgency rises as teeth run low, and losing one matters less when you're ahead (the Putrescence clock).
- cards: power + strategy fit, minus the worst card you'd have to drop.
- dice: request rights × Town Square card values, plus set-family taste, plus what your cadre's faces reward or punish. While rerolls remain, partial sets count too.

Optional effects carry an **offer**: `may(prompt, {cost = {...}, gain = {...}})`, `may_pay(cost, prompt, gain)`. Activated abilities may declare `gain = {...}`; otherwise `Valuer.ACT_GAINS` supplies a default by act id. So "Spend 2W to score a set again" is taken when the extra request is worth more than 2 × price(W).

**Card fit is derived from card text, never hand-set.** `tools/card_features.py` (run by `sync_cards.py`) parses each face into signed features. Oathkeeper comes out as `kind +1 · straight −1`, Hairshirt Bearer as `straight +1`. Parser misses are fixed in `data/feature_overrides.json`. Audit the result in `design/card_features.md`.

**Adaptive commitment.** The weight of each strategy is softmax(log viability + commitment × Σ fit over cadre cards). A Town Square card is valued under the mix you *would* have after taking it, so a pivot toward a stronger strategy happens without special-case code.

**Learned card power.** `run.sh learn games=600` credits each key to the card whose ability produced it and writes `ai/data/card_power.json`, shrinking rarely-seen cards toward the mean. `Valuer.power()` prefers this file over the feature guess. Re-learn after card edits, and with smarter bots in the seats.

```bash
game/run.sh sim games=100 bots=adaptive,straights,random
```
```bash
game/run.sh debug games=30 bots=adaptive,straights,random
```
```bash
game/run.sh tests ai
```
The first runs a league (seats rotate each game). The second totals what each bot actually does. The third runs the AI tests.

**Next steps:**
- fit corrections learned from league data (per-card, per-strategy residuals);
- replay-based look-ahead for timing-sensitive decisions;
- weight tuning with `Strategy.mutated()`;
- a solver-aware `choose_rotate_die`.

## Writing a card

```gdscript
# cards/water_03.gd: Three of Cups
extends RefCounted

class Top extends Ability:  # Gin-Soaked Gutter-Sweeper
	func on_token_gained(ev):
		if ev.type == "W" and not ev.additional and await may("Gain +1W?"): await gain({W = 1}, true)

class Inv extends Ability:  # Dependable Tosspot
	func on_score_nothing(_ev): await gain({W = 3})
	func acts(): return {key = {cost = {W = 2, burn = true}, label = "2W, incinerate: gain a key"}}
	func act_key(): await gain_keys()
```
Card ids come from tarot identity (`major_00`…`major_21`, `earth_01`…`earth_10`, `earth_princess`/`prince`/`queen`/`king`, and the same for water/fire/air), so renames in the sheet don't break code. Faces without a script load as text-only (`implemented = false`).

Phrase helpers on `Ability`: `potency_for` ("On rolling X, you may discard a Potency die to gain X equal to that Potency"), `adjust_potency(±1)`, `rotate_any`, the relinquish act, `with_die` (bonus dice), `may_pay`, `color_set`, `set_has`.

## Status

- **All 78 cards / 156 faces are scripted.** A fuzz run (`fuzz=1`, 150 four-player games) executes all 248 card hook methods with no script errors.
- **Toothless Grinner:** cards that offer a choice joined by "or" (Sower, Herbalist, Brawny Striker, Footnoted Scholar, Glutton) route it through `Ability.either()`, which offers "and" for 2Q.
- **No self-retrigger:** a card's hook doesn't fire again while it is still resolving. For example, Patient Confidant's own E→W rotation doesn't trigger its W→E line. Other cards still see the retriggered on-roll.

### Rulings (confirmed 2026-10-22)
- The first player rotates each round. "Simultaneous" steps resolve one player at a time, in that order.
- Town Square slots can also be requested for 3W / 3E / 3F / 3A (slot 1–4), paid on a successful claim, as often as you can afford. Each scored set gives one request (tier 3 gives two).
- A wager is a specific set of tokens (raw total compared). The winner spends exactly those; losers keep theirs.
- Teeth lost as a cost *can* be prevented or replaced (Stoic, Boxer, Oathbreaker, Archon…).
- Scheme orientation counts as inverting (Pedantic Pedagogue fires).
- God-Struck Fool: "if you did not score any Potency dice".
- Stonefaced Stoic: buried teeth leave your count, so you can reach Putrescence with teeth on the Stoic.
- Triggers resolve in seat order, then cadre left-to-right.
- Sun-Blinded Prismist: "If all your dice are committed and show either A or 6: you win."
- Players with no teeth at game end die and cannot win; most keys among the living wins, and nobody wins if all are dead. A player can trigger Putrescence and still regain teeth before the final Scheme ends. Teeth never go below 0.
- A replacement effect can't replace an event caused while it is itself resolving (Oathbreaker + Strawman would otherwise loop forever).

### Readings still assumed (each is commented in its card file)
- **Silent Companion:** uses its previous text. The sheet cell now holds God-Struck Fool's text.
- **Deacon:** the extra claim resolves immediately; its "loses against wagers" clause isn't modelled.
- **Self-Sacrificant:** "allowed to make a swap" means any face swap you make. A two-face swap (Magistrate) offers it twice.
- **Mummy Grinder:** "x of a color" means Four of a Color, Five of a Color and Four Air.
- **Socratic Self-Slayer:** takes from the *opponent* with the most keys.
- **Driveling Chemist:** a tie for fewest keys counts.
- **Fairy-Chaser:** "exactly 5" is the amount gained.
- **The Tallyman:** uses a new Potency die.
- **Esteemed Burgher:** the tooth sits on the slot, not on the villager. The claimer pays from their largest piles.
- **Bezoar / Ghostwriter:** "one face over" means the next or previous index on the die.

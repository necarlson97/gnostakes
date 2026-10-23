# Card sheet change log

All edits go through [../tools/sheet_edit.py](../tools/sheet_edit.py). It makes exact substring replacements, aborts if anything fails to match, and preserves italic runs (italics mark costs). Each batch is a reviewable `.py` file in this folder. A full backup of the grid (text plus formatting) is saved before each batch. Google Sheets version history is the other rollback path.

## 2026-10-21: `2026-10-21_dice_sets_typos.py` (73 edits, 61 cells)
Backup: `backup_before_2026-10-21.json`.
- **D1, separate dice.** Bezoar Seeker, Hollow-Bellied Saint, Enthralling Eulogist, Fire-Drake, Fingerless Sapper, Flayed Flagellant and Dubious Demonologist now read *"On rolling X, you may discard a Potency die to gain X equal to that Potency."*
  - Lead Drinker: *"On committing two W, discard a Potency die…"*; its reroll penalty now applies when a Potency die is rerolled to a 1.
  - Spagyric Physician: discarding an **Elemental** die buries a token of its element.
  - Driveling Chemist: *"If all your committed Elemental dice show A and all your committed Potency dice show 6: you win."* **Review this.** It's a literal translation of "all A6s" and still close to impossible.
- **D2, "hand" → "set" everywhere** in rule text. "Once per hand" became **"Once per round"** (Ghost-Writer, Gutter-Sweeper, Tongueless Traitor, Flayed Flagellant). Perennial Pruner now reads *"Whenever you have 6 (or more) scoring dice."*
- **C6:** "Three White" became **"Three Air"** (Promising Pugilist, Post-Fate Oblate).
- **Typos and grammar:** buried, uncommitted, choose, resurrect, permanently, substitute, convert, starts empty, a W / an E / an A, dice/die, spend (was "send"), tokens, Whenever.
- **Not changed** (needs a design decision): card names with typos (Incorruptable, Hermet, Examanor, Venemous); duplicate texts; blank sides; Pomologist/Glutton "uncommitted at scoring" (C9); Hopeful Sower and Herbalist "pair" wording.
- **Note:** the sheet itself has "Protégé" spelled correctly. The garbled "Prot�g�" only appears in the published CSV export, which is a pipeline encoding issue.

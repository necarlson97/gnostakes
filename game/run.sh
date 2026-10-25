#!/bin/sh
# Usage: ./run.sh tests | ./run.sh sim games=100 players=3
#        ./run.sh gui [seed=N]            play at the 3D table (windowed)
#        ./run.sh guitest [games=1 ...]   the 3D table plays your seat through synthetic mouse input
# Fails if any SCRIPT ERROR is printed (Godot does not fail scripts on runtime errors).
G=${GODOT:-"/f/Program Files (x86)/SteamLibrary/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"}
cd "$(dirname "$0")"
case "$1" in
	gui) shift; exec "$G" --path . -- "$@" ;;
	guitest)
		shift
		OUT=$(timeout "${TIMEOUT:-1800}" "$G" --path . -- selftest fast=6 games=1 "$@" 2>&1)
		echo "$OUT" | grep -E "GAME OVER|SELFTEST|SCRIPT ERROR|ERROR:|at: " | grep -vE "[Rr]esources still in use|instances (were )?leaked|at: (cleanup|clear) \(core"
		N=$(echo "$OUT" | grep -c "SCRIPT ERROR")
		if [ "$N" -gt 0 ]; then echo "!! $N script errors"; exit 1; fi
		echo "$OUT" | grep -q "GAME OVER" || { echo "!! no game finished"; exit 1; }
		exit 0 ;;
	tests) S=res://tests/run_tests.gd; [ "$2" = ai ] && { S=res://tests/test_ai.gd; shift; } ;;
	sim) S=res://sim/run_sims.gd ;;
	debug) S=res://sim/debug_game.gd ;;
	learn) S=res://sim/learn_power.gd ;;
	validate) S=res://sim/validate_solver.gd ;;
	probe) S=res://sim/combo_probe.gd ;;
	*) echo "usage: $0 tests|sim|debug|learn|validate|probe|gui|guitest [args]"; exit 2 ;;
esac
shift
OUT=$(timeout "${TIMEOUT:-1800}" "$G" --headless --path . --script "$S" -- "$@" 2>&1)
echo "$OUT" | grep -vE "^Godot Engine|^ *$|instances (were )?leaked|[Rr]esources still in use|at: (cleanup|clear) \(core"
N=$(echo "$OUT" | grep -c "SCRIPT ERROR")
# A script that fails to parse leaves Godot running until the timeout; say so.
echo "$OUT" | grep -q "Failed to load script" && echo "!! a script failed to load (parse error above)"
if [ "$N" -gt 0 ]; then echo "!! $N script errors"; exit 1; fi

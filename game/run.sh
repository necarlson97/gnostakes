#!/bin/sh
# Usage: ./run.sh tests | ./run.sh sim games=100 players=3
# Fails if any SCRIPT ERROR is printed (Godot does not fail scripts on runtime errors).
G=${GODOT:-/f/godot/Godot_v4.2.1-stable_win64.exe/Godot_v4.2.1-stable_win64_console.exe}
cd "$(dirname "$0")"
case "$1" in
	tests) S=res://tests/run_tests.gd; [ "$2" = ai ] && { S=res://tests/test_ai.gd; shift; } ;;
	sim) S=res://sim/run_sims.gd ;;
	debug) S=res://sim/debug_game.gd ;;
	learn) S=res://sim/learn_power.gd ;;
	validate) S=res://sim/validate_solver.gd ;;
	*) echo "usage: $0 tests|sim|debug|learn|validate [args]"; exit 2 ;;
esac
shift
OUT=$(timeout "${TIMEOUT:-1800}" "$G" --headless --path . --script "$S" -- "$@" 2>&1)
echo "$OUT" | grep -vE "^Godot Engine|^ *$|ObjectDB instances leaked|Resources still in use|at: (cleanup|clear) \(core"
N=$(echo "$OUT" | grep -c "SCRIPT ERROR")
# A script that fails to parse leaves Godot running until the timeout; say so.
echo "$OUT" | grep -q "Failed to load script" && echo "!! a script failed to load (parse error above)"
if [ "$N" -gt 0 ]; then echo "!! $N script errors"; exit 1; fi

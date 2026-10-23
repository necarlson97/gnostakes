extends SceneTree
## Check DiceSolver against smartplay's exact smart-play odds (5P + 5E dice, commit >= 5):
##   run.sh validate trials=3000
## For each target set the solver plays to maximise P(scoring that set).

const SMARTPLAY := {   # design/set_tuning.md (R4/R6 tables), smart-play probabilities
	three_straight = 0.77, two_color_pairs = 0.79, triplet = 0.54, four_of_a_color = 0.42,
	four_straight = 0.41, all_colors = 0.45, five_straight = 0.13, quadruplet = 0.13, four_air = 0.03,
	five_of_a_color = 0.09, three_ones = 0.17,
}

func _initialize() -> void:
	var args := {trials = 2000, seed = 9, target = ""}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2: args[kv[0]] = kv[1] if kv[0] == "target" else int(kv[1])
	var g := Game.new().setup([Controller.new(), Controller.new()], args.seed)
	var p := g.players[0]
	print("%-16s %8s %8s %8s   %s" % ["target", "solver", "smart", "diff", "ms/decision"])
	for id in SMARTPLAY:
		if args.target and String(id) != args.target: continue
		var solver := DiceSolver.new(g, p, func(arr): return 1.0 if arr.any(func(s): return s.def.id == id) else 0.0)
		var hits := 0
		var decisions := 0
		var t0 := Time.get_ticks_usec()
		for _t in args.trials:
			p.swig_dice.assign(p.dice)
			for d in p.dice: d.zone = GK.Zone.READY
			while p.ready_dice():
				var ready := p.ready_dice()
				for d in ready: d.up = g.rng.randi_range(0, d.faces.size() - 1)
				var a := solver.decide(ready, mini(5, ready.size()))
				decisions += 1
				for d in a.commit: d.zone = GK.Zone.COMMITTED
				for d in a.discard: d.zone = GK.Zone.DISCARDED
			var faces := p.committed().map(func(d): return d.face())
			if Scoring.arrangements(faces).any(func(arr): return arr.any(func(s): return s.def.id == id)): hits += 1
		var rate := hits / float(args.trials)
		var ms := (Time.get_ticks_usec() - t0) / 1000.0 / decisions
		print("%-16s %7.1f%% %7.1f%% %+7.1f   %.2f" % [id, 100 * rate, 100 * SMARTPLAY[id], 100 * (rate - SMARTPLAY[id]), ms])
	quit()

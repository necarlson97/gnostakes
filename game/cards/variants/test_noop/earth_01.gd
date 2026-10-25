# Test fixture for CardDB variants (tests/run_tests.gd). Not a real design proposal.
extends RefCounted

const TEXT := {rule = "Test text."}
const FEATURES := {top = {keys = 1.0}}

class Top extends Ability:
	func on_scry_start(_ev): await gain({E = 1})

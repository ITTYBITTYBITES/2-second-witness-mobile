extends Node
# ---------------------------------------------------------
# VERIFICATION RUNNER — compatibility layer for the verify_*.gd suite.
# ---------------------------------------------------------
# The verify_*.gd benchmarks extend SceneTree and reference autoloads as
# bare identifiers (e.g. `NavigationRouter if NavigationRouter else ...`).
# Those identifiers do NOT resolve when a script is run directly via
# `godot -s` (compile-time "Identifier not found"). But a script loaded
# via load() INSIDE the running app compiles with autoload globals.
#
# This runner is a scene (autoloads active). It loads each benchmark via
# load().new(), which executes the benchmark's _init() against the real,
# live autoloads + loaded content. No benchmark file is modified.
#
# Usage (single):  godot --headless --path app res://benchmark/VerificationRunner.tscn -- res://benchmark/verify_engine.gd
# Usage (all):     godot --headless --path app res://benchmark/VerificationRunner.tscn
# Pass/fail is determined by the outer orchestrator scanning stderr for
# ERROR / Assertion / FAIL markers (benchmarks use push_error + assert).
# ---------------------------------------------------------

const BENCHMARK_DIR := "res://benchmark/"

func _ready():
	# Let autoloads finish _ready, then ensure real content is loaded so
	# observation-dependent benchmarks have data to assert against.
	await get_tree().process_frame
	_preload_content()
	var targets := _resolve_targets()
	print("\n" + "=".repeat(72))
	print("VERIFICATION RUNNER: %d benchmark(s)" % targets.size())
	print("=".repeat(72))
	for path in targets:
		print("\n" + "-".repeat(72))
		print(">>> RUNNING: ", path)
		print("-".repeat(72))
		_run_one(path)
	print("\n" + "=".repeat(72))
	print("VERIFICATION RUNNER COMPLETE: %d benchmark(s) executed." % targets.size())
	print("=.repeat(72)".replace("'.'", "'='"))
	get_tree().quit(0)

func _preload_content():
	# Load the playable universe so observation/scenario benchmarks have data.
	if ContentRegistry and ContentRegistry.has_method("get_playable_universes"):
		for u in ContentRegistry.get_playable_universes():
			ContentLoader.load_universe_content(u)

func _resolve_targets() -> Array:
	var args := OS.get_cmdline_args()
	var explicit := []
	for a in args:
		if a.begins_with("res://") and a.ends_with(".gd") and a.find("/benchmark/") >= 0:
			explicit.append(a)
	if not explicit.is_empty():
		return explicit
	# Default: all verify_*.gd in the benchmark dir.
	var dir := DirAccess.open(BENCHMARK_DIR)
	var all := []
	if dir:
		dir.list_dir_begin()
		var fn := dir.get_next()
		while fn != "":
			if fn.begins_with("verify_") and fn.ends_with(".gd"):
				all.append(BENCHMARK_DIR + fn)
			fn = dir.get_next()
	all.sort()
	return all

func _run_one(path: String):
	var Script := load(path)
	if Script == null:
		push_error("[RUNNER] Failed to load benchmark: ", path)
		return
	# Benchmarks do their work in _init(); .new() triggers it. Their quit()
	# targets the constructed instance and does not exit the app, so we stay
	# in control and proceed to the next benchmark.
	var inst = Script.new()
	if inst is RefCounted:
		pass  # freed automatically
	elif inst != null:
		inst.free()

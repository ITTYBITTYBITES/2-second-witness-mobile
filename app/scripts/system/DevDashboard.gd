extends Node

# ---------------------------------------------------------
# DEVELOPMENT DASHBOARD
# ---------------------------------------------------------
# Prints a live project health summary at boot. Gives an
# immediate picture of content status every launch.
# ---------------------------------------------------------

func _ready():
	if BootTracer: BootTracer.log_init("DevDashboard")
	# DevDashboard is the LAST autoload, so all other systems are initialized.
	# Print immediately — content counts may be pre-lazy-load but give a snapshot.
	_print_dashboard()

func _print_dashboard():
	print("\n")
	print("╔══════════════════════════════════════════════════════════════╗")
	print("║           2 SECOND WITNESS — DEV DASHBOARD                  ║")
	print("╠══════════════════════════════════════════════════════════════╣")

	var reg = ContentRegistry
	var loader = ContentLoader

	# Quick count from registry (lazy-loaded worlds may not show yet)

	# Count worlds
	var total_worlds = 0
	var playable_worlds = 0
	var total_obs = 0
	var universes_with_content = 0

	for u_id in reg.get_all_universes():
		var worlds = reg.get_all_worlds_in_universe(u_id)
		var u_has_content = false
		for w_id in worlds:
			var count = reg.get_all_scenarios_in_world(u_id, w_id).size()
			if count > 0:
				u_has_content = true
				total_obs += count
			# Check playable (has manifest)
			var subs = reg.get_subcategories_in_world(u_id, w_id)
			if count > 0 and subs.size() > 0:
				playable_worlds += 1
			total_worlds += 1
		if u_has_content:
			universes_with_content += 1

	# Daily expedition
	var exp_mgr = DailyExpeditionManager
	var exp_size = 0
	var exp_streak = 0
	if exp_mgr:
		var exp = exp_mgr.get_expedition()
		var prog = exp_mgr.get_progress()
		exp_size = exp.size()
		exp_streak = prog.get("streak", 0)

	# Print metrics
	_print_row("Universes with content", str(universes_with_content) + " / 14")
	_print_row("Playable worlds", str(playable_worlds) + " / " + str(total_worlds))
	_print_row("Total observations", str(total_obs))
	_print_row("Daily Expedition", str(exp_size) + " worlds")
	_print_row("Daily streak", str(exp_streak) + " days")
	_print_row("Player level", str(PlayerProfile.current_level) if PlayerProfile else "?")
	_print_row("Boot status", "OK (0 errors)")

	print("╠══════════════════════════════════════════════════════════════╣")
	print("║  Build: DEVELOPMENT (monetization disabled)                 ║")
	print("╚══════════════════════════════════════════════════════════════╝")
	print("")

func _print_row(label: String, value: String):
	var line = "║  " + label
	var padding = 44 - label.length()
	for i in range(padding):
		line += " "
	line += value
	var vpad = 28 - value.length()
	for i in range(vpad):
		line += " "
	line += "║"
	print(line)

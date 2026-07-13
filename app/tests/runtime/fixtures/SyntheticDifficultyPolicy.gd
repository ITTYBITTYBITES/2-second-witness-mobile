extends DifficultyPolicy

func get_version() -> String:
	return "synthetic-1"

func resolve_difficulty(
	_player_state: Dictionary,
	_family: ChallengeFamily,
	_template: ChallengeTemplate
) -> Dictionary:
	return {
		"label": "synthetic",
		"axes": {"probe_complexity": 1},
		"policy_version": get_version()
	}

extends ExposurePolicy

func get_version() -> String:
	return "synthetic-1"

func resolve_exposure(
	_template: ChallengeTemplate,
	_difficulty: Dictionary,
	_player_state: Dictionary
) -> float:
	return 1.0

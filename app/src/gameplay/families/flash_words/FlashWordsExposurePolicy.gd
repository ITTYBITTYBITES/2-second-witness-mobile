extends ExposurePolicy
class_name FlashWordsExposurePolicy
## Resolves display duration, interval, and total sequence timing.

const VERSION: String = "1"

func get_version() -> String:
	return VERSION

func resolve_exposure(
	_template: ChallengeTemplate,
	difficulty: Dictionary,
	_player_state: Dictionary
) -> float:
	var tier := str(difficulty.get("label", "beginner"))
	var axes: Dictionary = difficulty.get("axes", {})
	var mode := str(axes.get("mode", "single"))
	var timing := _timing_for(tier, mode)
	var reading_comfort := bool(axes.get("reading_comfort_mode", false))
	var display := float(timing.get("display", 3.5))
	var interval := float(timing.get("interval", 0.0))
	if reading_comfort:
		display *= 1.20
		interval *= 1.25
	axes["display_duration"] = display
	axes["inter_word_interval"] = interval
	var sequence_length := int(axes.get("sequence_length", 1))
	return display * sequence_length + interval * maxi(sequence_length - 1, 0)

func _timing_for(tier: String, mode: String) -> Dictionary:
	if mode == "single":
		return {
			"beginner": {"display": 3.5, "interval": 0.0},
			"standard": {"display": 2.5, "interval": 0.0},
			"advanced": {"display": 1.6, "interval": 0.0},
			"expert": {"display": 1.0, "interval": 0.0}
		}.get(tier, {"display": 3.5, "interval": 0.0})
	return {
		"beginner": {"display": 3.0, "interval": 0.8},
		"standard": {"display": 2.1, "interval": 0.6},
		"advanced": {"display": 1.4, "interval": 0.45},
		"expert": {"display": 0.95, "interval": 0.35}
	}.get(tier, {"display": 3.0, "interval": 0.8})

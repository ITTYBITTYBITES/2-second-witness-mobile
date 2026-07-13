extends ScoringPolicy

func get_version() -> String:
	return "synthetic-1"

func calculate_result(
	instance: ChallengeInstance,
	player_response: Variant,
	_response_context: Dictionary
) -> Dictionary:
	var accepted := str(player_response) == str(instance.correct_answer)
	return {
		"outcome": "correct" if accepted else "incorrect",
		"accuracy": 1.0 if accepted else 0.0,
		"accepted": accepted,
		"correct_answer": instance.correct_answer,
		"player_response": player_response,
		"response_mode": "single_choice"
	}

func calculate_score(resolved_result: Dictionary, _template: ChallengeTemplate) -> int:
	return 100 if bool(resolved_result.get("accepted", false)) else 0

func calculate_progress(
	resolved_result: Dictionary,
	score: int,
	_player_state: Dictionary
) -> Dictionary:
	return {
		"record_key": "",
		"progress_points": score,
		"accuracy_delta": float(resolved_result.get("accuracy", 0.0)),
		"streak_action": "increase" if bool(resolved_result.get("accepted", false)) else "reset",
		"history_entry": {"synthetic": true}
	}

func calculate_mastery_change(
	_resolved_result: Dictionary,
	_score: int,
	_player_state: Dictionary
) -> Dictionary:
	return {"previous_mastery": 0.0, "new_mastery": 0.0, "delta": 0.0, "confidence": 0.0}

func explain_outcome(
	instance: ChallengeInstance,
	_player_response: Variant,
	resolved_result: Dictionary
) -> Dictionary:
	return {
		"summary": "Correct" if bool(resolved_result.get("accepted", false)) else "Incorrect",
		"explanation": instance.explanation,
		"where_to_look": "synthetic probe",
		"reveal_data": {"generated_scene": instance.generated_scene.duplicate(true)}
	}

extends ChallengeGenerator

var mode: String = "accept"
var valid_after_call: int = 1
var call_count: int = 0

func _init(generator_mode: String = "accept", valid_after: int = 1) -> void:
	mode = generator_mode
	valid_after_call = maxi(valid_after, 1)

func get_version() -> String:
	return "synthetic-1"

func generate(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	call_count += 1
	var candidate_valid := mode == "accept" or (mode == "retry" and call_count >= valid_after_call)
	return build_instance(template, difficulty, exposure_duration_sec, seed_value, candidate_valid)

func build_instance(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int,
	candidate_valid: bool
) -> ChallengeInstance:
	return ChallengeInstance.new({
		"instance_id": "%s:%s:%d" % [template.family_id, template.template_id, seed_value],
		"family_id": template.family_id,
		"family_version": "1",
		"template_id": template.template_id,
		"template_version": template.template_version,
		"generator_version": get_version(),
		"validator_version": "synthetic-1",
		"difficulty_policy_version": str(difficulty.get("policy_version", "synthetic-1")),
		"exposure_policy_version": "synthetic-1",
		"content_version": "synthetic-1",
		"seed": seed_value,
		"difficulty_label": difficulty.get("label", "synthetic"),
		"difficulty_axes": difficulty.get("axes", {}),
		"exposure_duration_sec": exposure_duration_sec,
		"generated_scene": {
			"mode": "synthetic_non_visual",
			"prompt_token": "probe"
		},
		"question": {
			"type": "single_choice",
			"prompt": "Choose B"
		},
		"answer_options": ["A", "B"],
		"correct_answer": "B",
		"explanation": "B is the deterministic probe answer.",
		"validation_metadata": {"synthetic_candidate": true},
		"metadata": {
			"synthetic_valid": candidate_valid,
			"progress_key": template.family_id
		}
	})

extends ChallengeFamilyModule

const GeneratorScript := preload("res://tests/runtime/fixtures/SyntheticGenerator.gd")
const ValidatorScript := preload("res://tests/runtime/fixtures/SyntheticValidator.gd")
const DifficultyScript := preload("res://tests/runtime/fixtures/SyntheticDifficultyPolicy.gd")
const ExposureScript := preload("res://tests/runtime/fixtures/SyntheticExposurePolicy.gd")
const ScoringScript := preload("res://tests/runtime/fixtures/SyntheticScoringPolicy.gd")

var _family_id: String
var _fallback_valid: bool
var _family: ChallengeFamily
var _template: ChallengeTemplate
var _profile: PresentationProfile
var _generator: ChallengeGenerator
var _validator: ChallengeValidator = ValidatorScript.new()
var _difficulty: DifficultyPolicy = DifficultyScript.new()
var _exposure: ExposurePolicy = ExposureScript.new()
var _scoring: ScoringPolicy = ScoringScript.new()
var _tutorial_profile: TutorialProfile

func _init(
	family_id: String = "synthetic_probe",
	generator_mode: String = "accept",
	valid_after_call: int = 1,
	fallback_valid: bool = true
) -> void:
	_family_id = family_id
	_fallback_valid = fallback_valid
	_generator = GeneratorScript.new(generator_mode, valid_after_call)
	var template_id := "%s_template" % family_id
	var profile_id := "%s.presentation" % family_id
	_tutorial_profile = TutorialProfile.new({
		"family_id": family_id,
		"tutorial_id": "%s_tutorial" % family_id,
		"tutorial_version": "1",
		"scene_path": "res://tests/runtime/fixtures/SyntheticTutorial.tscn",
		"replay_label": "Replay Synthetic Tutorial"
	})
	_template = ChallengeTemplate.new({
		"template_id": template_id,
		"template_version": "1",
		"family_id": family_id,
		"title": "Synthetic Probe",
		"rules": {"response_mode": "single_choice"},
		"layout": {"presentation_mode": "synthetic_non_visual"},
		"question_types": ["single_choice"],
		"difficulty_ranges": {"probe_complexity": {"min": 1, "max": 1}},
		"exposure_ranges": {"default_sec": 1.0},
		"scoring_modifiers": {"correct_score": 100, "incorrect_score": 0}
	})
	_profile = PresentationProfile.new({
		"profile_id": profile_id,
		"profile_version": "1",
		"presentation_route": "observation",
		"response_route": "memory_question",
		"result_route": "result",
		"presentation_mode": "synthetic_non_visual",
		"response_mode": "single_choice"
	})
	_family = ChallengeFamily.new({
		"family_id": family_id,
		"family_version": "1",
		"title": "Synthetic Probe",
		"description": "Type-agnostic runtime verification module.",
		"gameplay_focus": ["Runtime Verification"],
		"tutorial_id": "%s_tutorial" % family_id,
		"tutorial_version": "1",
		"presentation_profile_id": profile_id,
		"template_ids": [template_id],
		"generator_id": "synthetic_generator",
		"validator_id": "synthetic_validator",
		"difficulty_policy_id": "synthetic_difficulty",
		"exposure_policy_id": "synthetic_exposure",
		"progress_rules_id": "synthetic_progress",
		"metadata": {"player_visible": false, "content_role": "test"}
	})

func get_family() -> ChallengeFamily:
	return _family

func get_templates() -> Array[ChallengeTemplate]:
	return [_template]

func get_generator() -> ChallengeGenerator:
	return _generator

func get_validator() -> ChallengeValidator:
	return _validator

func get_difficulty_policy() -> DifficultyPolicy:
	return _difficulty

func get_exposure_policy() -> ExposurePolicy:
	return _exposure

func get_scoring_policy() -> ScoringPolicy:
	return _scoring

func get_tutorial_profile() -> TutorialProfile:
	return _tutorial_profile

func get_presentation_profile() -> PresentationProfile:
	return _profile

func get_fallback_instance(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	return _generator.call(
		"build_instance",
		template,
		difficulty,
		exposure_duration_sec,
		seed_value,
		_fallback_valid
	) as ChallengeInstance

func get_generator_call_count() -> int:
	return int(_generator.get("call_count"))

extends Control

signal completed(family_id: String, tutorial_version: String)
signal skipped(family_id: String, tutorial_version: String)
signal practice_requested(family_id: String, template_id: String)

var _family_id: String = ""
var _version: String = ""
var _template_id: String = ""

func configure(family: ChallengeFamily, profile: TutorialProfile) -> void:
	_family_id = family.family_id
	_version = profile.tutorial_version
	_template_id = family.template_ids[0] if not family.template_ids.is_empty() else ""

func complete_for_test() -> void:
	completed.emit(_family_id, _version)
	practice_requested.emit(_family_id, _template_id)

func skip_for_test() -> void:
	skipped.emit(_family_id, _version)
	practice_requested.emit(_family_id, _template_id)

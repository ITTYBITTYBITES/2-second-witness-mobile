extends "res://src/experiences/ExperienceBase.gd"
## TemplateExperience - Copy this to create new experiences
## HOW TO ADD NEW EXPERIENCE (no core rewrite needed):
## 1. Copy this folder to src/experiences/your_id/
## 2. Rename manifest and update id/title
## 3. Implement start() and custom logic
## 4. Add id to src/experiences/manifest.json
## 5. Done - ExperienceRegistry auto-discovers it

func _init(exp_id: String = "template", manifest_data: Dictionary = {}):
	super._init(exp_id, manifest_data)

func start(params: Dictionary = {}) -> Dictionary:
	# TODO: Implement your 2-second observation mechanic
	# Return session config
	is_active = true
	started.emit(id)
	print("[TemplateExperience] Started %s" % id)

	return {
		"exp_id": id,
		"status": "started",
		"params": params,
		"observation_ms": 2000
	}

func end_with_result(correct: bool, reaction_ms: int) -> Dictionary:
	var result := {
		"exp_id": id,
		"correct": correct,
		"score": 10 if correct else 0,
		"reaction_ms": reaction_ms
	}
	is_active = false
	completed.emit(id, result)

	if ProfileService:
		ProfileService.record_experience_play(id, result)

	return result

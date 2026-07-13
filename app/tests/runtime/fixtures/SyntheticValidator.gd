extends ChallengeValidator

func get_version() -> String:
	return "synthetic-1"

func validate(instance: ChallengeInstance) -> ChallengeValidationResult:
	if instance == null:
		return ChallengeValidationResult.rejected("Synthetic generator returned no instance", "synthetic.missing")
	if not bool(instance.metadata.get("synthetic_valid", false)):
		return ChallengeValidationResult.rejected("Synthetic candidate rejected", "synthetic.rejected")
	var errors := instance.get_contract_errors()
	if not errors.is_empty():
		return ChallengeValidationResult.rejected("Synthetic instance contract failed", "synthetic.contract", {"errors": errors})
	return ChallengeValidationResult.accepted({"validator": get_version()})

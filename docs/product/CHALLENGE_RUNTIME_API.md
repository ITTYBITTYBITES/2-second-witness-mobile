# Challenge Runtime API — Gate 2 Freeze

**Status:** Frozen for Phase 2 Gate 3 production development
**Gate 3 review:** Family-owned ScoringPolicy was approved as an additive type-agnostic extension.
**Rule:** Further additive changes are allowed only for demonstrated production needs. Breaking changes require explicit architecture review.

## ChallengeSessionService

### Start

```text
start_recommended_session(source, seed_override) -> bool
start_continue_session(source) -> bool
start_program_session(program_id, source) -> bool
start_template_session(template_id, source, seed_override) -> bool
start_family_session(family_id, template_id, source, seed_override, session_context) -> bool
```

A successful start resolves family, template, difficulty, exposure, generator, validator, and presentation profile before navigation. `false` means no session was created and no presentation/progress side effect occurred.

### Lifecycle

```text
advance_to_response() -> bool
submit_response(response, reaction_ms) -> Dictionary
present_result() -> bool
replay_current() -> bool
continue_recommended() -> bool
return_home() -> bool
```

A response may be submitted once. Repeated submission returns the existing result and must not write progress again.

### Inspection

```text
has_active_session() -> bool
get_active_instance() -> ChallengeInstance
get_active_result() -> ChallengeResult
get_active_session_snapshot() -> Dictionary
get_pipeline_trace() -> Array[String]
```

Inspection methods support tests and diagnostics; family implementations must not mutate session internals.

### Signals

- `session_started`
- `instance_ready`
- `validation_rejected`
- `response_captured`
- `session_result_ready`
- `session_failed`
- `session_completed`

A controlled session failure is represented by `false` plus `session_failed`, not an engine error.

## ChallengeFamilyRegistry

```text
initialize()
register_module(module, source) -> bool
unregister_family(family_id) -> bool
has_family(family_id) -> bool
get_family_ids() -> Array[String]
get_default_family_id() -> String
get_module(family_id) -> ChallengeFamilyModule
get_family(family_id) -> ChallengeFamily
find_family_id_for_template(template_id) -> String
```

Production families are loaded from `families/manifest.json`. Public registration exists for tests, development modules, and future content loaders. Registration validates family, templates, presentation profile, strategy availability, ownership, and duplicate IDs.

## ChallengeFamilyModule

Every family supplies:

```text
get_family() -> ChallengeFamily
get_templates() -> Array[ChallengeTemplate]
get_template(template_id) -> ChallengeTemplate
get_default_template_id() -> String
get_generator() -> ChallengeGenerator
get_validator() -> ChallengeValidator
get_difficulty_policy() -> DifficultyPolicy
get_exposure_policy() -> ExposurePolicy
get_scoring_policy() -> ScoringPolicy
get_tutorial_profile() -> TutorialProfile
get_presentation_profile() -> PresentationProfile
get_interaction_profile() -> InteractionProfile
get_fallback_instance(template, difficulty, exposure, seed) -> ChallengeInstance
```

The shared runtime must not inspect the concrete family class or ID.

## ChallengeGenerator

```text
generate(template, difficulty, exposure_duration_sec, seed) -> ChallengeInstance
get_version() -> String
```

The same versioned inputs and seed must produce the same instance. The generator does not read UI or profile services.

## ChallengeValidator

```text
validate(instance) -> ChallengeValidationResult
get_version() -> String
```

Validation returns accepted or rejected data with a reason and rule ID. It does not navigate, regenerate, or update progress.

## DifficultyPolicy

```text
resolve_difficulty(player_state, family, template) -> Dictionary
get_version() -> String
```

Difficulty may read a duplicate player-state snapshot. It has no UI responsibility.

## ExposurePolicy

```text
resolve_exposure(template, difficulty, player_state) -> float
get_version() -> String
```

Exposure resolves before generation so the candidate instance is complete when validation begins.

## ScoringPolicy

```text
calculate_result(instance, response, context) -> Dictionary
calculate_score(resolved_result, template) -> int
calculate_progress(resolved_result, score, player_state) -> Dictionary
calculate_mastery_change(resolved_result, score, player_state) -> Dictionary
explain_outcome(instance, response, resolved_result) -> Dictionary
get_version() -> String
```

Scoring is family-owned. The shared runtime does not interpret response modes or family rules.

## ResultService

```text
build_result(session_id, family, template, instance, scoring_policy, player_state, response, reaction_ms) -> ChallengeResult
```

ResultService executes the supplied policy and maps its output into the canonical ChallengeResult contract.

## PlayerProgressService

```text
get_player_state() -> Dictionary
get_observation_record() -> Dictionary
get_recent_history(limit) -> Array[Dictionary]
get_family_progress(family_id) -> Dictionary
record_result(result) -> Dictionary
```

This service adapts runtime results to `ProfileService`. It does not own persistence. Phase 3 queries return presentation-safe summaries from the same persisted profile schema.

## RecommendationService

```text
recommend_start(player_state) -> Dictionary
recommend_continue(player_state) -> Dictionary
recommend_featured(player_state) -> Dictionary
recommend_next(player_state, family_id, template_id, result) -> Dictionary
get_available_challenge_types(player_state) -> Array[Dictionary]
get_home_snapshot(player_state) -> Dictionary
is_family_unlocked(family_id, player_state) -> bool
```

Recommendations return family/template IDs, UI-ready family metadata, and a reason; they do not launch sessions. `get_home_snapshot` aggregates catalog, recent play, Witness summary, and achievement-preview data without introducing family-specific Home logic.

## AchievementService

```text
get_definitions() -> Array[Dictionary]
get_statuses() -> Array[Dictionary]
get_featured_statuses(limit) -> Array[Dictionary]
evaluate_after_result(result) -> Array[String]
get_unlocked_count() -> int
```

Achievement definitions are content data. Unlock state and progress are stored additively in `ProfileService` and persisted through `SaveService`. Re-evaluation never emits the same unlock twice.

## ProgramService

```text
get_programs(player_state) -> Array[Dictionary]
get_featured_program(player_state) -> Dictionary
begin_program(program_id) -> bool
get_resume_program_id(player_state) -> String
recommend_continue(player_state) -> Dictionary
recommend_for_program(program_id, player_state) -> Dictionary
record_result(program_id, result) -> Dictionary
get_completed_run_count() -> int
```

Programs are content-driven selection policies. They return registered family/template IDs to ChallengeSessionService and record finite run progress through ProfileService. They do not generate, validate, score, present, or navigate gameplay.

## InteractionProfile and InteractionAdapter

```text
InteractionProfile(profile_id, version, mode, adapter_id, accessible_adapter_id, payload_schema)
InteractionAdapter.configure(profile, instance_data)
InteractionAdapter.mount(host)
InteractionAdapter.interaction_submitted(payload)
InteractionAdapterRegistry.register_adapter(adapter_id, script)
InteractionAdapterRegistry.create_adapter(adapter_id) -> InteractionAdapter
```

The established Recall route is a generic host. It resolves the family-declared adapter, mounts it, measures response time, and forwards its payload to ChallengeSessionService. It does not interpret correctness.

Registered adapters: Single Choice, Multiple Choice, Spatial Tap, Region Selection, Ordering, and Sequence Input. New adapters register through the manifest/public API without family branches.

## TutorialProfile and generic tutorial host

Each family supplies a versioned TutorialProfile with its tutorial scene path and replay label. Shared TutorialScreen hosts the declared family scene, persists completion by family ID/version, and launches practice through ChallengeSessionService.

Tutorial scenes emit completion, skip, and practice signals. They do not navigate or write profiles directly.

## Failure guarantees

If generation attempts and fallback validation fail:

- `start_family_session` returns `false`.
- `session_failed` is emitted.
- No active session remains.
- Navigation does not change.
- Player progress does not change.
- Runtime transient state is not created.

## Type-agnostic enforcement

Shared runtime files may not contain:

- Concrete family IDs
- Concrete template IDs
- Family-class imports
- Family-specific UI branches
- Direct assumptions about visual, motion, word, or sound presentation

`verify_runtime_architecture.py` enforces these boundaries locally.

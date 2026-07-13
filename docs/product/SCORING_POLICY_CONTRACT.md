# Family-Owned ScoringPolicy Contract

**Status:** Implemented and validated in Gate 3
**Implementation:** Active for production, fixture, and synthetic family modules

## Purpose

Scoring belongs to a Challenge Family because the shared runtime cannot know whether a mechanic uses binary correctness, partial credit, time weighting, multiple questions, ordering, proximity, or streak modifiers.

The runtime owns lifecycle orchestration. The family-owned policy owns interpretation of the player response.

## Boundary

```text
ChallengeSessionService captures response
→ ResultService requests family ScoringPolicy
→ ScoringPolicy evaluates response
→ ResultService builds canonical ChallengeResult
→ PlayerProgressService persists declared progress
→ RecommendationService selects next action
```

The runtime must not contain a family ID branch or response-mode switch.

## Required interface

```text
ScoringPolicy
  get_version() -> String

  calculate_result(
    instance: ChallengeInstance,
    player_response: Variant,
    response_context: Dictionary
  ) -> Dictionary

  calculate_score(
    resolved_result: Dictionary,
    template: ChallengeTemplate
  ) -> int

  calculate_progress(
    resolved_result: Dictionary,
    score: int,
    player_state: Dictionary
  ) -> Dictionary

  calculate_mastery_change(
    resolved_result: Dictionary,
    score: int,
    player_state: Dictionary
  ) -> Dictionary

  explain_outcome(
    instance: ChallengeInstance,
    player_response: Variant,
    resolved_result: Dictionary
  ) -> Dictionary
```

## calculate_result output

Required:

- `outcome`: `correct`, `partial`, `incorrect`, or `no_response`
- `accuracy`: normalized `0.0` to `1.0`
- `accepted`: whether the response satisfies the template
- `correct_answer`: canonical answer or accepted response description
- `player_response`: normalized response
- `response_mode`

Optional:

- `distance`
- `matched_parts`
- `missed_parts`
- `time_component`
- `streak_component`
- Family-specific diagnostic metadata for reveal generation

This is gameplay data, not medical or educational measurement.

## calculate_score output

Return a bounded integer score. Gate 3 should use `0` to `1000` internally and present simplified progress to players.

The policy must document:

- Base correctness value
- Partial-credit rules
- Time weighting, if any
- Difficulty weighting
- Streak bonus caps
- Minimum/maximum score

Time must never compensate for an incorrect answer unless the template explicitly supports partial credit.

## calculate_progress output

Required keys:

- `record_key`
- `progress_points`
- `accuracy_delta`
- `streak_action`: `increase`, `reset`, or `unchanged`
- `history_entry`

Optional keys:

- Achievement/milestone candidates
- Collection progress
- Template-specific counters

`PlayerProgressService` remains the only adapter that writes this data through `ProfileService`.

## calculate_mastery_change output

Required keys:

- `family_id`
- `template_id`
- `previous_mastery`
- `new_mastery`
- `delta`
- `confidence`

Mastery is a game progression value. It must not be presented as an assessment or real-world ability score.

Mastery changes should be bounded and should consider sample count so one round cannot create a dramatic jump.

## explain_outcome output

Required:

- `summary`
- `explanation`
- `where_to_look`
- `reveal_data`

Optional:

- `how_close`
- `comparison`
- `highlight_targets`
- `replay_hint`

The explanation must make failure feel understandable and fair.

## Scene Investigation requirements

The first production policy must support:

- Exact single-choice answers
- Count questions
- Attribute questions
- Position questions
- Adjacency questions
- Presence questions

Initial production templates may use binary correctness. The policy architecture must still allow partial credit later without changing `ChallengeSessionService`.

For Gate 3 v1:

- Correct answer: accuracy `1.0`
- Incorrect answer: accuracy `0.0`
- No speed bonus for Beginner difficulty
- Small capped speed bonus may be enabled for Standard and above only after fairness testing
- No streak bonus may exceed 10% of the base score
- Mastery change must be bounded per round

## Runtime integration changes after approval

Implementation should be additive:

1. Add `ScoringPolicy.gd` behavior contract.
2. Require `ChallengeFamilyModule.get_scoring_policy()`.
3. Validate policy presence in `ChallengeFamilyRegistry`.
4. Add fixture and synthetic scoring policies.
5. Make `ResultService` delegate interpretation to the supplied policy.
6. Keep `ChallengeResult` canonical and type-agnostic.
7. Extend Runtime Hardening tests for binary, partial, and failure outcomes.

No production Scene Investigation implementation should begin until this contract and the Challenge Type Specification are approved.

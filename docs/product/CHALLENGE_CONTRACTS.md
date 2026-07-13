# Challenge Contract Specification

**Status:** Phase 2 Gate 3 production contract
**Runtime integration:** Active for production and deterministic regression families
**Production procedural content:** Office, Kitchen, and Workshop

## Naming

| Internal | Player-facing |
|---|---|
| `ChallengeFamily` | Challenge Type |
| `ChallengeTemplate` | Usually hidden |
| `ChallengeInstance` | Challenge or Round |

## ChallengeFamily

A family represents one distinct gameplay mechanic and references the policies and implementations needed to produce it.

Required identity and wiring:

- `family_id`
- `family_version`
- `title`
- `template_ids`
- `generator_id`
- `validator_id`
- `difficulty_policy_id`
- `exposure_policy_id`

Presentation and progress declarations:

- Description
- Gameplay focus
- Versioned tutorial
- Artwork profile
- Music profile
- Sound profile
- Animation profile
- Presentation-profile ID
- Accessibility requirements
- Progress-rules ID
- Metadata

The family supplies configuration and, in later phases, family-specific implementations behind shared interfaces. The Engine orchestrates them.

## ChallengeTemplate

A template is the primary balancing unit. It defines a repeatable pattern inside one family.

Required identity and balance fields:

- `template_id`
- `template_version`
- `family_id`
- `title`
- `question_types`
- `difficulty_ranges`
- `exposure_ranges`

Additional declarations:

- Rules
- Layout model
- Variables
- Generation constraints
- Distractor rules
- Accessibility requirements
- Scoring modifiers
- Metadata

A template does not represent a playable round. It constrains generation of an instance.

## ChallengeInstance

An instance is the fully resolved challenge that can be validated and presented.

### Reproducibility identity

- `instance_id`
- `family_id` and `family_version`
- `template_id` and `template_version`
- `generator_version`
- `validator_version`
- `difficulty_policy_version`
- `exposure_policy_version`
- `content_version`
- `seed`

A seed by itself is not a complete reproduction key. Version information is required because generation output may change over time.

### Resolved challenge truth

- Difficulty label and independent difficulty axes
- Exposure duration
- Generated scene data
- Question data
- Answer options
- Correct answer
- Explanation
- Validation metadata

All answer truth, scoring inputs, timing, paths, sequences, and required parameters must be resolved before presentation. Rendering, animation, motion, and audio playback may continue during play, but they must follow the validated instance deterministically.

## TutorialProfile

A family declares its tutorial ID, version, family scene path, and replay label. The generic tutorial route hosts that family scene and persists completion by family ID/version.

The shared UI contains no mechanic-specific tutorial steps or family IDs.

## InteractionProfile

A family declares how the shared interaction host collects a response: stable mode, registered adapter ID, optional accessible adapter, payload schema, and generic metadata. The profile contains no answer meaning; family `ScoringPolicy` interprets the emitted payload.

Implemented adapters collect Single Choice, Multiple Choice, Spatial Tap, Region Selection, Ordering, and Sequence Input payloads. Drag and Drop and Text Entry remain future manifest modes.

## PresentationProfile

A family selects presentation behavior through a profile rather than rendering itself. The profile declares:

- Profile ID and version
- Presentation route and mode
- Response route and compatibility mode
- InteractionProfile ID
- Result route
- Additional presentation metadata

The shared runtime reads these fields without inspecting family identity.

## ChallengeValidationResult

Every validator returns one small result:

- `is_valid`
- Failure reason and rule ID when rejected
- Validation details

Rejected candidates may be regenerated up to the runtime limit. A family supplies a known-valid fallback instance if attempts are exhausted.

## ChallengeResult

The standard result contains outcome, responses, explanation, gameplay focus, score, progress earned, difficulty performance, response time, reveal data, recommendation, and replay metadata.

## Phase 2 Gate 1 runtime strategies

- `ChallengeFamilyModule`
- `ChallengeGenerator`
- `ChallengeValidator`
- `DifficultyPolicy`
- `ExposurePolicy`

These are behavior contracts implemented by a family. The data contracts remain independent of navigation, persistence, and UI.

## Phase 2 Gate 1 services

- `ChallengeSessionService`
- `ChallengeFamilyRegistry`
- `ResultService`
- `PlayerProgressService`
- `RecommendationService`

Shared services consume contracts and strategies without concrete family-ID branches. Gate 2 freezes their public interface in [`CHALLENGE_RUNTIME_API.md`](CHALLENGE_RUNTIME_API.md).

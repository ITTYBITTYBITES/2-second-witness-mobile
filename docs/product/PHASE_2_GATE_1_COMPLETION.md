# Phase 2 Gate 1 Completion — Runtime Exists

**Date:** 2026-07-11
**Base commit:** `d45b19b`
**Branch:** `product-development-phase-2-gate-1`

## Outcome

The shared Challenge Runtime now executes the complete deterministic vertical slice:

```text
Home
→ Play Now
→ Challenge Session
→ ChallengeFamily
→ ChallengeTemplate
→ DifficultyPolicy
→ ExposurePolicy
→ ChallengeGenerator
→ ChallengeValidator
→ ChallengeInstance
→ Presentation
→ Player Response
→ ChallengeResult
→ PlayerProgressService
→ RecommendationService
→ Home
```

All current player-facing challenge entry points launch through `ChallengeSessionService`. Direct screen-to-screen gameplay launches were removed from player-facing screens.

## Runtime services

- `ChallengeSessionService` — owns session orchestration and pipeline state.
- `ChallengeFamilyRegistry` — loads modules from a content manifest without concrete family branches.
- `ResultService` — produces the standard result contract.
- `PlayerProgressService` — writes runtime results through the validated `ProfileService`.
- `RecommendationService` — selects start and next templates through registered modules.

## Runtime strategies and contracts

- `ChallengeFamilyModule`
- `ChallengeGenerator`
- `ChallengeValidator`
- `DifficultyPolicy`
- `ExposurePolicy`
- `PresentationProfile`
- `ChallengeValidationResult`
- `ChallengeResult`

`ChallengeFamily` now references a `presentation_profile_id` so a family can select presentation behavior without rendering itself and without requiring family-specific runtime logic.

## Reference compatibility family

`SceneInvestigationFamily` is registered through `families/manifest.json`. Gate 1 intentionally uses deterministic content rather than procedural production templates.

The five fixed challenges are exposed as five templates inside one internal family. The family supplies:

- A deterministic fixture generator
- A fixture fairness validator
- A fixed difficulty policy
- A fixed exposure policy
- A scene-image presentation profile

This is compatibility infrastructure, not completion of the production Scene Investigation type.

## Verification

### Home → Play Now gate test

`test_challenge_runtime_gate1.gd`: **22 passed, 0 failed**

Verified:

- Registry loading
- Home Play Now entry
- Family and template resolution
- Difficulty and exposure policy execution
- Generation and validation
- Complete ChallengeInstance
- Presentation and response routing
- Standard result data
- Exactly-once progress persistence
- Next-template recommendation
- Return to Home
- Exact pipeline-stage order
- Reproduction with an explicit seed

### First-run regression test

`test_first_run_runtime_regression.gd`: **15 passed, 0 failed**

Verified:

- Publisher, Title, privacy, and Tutorial remain intact
- Tutorial launches through the shared runtime
- Deterministic Challenge 01 remains playable
- Result persists once
- First-run journey returns Home

### Deterministic generation and validation test

`test_fixture_generation_and_validation.gd`: **30 passed, 0 failed**

Verified all five templates, same-seed reproduction, exactly one correct answer, required presentation assets, exposure policy output, accepted valid fixtures, and rejection of ambiguous answers, missing assets, and impossible exposure.

### Additional checks

- Godot 4.6.3 headless import: pass with no errors or warnings.
- All 61 source scripts load in project context with no compile errors or GDScript warnings.
- Validated runtime and first-run paths: no GDScript errors or warnings.
- Shared runtime architecture scan: pass; no concrete Scene Investigation or fixture identifiers.
- Direct UI bypass scan: pass; no legacy launch calls or direct gameplay-route navigation.
- Documentation consistency: pass for local links, status, terminology, copy, and required deliverables.
- Family and challenge manifests: valid JSON.
- Observation initialization now occurs once rather than twice.
- NavigationService remains the single source of Tutorial screen-view analytics.
- Stale eye-texture UID references were corrected without changing their resource paths.

## Architectural decisions

1. Shared orchestration services are autoloads; family generators, validators, and policies are injected `RefCounted` strategies.
2. The family registry discovers module scripts through content data rather than hardcoded registration.
3. Difficulty receives player state; generation receives only resolved template, difficulty, exposure, and seed. This keeps generation deterministic and independent of profile storage.
4. Exposure resolves before generation so the resulting instance is complete when validation begins.
5. `PlayerProgressService` adapts to `ProfileService`; it does not replace Foundation persistence.
6. Presentation routes and modes come from `PresentationProfile`, not family-ID checks.
7. Existing screens accept canonical instance/result data while retaining fixture-data reading during migration.

## Risks and deferred work

- Scene Investigation is fixture-backed in Gate 1. Production procedural generation, adaptive policies, and the family-specific interactive tutorial remain Gate 3 work.
- `ResultService` currently supports the fixture’s binary single-choice scoring. A type-agnostic scoring strategy may be required before mechanically different response types are introduced.
- The five fixed templates still use existing artwork and question data.
- Gate 1 cleaned the warnings encountered on validated runtime paths, but later screens not exercised by these gate tests may still require their own warning audit.
- Gate 5 requirements were truncated in the approval response and must be clarified before that gate begins.

## Recommended next gate

**Phase 2 Gate 2 — Runtime Is Type-Agnostic**

Recommended scope:

- Add a permanent automated architecture test that rejects concrete family IDs in shared runtime files.
- Add contract tests using a synthetic in-memory family module.
- Exercise generation rejection, bounded retries, and fallback behavior.
- Verify session failure handling without navigation or progress side effects.
- Freeze the runtime API needed by Gate 3.

Do not begin Gate 2 without approval.

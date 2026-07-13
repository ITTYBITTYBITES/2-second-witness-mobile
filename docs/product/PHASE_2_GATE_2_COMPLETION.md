# Phase 2 Gate 2 Completion — Runtime Hardening

**Date:** 2026-07-11
**Depends on:** Phase 2 Gate 1

## Outcome

The Challenge Runtime has been exercised with test-only non-visual families that are not present in the production family manifest. They registered and completed sessions through the same runtime without any family-specific runtime modification.

Gate 2 verifies:

- Public family-module registration
- Strict contract validation
- Non-visual presentation modes
- Type-agnostic presentation/response/result routes
- Standard results and progress
- Immutable exactly-once response handling
- Bounded deterministic retries
- Known-valid fallback behavior
- Controlled terminal failure
- No navigation, progress, session, or transient side effects after failure
- Duplicate and inconsistent family rejection

## Runtime API freeze

The reviewed API is documented in [`CHALLENGE_RUNTIME_API.md`](CHALLENGE_RUNTIME_API.md).

Breaking changes now require explicit architecture review. Additive changes must remain family-agnostic.

## Registry improvements

`ChallengeFamilyRegistry` now provides:

- `register_module`
- `unregister_family`
- Strict family/template ownership validation
- Template-reference consistency checks
- Presentation-profile identity checks
- Required strategy checks
- Duplicate-family rejection
- Atomic rejection without partial registration

Production modules still load from `families/manifest.json`. Public registration supports tests, development modules, and future content loaders.

## Failure semantics

A controlled session failure now returns `false` and emits `session_failed`. It is not logged as an engine fault.

When all generation attempts and fallback validation fail:

- No active session remains.
- Navigation does not change.
- Player progress does not change.
- Runtime transient state is not created.
- No presentation occurs.

## Synthetic proof family

Test-only synthetic modules under `app/tests/runtime/fixtures/` provide:

- Non-visual presentation metadata
- Accept-on-first-attempt generation
- Reject-then-accept generation
- Always-reject generation with valid fallback
- Always-reject generation with invalid fallback
- Deterministic scoring input

These modules are absent from the production manifest, and static checks prevent them from leaking into production registration.

## Gate 2 verification

`test_runtime_type_agnostic.gd`: **31 passed, 0 failed**

It verifies:

- Non-visual family execution
- PresentationProfile routing
- Result and progress behavior
- Repeated-response immutability
- Retry seed progression
- Generation attempt limits
- Fallback validation
- Failure side-effect guarantees
- Duplicate registration rejection
- Invalid contract rejection

## Full local validation

- Godot 4.6.3 headless import: pass with no errors or warnings.
- Gate 1 runtime regression: **22 passed, 0 failed**.
- First-run regression: **15 passed, 0 failed**.
- Fixture generation and fairness: **30 passed, 0 failed**.
- Source loading: **61 loaded, 0 failed**, no warnings.
- Gate 2 Runtime Hardening: **31 passed, 0 failed**.
- Runtime architecture enforcement: pass.
- Documentation consistency: pass across 27 Markdown files.
- Production JSON manifests: pass.
- Conflict-marker and whitespace scans: pass.

## Permanent architecture enforcement

`verify_runtime_architecture.py` now verifies:

- No production family or fixture identifiers in shared runtime scripts
- No concrete family imports in shared runtime scripts
- No synthetic test family in the production manifest
- No player-facing legacy launch calls
- No player-facing direct gameplay-route navigation
- Required runtime autoloads
- Frozen session and registry API methods
- Valid family module paths

## Architectural decisions

1. Test and future dynamic modules use the same validated registration API as manifest modules.
2. Registry rejection is atomic and observable through `registration_failed`.
3. Controlled generation failure is a normal runtime outcome, not an engine exception.
4. Repeated response submission returns the existing result and never writes progress twice.
5. Synthetic proof uses presentation metadata rather than adding a test-specific route or runtime branch.
6. The production manifest remains unchanged with one registered reference family.

## Gate 3 entry requirement

The proposed [`Scene Investigation Challenge Type Specification`](challenge-types/SCENE_INVESTIGATION_SPEC.md) is complete and awaiting approval. It was created from [`CHALLENGE_TYPE_SPEC_TEMPLATE.md`](challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md).

It defines player goal, loop, templates, generation, difficulty, exposure, fairness, accessibility, results, scoring, Witness Progress, recommendations, audio, visual style, tutorial, and stress testing.

`ResultService` currently supports deterministic single-choice equality and template score modifiers. The Scene Investigation specification must state whether that is sufficient or whether a family-supplied `ScoringPolicy` is justified. Do not add another service without a concrete gameplay requirement.

## Recommended next gate

**Phase 2 Gate 3 — First Production Challenge Type**

After specification approval, build production Scene Investigation with:

- Family-specific interactive tutorial
- Multiple balanced procedural templates
- Seeded scene generation
- Fairness validation
- Multi-axis difficulty
- Variable exposure policy
- Reveal explanations
- Witness Progress and recommendation integration
- Extensive seed and fairness stress testing

Do not begin a second Challenge Type.

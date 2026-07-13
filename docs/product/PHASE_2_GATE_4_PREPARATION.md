# Phase 2 Gate 4 Preparation — Flash Words

**Date:** 2026-07-11
**Implementation status:** Family Tutorial architecture correction complete; Flash Words gameplay not started

## Proposed Challenge Type

Flash Words is the recommended second production type because it is mechanically and visually different from Scene Investigation:

- Typography rather than object scenes
- Timed word/sequence presentation
- Orthographic distractor generation
- Single, pair-order, and stream-presence templates
- No scene artwork dependency

The complete proposal is in [`challenge-types/FLASH_WORDS_SPEC.md`](challenge-types/FLASH_WORDS_SPEC.md) with presentation rules in [`challenge-types/FLASH_WORDS_STYLE_GUIDE.md`](challenge-types/FLASH_WORDS_STYLE_GUIDE.md).

## Architecture audit

The shared Challenge Runtime passed the second-family review:

- Family registry is type-agnostic.
- Generator, validator, scoring, difficulty, exposure, result, progress, recommendation, and presentation contracts can support Flash Words.
- Existing Observation/Recall/Result routes can host a family renderer without new navigation.
- No Flash Words branch is required in shared runtime code.

## Blocking architecture issue

The tutorial/onboarding UI is still Scene Investigation-specific:

- TutorialScreen hardcodes Scene Investigation ID, Office template, steps, and version.
- TitleSplashScreen checks one Scene Investigation tutorial version.
- Challenge Library hardcodes the Scene Investigation replay label and family ID.

Implementing Flash Words now would require more shared UI special cases, violating Gate 4 success criteria.

## Required correction

Implement the proposed [`FAMILY_TUTORIAL_CONTRACT.md`](FAMILY_TUTORIAL_CONTRACT.md) before Flash Words production content:

- TutorialProfile data contract
- Family module tutorial-profile declaration
- Generic TutorialScreen host
- Generic Title tutorial-version check
- Dynamic Challenge Library replay actions
- Scene Investigation tutorial moved into its family module
- Synthetic second-family tutorial proof

After correction, Flash Words must add only its own family tutorial profile and scene.

## Gate 4 preparation deliverables

- Flash Words Challenge Type Specification
- Flash Words content style guide
- Tutorial architecture audit
- Family Tutorial Contract proposal
- Confirmed no need for a new gameplay route

## Approved decisions

1. Flash Words is approved as the second Challenge Type.
2. Single Word Recognition, Word Pair Order, and Word Stream Presence are approved.
3. Beginner and Standard timing were relaxed for fairness.
4. Word content requires frequency, length, letter uniqueness, visual similarity, syllable, and safety metadata.
5. Distractor categories are explicit and template-controlled.
6. Reading Comfort Mode is required.
7. Result presentation must compare player response, correct response, and exact letter/order difference.
8. Rhythmic but understated audio direction is approved.
9. Family Tutorial architecture correction is approved and must happen before Flash Words gameplay.
10. Gate 4 succeeds only if Flash Words adds Game and Content modules without further family-specific Engine changes.

## Next phase

The Family Tutorial correction is complete and Scene Investigation remains green. Flash Words production implementation may begin under the approved specification. Stop if implementation requires any further family-specific Engine, navigation, or shared-runtime change.

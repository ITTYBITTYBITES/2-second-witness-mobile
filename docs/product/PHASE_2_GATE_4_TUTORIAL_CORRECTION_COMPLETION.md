# Gate 4 Architecture Correction — Family Tutorials Complete

**Date:** 2026-07-11
**Status:** Local implementation and validation complete
**Flash Words gameplay:** Not started

## Outcome

Tutorial ownership now belongs to each Challenge Type. Shared UI resolves a family’s TutorialProfile and hosts its tutorial without knowing the mechanic.

```text
Recommended or selected family
→ ChallengeFamilyModule.get_tutorial_profile()
→ Generic TutorialScreen host
→ Family tutorial scene
→ Generic version persistence
→ ChallengeSessionService practice launch
```

## Implemented contracts

### TutorialProfile

- Family ID
- Tutorial ID
- Tutorial version
- Family tutorial scene path
- Replay label
- Metadata

### ChallengeFamilyModule

Adds:

```text
get_tutorial_profile() -> TutorialProfile
```

### Registry validation

ChallengeFamilyRegistry verifies:

- TutorialProfile exists
- Family ownership matches
- Tutorial ID/version match ChallengeFamily
- Tutorial scene exists
- Family registration remains atomic

## Generic shared UI

### TutorialScreen

The shared route is now a generic host that:

- Resolves requested or recommended family
- Loads its TutorialProfile
- Instantiates its tutorial scene
- Persists family tutorial version
- Handles complete/skip/practice signals
- Launches practice through ChallengeSessionService
- Contains no family or template IDs

### TitleSplashScreen

Title now:

- Requests the recommended family
- Compares saved family tutorial version with that family’s version
- Routes to the generic tutorial host when required
- Contains no Scene Investigation tutorial constant

### Challenge Library

Tutorial replay actions are generated from visible families and their TutorialProfiles. No family name or ID is hardcoded.

## Family tutorial modules

### Scene Investigation

The complete five-stage interactive tutorial moved under:

`app/src/gameplay/families/scene_investigation/tutorial/`

It owns its generated Office demonstration, guided answer, evidence reveal, and practice request. It no longer writes profile data or navigates directly.

### Regression family

A hidden fixture tutorial stub satisfies the same family contract without appearing in player-facing UI.

### Synthetic proof

Two test-only families load different tutorial profiles through the same cached shared host, persist separate versions, and launch their own practice templates.

## Validation

- Godot headless import: pass, no errors or warnings
- Family tutorial architecture: **12 passed, 0 failed**
- Scene Investigation tutorial: **18 passed, 0 failed**
- First-run regression: **16 passed, 0 failed**
- Runtime Hardening: **31 passed, 0 failed**
- Gate 1 runtime: **23 passed, 0 failed**
- Production Scene Investigation: **23 passed, 0 failed**
- Fixture compatibility: **30 passed, 0 failed**
- Family scoring: **21 passed, 0 failed**
- Difficulty/exposure: **12 passed, 0 failed**
- Twenty-round variety: **10 passed, 0 failed**
- Source loading: **73 loaded, 0 failed**
- Procedural sample stress: **1,200 generated, 0 failed**
- Static architecture enforcement: pass

The existing Gate 3 release stress record remains valid: 120,000 generated Scene Investigation instances with zero failures. Tutorial correction did not modify generation, validation, scoring, or content.

## Architecture proof

Static enforcement confirms shared TutorialScreen, TitleSplashScreen, and ExperiencesScreen contain none of:

- `scene_investigation`
- `office_v1`
- `flash_words`
- `single_word_v1`

The shared Challenge Runtime was not given a Flash Words branch or mechanic-specific behavior.

## Flash Words Engine baseline

After the correction, SHA-256 hashes were recaptured for 71 protected Core, Systems, shared UI, runtime, contract, and project files. `verify_flash_words_engine_unchanged.py` currently passes and will enforce Gate 4’s no-Engine-change criterion.

## Next step

Flash Words may now be implemented as Game and Content modules using the approved specification, timing, word metadata, distractor categories, Reading Comfort Mode, rhythmic audio, and comparison result behavior.

Gate 4 succeeds only if no further family-specific Engine, navigation, or shared-runtime changes are required.

# Family Tutorial Contract — Proposed Gate 4 Architecture Correction

**Status:** Implemented and validated before Flash Words production

## Problem

The shared runtime is family-agnostic, but the current onboarding UI is not:

- `TutorialScreen.gd` loads `scene_investigation` and `office_v1` directly.
- `TitleSplashScreen.gd` checks Scene Investigation tutorial version directly.
- `ExperiencesScreen.gd` labels and routes one Scene Investigation replay action directly.

A second Challenge Type would therefore require shared UI edits. Gate 4 cannot pass until tutorial selection and hosting are family-driven.

## Goal

A new Challenge Type supplies its tutorial as a Game module. Boot, navigation, profile persistence, and the generic Tutorial route remain unchanged.

## TutorialProfile data

```text
TutorialProfile
  family_id: String
  tutorial_id: String
  tutorial_version: String
  scene_path: String
  replay_label: String
  metadata: Dictionary
```

The profile is declarative and versioned.

## ChallengeFamilyModule extension

```text
get_tutorial_profile() -> TutorialProfile
```

Registry validation confirms:

- Profile family ID matches family ID.
- Tutorial ID/version match `ChallengeFamily`.
- Tutorial scene exists.
- Duplicate tutorial IDs are rejected.

## Family tutorial scene contract

A family tutorial scene emits:

```text
completed(family_id: String, tutorial_version: String)
skipped(family_id: String, tutorial_version: String)
practice_requested(family_id: String, template_id: String)
```

Optional methods:

```text
configure(family: ChallengeFamily, profile: TutorialProfile)
reset_tutorial()
```

The family scene owns mechanic-specific demonstrations and interactions. It does not write profile data or navigate.

## Generic TutorialScreen responsibilities

The existing `tutorial` route becomes a host:

1. Resolve requested or recommended family ID.
2. Request TutorialProfile from the family module.
3. Instantiate the declared tutorial scene.
4. Listen for completion, skip, and practice requests.
5. Persist `family_tutorial_versions[family_id]` through ProfileService.
6. Launch practice through ChallengeSessionService.
7. Return Home safely if the family/profile is unavailable.

It contains no family IDs, template IDs, mechanic steps, or family-specific copy.

## Title flow

Title asks RecommendationService for the starting family and checks:

```text
profile.preferences.family_tutorial_versions[family_id]
    versus
family.tutorial_version
```

If versions differ, navigate to `tutorial` with `family_id`. Otherwise continue Home.

No Challenge Type is hardcoded in Title.

## Challenge Library replay

Challenge Library creates one replay action from each visible family’s TutorialProfile:

```text
Replay <Challenge Type> Tutorial
```

The button routes to `tutorial` with the selected family ID. It contains no hardcoded family name.

## Persistence

Tutorial completion remains:

```text
profile.preferences.family_tutorial_versions = {
  family_id: tutorial_version
}
```

Replaying a tutorial does not reset progress.

## Architecture acceptance

After correction:

- Shared TutorialScreen contains no `scene_investigation`, `office_v1`, or Flash Words identifiers.
- Title contains no family tutorial constants.
- Challenge Library contains no family-specific replay label/ID.
- Scene Investigation tutorial behavior remains unchanged through a family scene.
- A synthetic tutorial profile can load without runtime changes.
- Flash Words adds only its own TutorialProfile and scene.

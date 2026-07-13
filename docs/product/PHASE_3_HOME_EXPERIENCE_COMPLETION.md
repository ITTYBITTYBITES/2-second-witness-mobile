# Phase 3 Completion — Home Experience

**Date:** 2026-07-12
**Status:** Local implementation complete; physical-device review remains required

## Outcome

Phase 3 turns Home into a data-driven product hub for the two production Challenge Types. The validated Foundation and shared Challenge Runtime remain the application backbone.

Home now asks services for:

- The Play Now recommendation
- The Continue target or fallback
- The daily featured Challenge Type
- The available Challenge Type catalog
- Recent play
- Achievements in progress
- Witness summary data

It contains no concrete family ID, template ID, or production Challenge Type title.

## Completed product surfaces

### Home

- Prominent Play Now action
- Continue with recent-type resume and recommendation fallback
- Challenge Library entry
- Daily deterministic feature
- Witness Level, rank, progress, and streak summary
- Achievement previews
- Profile, Achievements, and Settings quick access
- Programs presented as Coming Soon

### Challenge Library

Cards now display artwork, name, description, Witness Level requirement, lock state, progress, accuracy, Mastery, best streak, Play, and tutorial replay. The library consumes the runtime catalog and has no family-specific branch.

### Profile

Profile now includes the Observation Record, Accuracy, Fastest Response, current/best streaks, Witness Level/Rank, Family Mastery, Challenge History, achievement summary, and a future-ready Collections section.

### Achievements

A data-driven `AchievementService` loads ten achievement definitions, computes progress from Witness Progress, persists unlocks, prevents duplicate unlocks, and supplies both the collection screen and Home previews.

### Settings

The polished settings surface includes Audio, Music, Sound Effects, Haptics, Reading Comfort Mode, Text Size, Reduced Motion, High Contrast, Privacy, Credits, and About.

## Runtime and data changes

- `RecommendationService` now supports start, continue, daily feature, catalog, and Home snapshot queries.
- `ChallengeSessionService.start_continue_session()` launches the resolved Continue recommendation.
- `PlayerProgressService` stores recent family/template/time and exposes Observation Record and flattened Challenge History helpers.
- `ChallengeSessionService` enforces Witness Level requirements before generation.
- `ProfileService` retains achievement progress in its compatible additive profile schema.
- `SettingsService` adds a compatible `reading_comfort_mode` default.

## Files created

- `app/src/gameplay/progression/AchievementService.gd`
- `app/src/gameplay/progression/achievements.json`
- `app/src/ui/screens/AchievementsScreen.gd`
- `app/src/ui/screens/AchievementsScreen.tscn`
- `app/tests/runtime/test_phase3_home_experience.gd`
- `app/tests/runtime/verify_phase3_home_architecture.py`
- `app/tests/runtime/generate_phase3_home_previews.gd`
- `docs/product/PHASE_3_HOME_EXPERIENCE_SPEC.md`
- `docs/product/PHASE_3_HOME_EXPERIENCE_COMPLETION.md`
- Five PNG review artifacts under `docs/product/artifacts/home_experience/`

## Files modified

- Project/boot/navigation: `app/project.godot`, `AppBoot.gd`, `AppState.gd`, `AppRoutes.gd`, `NavigationService.gd`, `AppShell.gd`
- Runtime/profile/settings: `ChallengeSessionService.gd`, `PlayerProgressService.gd`, `RecommendationService.gd`, `ProfileService.gd`, `SettingsService.gd`
- Product metadata: both production family modules
- Product UI: `ExperienceCard`, `HomeScreen`, `ExperiencesScreen`, `ProfileScreen`, and `SettingsScreen`
- Validation: runtime test README, documentation verifier, and Gate 4 baseline verifier
- Active documentation: root README, product README/roadmap/boundaries/runtime API, and Foundation architecture/implemented systems/folder structure/next steps
- Whitespace-only closeout cleanup: shared button/card/header and existing Observation, Recall, Result, and Title screen scripts

## Architecture decisions

1. **One product catalog.** `RecommendationService.get_available_challenge_types()` adapts registered family contracts, metadata, TutorialProfiles, and persisted progress into UI-ready records.
2. **No parallel launch path.** Home, feature cards, Continue, tutorials, and the Challenge Library all enter `ChallengeSessionService`.
3. **Achievements are data, not screen logic.** Criteria live in JSON; the service evaluates and persists; screens render status records.
4. **Profile remains an adapter.** Witness Progress extends `ProfileService` data and continues to save through `SaveService`.
5. **Locked content is guarded twice.** Cards disable Play and the shared session service rejects a locked family.
6. **Programs stay dormant.** The Home surface reserves a clear future entry without introducing program orchestration early.

## Visual review

Local portrait artifacts are stored outside the exported application:

`docs/product/artifacts/home_experience/`

- `home_screen.png`
- `experiences_screen.png`
- `profile_screen.png`
- `achievements_screen.png`
- `settings_screen.png`

The review corrected narrow status labels that initially wrapped vertically. Final cards reserve width for lock, Mastery, rank, slider-value, and achievement-progress labels.

## Automated validation

| Validation | Result |
|---|---:|
| Fresh Godot 4.6.3 import | Pass, no app errors or warnings |
| Full source loading | 83 loaded, 0 failed |
| Phase 3 Home runtime/UI | 76 passed, 0 failed |
| Phase 3 architecture | Pass, 2 visible types / 10 achievements |
| Gate 1 runtime | 23 passed, 0 failed |
| First-run flow | 16 passed, 0 failed |
| Fixture compatibility | 30 passed, 0 failed |
| Runtime Hardening / synthetic family | 31 passed, 0 failed |
| Family tutorial architecture | 12 passed, 0 failed |
| Scene Investigation production flow | 23 passed, 0 failed |
| Scene Investigation tutorial | 18 passed, 0 failed |
| Scene Investigation scoring | 21 passed, 0 failed |
| Scene Investigation difficulty | 12 passed, 0 failed |
| Scene Investigation variety | 10 passed, 0 failed |
| Scene Investigation release stress | 120,000 generated, 0 failed |
| Flash Words production flow | 24 passed, 0 failed |
| Flash Words tutorial | 13 passed, 0 failed |
| Flash Words policies | 16 passed, 0 failed |
| Flash Words variety | 7 passed, 0 failed |
| Flash Words reproducibility | 100 sampled seeds, 0 failures |
| Flash Words release stress | 120,000 generated, 0 failed |
| Runtime architecture | Pass |
| Scene Investigation content | 3 templates / 54 archetypes, pass |
| Flash Words content | 3 templates / 373 words, pass |
| Gate 4 baseline after Phase 3 | 71 tracked; 44 unchanged / 27 approved Phase 3 or whitespace-only evolutions |
| Documentation | 43 Markdown files, pass |
| JSON, links, terminology, conflicts, trailing whitespace | Pass |

The Gate 4 baseline remains the historical proof that Flash Words was added without changing the 71 protected files. The post-Phase-3 verifier permits only an explicit allowlist of approved product-hub changes and closeout whitespace cleanup; every other tracked file must retain its Gate 4 hash.

## Risks and remaining work

- Physical-device review is still required for safe areas, touch ergonomics, font scaling, OLED/LCD contrast, and small-screen scroll behavior.
- Date-based featured rotation uses the device's local system date.
- Family unlock metadata currently places both production types at Witness Level 1; higher-level lock balancing remains a product decision.
- Collections and Programs are intentionally future-ready placeholders, not implemented systems.
- Achievement thresholds require human pacing review as the catalog grows.

## Recommended next phase

**Phase 4 — Player Progress depth and balancing**

The core Witness record now exists. Phase 4 should refine progression pacing, rank thresholds, Mastery communication, achievement thresholds, milestones, and collection contracts without replacing the Phase 3 Home or shared runtime.

Stop and wait for approval before Phase 4 implementation.

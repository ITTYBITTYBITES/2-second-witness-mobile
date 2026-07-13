# Phase 4 Completion — Player Journey and Product Experience

**Date:** 2026-07-12
**Approval:** Approved for Phase 5 preparation on 2026-07-12
**Status:** Complete and approved

## Completed experience

### Home and Continue

- Programs is now an active destination rather than Coming Soon.
- Home presents a data-driven featured curated run.
- Continue prioritizes unfinished Program progression, then recent Challenge Type, then the normal recommendation fallback.
- Play Now and every Program launch still enter `ChallengeSessionService`.

### Programs

Six content-driven curated runs now use generic selection policies:

- Daily Witness
- Observation Bootcamp
- Rapid Recall
- Mixed Rotation
- Favorites Run
- Weekend Challenge

Programs support schedules, Witness Level requirements, finite run lengths, resume, per-family rotation counts, accuracy, completed runs, and best run accuracy. Program completion is shown in Result and finishes through the normal runtime return lifecycle.

### Challenge Library

- Added persistent Challenge Type favorites.
- Added family-owned gameplay-focus metadata to catalog records.
- Added family-owned recommendation weight.
- Favorite state appears on every dynamic Challenge Type card.

### Profile and Collections

- Renamed the primary record surface to Witness Record.
- Added next-rank guidance.
- Added Recently Played.
- Added Favorite Challenge Types.
- Added Program Record.
- Replaced the Collections placeholder with tracked collection goals for Challenge Types, achievements, and curated runs.

### Achievements

Expanded the catalog from 10 to 14 while preserving the original achievements:

- Versatile Witness
- Curator
- First Journey
- All Angles

## Files created

- `app/src/gameplay/programs/ProgramService.gd`
- `app/src/gameplay/programs/programs.json`
- `app/src/ui/components/ProgramCard.gd`
- `app/src/ui/components/ProgramCard.tscn`
- `app/src/ui/screens/ProgramsScreen.gd`
- `app/src/ui/screens/ProgramsScreen.tscn`
- `app/tests/runtime/test_phase4_product_experience.gd`
- `app/tests/runtime/verify_phase4_product_architecture.py`
- `app/tests/runtime/generate_phase4_product_previews.gd`
- `docs/product/PHASE_4_PLAYER_JOURNEY_SPEC.md`
- `docs/product/PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md`
- Five PNG review artifacts under `docs/product/artifacts/phase4_product_experience/`

## Major files modified

- Project autoload and AppBoot initialization
- AppState, AppRoutes, NavigationService, and AppShell route mapping
- ChallengeSessionService program context/lifecycle integration
- RecommendationService catalog, Continue, featured Program, favorites, focus, and weight data
- PlayerProgressService favorites, recently played, and next-rank summaries
- ProfileService additive profile schema
- AchievementService and achievement content
- Both production family recommendation metadata
- TutorialScreen generic session-context forwarding
- Home, Challenge Library cards/screen, Profile, and Result
- Phase 3/3.5 regression and architecture checks
- Active roadmap, architecture, folder, implementation, testing, and status documentation

## Architectural decisions

1. **Programs are selection policies only.** ProgramService selects family/template IDs from registered catalog data and records run state. ChallengeSessionService remains the only gameplay launcher.
2. **Program context is generic session metadata.** Tutorial gating, replay, Continue, Result, and return behavior preserve an opaque Program context without family branches.
3. **Favorites remain profile data.** They extend PlayerProgressService/ProfileService rather than adding a favorite database.
4. **Collections are derived goals.** Phase 4 makes the surface meaningful without prematurely creating an inventory/economy service.
5. **Achievements remain content-driven.** New criteria count generic profile/runtime facts and contain no UI logic.
6. **Family recommendation influence is owned by families.** Shared recommendations read a metadata weight without knowing the family.

## Validation

| Validation | Result |
|---|---:|
| Fresh Godot 4.6.3 import | Pass, no app errors or warnings |
| Full source loading | 87 loaded, 0 failed |
| Phase 4 product/runtime/UI | 61 passed, 0 failed |
| Phase 4 static architecture | Pass, 6 Programs / 14 achievements / 3 registered families |
| Phase 3.5 responsive/performance | 94 passed, 0 failed |
| Phase 3 Home | 76 passed, 0 failed |
| Gate 1 runtime | 23 passed, 0 failed |
| First-run flow | 16 passed, 0 failed |
| Fixture compatibility | 30 passed, 0 failed |
| Runtime Hardening | 31 passed, 0 failed |
| Family tutorial architecture | 12 passed, 0 failed |
| Scene Investigation production/tutorial/scoring/difficulty/variety | 23 / 18 / 21 / 12 / 10 passed |
| Scene Investigation release stress | 120,000 generated, 0 failed |
| Flash Words production/tutorial/policy/variety | 24 / 13 / 16 / 7 passed |
| Flash Words reproducibility | 100 sampled seeds, 0 failures |
| Flash Words release stress | 120,000 generated, 0 failed |
| Runtime and Phase 3/3.5 architecture | Pass |
| Scene/Flash content validation | 3 templates / 54 archetypes and 3 templates / 373 words, pass |
| Gate 4 baseline after approved evolution | 71 tracked; 33 unchanged / 38 allowlisted evolutions |
| Documentation, JSON, links, terminology, conflicts, whitespace | Pass |
| Portrait visual review | Home, Programs, Library, Profile, Achievements reviewed |

Phase 3.5 performance remained inside its budgets after adding Programs: 35 responsive screen/profile constructions completed in approximately 1.75 seconds, Home snapshot construction averaged approximately 0.30 ms, and static memory was approximately 36.2 MB in the final local headless run.

## Remaining technical debt

- The Android sponsor-first boot gate remains open pending suitable physical hardware or a hardware-accelerated emulator.
- Programs and profile progress are local-only; no cloud sync exists.
- Device-clock schedule changes can alter Daily/Weekend availability.
- Program run history is summarized rather than stored as a dedicated per-run archive.
- Collections are derived progress goals, not yet an item/reward inventory.
- Rank thresholds remain intentionally simple and require human pacing review.
- With two production families, long mixed Programs necessarily revisit families.
- Dormant Foundation-era Experience scaffolding remains isolated but present.

## Risks

- Achievement and Program pacing need human retention/playtesting.
- More Challenge Types may expose focus-tag taxonomy gaps.
- Program selection must stay deterministic enough to explain while gaining variety as content expands.
- Local schedule logic needs explicit policy if live or seasonal content is introduced.

## Suggested improvements

- Add per-run Program summaries and history in Phase 5.
- Expand collections into content-owned sets and rewards.
- Add daily/weekly/seasonal objective definitions without separate gameplay.
- Add more mechanically distinct Challenge Types before aggressive Program balancing.
- Tune Witness Rank and achievement thresholds from real play data.

## Readiness for Phase 5

Phase 4 is approved for Phase 5 preparation. New Challenge Types can enter Home, Library, Programs, favorites, Profile, Collections, achievements, and recommendations through existing contracts and metadata. The Phase 5 Acceptance Contract and Portfolio Matrix must be approved before Spot the Difference implementation begins.

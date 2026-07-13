# Implemented Systems

**Foundation:** Complete and validated
**Product Development:** Phase 6 Production Readiness locally complete; external release gates open

The Product Development source of truth is [`../product/`](../product/README.md).

## Stable Foundation

### Application core

- `AppBoot` — ordered startup and service initialization
- `AppState` — application phase and transient session data
- `EventBus` — decoupled application events
- `ErrorHandler` — bounded error history and safe recovery

### Navigation and shell

- `NavigationService` and `AppRoutes` — validated routes, history, and screen-view analytics
- `AppShell` — screen loading/cache, chrome, overlays, safe areas, and route presentation

### Shared services

- `ConfigService` — application configuration and feature flags
- `SaveService` — versioned persistence and migrations
- `ProfileService` — player record and current progress storage
- `SettingsService` — persisted player preferences
- `ThemeService` — colors, typography, spacing, radius, and component styles
- `AccessibilityService` — font, motion, contrast, hints, and haptics
- `AudioService` — shared audio transport and buses
- `AnalyticsService` — consent-aware event transport
- `ContentService` — packaged and cached content loading

Product Development extends these services through adapters and schemas; it does not replace them.

## Challenge data contracts

- `ChallengeFamily`
- `ChallengeTemplate`
- `ChallengeInstance`
- `PresentationProfile`
- `TutorialProfile`
- `ChallengeValidationResult`
- `ChallengeResult`

Contracts contain serializable state and validation helpers. They do not own navigation, persistence, rendering, or profile access.

## Shared Challenge Runtime

### ChallengeSessionService

Orchestrates family/template selection, difficulty, exposure, generation, validation, instance presentation, response capture, result creation, progress dispatch, recommendation, replay, continue, and Home completion.

### ChallengeFamilyRegistry

Loads enabled module scripts from `gameplay/families/manifest.json`, supports validated public registration, verifies family/template ownership and strategy contracts, rejects duplicates atomically, and exposes modules without concrete family branches.

### ResultService

Executes the family-owned `ScoringPolicy` and maps its outcome, score, explanation, progress, mastery, and reveal data into canonical `ChallengeResult` data.

### PlayerProgressService

Writes standard runtime results through `ProfileService`, maintains additive Witness Level/Rank, family mastery, accuracy, streak, template/seed/signature history, and returns progress-earned data. It does not create a second persistence system.

### RecommendationService

Builds the player-visible Challenge Type catalog, introduces unplayed types, balances recommendations by plays/Mastery, avoids immediate repeats, resumes recent play, rotates a deterministic daily feature, and supplies the complete Home snapshot. It contains no concrete family IDs.

## Runtime behavior interfaces

- `ChallengeFamilyModule`
- `ChallengeGenerator`
- `ChallengeValidator`
- `DifficultyPolicy`
- `ExposurePolicy`
- `ScoringPolicy`

Family-specific implementations live outside the shared runtime directory.

## Production Scene Investigation

The player-facing family implements five production templates:

- Office
- Kitchen
- Workshop
- Travel Desk
- Garden Bench

It supplies seeded scene generation, 120 object archetypes, vector object rendering, illustrated backgrounds, fairness validation, independent difficulty axes, approved exposure tiers, family-owned scoring, evidence reveals, Witness Progress, recommendation rotation, and tutorial version 2.

## Production Flash Words

The second production family implements:

- Single Word Recognition
- Word Pair Order
- Word Stream Presence
- Position Catch
- 373 reviewed words with frequency, length, uniqueness, similarity, syllable, category, and orthographic metadata
- Seeded generation and fairness validation
- Template-controlled distractor categories
- Independent timing, interval, sequence, similarity, and word-length axes
- Reading Comfort Mode
- Family-owned scoring and exact comparison reveals
- Typography renderer and family tutorial
- Rhythmic understated audio
- Witness Progress, mastery, recent-word, seed, and signature history

Its protected Engine baseline check proves 71 shared files remained unchanged.

## Regression fixture family

The separate internal `scene_investigation_fixtures` family preserves five deterministic fixtures through the same runtime. It is excluded from player-facing recommendations and Challenge Library listings.

## Presentation and tutorial adapters

The existing Observation, Recall, and Result screens consume canonical instance/result data and advance through `ChallengeSessionService`.

The shared TutorialScreen is a generic host. Family modules supply TutorialProfiles and mechanic-specific tutorial scenes. Title and Challenge Library resolve tutorial behavior dynamically without family IDs.

Player-facing launch paths using the runtime:

- Home Play Now
- Home featured challenge
- Tutorial completion
- Challenge Library selection
- Replay
- Continue
- Return Home

## Phase 3 product experience

- Data-driven Home with Play Now, Continue, daily feature, achievement previews, quick access, and Programs Coming Soon
- Rich Challenge Library cards generated from registered family metadata and progress
- Witness Profile with Observation Record, Family Mastery, Challenge History, achievements, and Collections future readiness
- `AchievementService` plus ten JSON achievement definitions and a collection screen
- Settings surface for audio, music, sound, haptics, Reading Comfort Mode, text size, motion, contrast, privacy, credits, and About
- Achievements route and app phase
- Portrait visual-review artifacts under `docs/product/artifacts/home_experience/`

## Phase 3.5 production polish

- Sponsor artwork is the first engine boot visual and the publisher route uses matching full-screen art.
- Android Gradle export themes suppress the Android 12+ launcher-icon splash before sponsor artwork.
- ResponsiveLayout centers product content across phones, tablets, and unfolded profiles.
- AppShell scales safe-area insets, enforces 48-pixel targets, handles Android Back, and presents Reduced Motion-aware transitions/loading.
- Text Size scales shared typography; High Contrast derives complete tokens.
- Reading Comfort and Color Assistance reach family-owned policies.
- AnalyticsService records cold-start, screen-presentation, challenge-preparation, generation-attempt, and memory samples.
- Large runtime textures use bounded import dimensions.

## Phase 4 player journey

- ProgramService loads nine curated run definitions and selects registered families/templates through generic daily, focus, mixed, favorites, and weekend policies.
- ChallengeSessionService preserves opaque Program context through tutorial gating, replay, Continue, Result, and completion.
- Home activates Programs and unfinished-Program Continue.
- Challenge Library supports persistent favorite Challenge Types.
- Profile includes Witness Record, next rank, Recently Played, Favorites, Program Record, and Collection Progress.
- AchievementService supports 26 definitions including versatile play, favorites, Program completion, and cross-family Mastery.
- Production families own gameplay-focus tags and recommendation weights consumed by shared selection services.

## Phase 5 Challenge Type Expansion

- InteractionProfile contract and data-driven InteractionAdapterRegistry
- Six generic adapters: Single Choice, Multiple Choice, Spatial Tap, Region Selection, Ordering, Sequence Input
- Drag and Drop and Text Entry reserved for future registration
- Spot the Difference with four templates and Spatial Tap/accessibility fallback
- Object Recall with four templates and Multiple Choice
- Pattern Recall with three templates and Sequence Input
- Five production families, twenty total production templates, and twenty-six achievements
- Forty-seven-file shared interaction baseline plus a 58-file post-approval platform freeze
- Mandatory Challenge Type Acceptance Contract and portfolio differentiation matrix

No shared Interaction or runtime file contains a Phase 5 family identifier.

## Phase 5.5 Content & Quality Pass

- Scene Investigation: five settings and 120 archetypes
- Flash Words: four distinct decisions over 373 reviewed words
- Spot the Difference: 48 identities, four themes, richer legal mutations, and one-pass sequential comparison
- Object Recall: 48 data-driven identities, four templates, illustrated silhouettes, and explicit missing-object evidence
- Pattern Recall: 12 named symbols, connected paths, distinct cumulative builds, and numbered reveals
- Renderer-backed tutorials and three understated family audio cues
- Nine curated Programs and twenty-six achievements through unchanged services
- Adaptive family difficulty recovery and tuned recommendation metadata
- Automated 50-round quality proxies across every family
- Fifty-eight-file platform freeze, with one documented generic response-context defect correction

No sixth Challenge Type was added.

## Phase 6 Production Readiness

- Full construction and touch-target pass over 13 production screens
- Atomic save replacement, previous-valid backups, corrupt-primary recovery, and version-one migration
- Nested profile-default migration safety
- Bounded local analytics with complete opt-out and no production endpoint
- Offline production config and Android presets without Internet/network-state permissions
- Cached packaged audio, immediate mute/volume updates, and duplicate-cue cleanup
- Bounded shell cache that releases splash, tutorial, gameplay, response, and Result screens
- Friendly loading, empty, success, achievement, collection, and error states
- Exact-count Multiple Choice guidance and clean Sequence Input remounting
- Explicit High Contrast treatment in every custom family renderer
- Show Tutorials preference connected to automatic Runtime gating
- Compact privacy modal, final About/credits notices, and production privacy copy
- Nine Programs and twenty-six achievements revalidated for pacing
- Final Android, store, open-source, and release checklists
- Post-polish 58-file platform baseline with no family-specific shared branches

No human playtesting was performed. Human, physical-device, signed-artifact, and store/legal gates remain external.

## Transitional fixture loading

`ChallengeRegistry` continues to load and normalize `challenges.json` for compatibility. Player-facing screens no longer call its launch/replay/continue methods.

## Dormant Foundation scaffolding

The earlier Experience module scaffolding remains present but is not the playable backbone and must not become a competing architecture.

## Automated verification

- `tests/runtime/test_challenge_runtime_gate1.gd`
- `tests/runtime/test_first_run_runtime_regression.gd`
- `tests/runtime/test_fixture_generation_and_validation.gd`
- `tests/runtime/test_load_all_source_scripts.gd`
- `tests/runtime/test_runtime_type_agnostic.gd`
- `tests/runtime/test_family_tutorial_architecture.gd`
- `tests/runtime/test_scene_investigation_production_flow.gd`
- `tests/runtime/test_scene_investigation_tutorial.gd`
- `tests/runtime/test_scene_investigation_scoring.gd`
- `tests/runtime/test_scene_investigation_difficulty.gd`
- `tests/runtime/test_scene_investigation_session_variety.gd`
- `tests/runtime/test_scene_investigation_stress.gd`
- `tests/runtime/test_flash_words_production_flow.gd`
- `tests/runtime/test_flash_words_tutorial.gd`
- `tests/runtime/test_flash_words_policies.gd`
- `tests/runtime/test_flash_words_session_variety.gd`
- `tests/runtime/test_flash_words_seed_reproducibility.gd`
- `tests/runtime/test_flash_words_stress.gd`
- `tests/runtime/test_phase3_home_experience.gd`
- `tests/runtime/test_phase35_production_polish.gd`
- `tests/runtime/test_phase4_product_experience.gd`
- `tests/runtime/verify_phase4_product_architecture.py`
- `tests/runtime/verify_phase5_preparation.py`
- `tests/runtime/test_phase5_interaction_system.gd`
- `tests/runtime/test_phase5_challenge_types.gd`
- `tests/runtime/test_phase5_tutorials.gd`
- `tests/runtime/test_phase5_reproducibility_variety.gd`
- `tests/runtime/test_phase5_stress.gd`
- `tests/runtime/verify_phase5_architecture.py`
- `tests/runtime/verify_phase5_content.py`
- `tests/runtime/verify_phase5_interaction_baseline.py`
- `tests/runtime/test_phase55_replay_quality.gd`
- `tests/runtime/verify_phase55_content_quality.py`
- `tests/runtime/test_phase6_persistence_performance.gd`
- `tests/runtime/test_phase6_product_pass.gd`
- `tests/runtime/verify_phase6_production_readiness.py`
- `tests/runtime/verify_phase3_home_architecture.py`
- `tests/runtime/verify_phase35_production_polish.py`
- `tests/runtime/generate_phase3_home_previews.gd`
- `tests/runtime/verify_scene_investigation_content.py`
- `tests/runtime/verify_flash_words_content.py`
- `tests/runtime/verify_flash_words_engine_unchanged.py`
- `tests/runtime/fixtures/` synthetic family strategies
- `tests/runtime/verify_runtime_architecture.py`
- `tests/runtime/verify_documentation.py`

These cover all five production families, runtime extension points, tutorials, deterministic replay, exactly-once progress, family scoring, difficulty/exposure, Reading Comfort Mode, 20/50-round variety proxies, 100-seed reproducibility audits, full 10,000-seed/template/tier release stress, fixture compatibility, source loading, synthetic type-agnostic execution, retries, fallback, controlled failure, protected platform hashes, content quality, architecture boundaries, and documentation consistency.

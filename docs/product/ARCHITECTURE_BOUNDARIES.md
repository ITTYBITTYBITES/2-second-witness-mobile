# Engine, Game, and Content Boundaries

**Status:** Product Development source of truth
**Phase:** Phase 6 Production Readiness locally complete
**Runtime status:** Hardened, family-agnostic, and proven by five production Challenge Types and a data-driven product hub

## Principle

The validated Foundation remains stable. Product Development adds modular gameplay above it.

> The Engine runs challenges. The Game defines their rules. Content gives them presentation and variety.

## Engine

The Engine contains reusable infrastructure and orchestration. It must not contain Challenge Type-specific rules.

### Validated Foundation responsibilities

- Boot sequence and initialization order
- Splash sequence
- Application shell and route history
- Save and profile persistence
- Settings
- Theme tokens and shared UI components
- Accessibility services
- Audio transport, buses, and playback
- Analytics transport and consent handling
- Error handling and application state
- Content loading infrastructure
- General project organization

### Shared runtime responsibilities

- Challenge session orchestration
- Seed recording and deterministic replay
- Family and template resolution
- Difficulty and exposure policy execution
- Generation orchestration
- Fairness-validation orchestration
- Bounded retries and known-valid fallback
- Recent-signature rejection
- Presentation-profile routing
- Family-owned ScoringPolicy execution
- Canonical result creation
- Player-record update dispatch
- Recommendation dispatch
- Controlled failure without navigation/progress side effects

The Engine executes supplied interfaces. It never branches on a concrete family ID, template ID, response mode, or presentation type.

## Game

The Game layer defines product behavior while using Engine services.

Responsibilities:

- ChallengeFamily modules
- ChallengeTemplate interpretation
- ChallengeInstance production
- Family-specific tutorials
- Generators and validators
- Scoring policies
- Difficulty and exposure policies
- Player progress declarations
- Recommendations
- Programs
- Achievements and milestones

Internally the architecture uses `ChallengeFamily`, `ChallengeTemplate`, and `ChallengeInstance`. Player-facing UI uses **Challenge Type**, **Challenge**, or **Round**.

A family may implement specialized mechanics, but it must not reimplement navigation, saving, analytics transport, accessibility, audio transport, or the standard session lifecycle.

## Content

Content supplies versioned data and presentation resources consumed by Game modules.

Responsibilities:

- Family manifests
- Template configurations
- Object pools
- Artwork/backgrounds
- Music and sound assets
- Animation/presentation profiles
- Tutorial copy
- Difficulty/exposure tuning tables
- Localization
- Known-valid fallback fixtures

Content may select a registered implementation by ID. It must not create alternate application services or navigation flows.

## Dependency direction

```text
Content definitions and assets
            ↓
Game families, policies, and rules
            ↓
Shared runtime contracts and orchestration
            ↓
Validated Foundation services
```

Foundation services do not import a specific family. Shared runtime code depends on contracts, not concrete Challenge Types.

## Extension acceptance test

Adding a new Challenge Type should require only:

- Approved Challenge Type Specification
- Family manifest and module
- Templates and content
- Tutorial
- Artwork and audio profiles
- Generator and validator
- Scoring, difficulty, and exposure policies
- Accessibility requirements
- Progress declarations

It must not require family-specific edits to boot, navigation, Home framework, profile persistence, settings, theme, shared UI services, audio/analytics transport, or shared runtime orchestration.

## Current production state

### Scene Investigation

Owns Office, Kitchen, Workshop, Travel Desk, and Garden Bench templates, scene generator, validator, ScoringPolicy, DifficultyPolicy, ExposurePolicy, vector renderer, content, and family tutorial.

### Flash Words

Owns Single Word, Pair Order, Word Stream, and Position Catch templates, 373-word content pack, generator, validator, ScoringPolicy, DifficultyPolicy, ExposurePolicy, typography renderer, audio, Reading Comfort behavior, and family tutorial.

### Regression fixtures

`SceneInvestigationFixtureFamily` separately adapts five deterministic definitions for regression coverage and is hidden from player-facing recommendations and the Challenge Library.

Shared Observation, Recall, Result, Tutorial, Title, and Challenge Library code use family contracts and contain no production-family IDs.

## Gate 4 architecture proof

Flash Words was added without modifying the protected baseline of 71 Core, Systems, shared UI, runtime, contract, and project files.

Gate 4 demonstrates that new Challenge Types can supply:

- Content
- Generator and validator
- Difficulty, exposure, and scoring policies
- Presentation renderer
- TutorialProfile and family tutorial
- Audio/visual assets
- Progress declarations

without family-specific Engine, navigation, or shared-runtime changes.

## Phase 3 product-hub boundary

Home and the Challenge Library consume catalog/recommendation records from `RecommendationService`. They do not contain production family IDs or import family implementations. `AchievementService` evaluates JSON definitions against persisted Witness Progress. Profile remains a presentation over `PlayerProgressService` and `ProfileService` rather than a second progression store.

Approved shared product APIs now include:

- Start, Continue, daily feature, and catalog recommendations
- A Home snapshot containing recent play, Witness summary, and achievement previews
- Observation Record and flattened Challenge History queries
- Data-driven achievement status and unlock evaluation

Future Challenge Types provide metadata, artwork, TutorialProfile, templates, and progress through existing family contracts; Home and library cards appear without a family-specific UI change.

## Phase 3.5 polish boundary

ResponsiveLayout is a stateless UI helper. Safe-area application, route transitions, global touch targets, loading presentation, and Android Back remain AppShell responsibilities. ThemeService derives typography and contrast tokens from SettingsService; AccessibilityService exposes the same persisted preferences. Performance samples use AnalyticsService rather than a parallel telemetry transport.

Color Assistance is stored generically but interpreted by Scene Investigation because that family owns color-dependent question selection. Android system-splash customization is supplied through Godot export attributes rather than a custom activity fork.

## Phase 4 Program boundary

Programs are Game-layer selection policies. ProgramService may filter and order the player-visible catalog, choose a family/template, and record run progress. It may not generate instances, validate fairness, calculate scores, render presentation, or navigate directly to gameplay routes. ChallengeSessionService remains the only launch and lifecycle authority.

Program context is opaque metadata carried through tutorial gating and the standard runtime. New Challenge Types participate through gameplay-focus tags and family-owned recommendation weights; no Program contains a production family ID.

Favorites, Program progress, Recently Played, achievements, and Collection Progress extend the existing ProfileService schema and PlayerProgressService adapter. No second persistence system exists.

## Phase 5 Interaction and family boundary

PresentationProfile references a family-supplied InteractionProfile. InteractionAdapterRegistry resolves a generic adapter that collects one payload and forwards it through ChallengeSessionService. Adapters know interaction mechanics only; family ScoringPolicy owns meaning and correctness.

Implemented generic modes are Single Choice, Multiple Choice, Spatial Tap, Region Selection, Ordering, and Sequence Input. Shared interaction code contains none of the five production family IDs.

Spot the Difference, Object Recall, and Pattern Recall own their generators, validators, policies, renderers, tutorials, content identity, scoring, progress keys, and recommendation metadata. Home, Library, Programs, Profile, Collections, and recommendations discover them automatically.

Every future family still requires the Acceptance Contract and Portfolio Matrix. Family implementation may add Game and Content modules, but may not add family-specific branches to Engine, shared runtime, interaction adapters, Home, Programs, Profile, persistence, accessibility, audio transport, analytics transport, or navigation.

## Phase 5.5 platform freeze

Phase 5.5 deepens only family-owned content and existing data catalogs. The 58-file platform baseline protects Engine, runtime, interaction contracts/adapters, Programs, recommendations, Witness Progress, Home, Challenge Library, Profile, and shared presentation/result hosts.

A single defect-qualified generic correction adds `interaction_phase = response` to renderer data mounted by SpatialTapSurface. It prevents sequential observation animation from disagreeing with normalized response regions. The adapter still emits only coordinates and contains no family ID or correctness rule.

## Phase 6 compatible hardening

Phase 6 preserves all dependency directions and public gameplay contracts. Compatible evolutions are limited to production behavior around the frozen architecture:

- Atomic persistence and recovery behind unchanged SaveService/ProfileService APIs
- Bounded local analytics behind unchanged event APIs
- Audio caching and settings synchronization behind unchanged AudioService APIs
- Screen lifecycle, transition, state, and accessibility polish in existing routes
- Existing setting behavior connected where it was previously inactive
- Generic interaction usability without adapter correctness knowledge
- Family-local visual contrast and progress-confidence tuning
- Offline/Android export configuration and final release records

`PHASE_6_PLATFORM_BASELINE.json` records the post-polish hashes. Static checks continue to reject any concrete production family identifier in shared Engine, Runtime, interactions, Programs, recommendations, progress, Home, Library, Profile, persistence, accessibility, or navigation code.

## Deferred

- Physical Android notch/tablet/foldable and sponsor-first boot confirmation
- Further Scene Investigation settings beyond the approved five
- Seven remaining planned Challenge Types
- Live events, leaderboards, or multiplayer
- Collection rewards and long-term milestone depth
- Runtime-downloaded executable family code

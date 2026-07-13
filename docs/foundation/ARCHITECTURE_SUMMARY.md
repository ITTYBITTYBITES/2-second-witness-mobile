# Two Second Witness — Foundation Architecture Summary

**Foundation status:** Complete and validated
**Current phase:** Phase 6 Production Readiness locally complete; external release gates open
**Engine:** Godot 4.6.3
**Package:** `com.ittybittybites.the2secondwitness`

## Purpose

The Foundation provides stable application infrastructure. Product Development must evolve gameplay above this layer rather than rebuild it.

Current Product Development boundaries are defined in [`../product/ARCHITECTURE_BOUNDARIES.md`](../product/ARCHITECTURE_BOUNDARIES.md).

## Stable Foundation

### Application shell

- `AppShell` owns screen presentation, overlays, top navigation, and bottom navigation.
- `NavigationService` validates routes and maintains history.
- `AppState` tracks application phase, loading state, and transient route data.
- `AppBoot` initializes services in an explicit dependency order.

### Core services

- `ConfigService` — configuration and feature flags
- `SaveService` — versioned JSON persistence
- `ProfileService` — player record and current temporary progress
- `SettingsService` — persisted player preferences
- `ThemeService` — design tokens and shared styling
- `AccessibilityService` — motion, font, contrast, and haptic settings
- `AudioService` — audio buses and playback transport
- `AnalyticsService` — consent-aware local analytics transport
- `ContentService` — resource and cached-content loading
- `ErrorHandler` — centralized error reporting and safe recovery
- `EventBus` — shared event transport

These services may be improved through compatible fixes, but Product Development must not replace them or create parallel versions.

## Current application flow

```text
Publisher Splash
→ Title
→ Privacy acknowledgment when required
→ Family tutorial when required
→ Home product hub
→ Play Now, Continue, daily feature, or Challenge Library
→ Observation / presentation
→ Recall / response
→ Result
→ Continue or Home
```

The visible journey remains familiar, but all player-facing challenge launches now enter the shared Challenge Runtime.

## Transitional gameplay

`ChallengeRegistry.gd` loads and normalizes five fixed entries from `challenges.json`. `SceneInvestigationFamily` adapts them into templates and instances for the shared runtime.

The registry's former launch methods remain transitional internals; player-facing screens no longer call them. The fixed content protects the validated flow but is not the target production model.

The five entries and their images are designated regression fixtures in [`../../app/src/gameplay/REGRESSION_FIXTURES.md`](../../app/src/gameplay/REGRESSION_FIXTURES.md).

## Product Development contracts

Phase 1 adds behavior-neutral contracts under `app/src/gameplay/contracts/`:

- `ChallengeFamily` — one internal gameplay module, presented to players as a Challenge Type
- `ChallengeTemplate` — one balanced and versioned pattern
- `ChallengeInstance` — one fully resolved and reproducible challenge

The data contracts remain plain `RefCounted` values. Phase 2 Gate 1 adds generic runtime services and family-supplied strategies above them. Current screens receive canonical instance/result data through a `PresentationProfile`.

## Layer model

```text
CONTENT
Manifests, template configuration, artwork, audio, tuning, localization
                         ↓
GAME
Families, rules, tutorials, policies, progress, recommendations, programs
                         ↓
ENGINE
Shared challenge orchestration and validated Foundation services
```

The Engine must not contain family-specific branches. Families may implement specialized mechanics through shared contracts but may not reimplement navigation, persistence, accessibility, analytics transport, or the session lifecycle.

## Foundation invariants

Product Development must preserve:

- Boot order and startup reliability
- Splash and privacy behavior
- Route and history behavior
- Save compatibility
- Settings compatibility
- Player-profile compatibility
- Theme tokens and shared component behavior
- Accessibility settings
- Audio and analytics transport
- Android package identity

## Current gate boundary

Phase 2 is complete with two production Challenge Types: Scene Investigation and Flash Words. Flash Words preserved the 71-file Engine/shared baseline, proving the platform supports mechanically different families without architecture rewrites.

Phase 3 intentionally evolves shared product UI after that proof. Home and the Challenge Library consume a generic catalog/Home snapshot; Continue, daily feature, Profile, Challenge History, achievements, and settings remain adapters over the validated runtime and Foundation services.

Phase 3.5 hardens that product layer with sponsor-first Android configuration, safe-area scaling, responsive maximum-width content, touch targets, accessibility-derived theme behavior, branded loading/transitions, and performance instrumentation.

Phase 4 activates Programs as generic selection policies over the same runtime. Program context remains opaque to family mechanics; favorites and Program progress extend ProfileService; Collections derive from existing progress.

Phase 5 added a generic InteractionProfile/InteractionAdapter layer and three production families without family-specific Engine branching. Phase 5.5 deepened the five-family catalog to 20 templates. Phase 6 completed compatible UI, accessibility, persistence, offline, performance, Android configuration, privacy, credits, and release-workflow hardening. The post-polish 58-file baseline records 18 approved compatible evolutions without family-specific shared code. Human playtesting, signed-artifact review, and physical Android confirmation remain open.

The authoritative roadmap is [`../product/PRODUCT_DEVELOPMENT_ROADMAP.md`](../product/PRODUCT_DEVELOPMENT_ROADMAP.md).

# Current State Baseline Audit — Two Second Witness Flagship Evolution

**Purpose:** establish the protected production baseline from which flagship evolution proceeds.
**Scope:** documentation/planning baseline only; no application code is changed by this package.
**Product-code baseline inspected:** `45df4f4d1e86021bb0e972d3204d70d43b8cf778` with subsequent documentation-only planning commits.

---

# 1. Baseline product summary

Two Second Witness is a portrait Android/Godot observation game with five player-visible Challenge Types and a shared challenge lifecycle:

```text
Scene Investigation → Observation → Recall → Evidence Reveal → Witness Record
```

The product has more infrastructure than a prototype: generated/validated challenge instances, five tutorial-owned families, a data-driven catalog, Programs, local progression, local saves with recovery, accessibility controls, offline defaults, audio/haptics, and Android export preparation.

The current flagship direction is **Scene Investigation as the Witness Moment**. The existing app is valuable because this core can evolve through content, policy, presentation, and product-surface changes without a full rebuild.

---

# 2. Architecture baseline

## Layer model

```text
CONTENT
Family manifests, templates, object/word pools, scene JSON, artwork, audio, tuning
        ↓
GAME
Challenge families, generators, validators, difficulty/exposure/scoring policies,
Programs, achievements, witness progression, recommendations
        ↓
WITNESS RUNTIME
Challenge session orchestration, family registry, interaction adapters,
result creation, player-progress dispatch, route presentation
        ↓
FOUNDATION
Boot, shell/navigation, save/profile/settings, theme, accessibility, audio,
analytics, content loading, error handling, Android project/export configuration
```

## Application boot and shell

| System | Current responsibility | Protection requirement |
|---|---|---|
| `AppBoot` | Initializes config, saves/profile, settings/accessibility/theme, content/runtime, audio, navigation in explicit order. | Preserve dependency order; cold Android launch must not regress. |
| `AppShell` | Mounts routes, handles shell chrome, safe areas, screen lifecycle/cache, loading/error state, Back behavior. | Preserve safe-area/chrome/gameplay route separation and non-cached transient gameplay screens. |
| `NavigationService` / `AppRoutes` | Validates routes, tracks history, updates app phase and route audio. | Keep one route authority and existing Back semantics. |
| Publisher/Title splash | Sponsor-first/title/loading/privacy/intro handoff. | Preserve first branded frame, privacy flow, and bounded boot. Clarify—not replace—first-session tutorial policy. |

## Active gameplay runtime

| System | Current responsibility | Protection requirement |
|---|---|---|
| `ChallengeFamilyRegistry` | Loads production family modules from manifest and exposes visible catalog/family contracts. | Preserve family-agnostic discovery; no shared family-ID branches. |
| `ChallengeSessionService` | Single lifecycle authority from start/recommendation through generation, response, result, progress, recommendation, and return. | All new entry/brief/reveal work must continue through this service. |
| `ChallengeFamily`, `ChallengeTemplate`, `ChallengeInstance` contracts | Define family, balanced template, and fully resolved reproducible round. | Preserve contract ownership and version/seed identity. |
| Generator / Validator / fallback | Produces deterministic candidate, validates fairness, retries bounded attempts, uses known-valid fallback. | Do not weaken fairness validation to accelerate content production. |
| Difficulty / Exposure policies | Resolve independent axes and player comfort timing. | Retain family ownership and accessible timing without progress penalties. |
| `PresentationProfile` / `InteractionProfile` | Selects generic routes, renderer and response mechanics. | Preserve generic presentation and adapter separation. |
| InteractionAdapterRegistry | Registers Single Choice, Multiple Choice, Spatial Tap, Region Selection, Ordering, Sequence Input. | Keep adapters mechanics-only; scoring stays in family policy. |
| `ResultService` | Builds canonical result from family scoring and resolved instance. | Preserve evidence/replay/progress data in result contracts. |

## Product systems

| System | Current responsibility | Protection requirement |
|---|---|---|
| `RecommendationService` | Play Now, Continue, deterministic featured type, catalog, Home snapshot, next-round recommendation. | Clarify player-facing semantics; do not create alternate recommendation stores. |
| `ProgramService` | Nine finite curated-run definitions with daily/focus/mixed/favorites/weekend policies and resume. | Reuse as Witness Brief foundation; do not create a parallel session path. |
| `PlayerProgressService` | Adapts results to Witness Progress, family mastery/history, ranks, recent signatures, favorites, observation record. | Preserve one progression adapter and save path. |
| `AchievementService` | Evaluates 26 data-driven definitions. | Keep optional/data-driven; do not make achievement quantity the flagship loop. |
| Challenge Library | Generic catalog cards, lock/favorite/mastery/tutorial/Play affordances. | Preserve as secondary discovery surface. |
| Home V2 | Routed Home: identity, one dominant recommendation/continue card, compact progress, Library/Programs access. | Preserve data-driven launch path; evolve semantics without restoring a dashboard by default. |
| Profile / Settings / About | Witness record, history, achievements/program summary, controls/legal/credits. | Preserve privacy/accessibility/settings and local player record. |

---

# 3. Prompt terminology mapping and protection

The terms below are useful product shorthand in this Master Plan. They are **not all verified as literal source singleton names**. Development must preserve the actual service equivalents, not invent or replace systems simply to match vocabulary.

| Planning term | Actual current equivalent(s) | Baseline rule |
|---|---|---|
| **Witness Engine** | ChallengeSessionService + contracts + ResultService + PlayerProgressService + registered family modules. | Treat as the protected shared challenge lifecycle, not a new engine to build. |
| **Iris Engine** | No dedicated source system with this exact name. Closest functions are the eye/witness brand motif, Scene Investigation renderer, VisualStyleSystem, ThemeService, observation/reveal presentation. | Use only as a presentation/design concept unless a documented future need proves a new abstraction. |
| **Content Registry** | ChallengeFamilyRegistry for active families; family manifests/content; legacy ContentService/ExperienceRegistry exists but is not active player path. | Active extension model is ChallengeFamilyRegistry/family-owned content. Audit legacy path before retirement. |
| **Sampling Controller** | RecommendationService + ProgramService + difficulty/exposure policies + recent-signature protection. | Preserve selection/fairness logic; do not add a separate controller without explicit architecture justification. |
| **Witness Record** | PlayerProgressService, ProfileService, history/favorites/mastery/rank/Program records. | Evolve presentation and additive metadata only; do not create a second persistence system. |

---

# 4. Screens, scenes, and current data flow

## Active route journey

```text
Android launch surface
→ Publisher Splash
→ Title/Loading
→ Privacy acknowledgment when required
→ intro/family tutorial behavior when required
→ Home V2
→ Recommendation / Continue / Library / Programs
→ Observation
→ Recall
→ Result
→ Next / Retry / Library / Home
```

## Primary screens

| Route/screen | Current role | Flagship evolution role |
|---|---|---|
| PublisherSplashScreen | Publisher identity and first visual handoff. | Preserve; ensure it does not delay first Witness Moment unnecessarily. |
| TitleSplashScreen | Loading, privacy host, first-session intro routing. | Clarify one intentional first-session contract. |
| TutorialScreen + family tutorial scenes | Generic host for family-owned instruction/practice. | Use for one concise Scene Investigation witness contract; avoid duplicate teaching. |
| HomeV2Screen | Current state-aware primary recommendation/continue entry. | Become truthful doorway to current Witness Brief, not a feature dashboard. |
| ExperiencesScreen | Generic Challenge Library. | Secondary discovery after flagship understanding. |
| ProgramsScreen | Curated-run browser. | Secondary/advanced curation; reuse program logic for Brief. |
| ObservationChallengeScreen | Shared timed presentation host with family renderer. | Flagship stage: protect scene focus, timing, fair visual hierarchy. |
| MemoryQuestionScreen | Generic response host mounting interaction adapters. | Keep one clear Scene Investigation witness call. |
| ResultScreen | Family evidence reveal, result information, next/retry/library/home actions. | Transform into signature truth/reveal hierarchy. |
| ProfileScreen | Current record, mastery, history, Program/achievement summaries. | Evolve toward quiet Witness Record/archive. |
| Settings/About/Achievements | Controls, legal, credits, optional recognition. | Preserve access; keep secondary to current moment. |

## Challenge data flow

```text
Home / Library / Program selection
→ ChallengeSessionService
→ family module + template
→ difficulty + exposure policy
→ seeded generator
→ validator / retry / fallback
→ resolved ChallengeInstance
→ Observation route + family renderer
→ response adapter
→ family scoring + canonical ChallengeResult
→ PlayerProgress/Profile/Program/Achievement updates
→ next recommendation / Result route
```

## Content flow

```text
family manifest
→ ChallengeFamily module
→ family template/content JSON and asset references
→ generator produces scene truth + question + options + reveal data
→ validator accepts/rejects
→ renderer consumes resolved generated_scene
→ result consumes family explanation/evidence data
```

No player-facing flagship feature should bypass this flow.

---

# 5. Current content and asset baseline

## Production portfolio

| Family | Current purpose | Content baseline | Flagship role |
|---|---|---|---|
| Scene Investigation | Brief ordinary scene, unknown question, evidence reveal. | Five settings, 120 archetypes, five question categories, generated scene truth. | **Flagship Witness Moment.** |
| Flash Words | Rapid word/sequence recognition. | 373 English words, four templates. | Companion variation. |
| Spot the Difference | Compare/tap one changed visual detail. | Four templates, 48-object pool. | High-legibility companion/challenger. |
| Object Recall | Isolated set membership/position recall. | Four templates, 48-object pool. | Calm companion/accessibility variation. |
| Pattern Recall | Ordered grid/symbol reconstruction. | Three templates, 12 symbols. | Specialist mastery variation. |

## Asset pipeline

- Scene Investigation uses family-owned scene data plus sprite-first rendering with vector fallback.
- Existing visual migration uses grounded backgrounds, warm evidence accents, code-drawn shadows, processed transparent object sprites, and ETC2 asset import.
- Other families have their own renderer/asset profiles.
- Audio framework provides BGM by route, packaged UI/gameplay/result cues, bus volumes/mutes, ducking, and optional haptics.
- Store/trailer assets exist, but real device gameplay footage remains a release requirement.

---

# 6. Current user experience baseline

## First launch

1. System/publisher/title load sequence establishes brand and privacy.
2. Privacy acknowledgment persists locally.
3. Current source may launch an intro tutorial based on `onboarding_completed` and first visible family; family tutorials can also gate entry.
4. A practice/first round enters the normal runtime.
5. Result actions mark first-session completion.

**Baseline strength:** privacy/trust, generic tutorial hosting, normal runtime practice.
**Baseline weakness:** first-session logic/documentation has drift; first family is effectively manifest-order driven; the user can encounter more teaching structure than the central idea requires.

## Returning session

1. Player reaches Home V2 after title flow.
2. Home favors Continue for recent family/unfinished Program, otherwise balanced recommendation.
3. Player may browse Library/Programs or start primary card.
4. A normal family session resolves and updates local record.

**Baseline strength:** recommendation, resume, Library, programs, persistence all exist.
**Baseline weakness:** “Today,” featured, balanced Play Now, Continue, Program, rank, and correct-answer streak have overlapping meanings; daily ritual is not yet a singular player concept.

---

# 7. Protected Systems List

The following must not break during controlled evolution. Any modification requires documented benefit, migration plan, regression coverage, and explicit owner.

## Foundation protection

- Boot initialization order and cold-start fallback behavior.
- Publisher splash, title splash, privacy/terms acknowledgment, hosted policy links.
- Navigation routing/history/Android Back/safe-area behavior.
- Theme tokens, light/dark/high-contrast behavior, text scaling, touch-target enforcement.
- Accessibility preferences: Reduced Motion, Comfortable Timing, Reading Comfort, Color Assistance, screen-reader hints, haptics, audio controls.
- Audio bus/mute/volume behavior and safe pre-initialization handling.
- Error handling, loading states, player-safe recovery.
- Profile/Settings/Save APIs, atomic replacement, `.bak` recovery, migration compatibility.
- Offline/no-account/no-remote-endpoint posture unless an approved strategy explicitly changes it.
- Android package identity, portrait orientation, export/signing pipeline, safe permissions.

## Gameplay protection

- ChallengeSessionService as the only player-facing lifecycle/launch authority.
- Family-agnostic shared runtime and no family-ID branches in Engine/shared UI.
- Resolved instance truth before presentation.
- Generator/validator/retry/fallback fairness model.
- Family-owned scoring/difficulty/exposure/tutorial/rendering.
- Interaction adapters as payload collectors only.
- Deterministic regression fixtures and hidden compatibility coverage.
- Evidence/replay metadata in canonical results.

## Product protection

- Challenge Library generic discovery path.
- Recommendation/Continue/Program selection through the runtime.
- One local Witness Progress/Profile record, not parallel player stores.
- Existing player history/favorites/Program data preservation.
- Current content asset ownership and versioning.

---

# 8. Strengths to preserve

1. **Evidence-first results:** the strongest product differentiator.
2. **Fairness architecture:** seeded truth, validation, fallback, and reveal support are unusually valuable.
3. **Scene Investigation content base:** five ordinary worlds are enough to establish a flagship before expansion.
4. **Generic extension architecture:** new content/families do not require a rebuild.
5. **Offline/private trust:** no account/ads/network dependency lowers friction.
6. **Accessibility depth:** comfort is part of fair observation.
7. **Local save quality:** player trust survives short-session product evolution.
8. **Programs/recommendations:** reusable infrastructure for a future Brief without alternate paths.

---

# 9. Baseline weaknesses preventing flagship quality

- No human proof that the first Witness Moment is understood, fair, or replay-worthy.
- No physical Android proof for timing, touch, sound/haptics, safe areas, high text size, or accessibility alternatives.
- Home/daily/Continue semantics are not one clear return ritual.
- Result evidence is technically strong but competes with metrics and several exit paths.
- Scene-first witness identity competes with equal family catalog treatment and thriller-style marketing material.
- Progression has too many possible signals without validated player hierarchy.
- Older docs/screenshots/test baselines drift from current Home V2/mobile/visual changes.
- Legacy ExperienceRegistry/ContentService paths obscure the active Challenge Family extension model.

---

# 10. Technical and experience risks

## Technical risks

- Regressing boot, Android rendering, splash order, or safe-area behavior during visual changes.
- Breaking profile/save compatibility by adding parallel Witness Record/thread state.
- Introducing family-specific logic into shared runtime/Home/Programs.
- Failing to update frozen baselines/tests after intended platform changes.
- Treating local static checks as substitute for actual Godot/device validation.
- Asset growth, texture memory, rendering fallback, or audio layering regressions on real devices.

## Experience risks

- Turning the product into a dashboard, assessment, or generic mini-game anthology.
- Making “two seconds” feel unfair or misleading at first play.
- Allowing score/achievements to outrank evidence reveal.
- Creating daily obligation/streak anxiety rather than a return ritual.
- Making content expansion more visible than scene quality.
- Introducing narrative Threads before the normal Witness Moment earns retention.

This baseline is the control point for every update in the Flagship Evolution Roadmap.

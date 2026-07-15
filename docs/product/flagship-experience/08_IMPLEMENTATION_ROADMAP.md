# Flagship Experience Reconstruction Roadmap

**Scope:** reconstruct the central Scene Investigation Witness Moment before redesigning the full product or expanding the portfolio.
**Rule:** validate each phase with real users and devices before broadening scope.

---

# Roadmap principles

1. Reuse the current Challenge Family/runtime/save/accessibility architecture wherever possible.
2. Do not add new Challenge Types, economy, competition, cloud, or story systems to compensate for an unclear core.
3. Treat the first scene, daily brief semantics, result reveal, and progression meaning as product-critical content decisions.
4. Separate required flagship reconstruction from premium polish and optional expansion.
5. Update tests, baselines, documentation, and device evidence alongside any behavior change.

---

# Phase 1 — Required changes for the flagship experience

## Objective

Make the first Scene Investigation Witness Moment, its evidence reveal, and its immediate continuation unmistakably clear and fair.

## Required product outcomes

- One intentional first-session path from privacy acknowledgment to first Scene Investigation result.
- One explicitly authored/configured first Witness Moment, rather than an implicit first registry template.
- One concise witness-contract explanation with no duplicate conceptual tutorial.
- A novice-friendly exposure progression that teaches fairness before the 2-second standard rhythm.
- A Scene Investigation result hierarchy that places scene evidence before score/progression noise.
- One truthful primary post-result continuation based on the current brief state.
- A defined meaning for the Daily Witness Brief/Continue state, even if its first version uses existing Program infrastructure.
- Device and human validation of this complete path.

## Existing systems to reuse

| Existing system | Reuse role |
|---|---|
| `ChallengeSessionService` | Remains the only launch/session/result/return authority. |
| Scene Investigation family | Supplies scene generation, validator, difficulty/exposure policies, scoring, renderer, tutorial, and reveal data. |
| `TutorialScreen` and family tutorial | Hosts the one deliberate Scene Investigation learning path. |
| `RecommendationService` / `ProgramService` | Resolves first, resume, daily, and next-moment state without alternate gameplay routes. |
| Observation / Recall / Result routes | Continue to host the generic lifecycle and family-specific renderer data. |
| `PlayerProgressService` / Profile / SaveService | Record first moment and brief state safely. |
| Theme / Accessibility / Audio / ResponsiveLayout | Preserve fair presentation across settings and devices. |
| Existing scene content | Office/Kitchen/Workshop/Travel Desk/Garden Bench provide the first content base. |

## New or changed systems required

Keep additions narrow and content-led:

- **First Witness Moment definition:** a small explicit content/configuration contract identifying the intended first scene, seed/composition constraints, exposure, question category, distractor policy, and reveal acceptance requirements.
- **Witness Brief semantics:** clarify or minimally extend existing Program/recommendation metadata so “today,” “resume,” and “next” refer to one player-understood unit.
- **Result hierarchy/reveal behavior:** evolve presentation/content data and family view behavior where necessary; do not replace the generic result contract.
- **Onboarding policy:** one documented rule connecting title intro, family tutorial completion, practice, and first-session completion.
- **Validation artifacts:** current runtime screenshots/video, first-session fixture coverage, updated static baselines, physical-device evidence.

## Explicitly out of scope

- New challenge families.
- New currency, store, collection economy, or leaderboard.
- Narrative case system or trailer-inspired story content.
- Cloud accounts/sync.
- Full Home/Library/Profile visual redesign.
- Broad content expansion before first-session research.

## Expected impact

**Highest impact.** This phase determines whether the product’s central promise is understandable, emotionally satisfying, fair, and worthy of future polish.

## Exit criteria

- First-time players understand the witness contract without coaching.
- Players experience the reveal as evidence rather than merely a score.
- A fair miss produces “I see it now” behavior/language.
- Players choose a second Witness Moment voluntarily at a meaningful rate in research.
- Full first-session and device/accessibility paths pass on target Android hardware.
- Current test/documentation baselines accurately represent the changed behavior.

---

# Phase 2 — Premium flagship polish

## Objective

Make the validated Witness Moment feel composed, tactile, and coherent from scene arrival through evidence reveal and brief closure.

## Product outcomes

- A unified editorial-evidence visual language across flagship scenes, observation stage, evidence highlight, result, and brief closure.
- Purposeful motion hierarchy: scene → conceal → context return → evidence focus → continuation.
- Cohesive sound/haptic hierarchy with no punishment or sensory overload.
- Device-proven typography, safe areas, contrast, touch targets, text scaling, reduced motion, and comfort timing.
- A Witness Record presentation that makes continuity meaningful without recreating a dashboard.
- Real gameplay footage/store assets that show the actual flagship experience rather than a trailer-only promise.

## Existing systems to reuse

| Existing system | Reuse role |
|---|---|
| VisualStyleSystem and sprite/vector fallback | Improve/standardize Scene Investigation art without altering game truth. |
| ThemeService | Token-driven dark/light/high-contrast typography and surfaces. |
| AccessibilityService and settings | Reduced Motion, High Contrast, color assistance, text scale, timing, haptics. |
| AudioService | BGM/cue routing, ducking, volume/mute, cached packaged audio. |
| Result/Observation screens | Retain route lifecycle while refining information hierarchy. |
| Profile/history/progress services | Supply Witness Record information without creating a second progression store. |
| ResponsiveLayout/AppShell | Preserve mobile-first safe-area, lifecycle, and Back behavior. |

## New or changed systems required

- Mostly presentation/content work, not new platform services.
- Family-scene art direction and acceptance assets for the flagship category set.
- Evidence reveal choreography/data requirements where current highlight/reveal does not satisfy the specification.
- A curated current-record summary based on existing progress/history fields.
- Capture and review workflow for actual device footage, audio, and accessibility states.

## Expected impact

**High impact after Phase 1 is proven.** This phase turns a working loop into a premium, recognizable, trustworthy ritual. It should not be used to hide unresolved fairness/onboarding problems.

## Exit criteria

- Players describe the presentation as focused, fair, calm, and intentional.
- Reduced Motion/High Contrast/text scaling/audio-off states preserve the same evidence meaning.
- Audio and haptics pass phone-speaker/headphone physical review.
- The flagship path looks and behaves correctly across the supported Android device matrix.
- Store screenshots/video are captured from the real runnable product.

---

# Phase 3 — Evidence-based expansion opportunities

## Objective

Expand only where Phase 1–2 research identifies a specific gap in freshness, accessibility, or meaningful long-term relationship.

## Candidate opportunities, gated by evidence

| Opportunity | Existing foundation | Evidence required before authorization |
|---|---|---|
| Additional Scene Investigation world/content packs | Family content architecture, generator, truth graph, visual pipeline, templates. | Existing five worlds show real fatigue or players ask for a distinct observation grammar. |
| A more deliberate rotating Witness Brief | Program policies, daily selection, content metadata, runtime context. | Players understand/value the first brief and return for it. |
| Elevated Spot the Difference companion role | Spatial Tap, paired scene generator, result evidence, tutorial. | It materially improves first clarity, variety, or retention without replacing witness identity. |
| Meaningful Moment Archive refinement | Existing history, favorites, progress, profile data. | Players want to revisit/remember past moments and can explain why. |
| Lightweight sharing of spoiler-safe witnessed moments | Scene/reveal visuals and result data. | Players naturally want to show a moment; privacy/spoiler rules are defined. |
| New Challenge Family | Generic family/interaction architecture and seven documented concepts. | A research-proven player need cannot be served by current five modes/content. |
| Cloud/account continuity | Profile/save architecture could be adapted later. | Local-only progress demonstrably blocks the target audience, with privacy and migration strategy approved. |

## Explicit expansion guardrails

Do not authorize an opportunity merely because the technology can support it. It must:

1. strengthen the Witness Moment or its daily ritual;
2. preserve fairness and offline/trust posture unless a deliberate strategy changes it;
3. have a clear player need observed in research;
4. avoid creating a second product identity;
5. pass the existing Engine/Game/Content boundary and accessibility contract.

## Expected impact

**Variable.** Phase 3 is not a mandatory list. Its purpose is to give the now-proven flagship more depth where evidence warrants it.

---

# Cross-phase validation requirements

Every phase must include:

- fresh Godot import and runtime suite on the actual revision;
- repaired/updated static baseline ownership rather than ignored verifier failures;
- first-time and returning human play sessions;
- physical Android boot, touch, audio/haptic, save, safe-area, performance, and accessibility checks;
- validation under High Contrast, Text Size, Reduced Motion, Comfortable Timing, Reading Comfort, Color Assistance, screen-reader hints, audio off, and haptics off where applicable;
- updated product documentation that describes the active routed experience rather than a prior phase artifact.

---

# Sequencing decision

**Do Phase 1 before any full-app visual redesign.**

A new Home, Library, profile, trailer, or generalized content expansion can only serve the flagship after the first Witness Moment has proven its emotional and behavioral contract. The flagship is the skeleton; every future product surface should serve it.

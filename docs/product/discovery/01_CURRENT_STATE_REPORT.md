# Current State Report — Two Second Witness

**Discovery snapshot:** 2026-07-15
**Repository revision inspected:** `45df4f4d1e86021bb0e972d3204d70d43b8cf778` (`main`)
**Scope:** source, content, product/release documentation, generated review artifacts, Android configuration, GitHub PR/check history, and local static verification. This is a reconstruction of the product as it exists; it is not a redesign proposal.

## Evidence and confidence

- The active Android/Godot application is version **4.0.0**, portrait-first, offline-first, and starts at `AppShell.tscn`.
- The active Home route is **`HomeV2Screen`**, introduced after the earlier Phase 3/4 Home screenshots and specifications. Older `HomeScreen` remains in the tree but is not routed.
- The repository’s local Git graph is shallow, so GitHub pull-request history—not local commit ancestry—was used for iteration history.
- Godot is not installed in this analysis environment. The current `main` GitHub workflow passed its **project import** check, but it does not execute the full runtime suite. See **Current validation reality** below.

---

# 1. Current Product Snapshot

## What the application currently is

**Two Second Witness is a five-mode, offline mobile observation-and-recall game.** A player briefly studies a visual or textual moment, responds after it is concealed or changed, then receives a result that explains the evidence. It is positioned as a premium puzzle experience rather than an assessment or “brain-training” product.

The live product catalog contains five player-visible **Challenge Types**:

| Challenge Type | Player action | Production templates | Current level requirement |
|---|---|---:|---:|
| **Scene Investigation** | Study an ordinary generated scene; answer one question about a detail, relationship, count, attribute, or location. | 5: Office, Kitchen, Workshop, Travel Desk, Garden Bench | 1 |
| **Flash Words** | Catch a word, pair, stream, or exact position in a rapid typography sequence; choose what appeared. | 4 | 1 |
| **Spot the Difference** | Compare matched visual states and tap the one changed region/detail. | 4 | 1 |
| **Object Recall** | Remember an isolated object set and select the correct members or positions. | 4 | 1 |
| **Pattern Recall** | Observe a grid path, symbol sequence, or cumulative pattern and reproduce its order. | 3 | 2 |

That is **20 production templates**. Five deterministic image-based challenges are also present, but are intentionally hidden as regression fixtures rather than product content.

## Who it is for

The product is built for people who want short, self-contained visual puzzle rounds: mobile players who enjoy noticing details, remembering a moment, comparing changes, or reconstructing patterns. Its strongest fit is someone seeking a quick, offline, no-account puzzle session rather than a narrative detective game, a social game, or a quantified self/ability-testing tool.

The intended emotional promise is explicit in the product roadmap and family specifications:

> “I can’t believe I missed that.”

The inverse promise is equally important: a miss should never feel arbitrary or unfair.

## What the user does

A user enters a recommended round, chooses a Challenge Type from the Library, or starts a curated Program. The runtime:

1. resolves a family and template;
2. applies difficulty and exposure policies;
3. seed-generates and validates an instance;
4. presents the moment;
5. collects one family-appropriate response;
6. scores it with family-owned rules;
7. shows evidence and an explanation;
8. records Witness Progress, mastery, history, achievements, favorites, and Program progress; and
9. offers retry, a next round, Library, or Home.

## The main experience

The core experience is **brief observation followed by accountable recall**. The product’s most consistent rhythm is:

```text
Notice a moment → lose or compare the evidence → make one decision → see why → continue
```

Scene Investigation is the clearest expression of the “witness” fantasy: ordinary scene, concealed evidence, one fair question, then an annotated reveal. The other four modes broaden the same rhythm into verbal, comparative, set, and sequential forms.

## What makes it different

1. **Evidence-first misses.** The result is not only correct/incorrect; family renderers can show the relevant scene area, changed region, set membership, or numbered sequence, plus explanatory text.
2. **Fairness is implemented as a system.** Each family owns generator, validator, difficulty, exposure, scoring, fallback, and tutorial behavior. The shared runtime rejects invalid candidates, avoids recent signatures, and preserves deterministic seeds.
3. **Five genuinely different response mechanics on one platform.** Single Choice, Multiple Choice, Spatial Tap, and Sequence Input are used today; the adapter registry also supports Region Selection and Ordering for future families.
4. **Offline and privacy-minded by default.** There is no account, ad SDK, remote content endpoint, Internet permission, or remote analytics endpoint in the configured production build.
5. **A reusable product platform already exists.** Catalog, Program, progression, Library, Profile, tutorials, accessibility controls, and result flow discover registered families rather than naming individual families in shared code.

## Complete today

### Product and gameplay

- Five playable Challenge Types, 20 templates, five family tutorials, and family-specific evidence reveals.
- Seeded generation, validation, bounded retries, known-valid fallbacks, reproducibility metadata, and recent-signature rejection.
- Home V2 recommendation/continue entry point, Challenge Library, Programs, Profile, Achievements, Settings, About, and native Back handling.
- Nine curated Programs and 26 persisted achievement definitions.
- Witness levels/ranks, per-family mastery, accuracy, streaks, favorites, recent history, and local collection counters.
- Audio cues, route-based BGM, optional haptics, light/dark themes, text scaling, High Contrast, Reduced Motion, Reading Comfort, Comfortable Timing, Color Assistance, and screen-reader-hint paths.

### Platform and release preparation

- Atomic JSON saves, `.bak` recovery, stale temp cleanup, and a limited version-one display-name migration.
- Package identity, Play Store export preset, arm64, portrait orientation, immersive mode, splash configuration, and offline Android permissions are configured.
- Store listing copy, privacy policy, credits/open-source notices, release workflow, release checklist, trailer assets, and promotional graphics exist.

## Incomplete, unproven, or materially ambiguous

### Product proof

- **No human playtesting evidence exists.** Documentation explicitly says that 20/50-round sessions, perceived fairness, fatigue, voluntary replay, and final balance remain open.
- **No physical Android validation evidence exists.** Sponsor-first boot, gesture navigation, spatial tapping, audio/haptics, 140% text, and diverse device layouts remain release gates.
- **No signed AAB review or real save-upgrade verification exists.** The release checklist still requires signing continuity, installation, dependency inspection, real old-save migration, and store/legal signoff.
- **There is no behavioral product data loop.** Analytics is local-only and bounded; there is no remote telemetry endpoint, account, cloud sync, or evidence of real-player retention/selection data.

### Scope and content

- The planned portfolio contains seven unimplemented families: Motion Tracking, Hidden Detail, Color Recall, Direction Recall, Symbol Recognition, Number Recall, and Sound Recognition.
- English is the only declared product language.
- Progress is local to a single installation; there is no cloud backup, restore, cross-device identity, or shared/social layer.
- Programs summarize aggregate progress but do not maintain a rich per-run archive.
- Collections are counters/derived goals, not an inventory, reward, or content-collection system.
- The business model called “premium” is not represented by a purchase, subscription, entitlement, or price system in the application source.

### Product coherence and maintenance

- Current source and older product documents are not fully synchronized. The routed Home V2 was added after Phase 3/4 artifacts; those artifacts depict the earlier dashboard-like Home.
- The code has two older, mostly dormant content paths: `experiences/`/`ExperienceRegistry` and `ChallengeRegistry`. The former legacy Flashword model is autoloaded but not initialized or referenced by active screens; the latter remains intentionally active only for hidden deterministic fixtures and UI fallbacks.
- Product-facing marketing uses a cinematic psychological-thriller/detective frame, while the app itself offers abstract and ordinary-scene puzzle rounds. The relationship between those identities is not yet evidenced by player research.

---

# 2. Current User Experience Flow

## The actual journey in source

| Journey stage | What happens now | What works well | What feels weak or uncertain | What could become stronger (without prescribing a redesign) |
|---|---|---|---|---|
| **Launch / boot** | Android system splash uses a dark surface; Godot’s boot splash, a 1.4-second publisher screen, and a branded title/loading screen follow. Boot initializes config, saves, settings, theme, content/runtime, audio, and navigation. | Explicit service order, timeout handling, sponsor-first intent, loading feedback, reduced-motion consideration, safe-area shell. | Physical Android first-frame order and blank-screen behavior are unverified. A recent rendering change from `opengl3` expectation to `vulkan` has not been reconciled with several static baselines. | The launch promise can only be judged after device evidence establishes what a new player actually sees and how long it takes. |
| **First-launch acknowledgment** | A blocking Privacy & Terms modal appears when the current policy version has not been accepted. It states local progress, no account, no personal information, and no ads. Acceptance persists in both profile/settings areas. | Clear local/offline trust proposition; policy/terms links; explicit acceptance; 48-pixel target styling. | The policy page is linked externally, so real device/browser behavior and legal approval are still unknown. | The product needs evidence that users understand the offline/local-data promise without mistaking it for an account setup. |
| **Intro/onboarding** | The title screen checks `onboarding_completed`. For a new profile it dynamically chooses the first visible registered family—currently Scene Investigation by manifest order—and opens its family tutorial and practice round. Separately, first entry to every family is tutorial-gated unless tutorials are disabled. | Family tutorials are mechanic-owned, versioned, replayable from Library, and launch normal runtime practice. | Documentation/comments say tutorials appear only when a family is entered, while current title-screen logic also launches an intro tutorial. The first family is implicit registry ordering, not an explicitly stated product decision. Onboarding is marked complete only through result exit actions. | The intended first-session teaching contract, success condition, and role of the flagship family need to be explicitly validated. |
| **Home** | `HomeV2Screen` shows greeting/rank/level progress, one dominant “Today’s Witness Experience” card, answer-streak and achievement pills, plus compact Library and Programs paths. It promotes Continue when a recent family or Program exists; otherwise it uses `recommend_start`. | One clear primary action; data-driven recommendation; no family-specific branching; loading state and direct route to runtime are preserved. | “Today” is presentation language, but the card uses the balanced Play Now recommendation rather than the separate deterministic daily-feature recommendation. “Streak” is a consecutive-correct-answer streak, not evidence of a daily return habit. Home V2 has no current runtime screenshot artifact in the repository. | The intended meaning of “daily,” “continue,” identity, and return motivation must be established against observed player behavior. |
| **Selection / discovery** | Bottom tabs lead to Home, Challenge Library, Profile, and Settings. The Library lists all five active families with art, lock state, mastery, accuracy, best streak, favorite, Play, and Tutorial replay. Programs is a non-tab route reached from Home or other entry points. | The catalog is generic; four types are available at level 1 and Pattern Recall unlocks at level 2. Tutorials and favorites are close to selection. | A player sees five types but has little empirical guidance on why to choose one beyond description and progress. Many older visual artifacts show only the original two-family catalog. | The product has enough catalog and recommendation data to investigate whether selection is meaningful, confusing, or unnecessary. |
| **Core activity: Observe** | A shared Observation screen presents family-provided renderer data for a timed scene, flash, paired comparison, tray, or sequence. It shows `OBSERVE`, timer, duration, family identity, audio/haptic cues, and a compact exit control. | The renderer is family-owned and the shell stays generic. Generated truth is resolved before display. Timing, safe areas, and reduced motion are considered. | The experience has not been evaluated on physical touch devices, across accessibility settings, or under sustained play. The very short product name can set a uniform “two second” expectation even though current exposure policies vary by family and difficulty. | The relationship between the title’s promise, timing variability, tension, and fairness needs human validation. |
| **Core activity: Recall / response** | A generic Recall host loads an adapter specified by the family: single choice, multiple choice, spatial tap, or sequence input. Response time begins here; the scoring policy interprets the payload. | Clear architecture boundary: adapters collect interaction only; scoring stays family-owned. Dynamic controls receive shared touch-target styling. | Spatial Tap, Multiple Choice, and Sequence Input have not passed the physical-device accessibility matrix. The shared host creates visual consistency but may blur distinctions between different family fantasies. | Human observation should determine whether players understand the task instantly and whether each interaction feels distinct enough. |
| **Results** | A result says `CORRECT!` or `I MISSED IT.`, shows family explanation and rendered evidence/reveal, progression/achievement/Program context, then offers next challenge, retry, Library, and Home. | This is the product’s strongest fairness mechanism: the answer is explained rather than merely graded. Multiple continuation choices support different intents. | The evidence experience is tested structurally, not proven emotionally. Four exit paths can make the immediate post-result decision meaningful or ambiguous; no behavior data says which. | The relative value of reflection, mastery, retry, variety, and Program continuation needs observed use rather than assumptions. |
| **Progression and return** | Results update profile stats, family mastery/confidence, Witness Progress, ranks, history, favorites, achievements, Program progress, and recommendations. Returning launches skip privacy if accepted and route toward Home after title loading. | Everything persists through the same save/profile layer. Continue prioritizes an unfinished Program, then recent family, then a recommendation. | There is no verified day-based loop, externally measured retention, content calendar, cloud continuity, reward economy, or real pacing study. Daily/weekend programs depend on device time. | The meaning of long-term progress—and what would make a player choose to return tomorrow—remains an open product question. |

---

# 3. Existing Systems Inventory

## Gameplay and content systems

| System | Current purpose | Current quality | Future usefulness |
|---|---|---|---|
| **Challenge Family contracts** | `ChallengeFamily`, `ChallengeTemplate`, `ChallengeInstance`, `PresentationProfile`, `TutorialProfile`, `InteractionProfile`, validation and result contracts define the product boundary. | Strongly structured and explicitly documented. | High: supports new families/content without changing shared navigation or persistence. |
| **Challenge Runtime** | Orchestrates family → template → difficulty → exposure → generation → validation → presentation → response → result → progress → recommendation. Uses three bounded attempts and fallback. | A mature reusable core with deterministic seed/replay support. | High: the best foundation for expansion and controlled experimentation. |
| **Five production families** | Supply separate generator, validator, policy, scoring, tutorial, renderer, metadata, and reveal behavior. | Functionally broad: scene, word, comparison, set, and sequence play. Human quality/fairness remains unproven. | High: enough mechanical range to learn which fantasy is truly flagship. |
| **Interaction Adapter Registry** | Generic Single Choice, Multiple Choice, Spatial Tap, Region Selection, Ordering, and Sequence Input payload collection. Drag/Drop and Text Entry are reserved. | Good separation of mechanics from correctness. Only four modes are visibly used by current production families. | High: reduces cost/risk of future response styles. |
| **Family content packs** | 120 scene archetypes across five settings, 373 reviewed English words, 48 object identities, 12 named pattern symbols, visual assets and family policies. | More than a prototype catalog; still needs sustained human freshness review. | High: content can deepen before new infrastructure is needed. |
| **Deterministic regression fixtures** | Five fixed historical challenges exercise boot, navigation, scoring, persistence, and compatibility. | Useful technical safety net; not player-visible content. | High for regression; low as product content. |

## Product, UI, and navigation systems

| System | Current purpose | Current quality | Future usefulness |
|---|---|---|---|
| **App shell and navigation** | Central routes, history, safe-area insets, chrome, loading, errors, cached product screens, uncached gameplay screens, Android Back. | Broadly robust in source; physical-device proof is open. | High: routes and shell can host substantial product evolution. |
| **Home V2** | Singular next-action entry with identity, recommendation/continue, compact progress, Library, and Programs. | Recently added and source-connected to existing services; its runtime presentation has not been manually reviewed in this repository. | High as a focused entry surface; its actual product role needs validation. |
| **Challenge Library** | Generic dynamic catalog, lock handling, favorites, mastery, history indicators, Play, tutorial replay. | Complete data surface and reusable card system. | High: new families appear through metadata. |
| **Programs** | Nine data-defined, finite curated runs using daily rotation, focus tags, least-used mixed rotation, favorites, and weekend availability. | Works as a selection policy over the same runtime. Current quality is limited by no player pacing evidence and device-clock dependence. | High: supports future curation without parallel gameplay. |
| **Profile / Achievements / Collections** | Witness record, rank, mastery, history, achievements, favorite types, Program record, derived collections. | Broad but dashboard-like; recent UX work intentionally hides some legacy/developer detail. | High data foundation; unclear which signals matter to players. |
| **Settings / accessibility** | Theme, audio buses, haptics, text size, contrast, reduced motion, color assistance, comfort settings, tutorials, local analytics, privacy/about. | Unusually complete in code for this stage. Matrix validation on actual devices is outstanding. | High: preserves accessibility and preference control as content expands. |

## Data, platform, and support systems

| System | Current purpose | Current quality | Future usefulness |
|---|---|---|---|
| **Profile / Witness Progress** | Local player identity, stats, per-family mastery, recent signatures, history, ranks, favorites, Program and achievement state. | One shared persisted source; profile schema merges defaults. | High: progression can evolve without a second store. |
| **Save service** | Versioned JSON, temp verification, atomic replacement, `.bak` recovery, delete cleanup. | Strong local design; real old-build migration and force-close tests remain open. | High: protects player trust and is a good base for any future migration decision. |
| **Recommendations** | Chooses first play, balanced progress play, recent-family continue, deterministic featured type, and next template. | Data-driven and generic. Home V2 currently does not use all exposed recommendation fields. | High: supports personalization and curation, subject to product intent. |
| **Audio / haptics** | Route-based BGM, preloaded UI/gameplay/result cues, per-bus volumes/mutes, ducking, optional haptics. | Recent hardening addressed invalid volume/NaN paths; no hardware listening pass. | Medium-high: a cohesive feedback layer already exists. |
| **Analytics** | Consent/settings-aware local event buffer for launches, screens, preparation, results, tutorials, settings, errors. | Privacy-aligned and bounded; intentionally not a research/telemetry pipeline. | Medium: can support device diagnostics, but does not currently answer retention/product questions. |
| **Theme / ResponsiveLayout** | Tokens, dark/light/high-contrast variants, text scaling, safe areas, mobile gutters, tablet/foldable centering, target enforcement. | Well centralized, with current validator/baseline drift. | High: avoids scattered UI-level policy. |
| **Error handling / EventBus** | Player-safe messages, safe recovery, global event wiring. | Reusable Foundation infrastructure. | Medium-high: important for reliability and future integrations. |
| **Legacy Experience content path** | Old `ExperienceRegistry`, `ContentService`, and `FlashwordExperience` model from the foundation era. | Dormant/duplicative in the active product. `ExperienceRegistry` is autoloaded but not initialized by `AppBoot`; active UI does not query it. | Low until a deliberate compatibility decision is made; it is currently a maintenance and conceptual-cost source. |

---

# 4. Current Validation Reality

The repository contains a substantial test harness: 29 Godot runtime scripts and 17 Python static verifiers. Historical phase documents report broad passing suites and large generated-instance stress samples. Those records are valuable, but they are not the same as a current clean verification result.

## Checks observed during this discovery

| Evidence | Current finding |
|---|---|
| Latest GitHub `Foundation CI` for `45df4f4` | **Passed**, but only imports the Godot project and checks branding/assets/export markers. |
| Local Godot runtime tests | **Not run**: no `godot` binary is available in this environment. |
| Python static verifiers | **11 of 17 passed** on the inspected current revision. |
| Passing examples | Runtime architecture, Phase 3 Home architecture, Phase 4 product architecture, Phase 5 architecture/content/preparation, Scene/Flash content, gameplay immersion, settings/profile optimization. |
| Failing examples | Documentation, Phase 3.5 polish, Phase 5 interaction baseline, Phase 5.5 platform freeze, Phase 6 readiness, and visual-style migration safety. |

## What the failures mean

- The documentation/Phase 3.5 checks find the word **“cognitive”** only in a Home V2 source comment, not in rendered player copy.
- Phase 3.5 and Phase 6 still expect `rendering_device/driver.android="opengl3"`; current project configuration uses `"vulkan"` after PR #30 explicitly changed the value to address Android rendering risk.
- Phase 5/5.5/6 baselines are out of date for five platform files changed in subsequent mobile/home/audio work: `project.godot`, `AppRoutes.gd`, `AudioService.gd`, `ThemeService.gd`, and `AppShell.gd`.
- The visual migration safety verifier requires a temporary `/tmp` baseline that is absent in a fresh environment, so it cannot independently prove the stated “logic unchanged” claim.

These are primarily **verification-governance and documentation-drift signals**, not proof that a player-facing runtime path is broken. They do mean current readiness cannot be described as fully green without re-establishing a clean baseline and running the Godot/device gates.

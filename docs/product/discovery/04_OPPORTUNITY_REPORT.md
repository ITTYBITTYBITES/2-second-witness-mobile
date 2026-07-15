# Opportunity Report — Two Second Witness

**Discovery snapshot:** 2026-07-15
**Important boundary:** this report identifies latent value in systems that already exist. It does not choose a redesign direction or prescribe visual/UI changes.

---

# 1. Untapped Potential Already Present

## A. The fairness/reveal loop can be a signature experience

### What exists

Every family resolves answer truth before presentation and supplies a reveal/evidence mode after response. Scene Investigation highlights the relevant object/relationship, Spot the Difference marks matched change regions, Object Recall can identify not-shown evidence, Pattern Recall numbers the correct sequence, and Flash Words compares exact observed/selected material.

### Why it is underexploited

This is richer than a quiz score, but its actual emotional value has never been measured with players. The current product has evidence that it can *explain* a miss; it does not yet have evidence that it creates the desired “I missed it” response often enough to be the product’s memorable promise.

### Potential to investigate

The existing result system could support a distinctive product identity centered on discovery, trust, and a satisfying second look—not merely performance tracking. This is an experiential opportunity, not a request for an additional system.

---

## B. The existing five-family portfolio is a research asset

### What exists

The current catalog spans five different decision types using the same lifecycle:

| Family | Existing player decision | What it can reveal about player preference |
|---|---|---|
| Scene Investigation | Notice a detail in a broad ordinary scene. | Whether the witness fantasy and visual scanning are the strongest core. |
| Flash Words | Recognize exact text/order from a flash. | Whether rapid, lightweight verbal recognition creates the desired tension. |
| Spot the Difference | Locate one change between visual states. | Whether direct visual search/tapping is more immediately legible and marketable. |
| Object Recall | Reconstruct set membership/position. | Whether clean, low-clutter recall is more approachable than scene complexity. |
| Pattern Recall | Reproduce a visual sequence. | Whether abstract structured recall provides satisfying mastery or breaks the witness fantasy. |

### Why it is underexploited

The architecture treats all five as available catalog members, and the Home recommendation balances progress. No qualitative or quantitative evidence says whether they should be equally central, serve different audiences/moods, or support one flagship experience.

### Potential to investigate

The portfolio can answer the most important product question before any expansion: **what do players choose voluntarily, replay, talk about, and perceive as fair?** The answer should come from existing families before adding the seven planned ones.

---

## C. The content depth is larger than its current presentation implies

### What exists

- Scene Investigation: five ordinary settings, 120 archetypes, five question categories, four timing tiers, sprite/vector render fallbacks.
- Flash Words: 373 reviewed English words and four decision modes.
- Spot the Difference and Object Recall: 48-object pools, four templates each.
- Pattern Recall: 12 named symbols, 3×3/4×4 legal paths, three presentation styles.
- Runtime: recent-signature protection, difficulty/exposure axes, and seeded variety.

### Why it is underexploited

Source-level content volume does not automatically communicate variety to a player. Existing Home V2 intentionally reduces the surface area of discovery; older Library artifacts predate three of the five families. Automated 50-round proxy results prove structural breadth but not visible perceived variety.

### Potential to investigate

The current catalog can support a more informed content-quality assessment: which settings/modes players recognize, which feel repetitive, which questions feel most fair, and whether the visible product communicates the difference between templates.

---

## D. Programs are a flexible curation engine, not merely a menu

### What exists

Nine data-defined Programs already select rounds through generic policies:

- daily deterministic rotation;
- focus-tag matching;
- least-used mixed rotation;
- favorites;
- weekend availability;
- level requirements;
- finite run length, resume, completion, and per-family counts.

Programs do not create a separate gameplay implementation; all rounds use ChallengeSessionService.

### Why it is underexploited

Programs have been implemented before their player role is known. The product currently has no evidence that players understand a “curated run,” prefer it to direct choice, finish it, or return to it. The current Home V2 promotes only a small Programs teaser.

### Potential to investigate

The system can test different *product meanings*—focused practice, discovery tour, personal favorites, daily session, or weekend longer session—without changing family mechanics. The key unresolved question is what a Program should mean emotionally and behaviorally.

---

## E. Recommendation and progression data exist beyond what Home currently expresses

### What exists

`RecommendationService.get_home_snapshot()` returns:

- balanced Play Now;
- Continue with unfinished Program priority;
- deterministic daily featured type;
- available catalog/locks;
- recent family;
- achievement previews;
- witness level/rank/progress/streak;
- featured Program and Program count.

The profile also has per-family mastery, accuracy, confidence, recent history, favorites, ranks, collections, and Program records.

### Why it is underexploited

The active Home V2 uses the recommendation/continue path, rank, correct-answer streak, achievements, Library, and Programs. It does not visibly use the separate daily featured recommendation, recent-play record, catalog breadth, or the richer Program/profile context. This is not necessarily wrong; it means the service layer is more expressive than the current presentation.

### Potential to investigate

The existing data can support an evidence-based decision about what a returning player actually needs to see: identity, a specific recommendation, continuity, mastery, discovery, a goal, or less information. No new data store is required to answer that question.

---

## F. Tutorials are a reusable first-session laboratory

### What exists

Each family owns a versioned tutorial scene. The generic tutorial host persists completion by family/version, supports replay, and can launch a practice round through the normal runtime. Automatic tutorial gating can be bypassed by a persisted Show Tutorials preference.

### Why it is underexploited

There is no observed evidence that tutorial completion leads to understanding, enjoyment, or subsequent voluntary selection. Current title logic additionally chooses an implicit first family for an intro tutorial, while documentation describes the sequence differently.

### Potential to investigate

The platform can distinguish “mechanics understood” from “product desire established,” identify whether any tutorial is unnecessary or insufficient, and clarify the intended first family without architectural work.

---

## G. Accessibility infrastructure can support broader reach if validated as gameplay quality

### What exists

- 48 logical-pixel target enforcement.
- Text scaling up to 140% in settings/tests.
- High Contrast tokens and family-renderer branches.
- Reduced Motion behavior.
- Comfortable Timing and Reading Comfort.
- Color Assistance for relevant color-dependent selection.
- Screen-reader hints and an accessible single-choice alternative for Spatial Tap.
- Separate audio, interface, effects, and haptics controls.

### Why it is underexploited

The controls are source-complete but unverified on physical devices and with real players. In a game defined by quick perception and timed recall, accommodations are central to fairness, not a compliance appendix.

### Potential to investigate

The product can learn whether its fairness promise holds across modes/settings and where accommodations create a meaningfully equivalent experience. This may reveal the true boundaries of current/future families.

---

## H. Offline trust can be a real product advantage

### What exists

No account, no remote endpoint, no ads, no Internet permission, local-only analytics with opt-out/clear, atomic recovery-aware saves, and explicit privacy copy.

### Why it is underexploited

These are meaningful product characteristics, but they do not yet have validated player value or an articulated relation to the premium proposition. Current proof focuses on source configuration, not user trust comprehension.

### Potential to investigate

The team can validate whether quick private/offline access is a genuine acquisition/retention advantage for this audience and what players expect from local-only progress.

---

## I. Audio, haptics, and artwork are already an experience layer

### What exists

Five BGM tracks route by screen; over 20 UI/gameplay/result cues are preloaded; BGM ducks at key moments; haptics are optional. The latest visual migration adds sprite-first rendering, warm earth/gold game surfaces, and vector fallbacks across all families. The repository also contains trailer, store graphics, and a brand eye motif.

### Why it is underexploited

No physical audio/haptic listening pass or visual/device review has validated whether this layer reinforces one consistent emotional product. The game UI’s theme remains primarily dark/purple, while recent family-rendering work moved toward warm grounded palettes; the trailer adds a cinematic thriller language.

### Potential to investigate

The current asset and feedback layer has enough material to assess coherence, not merely technical presence: what should feel tense, calm, premium, mysterious, playful, or reflective at each moment?

---

# 2. Areas Limited More by Presentation or Product Framing Than by Missing Systems

| Area | Existing capability | Current limitation is primarily | Evidence to gather before judging it a gap |
|---|---|---|---|
| **Daily experience** | Deterministic daily feature, Daily Witness Program, date-aware selection. | Meaning/presentation: Home calls a balanced recommendation “today,” while daily systems are separate. | Do players want one daily ritual? Do they understand why today’s round is special? |
| **Personalization** | Recommendations use plays/mastery/recent family/weights; Continue knows Program context. | Product framing: no proof that the surfaced recommendation feels personal or useful. | Player explanation, voluntary acceptance, and comparison with direct selection. |
| **Discovery** | Five-family catalog, templates, focus tags, previews, tutorials, favorites, Programs. | Presentation and decision model: current Home intentionally de-emphasizes browsing. | Can players name differences between modes and choose based on intent? |
| **Progression** | Ranks, mastery, confidence, achievements, collection progress, history, Programs. | Meaning: many signals exist but no validated hierarchy of importance. | Which milestones users remember, pursue, or ignore. |
| **Variety** | 20 templates, large content pools, seed variation, anti-repeat logic. | Perceived variety: content machinery is largely invisible until played. | Human 20/50-round fatigue and recognizability studies. |
| **Accessibility** | Controls and family-specific support paths exist. | Real-world validation: source intent needs device/player proof. | Complete physical matrix and feedback from players using accommodations. |
| **Premium polish** | Shell, audio, haptics, theme, assets, responsive layout, release assets. | Coherence/verification: actual device look and feel are not established. | Recorded device walkthroughs and first-impression review. |

---

# 3. Opportunity Constraints Already Known

Any future product work should be aware of these non-negotiable realities discovered in source:

1. **The core runtime and shared contracts are valuable infrastructure.** Replacing them would discard proven generic lifecycle, content, progression, tutorial, and interaction boundaries.
2. **All active player launches use `ChallengeSessionService`.** New entry experiences should be evaluated against that single lifecycle rather than creating bypasses.
3. **Family truth must stay resolved and validated before presentation.** The fairness contract is part of the product’s value.
4. **The app is configured offline and local-only.** Any product direction that assumes remote content, account identity, live competition, or cloud save is a strategic decision with privacy/release implications, not a small feature.
5. **Physical-device and human validation are not optional polish.** Touch precision, exposure timing, audio, performance, safe areas, and accessibility directly determine whether the core promise holds.
6. **Legacy foundation paths exist.** Future analysis should distinguish compatibility scaffolding from active architecture before counting “available systems.”

---

# 4. The Largest Untapped Potential

The central opportunity is not simply more content, more modes, or more UI. It is to use the existing product to answer a still-unresolved question:

> **What specific kind of observation moment makes someone want to become a better witness and return?**

The codebase already has enough capability to investigate that question across multiple mechanics, programs, timing policies, evidence reveals, progression signals, and accessibility states. What it lacks is real-player evidence and a clear decision about which existing strength is the product’s defining promise.

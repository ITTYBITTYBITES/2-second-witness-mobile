# Device, Accessibility, and Validation Plan

**Purpose:** ensure a timed observation product is fair, reliable, and premium on actual Android hardware—not only source-complete in headless/static validation.

---

# 1. Validation principle

A Witness Moment is only fair if the player can actually see the scene, receive the full exposure duration, make a reliable response, understand the evidence reveal, and preserve their record on the device they use.

Device quality is therefore a product/fairness requirement, not final polish.

---

# 2. Required Android test matrix

## Device classes

| Class | Required coverage | Primary risks |
|---|---|---|
| Compact phone | 360×640-class logical layout or equivalent. | Text/crowding/touch target/safe-area pressure. |
| Standard phone | Typical 1080×1920/modern logical scaling. | Baseline visual timing/performance. |
| Tall/notched phone | Cutout/gesture navigation device. | Safe areas, splash/chrome, bottom actions. |
| Low/mid-tier Android | Android 12+ physical hardware. | Frame pacing, texture/audio memory, preparation latency. |
| High-refresh phone | 90Hz and/or 120Hz device. | Timer duration accuracy, animation pacing, input acknowledgement. |
| Tablet | Large portrait screen. | Content width, scene scale, text hierarchy. |
| Foldable folded | Narrow/tall changing safe areas. | Layout/continuity. |
| Foldable unfolded/large window | Wide available width. | Centering, stage scale, no desktop-web feel. |
| Gesture navigation | Physical gesture inset. | Exit/result/brief actions safe. |
| Three-button navigation | System nav bar. | Bottom safe area/navigation coexistence. |

## Android release states

- Cold launch after device restart.
- Warm launch.
- Background/resume during title, observation, recall, result, Brief, and record.
- Airplane mode/full offline use.
- Fresh install.
- Upgrade from supported prior save.
- Corrupt primary profile/settings recovery from `.bak`.
- Signed AAB/APK installed from release configuration.

---

# 3. Timing fairness validation

## Observation duration

Validate measured duration from first stable, fully rendered scene frame until concealment begins.

| Tier | Design target | Validation requirement |
|---|---:|---|
| First moment | 4.0 s | Measured stable presentation matches configured policy within one display-frame tolerance. |
| Follow-up | 3.0 s | Same. |
| Standard | 2.0 s | Same across 60/90/120Hz tested devices. |
| Advanced | 1.8–2.0 s | No hidden frame-rate shortening or scene-load delay. |
| Expert | 1.6–2.0 s | Only after human fairness approval. |
| Comfortable Timing | Policy-derived extended duration | Normal progression and reveal quality remain equivalent. |

## Timing requirements

- Timer starts only after the scene is visually stable enough to observe.
- Resource generation/load must not consume visible observation time.
- Frame drops must not cause early concealment or duplicate route advance.
- Background/resume cannot silently complete/score a moment unfairly.
- Reduced Motion changes decorative behavior, not mechanical truth/timing policy without explanation.

---

# 4. Interaction and latency validation

## Touch/input

- Every interactive control must meet the existing 48 logical-pixel minimum.
- Tap response should produce perceptible visual acknowledgement promptly; target engineering measurement is **under 100 ms** from accepted input to state feedback on supported hardware.
- One input must create one submission; no double answer after delayed frame/tap.
- Exit confirmation must preserve active session/record behavior correctly.
- Spatial Tap, Multiple Choice, Sequence Input, and Single Choice require physical touch validation even if Scene Investigation is flagship.

## Performance targets

Targets must be measured and reported by device class rather than assumed from desktop/headless runs.

| Area | Target standard |
|---|---|
| Launch | No blank/incorrect-color frame after approved Android launch surface; no ANR. |
| Scene preparation | Player-facing loading only while needed; target scene is stable before observation timer begins. |
| Frame pacing | No perceptible sustained jank during scene observation/reveal on supported devices; log percentile frame times by device class. |
| Input | No lost/double input; prompt state acknowledgement. |
| Memory | No unbounded rise through 50-round session; remain inside documented device budget. |
| Audio | No repeated/stacked cue, pop, mute failure, or BGM leak across route transitions. |
| Save | Atomic save/recovery works; visible save work does not block core interaction. |

---

# 5. Accessibility validation matrix

For each flagship path—launch → first moment → recall → reveal → Brief → Witness Record—test:

| Setting | Required evidence |
|---|---|
| Default | Full visual/audio/timing path. |
| 140% Text Size | No clipped question, explanation, action, privacy, or record copy. |
| High Contrast | Scene/question/evidence remain separable; no token-only assumption. |
| Reduced Motion | Same evidence hierarchy without motion dependence. |
| Comfortable Timing | Fair extended exposure, normal progress. |
| Reading Comfort | Flash/word-related settings do not destabilize flagship selection/record. |
| Color Assistance | No color-only Scene Investigation truth; visual alternatives remain clear. |
| Screen-reader hints | Routes/controls/result language are ordered and understandable. |
| All audio muted | No answer/reveal meaning lost. |
| Haptics off | No interaction/result meaning lost. |
| Gesture/three-button nav | Back/exit/result/Brief actions safe and discoverable. |

Accessibility testing must include real participant feedback where possible; passing a static renderer branch is not proof of equivalent player experience.

---

# 6. Validation levels

## Level 1 — Automated/static

- Fresh Godot import and all source script loading.
- Runtime/unit/stress tests with isolated save homes.
- Content JSON/schema/resource/path checks.
- Architecture checks: no family-specific shared branches, runtime launch authority preserved.
- Baseline/hash verification updated for intentional changes.
- Asset import/size/compression checks.

## Level 2 — Instrumented local/device

- Startup duration, screen construction, challenge preparation, memory, and texture measurements.
- Observation timer capture at 60/90/120Hz.
- Input acknowledgement/duplicate submission test.
- Route/audio/haptic lifecycle test.
- Save/recovery/upgrade/force-close tests.

## Level 3 — Human product validation

- First-time no-coaching journey.
- Returning Brief comprehension and voluntary return behavior.
- Correct/missed evidence fairness reaction.
- 20/50-round scene fatigue/variety sessions.
- Accessibility participants/settings behavior where feasible.

No level substitutes for another.

---

# 7. Acceptance criteria and release blockers

## Hard blockers

- Blank screen, incorrect splash order, crash, ANR, or missing resource.
- Observation timing that is shortened/ambiguous due to rendering/load/frame behavior.
- Lost/double response input or incorrect scoring/result route.
- Evidence reveal inaccessible or unreadable in required settings.
- Save loss/recovery failure, upgrade corruption, or offline failure.
- Critical layout crop/unsafe action on supported device classes.
- Signed artifact permission/dependency/store mismatch.

## Product blockers

- New players cannot explain Witness Moment after first session.
- Missed answers are experienced as unfair or judgmental.
- Result is perceived primarily as score feedback rather than evidence.
- Daily Brief feels like a task/streak obligation.
- Scene quality/replay evidence is insufficient for stated premium claims.

## Release evidence package

Every flagship release must archive:

- device matrix results;
- accessibility matrix results;
- first-session and replay research summary;
- timing/performance/memory measurements;
- signed artifact/version/package/dependency report;
- screenshots/video from actual device build;
- known issues, severity, owner, rollback/staged rollout plan.

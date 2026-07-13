# Two Second Witness 4.0.0 — Runtime Validation Guide

Use this guide to validate PR #23 / version 4.0.0 in Godot and on Android. Execute tests on a clean install first, then repeat key launch and persistence tests as a returning player.

Record every failure with device, OS version, build type, exact route/screen, screenshot or video if possible, and the defect reference used by your tracker.

## Test Matrix

Minimum devices:

- Compact phone / 360×640-class logical layout
- Standard Android phone
- Tall/notched Android phone with gesture navigation
- Android tablet or large-screen emulator

Minimum settings passes:

- Default settings
- 140% text size
- Reduced Motion
- High Contrast
- Comfortable Timing
- Muted audio and haptics off

---

## RC-001 — Clean Install First Launch

- **Feature:** First-time launch flow
- **Preconditions:** App freshly installed or app storage cleared. Network state is irrelevant.
- **Steps:**
  1. Launch the app.
  2. Observe Publisher Splash.
  3. Wait for Title Screen.
  4. Continue until the Terms & Privacy modal appears.
- **Expected behavior:** Publisher Splash appears first, Title Screen appears next, then Terms & Privacy modal appears only because no accepted policy version exists.
- **Pass criteria:** No wrong-color flash, no debug overlay, no navigation dead end, modal blocks interaction behind it.
- **Fail criteria:** Home appears before acceptance, modal never appears, app crashes, or branding is inconsistent.
- **Tester notes:**
- **Defect reference:**

## RC-002 — Terms & Privacy Viewing

- **Feature:** Terms of Service and Privacy Policy modal
- **Preconditions:** RC-001 modal is visible.
- **Steps:**
  1. Tap **VIEW PRIVACY POLICY**.
  2. Confirm the OS attempts to open the privacy document URL.
  3. Return to the app.
  4. Tap **VIEW TERMS OF SERVICE**.
  5. Confirm the OS attempts to open the terms document URL.
  6. Return to the app.
- **Expected behavior:** Both document buttons respond and the modal remains available until explicit acceptance.
- **Pass criteria:** Both documents are viewable or handed to the OS browser without app crash.
- **Fail criteria:** Either button is missing, unresponsive, opens the wrong document, or dismisses the modal.
- **Tester notes:**
- **Defect reference:**

## RC-003 — Terms & Privacy Acceptance Persistence

- **Feature:** Persisted acceptance and policy version
- **Preconditions:** Terms & Privacy modal is visible.
- **Steps:**
  1. Tap **ACCEPT & CONTINUE**.
  2. Complete the introductory flow through Results and Home.
  3. Force close the app.
  4. Relaunch.
- **Expected behavior:** Acceptance is saved with policy version `4.0.0-2026-07-13`. Relaunch goes Publisher Splash → Title → Home without showing the modal again.
- **Pass criteria:** Modal does not reappear for the same policy version.
- **Fail criteria:** Modal reappears unexpectedly, acceptance is not saved, or Home is reachable without explicit acceptance on first launch.
- **Tester notes:**
- **Defect reference:**

## RC-004 — Introductory Guided Tutorial

- **Feature:** First-launch core gameplay tutorial
- **Preconditions:** Fresh install, Terms & Privacy accepted.
- **Steps:**
  1. Continue from the Title Screen after acceptance.
  2. Observe the introductory Scene Investigation tutorial.
  3. Follow the tutorial steps.
  4. Start practice from the tutorial.
  5. Complete Observation, Recall, and Results.
  6. Continue to Home.
- **Expected behavior:** Intro tutorial appears once, teaches Observe → Remember → Recall, starts one primary Challenge Type practice round, then reaches Results and Home.
- **Pass criteria:** Tutorial is understandable, no clipped text/buttons, practice round scores, Results appears, Home appears after Continue/Home.
- **Fail criteria:** Tutorial repeats before Home after completion, tutorial skips unexpectedly, or Results/Home cannot be reached.
- **Tester notes:**
- **Defect reference:**

## RC-005 — Returning Launch

- **Feature:** Returning user launch flow
- **Preconditions:** RC-004 completed; app force closed.
- **Steps:**
  1. Relaunch the app.
  2. Observe splash and title sequence.
- **Expected behavior:** Publisher Splash → Title → Home. No Terms modal and no automatic introductory tutorial.
- **Pass criteria:** Returning launch reaches Home quickly without interruptions.
- **Fail criteria:** Intro tutorial or Terms modal repeats unexpectedly.
- **Tester notes:**
- **Defect reference:**

## RC-006 — Home Screen Visual/Layout

- **Feature:** Home
- **Preconditions:** Returning player on Home.
- **Steps:**
  1. Review eye branding, hero text, stat cards, Play Now, Programs, featured Challenge Type, achievements, and quick actions.
  2. Scroll from top to bottom.
  3. Repeat at 140% text size.
- **Expected behavior:** Premium eye identity is visible, all controls are aligned, no floating labels, all text wraps cleanly.
- **Pass criteria:** No overlap, no clipped buttons, no broken images, all touch targets feel reachable.
- **Fail criteria:** Floating nav labels, clipped stat text, distorted art, or unreachable controls.
- **Tester notes:**
- **Defect reference:**

## RC-007 — Challenge Library and Replay Tutorials

- **Feature:** Challenge Library
- **Preconditions:** Home is visible.
- **Steps:**
  1. Open Challenge Library.
  2. Verify all five Challenge Type cards have premium artwork.
  3. Tap each **REPLAY TUTORIAL** button.
  4. Return to Library after each tutorial/practice check as needed.
- **Expected behavior:** Each card is visually distinct. Tutorials remain replayable on demand.
- **Pass criteria:** No generic thumbnails; replay buttons work; back/Home navigation recovers cleanly.
- **Fail criteria:** Missing card art, broken image, dead replay button, or navigation loop.
- **Tester notes:**
- **Defect reference:**

## RC-008 — First-Time Challenge Tutorial Gating

- **Feature:** Per-Challenge Type first-time tutorial gating
- **Preconditions:** Fresh profile or reset family tutorial completion if available.
- **Steps:**
  1. From Library, start Flash Words for the first time.
  2. Confirm its tutorial appears.
  3. Complete or skip to practice.
  4. Finish Results and return Home/Library.
  5. Start Flash Words again.
  6. Repeat for Spot the Difference, Object Recall, and Pattern Recall.
- **Expected behavior:** Each family tutorial appears only the first time that family is selected, then not automatically again.
- **Pass criteria:** First entry teaches the family; second entry starts gameplay directly; replay remains available from Library.
- **Fail criteria:** Tutorial never appears on first entry, repeats every entry, or cannot be replayed manually.
- **Tester notes:**
- **Defect reference:**

## RC-009 — Scene Investigation Gameplay

- **Feature:** Scene Investigation
- **Preconditions:** Challenge can be launched from Library or Play Now.
- **Steps:**
  1. Start Scene Investigation.
  2. Observe presentation.
  3. Answer recall question.
  4. Review Results reveal.
- **Expected behavior:** Presentation is polished and readable; Recall controls are reachable; Results explain the answer.
- **Pass criteria:** No layout overlap, no unfair unreadable details, reveal evidence is clear.
- **Fail criteria:** Distorted scene, missing renderer, clipped options, or incorrect scoring path.
- **Tester notes:**
- **Defect reference:**

## RC-010 — Flash Words Gameplay

- **Feature:** Flash Words
- **Preconditions:** Flash Words available.
- **Steps:**
  1. Start Flash Words.
  2. Observe word presentation.
  3. Answer recall prompt.
  4. Review Results.
- **Expected behavior:** Cinematic word card appears, timing respects settings, answer options are touch-safe.
- **Pass criteria:** Word is legible, no flicker, Results show correct comparison.
- **Fail criteria:** Text clips, word card distorts, or controls overlap.
- **Tester notes:**
- **Defect reference:**

## RC-011 — Spot the Difference Gameplay

- **Feature:** Spot the Difference
- **Preconditions:** Family available.
- **Steps:**
  1. Start side-by-side and sequential templates if surfaced.
  2. Tap the changed region.
  3. Review reveal.
- **Expected behavior:** Comparison panels are professionally framed; tap regions are fair; reveal highlights the changed area.
- **Pass criteria:** Panels fit phone screen, no touch blocking, reveal is clear.
- **Fail criteria:** Panels too small, clipped, or tap response inconsistent.
- **Tester notes:**
- **Defect reference:**

## RC-012 — Object Recall Gameplay

- **Feature:** Object Recall
- **Preconditions:** Family available.
- **Steps:**
  1. Start Object Recall.
  2. Observe artifact/evidence tray.
  3. Select requested objects.
  4. Review reveal.
- **Expected behavior:** Museum/archive visual identity is clear; multi-select controls are touch-safe.
- **Pass criteria:** Objects are legible and selection count behavior is clear.
- **Fail criteria:** Object cards overlap, labels clip, or submit state is confusing.
- **Tester notes:**
- **Defect reference:**

## RC-013 — Pattern Recall Gameplay

- **Feature:** Pattern Recall
- **Preconditions:** Family available.
- **Steps:**
  1. Start Pattern Recall.
  2. Observe path/shape sequence.
  3. Re-enter sequence.
  4. Review reveal.
- **Expected behavior:** Blueprint/technical visual identity is clear; ordering input is understandable.
- **Pass criteria:** Sequence steps are visible and controls remain reachable.
- **Fail criteria:** Symbols too small, sequence impossible to follow, or submit/reset controls fail.
- **Tester notes:**
- **Defect reference:**

## RC-014 — Programs

- **Feature:** Programs
- **Preconditions:** Returning player on Home.
- **Steps:**
  1. Open Programs.
  2. Review every Program card and artwork.
  3. Start an available Program.
  4. Continue through at least two rounds.
- **Expected behavior:** Program cards feel curated, artwork appears, progress round count updates.
- **Pass criteria:** Program starts and continues without dead ends.
- **Fail criteria:** Missing art, unavailable program starts incorrectly, or continuation fails.
- **Tester notes:**
- **Defect reference:**

## RC-015 — Results Actions

- **Feature:** Results, Continue, Replay, Home
- **Preconditions:** Any Results screen visible.
- **Steps:**
  1. Verify result badge art.
  2. Tap Replay.
  3. Complete or exit replay to Results.
  4. Tap Continue.
  5. Return to Results and tap Home.
- **Expected behavior:** Badge art matches outcome, Replay restarts current challenge, Continue starts next/recommended flow, Home returns safely.
- **Pass criteria:** No duplicate taps, no dead route, no tutorial loop after completion.
- **Fail criteria:** Buttons unresponsive, duplicate navigation, or Home not reachable.
- **Tester notes:**
- **Defect reference:**

## RC-016 — Settings

- **Feature:** Settings and persistence
- **Preconditions:** Home visible.
- **Steps:**
  1. Open Settings.
  2. Change text size, reduced motion, high contrast, audio, haptics, tutorials, and comfortable timing.
  3. Leave Settings and return.
  4. Relaunch app.
- **Expected behavior:** Controls are aligned and touch-safe; settings persist after relaunch.
- **Pass criteria:** Values persist and visibly affect relevant systems.
- **Fail criteria:** Clipped controls, missing save, or setting causes crash.
- **Tester notes:**
- **Defect reference:**

## RC-017 — Profile and Achievements

- **Feature:** Profile, progress, achievements
- **Preconditions:** Complete at least one round.
- **Steps:**
  1. Open Profile.
  2. Review stats, mastery, history, programs, achievements, and collections.
  3. Open Achievements.
- **Expected behavior:** Progress is visible and readable; empty states are polished.
- **Pass criteria:** No clipped sections, no debug controls in production export, achievements list scrolls cleanly.
- **Fail criteria:** Broken progress data, clipped rows, or inaccessible sections.
- **Tester notes:**
- **Defect reference:**

## RC-018 — Navigation and Android Back

- **Feature:** Navigation
- **Preconditions:** App running on Android.
- **Steps:**
  1. Navigate Home → Library → Profile → Settings → Programs → Achievements.
  2. Use top-bar Back where shown.
  3. Use Android Back on every non-Home route.
  4. Use Android Back during Observation, Recall, and Results.
- **Expected behavior:** Back returns to previous route or Home consistently; no splash routes re-enter history.
- **Pass criteria:** No loops, dead routes, duplicate transitions, or floating nav labels.
- **Fail criteria:** App exits unexpectedly, returns to splash, or duplicates screens.
- **Tester notes:**
- **Defect reference:**

## RC-019 — Audio and Haptics

- **Feature:** Audio/haptics feedback
- **Preconditions:** Device supports audio and vibration.
- **Steps:**
  1. Trigger UI taps, gameplay start, correct result, incorrect result.
  2. Toggle Mute All Audio.
  3. Toggle Haptics off.
  4. Repeat interactions.
- **Expected behavior:** Audio cues are tasteful and do not stack; mute silences buses; haptics setting is respected.
- **Pass criteria:** Feedback supports interactions without distraction.
- **Fail criteria:** Audio continues while muted, repeated stacked sounds, or haptics ignore setting.
- **Tester notes:**
- **Defect reference:**

## RC-020 — Accessibility

- **Feature:** Accessibility settings
- **Preconditions:** App installed and playable.
- **Steps:**
  1. Enable 140% text, High Contrast, Reduced Motion, Color Assistance, Reading Comfort, Comfortable Timing, and Screen Reader Hints.
  2. Play one round in each Challenge Type.
- **Expected behavior:** Layouts remain usable; animations reduce; timing does not shorten; evidence remains clear.
- **Pass criteria:** No clipped text, no inaccessible controls, no color-only dependency.
- **Fail criteria:** Text overlaps, buttons unreachable, or gameplay becomes unfair.
- **Tester notes:**
- **Defect reference:**

## RC-021 — Branding and Visual Consistency

- **Feature:** Visual identity
- **Preconditions:** App available on clean and returning profiles.
- **Steps:**
  1. Review Publisher Splash, Title, loading overlay, Home, Library, Programs, Tutorials, and Results.
  2. Confirm eye motif and premium observation identity are consistent.
- **Expected behavior:** Screens feel like one cohesive product family.
- **Pass criteria:** No generic placeholder art, no broken textures, no inconsistent card/button style visible in normal flow.
- **Fail criteria:** Generic symbols replace brand art, mismatched styles, stretched images, or default Godot visuals.
- **Tester notes:**
- **Defect reference:**

## RC-022 — Save Persistence

- **Feature:** Local saves
- **Preconditions:** Complete onboarding and at least two rounds.
- **Steps:**
  1. Note progress, achievements, tutorial completion, settings, and policy acceptance.
  2. Force close and relaunch.
  3. Reboot device if possible and relaunch again.
- **Expected behavior:** Data persists, no repeated first-launch flow, progress remains consistent.
- **Pass criteria:** No data loss and no corrupted save recovery UI.
- **Fail criteria:** Repeated onboarding, reset profile, missing progress, or crash during save/load.
- **Tester notes:**
- **Defect reference:**

## RC-023 — Android Development APK Export

- **Feature:** Local APK export
- **Preconditions:** Godot 4.6.3, Android SDK, export templates installed.
- **Steps:**
  1. Open `app/project.godot` in Godot.
  2. Open Export.
  3. Select `Android_Development`.
  4. Export APK to `build/android/2sw-dev.apk`.
- **Expected behavior:** APK exports using package `com.ittybittybites.the2secondwitness`, portrait orientation, GL Compatibility/OpenGL 3, debug signing.
- **Pass criteria:** APK builds and installs on test device.
- **Fail criteria:** Missing preset, signing failure, missing icon, renderer error, or install failure.
- **Tester notes:**
- **Defect reference:**

## RC-024 — Play Store AAB Generation

- **Feature:** Release bundle export
- **Preconditions:** Release machine with valid signing credentials configured locally.
- **Steps:**
  1. Open Export.
  2. Select `Android_PlayStore`.
  3. Configure release keystore locally if needed.
  4. Export AAB to `build/android/2sw-release.aab`.
  5. Inspect dependency/permission report.
- **Expected behavior:** AAB exports with package/version identity intact and no unexpected permissions or SDKs.
- **Pass criteria:** Signed AAB is generated and ready for internal testing upload.
- **Fail criteria:** Version conflict, signing failure, unexpected billing/ad/network dependency, or permission mismatch.
- **Tester notes:**
- **Defect reference:**

## RC-025 — Performance Observations

- **Feature:** Runtime performance
- **Preconditions:** Development APK installed on target devices.
- **Steps:**
  1. Cold launch app five times.
  2. Play a 10-round mixed session.
  3. Open/close Programs, Library, Profile, Settings repeatedly.
  4. Watch memory, temperature, frame pacing, and ANR behavior.
- **Expected behavior:** Smooth UI, no stalls, no ANR, no visible asset-loading hitches after initial import.
- **Pass criteria:** App remains responsive across session.
- **Fail criteria:** ANR, crash, severe frame drops, or memory growth causing instability.
- **Tester notes:**
- **Defect reference:**

## RC-026 — Google Play Media Capture Plan

- **Feature:** Store screenshots and trailers
- **Preconditions:** Development APK or signed internal-testing build validated visually.
- **Steps:**
  1. Capture portrait screenshots from real app footage for Home, Library, Tutorial, each Challenge Type, Programs, and Results.
  2. Record real footage for 15-second, 30-second, and 60-second trailers.
  3. Include Publisher Splash, Title, premium eye branding, every Challenge Type, Programs, Results, and end card “Available on Google Play.”
- **Expected behavior:** Media reflects the current production build and contains no mock or placeholder gameplay.
- **Pass criteria:** Screenshots/trailers are real, polished, readable, and accurate to implemented features.
- **Fail criteria:** Mock gameplay, debug overlays, placeholder art, stretched graphics, or unimplemented feature claims.
- **Tester notes:**
- **Defect reference:**

# Phase 3.5 Completion — Production Polish

**Date:** 2026-07-12
**Approval:** Approved after local gate review on 2026-07-12
**Status:** Phase 3.5 approved locally; corrected Android APK exported; physical/hardware-accelerated boot gate remains open

## Completed locally

- Sponsor-first Godot boot and publisher flow
- Android 12+ transparent system-splash icon configuration for Gradle exports
- Portrait lock verification in project and both Android presets
- Physical-to-logical safe-area scaling
- Centered responsive product surfaces for phones, tablets, and unfolded profiles
- Global 48-pixel touch-target enforcement and Android Back handling
- Branded loading state and Reduced Motion-aware route transitions
- Text Size integration in shared typography
- Functional High Contrast tokens
- Reading Comfort Mode review
- New Color Assistance that removes color-dependent Scene Investigation questions
- Settings slider refresh debounce
- Hidden-screen reconstruction deferral
- Startup, screen, challenge-preparation, generation-attempt, and memory instrumentation
- Runtime texture size limits for seven large assets
- Dedicated local device-layout and performance acceptance tests

## Files created

- `app/src/ui/layout/ResponsiveLayout.gd`
- `app/android/README.md`
- `app/tests/runtime/test_phase35_production_polish.gd`
- `app/tests/runtime/verify_phase35_production_polish.py`
- `docs/product/PHASE_3_5_PRODUCTION_POLISH_SPEC.md`
- `docs/product/PHASE_3_5_DEVICE_VALIDATION_MATRIX.md`
- `docs/product/PHASE_3_5_PRODUCTION_AUDIT.md`
- `docs/product/PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md`

## Major modified areas

- Project boot splash and Android export presets
- AppBoot, AppShell, top bar, bottom navigation, and loading overlay
- ThemeService, AccessibilityService, SettingsService, and PlayerProgressService
- Home, Library, Profile, Achievements, Settings, About, Title, Observation, Recall, and Result screens
- Both production family tutorials
- Scene Investigation difficulty/generation accessibility behavior
- Runtime performance instrumentation and large-texture import settings
- Active roadmap, architecture, testing, and status documentation

## Architecture decisions

1. Android native splash customization uses Godot 4.6 Gradle custom-theme attributes; no forked Android activity or parallel boot system is introduced.
2. Responsive behavior is a pure shared helper, not a new runtime service.
3. Performance samples use the existing consent-aware AnalyticsService.
4. Color Assistance is a shared preference interpreted by the family that owns color questions.
5. Physical-device claims remain explicitly pending until an Android SDK/emulator or hardware run is available.

## Final validation

| Validation | Result |
|---|---:|
| Fresh Godot 4.6.3 import | Pass, no app errors or warnings |
| Full source loading | 84 loaded, 0 failed |
| Phase 3.5 polish/device/performance | 84 passed, 0 failed |
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
| Phase 3.5 static polish architecture | Pass |
| Runtime, content, documentation, JSON, conflicts, whitespace | Pass |
| Gate 4 baseline after approved Phase 3/3.5 evolution | 71 tracked; 34 unchanged / 37 allowlisted evolutions |

Local performance result from the final dedicated run:

```text
service_init_ms: 103.47
layout_matrix_ms (30 screen/profile combinations): 1268.52
home_snapshot_average_ms: 0.19384
home_scene_average_ms: 0.718
static_memory_mb: 35.5
```

These are repeatable headless local baselines, not substitutes for Android frame timing, GPU memory, or thermal measurements.

## Approval boundary

Phase 3.5 is approved. The shared platform architecture is now frozen except for verified bug fixes and changes required by the open Android device gate. Phase 4 must not begin until the device result is recorded or the remaining device work is explicitly accepted as deferred release work.

The boot experience is not considered device-complete until an exported build demonstrates this exact sequence:

```text
Android launch surface
→ Sponsor artwork
→ Publisher screen
→ Two Second Witness loading screen
→ Privacy / Tutorial on first run
→ Home
```

The capture must show no launcher icon before sponsor artwork.

## Android export validation update

A corrected Godot 4.6.3 Gradle development APK was exported after the initial API 31 run exposed a missing Android mobile renderer override. The minimal fix explicitly selects `gl_compatibility` and `opengl3` for Android. Generated resources confirm the transparent Android 12+ splash icon and sponsor-matched background. The corrected log confirms Vulkan is disabled.

The available software emulator could not complete visual validation because it lacked KVM acceleration, failed SwiftShader GLES3 scene-shader linking, and destabilized the emulated Android system under load. The boot gate therefore remains open. Full evidence is recorded in [`PHASE_3_5_DEVICE_VALIDATION_MATRIX.md`](PHASE_3_5_DEVICE_VALIDATION_MATRIX.md).

## Remaining device-only work

- Install the corrected validation APK on physical Android 12+ hardware or a hardware-accelerated emulator.
- Capture cold and warm boot to prove no launcher icon appears before sponsor artwork.
- Verify sponsor, publisher, loading, Privacy/Tutorial, and returning-user Home frames.
- Execute notch, tablet, and foldable device profiles.
- Verify real haptics, audio balance, GPU memory, thermal behavior, and system font interactions.
- Confirm gesture-navigation and split-screen behavior on supported devices.

## Recommended next phase

After the device matrix is completed or consciously accepted as release work, proceed to **Phase 4 — Player Journey and Progress depth**. Stop for approval before beginning it.

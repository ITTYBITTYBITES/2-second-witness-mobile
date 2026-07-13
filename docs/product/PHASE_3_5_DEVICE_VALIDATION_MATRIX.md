# Phase 3.5 — Android Device Validation Matrix

**Status:** Export completed and API 31 emulator attempted; hardware-accelerated or physical-device boot gate remains open

## Exported-build validation attempt — 2026-07-12

### Build result

- Godot: `4.6.3.stable.official.7d41c59c4`
- Gradle custom build: completed
- Package: `com.ittybittybites.the2secondwitness`
- Version: `4.0.0` (`40000`)
- Minimum/target SDK: 24 / 36
- Validation APK ABI: arm64-v8a
- APK signature: temporary Godot debug certificate, APK Signature Schemes v2/v3
- SHA-256: `018e76d602212a8101f5483e21ad09375d01511dff9416a660b1ade8f86b49ab`
- Artifact retention: the temporary 43 MB debug APK was not retained in the persisted workspace; it was not production-signed

Generated Android resources confirmed:

```xml
<style name="GodotAppSplashTheme" parent="Theme.SplashScreen">
    <item name="android:windowSplashScreenBackground">#0E0E14</item>
    <item name="windowSplashScreenAnimatedIcon">@android:color/transparent</item>
    <item name="postSplashScreenTheme">@style/GodotAppMainTheme</item>
</style>
```

### Issue discovered and minimal correction

The first exported emulator build selected Vulkan before loading the Godot project. The cause was a missing Android/mobile renderer override even though the desktop renderer was already `gl_compatibility`.

Minimal correction in `app/project.godot`:

```text
renderer/rendering_method.mobile="gl_compatibility"
rendering_device/driver.android="opengl3"
```

The corrected Android log confirms:

```text
usesVulkan(): false
renderingDevice: opengl3 (ProjectSettings)
renderer: gl_compatibility (ProjectSettings)
```

### API 31 emulator result

A software-emulated Android 12 / API 31 image was booted at 360 × 640 without KVM acceleration. Installation and launch were attempted with an x86_64 validation build containing the same project data and Android theme.

| Acceptance criterion | Observed result |
|---|---|
| No launcher icon before sponsor artwork | No icon appeared in the limited capture; generated theme is correct, but frame coverage is insufficient for final approval |
| Sponsor artwork fills screen | Not observable; SwiftShader could not link Godot GLES3 scene shaders |
| Publisher transition | Not reached visually |
| Two Second Witness loading screen | Not reached visually |
| Privacy/Tutorial first-run path | Not reached visually |
| Returning user reaches Home | Not tested |
| No flicker, blank frames, or orientation changes | Cannot pass; blank frames were produced by emulator graphics failure |
| Portrait orientation | Emulator remained portrait at 360 × 640 |

The emulator lacked hardware acceleration and ran inside a constrained environment. SwiftShader scene-shader linking failed and the emulated Android system produced ANRs under load, so this attempt cannot close the boot gate. This is a validation-environment limitation after the renderer correction, not evidence that the required UI sequence passes.

Evidence:

- [`artifacts/android_boot_validation/README.md`](artifacts/android_boot_validation/README.md)
- [`artifacts/android_boot_validation/pre_correction_vulkan_failure_frames/`](artifacts/android_boot_validation/pre_correction_vulkan_failure_frames/)
- [`artifacts/android_boot_validation/post_correction_emulator_frames/`](artifacts/android_boot_validation/post_correction_emulator_frames/)

**Gate decision:** Remains open pending physical Android 12+ hardware or a hardware-accelerated emulator.

## Local automated profiles

Each profile instantiates Home, Challenge Library, Profile, Achievements, Settings, and About at 140 percent Text Size. The test verifies horizontal bounds and 48-pixel touch targets.

| Profile | Logical size | Local result |
|---|---:|---:|
| Compact phone | 360 × 640 | Pass (local automated) |
| Modern phone | 412 × 915 | Pass (local automated) |
| Small tablet | 600 × 960 | Pass (local automated) |
| Large tablet | 800 × 1280 | Pass (local automated) |
| Unfolded portrait | 884 × 1104 | Pass (local automated) |

Synthetic safe-area checks cover top/bottom cutouts and symmetric side insets after physical-to-logical scaling.

## Required Android execution matrix

| Device class | Suggested profile | API | Required checks | Status |
|---|---|---:|---|---|
| Small phone | 360 × 640 emulator or comparable device | 26+ | Scroll reachability, touch targets, 140% text | Pending device/emulator |
| Notched phone | Pixel-class portrait | 31+ | Top cutout, gesture inset, sponsor-first boot | Pending device/emulator |
| Current phone | 412 × 915 class | 35+ | Cold/warm launch, navigation, haptics, audio | Pending device/emulator |
| Small tablet | 7–8 inch portrait | 31+ | Centered max-width content, card hierarchy | Pending emulator/device |
| Large tablet | 10–12 inch portrait | 35+ | Content width, touch reach, typography | Pending emulator/device |
| Foldable folded | Narrow portrait profile | 31+ | Compact gutters, scroll, no clipping | Pending foldable emulator/device |
| Foldable unfolded | 884 × 1104 or vendor profile | 31+ | Centered content and side safe areas | Pending foldable emulator/device |

## Test configurations

Run each relevant profile with:

- Default settings
- Text Size 140%
- High Contrast on
- Reduced Motion on
- Reading Comfort Mode on
- Color Assistance on
- Android gesture navigation and three-button navigation where available

## Boot capture protocol

On Android 12+:

1. Force-stop the application.
2. Start a screen recording before launch.
3. Launch from the launcher.
4. Review frame-by-frame.
5. Confirm the launcher icon never appears as a launch splash.
6. Confirm the first branded visual is ITTYBITTYBITES sponsor artwork.
7. Confirm transition order is sponsor → Two Second Witness loading screen.
8. Repeat warm launch after the process remains cached.

## Interaction protocol

- Tap every Home and bottom-navigation action near each target edge.
- Use Android Back from Library, Profile, Achievements, Settings, About, and gameplay.
- Scroll every long surface to its final item.
- Drag all sliders without the row disappearing mid-gesture.
- Toggle accessibility settings and revisit cached screens.
- Rotate the device and confirm the app remains portrait.
- Enter split-screen/multi-window where the device permits it and record behavior.

## Performance capture protocol

Record at least three cold and three warm runs:

- Process start to sponsor frame
- Sponsor frame to title/loading frame
- Service-ready event
- Home first presentation
- Home → Library first and cached navigation
- Home → Challenge presentation
- Memory before Home, after Library, and after ten rounds

Physical results belong in this file before store submission. Local completion does not substitute for those measurements.

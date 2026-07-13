# Phase 3.5 — Production Polish Specification

**Date:** 2026-07-12
**Status:** Implemented locally; physical Android matrix remains
**Purpose:** Convert the validated Phase 3 product hub into a locally production-ready Android experience before progression expansion.

## Non-goals

- No new Challenge Type
- No progression expansion
- No Programs implementation
- No gameplay redesign
- No replacement of Foundation or Challenge Runtime services

## Workstream 1 — Android layout and input

- Preserve portrait orientation in project and both Android export presets.
- Scale physical safe-area/cutout values into logical viewport coordinates.
- Center product content in a maximum-width column on tablets and unfolded devices.
- Keep compact-phone gutters usable.
- Ensure all interactive controls have at least a 48 × 48 logical-pixel target.
- Support Android/system Back through the existing route history.
- Keep every long product surface scrollable.
- Validate local layouts at compact phone, modern phone, small tablet, large tablet, and unfolded portrait dimensions.

## Workstream 2 — Home and shared presentation polish

- Add restrained route fades that obey Reduced Motion.
- Add branded preparation states before Home gameplay launches.
- Replace the stock loading spinner with a labeled eye-like pulse.
- Preserve text labels and icons so state is never color-only.
- Avoid rebuilding hidden cached screens when profile or theme events fire.
- Apply consistent Library terminology in the bottom navigation.
- Keep existing empty states for unavailable content, history, and completed milestones.

## Workstream 3 — Sponsor-first boot

Required sequence:

```text
Android system launch surface
→ sponsor artwork as the first engine-drawn frame
→ sponsor route
→ redesigned Two Second Witness loading screen
→ privacy/tutorial/Home routing
```

Configuration requirements:

- Android 12+ `windowSplashScreenAnimatedIcon` is transparent.
- Android system splash background matches the sponsor artwork background.
- Godot `boot_splash/image` uses `ittybittybites_splash.png` in cover mode, never the launcher icon.
- `PublisherSplashScreen` continues the same full-screen sponsor artwork without a visual jump.
- The launcher icon remains unchanged for launcher/store identity.

The Android system behavior requires a Gradle custom build and must be confirmed on an Android 12+ physical device or emulator capture.

## Workstream 4 — Accessibility

- Text Size scales shared typography up to 140 percent.
- High Contrast derives a complete light/dark token set with at least 7:1 primary and secondary text contrast against the background.
- Reduced Motion resolves nonessential animation durations to zero.
- Reading Comfort Mode remains connected to Flash Words.
- Color Assistance prevents Scene Investigation from selecting color-dependent questions.
- Correct/incorrect states retain icon and text cues in addition to color.
- Settings changes persist through the existing SettingsService.

## Workstream 5 — Performance

Instrumentation records:

- Cold service initialization
- Screen construction/cached presentation duration
- Challenge preparation duration and generation attempts
- Static memory at screen presentation

Local acceptance budgets:

| Metric | Budget |
|---|---:|
| Service initialization | < 1,000 ms |
| Home snapshot average | < 2 ms |
| Packed Home scene instantiation average | < 10 ms |
| 30-screen responsive layout matrix | < 3,000 ms |
| Static memory review ceiling | < 384 MB |

Large runtime textures use import-time size limits to reduce decode/upload and resident texture cost without altering source art.

## Acceptance gate

Phase 3.5 is locally complete when:

1. The dedicated runtime polish test passes.
2. Static boot, orientation, accessibility, responsive-layout, performance, and texture checks pass.
3. Every Phase 1–3 regression and both production stress suites remain green.
4. Documentation, terminology, links, conflict markers, and trailing whitespace pass.
5. Remaining physical-device-only checks are explicitly listed rather than claimed complete.

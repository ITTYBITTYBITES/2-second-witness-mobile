# Phase 0.5 Report — Mobile Layout Foundation Pass

**Date:** 2026-07-15  
**Status:** Implemented on PR #38 after Android APK validation feedback  
**Scope:** Mobile readability, scrolling, cards, and responsive presentation foundation only

---

## Why Phase 0.5 Was Added

Physical Android APK validation found a foundational usability issue: the Phase 0 Witness identity shell could be correct in hierarchy while still feeling cramped on a real phone.

Observed issues included:

- screens that could clip content when height exceeded the viewport;
- cards that felt undersized for thumb interaction and phone reading;
- text that was too small on physical devices;
- layouts that relied too much on static viewport assumptions.

This is not a feature update. It is a mobile usability correction required before Update 1 begins.

---

## What Changed

### Global scroll preparation

Added mobile scroll preparation helpers to `ResponsiveLayout`:

- `prepare_mobile_scroll(...)`
- `prepare_scroll_descendants(...)`

`AppShell` now prepares scroll descendants after screen load, so nested scroll surfaces, including family tutorial scenes mounted inside the generic tutorial host, receive consistent mobile scroll/touch treatment without modifying gameplay or tutorial logic.

Primary scroll screens now explicitly opt into mobile scroll preparation:

- Witness Home
- Record
- Settings
- Explore Experiences / Library
- Result

### Mobile card sizing

Raised mobile-first card and tap sizing for:

- `DailyExperienceCard`
- `ExperienceCard`
- `ProgramCard`
- `AppCard`

Changes include larger card minimum heights, larger internal padding, stronger spacing, larger preview/artwork areas, and larger button/touch targets.

### Typography and touch readability

Raised base theme readability tokens:

- display/title/headline sizes;
- body and body-small sizes;
- button size;
- caption and label sizes;
- default touch target floor from 48 to 56.

Accessibility scaling, high contrast mode, and reduced motion paths remain preserved.

### Result scroll safety

Result screens now reserve additional bottom scroll padding so actions remain reachable above bottom navigation and device safe areas.

---

## Files Changed

- `app/src/ui/layout/ResponsiveLayout.gd`
- `app/src/ui/shell/AppShell.gd`
- `app/src/systems/theme/ThemeService.gd`
- `app/src/ui/components/AppCard.gd`
- `app/src/ui/components/DailyExperienceCard.gd`
- `app/src/ui/components/DailyExperienceCard.tscn`
- `app/src/ui/components/ExperienceCard.gd`
- `app/src/ui/components/ExperienceCard.tscn`
- `app/src/ui/components/ProgramCard.gd`
- `app/src/ui/components/ProgramCard.tscn`
- `app/src/ui/screens/HomeV2Screen.gd`
- `app/src/ui/screens/ExperiencesScreen.gd`
- `app/src/ui/screens/SettingsScreen.gd`
- `app/src/ui/screens/ProfileScreen.gd`
- `app/src/ui/screens/ResultScreen.gd`
- `app/tests/runtime/verify_phase05_mobile_layout.py`
- `app/tests/runtime/README.md`

---

## Explicitly Not Changed

Phase 0.5 did not change:

- `ChallengeSessionService.gd`
- `ObservationChallengeScreen.gd`
- `MemoryQuestionScreen.gd`
- `TutorialScreen.gd`
- observation timing
- gameplay logic
- challenge content architecture
- monetization
- analytics schema
- Android/export configuration

---

## Validation Completed

Passed:

```bash
git diff --check
python3 app/tests/runtime/verify_phase05_mobile_layout.py
python3 app/tests/runtime/verify_phase0_witness_shell.py
```

Also re-run with the existing static architecture suite before closeout:

```bash
python3 app/tests/runtime/verify_phase3_home_architecture.py
python3 app/tests/runtime/verify_phase4_product_architecture.py
python3 app/tests/runtime/verify_phase5_architecture.py
python3 app/tests/runtime/verify_flash_words_engine_unchanged.py
```

Godot runtime validation and physical Android re-test remain required before merge/release because the original issue was found on device.

---

## Required Device Re-check

Validate at minimum:

- small Android phone portrait;
- standard Android phone portrait;
- large phone/tablet or foldable viewport.

Confirm:

- Witness Home scrolls and remains readable;
- Record scrolls through all dynamic history/progress content;
- Settings rows and sliders remain reachable;
- Explore Experiences cards are readable and thumb-sized;
- Result actions are reachable above bottom chrome;
- tutorial content scrolls when family tutorial scenes exceed viewport height;
- no content is clipped below navigation or safe areas.

---

## Next Step

After Phase 0.5 device validation passes, proceed to Update 1 planning:

```text
Phase 0 — Witness identity shell
Phase 0.5 — Mobile readability/layout foundation
Update 1 — Witness Moment Foundation
Update 2 — Evidence Reveal Transformation
```

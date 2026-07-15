# Phase 0 Implementation Report — Witness Foundation Shell

**Date:** 2026-07-15  
**Status:** Implementation complete on `arena/019f6582-2-second-witness-mobile`  
**Scope:** Navigation hierarchy and presentation shell only

---

## Summary

Phase 0 refocuses the existing Two Second Witness app shell around a clear Witness identity without rebuilding navigation or changing gameplay systems.

The app now presents a primary product hierarchy of:

```text
Witness
Record
Settings
```

The Library/Experiences, Programs, Achievements, and other existing surfaces remain available as secondary destinations. The main landing screen now answers “What should I witness now?” with a single primary observation action and quiet access to Record, Explore Experiences, and Settings.

---

## What Changed

### Primary navigation

- Changed the player-facing bottom navigation from `Home / Library / Profile / Settings` to `Witness / Record / Settings`.
- Kept internal route names stable:
  - `home` remains the Witness landing route.
  - `profile` remains the implementation route for Witness Record.
  - `experiences` remains the Library route, but is no longer a primary tab.
- Preserved back navigation and route history through the existing `NavigationService`.

### Witness Home

- Reframed `HomeV2Screen` as the Witness landing surface.
- Changed primary copy to emphasize observation:
  - “Witness”
  - “Observe what others miss.”
  - “Begin Observation”
- Reduced Home’s visible emphasis on streaks, achievements, mastery, and program lists.
- Repurposed the visible record preview around:
  - moments witnessed;
  - accuracy / record state;
  - personal Witness level/rank.
- Kept secondary access to:
  - Witness Record;
  - Explore Experiences / Library;
  - Settings.

### Record surface

- Reused existing `ProfileScreen` infrastructure.
- Renamed player-facing presentation to “Witness Record.”
- No new progression store was introduced.

### Result / reveal preparation

- Added `EvidenceRevealContainer.gd` as a structural wrapper around existing result reveal content.
- The result flow still uses the existing result data and reveal rendering path.
- This is only a future-ready container; it does not implement the full Evidence Reveal update.

### Reusable shell components

Added lightweight reusable shell components:

- `ScreenContainer.gd` — shared screen margin/layout helper using existing `ResponsiveLayout`.
- `ModalLayer.gd` — overlay host inside the existing AppShell layering model.
- `EvidenceRevealContainer.gd` — structural result/reveal host for future updates.

These components extend the current architecture; they do not replace `AppShell`, `NavigationService`, or route loading.

### Asset pipeline preparation

Added placeholder directories for future production assets:

```text
app/assets/scenes/
app/assets/evidence/
app/assets/home/
app/assets/record/
app/assets/branding/
```

An `app/assets/README.md` documents intended use. No final artwork or new scenarios were added.

---

## Why It Changed

Phase 0 prepares the product for the Flagship Evolution roadmap by making the existing app feel like a focused Witness instrument rather than a broad feature hub.

The intended first impression is:

> “I open this app to witness something, test my perception, and build my record.”

This phase establishes hierarchy, language, and shell structure so future updates can deepen the Witness Moment without adding disconnected menus.

---

## Files Modified

### Navigation and shell

- `app/src/core/navigation/AppRoutes.gd`
- `app/src/ui/shell/AppShell.gd`
- `app/src/ui/shell/AppShell.tscn`
- `app/src/ui/shell/MainNavigation.gd`
- `app/src/ui/shell/TopBar.gd`

### Home / Record / Result presentation

- `app/src/ui/screens/HomeV2Screen.gd`
- `app/src/ui/screens/HomeV2Screen.tscn`
- `app/src/ui/screens/ProfileScreen.tscn`
- `app/src/ui/screens/ResultScreen.gd`

### Components / theme / assets

- `app/src/ui/components/DailyExperienceCard.gd`
- `app/src/ui/components/DailyExperienceCard.tscn`
- `app/src/ui/components/ScreenContainer.gd`
- `app/src/ui/components/ModalLayer.gd`
- `app/src/ui/components/EvidenceRevealContainer.gd`
- `app/src/systems/theme/ThemeService.gd`
- `app/assets/README.md`
- `app/assets/scenes/.gitkeep`
- `app/assets/evidence/.gitkeep`
- `app/assets/home/.gitkeep`
- `app/assets/record/.gitkeep`
- `app/assets/branding/.gitkeep`

### Validation and documentation

- `app/tests/runtime/verify_phase0_witness_shell.py`
- `app/tests/runtime/README.md`
- `PROJECT_COMMAND_CENTER.md`
- `docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md`
- `docs/product/flagship-master-plan/PHASE_0_IMPLEMENTATION_REPORT.md`
- `docs/product/flagship-master-plan/PHASE_0_STORE_UPDATE_NOTES.md`

---

## Architecture Decisions

1. **Route names stay stable.** The product language changed to Witness/Record, but `home`, `profile`, and `settings` remain the primary route IDs.
2. **Library is secondary, not removed.** `ExperiencesScreen` and the `experiences` route remain intact and reachable from Witness Home.
3. **No second navigation framework.** AppShell, NavigationService, AppRoutes, and route history remain the only navigation model.
4. **No second progression store.** Witness Record continues to use existing ProfileService and PlayerProgressService data.
5. **Evidence reveal remains deferred.** Phase 0 adds a reusable container only; the future reveal sequence belongs to Update 2.
6. **Gameplay remains frozen.** ChallengeSessionService and the Observation/Question/Tutorial gameplay screens were not modified.
7. **Asset folders are placeholders only.** No final art, new scenarios, or content pipeline behavior was added.

---

## Explicitly Not Included

Phase 0 did **not** implement:

- Witness Threads;
- Story Mode;
- new challenge types;
- economies, shops, currencies, or rewards;
- social systems;
- accounts;
- leaderboards;
- new gameplay mechanics;
- new scenarios;
- monetization changes;
- analytics schema changes;
- Android/export changes;
- full Evidence Reveal transformation.

---

## Validation Completed

### Static validation

Passed:

```bash
git diff --check
python3 app/tests/runtime/verify_phase0_witness_shell.py
python3 app/tests/runtime/verify_phase3_home_architecture.py
python3 app/tests/runtime/verify_phase4_product_architecture.py
python3 app/tests/runtime/verify_phase5_architecture.py
python3 app/tests/runtime/verify_flash_words_engine_unchanged.py
```

The Phase 0 verifier confirms:

- primary navigation is Witness / Record / Settings;
- Library remains reachable as a secondary destination;
- reusable Phase 0 shell/reveal components exist;
- future asset placeholder directories exist;
- frozen gameplay/session files are unchanged.

### Godot/runtime validation

Not run in this sandbox because no `godot` binary is available on PATH.

Required manual/device validation remains:

- launch → splash → privacy modal if needed → Witness;
- Witness → Record → Settings navigation;
- Witness → Begin Observation → Observation → Question → Result → Return Home;
- Witness → Explore Experiences → Library;
- profile/save persistence;
- privacy state persistence;
- theme switching;
- accessibility settings;
- Android phone safe areas and aspect ratios.

---

## What Remains for Update 1

Update 1 should now build on this shell by refining the first actual Witness Moment:

- intentional first Scene Investigation session;
- novice-safe first scene;
- one concise witness contract;
- clear observation timing progression;
- one recall question;
- evidence-first result language and continuation;
- human/device first-session validation.

Update 1 should not rebuild the shell again unless Phase 0 validation exposes a specific blocker.

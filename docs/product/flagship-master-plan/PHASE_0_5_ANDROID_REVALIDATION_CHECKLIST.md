# Phase 0.5 Android Re-validation Checklist

**Purpose:** verify the Phase 0/0.5 Witness shell on real Android hardware before PR #38 is merged.  
**Status:** Required manual gate. Static checks passed, but APK/device review is the authority for this phase.

---

## Test Builds

Record before testing:

| Field | Value |
|---|---|
| PR | #38 — Phase 0/0.5 Witness Foundation Shell and Mobile Layout Foundation |
| Branch | `arena/019f6582-2-second-witness-mobile` |
| APK/AAB build date |  |
| Commit SHA |  |
| Godot version |  |
| Android export preset |  |
| Tester |  |

---

## Devices Required

Test at minimum:

| Device class | Example | Result |
|---|---|---|
| Small Android phone | narrow/short phone, gesture nav enabled | Not tested |
| Standard Android phone | typical portrait phone | Not tested |
| Large phone / foldable / tablet viewport | large portrait or unfolded/foldable view | Not tested |

For each device, record:

- device model;
- Android version;
- display size / resolution if known;
- gesture nav vs 3-button nav;
- font/display size OS setting if non-default.

---

## 1. Launch and Shell Route Validation

Expected route flow:

```text
Launch
→ Publisher Splash
→ Title / Privacy modal if first install
→ Witness
→ Record
→ Settings
```

| Check | Pass/Fail | Notes |
|---|---|---|
| App launches without black screen or stuck splash |  |  |
| Privacy modal, if shown, is readable and tappable |  |  |
| After acceptance/returning launch, Witness screen appears |  |  |
| Bottom navigation shows only Witness / Record / Settings |  |  |
| Witness tab is legible and tappable |  |  |
| Record tab is legible and tappable |  |  |
| Settings tab is legible and tappable |  |  |
| Android Back does not enter splash routes |  |  |
| No content overlaps status bar, notch, or gesture area |  |  |

---

## 2. Witness Home Mobile Layout

| Check | Pass/Fail | Notes |
|---|---|---|
| “Witness” title is readable at arm’s length |  |  |
| “Observe what others miss.” is readable |  |  |
| Today’s Witness Moment card feels phone-sized, not tiny |  |  |
| Scene preview / placeholder area has sufficient height |  |  |
| Begin Observation button is thumb-sized and reachable |  |  |
| Record preview is readable without cramped labels |  |  |
| Secondary actions are quiet but discoverable |  |  |
| Explore Experiences button is reachable |  |  |
| Settings secondary card/action is reachable |  |  |
| Whole screen scrolls if content exceeds viewport |  |  |
| Bottom content is not hidden behind bottom navigation |  |  |

---

## 3. Explore Experiences / Library

Path:

```text
Witness
→ Explore Experiences
```

| Check | Pass/Fail | Notes |
|---|---|---|
| Library route opens from Witness Home |  |  |
| Screen scrolls vertically through all Challenge Type cards |  |  |
| Cards are large enough for mobile reading |  |  |
| Card artwork/preview area is not too small |  |  |
| Card descriptions are readable |  |  |
| Play buttons are thumb-sized |  |  |
| Tutorial buttons are thumb-sized |  |  |
| Favorite buttons remain reachable and not too small |  |  |
| No card content is clipped |  |  |
| Bottom card/action clears bottom nav and gesture area |  |  |

---

## 4. Witness Record

Path:

```text
Bottom nav
→ Record
```

| Check | Pass/Fail | Notes |
|---|---|---|
| Header reads as Witness Record, not generic Profile |  |  |
| Header card is readable and not cramped |  |  |
| Observation stats are readable |  |  |
| Dynamic history content scrolls vertically |  |  |
| Program / recently played / favorites sections remain reachable |  |  |
| Achievement/milestone actions are tappable |  |  |
| No text is clipped at larger record counts |  |  |
| Bottom content clears bottom nav and gesture area |  |  |

---

## 5. Settings

Path:

```text
Bottom nav
→ Settings
```

| Check | Pass/Fail | Notes |
|---|---|---|
| Settings title and intro are readable |  |  |
| Settings scroll vertically through all sections |  |  |
| Toggles are at least thumb-sized |  |  |
| Sliders are usable with touch |  |  |
| Text Size setting changes are visible and do not break layout |  |  |
| High Contrast remains readable |  |  |
| Reduced Motion setting remains accessible |  |  |
| Color Assistance and tutorial settings remain reachable |  |  |
| Reset/privacy/about actions remain reachable |  |  |
| Bottom content clears bottom nav and gesture area |  |  |

---

## 6. Gameplay Flow Regression

Path:

```text
Witness
→ Begin Observation
→ Tutorial if required
→ Observation
→ Question
→ Result
→ Return Home
```

| Check | Pass/Fail | Notes |
|---|---|---|
| Begin Observation starts through normal runtime |  |  |
| Tutorial, if shown, is readable and scrolls if needed |  |  |
| Observation screen timing/layout is not destabilized |  |  |
| Question screen remains readable and tappable |  |  |
| Result screen opens after answer |  |  |
| Result can scroll if reveal/content exceeds viewport |  |  |
| Continue / Retry / Library / Return Home actions are reachable |  |  |
| Return Home returns to Witness, not old menu language |  |  |
| No save/profile/progress regression observed |  |  |

---

## 7. Result / Evidence Reveal Shell

| Check | Pass/Fail | Notes |
|---|---|---|
| Evidence Reveal title/container is readable |  |  |
| Existing reveal view appears inside the container |  |  |
| Explanation text is readable |  |  |
| Reveal does not imply unreleased evidence-board features |  |  |
| All result actions remain reachable above bottom nav |  |  |

---

## 8. Accessibility and Display Stress

Run at least one phone through these settings:

| Setting | Pass/Fail | Notes |
|---|---|---|
| In-app Text Size increased |  |  |
| High Contrast enabled |  |  |
| Reduced Motion enabled |  |  |
| Comfortable Timing enabled |  |  |
| OS display/font size increased, if practical |  |  |
| Haptics disabled |  |  |
| Audio muted |  |  |

Confirm:

- no critical text clipping;
- buttons remain tappable;
- scroll remains available;
- gameplay remains understandable.

---

## 9. Pass / Block Decision

### Pass criteria

Phase 0/0.5 can be considered merge-ready only if:

- Witness / Record / Settings navigation is usable on all tested devices;
- primary screens scroll vertically when needed;
- no critical action is hidden behind bottom nav or gesture areas;
- text/card sizing feels mobile-readable;
- Begin Observation gameplay flow still completes;
- settings/accessibility controls remain functional;
- no frozen gameplay behavior regresses.

### Block criteria

Do not merge if any of the following remain:

- unreadable text on a standard phone;
- inaccessible Begin Observation / result continuation actions;
- screens that cannot scroll to hidden content;
- bottom nav overlapping required controls;
- tutorial content clipped with no scroll path;
- gameplay flow regression;
- save/privacy/profile persistence regression.

---

## Final Sign-off

| Role | Name | Date | Decision | Notes |
|---|---|---|---|---|
| Android device tester |  |  | Pass / Block |  |
| Product owner |  |  | Merge / Hold |  |

If blocked, document exact device, screen, reproduction path, screenshot/video if available, and required correction before Update 1 begins.

# Homepage Experience Specification — Reverse-Engineered from Implementation

**Product:** Two Second Witness  
**Publisher:** ITTYBITTYBITES  
**Engine:** Godot 4.6.3  
**Platform:** Android (package: `com.ittybittybites.the2secondwitness`)  
**Date of Analysis:** 2026-07-14  
**Status:** Phase 6 — Production Readiness (locally complete)  
**Purpose:** Handoff document for future homepage/creative redesign

---

## 1. HOMEPAGE ENTRY FLOW

### 1.1 Full Launch Sequence

The app has a **linear, deterministic launch sequence** with no branching until the decision to show a privacy dialog or intro tutorial.

```
[App Icon Tapped]
        │
        ▼
[PublisherSplashScreen] ─── displayed immediately, no delay
        │  1.4s minimum display (DISPLAY_DURATION), up to 3.5s max wait (MAX_WAIT)
        │  Tap-to-skip after 0.25s if boot completed
        │  Boot subsystem runs in background during this screen
        ▼
[TitleSplashScreen] ─── branded "Two Second Witness" boot screen
        │  Shows: "TWO SECOND WITNESS" + glowing eye motif + loading progress
        │  MIN_DISPLAY_TIME = 1.2s, MAX_BOOT_WAIT_TIME = 6.0s
        │  Real boot steps: Config → Save → Settings → Theme → Content → Audio → Nav → Finalize
        │  Progress bar fills as boot steps complete
        │
        ├── [First Launch?] ─── PrivacyTermsDialog modal (centered overlay)
        │       │  Shows: "Terms & Privacy" title, welcome text, 4 bullet points
        │       │  Buttons: ACCEPT & CONTINUE, VIEW PRIVACY POLICY, VIEW TERMS OF SERVICE
        │       │  Blocks screen beneath; must accept to proceed
        │       │  Policy version tracked: "4.0.0-2026-07-13"
        │       │  URLs: ittybittybites.github.io/two-second-witness/privacy
        │       │         ittybittybites.github.io/two-second-witness/terms
        │       ▼
        │   [Privacy Accepted] ─── persisted to profile + settings
        │
        ├── [Needs Intro Tutorial?] ─── checks `preferences.onboarding_completed`
        │       │  Routes to tutorial screen for first visible family
        │       ▼
        │   [Tutorial Completed]
        │
        └── [Returning User / Tutorial Done] ─── navigate_to("home")
                │
                ▼
            [HomeScreen]
```

**Key files:**
- `/home/user/2-second-witness-mobile/app/src/ui/screens/PublisherSplashScreen.gd` — ITTYBITTYBITES publisher intro (1.4s auto-advance)
- `/home/user/2-second-witness-mobile/app/src/ui/screens/TitleSplashScreen.gd` — branded loading screen with eye pulse, progress bar, privacy dialog trigger
- `/home/user/2-second-witness-mobile/app/src/ui/dialogs/PrivacyTermsDialog.gd` — centered modal with accept/view buttons
- `/home/user/2-second-witness-mobile/app/src/core/app/AppBoot.gd` — boot orchestrator (8 sequential steps)
- `/home/user/2-second-witness-mobile/app/src/ui/shell/AppShell.gd` — root container managing all shell layers

### 1.2 First-Time User Flow

1. App launches → **PublisherSplashScreen** shows "ITTYBITTYBITES" brand for 1.4s minimum
2. Transitions to **TitleSplashScreen** showing the "Two Second Witness" brand, the glowing eye icon, and a progress bar as services initialize
3. After boot completes AND minimum display time (1.2s) has passed:
   - If **privacy not acknowledged**: A centered modal (PrivacyTermsDialog) appears over the loading screen
   - User reads 4 bullet points about local storage, no account, no data collection, no ads
   - User must tap "ACCEPT & CONTINUE" (acceptance persisted to both ProfileService and SettingsService)
4. After privacy accepted, if **onboarding not completed**: Routes to the first visible family's tutorial
5. After tutorial → navigates to **HomeScreen**
6. If no tutorial needed → navigates directly to **HomeScreen**

**Important:** There is NO multi-step onboarding. No permissions are requested. No account creation. There is exactly one checkbox-style privacy dialog.

### 1.3 Returning User Flow

1. App launches → **PublisherSplashScreen** (1.4s minimum or tap-to-skip)
2. Transitions to **TitleSplashScreen** with loading progress
3. Boot completes → checks privacy (already acknowledged) → checks tutorial (already completed)
4. Navigates directly to **HomeScreen** with a fade transition
5. The HomeScreen calls `_refresh_data()` which queries `RecommendationService.get_home_snapshot()` on arrival

### 1.4 Conditions That Change the Experience

| Condition | Behavior |
|-----------|----------|
| `preferences.privacy_acknowledged` = false | Privacy dialog blocks progression |
| `preferences.onboarding_completed` = false | Routes to first family tutorial |
| `family_tutorial_versions` mismatched | Shows tutorial for updated family |
| Deep link / pending template | Skips splash; loads target screen directly |
| Boot failure | Shows error banner; stays on publisher splash |

---

## 2. HOMEPAGE FILE AND ARCHITECTURE MAP

### 2.1 Core Homepage Files

| File | Purpose |
|------|---------|
| `app/src/ui/screens/HomeScreen.tscn` | Scene file defining the full layout tree of the homepage |
| `app/src/ui/screens/HomeScreen.gd` | Script controlling all homepage behavior, data binding, button wiring |
| `app/src/gameplay/runtime/RecommendationService.gd` | Generates all data snapshots consumed by the homepage |
| `app/src/gameplay/runtime/PlayerProgressService.gd` | Provides player state, progress records, family progress |
| `app/src/gameplay/runtime/ChallengeSessionService.gd` | Launches challenge sessions from homepage actions |
| `app/src/gameplay/progression/AchievementService.gd` | Evaluates achievement progress and provides featured statuses |
| `app/src/gameplay/programs/ProgramService.gd` | Provides program data and recommendations |
| `app/src/ui/components/ExperienceCard.tscn` | Scene for the featured challenge type card |
| `app/src/ui/components/ExperienceCard.gd` | Script controlling the featured challenge card rendering |

### 2.2 Navigation & Shell Files

| File | Purpose |
|------|---------|
| `app/src/core/navigation/AppRoutes.gd` | Route definitions — "home" is the first tab route |
| `app/src/core/navigation/NavigationService.gd` | Orchestrates all navigation; manages history, BGM, analytics |
| `app/src/ui/shell/AppShell.tscn` | Root scene with content container, nav bar, top bar, overlays |
| `app/src/ui/shell/AppShell.gd` | Shell logic: screen caching, chrome visibility, safe areas, transitions |
| `app/src/ui/shell/MainNavigation.gd` | Bottom tab bar with 4 tabs: Home, Library, Profile, Settings |
| `app/src/ui/shell/TopBar.gd` | Top app bar with title, back button, profile/settings actions |
| `app/src/ui/layout/ResponsiveLayout.gd` | Shared responsive layout helpers (centering, gutters, safe areas) |

### 2.3 Theme & Design System Files

| File | Purpose |
|------|---------|
| `app/src/systems/theme/ThemeService.gd` | Full design token system; defines DARK and LIGHT token dictionaries |
| `app/src/systems/settings/SettingsService.gd` | Settings persistence; consumed by ThemeService for font scale, high contrast |
| `app/src/systems/accessibility/AccessibilityService.gd` | Controls animation, haptics, reduced motion settings |

### 2.4 Backend/Data Files

| File | Purpose |
|------|---------|
| `app/src/systems/save/ProfileService.gd` | Player profile persistence (all progress, stats, preferences) |
| `app/src/gameplay/progression/achievements.json` | Data-driven achievement definitions (26 achievements) |
| `app/src/gameplay/programs/programs.json` | Data-driven program definitions (9 curated programs) |
| `app/src/gameplay/families/manifest.json` | Registry of all challenge family modules (5 production + 1 fixture) |
| `app/src/core/app/AppState.gd` | App-level state machine (phase tracking, loading state, transient data) |
| `app/src/systems/audio/AudioService.gd` | BGM/SFX/UI audio management; maps scenes to BGM tracks |
| `app/src/systems/analytics/AnalyticsService.gd` | Analytics logging hooks throughout navigation and gameplay |

### 2.5 Asset Files Used on Homepage

| Asset | Path | Usage |
|-------|------|-------|
| Eye glow icon | `app/assets/brand/witness_eye_glow.png` | Hero section branding, loading overlay spinner |
| Home BGM | `app/assets/audio/bgm_home.wav` | Background music while on homepage |
| UI click | `app/assets/audio/ui_click.wav` | Button press feedback |
| UI unlock | `app/assets/audio/ui_unlock.wav` | Rank-up celebration sound |

### 2.6 Dependencies (services HomeScreen references)

HomeScreen directly accesses these global singletons (via Godot's auto-load system):

- `ThemeService` — design tokens, label styling
- `ProfileService` — profile save events
- `PlayerProgressService` — player state data
- `RecommendationService` — all homepage data snapshots
- `ChallengeSessionService` — challenge launch
- `AchievementService` — achievement progress updates
- `NavigationService` — screen navigation
- `AccessibilityService` — haptic feedback
- `AudioService` — UI sound effects
- `AppState` — loading state management
- `ResponsiveLayout` (static class) — responsive margin calculations

---

## 3. COMPLETE SCREEN BREAKDOWN

### 3.1 Scene Tree (from `HomeScreen.tscn`)

The homepage is structured as a vertically scrolling layout with these elements in top-to-bottom order:

```
HomeScreen (Control)
├── Background (ColorRect) ── fills entire screen, color #0F0F12
├── MainMargin (MarginContainer)
│   └── Scroll (ScrollContainer)
│       └── Content (VBoxContainer) ── separation: 18px
│           ├── Hero (VBoxContainer) ── center-aligned, separation: 4px
│           │   ├── BrandLabel ── "TWO SECOND WITNESS"
│           │   ├── EyeWrap (CenterContainer)
│           │   │   └── Eye (TextureRect) ── 160×64, witness_eye_glow.png
│           │   ├── GreetingLabel ── "READY, WITNESS?"
│           │   ├── RankLabel ── "Observer" (dynamic)
│           │   └── Tagline ── "Notice details. Recall what mattered. Keep your streak alive."
│           │
│           ├── StatsRow (HBoxContainer) ── separation: 10px
│           │   ├── LevelCard (PanelContainer) ── "WITNESS LEVEL" / number
│           │   ├── ProgressCard (PanelContainer) ── "PROGRESS" / number
│           │   └── StreakCard (PanelContainer) ── "STREAK" / "0 · best 0"
│           │
│           ├── PlayNowButton (Button) ── 76px tall, primary purple style
│           │   └── Text: "PLAY NOW\n[recommendation title]" (two lines)
│           ├── RecommendationReason (Label) ── subtitle below Play Now
│           │
│           ├── PrimaryLinks (HBoxContainer) ── separation: 10px
│           │   ├── ContinueButton (Button) ── 58px tall, secondary style
│           │   └── LibraryButton (Button) ── 58px tall, secondary style
│           │
│           ├── FeaturedHeader (Label) ── "TODAY'S FEATURED CHALLENGE TYPE"
│           ├── FeaturedHost (VBoxContainer) ── hosts ExperienceCard or empty label
│           │
│           ├── AchievementsHeader (Label) ── "ACHIEVEMENTS IN PROGRESS"
│           ├── AchievementsHost (VBoxContainer) ── separation: 8px
│           │   └── [Dynamic: per-achievement progress cards or "all done" label]
│           ├── AchievementsButton (Button) ── 52px tall, "VIEW ALL ACHIEVEMENTS"
│           │
│           ├── QuickActionsHeader (Label) ── "QUICK ACCESS"
│           ├── QuickActions (HBoxContainer) ── separation: 10px
│           │   ├── ProfileButton (Button) ── 52px tall, "PROFILE"
│           │   └── SettingsButton (Button) ── 52px tall, "SETTINGS"
│           │
│           ├── ProgramsCard (PanelContainer) ── card with border
│           │   └── Title: "PROGRAMS · CURATED RUNS"
│           │       Copy: dynamic (featured program or generic message)
│           │       ProgramsButton: "BROWSE PROGRAMS"
│           │
│           └── BottomSpacer (Control) ── 24px padding at scroll bottom
```

### 3.2 Element-By-Element Specification

#### Hero Section

| Property | Value |
|----------|-------|
| **BrandLabel** | Text: "TWO SECOND WITNESS" (static). Style: `label_small`, color token `text_tertiary`. Center-aligned. |
| **Eye** | Texture: `witness_eye_glow.png`. Size: 160×64. Stretch mode: Keep aspect centered. No animation on homepage (static). |
| **GreetingLabel** | Text: "READY, WITNESS?" (static). Style: `display` (34px, bold), color `text_primary`. Center-aligned. |
| **RankLabel** | Text: Dynamic — from `witness_summary.rank` (default: "Observer"). Style: `title` (22px), color `primary_variant`. **Animates on rank-up**: modulates to gold (#FFC84D) and scales to 1.12x with Tween, plays `ui_unlock` sound. |
| **Tagline** | Text: "Notice details. Recall what mattered. Keep your streak alive." (static). Style: `body_small` (16px), color `text_secondary`. Center-aligned. Auto-wraps. |

#### Stats Row

Three equally-sized stat cards in a horizontal row.

| Stat Card | Label (static) | Value (dynamic) |
|-----------|----------------|-----------------|
| **LevelCard** | "WITNESS LEVEL" | `witness_summary.level` (default: "1") |
| **ProgressCard** | "PROGRESS" | `witness_summary.progress_points` (default: "0") |
| **StreakCard** | "STREAK" | Format: `"X · best Y"` from `current_streak` and `best_streak` (default: "0 · best 0") |

Each card: PanelContainer with 16px corner radius, surface background (#1E1E26), 1px border (#2E2E3A), 10px shadow. Internal padding 10px horizontal, 12px vertical. Label/text values styled with theme tokens. No interactivity.

#### Play Now Button

| Property | Value |
|----------|-------|
| Min height | 76px |
| Text format | `"PLAY NOW\n[recommendation title]"` (two lines) |
| Style | **Primary** — purple background (`#6A3DFF`), no border, white text, 16px corner radius |
| States | Disabled when recommendation is empty; loading state disables during session preparation |
| Action | Calls `ChallengeSessionService.start_recommended_session("play_now")` |
| Fallback | If session fails to start, navigates to `"experiences"` (Library) |
| Feedback | Haptic (20ms vibration) + `ui_click` sound |

#### Recommendation Reason

| Property | Value |
|----------|-------|
| Text | Dynamic — from `play_now.reason_text` (default: "Your next round is ready") |
| Style | `caption` (14px), color `text_secondary`. Center-aligned. |

#### Continue Button

| Property | Value |
|----------|-------|
| Min height | 58px |
| Text format | `"CONTINUE · [program title]"` if recent; else `"CONTINUE · START RECOMMENDATION"` |
| Style | **Secondary** — surface background (#1E1E26), 1px border (#2E2E3A), 16px corner radius |
| States | Disabled when continue recommendation is empty |
| Action | Calls `ChallengeSessionService.start_continue_session("continue")` |
| Fallback | Falls back to Play Now if no valid continue exists |

#### Library Button

| Property | Value |
|----------|-------|
| Text | "CHALLENGE LIBRARY" (static) |
| Style | Secondary (same as Continue) |
| Action | Navigates to `"experiences"` route |

#### Featured Section

| Property | Value |
|----------|-------|
| **FeaturedHeader** | Text: "TODAY'S FEATURED CHALLENGE TYPE" (static). Style: `label` (16px), color `text_tertiary` |
| **FeaturedHost** | Contains either: an `ExperienceCard` instance (with full card UI) or a fallback label "A featured Challenge Type will appear when content is available." |

The featured challenge type is selected deterministically by date: `RecommendationService.recommend_featured()` uses `Time.get_date_string_from_system()` hashed against available unlocked families.

The `ExperienceCard` (from `app/src/ui/components/ExperienceCard.tscn`) is a rich card displaying:
- Artwork (preview image from manifest)
- Title
- Description (3 lines max)
- Lock/Ready state label
- Mastery % with progress bar
- Rounds completed + progress points
- Accuracy %
- Best streak
- Play button and Tutorial replay button
- Favorite toggle (☆/★)

#### Achievements Section

| Property | Value |
|----------|-------|
| **AchievementsHeader** | "ACHIEVEMENTS IN PROGRESS" (static) |
| **AchievementsHost** | Contains up to 3 achievement progress cards (from `get_featured_statuses(3)`) or "Every current milestone is unlocked." |

Each achievement preview card shows:
- Title
- Current / Target count (e.g. "5 / 10")
- Progress bar (thin, 7px height)

| Property | Value |
|----------|-------|
| **AchievementsButton** | Text: "VIEW ALL ACHIEVEMENTS". Style: secondary. Action: navigates to `"achievements"` route |

#### Quick Actions

| Button | Action | Notes |
|--------|--------|-------|
| **ProfileButton** | Navigate to `"profile"` | 52px tall, secondary style |
| **SettingsButton** | Navigate to `"settings"` | 52px tall, secondary style |

#### Programs Card

| Property | Value |
|----------|-------|
| **Title** | "PROGRAMS · CURATED RUNS" (static) |
| **Copy** | Dynamic: `"Featured Program Title · Description"` if featured program exists; else "Curated challenge journeys are ready from the Programs tab." |
| **ProgramsButton** | Text: "BROWSE PROGRAMS". Disabled when no programs available. Action: navigates to `"programs"` |

### 3.3 Visual Design Token Reference (Dark Mode)

All values from `DARK_TOKENS` in `ThemeService.gd`:

```json
{
  "background": "#0F0F12",
  "background_secondary": "#1A1A1F",
  "background_tertiary": "#24242C",
  "surface": "#1E1E26",
  "surface_elevated": "#2A2A36",
  "primary": "#6A3DFF",
  "primary_variant": "#8A68FF",
  "secondary": "#2EE6A6",
  "accent": "#FF6B6B",
  "text_primary": "#FFFFFF",
  "text_secondary": "#B8B8CC",
  "text_tertiary": "#8A8AA3",
  "border": "#2E2E3A",
  "border_strong": "#3D3D4D",
  "radius_sm": 8,
  "radius_md": 12,
  "radius_lg": 20,
  "spacing_xs": 4,
  "spacing_sm": 8,
  "spacing_md": 16,
  "spacing_lg": 24,
  "spacing_xl": 32,
  "touch_target_min": 48
}
```

**Typography:**

| Token | Size | Weight |
|-------|------|--------|
| display | 34px | 700 |
| headline | 26px | 700 |
| title | 22px | 600 |
| body | 18px | 400 |
| body_small | 16px | 400 |
| caption | 14px | 500 |
| label | 16px | 600 |
| label_small | 14px | 600 |
| button | 18px | 600 |

---

## 4. USER EXPERIENCE FLOW

### 4.1 What the User Sees First

When the homepage appears after launch splash, the user immediately sees:

1. **Rank name** ("Observer") and greeting ("READY, WITNESS?") — top-center, most prominent text
2. **The eye icon** — brand symbol
3. **Tagline** — "Notice details. Recall what mattered. Keep your streak alive."
4. **Three stat cards** — Level, Progress, Streak (numeric, at-a-glance)
5. **Play Now button** — largest, most visually prominent action (purple, 76px tall, two-line text)

### 4.2 Most Prominent Action

**Play Now** is the primary action. It is:
- The largest button on screen (76px vs 52-58px for others)
- The only **primary** (purple) button in the main flow
- Placed high in the scroll order (3rd item in Content)
- Contains a two-line label with the challenge type name

### 4.3 All Available Actions

| Action | Interaction | Navigation |
|--------|-------------|------------|
| Play Now | Tap primary button | → Challenge observation screen |
| Continue | Tap secondary button | → Resume recent challenge/program |
| Challenge Library | Tap secondary button | → `"experiences"` screen |
| Featured challenge card | Tap card's Play button | → That challenge type |
| Featured tutorial | Tap card's Tutorial button | → `"tutorial"` screen with replay |
| Featured favorite | Tap card's ☆/★ button | Toggles favorite (stays on Home) |
| View All Achievements | Tap button | → `"achievements"` screen |
| Profile | Tap button | → `"profile"` screen |
| Settings | Tap button | → `"settings"` screen |
| Browse Programs | Tap button | → `"programs"` screen |
| Bottom tab: Library | Tap tab | → `"experiences"` screen |
| Bottom tab: Profile | Tap tab | → `"profile"` screen |
| Bottom tab: Settings | Tap tab | → `"settings"` screen |

### 4.4 Step-by-Step Flows

**Flow A: New User Plays First Round**
1. Launch → publisher splash → title splash → privacy dialog → accept → (optional tutorial) → Home
2. Home shows: "Observer" rank, Level 1, Progress 0, Streak 0 · best 0
3. Play Now button shows the first recommended challenge type (prioritizes unplayed types)
4. User taps Play Now → loading overlay "Preparing your recommended round…" → observation screen
5. User completes challenge → result screen → Continue or return Home
6. Back on Home: stats update, achievement previews appear

**Flow B: Returning User Resumes**
1. Launch → publisher splash → title splash → Home
2. Home loads snapshot: shows updated level/rank/progress/streak from saved profile
3. Continue button shows the most recently played challenge type
4. User can also tap Play Now for a fresh recommendation

**Flow C: Featured Challenge Discovery**
1. User sees "TODAY'S FEATURED CHALLENGE TYPE" section
2. The card shows artwork, title, description, mastery info
3. User taps PLAY NOW → launches that challenge type
4. User can also ♥ to favorite, or replay tutorial

**Flow D: Checking Progress**
1. User taps Profile → sees: rank, level, accuracy, challenges completed, best streak
2. Sees mastery bars for each challenge type
3. Sees recent challenge history (last 6 rounds)
4. Sees achievement summary + program progress

### 4.5 How the Homepage Changes After Progress

- **Rank** updates from "Observer" → "Noticer" (level 3) → "Attentive Witness" (level 6) → "Sharp Witness" (level 12) → "Master Witness" (level 20+)
- **Level** increments every 100 progress points (1 + floor(total_progress / 100))
- **Streak** shows current and best
- **Progress** shows accumulated points
- **Achievements** section shows progress toward next milestones
- **Mastery** on featured cards updates per-family
- **Recommendations** shift: after playing a type, it penalizes repeats and recommends unplayed types

---

## 5. HOMEPAGE PURPOSE AS CURRENTLY IMPLEMENTED

### 5.1 Facts (from code)

- The homepage is a **data-driven product hub** that never names a specific challenge type ID
- It serves as the **primary navigation origin** — most user journeys start here
- It is the **first substantive screen** after the boot sequence
- It is **one of four tabs** in the bottom navigation, but serves as the default landing
- It provides a **snapshot of user progress** (level, rank, streak, achievements)
- It surfaces **three recommendation paths**: Play Now (algorithmic), Continue (history-based), and Featured (date-based)
- It provides **access to all secondary screens**: Library, Profile, Settings, Achievements, Programs, Tutorial

### 5.2 Interpretations (based on implementation patterns)

- **What role:** The homepage positions itself as a "witness command center" — a place to see your status and start a new observation round
- **What user need:** Curiosity about progress + desire for quick, varied gameplay
- **What the product tries to accomplish:** Get the user into a challenge round with minimal friction; encourage daily return via streaks and featured content
- **What behavior it encourages:** Regular play (streaks), variety (algorithm avoids repeats), discovery (featured rotation), mastery (visible progress bars)
- **Emotional tone:** "Ready, Witness?" is encouraging, not pressuring. The eye motif and purple/white dark theme feel premium and slightly mysterious. The tagline emphasizes noticing and recalling — cognitive empowerment.

---

## 6. PROGRESSION AND REWARD SYSTEM

### 6.1 Witness Level & Rank

**Storage:** `profile.witness_progress` in ProfileService → persisted via SaveService

**Calculation:**
```python
witness_level = 1 + floor(total_progress / 100)
total_progress accumulates from `progress_points` earned per round
```

**Rank thresholds (from `PlayerProgressService.gd`):**

| Level | Rank |
|-------|------|
| 1-2 | "Observer" |
| 3-5 | "Noticer" |
| 6-11 | "Attentive Witness" |
| 12-19 | "Sharp Witness" |
| 20+ | "Master Witness" |

**When it changes:** After each completed round (`record_result` → `_update_witness_progress`)

**How user sees it:**
- RankLabel on homepage hero (with gold flash animation on rank-up)
- Stat cards showing Level and Progress
- Profile screen showing current rank, level, and next rank milestone

### 6.2 Streaks

**Storage:** `profile.witness_progress.families[family_id].current_streak` and `.best_streak` per-family; also `profile.stats.streak_current` and `streak_best` globally

**Calculation:** Incremented on correct answer, reset to 0 on incorrect. Best is max of current over time.

**How user sees it:** StreakCard on homepage ("X · best Y"), Profile stats

### 6.3 Mastery

**Storage:** `witness_progress.families[family_id].mastery` (0-100 float)

**Calculation:** Determined by each family's scoring policy; declared in `mastery_change` dictionary on results

**How user sees it:** ExperienceCard mastery bar (homepage featured), Profile family mastery section

### 6.4 Achievements

**Definition file:** `app/src/gameplay/progression/achievements.json` — 26 achievements

**Storage:** `profile.achievements` (array of unlocked IDs), `profile.achievement_progress` (dictionary of ID → value)

**Evaluation:** `AchievementService.evaluate_after_result()` runs after each challenge result. Each achievement has a `criterion` (total_plays, family_correct, family_mastery, unique_families_played, favorites_count, program_runs, families_mastery_at_least, best_streak, fast_response, comeback), a `target`, and optionally `family_id` or `threshold_ms`.

**How user sees it:** Homepage achievements section (3 closest to completion), Achievements screen (full list), Profile summary

**Unlock feedback:** Plays `ui_achievement` sound, ducks BGM momentarily

### 6.5 Programs (Curated Runs)

**Definition file:** `app/src/gameplay/programs/programs.json` — 9 programs (Daily Witness, Observation Bootcamp, Rapid Recall, Mixed Rotation, Favorites Run, Weekend Challenge, Detail Detective, Set & Sequence, Five-Type Tour)

**Storage:** `profile.program_progress` per-program ID

**Mechanics:** Each program has a round count (3-10), a selection policy (daily_rotation, focus_tags, favorites, mixed_rotation), schedule (always/weekend), and required level.

**How user sees it:** Programs card on Home, Program summaries on Profile, full Programs screen

### 6.6 Points/Currency

**There is NO virtual currency system.** The only "currency" is:
- `progress_points` — earned per round, accumulates toward Witness Level
- These are session-level, not purchasable, not spendable

---

## 7. RETURN USER EXPERIENCE

### 7.1 What Changes

When a returning user opens the app:

- **Stats update:** Saved level, rank, progress, and streak are loaded from profile
- **Recommendations are fresh:** `RecommendationService.get_home_snapshot()` recalculates based on current player state
- **Featured is day-based:** Same feature all day, changes next day
- **Continue works:** Shows the last played challenge type from saved `last_played_family_id`
- **Achievements update:** In-progress achievements reflect latest progress
- **Programs show progress:** If a program was active, Continue picks up where left off

### 7.2 What Progress Is Remembered

Everything in `profile` is persisted:

- Witness progress (level, rank, total points, per-family mastery/history/streaks)
- Stats (total observations, correct, fastest reaction, streak)
- Achievement state (unlocked IDs, progress values)
- Program progress (per-program rounds, completions, accuracy)
- Active program ID
- Favorites list
- Preferences (privacy ack, tutorial versions, onboarding flag)

### 7.3 What Encourages Returning

- **Streak system** — visible on homepage; best streak motivates continued play
- **Daily featured challenge** — changes daily, deterministic rotation
- **Mastery progression** — visible progress bars show improvement trajectory
- **Achievement goals** — "3 / 10 correctly done" creates completion drive
- **Programs** — multi-round curated runs with completion tracking

### 7.4 What Does NOT Change

- The homepage layout is **static** — same sections in same order
- The tagline is **static**
- The hero text "READY, WITNESS?" is **static** — no personalization beyond rank
- There is **no daily reward popup, no notification, no push prompt**

---

## 8. VISUAL DESIGN SPECIFICATION

### 8.1 Colors

See section 3.3 for the complete dark-mode token set. The homepage uses these specific tokens:

| Token | Value | Usage |
|-------|-------|-------|
| background | `#0F0F12` | Full screen background |
| surface | `#1E1E26` | Card backgrounds |
| primary | `#6A3DFF` | Play Now button, primary CTAs |
| primary_variant | `#8A68FF` | Rank label, progress bar fill |
| text_primary | `#FFFFFF` | Main body text |
| text_secondary | `#B8B8CC` | Secondary text |
| text_tertiary | `#8A8AA3` | Labels, headers, captions |
| border | `#2E2E3A` | Card borders, secondary buttons |
| secondary | `#2EE6A6` | Success indicators |

**High Contrast Mode** adjustments (in `ThemeService.gd`):
- Background → `#000000` (darker)
- Primary → `#9D83FF` (brighter purple)
- Text → `#FFFFFF` / `#F1F1F7` (brighter)
- Borders → `#77778A` (more visible)

### 8.2 Typography

- All text uses the system default font (no custom font family specified)
- Font sizes range from 14px (caption) to 34px (display)
- Weight varies: 400 (body), 500 (caption), 600 (label/title), 700 (display/headline)
- Font scale can be adjusted by user in Settings (0.8x to 1.4x)
- Headers are uppercase by convention: "TODAY'S FEATURED CHALLENGE TYPE", "ACHIEVEMENTS IN PROGRESS"

### 8.3 Layout

- **Scrollable** vertical layout (ScrollContainer wrapping VBoxContainer)
- **20px edge gutters** on phones (via MainMargin)
- **Center-column layout** on tablets (viewport > 1280px) — content constrained to 720px max
- **18px** default separation between sections
- **4px** separation within hero, **10px** between stat cards and button rows
- Bottom spacer adds 24px padding at scroll end

### 8.4 Buttons

- **Primary (Play Now):** Purple fill (`#6A3DFF`), no border, white text, 16px corner radius, 14px inner padding (top/bottom), 16px (left/right), 76px min height
- **Secondary (all others):** Surface fill (`#1E1E26`), 1px border (`#2E2E3A`), white text, 16px corner radius, 52-58px min height
- **Hover:** 8% lighter background
- **Pressed:** 10% darker background
- **Disabled:** dimmed via `disabled` property

### 8.5 Cards

- Background: `surface` (`#1E1E26`)
- Border: 1px `#2E2E3A`, 16px corner radius
- Shadow: 10px size, 3px offset, 22% opacity black
- Stat cards: 10px horizontal / 12px vertical internal padding
- Programs card: 16px horizontal / 14px vertical internal padding

### 8.6 Animations

- **Screen transition:** Fade in (0.2s) from transparent — only for non-launch routes
- **Rank-up animation:** Gold modulate (#FFC84D) + scale to 1.12x and back (0.5s total), plays `ui_unlock` sound
- **No perpetual animations on homepage** (the eye is static, unlike the pulsing eye on the title splash)

### 8.7 Icons & Images

- **Eye glow icon:** 160×64 px, centered, used as brand element in hero
- **ExperienceCard artwork:** From each family's `preview_image` metadata field (SVG or PNG); displayed at 144px min height, keeps aspect ratio
- **No system icons** — all buttons use text labels only
- **No emoji or icon fonts**

### 8.8 Mobile Considerations

- Touch targets minimum 48px (enforced by `ResponsiveLayout.enforce_touch_targets`)
- Safe area insets applied: top ≥44px (Android/iOS), bottom ≥24px
- Bottom navigation tab bar: 64px+ height, rounded top corners, shadow
- Top bar: 60px+ height, 1px bottom border
- Content area sits between top bar and nav bar, with safe area inset
- Scrolling handles content that exceeds viewport

---

## 9. CONTENT MODEL

### 9.1 Static vs Dynamic Content

| Content | Type | Source |
|---------|------|--------|
| Brand label "TWO SECOND WITNESS" | Static | `HomeScreen.tscn` hardcoded |
| Greeting "READY, WITNESS?" | Static | Hardcoded |
| Tagline | Static | Hardcoded |
| Rank label | Dynamic | `witness_summary.rank` |
| Level / Progress / Streak values | Dynamic | `witness_summary` |
| Play Now text | Dynamic | `play_now.title` from recommendation |
| Continue text | Dynamic | `continue.program_title` or fallback |
| Featured section | Dynamic | `featured` + `available_challenge_types` |
| Achievements | Dynamic | `achievements_in_progress` from AchievementService |
| Programs card copy | Dynamic | `featured_program` or generic message |
| Stat card labels ("WITNESS LEVEL", "PROGRESS", "STREAK") | Static/Theme | Set at runtime by `_style_stat_card` |

### 9.2 Data Sources

| Data | Service | Method |
|------|---------|--------|
| Full homepage snapshot | `RecommendationService` | `get_home_snapshot(player_state)` |
| Player state | `PlayerProgressService` | `get_player_state()` |
| Achievement statuses | `AchievementService` | `get_featured_statuses(3)` |
| Program definitions | `ProgramService` | `get_definitions()` |
| Featured program | `ProgramService` | `get_featured_program(player_state)` |
| Player profile | `ProfileService` | `profile` property |

### 9.3 The `get_home_snapshot()` Contract

Returns a dictionary with this structure (from `RecommendationService.gd`):

```javascript
{
  "play_now": {
    "family_id": "scene_investigation",
    "template_id": "round_a", 
    "title": "Scene Investigation",
    "description": "...",
    "preview_image": "res://...",
    "reason": "unplayed_challenge_type",
    "reason_text": "Try a Challenge Type you have not played yet"
  },
  "continue": { /* same structure, or empty dict */ },
  "featured": { /* same structure, date-rotated */ },
  "available_challenge_types": [
    {
      "family_id": "scene_investigation",
      "id": "round_a",
      "template_id": "round_a",
      "default_template_id": "round_a",
      "title": "Scene Investigation",
      "description": "Generated scenes...",
      "gameplay_focus": ["Observation", "Attention", "Change Detection"],
      "recommendation_weight": 1.0,
      "favorite": false,
      "preview_image": "res://assets/gameplay/scene_investigation_preview.svg",
      "required_level": 1,
      "locked": false,
      "estimated_duration_sec": 15,
      "progress": {
        "plays": 5,
        "correct": 3,
        "accuracy": 0.6,
        "mastery": 35.0,
        "confidence": 0.42,
        "current_streak": 2,
        "best_streak": 3,
        "progress_points": 47
      },
      "tutorial_profile": { /* dictionary */ }
    }
    // ... more families
  ],
  "recent": { /* last played family's available_challenge_types entry */ },
  "has_recent": true,
  "achievements_in_progress": [
    { "id": "...", "title": "...", "current": 3, "target": 10, "ratio": 0.3, "order": 5 }
  ],
  "featured_program": {
    "id": "daily_witness",
    "title": "Daily Witness",
    "description": "A fresh three-round mix...",
    "progress": { /* ... */ }
    // ... full program definition
  },
  "program_count": 9,
  "witness_summary": {
    "level": 1,
    "rank": "Observer",
    "progress_points": 47,
    "current_streak": 2,
    "best_streak": 3
  }
}
```

### 9.4 Selection Logic

**Play Now algorithm** (in `recommend_start`):
1. Filter to player-visible, unlocked challenge types
2. Prefer any type with zero plays (introduce everything once)
3. Then sort by: mastery + plays*0.5 + repeat_penalty - recommendation_weight*2
4. Pick lowest score (least-played, lowest-mastery, not-last-played)
5. Return recommendation with title, template, reason text

**Continue algorithm** (in `recommend_continue`):
1. Check if an active program exists → resume program
2. Otherwise read `last_played_family_id` and `last_played_template_id`
3. Verify family exists and is unlocked
4. Resume that family/template
5. Fall back to `recommend_start` if nothing valid

**Featured algorithm** (in `recommend_featured`):
1. Get all unlocked challenge types
2. Hash today's date string → pick index: `abs(day_string.hash()) % unlocked.size()`
3. Same feature all day, changes at midnight

### 9.5 Rotation Systems

- **Featured:** Daily rotation via date hash, no explicit content calendar
- **Programs:** Some use `daily_rotation` policy (Daily Witness), some use `mixed_rotation` (least-used), some use `focus_tags` (tag-filtered), some use `favorites` (user's favorites only)
- **No time-limited events or seasons**

---

## 10. TECHNICAL BEHAVIOR

### 10.1 Signals & Events

HomeScreen connects to these signals:

| Signal | Connected | Purpose |
|--------|-----------|---------|
| `resized` | `_apply_responsive_layout()` | Recalculate margins on resize |
| `ThemeService.theme_changed` | `_on_theme_changed()` | Restyle when theme switches |
| `ProfileService.profile_saved` | `_on_profile_saved()` | Refresh data after profile change |
| `AchievementService.achievement_progress_updated` | `_on_achievement_progress_updated()` | Refresh achievements display |

HomeScreen emits no signals directly — it calls NavigationService and ChallengeSessionService methods.

### 10.2 State Management

- **AppState** tracks current phase (`HOME` when on homepage), loading state, and transient data
- **PlayerProgressService** provides the canonical player state dictionary
- **ProfileService** holds the persisted profile; `PlayerProgressService` wraps it as an adapter
- HomeScreen stores local `_home_data` (the snapshot) and `_launch_pending` / `_refresh_pending` flags

### 10.3 Save/Load Behavior

- Profile auto-saves after every challenge result (in `PlayerProgressService.record_result`)
- Profile auto-saves after privacy acknowledgment, favorite toggle, preference changes
- HomeScreen does NOT trigger saves — it reads from services that auto-save
- Save service: `app/src/systems/save/SaveService.gd` — persists to local device storage

### 10.4 Analytics Hooks

Path: `app/src/systems/analytics/AnalyticsService.gd`

Navigation logging is centralized in `NavigationService._log_screen_view()` — screens do not log their own views.

Events that fire from homepage actions:
- `tab_selected` — when navigating via bottom tabs
- `screen_presented` — screen load timing and cache status
- Navigation events — logged by NavigationService as screen views

### 10.5 Error Handling

| Scenario | Behavior |
|----------|----------|
| Session preparation fails | Shows error banner ("That challenge could not be prepared. Please try again.") for 4s |
| No recommendation available | Play Now and Continue buttons become disabled |
| Profile load fails | Falls back to default profile |
| App boot fails | Shows error banner, stays on publisher splash |
| Unavailable route | Shows "This screen is unavailable." fallback |

No crash-on-error patterns. `ErrorHandler` captures errors with severity levels and emits user messages.

### 10.6 Performance Considerations

- Screens are cached (`CACHEABLE_ROUTES` includes `"home"`)
- Data refresh is deferred via `call_deferred("_refresh_data")` when returning from another screen
- Loading overlay uses the branded eye icon (not a generic spinner)
- BGM transitions smoothly when navigating to/from home (0.45s fade)
- Touch target enforcement happens after screen mounting

### 10.7 Device-Specific Behavior

| Device | Behavior |
|--------|----------|
| Android phone | Full-screen with safe area insets (44px top, 24px bottom) |
| iOS | Same safe area handling |
| Tablet / Foldable | Content centered in 720px column when viewport > 1280px |
| Desktop / Editor | Also gets centered layout; minimum safe areas 12px top/bottom |
| Devices with notches | Safe area insets respected |
| Devices with gesture nav | Bottom inset added for nav bar + gesture area |

---

## 11. CURRENT HOMEPAGE EXPERIENCE SUMMARY

**The homepage currently functions as a data-driven witness command center.** It presents the user's progress stats (level, rank, streak), offers three gameplay entry points (Play Now, Continue, Featured), and provides navigation to all secondary areas (Library, Profile, Settings, Achievements, Programs).

**User journey:** The user arrives after a branded splash/loading sequence. They see their rank, greeting, and stats at a glance. The Play Now button — large, purple, centrally positioned — is the clear primary action. Below it, Continue and Challenge Library offer secondary paths. Scrolling reveals the daily featured challenge type, in-progress achievements, quick-access buttons to Profile and Settings, and a Programs card.

**Main interaction:** Tap Play Now → brief loading overlay → challenge observation screen. The entire flow is designed for <2 second transitions.

**Reward/progression loop:** Each completed challenge earns progress points → increases Witness Level → unlocks new ranks → streaks track consistency → mastery tracks per-type skill → achievements provide milestone goals. All visible on the homepage.

**Emotional tone:** Premium, calm, encouraging. Dark purple/white aesthetic. "Ready, Witness?" invites participation without pressure. The eye motif suggests observation and awareness.

**Key differentiators:**
- **Zero challenge-type-specific code** on the homepage — entirely data-driven
- **Algorithmic variety** — Play Now introduces unseen types, avoids repeats
- **Daily deterministic feature** — same challenge all day, changes automatically
- **No virtual currency, no purchases, no ads, no accounts**
- **Progress is local-only** — no cloud save, no login required

---

## 12. INFORMATION REQUIRED BEFORE CREATING NEW HOMEPAGE CONCEPTS

### 12.1 Current Homepage Goals

1. Provide a clear, immediate path to start a challenge (Play Now)
2. Show the user their progress at a glance (level, rank, streak)
3. Enable resume of recent activity (Continue)
4. Surface daily variety (Featured Challenge Type)
5. Drive discovery of the full product (Library, Programs, Achievements)
6. Provide access to identity and settings (Profile, Settings)

### 12.2 Existing Mechanics That Must Be Preserved

- **Data-driven recommendations** — the homepage must not hardcode challenge type IDs or names
- **Three entry points** — Play Now (algorithmic), Continue (history-based), Featured (date-based)
- **Progress display** — level, rank, streak must be visible somewhere
- **Achievement awareness** — some surface showing achievement progress
- **Programs surfacing** — some mention of curated runs
- **Tab-based navigation** — Home is one of 4 tabs; must remain compatible with tab system
- **Scrollable layout** — must fit in a vertical scroll container
- **Loading overlay** — session preparation shows branded loading with eye icon
- **Error resilience** — disabled buttons when no data available

### 12.3 Constraints

- **No account system** — everything is local device storage
- **No virtual currency** — cannot add spendable tokens without architectural changes
- **No push notifications** — no infrastructure for reminders
- **No in-app purchases** — store page exists but no IAP implementation
- **No ads** — the PrivacyTermsDialog explicitly states this
- **Single-player only** — no multiplayer, no social features
- **Offline-first** — no network calls on the homepage
- **Godot 4.6.3** — must work within this engine
- **Mobile-first** — designed for portrait phone screens
- **Theme system** — must work in both dark and light modes, plus high-contrast
- **Accessibility** — must support reduced motion, text scaling, haptic control

### 12.4 Technical Limitations

- **No web views** — in-app browser for privacy/terms opens `OS.shell_open()` (external browser)
- **No real-time/websocket** — everything is request-response from local services
- **No animation framework beyond Godot Tweens** — no Lottie, no Spine
- **Text-only buttons** — no icon font; all button text is uppercase labels
- **Image formats** — PNG, SVG, WAV, OGG only; no GIF, MP4 on homepage
- **No dynamic font loading** — uses system default font only
- **Screen caching** — home screen instance is cached; data refreshes on nav-to, not on timer

### 12.5 Brand Requirements

- "Two Second Witness" brand name must appear
- Publisher "ITTYBITTYBITES" appears on splash, not on homepage
- Eye motif (witness_eye_glow.png) is the core brand icon
- Color identity: purple (`#6A3DFF`) primary, dark backgrounds (`#0F0F12`), white text
- Dark theme is default; light theme exists but is secondary
- Language is "observation" and "witness" focused, not "test" or "quiz"
- No competitive/game-like elements that suggest speed pressure (e.g., no countdown timers on homepage)

### 12.6 User Expectations

- Returning users expect to see their saved progress (level, rank, streak)
- Users expect to start playing within 1-2 taps
- Users expect a different featured challenge each day
- Users expect Continue to resume their last session
- Users expect to find all challenge types in the Library

### 12.7 Features Already Implemented

| Feature | File | Status |
|---------|------|--------|
| Play Now recommendation | `RecommendationService.gd` | Complete |
| Continue recommendation | `RecommendationService.gd` | Complete |
| Daily featured challenge | `RecommendationService.gd` | Complete |
| Progress stats (level/rank/streak) | `HomeScreen.gd` | Complete |
| Rank-up celebration animation | `HomeScreen.gd` | Complete |
| Achievement progress preview | `AchievementService.gd` | Complete |
| Programs surface | `ProgramService.gd` | Complete |
| Favorites system | `PlayerProgressService.gd` | Complete |
| Tutorial replay | `ExperienceCard.gd` | Complete |
| Responsive layout | `ResponsiveLayout.gd` | Complete |
| Dark/light theme | `ThemeService.gd` | Complete |
| Accessibility (reduced motion, font scale, high contrast) | `AccessibilityService.gd`, `SettingsService.gd` | Complete |
| Safety area/notch handling | `AppShell.gd` | Complete |

---

## 13. COMPLETE APPLICATION EXPERIENCE MAP

### 13.1 Screen Hierarchy

```
App Launch
└── [PublisherSplashScreen]  ── ITTYBITTYBITES brand, 1.4s minimum
    └── [TitleSplashScreen]  ── Two Second Witness branded loading
        ├── [PrivacyTermsDialog]  ── MODAL over splash (first launch only)
        │   └── → TitleSplashScreen (after accept)
        ├── [TutorialScreen]  ── First-time tutorial (when needed)
        │   └── → Home
        └── HOME  ★  [HomeScreen]
            │
            ├── [Play Now] → [ObservationChallengeScreen]
            │   └── → [MemoryQuestionScreen]
            │       └── → [ResultScreen]
            │           ├── Continue → [next challenge]
            │           └── Home → HOME
            │
            ├── [Continue] → [same flow as Play Now]
            │
            ├── [Featured Card] → [same flow as Play Now]
            │
            ├── [Tab: Library] → [ExperiencesScreen] (Challenge Library)
            │   └── Each card → [same flow as Play Now]
            │
            ├── [Tab: Profile] → [ProfileScreen]
            │   ├── Achievement summary → [AchievementsScreen]
            │   └── Stats & Mastery (on-screen)
            │
            ├── [Tab: Settings] → [SettingsScreen]
            │   ├── Audio, Music, SFX controls
            │   ├── Haptics toggle
            │   ├── Reading Comfort Mode
            │   ├── Text Size slider
            │   ├── Reduced Motion toggle
            │   ├── High Contrast toggle
            │   ├── Color Assist
            │   ├── Privacy (link to policy)
            │   ├── Credits / About
            │   └── Reset Profile (debug only)
            │
            ├── [View All Achievements] → [AchievementsScreen]
            │
            ├── [Browse Programs] → [ProgramsScreen]
            │   └── Each program → Start/Resume → [same flow as Play Now]
            │
            └── [Tutorial Replay] → [TutorialScreen]
```

### 13.2 Screen Details

#### PublisherSplashScreen
- **Path:** `app/src/ui/screens/PublisherSplashScreen.tscn` + `.gd`
- **Purpose:** Display ITTYBITTYBITES publisher identity
- **Reached by:** App launch (first route)
- **Goes to:** TitleSplashScreen
- **Primary action:** Auto-advance after 1.4s (or tap-to-skip after 0.25s)
- **Info displayed:** Brand label "ITTYBITTYBITES", subtitle "Publisher"
- **Limitations:** None observed; performs as designed

#### TitleSplashScreen
- **Path:** `app/src/ui/screens/TitleSplashScreen.tscn` + `.gd`
- **Purpose:** Brand loading screen during boot; trigger for privacy dialog and tutorial
- **Reached by:** PublisherSplashScreen auto-advance
- **Goes to:** Home (or Privacy dialog, or Tutorial)
- **Primary action:** Wait for boot + minimum display time, then advance
- **Secondary action:** Tap to advance after boot complete
- **Info displayed:** "TWO SECOND WITNESS", pulsing eye icon, "YOU ARE" + "TWO SECOND WITNESS", tagline, status text, progress bar
- **Limitations:** None observed

#### PrivacyTermsDialog (Modal)
- **Path:** `app/src/ui/dialogs/PrivacyTermsDialog.tscn` + `.gd`
- **Purpose:** First-launch privacy acknowledgment
- **Reached by:** TitleSplashScreen when privacy not acknowledged
- **Goes to:** Back to TitleSplashScreen (which then advances)
- **Primary action:** "ACCEPT & CONTINUE"
- **Secondary actions:** "VIEW PRIVACY POLICY", "VIEW TERMS OF SERVICE" (opens external browser)
- **Info displayed:** 4 bullet points about data handling
- **Dependencies:** External URLs, local persistence

#### TutorialScreen
- **Path:** Per-family tutorial scenes (e.g., `SceneInvestigationTutorial.tscn`)
- **Purpose:** Teach first-time/changed challenge type mechanics
- **Reached by:** TitleSplashScreen (first launch), ExperienceCard tutorial button (replay)
- **Goes to:** Home or pending challenge
- **Primary action:** Complete tutorial steps
- **Limitations:** Tutorials are family-specific; no unified tutorial framework

#### HOME ★ HomeScreen
- **Path:** `app/src/ui/screens/HomeScreen.tscn` + `.gd`
- **Purpose:** Product hub — progress overview + action center
- **Reached by:** Default landing after launch sequence; bottom tab
- **Goes to:** All other screens via navigation
- **Primary action:** Play Now
- **Secondary actions:** Continue, Library, Featured, Achievements, Profile, Settings, Programs
- **Info displayed:** See section 3 above for complete breakdown
- **Limitations:** See section 13.3 below

#### ExperiencesScreen (Challenge Library)
- **Path:** `app/src/ui/screens/ExperiencesScreen.tscn` + `.gd`
- **Purpose:** Browse all available challenge types
- **Reached by:** Home library button, bottom tab "Library"
- **Goes to:** ObservationChallengeScreen (via card Play button)
- **Primary action:** Browse and select a challenge type
- **Info displayed:** Cards for each available family with artwork, stats, mastery
- **Limitations:** Cannot sort or filter; cards are in manifest order

#### ObservationChallengeScreen
- **Path:** `app/src/ui/screens/ObservationChallengeScreen.tscn` + `.gd`
- **Purpose:** Present the observation/presentation phase of a challenge
- **Reached by:** Play Now, Continue, Featured, Library card, Program
- **Goes to:** MemoryQuestionScreen
- **Primary action:** Observe presented content
- **Limitations:** Specific to observation-based challenge types

#### MemoryQuestionScreen
- **Path:** `app/src/ui/screens/MemoryQuestionScreen.tscn` + `.gd`
- **Purpose:** Present the response/recall phase
- **Reached by:** ObservationChallengeScreen auto-advance
- **Goes to:** ResultScreen
- **Primary action:** Submit answer
- **Limitations:** Specific to response-based interaction profiles

#### ResultScreen
- **Path:** `app/src/ui/screens/ResultScreen.tscn` + `.gd`
- **Purpose:** Show challenge outcome and progress earned
- **Reached by:** MemoryQuestionScreen after response
- **Goes to:** Next challenge or Home
- **Primary action:** Continue (next round) or Home
- **Info displayed:** Score, outcome, progress earned, achievements unlocked
- **Limitations:** No share functionality, no social comparison

#### ProfileScreen
- **Path:** `app/src/ui/screens/ProfileScreen.tscn` + `.gd`
- **Purpose:** Show player identity, stats, mastery, history
- **Reached by:** Home quick action, bottom tab "Profile"
- **Goes to:** AchievementsScreen (via card button)
- **Info displayed:** Avatar, rank, level, membership date, observation record (accuracy, total, best streak), family mastery with progress bars, achievement summary, recent history, program summary, collection progress
- **Dependencies:** PlayerProgressService, AchievementService, ProgramService

#### SettingsScreen
- **Path:** `app/src/ui/screens/SettingsScreen.tscn` + `.gd`
- **Purpose:** Application settings and information
- **Reached by:** Home quick action, bottom tab "Settings"
- **Info displayed:** Audio, Music, SFX sliders; Haptics, Reading Comfort Mode, Reduced Motion, High Contrast, Color Assist toggles; Text Size slider; Privacy link; Credits; About
- **Dependencies:** SettingsService, AccessibilityService, AudioService

#### AchievementsScreen
- **Path:** `app/src/ui/screens/AchievementsScreen.tscn` + `.gd`
- **Purpose:** Full achievement catalog with unlock status
- **Reached by:** Home "VIEW ALL ACHIEVEMENTS", Profile card
- **Goes to:** Back to previous screen
- **Info displayed:** All 26 achievements with title, description, progress bar, unlock state
- **Dependencies:** AchievementService

#### ProgramsScreen
- **Path:** `app/src/ui/screens/ProgramsScreen.tscn` + `.gd`
- **Purpose:** Browse and start curated challenge programs
- **Reached by:** Home "BROWSE PROGRAMS"
- **Goes to:** Start/Resume program → ObservationChallengeScreen
- **Info displayed:** Program cards with title, description, round count, progress, lock state
- **Dependencies:** ProgramService, ChallengeSessionService

### 13.3 Homepage Limitations Discovered

| Issue | Detail | Source |
|-------|--------|--------|
| No daily streak tracker | Only shows current/best streak, not consecutive days | `HomeScreen.gd` line referencing `stats.streak_current` |
| No greeting personalization | "READY, WITNESS?" is hardcoded; no time-of-day or name personalization | `HomeScreen.tscn` |
| No "get started" for empty state | A brand-new user sees "Observer" rank but no tutorial prompt on homepage itself | `HomeScreen.gd` — the tutorial is in the launch flow, not on Home |
| No refresh mechanism | Home only refreshes on `on_navigated_to` and on signal events; no pull-to-refresh, no timer | `HomeScreen.gd` |
| Stats are cumulative, not periodic | "PROGRESS" shows total points, not daily/weekly progress | `witness_summary.progress_points` |
| No content variety indication | The featured section label says "TODAY'S FEATURED CHALLENGE TYPE" regardless of whether the user has played it | `HomeScreen.tscn` |
| Programs card always visible | Even if no programs are available (level too low), the card shows with disabled button | `HomeScreen.gd` |
| No visual priority for in-progress programs | If a user is mid-program, Continue shows it, but the Programs card doesn't visually highlight "resume in progress" | `ProgramService.gd` |
| Static section headers | Headers don't change to reflect state (e.g., "ACHIEVEMENTS IN PROGRESS" shows even when all are complete) | `HomeScreen.tscn` |

---

## 14. USER JOURNEY ANALYSIS

### 14.1 New User Lifecycle

**First Launch:**
1. App icon tapped → 1.4s publisher splash (can tap to skip after 0.25s)
2. Title splash with loading progress (~1-3s depending on device)
3. Privacy dialog appears — user reads 4 bullet points about data handling
4. User taps "ACCEPT & CONTINUE" → acknowledgment saved locally
5. If onboarding not completed → first challenge type tutorial plays
6. Tutorial teaches the observation → recall → result loop
7. After tutorial → Home screen

**First interaction on Home:**
1. User sees "Observer" rank, Level 1, Progress 0, Streak 0
2. Play Now button recommends an unplayed challenge type
3. User taps → loading overlay → challenge begins
4. First challenge completed → Result screen shows first progress earned
5. "First Witness" achievement unlocks — sound plays, BGM ducks

**First return:**
1. Next app launch: shorter splash sequence → straight to Home
2. Home loads saved profile → shows Level 1+, Progress >0, Streak >0
3. Continue button shows the last played type
4. Achievements section shows "Consistency" progress (X of 20)

### 14.2 Returning User Lifecycle

1. Launch → 1.4s publisher splash → title splash (brief, boot likely cached) → Home
2. Home shows updated stats from last session
3. Play Now recommends a **different** type than last played (introduces variety)
4. Continue resumes last played type
5. Daily Featured may show a new or familiar type
6. User can: play, check Library, check Profile, adjust Settings, browse Programs

### 14.3 Long-Term User Lifecycle

- **Mastery:** Per-family mastery increases with correct answers (0-100 scale)
- **Level:** 20+ possible; each 100 progress points = 1 level
- **Ranks:** Observer → Noticer (3) → Attentive Witness (6) → Sharp Witness (12) → Master Witness (20)
- **Achievements:** 26 total milestones spanning all challenge types
- **Programs:** 9 curated runs (3-10 rounds each) with different selection policies
- **Replay:** No content cap; procedurally generated challenges per family
- **Retention systems:** Streak tracking (current + best), daily featured rotation, achievement progression

### 14.4 Critical Observation

**There is NO explicit "daily" system in the implementation.** While the featured challenge rotates by date, there is no:
- Daily login bonus
- Daily streak counter (streak tracks consecutive correct answers in-session, not calendar days)
- Daily quest/challenge
- Push notification for return

The streak on homepage (`stats.streak_current`) tracks **in-session correct answer streak**, not daily logins.

---

## 15. INFORMATION ARCHITECTURE REVIEW

### 15.1 Screen Priority Map

**Must see immediately (within 2s of app open):**
- Witness Level (number)
- Witness Rank (text)
- Play Now (action button)

**Should be one tap away:**
- Continue recent challenge
- Challenge Library
- Quick Profile access
- Quick Settings access

**Should be secondary (scroll to reach):**
- Featured challenge type
- Achievements in progress
- Programs card

**Should be hidden/settings:**
- Full achievement catalog
- Program detail and start
- Audio controls
- Theme/accessibility settings
- Privacy/legal info

### 15.2 Current IA Assessment

| Content | Where | Steps | Assessment |
|---------|-------|-------|------------|
| Player rank/level | Home hero (top) | 0 scroll | ✅ Immediate |
| Play Now | Home (position 3) | 0 scroll | ✅ Immediate |
| Continue | Home (position 4) | 0-1 scroll | ✅ Immediate |
| Challenge Library | Home button + tab | 1 tap | ✅ Well-placed |
| Featured challenge | Home (scroll) | 1-2 scrolls | ⚠️ Hidden below fold on small screens |
| Achievements progress | Home (scroll) | 2-3 scrolls | ⚠️ Important retention info is buried |
| Programs | Home (scroll) | 3-4 scrolls | ⚠️ Far down the page |
| Profile stats | Profile tab | 1 tap | ✅ Appropriate depth |
| Settings | Settings tab | 1 tap | ✅ Appropriate depth |
| Full achievements | Home → button | 2 taps | ✅ OK depth |
| Program detail | Home → button → Programs screen | 2 taps | ✅ OK depth |

### 15.3 Navigation Depth Issues

| Path | Depth | Notes |
|------|-------|-------|
| App open → Play → Challenge | 3-4 screens (Publisher → Title → Home → Challenge) | Boot sequence is one-time; cached after cold start |
| Home → Play → Complete → Next round | 3 screens (Observation → Recall → Result) | Well-optimized; auto-advance between phases |
| Home → Profile → Achievements | 2 taps | Reasonable |
| Home → Programs → Select → Play | 3 taps | Reasonable |

### 15.4 User Decision Points

1. **On Home:** What do I do? Play Now / Continue / Browse?
2. **At result:** Do another round or return Home?
3. **In Library:** Which challenge type do I try?
4. **In Programs:** Which curated run do I start/resume?

Homepage reduces these to a single primary decision point (Play Now or Continue) with secondary options clearly visible.

---

## 16. UX REDESIGN INPUT DOCUMENT

*Prepared for a UX designer who may create new homepage concepts.*

### 16.1 Existing Strengths (Preserve These)

- **Data-driven architecture** — the entire homepage is driven by a service snapshot. Creative designers can freely rearrange sections without touching backend logic
- **Minimal launch friction** — no account, no permissions, no multi-step onboarding
- **Clear primary action** — Play Now is visually and spatially dominant
- **Progress presentation** — stats at the top create immediate context
- **Variety engine** — recommendation algorithm naturally introduces all content types
- **Daily rotation** — featured content changes without manual curation
- **Dark premium aesthetic** — cohesive brand identity users may expect

### 16.2 Existing Constraints (Cannot Change)

- **Architecture constraint:** Homepage cannot name specific challenge type IDs or families. All content must come from the `get_home_snapshot()` dictionary
- **Navigation constraint:** Home is one of 4 bottom tabs. It must remain a tab-accessible screen
- **History constraint:** The back button and gesture-based back navigation must work correctly
- **Loading constraint:** Session preparation must show the branded loading overlay
- **Error constraint:** All buttons must handle empty/disabled states gracefully
- **Local-only constraint:** No cloud, no sync, no user accounts, no network calls
- **Theme constraint:** Must work in both dark and light modes, plus high-contrast
- **Accessibility constraint:** Must support reduced motion, font scaling (0.8x-1.4x), touch targets ≥48px

### 16.3 Existing Systems That Cannot Break

| System | What Could Break It |
|--------|---------------------|
| `RecommendationService.get_home_snapshot()` | Any change to the data contract (keys, types, nesting) |
| `NavigationService.navigate_to("home")` | Removal of "home" route from `AppRoutes.ROUTES` |
| `ChallengeSessionService.start_recommended_session()` | Changes to how it reads recommendation data |
| `PlayerProgressService.get_player_state()` | Changes to profile structure |
| Profile save/load | Any change that breaks `ProfileService.save()` |
| Achievement evaluation | Changes to `achievements.json` structure or `_criterion_value` logic |
| Program progression | Changes to `program_progress` or `active_program_id` |

### 16.4 Areas Open for Redesign

- **Layout and section order** — the scroll-based layout can be reordered, condensed, or replaced with a non-scrollable layout
- **Hero section** — can be redesigned (text, imagery, personalization)
- **Stat presentation** — can be reimagined (not just 3 cards in a row)
- **Action buttons** — can be restyled, regrouped, or replaced with visual actions
- **Featured card** — can be presented differently (larger, carousel, featured story)
- **Achievement preview** — can be more prominent or integrated differently
- **Programs card** — can be elevated or replaced with program entry points
- **Visual design** — colors, typography, spacing, card styles can evolve (within theme token system)
- **Empty/responsive states** — first-user experience, zero-progress states, all-unlocked states
- **Personalization** — different greeting, time-of-day awareness, play history recommendations

### 16.5 Opportunities for Improved Flow

1. **Reduce scroll distance:** The current layout has ~11 content blocks; some could be collapsed or made horizontal
2. **Surface program status:** A user mid-program should see that prominently, not at the bottom of a scroll
3. **Daily engagement hook:** No daily streak calendar or explicit "come back tomorrow" mechanic exists
4. **Empty state design:** A brand-new user sees the same layout as a veteran — no "welcome" CTA
5. **Achievement celebration:** Rank-up animates, but achievement unlocks happen on Result screen, not Home
6. **Faster return path:** "Continue after result" currently sends user to Home; could skip directly to Play Now
7. **Visual hierarchy of progress:** Level 1 and Level 20 show the same stat card layout; no visual differentiation

### 16.6 Potential Friction Points (From Code Analysis)

- **Over-scrolling** — the homepage is content-rich for a mobile viewport; users may miss featured content on first load
- **Undifferentiated buttons** — Continue, Library, Achievements, Profile, Settings are all styled identically (secondary)
- **No visual hierarchy for progress** — all three stats (level, progress, streak) have identical card styling despite differing importance
- **Programs discoverability** — Programs are a major feature but buried at the bottom of the page
- **Achievement preview depth** — 3 achievements at a time may not be enough to motivate, but full list requires navigating away
- **Static hero** — "READY, WITNESS?" never changes; no contextual messaging
- **No social proof** — no "you're in the top X%" or community stats
- **No notification dot/badge** — no indication of new content, updated programs, or available achievements
- **All-or-nothing disabled state** — when no recommendation exists, Play Now is completely disabled with no alternative prompt

---

*End of Homepage Experience Specification. This document reflects the implementation as of 2026-07-14.*

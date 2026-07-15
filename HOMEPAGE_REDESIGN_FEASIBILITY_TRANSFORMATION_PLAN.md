# HOMEPAGE REDESIGN FEASIBILITY & TRANSFORMATION PLAN

**Document Version:** 1.0  
**Date:** 2026-07-14  
**Role:** Senior Godot 4 Systems Architect, UX Systems Analyst, Technical Product Consultant  
**Repository:** `/home/user/2-second-witness-mobile` (branch: `arena/019f62b8-2-second-witness-mobile`)  
**Product:** Two Second Witness (ITTYBITTYBITES)  
**Engine:** Godot 4.6.3  
**Primary Platform:** Mobile (Android, package `com.ittybittybites.the2secondwitness`)  
**Viewport Design:** 720×1280 (stretch canvas_items / expand)  
**Status:** Phase 6 — Production Readiness (locally complete)  

**Purpose:** This is a factual reverse-engineering blueprint. It enables a product designer + implementation team to safely transform the homepage from a "dashboard showing everything" into a "focused daily experience" while **preserving** every validated system. No code changes are proposed here. No features are invented. All claims are verified against source.

**Core Principles Applied:**
- Code over documentation (verified every claim).
- Analysis only (no edits, no commits).
- Preserve existing architecture (reuse services, models, components; prefer flags/parallel/incremental).
- All references use exact file paths.
- Facts separated from analysis.

---

## 1. CURRENT HOMEPAGE REALITY

### Scene Architecture

**Primary container:**  
`/home/user/2-second-witness-mobile/app/src/ui/shell/AppShell.tscn` (244 lines)  
- Layered root: `BackgroundLayer` (Panel), `ContentLayer` (Control with `ContentContainer` + `TopBarContainer`), `NavigationLayer` (bottom tabs), `TopBarLayer`, `OverlayLayer` (LoadingOverlay + ErrorBanner).  
- HomeScreen is instantiated into `ContentLayer/ContentContainer` via `AppShell._load_screen`.  
- `CACHEABLE_ROUTES` includes "home". Full-rect anchors enforced. Safe-area offsets applied in `_apply_safe_area`.

**Homepage scene:**  
`/home/user/2-second-witness-mobile/app/src/ui/screens/HomeScreen.tscn` (261 lines)  
Scene tree (exact, top→bottom):

```
HomeScreen (Control, anchors_preset=15, groups=["app_screen"])
├── Background (ColorRect, full rect, mouse_filter=2)
├── MainMargin (MarginContainer, full rect, margins: left/right=20, top=12, bottom=20)
│   └── Scroll (ScrollContainer, horizontal_scroll_mode=0)
│       └── Content (VBoxContainer, separation=18)
│           ├── Hero (VBoxContainer, alignment=1, separation=4)
│           │   ├── BrandLabel (Label)
│           │   ├── EyeWrap (CenterContainer)
│           │   │   └── Eye (TextureRect, custom_min=160×64, texture=witness_eye_glow.png)
│           │   ├── GreetingLabel (Label)
│           │   ├── RankLabel (Label)
│           │   └── Tagline (Label, autowrap=3)
│           ├── StatsRow (HBoxContainer, separation=10)
│           │   ├── LevelCard (PanelContainer, size_flags=3)
│           │   │   └── Margin → VBox → Label("WITNESS LEVEL") + Value
│           │   ├── ProgressCard (PanelContainer, size_flags=3)
│           │   │   └── Margin → VBox → Label("PROGRESS") + Value
│           │   └── StreakCard (PanelContainer, size_flags=3)
│           │       └── Margin → VBox → Label("STREAK") + Value
│           ├── PlayNowButton (Button, custom_min_height=76)
│           ├── RecommendationReason (Label, autowrap=3)
│           ├── PrimaryLinks (HBoxContainer, separation=10)
│           │   ├── ContinueButton (Button, custom_min=58, size_flags=3)
│           │   └── LibraryButton (Button, custom_min=58, size_flags=3)
│           ├── FeaturedHeader (Label)
│           ├── FeaturedHost (VBoxContainer, size_flags=3)
│           ├── AchievementsHeader (Label)
│           ├── AchievementsHost (VBoxContainer, separation=8)
│           ├── AchievementsButton (Button, custom_min=52)
│           ├── QuickActionsHeader (Label)
│           ├── QuickActions (HBoxContainer, separation=10)
│           │   ├── ProfileButton (Button, custom_min=52, size_flags=3)
│           │   └── SettingsButton (Button, custom_min=52, size_flags=3)
│           ├── ProgramsCard (PanelContainer)
│           │   └── Margin → VBox → Title + Copy + ProgramsButton
│           └── BottomSpacer (Control, custom_min=24)
```

**Custom component reused:**  
`/home/user/2-second-witness-mobile/app/src/ui/components/ExperienceCard.tscn` (118 lines, min height 360)  
- Used exclusively for FeaturedHost on Home (and full list on ExperiencesScreen).  
- Internal nodes: Artwork (TextureRect), HeaderRow (Title + FavoriteButton + LockLabel), Description, RequirementLabel, MasteryRow+Bar, MetricsRow, BottomRow (Tutorial + Play buttons).

**Parent relationships (verified):**  
- HomeScreen is a direct child of ContentContainer (plain Control, not Container) → full-rect forced in AppShell.gd:227-235.  
- No direct nesting of gameplay or other screens inside Home.

### Script Architecture

**Homepage scripts:**  
`/home/user/2-second-witness-mobile/app/src/ui/screens/HomeScreen.gd` (445 lines)

Key attached script responsibilities (exact methods/signals):

- `_ready`: `_wire_buttons()`, `_apply_responsive_layout()`, `_apply_theme()`, `_refresh_data()`. Connects to `ThemeService.theme_changed`, `ProfileService.profile_saved`, `AchievementService.achievement_progress_updated`, `resized`.
- `_wire_buttons`: Connects 7+ buttons (play_now, continue, library, achievements, profile, settings, programs).
- `_apply_theme` / `_style_*`: Uses `ThemeService.tokens`, applies label styles, custom StyleBoxFlat for cards/buttons (primary vs surface, radii 16, shadows).
- `_apply_responsive_layout`: Delegates to `ResponsiveLayout.apply_centered_margin`.
- `_refresh_data`: Pulls `PlayerProgressService.get_player_state()` → `RecommendationService.get_home_snapshot(...)` → calls `_refresh_summary`, `_refresh_actions`, `_refresh_featured`, `_refresh_achievements`.
- `_refresh_summary`: Populates rank, stats, streak; triggers `_flash_rank_up` on level increase (tween + sfx).
- `_refresh_actions`: Dynamic text for PLAY NOW / CONTINUE / Programs copy.
- `_refresh_featured`: Clears FeaturedHost, instantiates `ExperienceCard`, wires signals.
- `_refresh_achievements`: Up to 3 dynamic PanelContainer previews (or "all done" label).
- Launch handlers: `_on_play_now`, `_on_continue`, `_on_featured_selected` — set loading via `AppState.set_loading`, call `ChallengeSessionService.start_*`, fallback navigate.
- Other: `_on_tutorial_requested`, `_on_favorite_toggled`, `_on_*` navigation, `_play_feedback` (haptic + audio), deferred refresh logic.

**Signals emitted/consumed:**  
- Button `pressed` → navigation / session start.  
- ExperienceCard signals: `experience_selected`, `tutorial_requested`, `favorite_toggled`.  
- Listens to service signals for live refresh.

**Dependencies (autoloads + direct):**  
`RecommendationService`, `PlayerProgressService`, `ProfileService`, `AchievementService`, `ProgramService`, `ChallengeSessionService`, `NavigationService`, `AppState`, `ThemeService`, `AudioService`, `AccessibilityService`, `ResponsiveLayout`.

**Other shell scripts impacting Home:**  
- `/home/user/2-second-witness-mobile/app/src/ui/shell/AppShell.gd` (590 lines): Route loading, chrome visibility (tabs + topbar hidden on gameplay/splash), safe area, loading/error overlays, screen cache.  
- `/home/user/2-second-witness-mobile/app/src/ui/shell/MainNavigation.gd`: 4 tabs (Home "Start", Library "Types", Profile "Stats", Settings "Tune"). Selected state: primary 22% opacity + 2px top border.  
- `/home/user/2-second-witness-mobile/app/src/ui/shell/TopBar.gd`: Dynamic title ("Two Second Witness" on home), actions, back.

### Data Architecture

**How homepage information is populated (verified flow):**

1. `HomeScreen.on_navigated_to` / `_ready` → `_refresh_data`.
2. `player_state = PlayerProgressService.get_player_state()` (wraps `ProfileService.profile` + preferences).
3. `_home_data = RecommendationService.get_home_snapshot(player_state)`.
4. Snapshot contract (exact keys from RecommendationService.gd:206-222):
   - `"play_now"`: recommendation dict (family_id, title, reason_text, ...)
   - `"continue"`: similar + program context
   - `"featured"`: daily hash-selected
   - `"available_challenge_types"`: full catalog (locked state computed from witness_level vs family metadata)
   - `"achievements_in_progress"`: top 3 from `AchievementService.get_featured_statuses(3)`
   - `"featured_program"`, `"program_count"`
   - `"witness_summary"`: level, rank, progress_points, current/best streak
   - `"has_recent"`, `"recent"`

**Services & data sources (exact paths):**

- Recommendation logic: `/home/user/2-second-witness-mobile/app/src/gameplay/runtime/RecommendationService.gd` (261 lines). Algorithms:
  - Play Now: prefer unplayed → sort by (mastery + plays*0.5 + repeat_penalty - weight*2).
  - Continue: active program first → last_played_family_id + template → fallback.
  - Featured: `abs(day_string.hash()) % unlocked.size()`.
- Progress: `/home/user/2-second-witness-mobile/app/src/gameplay/runtime/PlayerProgressService.gd` (303 lines). Ranks: Observer(1-2), Noticer(3-5), Attentive Witness(6-11), Sharp Witness(12-19), Master Witness(20+). Level = 1 + floor(total_progress/100). Streak = consecutive correct (in-session, not calendar).
- Achievements: `/home/user/2-second-witness-mobile/app/src/gameplay/progression/AchievementService.gd` + `/home/user/2-second-witness-mobile/app/src/gameplay/progression/achievements.json` (26 definitions, criteria: total_plays, family_correct, best_streak, etc.).
- Programs: `/home/user/2-second-witness-mobile/app/src/gameplay/programs/ProgramService.gd` + `/home/user/2-second-witness-mobile/app/src/gameplay/programs/programs.json` (9 programs, 5 selection policies).
- Families: `/home/user/2-second-witness-mobile/app/src/gameplay/families/manifest.json` (5 production + 1 fixture) + ChallengeFamilyRegistry.
- Profile/Save: `/home/user/2-second-witness-mobile/app/src/systems/save/ProfileService.gd` (DEFAULT_PROFILE v2) + SaveService (atomic JSON).
- Theme: `/home/user/2-second-witness-mobile/app/src/systems/theme/ThemeService.gd` (DARK/LIGHT tokens, apply_label_style).

**Save dependencies:** Home never writes directly. All mutations via ChallengeSessionService → PlayerProgressService.record_result → ProfileService.save.

**Discrepancy note:** Previous documentation (e.g. PHASE_3 spec) claims "Programs remain visible as Coming Soon" — actual code shows full ProgramsCard + navigation to "programs" route with real data from ProgramService. Source of truth = code (RecommendationService + ProgramService).

---

## 2. CURRENT USER EXPERIENCE ANALYSIS

### First Impression (on Home entry)

- **First visible (above fold on 1280px):** Hero (brand + 160×64 eye glow + "READY, WITNESS?" + dynamic Rank + tagline) + StatsRow (3 equal cards) + 76px primary Play Now button + RecommendationReason subtitle.
- **Primary action:** Play Now button (largest, purple, 2-line dynamic title).
- **What competes:** 3 stat cards, Continue/Library row immediately below, Featured section, Achievements preview, Quick actions, Programs teaser.
- Eye graphic and purple primary draw strongest visual attention (verified in styles).

### Decision Load

- Visible choices: 1 primary (Play Now) + 2 primary links (Continue/Library) + 1 featured card (with 2 actions inside) + 2 achievement previews (implicit) + 2 quick buttons + 1 programs button = **~9+ tappable areas**.
- Information density: High (stats, mastery bars, multiple texts, 3 stat cards, dynamic reasons).
- Scroll requirement: Yes (full content exceeds viewport; BottomSpacer + Featured/Achievements push content down).
- Navigation complexity: 4-tab bottom bar always present on Home. TopBar minimal on Home (title only).

### Current Homepage Identity

The homepage currently feels like a **comprehensive dashboard / product hub** (evidence):
- Multiple competing sections and secondary CTAs.
- Stats, achievements, programs, library access all co-equal on the primary screen.
- "Experience launcher" elements (Play Now + Continue + Featured card) are present but buried under discovery/monitoring UI.
- Matches "data-driven product hub" description in README and PHASE_3 spec, but implementation shows dashboard sprawl rather than singular daily focus.

---

## 3. EXISTING SYSTEMS TO PRESERVE

All systems listed below are **directly used by or critical to** the current Home implementation. Any redesign must treat them as non-negotiable unless a full migration plan is documented.

**System Name:** RecommendationService  
**Purpose:** Computes play_now / continue / featured / full catalog snapshot without naming concrete families.  
**File Location:** `app/src/gameplay/runtime/RecommendationService.gd`  
**How Homepage Uses It:** `get_home_snapshot(player_state)` populates every dynamic element.  
**Risk If Changed:** High — breaks Play Now, Continue, Featured, Library, session launch. Preserve interface exactly.

**System Name:** PlayerProgressService  
**Purpose:** Witness level/rank, streaks, family progress, history. Adapter over ProfileService.  
**File Location:** `app/src/gameplay/runtime/PlayerProgressService.gd`  
**How Homepage Uses It:** `get_player_state()`, summary values, recent history indirectly.  
**Risk If Changed:** High — core progression model.

**System Name:** ProfileService + SaveService  
**Purpose:** Atomic JSON persistence (v2 profile), DEFAULT_PROFILE.  
**File Location:** `app/src/systems/save/ProfileService.gd`, `SaveService.gd`  
**How Homepage Uses It:** Indirect via PlayerProgressService; triggers refresh on profile_saved.  
**Risk If Changed:** Critical — all progress lost.

**System Name:** AchievementService  
**Purpose:** 26 criteria-based achievements from JSON.  
**File Location:** `app/src/gameplay/progression/AchievementService.gd` + `achievements.json`  
**How Homepage Uses It:** `get_featured_statuses(3)`, progress signals, in-progress previews.  
**Risk If Changed:** Medium-High — featured progress UI + unlocks.

**System Name:** ProgramService  
**Purpose:** 9 curated programs (daily_rotation, focus_tags, etc.).  
**File Location:** `app/src/gameplay/programs/ProgramService.gd` + `programs.json`  
**How Homepage Uses It:** `get_featured_program`, program_count, continue routing, ProgramsCard copy.  
**Risk If Changed:** Medium — Programs tab + continue logic depend on it.

**System Name:** ChallengeSessionService + ChallengeFamilyRegistry  
**Purpose:** Session start (recommended/continue/template), family loading from manifest.  
**File Location:** `app/src/gameplay/runtime/ChallengeSessionService.gd`, `ChallengeFamilyRegistry.gd`, `families/manifest.json`  
**How Homepage Uses It:** All launch paths (`start_recommended_session("play_now")`, etc.). Featured uses registry for card data.  
**Risk If Changed:** Critical.

**System Name:** ThemeService  
**Purpose:** DARK/LIGHT tokens, typography, apply_* helpers, accessibility overrides.  
**File Location:** `app/src/systems/theme/ThemeService.gd`  
**How Homepage Uses It:** Every `_apply_theme`, card/button styles, label colors.  
**Risk If Changed:** High — visual consistency across app.

**System Name:** NavigationService + AppRoutes + AppShell  
**Purpose:** Route management, tab chrome, splash flow, screen cache.  
**File Location:** `app/src/core/navigation/*`, `app/src/ui/shell/AppShell.gd`  
**How Homepage Uses It:** `navigate_to`, `on_navigated_to`, tab visibility. Home is a tab route.  
**Risk If Changed:** High — first-run, chrome, history all affected.

**System Name:** ResponsiveLayout + AccessibilityService + AudioService  
**Purpose:** Safe area/gutter, touch targets, reduced motion, haptics, SFX/BGM.  
**File Location:** `app/src/ui/layout/ResponsiveLayout.gd`, `app/src/systems/accessibility/AccessibilityService.gd`, `app/src/systems/audio/AudioService.gd`  
**How Homepage Uses It:** Margins, `_play_feedback`, animation guards.  
**Risk If Changed:** Medium.

**System Name:** AnalyticsService + ErrorHandler + AppState  
**Purpose:** Telemetry, error banners, phase/loading state.  
**File Location:** `app/src/systems/analytics/AnalyticsService.gd`, `app/src/core/app/*`  
**How Homepage Uses It:** Screen presented logs, loading states, error fallbacks.  
**Risk If Changed:** Low-Medium.

**Additional:** ContentService, ExperienceRegistry (indirect), SettingsService (font scale, etc.).

**Preservation mandate:** Prefer visibility toggles, feature flags, parallel components (e.g. new "HomeV2" scene that reuses ExperienceCard + services), incremental migration. Never destructive replacement without verified fallback.

---

## 4. HOMEPAGE COMPONENT INVENTORY

**Element Name:** Hero / BrandLabel + Eye + GreetingLabel + RankLabel + Tagline  
**Location:** `HomeScreen.tscn: Hero` (HomeScreen.gd lines 37-40, 99-105)  
**Purpose:** Brand identity + personalized rank greeting.  
**Current Behavior:** Static text + dynamic rank from summary. Eye glow texture.  
**Data Source:** `witness_summary.rank`  
**Interaction:** None (visual).  
**Destination:** N/A  
**Dependencies:** ThemeService (display/title styles), witness_eye_glow.png

**Element Name:** StatsRow (LevelCard, ProgressCard, StreakCard)  
**Location:** `HomeScreen.tscn: StatsRow` (HomeScreen.gd 106-120)  
**Purpose:** At-a-glance progress.  
**Current Behavior:** 3 equal-width PanelContainers, styled cards.  
**Data Source:** `witness_summary` (level, progress_points, current_streak + best).  
**Interaction:** Visual only.  
**Destination:** N/A  
**Dependencies:** `_style_stat_card`, ThemeService tokens.

**Element Name:** PlayNowButton  
**Location:** `HomeScreen.tscn` + gd:121-124, 148-153  
**Purpose:** Primary daily action.  
**Current Behavior:** 76px, primary purple, dynamic 2-line text "PLAY NOW\n[title]". Disabled if empty rec.  
**Data Source:** `play_now.title`, `play_now.reason_text`  
**Interaction:** `_on_play_now` → loading + ChallengeSessionService.start_recommended_session("play_now").  
**Destination:** Gameplay (observation/memory_question).  
**Dependencies:** RecommendationService, AppState loading.

**Element Name:** RecommendationReason  
**Location:** HomeScreen.gd:125, 154  
**Purpose:** Context for Play Now.  
**Current Behavior:** Subtitle label.  
**Data Source:** `play_now.reason_text` (or default).  
**Interaction:** None.

**Element Name:** ContinueButton + LibraryButton (PrimaryLinks)  
**Location:** `HomeScreen.tscn: PrimaryLinks` (gd:155-162, 194-201)  
**Purpose:** Secondary quick actions.  
**Current Behavior:** Continue shows program/recent title or fallback. Disabled if no rec.  
**Data Source:** `continue`, `has_recent`, `featured_program`.  
**Interaction:** `_on_continue` / `_on_library` → session or navigate("experiences").  
**Destination:** Continue → gameplay or experiences.

**Element Name:** FeaturedHeader + FeaturedHost  
**Location:** `HomeScreen.tscn` (gd:163-178, 180-192)  
**Purpose:** Daily spotlight.  
**Current Behavior:** Dynamic ExperienceCard or empty label.  
**Data Source:** `featured` + `available_challenge_types` (matched by family_id).  
**Interaction:** Card signals → `_on_featured_selected` (start_template_session).  
**Destination:** Gameplay.  
**Dependencies:** ExperienceCard.tscn + .gd (full data contract).

**Element Name:** AchievementsHeader + AchievementsHost + AchievementsButton  
**Location:** `HomeScreen.tscn` (gd:179, 203-215, 217)  
**Purpose:** Progress teaser.  
**Current Behavior:** Up to 3 custom Panel previews (title + count + ProgressBar) or "all done". Button always visible.  
**Data Source:** `achievements_in_progress` from AchievementService.  
**Interaction:** Button → navigate("achievements").  
**Destination:** Achievements screen.

**Element Name:** QuickActions (ProfileButton + SettingsButton)  
**Location:** `HomeScreen.tscn` (gd:218-224)  
**Purpose:** Direct access.  
**Current Behavior:** Two equal buttons.  
**Interaction:** Navigate profile/settings.

**Element Name:** ProgramsCard (Title + Copy + ProgramsButton)  
**Location:** `HomeScreen.tscn: ProgramsCard` (gd:225-236)  
**Purpose:** Teaser for curated runs.  
**Current Behavior:** Dynamic copy from featured_program or fallback.  
**Data Source:** `featured_program`, `program_count`.  
**Interaction:** Button → navigate("programs").  
**Destination:** Programs screen.

**Element Name:** BottomSpacer + Scroll structure  
**Location:** HomeScreen.tscn  
**Purpose:** Breathing room + scroll safety.  
**Dependencies:** MainMargin + ResponsiveLayout.

**Additional reused:** All ExperienceCard internals (see component file). TopBar / MainNavigation chrome (not part of Home content).

---

## 5. REDESIGN OPPORTUNITY ANALYSIS

| Current Element | Current Purpose | Current Problem | Redesign Opportunity | Technical Difficulty | Risk Level | Recommended Approach |
|-----------------|-----------------|-----------------|----------------------|----------------------|------------|----------------------|
| Hero + StatsRow | Identity + quick progress | Competes with primary action; high density | Consolidate into compact Identity header (rank + level inline) | Low | Low | Reuse existing summary data + ThemeService styles; visibility flag for old stats |
| PlayNowButton | Primary action | Dynamic text good, but buried; no visual "daily focus" emphasis | Promote to singular Daily Experience card (larger, prominent) | Low | Low | Extend ExperienceCard or new parallel DailyCard that reuses RecommendationService |
| Continue + Library | Quick secondary | Two equal CTAs dilute focus | Merge Continue into Daily card secondary action; move Library to tab only | Low | Low | Keep Continue logic; de-emphasize Library button on Home |
| FeaturedHost (ExperienceCard) | Daily spotlight | Good data-driven card, but appears after multiple sections | Promote Featured (or Play Now) as the "Daily Experience Layer" | Medium | Medium | Reuse ExperienceCard exactly; new host layout only |
| Achievements in progress | Teaser motivation | 3 custom inline cards duplicate Profile/Achievements | Collapse to single progress indicator or move entirely to Profile | Low | Low | Use visibility toggle or keep as optional "Progress Layer" teaser (max 1) |
| ProgramsCard | Discovery teaser | Adds another decision point | Move to Discovery Layer (optional, below fold) or keep minimal | Low | Low | Reuse ProgramService data; simple card or link |
| QuickActions (Profile/Settings) | Direct nav | Redundant with bottom tabs | Remove from Home content (tabs suffice) | Low | Low | Delete section; tabs remain unchanged |
| RecommendationReason + multiple texts | Context | Adds cognitive load | Integrate reason into primary card subtitle | Low | Low | Data mapping unchanged |
| Overall scroll + 9+ actions | Dashboard feel | Decision fatigue on open | Focused "one primary action + supporting identity/progress" | Medium (layout) | Low | Phase visual hierarchy first; parallel V2 scene |

**Evidence basis:** All from HomeScreen.tscn + .gd + RecommendationService + AppShell chrome logic.

---

## 6. PROPOSED HOMEPAGE V2 ARCHITECTURE

**Goal:** Transform from "Dashboard showing everything" → "Focused daily experience".

### Identity Layer (top, compact)
**Purpose:** Instant "who I am / where I stand".  
**Possible contents (reuse existing):**
- Compact greeting + rank (from witness_summary).
- Small level/progress indicator.
- Eye brand mark (scaled).
**What stays:** All data sources.
**What moves:** Full StatsRow → optional collapsed or Profile.

### Daily Experience Layer (primary, above fold)
**Purpose:** The single most important action.  
**Possible contents:**
- Large "Daily Witness" / Play Now card (reuse or extend ExperienceCard).
- Prominent title + reason + mastery preview.
- Continue affordance (if active program/recent).
- Clear "Start" CTA.
**Data:** Directly from `play_now` + `continue` + RecommendationService.

### Progress Layer (supporting, minimal)
**Purpose:** Show growth without competing.  
**Possible contents:**
- Current streak (big number).
- Achievement teaser (1 line or mini bar).
- Level progress bar.
**Reuse:** Existing summary + AchievementService featured (limit 1).

### Discovery Layer (below fold, optional)
**Purpose:** Exploration without pressure.  
**Possible contents:**
- Today's Featured (or collapsed).
- Programs teaser (link to tab).
- "Browse all types" → Library tab.
**What is removed from Home:** Direct Library/Quick buttons, multiple achievement cards, full Programs card.

### Navigation Layer
**Purpose:** Move between major areas.  
**Plan:**
- **Stays unchanged:** 4-tab bottom nav (MainNavigation.gd), TopBar behavior.
- **What moves off Home:** Profile/Settings quick actions (redundant), Library button (now tab-only).
- **What is removed from Home:** Secondary discovery CTAs that duplicate tabs.
- New V2 screen can live parallel: e.g. register "home_v2" route with feature flag in AppRoutes / AppShell.

**Migration:** Introduce via flag in Settings or AppState. Old HomeScreen remains until validated. All services untouched.

---

## 7. DATA MAPPING

**UI Element (V2 proposal):** Daily Witness Card  
**Displayed Information:** Recommended title, reason, mastery, rounds/accuracy (from card data)  
**Existing Data Source:** RecommendationService.get_home_snapshot().play_now + matched available item  
**Service/Class:** RecommendationService  
**File Path:** `app/src/gameplay/runtime/RecommendationService.gd`  
**Data Object:** play_now dict + full item from available_challenge_types  
**Dictionary Key:** "title", "reason_text", "family_id"; progress sub-dict  
**Refresh Method:** `_refresh_data` → `get_home_snapshot` (called on navigate/profile/achievement signals)  
**Signal/Event:** recommendation_created (service), profile_saved / achievement_progress_updated  
**Navigation Destination:** ChallengeSessionService.start_recommended_session("play_now")

**UI Element:** Identity / Rank + Level  
**Displayed:** Rank name, level #, progress points  
**Existing:** witness_summary  
**Service:** PlayerProgressService (via Recommendation)  
**File:** `app/src/gameplay/runtime/PlayerProgressService.gd` (get_player_state + summary)  
**Keys:** "rank", "level", "progress_points", "current_streak"  
**Refresh:** Same as above

**UI Element:** Continue affordance  
**Displayed:** Program title or "Continue recent"  
**Source:** `continue` + `has_recent` + ProgramService  
**File:** RecommendationService.recommend_continue + ProgramService  
**Keys:** "program_title", "title", "program_id"

**UI Element:** Streak / Achievement teaser  
**Source:** witness_summary + AchievementService.get_featured_statuses(1)  
**File:** PlayerProgressService + AchievementService

**UI Element:** Featured (if kept separate)  
**Source:** `featured` + available match  
**Exact same contract as current FeaturedHost / ExperienceCard.set_experience**

**All other V2 elements map 1:1 to existing keys in get_home_snapshot contract.** No new data models required.

---

## 8. DESIGN SYSTEM COMPATIBILITY AUDIT

**Existing infrastructure (verified):**

- **ThemeService** (`app/src/systems/theme/ThemeService.gd`): Full DARK_TOKENS / LIGHT_TOKENS. Colors (primary #6A3DFF, surface #1E1E26, etc.), spacing (xs4-sm8-md16-lg24-xl32), radii (sm8-md12-lg20), touch 48, typography table (display34/700 ... caption14/500). Helpers: apply_label_style, apply_typography, get_font_size (with scale).
- **ResponsiveLayout** (`app/src/ui/layout/ResponsiveLayout.gd`): apply_centered_margin, horizontal_gutter (CENTERING_BREAKPOINT 1280, MAX 720), scale_safe_area_insets, enforce_touch_targets (MIN 48).
- **Shared components:** ExperienceCard (full theming + data contract), PanelContainer cards with StyleBoxFlat (shadows, radii 16, borders).
- **Buttons:** Primary (purple) vs surface styles duplicated in HomeScreen + ExperienceCard (inconsistent duplication — opportunity to centralize).
- **Animations:** Limited (rank flash tween in Home, loading pulse, screen fade). Guarded by AccessibilityService.should_animate / reduced_motion.
- **Accessibility:** Font scale, reduced motion, haptics, high contrast (tokens overridden).

**V2 Recommendation:**
- **Extend existing systems** (preferred): Add any new tokens to ThemeService (e.g. "daily_card_height"). Reuse ExperienceCard for Daily/Featured (or create thin wrapper).
- **Do not create one-off UI:** Centralize card/button styles into ThemeService helpers or new shared "HomeCard" component if needed.
- **Parallel components OK:** New DailyExperienceCard.tscn that loads ExperienceCard internally or inherits styling.
- **Avoid:** Hard-coded colors, new typography, custom layout math outside ResponsiveLayout.

Current duplication (HomeScreen.gd _style_button vs ExperienceCard._style_button) is a minor smell but low risk.

---

## 9. MOBILE AND ANDROID AUDIT

**Display (verified in project.godot + AppShell + ResponsiveLayout):**
- Viewport: window/size/viewport_width=720, height=1280.
- Stretch: canvas_items / expand.
- Safe areas: Enforced in AppShell._apply_safe_area (Android/iOS top ≥44, bottom ≥24; desktop fallback 12). Insets stored in ThemeService.tokens. ContentContainer offsets adjusted for visible chrome + nav bar.
- Responsive: Phones get full-bleed + gutter 20. Centering only >1280px (rare on mobile).

**Rendering:**
- `renderer/rendering_method = "gl_compatibility"` (desktop + mobile).
- Android: `rendering_device/driver.android = "vulkan"`.
- Textures: etc2_astc.
- Default clear: dark blue-ish.
- Boot splash configured.
- No evidence of black-screen risks in code; eye texture used for loading/brand.

**Interaction:**
- Touch targets: Explicitly enforced (ResponsiveLayout.enforce_touch_targets, ThemeService.touch_target_min=48, custom_min sizes 48-76 everywhere).
- Gestures: Tap primary (input map). No complex gestures in Home.
- Mobile usability: ScrollContainer on Home protects portrait. Large buttons. Haptics on actions (AccessibilityService). Feedback on every tap.
- No assumptions: All verified in AppShell, HomeScreen, ExperienceCard, ResponsiveLayout.

**Risks for redesign:** Any new full-screen elements must respect safe area + chrome offsets. Keep portrait-first.

---

## 10. V1 VS V2 VALIDATION

| Metric | Current V1 | Proposed V2 | Expected Change |
|--------|------------|-------------|-----------------|
| Primary user goal on open | Start a challenge (buried among 8+ elements) | Start today's recommended experience (singular prominent) | Clarity ↑ |
| Number of decisions above fold | 5-7 (Play, Continue, Library, Featured card actions, stats glance) | 1-2 (Primary card + optional continue) | Decision load ↓ |
| Taps required to start activity | 1 (Play Now) but after scanning | 1 (same) | Same or better |
| Above-the-fold priority | Mixed (hero + stats + 3 actions + featured) | Identity + Daily Experience dominant | Focus ↑ |
| Scroll requirement | Yes (achievements, programs, spacer) | Minimal or none for core action | Reduced |
| User understanding after opening app | "I see my level, streaks, achievements, programs, and options" | "Here's who I am and my one recommended action today" | Simpler mental model |
| Return motivation | Stats + multiple teasers | Streak + mastery in daily context + clear progress | Habit-forming ↑ (via existing streak/program data) |

All changes achievable by layout + visibility without touching services.

---

## 11. IMPLEMENTATION RISK ANALYSIS

**Low Risk**
- Layout changes, spacing, typography tweaks, reordering sections inside HomeScreen (or new scene).
- Styling updates via ThemeService tokens.
- Component rearrangement (e.g. collapse StatsRow).
- Adding visibility flags / feature flags in AppState or a new HomeController.
- Reusing ExperienceCard with different host container.

**Medium Risk**
- New card variants (DailyExperienceCard) that wrap ExperienceCard — requires careful signal forwarding.
- New interaction patterns inside primary card (e.g. swipe to continue) — must not break existing card contract.
- Animations on Home (rank flash already exists; add carefully behind AccessibilityService).
- Slight data enrichment in RecommendationService snapshot (additive only).

**High Risk (avoid or require explicit migration)**
- Navigation changes (adding/removing tab routes, altering AppShell chrome logic for Home).
- Save data / ProfileService / PlayerProgressService schema changes.
- Service interface changes to RecommendationService, ChallengeSessionService, etc.
- Architecture replacement (deleting HomeScreen.gd without parallel path).
- Removing any currently used data keys from get_home_snapshot without updating all callers.

**Migration strategy for any high-risk item:** Parallel implementation + feature flag + regression test matrix (existing tests/runtime/ already cover home snapshot).

---

## 12. IMPLEMENTATION ROADMAP

### Phase 1: Visual Hierarchy (Safest first step)
**Goal:** Create action-first homepage using existing data.  
**Expected changes:**
- Reorder/reduce sections in HomeScreen (or create parallel HomeV2.tscn that reuses same script patterns).
- Promote PlayNow + Featured into single prominent Daily card.
- Collapse or hide StatsRow + Achievements multi + Programs full card (use simple teaser or remove).
- Remove QuickActions row (tabs cover).
- Update styles only via existing ThemeService + ResponsiveLayout.
**Files affected (examples):** HomeScreen.tscn/.gd (or new parallel), minor AppShell if route flag added.  
**Risk:** Low.  
**Validation:** Existing test_phase3_home_experience.gd + manual.

### Phase 2: Experience Layer
**Goal:** Improve identity and daily engagement.  
**Expected changes:**
- New or extended DailyExperienceCard (reuses ExperienceCard data contract + set_experience).
- Integrate recommendation reason + mastery into primary card.
- Compact Identity header (reuse summary).
- Progress Layer: single streak + 1 achievement teaser.
- Keep all service calls identical.
**Files affected:** New component (parallel to ExperienceCard), updates to Home layout.  
**Risk:** Low-Medium.

### Phase 3: Personalization
**Goal:** Use existing data to make Home adaptive.  
**Expected changes:**
- Conditional sections based on player_state (e.g. show Continue only if has_recent).
- Dynamic copy using existing reason_text + program data.
- Feature flag for V2 vs V1 rendering.
- No new data collection.
**Files affected:** HomeScreen logic (or controller), AppState for flag.  
**Risk:** Low (purely presentation).

### Phase 4: Optimization
**Goal:** Polish, test, validate.  
**Expected changes:**
- Performance (caching, reduced child churn in hosts).
- Accessibility audit (enforce_touch_targets on new elements).
- Android device testing (safe areas, rendering).
- Analytics validation (new screen events if any).
- Full regression using existing suite.
**Files affected:** Minor + test updates.  
**Risk:** Low.

**Overall:** Start with Phase 1 using a parallel scene + flag in NavigationService/AppRoutes. Old implementation remains live until Phase 4 sign-off. No destructive edits.

---

## 13. FINAL RECOMMENDATION

### Recommended Homepage Direction
Home should become the **singular focused entry point for the daily habit**: "Who I am + the one recommended action right now + lightweight progress signal."

- **What should remain (100%):** All services (RecommendationService, PlayerProgressService, etc.), data contracts, ExperienceCard, ThemeService, Navigation tabs, safe-area/responsive logic, save model, analytics, accessibility, audio. Challenge launch paths unchanged.
- **What can be removed from Home content:** Multiple stat cards, full achievement previews, quick nav buttons (Profile/Settings), verbose Programs teaser, Library button (move to tab).
- **Biggest UX opportunities:** Reduce decision load on first open; make "Play Now" the unmistakable hero; leverage existing streak/program data for habit cues without dashboard sprawl.
- **Biggest technical risks:** Any accidental change to RecommendationService snapshot contract or ChallengeSessionService launch methods. Chrome/navigation side-effects in AppShell.

### Migration Strategy (safest path V1 → V2)
1. Introduce feature flag (e.g. `home_v2_enabled` in SettingsService or AppState).
2. Create parallel `HomeV2Screen.tscn` + minimal script that reuses identical refresh patterns + ExperienceCard.
3. Update AppShell / AppRoutes to select screen based on flag (CACHEABLE_ROUTES handling preserved).
4. Phase 1-2 visual + hierarchy changes in V2 only.
5. Full regression (existing tests + new V2 smoke).
6. Gradual rollout (internal → beta → full) with old Home as fallback.
7. Once validated, deprecate V1 (or keep for A/B).

This plan preserves 100% of working systems. Another agent can implement safely by following the exact file references, data mappings, and phased roadmap above.

**End of document.** All analysis derived exclusively from source inspection of listed files. No assumptions beyond verified code. Ready for handoff.
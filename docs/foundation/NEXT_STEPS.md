# Recommended Next Steps - After Foundation Phase

**Foundation Status:** COMPLETE (App Shell + Core Systems + 4 Screens + Experience Registry + Flashword Placeholder)

---

## Immediate Phase 2 Priorities (Full Game Experience)

### 1. Flashword - Complete Gameplay Loop (1-2 weeks)
- **Objective:** Implement definitive 2-second observation mechanic
- **Tasks:**
  - Create `FlashwordGameScreen.tscn/.gd` (separate from ExperiencesScreen, navigated via `experience_play` route)
  - States: `OBSERVATION (2000ms word display) -> RECALL (5000ms countdown + choices) -> RESULT (correct/incorrect + score + speed bonus)`
  - UI: large centered word, timer bar, 2x2 choice grid, haptics on correct/incorrect
  - Animation: word fade in/out, choice bounce, result confetti placeholder
  - Audio: generate placeholder tone using AudioStreamGenerator or add `ui_click`, `success`, `fail` wav assets to `assets/audio/`
  - Scoring: base 10 + speed bonus (max 10) + streak bonus (streak *2) as per manifest
  - Integration: AppState active_experience_id, ProfileService.record_experience_play
  - Testing: manual + headless benchmark `verify_flashword_lifecycle.gd`

### 2. Experience Pipeline - 2 More Experiences (2-3 weeks)
- **Goal:** Prove modular expansion works (no core rewrite)
- **Ideas (aligned with premise - observation, memory, reaction, quick decision):**
  - **FlashShape:** 2-sec shape/color/position glimpse, then pick correct from 4 variants. Tests visual memory.
  - **SnapReact:** Dot appears random after 1-3 sec delay, tap as fast as possible. Tests reaction.
  - **QuickPick:** 2-sec display of rule (e.g., "Pick the red circle"), then 6 objects, pick correct under time. Tests observation + decision.
- **Implementation Steps per Experience (copy _template):**
  1. Copy `src/experiences/_template/` to `src/experiences/flashshape/`
  2. Update `manifest.json` id, title, category, preview_color, rules, estimated_duration
  3. Implement `FlashshapeExperience.gd` extending ExperienceBase, implement `start()` returning session with shapes, `submit_answer()` scoring
  4. Create `FlashshapeGameScreen.tscn/.gd` if custom UI needed, or reuse generic `ExperiencePlayScreen`
  5. Add id to `src/experiences/manifest.json` experiences list
  6. Registry auto-discovers on boot

### 3. Generic Experience Player Screen (Reuse for all)
- **Create:** `src/ui/screens/ExperiencePlayScreen.tscn/.gd`
- **Route:** `experience_play` (non-tab, shows back button in TopBar)
- **Props:** receives `exp_id`, `difficulty` via NavigationService params
- **Logic:**
  - Load manifest via ExperienceRegistry, instantiate Experience class via `load("res://src/experiences/{id}/{Cap}Experience.gd").new(id, manifest)`
  - Call `experience.start({difficulty})` get session
  - Render generic observation UI or delegate to experience-specific scene if exists
  - On completion, `ProfileService.record_experience_play`, show result, offer Replay / Home / Next
  - Handle abort/back via dialog confirm (SettingsService.confirm_exit)
- **Benefit:** New experiences without new screens if they use generic player

### 4. Onboarding & First-Time User Experience (1 week)
- **Create:** `src/ui/screens/OnboardingScreen.tscn/.gd` (not tab, shown if ProfileService preferences onboarding_completed false)
- **Flow:** 3 slides: Welcome "You are the witness" → How to play (2-second glance) → Ready (Quick Play)
- **Persistence:** ProfileService set preferences.onboarding_completed true, SettingsService first_launch_completed true
- **AppBoot:** after finalize, check if onboarding needed -> navigate to onboarding instead of home

### 5. Polish & Juice (1 week)
- **Animations:** Use AccessibilityService.get_animation_duration() for all tweens, respect reduced_motion
- **Micro-interactions:** button scale 0.95 on press, haptics 20-50ms, card entry fade+slide
- **Theme:** add Easter egg or brand color pulse on splash icon
- **Audio:** create Procedural UI sounds (sine waves) if wav missing to avoid silent foundation

---

## Mid-Term (Phase 3) - Growth & Monetization Readiness

### 6. Content System OTA Revival
- **Goal:** Bring back live_content but clean (not old GitHubSyncManager)
- **Design:**
  - New `GitHubContentService.gd` (optional system) checks `https://raw.githubusercontent.com/ITTYBITTYBITES/2-second-witness-mobile/main/live_content/manifest.json` for version
  - If newer, download JSONs to `user://content/` (overrides res://)
  - ContentService already prefers user:// over res://, so OTA works without core change
  - Add feature flag `content.auto_update` via ConfigService
- **Security:** Validate JSON schema, size limit, signature if needed

### 7. Analytics Remote Endpoint
- **Current:** buffer local JSONL
- **Next:** add `AnalyticsRemoteUploader.gd` that batches 10 events, POST to `https://api.ittybittybites.com/telemetry/ingest` if SettingsService analytics_enabled and internet available
- **Offline:** keep buffer if fail, retry with exponential backoff
- **Privacy:** no PII, session_id anonymous, respect opt-out

### 8. Monetization (Ads + IAP) - Adapter Pattern
- **AdManager (future):** wrapper around AdMob plugin (old AdMob plugin list but not implemented in foundation)
  - Keep interface: `show_interstitial()`, `show_rewarded()`, `load_banner()`
  - Simulation mode if plugin missing (log only)
  - Feature flag `feature_flags.ads_enabled`
- **StoreManager (future):** wrapper around GodotGooglePlayBilling plugin already preserved
  - Adapter: `purchase_product(id)`, `restore_purchases()`, `is_purchased(id)`
  - StoreTransactionState persistence to `user://store.json`
  - Feature flag `iap_enabled`
- **Note:** Preserve signing compatibility, test billing on real device with license tester account

### 9. Progression & Mastery
- **Leveling:** ProfileService already has level/xp, xp_to_next *1.25. Add reward: unlock experience at level thresholds.
- **Mastery:** per-experience mastery 0-1 based on best_score / max_possible, add to ExperienceProgress UI as progress bar
- **Achievements:** simple list strings, e.g., "first_observation", "streak_5", check after each play, emit unlock event
- **Daily Challenge:** `DailyChallengeService.gd` picks random exp + difficulty + special rule, resets daily 00:00 UTC, reward XP bonus

### 10. Testing Pipeline
- **Create:** `app/benchmark/` new clean
  - `verify_boot.gd` (headless SceneTree, instantiate AppBoot, check steps 8)
  - `verify_navigation.gd` (navigate all routes, check history, back)
  - `verify_profile_persistence.gd` (create profile, add xp, save, load, check level)
  - `verify_experience_registry.gd` (count >=1, flashword registered)
  - `verify_theme.gd` (toggle dark/light, check tokens)
- **Run:** `godot --headless -s benchmark/verify_boot.gd` etc
- **CI:** GitHub Actions workflow `.github/workflows/foundation_ci.yml` run these + json lint + gdscript lint (gdformat)

---

## Long-Term (Phase 4) - Platform Expansion

### 11. Web Demo Export
- Old export had WEB_DEMO preset with Adsterra banner. New foundation can add Web preset back after gameplay done
- Need to ensure Touch emulation, localStorage for SaveService (already user:// maps to IndexedDB on web)

### 12. Accessibility Audit
- Screen reader: add `accessibility_label` meta to buttons, log via AccessibilityService if screen_reader_hints true
- Color contrast: check DARK/LIGHT tokens against WCAG AA (primary vs background)
- Font scaling: test 0.8-1.5, ensure no clipping in cards
- Reduced motion: audit all tweens use AccessibilityService.get_animation_duration

### 13. Localization
- Add `assets/i18n/en.json`, `es.json` etc, `LocalizationService.gd` that loads via ContentService
- Replace hardcoded strings in screens with `tr("HOME_TITLE")`

### 14. Release Checklist (Pre-Play Store Update)
- [ ] Place actual `release.keystore` at `app/release.keystore`, set user/pass in export_presets or env
- [ ] Increment version_code > old Play release (current old code = 1, foundation sets 100, so OK)
- [ ] Test upgrade install: install old APK (if available via Play internal), then install new AAB update, check profile migration (save v1->v2 handled)
- [ ] Test on 5+ real Android devices: API 24-34, different DPIs, cutouts
- [ ] Performance: cold start <2s, memory <150MB, no ANR
- [ ] Privacy policy link in Settings About
- [ ] Crash reporting opt-in respects SettingsService
- [ ] Analytics opt-out respects
- [ ] Final human art pass: replace placeholder icon text (⌂◫◉⚙) with proper icon font or textures (keep brand consistent)
- [ ] Promo assets: `promo_header_1920.png` already preserved, consider updating to reflect new UI

---

## Technical Debt to Watch

- **Duplicated ConfigService autoload** `AppConfig` and `ConfigService` both same script (intentional for backward naming but should consolidate to one in Phase 2)
- **TopBar and MainNavigation built both via TSCN + programmatic fallback** - could unify to single programmatic to avoid duplication, but kept for editor preview
- **AudioService placeholder missing wav** - currently silent, should add procedural generation or 3 tiny ogg files (ui_click, success, fail) <50KB each
- **No custom font** - using default, add `assets/fonts/` Inter or similar for brand
- **ProfileService ID generation** uses randi() not secure - OK for anonymous but could use UUID v4

---

## How to Continue Development

### For Human Dev in Godot Editor

1. Open Godot 4.6.3
2. Import `app/project.godot`
3. You should see AppShell scene with 4 layers; run (F5) -> Splash -> Home
4. Edit any system in `src/systems/`, hit Save, Godot hot-reloads if playing
5. To add experience: copy `_template` folder, follow README inside
6. To tweak theme: edit `ThemeService.gd` DARK_TOKENS/LIGHT_TOKENS dict, colors live update via signal

### For Agent/CI

- All source in `app/src/` is independent of binary assets
- Can lint via `python3 tools/gdscript_lint.py app/src/` (tool to be created Phase 3)
- Can run headless tests via `godot --headless -s benchmark/verify_*.gd` when Godot installed

---

## Deliverables for Next PR

- [ ] FlashwordGameScreen full loop
- [ ] 2 new experiences (FlashShape, SnapReact)
- [ ] Generic ExperiencePlayScreen
- [ ] Onboarding flow
- [ ] Audio assets (3 wav)
- [ ] Benchmark tests (4 scripts)
- [ ] Updated README.md with new screenshots
- [ ] Version bump to 2.1.0-experiences

---

## Contact & Ownership

- Repo: ITTYBITTYBITES/2-second-witness-mobile
- Package: com.ittybittybites.the2secondwitness
- Foundation Author: Agent rebuild 2026-07-09
- Old archive: `_legacy_archive/app_old/` preserved for reference but not used

**Goal:** Keep foundation clean, never reintroduce Worlds/Universes, always add via independent modules.


# Two Second Witness - Foundation Architecture Summary
## Rebuild 2.0 - Clean, Modern Entertainment Application

**Date:** 2026-07-09
**Engine:** Godot 4.6 (GL Compatibility for Android)
**Package ID:** `com.ittybittybites.the2secondwitness` (preserved for Play Store continuity)
**Version:** 2.0.0-foundation
**Mission:** Definitive rebuild from scratch - brand retained, premise retained, all old architecture (Worlds, Universes, old progression, old navigation) removed.

---

### 1. Design Principles

| Principle | Implementation |
|-----------|----------------|
| **Clean Separation** | 8 independent systems (Theme, Audio, Save, Settings, Analytics, Accessibility, Content, Config) communicate only via EventBus + signals, zero direct dependencies |
| **Maintainability** | Each system <250 LOC, single responsibility, SOLID, typed GDScript |
| **Future Expansion** | Experiences as independent modules under `src/experiences/` - auto-discovered via ExperienceRegistry without core rewrite |
| **Performance** | GL Compatibility renderer, no 3D tunnel, no shader ubershaders, minimal overdraw, object pooling for SFX, JSONL buffered analytics |
| **Mobile-First** | 1080x1920 viewport, bottom nav, 60dp touch targets, haptics abstraction, immersive mode |

### 2. High-Level Layers

```
+------------------- AppShell (Root Control) -------------------+
|  BackgroundLayer (themed color)                               |
|  ContentLayer -> ContentContainer (screen cache)              |
|       ├─ SplashScreen (boot progress)                        |
|       ├─ HomeScreen (hero + stats + featured)                |
|       ├─ ExperiencesScreen (filterable grid)                 |
|       ├─ ProfileScreen (level/xp/stats/progress)             |
|       └─ SettingsScreen (toggles/sliders)                   |
|  TopBarLayer (dynamic title, back, actions)                 |
|  NavigationLayer -> MainNavigation (4-tab bottom nav)       |
|  OverlayLayer -> LoadingOverlay + ErrorBanner                |
+--------------------------------------------------------------+
        ▲              ▲              ▲
        |              |              |
   AppState       NavigationService  EventBus
        ▲              ▲              ▲
+--------------------------------------------------------------+
| Core Systems (Autoload Singletons)                           |
|  EventBus, AppState, ErrorHandler, AppConfig, AppBoot        |
|  ThemeService, AudioService, SaveService, ProfileService     |
|  SettingsService, AnalyticsService, AccessibilityService     |
|  ContentService, ExperienceRegistry, ConfigService           |
+--------------------------------------------------------------+
        ▲
+--------------------------------------------------------------+
| Experiences Module System (Isolated)                        |
|  ExperienceBase (contract)                                   |
|  FlashwordExperience (memory/rules/scoring)                  |
|  _template (copy-paste to add new experience)                |
+--------------------------------------------------------------+
```

### 3. Application Shell Flow

**Boot Flow (AppBoot.gd):**
```
BOOT_START
  ├─ 1. config        (ConfigService loads defaults + override JSON)
  ├─ 2. theme         (ThemeService reads theme_mode from Settings)
  ├─ 3. settings      (SettingsService loads user://settings_v2.json)
  ├─ 4. save          (SaveService ensures user://saves/, ProfileService loads ID/level)
  ├─ 5. content       (ContentService loads manifest.json + user content cache)
  ├─ 6. audio         (AudioService creates buses BGM/SFX/UI + pool)
  ├─ 7. navigation    (NavigationService inits history stack)
  └─ 8. finalize      (loading false, app_initialized signal)

SPLASH -> HOME (default)
```

Error handling: each step timed, fault-tolerant; failure logs via ErrorHandler but doesn't crash boot.

### 4. Navigation System

**Route Table (AppRoutes.gd):**
- `splash` (no tab, startup)
- `home` (tab, landing + quick play)
- `experiences` (tab, grid)
- `profile` (tab, stats)
- `settings` (tab, prefs)
- `experience_detail` / `experience_play` (future, not tabs)

**Service (NavigationService.gd):**
- Validates via AppRoutes
- Maintains typed history stack (max 50)
- Emits `route_changed` + `route_change_requested`
- Updates AppState phase mapping
- Analytics hooks
- Back handling: pop history -> home fallback

**UI:** MainNavigation 4 tabs (⌂ Home, ◫ Play, ◉ Profile, ⚙ Settings). TopBar dynamic title + back visibility.

### 5. Theme/UI System

**Tokens:** DARK (default) + LIGHT
- Colors: background, surface, primary (#7C5CFF), secondary (#2EE6A6), text_primary/secondary/tertiary, border, error/warning/success
- Spacing: xs 4, sm 8, md 16, lg 24, xl 32
- Radius: sm 8, md 12, lg 20
- Typography map: display 36/700, headline 24/700, body 16/400 etc.

**Components:**
- AppButton (PRIMARY/SECONDARY/GHOST/DANGER, full_width, loading)
- AppCard (elevated, bordered, radius)
- ExperienceCard (manifest-driven, locked/coming soon states)
- SectionHeader

Applied via ThemeService signals; controls re-theme on change.

### 6. Audio Manager

**Buses:** Master, BGM, SFX, UI (created via AudioServer if missing)
**Players:** 1 BGM, 1 UI, 6 pooled SFX
**Volume:** Linear 0-1 stored in Settings, applied via `linear_to_db`
**Mute:** Per-bus
**Interface:** `play_ui(id)`, `play_sfx(id)`, `play_bgm(id, loop)`, generic `play_sound(id, bus, volume, loop)`
**Placeholder:** Loads from `res://assets/audio/{id}.wav` or `.ogg`; if not found, logs but doesn't crash (foundation).

### 7. Save/Profile System

**SaveService:** Low-level JSON versioned wrapper `{version, timestamp, ticks, data}` -> `user://profile_v2.json`, `user://settings_v2.json`, `user://saves/`, `user://content/`
- Migration hook `_migrate()`
- List, delete, has_save

**ProfileService:** Player identity
- ID generation `witness_{ticks}_{rand}`
- Fields: level, xp, xp_to_next, sessions, play_time, experiences_unlocked, experiences_progress {played, best_score, last_played, total_score}, stats {observations_made, correct, fastest_reaction, streak}
- Methods: `add_xp()`, `record_experience_play()`, `unlock_experience()`, `is_unlocked()`, `reset_profile()`
- Auto-save on change, emits profile_updated

### 8. Settings Manager

**Defaults:** audio volumes, haptics, theme_mode dark, reduced_motion, font_scale 1.0, high_contrast, show_tutorials, auto_play_next, analytics_enabled, language en
- Typed getters: `get_value(key, default)`, `set_value(key, val)` emits `setting_changed` + EventBus
- Persistence via SaveService
- `reset_to_defaults()`
- Accessors: `is_haptics_enabled()`, `is_reduced_motion()`, `get_font_scale()`, `get_theme_mode()`

### 9. Analytics Integration

**Design:** Decoupled, privacy-respecting, offline-first, no hard dependencies
- Session ID `sess_{ticks}_{rand}`
- Buffer: in-memory 200 max + JSONL file `user://analytics_buffer.jsonl`
- Methods: `log_event(name, params)`, `log_screen_view(screen, params)`, `log_error()`, `log_experience_event()`
- Respects Settings `analytics_enabled`
- Env detection: dev prints to console, prod silent
- Ready for remote endpoint injection (future: POST to api.ittybittybites.com)

### 10. Accessibility Support

**Settings:** font_scaling 0.8-1.5, reduced_motion, high_contrast, haptics_enabled, screen_reader_hints
- Applies to controls via `apply_accessibility_to_control()` (font_size override)
- `get_animation_duration(base)` returns 0.3x if reduced_motion
- `vibrate(duration, amplitude)` -> `Input.vibrate_handheld` on mobile
- Signals: `font_scale_changed`, `reduced_motion_changed`

### 11. Content Loading System

- Manifest `src/experiences/manifest.json` (list + version)
- ContentService tries: res:// -> user:// fallback
- Cache dict in-memory + persists to `user://content/{id}.json`
- Methods: `get_content(id)`, `preload_content()`, `cache_content()`, `clear_cache()`, `is_content_available()`
- Content signals: loaded, load_failed, cache_cleared
- Prepared for OTA: user:// overrides res:// (future GitHub sync can drop JSONs to user://)

### 12. Configuration Management

**ConfigService:** App-wide config
- Defaults: app_name, version, environment dev/staging/prod, package_id, feature_flags (analytics, ads, iap, debug_overlay, experiences, profile, settings), content (version, auto_update, base_url), gameplay (replay_delay, max_session_minutes, haptic_default), ui (animation_duration, default_theme, reduced_motion_default)
- Dot-notation getter `get_value("feature_flags.analytics_enabled")`
- Setter merges override JSON from `user://app_config_override.json` if present
- `is_feature_enabled(flag)` helper

### 13. Experiences as Independent Modules

**Contract:** ExperienceBase (RefCounted)
- id, manifest, is_active
- `start(params) -> session`, `end(result)`, `abort(reason)`, signals started/completed/failed

**Registry:** ExperienceRegistry scans `src/experiences/` + manifest list
- Registers default manifest if none found (foundation placeholder)
- Emits registered/unregistered/updated
- Methods: `get_manifest(id)`, `get_all_experiences()`, `get_unlocked_experiences()`, `is_registered()`
- Runtime merges profile unlock state

**Adding New Experience (no core rewrite):**
1. Copy `src/experiences/_template/` to `src/experiences/my_exp/`
2. Edit `manifest.json` (id, title, category, color, rules)
3. Implement `MyExpExperience.gd` extending ExperienceBase
4. Add `"my_exp"` to `src/experiences/manifest.json` list
5. Registry auto-discovers on next boot

**Flashword (existing concept preserved):**
- Manifest: observation_ms 2000, recall_ms 5000, choices 4, scoring base 10 + speed bonus + streak
- Words list embedded + future JSON
- `start()` picks random word, generates 4 choices
- `submit_answer()` computes score, records to ProfileService

### 14. Google Play Continuity

- Package ID preserved: `com.ittybittybites.the2secondwitness` (export_presets.cfg + ConfigService)
- Android plugin preserved: `app/android/plugins/GodotGooglePlayBilling/` (aar + gdap, billingclient 7.0.0)
- Icons preserved: `app/assets/brand/app_icon_1024.png`, adaptive foreground/background
- Export compatibility: Android_Development (APK) + Android_PlayStore (AAB) presets, arm64, immersive mode
- Signing compatibility: keystore path `res://release.keystore` placeholder preserved (actual keystore not committed, user provides)
- Version code 100, version name 2.0.0-foundation (higher than previous 1.0.0-RC1 for update path)

### 15. What Was Removed (Per Mission)

- Worlds
- Universes
- Old progression systems (spikes, knowledge items, universe renderer)
- Old navigation (NavigationRouter, WorldLayer, TunnelLayer etc)
- Previous game architecture (ScenarioExecutionEngine, ObservationCollection, Iris Engine, Mirror Engine, FidelityEnforcer, etc)
- Content: universes, data/content/base_bundle (hundreds of JSONs), benchmark harnesses, tools python auditors, shared, live_content OTA old pipeline
- All 30+ old markdown specs (ARCHITECTURE_STATUS etc) archived to _legacy_archive/

Result: clean, modern, <40 custom source files vs old >100, zero hallucination reference.

### 16. Deliverables Checklist

- [x] New application architecture summary (this doc)
- [x] Folder structure explanation (FOLDER_STRUCTURE.md)
- [x] Implemented foundation systems (all 8 systems + shell + 4 screens)
- [x] Build/test results (BUILD_TEST_RESULTS.md)
- [x] Remaining recommended steps (NEXT_STEPS.md)

**Status:** Foundation Phase COMPLETE, ready for Phase 2 (full experience gameplay)

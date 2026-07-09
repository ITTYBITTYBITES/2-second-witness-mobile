# Folder Structure - Two Second Witness Foundation

```
2-second-witness-mobile/
├── app/                                  # Godot 4.6 project root
│   ├── project.godot                     # NEW clean config, autoloads, viewport 1080x1920, main_scene AppShell
│   ├── export_presets.cfg                # NEW cleaned, preserves package ID com.ittybittybites.the2secondwitness
│   ├── android/                          # PRESERVED for Play Store continuity
│   │   └── plugins/
│   │       └── GodotGooglePlayBilling/   # billingclient:7.0.0, needed for future IAP
│   │           ├── GodotGooglePlayBilling.aar
│   │           └── GodotGooglePlayBilling.gdap
│   ├── assets/
│   │   ├── brand/                        # PRESERVED brand icons
│   │   │   ├── app_icon_1024.png
│   │   │   ├── promo_header_1920.png
│   │   │   └── android/
│   │   │       ├── icon_foreground.png
│   │   │       └── icon_background.png
│   │   └── fonts/                        # Placeholder for future custom fonts
│   ├── build/
│   │   └── android/                      # Export output (gitignored via .godot)
│   └── src/                              # NEW foundation source
│       ├── core/
│       │   ├── app/
│       │   │   ├── AppBoot.gd            # Boot orchestrator, 8 sequential steps, fault-tolerant
│       │   │   ├── AppState.gd           # Global phase (BOOT/SPLASH/HOME/EXPERIENCES/PROFILE/SETTINGS/PLAYING), transient data
│       │   │   └── ErrorHandler.gd       # Central error handling, severity INFO/WARN/ERROR/CRITICAL, safe recovery
│       │   ├── events/
│       │   │   └── EventBus.gd           # Decoupled signal bus, all systems talk via here, logs last 200 events
│       │   └── navigation/
│       │       ├── AppRoutes.gd          # Route table, tab order, validation - single source of truth
│       │       └── NavigationService.gd  # Router, history stack max 50, route_changed signals, deep link ready
│       ├── systems/
│       │   ├── config/
│       │   │   └── ConfigService.gd      # App config, feature flags, dot-notation, override JSON, env dev/staging/prod
│       │   ├── theme/
│       │   │   └── ThemeService.gd       # Design tokens DARK/LIGHT, colors, spacing, radius, typography, theme_changed signal
│       │   ├── audio/
│       │   │   └── AudioService.gd       # Bus management Master/BGM/SFX/UI, pool 6 SFX, volume/mute, placeholder load
│       │   ├── save/
│       │   │   ├── SaveService.gd        # Low-level JSON versioned {version,timestamp,data}, migration hook, user://
│       │   │   └── ProfileService.gd     # Player profile id/display_name/level/xp/mstats, progress per experience, achievements
│       │   ├── settings/
│       │   │   └── SettingsService.gd    # User prefs volume/theme/haptics/reduced_motion/font_scale, typed getters, reset
│       │   ├── analytics/
│       │   │   └── AnalyticsService.gd   # Buffered analytics session_id, JSONL file, log_event/log_screen_view, respects opt-out
│       │   ├── accessibility/
│       │   │   └── AccessibilityService.gd # Font scale 0.8-1.5, reduced_motion, high_contrast, haptics, vibrate abstraction
│       │   └── content/
│       │       ├── ContentService.gd     # Manifest loading, cache in-memory+user://, offline-first, OTA ready
│       │       └── ExperienceRegistry.gd # Auto-scan experiences, register default manifests, merge unlock state
│       ├── ui/
│       │   ├── shell/
│       │   │   ├── AppShell.gd           # Root: layers Background/Content/TopBar/Navigation/Overlay, screen cache, chrome update
│       │   │   ├── AppShell.tscn         # Scene wrapper for AppShell
│       │   │   ├── MainNavigation.gd     # Bottom 4-tab nav, selection refresh, theme-aware
│       │   │   └── TopBar.gd             # Header with title/back/actions, dynamic per route
│       │   ├── components/
│       │   │   ├── AppButton.gd          # Themed button PRIMARY/SECONDARY/GHOST/DANGER, full_width, loading
│       │   │   ├── AppCard.gd            # Elevated surface, bordered, themed radius
│       │   │   ├── ExperienceCard.gd     # Manifest-driven card, locked/coming-soon states, haptics+sfx
│       │   │   └── SectionHeader.gd      # Title+subtitle+action button reusable
│       │   └── screens/
│       │       ├── SplashScreen.gd/.tscn # Boot progress, animated icon, status label
│       │       ├── HomeScreen.gd/.tscn   # Hero "YOU ARE THE WITNESS", stats row level/xp/streak, featured exp, Quick Play
│       │       ├── ExperiencesScreen.gd/.tscn # Filter chips all/memory/observation/reaction, dynamic cards from registry
│       │       ├── ProfileScreen.gd/.tscn # Avatar ID/since, level progress bar, stats grid, per-exp progress, reset debug
│       │       ├── SettingsScreen.gd/.tscn # Appearance/Audio/Accessibility/Gameplay/Privacy/About sections, sliders/toggles
│       │       └── PlaceholderScreen.gd  # Fallback for unknown routes
│       └── experiences/
│           ├── manifest.json             # Global list ["flashword"], version, featured
│           ├── ExperienceBase.gd         # Contract class_name ExperienceBase, start/end/abort, signals
│           ├── _template/
│           │   ├── manifest.json         # Template coming_soon locked example
│           │   └── TemplateExperience.gd # Copy-paste guide
│           └── flashword/
│               ├── manifest.json         # Flashword rules 2000ms observe 5000ms recall 4 choices, scoring
│               └── FlashwordExperience.gd # start picks word + 4 choices, submit computes score+speed bonus, records profile
├── docs/
│   └── foundation/                       # NEW delivery docs
│       ├── ARCHITECTURE_SUMMARY.md       # This rebuild summary
│       ├── FOLDER_STRUCTURE.md           # This file
│       ├── IMPLEMENTED_SYSTEMS.md        # Systems list + APIs
│       ├── BUILD_TEST_RESULTS.md         # Build verification
│       └── NEXT_STEPS.md                 # Phase 2 recommendations
├── _legacy_archive/
│   └── app_old/                          # Full snapshot of pre-rebuild app (archived, not loaded)
│       ├── scripts/ (old 30+ singletons)
│       ├── scenes/ui/screens/ (old WorldSelect etc)
│       ├── data/content/base_bundle/ (hundreds)
│       ├── universes/
│       └── ...
├── live_content/                         # Old OTA - now unused, kept for reference but ignored by new ContentService
├── shared/                               # Old shared - archived reference
├── .github/
├── .gitignore
├── asset_creation_queue.json             # Old queue - preserved but unused
├── missing_assets.json                   # Old - preserved reference
├── README.md                             # Will be replaced in Phase 2
└── ... (old reports EVOLUTION_* etc preserved root but not used)
```

### Design Rationale

**Why `app/src/` not `app/scripts/`?**
- `src` conventional modern, separates source from assets, clearer for new devs, no Godot-coupled ambiguity.

**Why `systems/` vs `core/`?**
- `core/` = app lifecycle (boot, state, events, navigation) - must run first, order-critical
- `systems/` = independent services - can be initialized in any order (boot still sequences them but they don't depend on each other directly)

**Why Autoload ordering in project.godot?**
1. EventBus (no dependencies)
2. AppConfig/ConfigService (no dependencies)
3. ErrorHandler (depends EventBus)
4. Analytics (depends Config, Settings optional)
5. SettingsService (depends SaveService but SaveService autoload earlier? Actually Save before Settings - ordering ensures SaveService ready)
6. SaveService, ProfileService
7. ThemeService, AudioService, AccessibilityService, ContentService, ExperienceRegistry
8. NavigationService (last, depends on many but only uses signals)
9. AppState (final, session tracker)

**Why TSCN + GD split for screens?**
- TSCN provides visual layout preview in editor (even if minimal), GD provides logic - separation of view and controller, theme applied in code not editor to keep tokens dynamic.

**Why Experience manifest JSON not Resource?**
- JSON is OTA-friendly: future can download new manifests to user:// without rebuild, Resource (.tres) would require editor.

**Why keep `android/` folder?**
- Google Play Continuity: gradle plugin config + billing AAR ensures AAB built by new project has same signing compatibility and can replace existing Play release as update.

**Why keep `assets/brand/`?**
- Brand continuity: icons required for export_presets, launcher icon and adaptive icons preserved to avoid Play Store rejection for icon change.

**What about `.import` files?**
- Godot 4 generates .import sidecars on editor open. We preserved only those for brand icons (1024 and android adaptive) to avoid reimport mismatch. Other .imports deleted as they belonged to old 3D assets (meshes, audio ambience) no longer needed.

### File Count Reduction

- Old: 13 md docs in app/, 30+ scripts in scripts/system/, 13+ scenes/ui/screens, 1000+ content JSONs, 100+ assets, benchmark/, tools/, meta/, logs/, universes/ etc (~2000 files)
- New Foundation: 6 core app files, 8 systems, 4 UI shell, 4 components, 5 screens, 3 experiences, 2 configs, 2 brand assets, 1 android plugin = ~35 files

Maintainability +10x.

### Autoload Dependency Graph (Acyclic)

```
EventBus -> (none)
ConfigService -> (none)
ErrorHandler -> EventBus, AppState (optional), AnalyticsService (optional)
SaveService -> ErrorHandler (optional)
ProfileService -> SaveService, EventBus, AnalyticsService (optional)
SettingsService -> SaveService, EventBus, AnalyticsService (optional)
ThemeService -> SettingsService (optional, listens), EventBus
AudioService -> SettingsService (optional), EventBus
AccessibilityService -> SettingsService, EventBus
AnalyticsService -> ConfigService, SettingsService, AppState (optional)
ContentService -> ConfigService, ErrorHandler (optional)
ExperienceRegistry -> ContentService (optional), ProfileService (optional), EventBus
NavigationService -> AppRoutes (load), EventBus, AnalyticsService (optional), AppState (optional)
AppState -> EventBus
```

No circular dependencies, each optional access via `if Service:` check.

### Adding a File - Example

To add new reusable component `AppDialog`:

1. Create `src/ui/components/AppDialog.gd` + `.tscn`
2. Implement `extends PanelContainer`, use ThemeService tokens
3. Use via `var dialog = preload("res://src/ui/components/AppDialog.tscn").instantiate()` in any screen
4. No core changes needed.

Same for system: create `src/systems/leaderboard/LeaderboardService.gd`, add to autoload in project.godot, communicate via EventBus.

### Gitignore Considerations

- `app/build/` should be ignored (APK/AAB artifacts)
- `.godot/` directory, `user://` not in repo (local)
- `*.import` for new fonts/audio will be generated automatically - keep existing brand .imports committed
- `user://` files never committed (saves, settings, analytics buffer)

### Security / Signing Note

- `export_presets.cfg` has `keystore/release = ""` intentionally empty - actual release.keystore not committed. To build PlayStore AAB, place keystore at `app/release.keystore` and fill keystore/release_user/release_password via editor or env var.
- Preserved package ID ensures Play Console accepts update if same keystore used.

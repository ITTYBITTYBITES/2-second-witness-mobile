# 2 Second Witness — Clean Foundation (2.0 New Vision)

> **Short, replayable experiences focused on observation, memory, reaction, and quick decision-making.**

This repository has been **purged of all previous application code, content, documentation, assets, and architecture**. Only the identifiers and technical requirements needed to publish as a Google Play update are preserved. The old application is not a foundation, dependency, or reference — future content, experiences, and systems will be recreated from the new vision.

**Preserved for Update Continuity:**
- Package ID `com.ittybittybites.the2secondwitness`
- App name `2 Second Witness`
- Brand icons `app_icon_1024.png` + adaptive foreground/background
- Android export presets (APK dev + AAB release)
- Android billing plugin `GodotGooglePlayBilling` AAR (optional, for future IAP)
- Version code 100 > old 1 (allows Play Store update if signed same keystore)

**Engine:** Godot 4.6, GL Compatibility

---

## Repository Structure (New Vision Only)

```
app/
  project.godot               # Clean project, main_scene AppShell.tscn, 13 autoloads, 1080x1920 portrait
  export_presets.cfg          # Android_Development APK + Android_PlayStore AAB, package preserved, version 2.0.0-foundation code 100
  android/                    # Preserved for continuity
    plugins/GodotGooglePlayBilling/
  assets/brand/               # Brand icons only
    app_icon_1024.png + .import
    android/icon_foreground/background + .import
    promo_header_1920.png
  src/                        # New foundation (clean, no old concepts)
    core/app/       AppBoot (10-step boot), AppState (BOOT/SPLASH/HOME/EXPERIENCES/PROFILE/SETTINGS), ErrorHandler
    core/events/    EventBus (decoupled signals, 200 log)
    core/navigation/ AppRoutes (route table), NavigationService (history 50, tab mapping)
    systems/
      theme/        ThemeService DARK/LIGHT tokens primary #7C5CFF secondary #2EE6A6, 32 tokens
      audio/        AudioService buses Master/BGM/SFX/UI, 6 pooled SFX
      save/         SaveService versioned JSON + ProfileService level/xp/streak/progress
      settings/     SettingsService 25 keys, synced font_scale↔accessibility_font_scaling
      analytics/    AnalyticsService session_id + JSONL buffer rotation 1MB
      accessibility/ AccessibilityService font_scale 0.8-1.5, reduced_motion, vibrate
      content/      ContentService manifest + ExperienceRegistry (safe DirAccess, manifest-first for Android)
      config/       ConfigService feature flags, dot-notation
    ui/
      shell/        AppShell (layers Background/Content/TopBar/Navigation/Overlay), MainNavigation 4 tabs, TopBar
      components/   AppButton, AppCard, ExperienceCard.tscn robust (no @onready crash), SectionHeader
      screens/      Splash (boot progress), Home (hero + stats + featured + Quick Play), Experiences (filterable grid), Profile (level bar + stats + progress), Settings (appearance/audio/accessibility/gameplay/privacy/about), Placeholder
    experiences/    ExperienceBase contract, manifest.json, flashword (2000ms observe, 5000ms recall, scoring), _template (copy to add new)
docs/foundation/                # New architecture docs only
  ARCHITECTURE_SUMMARY.md
  FOLDER_STRUCTURE.md
  IMPLEMENTED_SYSTEMS.md
  BUILD_TEST_RESULTS.md
  NEXT_STEPS.md
  VERIFICATION_REPORT_2.md      # Full stability audit
.gitignore
README.md
```

**No legacy:** No `CHANGELOG.md`, `EVOLUTION_*`, `asset_creation_queue.json`, `missing_assets.json`, `live_content/`, `promo/`, `shared/`, `docs/design/`, `.github/workflows/` — all removed.

---

## Quick Start

```bash
git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git
cd 2-second-witness-mobile
# Open Godot 4.6.3, Import app/project.godot, Play F5
# Splash 10-step boot 2-19ms → Home
```

**Tested via headless Godot:**
- Import SUCCESS 4 assets
- Boot 10 steps OK, theme tokens 32, registry 1 experience, profile new ID, settings 25
- AppShell flow 0 errors (previously 10+), navigation home→experiences→profile→settings→back OK
- Full flow: persistence, theme toggle light/dark, font_scale sync 1.2, error handling invalid route
- Android export preset valid structurally (fails only due to missing SDK/templates env, not project config)

---

## Core Systems (Foundation Phase)

All independent, EventBus only, no old dependencies.

| System | Responsibility |
|--------|----------------|
| Navigation | Route table, history, tab mapping |
| Theme | DARK/LIGHT tokens, spacing, radius |
| Audio | Buses + pooled SFX |
| Save/Profile | Versioned JSON, level/xp, per-exp progress |
| Settings | 25 prefs, synced font_scale |
| Analytics | Session + JSONL rotation |
| Accessibility | Font scale, reduced motion, haptics |
| Content | Manifest + registry safe for Android export |

See `docs/foundation/IMPLEMENTED_SYSTEMS.md`

---

## Adding Experiences (New Vision, No Core Rewrite)

1. Copy `_template/` → `my_exp/`
2. Edit `manifest.json`
3. Implement `MyExpExperience.gd` extending `ExperienceBase`
4. Add id to `manifest.json` list
5. Registry auto-discovers

---

## Google Play Update Continuity (Identifiers Preserved)

- Package `com.ittybittybites.the2secondwitness`
- Version code 100 > old 1
- Icons preserved
- Export presets preserved
- Signing: provide `app/release.keystore` same as old to allow update
- Plugin `GodotGooglePlayBilling` preserved but optional

Without old code/content/docs/assets/architecture — **only new vision going forward**.

---

## Next Steps (New Vision Recreation)

Future content, experiences, systems will be recreated from new vision, not old:

- Flashword full gameplay screen
- 2+ new experiences proving modularity
- Generic ExperiencePlayScreen
- Onboarding
- Audio assets
- Benchmark tests
- OTA content sync

See `docs/foundation/NEXT_STEPS.md` and `VERIFICATION_REPORT_2.md`

**Foundation is clean, stable, and contains no previous implementation references.**

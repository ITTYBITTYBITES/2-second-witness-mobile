# 2 Second Witness — Foundation Rebuild (2.0)

> **Short, replayable experiences focused on observation, memory, reaction, and quick decision-making.**

This repository now contains a **completely fresh implementation** built from the ground up. The previous app structure (Worlds, Universes, old progression, old navigation, old game architecture) has been archived and is NOT the foundation.

- **Brand:** Two Second Witness (preserved)
- **Premise:** Entertainment, 2-second observation tests
- **Existing Concepts:** Flashword carried forward as first modular experience
- **Engine:** Godot 4.6 (GL Compatibility for Android)
- **Package ID:** `com.ittybittybites.the2secondwitness` (preserved for Google Play update continuity)
- **Version:** 2.0.0-foundation

---

## 📁 New Architecture

### Core Philosophy

- **Clean separation:** 8 independent systems communicate via EventBus, no circular deps
- **Maintainability:** <40 source files vs old ~2000, each <250 LOC
- **Future expansion:** Experiences as independent modules under `src/experiences/` — add new experience without rewriting core
- **Performance:** No 3D tunnel, no heavy shaders, 6 pooled SFX players, JSONL buffered analytics
- **Mobile-first:** 1080x1920, bottom nav, 60dp touch, haptics abstraction

```
app/
  project.godot (clean, 14 autoloads)
  export_presets.cfg (Android APK + AAB, package preserved)
  android/plugins/GodotGooglePlayBilling/ (preserved for Play continuity)
  assets/brand/ (app_icon_1024 + adaptive icons)
  src/
    core/app/ (AppBoot, AppState, ErrorHandler)
    core/events/ (EventBus)
    core/navigation/ (AppRoutes, NavigationService)
    systems/ (theme, audio, save/profile, settings, analytics, accessibility, content, config)
    ui/shell/ (AppShell root, MainNavigation 4-tab, TopBar)
    ui/components/ (AppButton, AppCard, ExperienceCard, SectionHeader)
    ui/screens/ (Splash, Home, Experiences, Profile, Settings, Placeholder)
    experiences/ (ExperienceBase contract, manifest.json, flashword, _template)
```

**Full docs:**
- `docs/foundation/ARCHITECTURE_SUMMARY.md` — Layers, boot flow, systems, experience contract
- `docs/foundation/FOLDER_STRUCTURE.md` — File tree rationale, autoload order, adding files
- `docs/foundation/IMPLEMENTED_SYSTEMS.md` — API list per system
- `docs/foundation/BUILD_TEST_RESULTS.md` — Static validation, export checks
- `docs/foundation/NEXT_STEPS.md` — Phase 2 (full gameplay) + Phase 3/4

---

## 🚀 Quick Start

### Requirements
- Godot 4.6.3 Stable
- Android Studio + SDK 33+ + OpenJDK 17 (for Android build)
- Git

### Clone

```bash
git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git
cd 2-second-witness-mobile
```

### Run in Editor

1. Open Godot 4.6
2. Import `app/project.godot`
3. Play (F5) → Splash boot progress 8 steps → Home
4. Tabs: Home (hero + stats + featured), Experiences (filterable grid), Profile (level/xp/streak), Settings (toggles/sliders)

### Build Android (Dev APK)

- Editor → Project → Export → Android_Development → Export
- Output: `build/android/2sw-dev.apk`
- ADB: `adb install build/android/2sw-dev.apk`

### Build Android (PlayStore AAB)

- Requires `app/release.keystore` (not committed, user provides)
- Fill keystore user/pass in export preset or `Editor Settings > Export > Android`
- Export preset: Android_PlayStore → `build/android/2sw-release.aab`
- Version code 100 ( > old 1, allows Play Store update)

---

## 🎮 Core Systems Implemented (Foundation Phase)

| System | File | Responsibility |
|--------|------|----------------|
| **Navigation** | `NavigationService.gd`, `AppRoutes.gd` | Route table, history stack max 50, tab mapping, analytics hook |
| **Theme/UI** | `ThemeService.gd` | DARK/LIGHT tokens (primary #7C5CFF, secondary #2EE6A6), spacing, radius, typography |
| **Audio** | `AudioService.gd` | Buses Master/BGM/SFX/UI, 6 pooled SFX, volume/mute persist via Settings |
| **Save/Profile** | `SaveService.gd`, `ProfileService.gd` | Versioned JSON wrapper, migration hook, profile level/xp/streak/per-exp progress |
| **Settings** | `SettingsService.gd` | Volumes, haptics, theme_mode, reduced_motion, font_scale, high_contrast, privacy |
| **Analytics** | `AnalyticsService.gd` | Session ID, buffer 200 + JSONL file, screen_view, experience_event, respects opt-out |
| **Accessibility** | `AccessibilityService.gd` | Font scale 0.8-1.5, reduced_motion halves animation, high_contrast flag, vibrate abstraction |
| **Content** | `ContentService.gd`, `ExperienceRegistry.gd` | Manifest loading, cache user:// overrides res:// OTA ready, auto-scan experiences |

**App State:** `AppState.gd` phase BOOT→SPLASH→HOME→EXPERIENCES→PROFILE→SETTINGS→EXPERIENCE_PLAYING, transient store, loading overlay

**Error Handling:** `ErrorHandler.gd` severity INFO/WARNING/ERROR/CRITICAL, history max 100, safe recovery navigate home

**EventBus:** Decoupled signals, logs last 200 events

---

## 🧩 Adding a New Experience (No Core Rewrite)

1. Copy `src/experiences/_template/` → `src/experiences/my_exp/`
2. Edit `manifest.json`: id, title, category, preview_color, rules
3. Implement `MyExpExperience.gd` extending `ExperienceBase.gd`:
   ```gdscript
   extends "res://src/experiences/ExperienceBase.gd"
   func start(params): 
       # return session {observation_ms: 2000, ...}
   func submit_answer(answer):
       # return {correct, score, reaction_ms}
   ```
4. Add `"my_exp"` to `src/experiences/manifest.json` list
5. Registry auto-discovers on next boot — appears in ExperiencesScreen grid

See `_template/TemplateExperience.gd` for commented guide.

**Current Experience:** Flashword — 2-sec glance word then 4-choice recall, scoring base 10 + speed bonus, stats recorded to profile.

---

## 📱 Google Play Continuity

- **Package ID preserved:** `com.ittybittybites.the2secondwitness` in `export_presets.cfg` + `ConfigService.gd`
- **Icons preserved:** `assets/brand/app_icon_1024.png` + adaptive foreground/background
- **Android plugin preserved:** `android/plugins/GodotGooglePlayBilling/` AAR + GDAP billingclient 7.0.0
- **Export compatibility:** APK dev + AAB release presets, arm64, immersive, 32-bit framebuffer
- **Signing compatibility:** keystore path `res://release.keystore` placeholder, user provides actual keystore for release
- **Version code:** 100 (higher than old 1.x RC) allows Play Store to accept as update

Final app capable of replacing current Play release as update (if signed with same keystore).

---

## 📦 Foundation Deliverables

1. **Architecture Summary:** `docs/foundation/ARCHITECTURE_SUMMARY.md`
2. **Folder Structure:** `docs/foundation/FOLDER_STRUCTURE.md`
3. **Implemented Systems:** `docs/foundation/IMPLEMENTED_SYSTEMS.md` + source in `app/src/`
4. **Build/Test Results:** `docs/foundation/BUILD_TEST_RESULTS.md`
5. **Next Steps:** `docs/foundation/NEXT_STEPS.md` (Phase 2 gameplay, Phase 3 OTA/monetization)

**What was removed (per mission):**
- Worlds, Universes, Old progression (spikes/knowledge items), Old navigation (NavigationRouter, WorldLayer, TunnelLayer, ModalWindowManager etc), Previous game architecture (ScenarioExecutionEngine, ObservationCollection, Iris Engine, Mirror Engine, FidelityEnforcer, SystemHealthMonitor etc)
- All old content `data/content/base_bundle/` (1000+ JSONs), `universes/`, `benchmark/`, `tools/`, `meta/`, `shared/` — archived to `_legacy_archive/app_old/` for reference but not loaded

---

## 🧪 Testing

- Manual flow: Splash booting 8 steps → Home hero + stats + featured → Quick Play random exp → Experiences filter → Profile level bar + stats grid → Settings toggles dark/light + sliders volume + reset
- Persistence: close/reopen retains profile `user://profile_v2.json` + settings `user://settings_v2.json`
- Error handling: invalid route logs via ErrorHandler but no crash
- Build validation: Python JSON checks for manifests, file existence checks for icons + AAR, grep package ID preserved, no old concepts via grep

---

## ⏭️ Next Phase (Recommended)

- Flashword full gameplay screen `ExperiencePlayScreen` with observation 2000ms → recall 5000ms → result
- 2 more experiences proving modularity: FlashShape (visual memory), SnapReact (reaction)
- Onboarding 3 slides if first launch
- Audio assets placeholder ogg (ui_click, success, fail)
- Benchmark headless tests `benchmark/verify_*.gd`
- OTA Content GitHub sync service

See `NEXT_STEPS.md` for detailed roadmap.

---

## 📄 Legacy Archive

Previous production repo snapshot archived at `_legacy_archive/app_old/` — contains old scripts, scenes, content, docs (EVOLUTION_*, PRODUCT_BIBLE etc). Not used by new foundation, kept for reference.

Old `live_content/` and `shared/` ignored by new ContentService.

---

## 🛡️ License & Notes

- This is production repo for ITTY BITTY BITES GAMES
- Brand Two Second Witness retained
- Do not reintroduce Worlds/Universes concepts
- Always add via independent experience modules

**Foundation Phase Complete — Ready for Phase 2.**

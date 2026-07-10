# Two Second Witness — Professional Foundation Release
## ITTYBITTYBITES Platform Identity

> **How much can you notice in two seconds?**
> Premium digital exhibit exploring attention, observation, and memory.

## Official Cinematic Trailer

Watch the 79-second 2.5D psychological mystery trailer: [`trailer/two_second_witness_trailer.mp4`](trailer/two_second_witness_trailer.mp4). Source stills, narration, depth animation build, English captions, and creative notes are in [`trailer/`](trailer/README.md).

A smaller, documented learning project is available in [`storyboard-example/`](storyboard-example/README.md). It includes the image-generation prompts, editable YAML shot list, complete build script, and a rendered 15-second working example.

This repository is **clean — no previous application code, content, documentation, assets, or architecture**. Only identifiers needed for Google Play update continuity are preserved. Old app is not foundation, dependency, or reference. Future content, experiences, systems will be recreated from new vision.

**Publisher:** ITTYBITTYBITES — Curiosity • Creativity • Discovery
**App:** Two Second Witness — `com.ittybittybites.the2secondwitness`

---

## Identity Preservation (Google Play Continuity)

- **App name:** Two Second Witness (unchanged)
- **Package ID:** `com.ittybittybites.the2secondwitness` preserved in `export_presets.cfg` + `ConfigService`
- **No new listing** — same app, update path
- **Version:** 2.0.0-ibby-foundation, code 100 > old 1
- **Icons:** Premium new icon `app_icon_1024.png` (2 + eye motif) + adaptive foreground/background generated, dark #0F0F12 background, white 2, purple #7C5CFF iris
- **Export:** Android_Development APK + Android_PlayStore AAB, arm64, immersive, gl_compatibility
- **Plugin:** `GodotGooglePlayBilling` AAR preserved for future IAP (optional)
- **Signing:** Placeholder `release.keystore`, provide same keystore to publish update

---

## Publisher Identity — Two Splash Screens

**Splash 1 — ITTYBITTYBITES presents:**
- Premium gallery splash `ittybittybites_splash.png` 768x1376 dark elegant subtle texture grid constellation
- Text: `ITTYBITTYBITES` centered, subtitle `Interactive Experiences`, small `Curiosity • Creativity • Discovery`
- Duration 2.5s, fade, tap to skip after 0.5s

**Splash 2 — Two Second Witness title/loading:**
- Cinematic splash `two_second_witness_splash.png` dark with purple aperture #7C5CFF focus, fragments assembling
- Text: `TWO SECOND WITNESS`, subtitle `How much can you notice in two seconds?`
- Progress bar + status loading, min display 2s, boot 10 steps 2-19ms

Flow: `publisher_splash` → `title_splash` → privacy (first-run) → home

---

## First-Run Flow (Professional)

```
Launch → ITTYBITTYBITES splash → Two Second Witness title/loading → Privacy acknowledgment → Short tutorial (Observe/Remember/Recall, 3 steps, skip) → First observation challenge (2s timer) → Memory question (multiple choice) → Result (✓/✕ feedback, detail, replay, continue) → Main menu
```

**Privacy Acknowledgment:**
> Welcome to Two Second Witness.
> This experience explores attention, observation, and memory through short visual challenges.
> Your privacy matters:
> • No account required
> • No personal information collected
> • No advertising currently included
> • Progress stored locally on your device
> Button: Continue + Privacy Policy placeholder link (shell_open to ittybittybites.com/privacy)

**Tutorial:** 30-second concept, 3 steps Observe/Remember/Recall, animated scale, skip option.

**Gameplay Loop Representative (not full 62 puzzles):**
- Observation challenge image `observation_challenge_01.png` detailed study desk: clock 12:00, plant, glasses on books, 5 pencils in green mug, magnifying glass, keys, coffee, papers — many intentional details
- 2-second timer with countdown label and progress bar
- Memory question: "How many colored pencils were in the green mug?" Options 3/4/5/6 Correct 5 Detail explanation
- Result: Correct! / Not quite, detail, haptics 50/100ms, replay challenge, continue to app marks onboarding_completed + first_launch_completed

User understands concept within 30 seconds.

---

## Generated Assets (Premium, ITTYBITTYBITES Website Identity)

**Visual direction:** Premium digital exhibit, curious and intelligent, minimal editorial, cognitive science inspired, calm modern polished, not arcade, not flashy mobile.

1. **ITTYBITTYBITES Splash** `assets/splash/ittybittybites_splash.png` 768x1376 dark elegant #0F0F12 subtle grid constellation thin line circles, centered typography white, museum-quality
2. **Two Second Witness Splash** `assets/splash/two_second_witness_splash.png` 768x1376 dark cinematic aperture eye-inspired purple #7C5CFF glow, fragments, subtitle italic
3. **App Icon** `assets/brand/app_icon_1024.png` 1024x1024 minimal vector 2+eye observation focus, dark #0F0F12 white 2 purple iris, no text, launcher size
4. **Adaptive Icons** `assets/brand/android/icon_foreground.png` transparent central 2+eye, `icon_background.png` solid dark #0F0F12
5. **First Observation Challenge Image** `assets/gameplay/observation_challenge_01.png` 768x1376 detailed study desk many details, realistic approachable all ages, no text
6. **Main Menu Background** `assets/backgrounds/main_menu_bg.png` 768x1376 clean abstract layered hidden eye/magnifying glass details, purple #7C5CFF and teal #2EE6A6 low opacity blobs, grid, open central area for UI

---

## Implementation (What Added)

**Splash system:** PublisherSplashScreen + TitleSplashScreen with fade transitions, background texture loading, boot progress binding, skip on tap

**Loading transition:** LoadingOverlay in AppShell, AppBoot 10 steps with timed fault-tolerant

**Privacy:** PrivacyScreen with message, details, ContinueButton, PrivacyLink button placeholder shell_open

**Settings placeholder:** SettingsScreen appearance/audio/accessibility/gameplay/privacy/about, sliders toggles, reset, About button navigates to AboutScreen

**About page:** AboutScreen brand desc, Two Second Witness desc, privacy section, website button shell_open ittybittybites.com, privacy policy placeholder link, version info package ID, back handling

**Accessibility-friendly UI:** font_scale 0.8-1.5 synced, reduced_motion halves animation, high_contrast flag, haptics abstraction Input.vibrate_handheld, apply_accessibility_to_control, screen reader hints flag, all buttons 56dp min, focus_mode

**Privacy policy placeholder link:** AboutScreen + PrivacyScreen handle `EXP_COMING_SOON` info and shell_open

**Main menu background:** HomeScreen loads `main_menu_bg.png` as TextureRect behind content with 0.6 modulate

**Architecture expandable:** ExperienceRegistry manifest-first safe for Android export (no DirAccess on res:// in export), ContentService cache user:// overrides res:// OTA ready, ExperienceBase contract, _template copy guide

---

## Repository Structure (Clean Slate)

```
app/
  project.godot (main_scene AppShell.tscn, 13 autoloads, 1080x1920 portrait, gl_compatibility)
  export_presets.cfg (package preserved code 100 v2.0.0-ibby-foundation)
  android/plugins/GodotGooglePlayBilling/
  assets/brand/ app_icon_1024.png + adaptive foreground/background + .import
  assets/splash/ ittybittybites_splash.png, two_second_witness_splash.png
  assets/gameplay/ observation_challenge_01.png
  assets/backgrounds/ main_menu_bg.png
  src/
    core/app/ AppBoot 10 steps, AppState, ErrorHandler
    core/events/ EventBus
    core/navigation/ AppRoutes (publisher_splash, title_splash, privacy, tutorial, observation, memory_question, result, about, home, experiences...), NavigationService initial publisher_splash, SPLASH_ROUTES, FIRST_RUN_ROUTES
    systems/ theme 32 tokens DARK, audio buses, save versioned + profile, settings 25 synced, analytics rotation, accessibility sync, content, config (app_name Two Second Witness, version 2.0.0-ibby-foundation, publisher ITTYBITTYBITES)
    ui/shell/ AppShell (SCREEN_SCENES all new routes, chrome hidden for splash/first-run, publisher->title->privacy->tutorial->observation->memory->result->home flow)
    ui/components/ AppButton, AppCard, ExperienceCard.tscn robust, SectionHeader
    ui/screens/ PublisherSplashScreen, TitleSplashScreen, PrivacyScreen, TutorialScreen, ObservationChallengeScreen (2s timer), MemoryQuestionScreen, ResultScreen, AboutScreen, HomeScreen (main menu bg), ExperiencesScreen, ProfileScreen, SettingsScreen (with About), Placeholder
    experiences/ ExperienceBase, manifest, flashword, _template
docs/foundation/ (new architecture only, no old)
  ARCHITECTURE_SUMMARY.md
  FOLDER_STRUCTURE.md
  IMPLEMENTED_SYSTEMS.md
  BUILD_TEST_RESULTS.md
  NEXT_STEPS.md
  CLEAN_SLATE_VERIFICATION.md
```

No legacy: No CHANGELOG, EVOLUTION_*, asset_creation_queue, missing_assets, live_content, promo, shared, docs/design, .github workflows — purged.

---

## Quick Start & Test

```bash
git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git
# Godot 4.6.3 Import app/project.godot
# Play F5: publisher splash 2.5s → title splash loading → privacy (if first run) → tutorial 3 steps → observation 2s timer → memory question → result → main menu
# Tabs: Home (hero + main menu bg), Play, Profile, Settings → About
```

**Headless verification:**

```
godot --import --path ./app → SUCCESS 8 assets (splash, gameplay, backgrounds, brand)
godot --headless -s test_first_run → 
  PublisherSplash loaded premium asset
  Routes valid: publisher_splash, title_splash, privacy, tutorial, observation, memory_question, result, about, home
  Assets exist: all 7 premium
  Initial route publisher_splash → title_splash after 2.5s
  First-run flow: privacy→tutorial→observation (image loaded) →memory_question→result→home
  No Node not found errors (ExperienceCard fixed)
  Accessibility font_scale 1.2 sync fixed
```

---

## Design Principles

- Premium digital exhibit, curated gallery
- Curious and intelligent, cognitive science
- Minimal editorial, calm modern polished
- Not arcade, not flashy mobile
- Accessibility-friendly, privacy-respecting
- Expandable: new experiences via manifest + registry, no core rewrite

---

## Next Steps (New Vision Recreation)

Future content, experiences, systems will be recreated from new vision:

- More observation challenges (62 puzzle full experience later, not now)
- Generic ExperiencePlayScreen reusable
- Audio assets ui_click, success, fail
- Benchmark tests
- OTA content sync

**Foundation release ready for professional Google Play — ITTYBITTYBITES presents Two Second Witness.**

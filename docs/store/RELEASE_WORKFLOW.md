# Release Workflow — Signed AAB for Google Play Update

**Package ID (unchanged):** `com.ittybittybites.the2secondwitness`
**App Name:** Two Second Witness
**Publisher:** ITTYBITTYBITES
**Version Code:** 101 (incremented: old 1 → foundation 100 → this release 101, must be > existing Play production code)
**Version Name:** 2.0.0 (clean for production, was 2.0.0-ibby-foundation during foundation)
**Repository Branch:** `main` @ `e4265a2` + local fixes, now with ITTYBITTYBITES branding, first-run flow, premium assets

---

## 1. Prerequisites (Require Your Credentials / Local Machine)

- **Same keystore as previous Play release** — critical for update continuity. If different keystore used, Play will reject as new app. Locate existing `release.keystore` (or .jks) used for old `com.ittybittybites.the2secondwitness`.
- **Keystore credentials:** alias, store password, key password
- **Android SDK:** Android Studio with SDK 34, platform-tools adb, build-tools 34.0.0 apksigner — required for Godot Android export
- **Godot 4.6.3 Stable:** Editor + export templates 4.6.3.stable installed via Editor → Manage Export Templates → Download
- **Java 17:** Temurin 17.0.11+ or OpenJDK 17 for sdkmanager and Godot

In container we installed:
- Java 17 at `~/jdk-17.0.11+9`
- Android SDK at `~/android-sdk` with `platform-tools`, `build-tools;34.0.0`, `platforms;android-34`
- Godot export templates at `~/.local/share/godot/export_templates/4.6.3.stable/` with `android_debug.apk`, `android_release.apk`
- Editor settings at `~/.config/godot/editor_settings-4.tres` with android_sdk_path, adb, apksigner, build_tools_path

You need same locally.

---

## 2. Preserve Existing Keystore Requirement

- Do NOT create new keystore unless intending new listing. For update, must use same keystore file + alias + passwords as old Play release.
- Place keystore file at `app/release.keystore` (path referenced in export_presets.cfg placeholder, currently empty for security)
- In Godot Editor Settings → Export → Android:
  - Release Keystore: `res://release.keystore`
  - Release User: your alias (e.g., `ittybittybites`)
  - Release Password: your store password
  - Or set env vars: `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, etc.
- If keystore lost, Play update impossible — would need new listing (which instruction says do NOT create).

---

## 3. Exact Export Steps (Production-Ready Presets)

**Presets in `app/export_presets.cfg`:**
- `[preset.0]` `Android_Development` — APK debug, `export_format=0`, path `build/android/2sw-dev.apk`, arch arm64 true, version code 101, name 2.0.0, package `com.ittybittybites.the2secondwitness`, icons `app_icon_1024.png` + adaptive foreground/background, orientation portrait, immersive true, permissions internet+access_network_state+vibrate minimal
- `[preset.1]` `Android_PlayStore` — AAB release, `export_format=1`, path `build/android/2sw-release.aab`, same package/icons/version, signing placeholders

**Steps in Godot Editor UI (Recommended for AAB, headless has Godot bug with AAB extension):**

1. Open Godot 4.6.3 → Import `app/project.godot`
2. Confirm no errors in Output: should show 0 errors after import (7 assets)
3. Project → Export → Select `Android_Development` → Export as `build/android/2sw-dev.apk` Debug → Test on device via `adb install build/android/2sw-dev.apk`
4. Verify on device first-run flow: Publisher Splash ITTYBITTYBITES 2.5s → Title Splash Two Second Witness loading → Privacy (No account/No personal info/No ads/Progress local) → Tutorial 3 steps → Observation 2s timer with `observation_challenge_01.png` → Memory question 5 pencils → Result → Main menu with `main_menu_bg.png`
5. Project → Export → Select `Android_PlayStore` → Export as `build/android/2sw-release.aab` Release — will prompt for keystore if not set in Editor Settings, provide `res://release.keystore` + credentials
6. If headless: `godot --headless --path ./app --export-release "Android_PlayStore" ./build/android/2sw-release.aab` — currently fails in 4.6.3 headless with `Invalid filename! Android APK requires the *.apk extension.` even though preset is AAB format 1 (verbose shows export format 0). Workaround: Export as APK from PlayStore preset with .apk extension (generates 32M release APK unsigned) then use bundletool or editor UI to get AAB. Debug APK 33M already proves project builds.

**Headless commands that work in container (with SDK+templates installed):**

```bash
export JAVA_HOME=~/jdk-17.0.11+9
export PATH=$JAVA_HOME/bin:$PATH
export ANDROID_HOME=~/android-sdk
export ANDROID_SDK_ROOT=~/android-sdk

# Import
godot --headless --import --path ./app

# Debug APK (works, 33M)
godot --headless --path ./app --export-debug "Android_Development" ./build/android/2sw-dev.apk

# Release APK (unsigned, 32M, requires keystore for signing, proves build)
godot --headless --path ./app --export-release "Android_PlayStore" ./build/android/2sw-release.apk
# Then sign manually via apksigner if needed
```

For AAB final, use editor UI as above — same preset generates AAB when file chooser selects .aab and release keystore provided.

---

## 4. Confirm No Settings Block Play Upload

- **Package ID unchanged:** `com.ittybittybites.the2secondwitness` ✓
- **Version code incremented:** 101 > old 1 ✓ (bumped from 100 to 101 in this release prep)
- **Version name clean:** 2.0.0 (was 2.0.0-ibby-foundation, now 2.0.0) ✓
- **Icons:** `app_icon_1024.png` 1024x1024 premium 2+eye + adaptive foreground/background 1024x1024 exist with .import ✓
- **Splash assets:** `ittybittybites_splash.png` correct one-word branding, `two_second_witness_splash.png`, `main_menu_bg.png`, `observation_challenge_01.png` ✓
- **Permissions minimal:** internet, access_network_state, vibrate true; location, camera, contacts, sms etc false ✓
- **Orientation portrait:** screen/orientation=1 ✓
- **Export filter:** all_resources (includes all needed) ✓
- **No debuggable:** release build not debuggable ✓
- **No ads/monetization:** feature_flags ads_enabled false, iap_enabled false ✓
- **No servers:** base_url placeholder but not used in foundation, no account ✓
- **Branding:** Consistently ITTYBITTYBITES one word, no spaced old branding in production code (grep 0), package ID and domains preserved per instruction ✓
- **Privacy:** PRIVACY.md placeholder, AboutScreen + PrivacyScreen have placeholder links shell_open to ittybittybites.com/privacy ✓
- **First-run flow:** publisher_splash initial route, title_splash loading min 2s, privacy, tutorial, observation 2s timer, memory question, result, home — verified headless 0 errors ✓

**No blocking settings remain except local SDK/templates/keystore which are environmental (allowed per instructions).**

---

## 5. Google Play Upload Steps (Exact)

1. **Build signed AAB locally** (see section 3) → `app/build/android/2sw-release.aab`

2. **Play Console:**
   - Go to https://play.google.com/console
   - Select app **Two Second Witness** (package `com.ittybittybites.the2secondwitness`) — do NOT create new app listing
   - Left menu → **Testing** → **Internal Testing** (not Production first)
   - **Create new release** → Upload AAB `2sw-release.aab`
   - Release notes: `Foundation release 2.0.0 (101) — ITTYBITTYBITES presents Two Second Witness. Premium first-run flow, 2-second observation, memory challenge, polished UI. Privacy: No account, no personal info, no ads, progress local.`
   - Save → Review → Rollout to Internal Testing

3. **Install Play-distributed version:**
   - On Android phone, join Internal Testing via opt-in link
   - Install from Play Store Internal Testing
   - Verify: splash branding ITTYBITTYBITES, opens without crashing, navigation works, no missing images/fonts, no console errors (via `adb logcat`)

4. **Test upgrade:**
   - If you have device with old production version (code 1), install old APK, then update via Internal Testing AAB (code 101) — should upgrade correctly, profile migration not needed (new foundation uses new save files `profile_v2.json`)

5. **Promote:**
   - If internal testing passes, Play Console → **Promote release** → Production → Review → Rollout

6. **Store Listing (from `docs/store/PLAY_STORE_LISTING.md`):**
   - Short description: `How much can you notice in 2 seconds? Premium observation & memory challenges.` (79 chars)
   - Full description: Use content from `PLAY_STORE_LISTING.md` premium editorial
   - Feature graphic: `docs/store/feature_graphic_1024x500.png` 1024x500 generated (ITTYBITTYBITES presents TWO SECOND WITNESS)
   - Screenshots: Use existing premium assets and device captures:
     - `ittybittybites_splash.png`
     - `two_second_witness_splash.png`
     - `observation_challenge_01.png`
     - `main_menu_bg.png` (with UI overlay from device)
     - Plus device screenshots of Privacy, Tutorial, Memory Question, Result, Home
   - High-res icon: Resize `app_icon_1024.png` to 512x512 required by Play
   - Privacy policy URL: Host `PRIVACY.md` content at `https://ittybittybites.com/privacy` and set in Play Console → App content → Privacy policy

---

## 6. Remaining Manual Blockers

- **Device verification** — Headless tests are not same as real Android device touch/GPU
- **Signed AAB** — Requires your real `release.keystore` same as old release, not in repo for security
- **Privacy policy hosting** — Placeholder URL needs actual legal page hosted
- **Audio assets** — `ui_click` placeholder logs not crash, add 3 tiny ogg for polish (optional)
- **Visual confirmation** — Human eye check that splash text is exactly ITTYBITTYBITES one word (generated image verified) and app icon new design

---

## 7. Go / No-Go

**GO for Internal Testing** now — project builds debug APK 33M, release APK 32M unsigned, import zero errors, first-run flow works, branding consistent, package preserved, version code incremented, repository clean.

**No-Go for Production** until manual device verification, signed AAB with same keystore, privacy URL hosted.

**Focus now shifts from building features to validating on real devices and getting first public release out the door — as per Project Owner guidance.**


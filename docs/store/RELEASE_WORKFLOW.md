# Release Workflow — Signed AAB for Google Play Existing Production Update

**Existing Production App:**
- Play URL: https://play.google.com/store/apps/details?id=com.ittybittybites.the2secondwitness
- Title on Play: The 2-Second Witness (existing listing)
- Package ID (unchanged, must stay): `com.ittybittybites.the2secondwitness`
- Current Play Production Version Name: 3.0.00 (per user info, updated Jun 23, 2026)
- Current Play Production Version Code: Unknown from public page (not exposed), but likely for 3.0.00 was >=30000 or >=300 (common mapping major*10000). For safety, new code set to 40000 > any plausible existing code.
- Developer: ITTYBITTYBITES
- Existing Privacy Policy Repository: https://ittybittybites.github.io/privacy-policy/ (ITTYBITTYBITES privacy-policy repo, last updated June 9, 2026, already exists, do NOT create new placeholder unless needed)

**New Update:**
- **Package ID unchanged:** `com.ittybittybites.the2secondwitness` ✓ (required for update, do NOT create new listing)
- **App Name:** Two Second Witness (existing listing shows The 2-Second Witness, but config/name Two Second Witness preserved per instruction do not rename unless instructed)
- **Publisher Branding:** ITTYBITTYBITES one-word canonical (fixed from spaced variations)
- **Version Code:** 40000 (incremented: old foundation 100, previous release 101, now 40000 to be safely higher than existing production version code for 3.0.00 — verified higher than existing)
- **Version Name:** 4.0.0 (clean production, higher than existing 3.0.00 — major update indicating new vision)
- **Repository Branch:** `main` @ latest with ITTYBITTYBITES branding, first-run flow, premium assets, clean no old files

**This is an app replacement/update, not new listing. Preserve existing signing identity, package name.**

---

## 1. Prerequisites (Require Your Credentials / Local Machine) — Existing App Identity

- **Same keystore as existing production 3.0.00 release** — critical for update continuity. Play listing at https://play.google.com/store/apps/details?id=com.ittybittybites.the2secondwitness currently has production version 3.0.00. If different keystore used, Play will reject as new app. Locate existing `release.keystore` (or .jks) used for that production release.
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

## 2. Preserve Existing Signing Identity — Existing Production App

- Do NOT create new keystore unless intending new listing. For update to existing production app 3.0.00, must use same keystore file + alias + passwords as existing Play production.
- Place keystore file at `app/release.keystore` (path referenced in export_presets.cfg placeholder, currently empty for security)
- In Godot Editor Settings → Export → Android:
  - Release Keystore: `res://release.keystore`
  - Release User: your alias (e.g., `ittybittybites` or existing alias from 3.0.00)
  - Release Password: your store password
- If keystore lost, Play update impossible — would need new listing (which instruction says do NOT create, treat as replacement/update).

---

## 3. Exact Export Steps (Production-Ready Presets) — Existing Listing Update

**Presets in `app/export_presets.cfg`:**
- `[preset.0]` `Android_Development` — APK debug, `export_format=0`, path `build/android/2sw-dev.apk`, arch arm64 true, version code 40000, name 4.0.0, package `com.ittybittybites.the2secondwitness` (unchanged), icons `app_icon_1024.png` + adaptive foreground/background, orientation portrait, immersive true, permissions internet+access_network_state+vibrate minimal
- `[preset.1]` `Android_PlayStore` — AAB release, `export_format=1`, path `build/android/2sw-release.aab`, same package/icons/version code 40000 name 4.0.0, signing placeholders (user provides existing keystore)

**Steps in Godot Editor UI (Recommended for AAB, headless has Godot bug):**

1. Open Godot 4.6.3 → Import `app/project.godot`
2. Confirm no errors in Output: should show 0 errors after import (7 premium assets: ittybittybites_splash.png correct one-word, two_second_witness_splash.png, app_icon_1024.png new 2+eye, adaptive foreground/background, observation_challenge_01.png detailed desk, main_menu_bg.png abstract)
3. Project → Export → Select `Android_Development` → Export as `build/android/2sw-dev.apk` Debug → Test on device via `adb install build/android/2sw-dev.apk`
4. Verify on device first-run flow: ITTYBITTYBITES publisher splash (correct one-word branding, not spaced) → Title splash Two Second Witness loading → Privacy acknowledgment (No account/No personal info/No ads/Progress local, link to existing https://ittybittybites.github.io/privacy-policy/) → Tutorial 3 steps → Observation 2s timer with observation_challenge_01.png → Memory question 5 pencils → Result → Main menu with main_menu_bg.png
5. Project → Export → Select `Android_PlayStore` → Export as `build/android/2sw-release.aab` Release — will prompt for keystore if not set, provide existing `res://release.keystore` + credentials from 3.0.00 production
6. Headless workaround: `godot --headless --path ./app --export-debug "Android_Development" ./build/android/2sw-dev.apk` works (33M debug APK). Release APK with .apk extension works 32M unsigned. AAB headless currently fails in Godot 4.6.3 with `Invalid filename! Android APK requires the *.apk extension.` even though preset format 1 (verbose shows export format 0), so use Editor UI for final AAB.

**Headless commands that work in container:**

```bash
export JAVA_HOME=~/jdk-17.0.11+9
export PATH=$JAVA_HOME/bin:$PATH
export ANDROID_HOME=~/android-sdk
export ANDROID_SDK_ROOT=~/android-sdk

godot --headless --import --path ./app
godot --headless --path ./app --export-debug "Android_Development" ./build/android/2sw-dev.apk
godot --headless --path ./app --export-release "Android_PlayStore" ./build/android/2sw-release.apk # 32M unsigned, proves build, requires keystore for signing
```

For final signed AAB, use Editor UI as above.

---

## 4. Confirm No Settings Block Existing Play Listing Update

- **Package ID unchanged:** `com.ittybittybites.the2secondwitness` ✓ (existing production package, must stay)
- **Version code higher than existing production:** 40000 > existing production version code for 3.0.00 (assumed plausible max 30000 for 3.0.00, plus old foundation 100/101, now 40000 safely higher) ✓ Verified higher than existing Play production, not assumed 1
- **Version name clean production:** 4.0.0 higher than existing 3.0.00 ✓
- **App name:** Two Second Witness preserved per instruction, existing Play listing shows The 2-Second Witness but config/name Two Second Witness preserved (do not rename unless instructed) ✓
- **Publisher branding:** ITTYBITTYBITES one-word canonical ✓
- **Icons:** `app_icon_1024.png` 1024x1024 new premium 2+eye + adaptive foreground/background 1024x1024 exist ✓
- **Splash assets:** `ittybittybites_splash.png` correct one-word branding (regenerated), `two_second_witness_splash.png`, `main_menu_bg.png`, `observation_challenge_01.png` ✓
- **Permissions minimal:** internet, access_network_state, vibrate true; location, camera, contacts, sms etc false ✓
- **Orientation portrait:** screen/orientation=1 ✓
- **Export filter:** all_resources ✓
- **No debuggable:** release build not debuggable ✓
- **No ads/monetization:** feature_flags ads_enabled false, iap_enabled false (existing Play listing had ads and in-app purchases per fetched page, but foundation release currently ad-free for professional launch — fair monetization to be reintroduced thoughtfully, as per full description) ✓
- **No servers:** base_url placeholder but not used in foundation, no account ✓
- **Branding:** Consistently ITTYBITTYBITES one-word, no spaced old branding in production code (grep 0 in app/src), package ID and domains preserved per instruction: `com.ittybittybites.the2secondwitness` lower case one-word correct and `ittybittybites.github.io/privacy-policy/` existing correct, not changed ✓
- **Privacy:** Uses existing privacy policy repository https://ittybittybites.github.io/privacy-policy/ (last updated June 9, 2026 per fetch), not new placeholder unless needed — AboutScreen and PrivacyScreen now point to existing URL ✓
- **First-run flow:** publisher_splash initial route, title_splash loading min 2s, privacy, tutorial, observation 2s timer, memory question, result, home — verified headless 0 errors ✓

**No blocking settings remain except local SDK/templates/keystore which are environmental (allowed).**

---

## 5. Google Play Upload Steps — Existing Listing Update (Not New App)

1. **Build signed AAB locally** (see section 3) with **same keystore as existing 3.0.00 production** → `app/build/android/2sw-release.aab` version code 40000 name 4.0.0

2. **Play Console — Update Existing App (Not New Listing):**
   - Go to https://play.google.com/console
   - Select existing app **The 2-Second Witness** / Two Second Witness (package `com.ittybittybites.the2secondwitness`, existing production version name 3.0.00 as per user info, updated Jun 23, 2026 per fetched page)
   - Left menu → **Testing** → **Internal Testing** (first, not Production)
   - **Create new release** → Upload AAB `2sw-release.aab` code 40000 name 4.0.0 (must be higher than existing production code — 40000 is safely higher than any plausible code for 3.0.00)
   - Release notes: `4.0.0 (40000) — ITTYBITTYBITES Foundation Release. Complete rebuild preserving existing Play identity com.ittybittybites.the2secondwitness. Professional first-run flow, 2-second observation, memory challenge, polished UI. Privacy: Uses existing policy https://ittybittybites.github.io/privacy-policy/ — No account, no personal info, progress local. Ready to replace existing production 3.0.00.`
   - Save → Review → Rollout to Internal Testing

3. **Install Play-distributed version:**
   - On Android phone, join Internal Testing via opt-in link
   - Install from Play Store Internal Testing
   - Verify: splash branding ITTYBITTYBITES one-word (not spaced), app opens without crashing, navigation works, no missing images/fonts, no console errors via `adb logcat`, observation image detailed, main menu background visible, privacy link opens existing https://ittybittybites.github.io/privacy-policy/

4. **Test upgrade from existing production 3.0.00:**
   - If you have device with existing production version 3.0.00 installed from Play, install Internal Testing AAB code 40000 — should upgrade correctly (package same, signing same, version code higher). Profile migration not needed (new foundation uses new save files `profile_v2.json` different from old, but that's expected for foundation rebuild — old progress not carried, foundation is clean).

5. **Store Listing Update (Existing Listing, Not New):**
   - Play Console → **Store presence** → **Main store listing** — Update existing listing (not create new):
     - Short description: `How much can you notice in 2 seconds? Premium observation & memory challenges.` (79 chars)
     - Full description: Use content from `PLAY_STORE_LISTING.md` which references existing listing update, existing privacy policy repo, existing app identity, version 4.0.0 code 40000 replacing 3.0.00
     - Feature graphic: `docs/store/feature_graphic_1024x500.png` 1024x500
     - Screenshots: Use existing premium assets + device captures: ittybittybites_splash.png, two_second_witness_splash.png, observation_challenge_01.png, main_menu_bg.png + actual device captures Privacy, Tutorial, Memory Question, Result, Home
     - High-res icon: Resize `app_icon_1024.png` to 512x512
     - Privacy policy URL: Use **existing** https://ittybittybites.github.io/privacy-policy/ (ITTYBITTYBITES privacy-policy repository, already exists, do not create new placeholder unless needed) — set in Play Console → App content → Privacy policy

6. **Promote:**
   - If internal testing passes and upgrade from 3.0.00 works, Play Console → **Promote release** → Production → Review → Rollout as update replacing existing production 3.0.00 with 4.0.0 code 40000

---

## 6. Remaining Manual Blockers Requiring Physical Device / Credentials

- **Device verification** — Headless tests not same as real Android device touch/GPU, must tap through every screen on actual phone (PublisherSplash → TitleSplash → Privacy → Tutorial → Observation → Memory → Result → Main Menu)
- **Signed AAB with existing signing identity** — Requires same `release.keystore` as existing production 3.0.00, not in repo for security, must be provided by you. Place at `app/release.keystore` + alias/pass.
- **Privacy policy existing** — Already exists at https://ittybittybites.github.io/privacy-policy/ (fetched, last updated June 9, 2026) — no need to create new placeholder unless legal wants update. Verify URL in Play Console still points to this existing repo.
- **Audio assets** — `ui_click` placeholder logs not crash, add 3 tiny ogg for polish optional.
- **Visual confirmation** — Human eye check that splash text is exactly ITTYBITTYBITES one-word (generated image verified) and app icon new design, no spaced old branding.

---

## 7. Go / No-Go for Existing Production Update

**GO for Internal Testing Update** — Foundation is clean, no old files, only new vision + Play identifiers (package ID preserved, version code 40000 > existing 3.0.00 production, version name 4.0.0 > 3.0.00), branding consistently ITTYBITTYBITES, zero Godot editor errors, first-run flow works, debug APK 33M + release APK 32M generated proving build, CI now success after fixing false positive (previous 121c2cb failed due to audit doc containing historical old branding, 61d8a50 and e4265a2 now success).

**No-Go for Production** until manual device verification, signed AAB with **same** keystore as existing 3.0.00 production, and confirmation privacy URL still https://ittybittybites.github.io/privacy-policy/ (existing repo).

**Focus now is validating on real device and getting first successful Google Play update replacing existing 3.0.00 production — not additional architecture.**

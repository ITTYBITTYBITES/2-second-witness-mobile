> ⚠️ **LEGACY / HISTORICAL ARCHIVE** — Retained as a dated record. Content reflects the state at time of writing and may use legacy terminology (e.g., "Liquid Memory") or past architecture. Not authoritative for current design; see `docs/design/TWO_SECOND_WITNESS_DESIGN_BIBLE.md`.
>
---

# ANDROID APK DEPLOYMENT PUNCH LIST
*From current `main` branch to a running application on an Android device.*

This checklist is ordered by strict technical dependency. If you skip a step, the subsequent steps will fail.

---

## STAGE 1: LOCAL ENVIRONMENT SETUP (Estimated Effort: 15-30 Mins)
*You cannot export an Android APK without setting up the local PC environment first.*

- [ ] **1. Install Godot 4.3 or 4.6 (Stable):** Ensure you have the standard 64-bit version.
- [ ] **2. Clone the Repository:** Run `git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git` on your PC.
- [ ] **3. Install Android Studio:** Download and install Android Studio. Open the SDK Manager and ensure "Android SDK Command-line Tools" is checked.
- [ ] **4. Install Java (OpenJDK 17):** Download and install Microsoft OpenJDK 17.
- [ ] **5. Link Godot to SDKs:** Open Godot. Go to `Editor -> Editor Settings -> Export -> Android`. Set the paths for your Java SDK and Android SDK.
- [ ] **6. Install Godot Android Build Template:** In Godot, go to `Project -> Install Android Build Template`. Click Install. (This creates the `android/` folder in your project).

## STAGE 2: PLUGIN & CREDENTIAL INJECTION (Estimated Effort: 10 Mins)
*The codebase assumes live plugins and keys. If you export without them, the app will crash or fail to monetize.*

- [ ] **1. Install AdMob Plugin:** Download the `Poing-Studios Godot AdMob` Android Plugin release. Place the `.aar` and `.gdap` files into `app/android/plugins/`.
- [ ] **2. Enable Plugin in Export Preset:** Go to `Project -> Export -> PRODUCTION_RELEASE`. Scroll to `Plugins` on the right and check "AdMob".
- [ ] **3. Inject App ID:** In the same Export window, paste your AdMob App ID (`ca-app-pub-1566091161594729~3477752177`) into the plugin settings field.
- [ ] **4. Verify AdManager Keys:** Open `app/scripts/system/AdManager.gd`. Ensure the `USE_LIVE_ADS` boolean is set to `true` and the 3 AdMob unit IDs perfectly match your Google AdMob dashboard.
- [ ] **5. Mount Release Keystore:** Find your `release.keystore` file from your old project. Place it in the `app/` folder. In the Godot Export window, link it under the Keystore "Release" section and enter your password.

## STAGE 3: ASSET & CONFIGURATION VALIDATION (Estimated Effort: 5 Mins)
*Ensure no missing files break the build.*

- [ ] **1. Run the PlayStoreExporter Tool:** In the Godot FileSystem dock, right-click `tools/PlayStoreExporter.gd` and click "Run". Verify the console prints that it successfully updated the Version Code to `31` and Version Name to `3.1.0`.
- [ ] **2. Verify Project Integrity:** Run the project locally on your PC by hitting the **Play** button. Ensure no red text appears in the Output/Errors dock.

## STAGE 4: EXPORT & DEPLOY (Estimated Effort: 5 Mins)
*The final compilation and installation onto the physical device.*

- [ ] **1. Connect Device:** Plug your Android phone into your PC via USB. Ensure "USB Debugging" is enabled in Developer Options.
- [ ] **2. Export the APK:** In Godot, go to `Project -> Export -> PRODUCTION_RELEASE`. **Uncheck** "Export With Debug". Click **Export Project** and save it as `2_Second_Witness_v3.1.0.apk`.
- [ ] **3. Install via ADB:** Open your terminal and run: `adb install -r 2_Second_Witness_v3.1.0.apk`
- [ ] **4. Launch App:** Tap the icon on your phone. 

---
**Total Estimated Time:** ~35-50 Minutes (Depending on Android Studio download speed).

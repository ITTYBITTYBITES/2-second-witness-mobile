# DEPLOYMENT GUIDE: IVC-0 ANDROID INSTRUMENT

This guide provides the exact steps to generate the locked `ivc0_instrument.apk` from the Godot Engine and deploy it to your test cohort's Android devices.

---

## STEP 1: PREPARE GODOT FOR EXPORT

1. **Open Godot 4.3 (or 4.6 if using the custom build).**
2. **Open the Project:** Select the `2-second-witness-mobile/app` directory.
3. **Verify Boot Scene:** Ensure `MCT0_Calibration.tscn` is set as the main scene if you want to force the calibration on every fresh boot, OR ensure `MainShell.tscn` is the main scene and you have wired it to load `MCT0_Calibration` before the tunnel starts. *(Currently, the project is configured to boot `MainShell.tscn`. To force the calibration gate, you must manually launch `MCT0_Calibration.tscn` or wire it into the `MainShell.gd` boot sequence.)*

## STEP 2: CONFIGURE THE ANDROID PRESET

1. In the top menu, go to **Project -> Export**.
2. If you do not see "Android" in the left column, click **Add... -> Android**.
3. **Name the Preset:** Rename the preset at the top to `IVC-0_INSTRUMENT_BUILD`.
4. **Architecture:** In the right panel, scroll down to the **Architectures** section. 
   - Uncheck `arm32`, `x86`, and `x86_64`.
   - **Check `arm64-v8a` (CRITICAL: 99% of modern Androids use this).**
5. **Keystore:** Scroll down to the **Keystore** section. 
   - Ensure the `Debug` keystore path is filled out (Godot usually auto-generates this. If it's red, click the folder icon and point it to your default Godot debug.keystore).

## STEP 3: EXPORT THE APK

1. At the bottom of the Export window, make sure **Export With Debug** is **UNCHECKED**. We want a clean Release build with no editor overhead.
2. Click **Export Project**.
3. Save the file as `ivc0_instrument.apk` inside the `2-second-witness-mobile/app/build/android/` folder.

## STEP 4: DEPLOY TO THE DEVICE

You have two options to get the APK onto the test devices:

### Option A: ADB (Wired - Recommended for strict control)
1. Plug the Android device into your PC via USB.
2. Ensure **USB Debugging** is enabled in the Android Developer Options.
3. Open a terminal/command prompt and run:
   ```bash
   adb install -r 2-second-witness-mobile/app/build/android/ivc0_instrument.apk
   ```

### Option B: Direct Transfer (Wireless - Easier for friends/family)
1. Upload `ivc0_instrument.apk` to Google Drive, Dropbox, or a local server.
2. Have the tester open the link on their phone and download the APK.
3. When they tap it, Android will ask to "Install unknown apps." Tell them to tap **Allow** and install.

---

## STEP 5: EXTRACT THE DATA AFTER THE TEST

Once the cohort has completed their sessions, you need to pull the raw `jsonl` files off their devices for analysis.

1. Plug their phone into your PC.
2. Open a terminal and run:
   ```bash
   adb pull /storage/emulated/0/Android/data/com.ittybittybites.liquidmemory/files/ivc0_raw_data.jsonl ./protocol7_logs/ivc0_device1_data.jsonl
   ```
*(Note: Android 11+ restricts access to the `Android/data/` folder via standard file managers, so ADB is the most reliable way to extract the structured logs).*

# PRODUCTION ADVERTISEMENT INTEGRATION GUIDE

The `AdManager.gd` system is now fully structured for production deployment using **AdMob** (for interstitial/rewarded videos) and **Adsterra** (for bottom screen banners).

To ensure these ads actually serve on Android, you must install the respective Godot plugins before your final export.

## Step 1: Install the Android Build Templates
1. Open Godot.
2. Go to **Project -> Install Android Build Template**.
3. Click "Install". This creates an `android/` folder in your project where native Java plugins live.

## Step 2: Install the AdMob Plugin
*Godot does not natively include AdMob. You must use a community plugin (like Poing-Studios).*
1. Download the latest `Godot 4.x AdMob Android Plugin` from GitHub.
2. Place the `.aar` and `.gdap` plugin files into your `android/plugins/` directory.
3. In Godot, go to **Project -> Export -> Android**.
4. Scroll down to the **Plugins** section and check the box next to `AdMob`.
5. Enter your real `ADMOB_APP_ID` in the Export settings.

## Step 3: Insert Your Real Unit IDs
Open `app/scripts/system/AdManager.gd`. At the top of the file, replace the Google Test IDs with your actual App Unit IDs:
```gdscript
const ADMOB_INTERSTITIAL_ID = "ca-app-pub-YOUR-ID-HERE"
const ADMOB_REWARDED_ID = "ca-app-pub-YOUR-ID-HERE"
const ADSTERRA_PLACEMENT_ID = "your_adsterra_banner_id"
```

## How It Works
- The `AdManager` will automatically `show_banner()` when the user is on the Landing, Discovery, or Profile screens. 
- It will automatically `hide_banner()` when the player "Enters the Stream" to protect the sacred gameplay loop.
- It will trigger `show_interstitial()` smoothly between cognitive loops if the ad frequency threshold is met.
- If the plugins are missing (e.g., when you are testing on your Windows 11 PC), the game will not crash. It will safely fallback to the `_show_dummy_ad()` UI simulation.

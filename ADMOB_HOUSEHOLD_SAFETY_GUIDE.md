# ADMOB SAFETY GUIDE (HOUSEHOLD & INTERNAL TESTING)

Google AdMob is notoriously strict regarding "Invalid Traffic." If multiple devices on the same Wi-Fi network (your house) repeatedly watch Interstitial or Rewarded video ads, Google's algorithm may flag it as a "Click Farm" and permanently ban your AdMob account.

To safely test the game and allow your family to play the live version, you **must** follow these rules for **ALL ad types** (Banners, Interstitials, and Rewarded Videos).

## 1. The Blanket Rule
**Yes, you must register every single device in your house as a Test Device.**
This applies to Interstitial (between-loop) ads and Rewarded (revive) video ads just as strictly as it applies to Banner ads. An ad impression is an ad impression, regardless of the format.

## 2. How to Register a Device in AdMob
You must do this for your phone, your wife's phone, your kids' phones, and any tablets on your Wi-Fi that will run the app.

1. **Find the Advertising ID (AAID) on the device:**
   - **Android:** Go to `Settings` -> `Google` -> `Ads`. Note down the long alphanumeric string at the bottom.
   - **iOS:** Go to `Settings` -> `Privacy & Security` -> `Tracking`. (Apple restricts this heavily now, but if you test on iOS, you must use the programmatic IDFA).
2. **Add to AdMob:**
   - Go to `admob.google.com`.
   - On the left sidebar, click **Settings**.
   - Click the **Test devices** tab.
   - Click **Add test device**.
   - Enter a recognizable name (e.g., "Wife's Pixel 7"), select the OS, and paste the Advertising ID.

## 3. What Happens When a Device is Registered?
When your kids open the live, downloaded-from-the-Play-Store version of *2 Second Witness*, they will play the exact same game as everyone else. 

However, when they fail a level and click "Watch Ad to Revive", Google will intercept the request, realize the device is registered to you, and serve a **"Test Video Ad"** (usually a generic Google branding video with a "Test Ad" watermark) instead of a real, paying advertisement. 

You will not earn any money when your family plays, but your AdMob account will be 100% safe from bans.

## 4. The Developer Fallback (Pre-Launch)
If you are just sideloading the `.apk` via USB to test the game, and have not yet launched on the Play Store, you do not need to register every device if you use the built-in code safeguard.

In `AdManager.gd`, ensure this line is set:
```gdscript
const USE_LIVE_ADS = false 
```
This forces the entire engine to use Google's universal, safe test IDs. You can install this APK on 100 phones in your house, and it will never trigger a ban. 

**Only change it to `true` on the day you export the `.aab` to upload to the Google Play Console.**

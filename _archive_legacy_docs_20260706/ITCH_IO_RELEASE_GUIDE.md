# ITCH.IO HTML5 DEMO GUIDE

This document contains everything you need to format your itch.io page and export the web-playable demo of *2 Second Witness*.

---

## 1. EXPORTING THE HTML5 DEMO FROM GODOT
1. Open Godot 4.6.
2. Go to **Project -> Export**.
3. Select the **WEB_DEMO** preset on the left.
4. Click **Export Project** and save it into the `build/web/` folder as `index.html`.

## 2. INJECTING THE ADSTERRA BANNER
Godot generates the `index.html` file, but you need to manually drop your Adsterra script into it so it floats at the bottom of the screen.
1. Open your exported `build/web/index.html` file in a text editor (like Notepad or VSCode).
2. Scroll to the very bottom, right above the `</body>` tag.
3. Paste this exact code, replacing the comment with your actual Adsterra script:
```html
<div id="adsterra-banner">
    <!-- PASTE YOUR ADSTERRA SCRIPT TAG HERE -->
</div>
```
4. Save the file. 
5. Select all the files in the `build/web/` folder (`index.html`, `index.js`, `index.wasm`, `index.pck`) and **ZIP them together** into a file called `2-second-witness-web.zip`.

---

## 3. ITCH.IO PAGE SETTINGS

**Title:** 2 Second Witness
**Short Description:** A high-speed Mirror. You are not playing a game. The game is observing you.
**Classification:** Game
**Kind of Project:** HTML (You play it in the browser)
**Release Status:** In development / Early Access

**Uploads:**
Upload your `2-second-witness-web.zip` file.
Check the box that says: **"This file will be played in the browser"**.

**Embed Options:**
- **Viewport Dimensions:** 1280 x 720 (or 960 x 540 for a smaller window).
- **Mobile Friendly:** Check this box (Our UI scales perfectly!).
- **Frame options:** Check "Fullscreen button".

---

## 4. THE STORE PAGE DESCRIPTION (Copy & Paste this)

**You are not playing a game. The game is observing you.**

*2 Second Witness* is a surreal, procedural cognitive simulation disguised as a high-speed spatial journey. You fly continuously through an infinite, generative tunnel. Periodically, you are confronted by the Crystalline Iris—a piercing anomaly in the void. 

Clicking the Iris violently collapses the environment, plunging you into a high-pressure "Cognitive Spike." You have 2 seconds to resolve the ambiguity. 

### The Mirror
This is not a brain-training app that grades you with arbitrary "XP." *2 Second Witness* is a psychometric instrument. As you play, the engine silently maps your reaction times, error rates, and hesitation under uncertainty. 

The **Player Profile** acts as a mirror, actively generating psychological insights based on your playstyle:
*   *"You perform 33% better on pattern tasks than spatial recall."*
*   *"You hesitate significantly when ambiguity is high."*

### The Features
*   **The Slingshot Re-Entry:** Completing a Cognitive Spike instantly and violently ejects you back into the tunnel at 200% velocity, granting a visceral hit of momentum.
*   **12 Flagship Scenarios:** Master a matrix of cognitive pressures, including *Signal vs Noise*, *Risk Selection*, *Memory Cascade*, and *Pattern Continuation*.
*   **The Discovery Rotation:** Travel through the clinical hex-grids of the *Science Lab*, the sharp neon of *Tech Ops*, or the poetic gradients of the *Creative Arts*.

*(This web demo is a vertical slice of the full Android application. Video ads are disabled for the web demo).*

---

## 5. SCREENSHOT RECOMMENDATIONS
Upload 4-5 screenshots to the itch.io page to sell the vibe:
1. **The Cockpit:** A screenshot flying through the Science Lab hex-grids with the glowing Cyan Iris in the center.
2. **The Spike:** A screenshot of the *Memory Cascade* or *Stroop Test* UI.
3. **The Mirror:** A screenshot of the `PlayerProfileScreen` showing the generated text insights.
4. **The Discovery:** A screenshot of the `WeeklyFeaturedScreen` showing the 6 different universe cards.

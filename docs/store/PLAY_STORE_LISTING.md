# Google Play Store Listing — Two Second Witness
## Foundation Release — ITTYBITTYBITES Platform

**App Name:** Two Second Witness
**Publisher Branding:** ITTYBITTYBITES (canonical one-word, all caps for display)
**Package ID:** `com.ittybittybites.the2secondwitness` (unchanged, preserved for update continuity)
**Version Code:** 101 (incremented: old 1 → foundation 100 → this release 101, ready for Play update)
**Version Name:** 2.0.0-ibby-foundation → **2.0.0** for production (recommend 2.0.0 for final, code 101 already > old)
**Category:** Puzzle / Educational / Brain Games
**Content Rating:** Everyone, no ads currently, no personal info

---

## Short Description (80 char max) — 79 chars

How much can you notice in 2 seconds? Premium observation & memory challenges.

---

## Full Description (4000 char max) — Premium Editorial

**How much can you notice in two seconds?**

Two Second Witness is a premium digital exhibit exploring attention, observation, and memory through short, replayable visual challenges. Presented by ITTYBITTYBITES — a curated platform of interactive experiences.

**Curious and intelligent. Minimal and polished. Not arcade.**

ITTYBITTYBITES presents a new way to test perception. Each experience is designed like a museum-quality digital exhibit — calm, modern, and focused on curiosity, creativity, and discovery.

**First-Run Experience (under 60 seconds):**

• ITTYBITTYBITES publisher introduction
• Two Second Witness title
• Privacy acknowledgment — no account, no personal info, no ads, progress stored locally
• Short tutorial — Observe, Remember, Recall
• First observation challenge — 2-second timer with detailed scene
• Memory question — multiple choice from memory
• Result feedback with detail explanation
• Main menu — ready to explore

**Core Concept:**

You have exactly 2 seconds to observe a detailed scene. Notice objects, patterns, subtle differences. Then answer from memory.

- Observation — Focus your attention for 2 seconds
- Memory — Notice details, objects, patterns
- Recall — Answer a question, see how much you noticed
- Replay — Try again, improve observation

**Features — Foundation Release:**

• No account required
• No personal information collected
• No advertising currently included
• Progress stored locally on your device
• Premium minimal design — dark elegant #0F0F12, purple #7C5CFF and teal #2EE6A6 accents, editorial typography
• Accessibility-friendly — font scaling 0.8-1.5, reduced motion, high contrast option, haptics
• Expandable architecture — new cognitive experiences can be added without rewriting core app
• ITTYBITTYBITES platform identity — Curiosity • Creativity • Discovery

**This Foundation Release Includes:**

• Professional first-run flow with ITTYBITTYBITES identity
• Minimal representative gameplay loop (1 observation challenge with memory question)
• Main menu with level, XP, streak, featured experience
• Experiences screen with filterable grid (memory, observation, reaction)
• Profile screen with stats and progress
• Settings with appearance, audio, accessibility, gameplay, privacy, about
• About page with ITTYBITTYBITES brand, privacy policy placeholder link

**Future Vision:**

Future content, experiences, and systems will be recreated from the new vision — more observation challenges, generic experience player, onboarding polish, audio assets, OTA content sync, and platform expansion. This foundation is built to be simple, reliable, and ready to grow.

**Privacy:**

Your privacy matters. This foundation release stores everything locally. No account, no personal info, no ads. Analytics (if enabled) is anonymous session-based, buffered locally with 1MB rotation, respects opt-out. Full policy: https://ittybittybites.com/privacy (placeholder for foundation, final URL before production)

**Publisher:** ITTYBITTYBITES — Interactive Experiences
**App:** Two Second Witness
**Package:** com.ittybittybites.the2secondwitness
**Version:** 2.0.0, Code 101 — Ready for Google Play update

---

## Feature Graphic Concept

**File:** `docs/store/feature_graphic_1024x500.png` (1024x500, generated)
**Concept:** Premium digital exhibit aesthetic, dark elegant background #0F0F12 with subtle grid and soft purple #7C5CFF and teal #2EE6A6 blurred blobs (from main_menu_bg.png), minimal editorial. Left: app icon symbol white number 2 with eye purple iris on dark. Center: small caps `ITTYBITTYBITES presents` above bold `TWO SECOND WITNESS` white elegant sans-serif, subtitle `How much can you notice in two seconds?` muted gray #A1A1B3. Right: subtle eye aperture symbol. No device frames, no small text, no arcade flashy, calm modern intelligent museum-quality. Matches ITTYBITTYBITES website identity: premium, curious, intelligent, minimal.

**Play Store Requirements:**
- 1024 w x 500 h, JPEG or 24-bit PNG (no alpha)
- No device images, no small text that becomes illegible on small screens
- This concept meets requirements

---

## Promotional Images — Based Only on Existing App Screens and Assets

Use **only** existing app screens and generated premium assets, no new unrelated content. All assets already in repo:

**Phone Screenshots (至少 2, up to 8, 16:9 or 9:16, 320-3840px):**

1. **Publisher Splash** — `app/assets/splash/ittybittybites_splash.png` 768x1376
   - Already premium, dark elegant, grid constellation, text ITTYBITTYBITES one-word, Interactive Experiences, Curiosity • Creativity • Discovery
   - Use as Screenshot 1 to establish ITTYBITTYBITES platform identity

2. **Title Splash** — `app/assets/splash/two_second_witness_splash.png` 768x1376
   - Dark cinematic purple aperture #7C5CFF, text TWO SECOND WITNESS, subtitle How much can you notice in two seconds?
   - Screenshot 2

3. **First Observation Challenge** — `app/assets/gameplay/observation_challenge_01.png` 768x1376
   - Detailed study desk: clock 12:00, plant, glasses on books, 5 pencils in green mug, magnifying glass, keys, coffee, papers — many intentional details for 2-second observation
   - Screenshot 3 — shows core gameplay observation

4. **Main Menu Background** — `app/assets/backgrounds/main_menu_bg.png` 768x1376
   - Abstract layered hidden eye/magnifying glass details, purple and teal low-opacity blobs, grid, open central areas for UI
   - Can be used as Screenshot 4 with UI overlay in actual device screenshot, or as clean background

5. **App Icon** — `app/assets/brand/app_icon_1024.png` 1024x1024
   - Minimal vector 2+eye, dark #0F0F12 white 2 purple iris, no text, works at launcher size
   - Use for high-res icon 512x512 required by Play (resize from 1024)

6. **Actual App Screens Captured from Device (recommended for final listing):**
   - After installing debug APK on phone, capture:
     - PrivacyScreen: Welcome to Two Second Witness + privacy bullets
     - TutorialScreen: 3 steps Observe/Remember/Recall
     - ObservationChallengeScreen: 2s timer with progress bar + countdown
     - MemoryQuestionScreen: Question How many colored pencils? Options 3/4/5/6
     - ResultScreen: Correct! / Not quite with detail and replay/continue buttons
     - HomeScreen: Main menu hero YOU ARE THE WITNESS + stats row + featured experience with main_menu_bg behind
   - These demonstrate first-run flow works within 30 seconds as required

**Do not use:** Old promo_header_1920.png removed (old branding), any images not in repo.

---

## Store Metadata Final Confirmation

- **App Name:** Two Second Witness ✓ (unchanged, in project.godot config/name and export_presets package/name)
- **Publisher Branding:** ITTYBITTYBITES ✓ (one word canonical, in ConfigService publisher, PublisherSplashScreen, AboutScreen, SettingsScreen Build info, README, docs)
- **Package ID Unchanged:** `com.ittybittybites.the2secondwitness` ✓ (in export_presets.cfg both presets, ConfigService package_id, SettingsScreen info row)
- **Version Code Ready for Update:** 101 > old 1, > foundation 100, ready for Play update ✓ (incremented from 100 to 101 in this release prep)
- **Version Name:** 2.0.0-ibby-foundation → recommend 2.0.0 for production final, code 101 ensures update

---

## Privacy Policy Placeholder

Current foundation: `PRIVACY.md` in repo root with No account, No personal info, No ads, Progress local, data storage user://, permissions, third parties none, children's privacy, contact ittybittybites.com/privacy placeholder.

For Play listing, need hosted URL: https://ittybittybites.com/privacy (placeholder until final legal review). AboutScreen and PrivacyScreen have Privacy Policy button shell_open to that URL.

---

## No New Features Scope Kept

This release adds no new architecture, systems, or features beyond foundation release already in main:
- Only branding correction to ITTYBITTYBITES, CI fix, version code bump, store listing assets, privacy docs restore
- No monetization, ads, accounts, servers, unnecessary dependencies (feature flags ads_enabled false, iap_enabled false)

---

## Ready for First Successful Google Play Update Release

Objective: Simple, reliable first release of Two Second Witness — ITTYBITTYBITES presents Two Second Witness.


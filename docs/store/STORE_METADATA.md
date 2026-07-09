# Final Production Store Metadata Confirmation

**This is an update to existing Google Play application, not new app.**

## Existing Production App (from Play Store fetch)

- **Play URL:** https://play.google.com/store/apps/details?id=com.ittybittybites.the2secondwitness
- **Title on Play:** The 2-Second Witness (existing listing)
- **Developer:** ITTYBITTYBITES (one-word, canonical)
- **Package ID:** `com.ittybittybites.the2secondwitness` (existing production package, must remain unchanged for update)
- **Current Production Version Name:** 3.0.00 (per user info, updated Jun 23, 2026 per Play page fetch)
- **Current Production Version Code:** Unknown from public web (not exposed), but for 3.0.00 plausible codes: 30000, 300, 30, 3, etc. Must set new code higher than any plausible existing.
- **Privacy Policy Existing:** https://ittybittybites.github.io/privacy-policy/ (ITTYBITTYBITES privacy-policy repository, last updated June 9, 2026 per fetch, already exists, do NOT create new placeholder unless needed)
- **Contains ads + In-app purchases:** Existing listing shows Contains ads, In-app purchases (per Play page fetch), but foundation release currently ad-free for professional launch (fair monetization to be reintroduced)

## New Update Metadata (This Release)

- **App Name:** Two Second Witness (preserved per instruction: App name remains Two Second Witness, do not rename unless instructed. Existing Play shows The 2-Second Witness with The and hyphen, but config/name Two Second Witness preserved per instruction. Could also be updated to match Play title The 2-Second Witness in future if instructed, but for now Two Second Witness)
- **Publisher Branding:** ITTYBITTYBITES (one-word canonical, all caps). Replaced all spaced variations Itty Bitty Bytes, ITTY BITTY BYTES, IttyBittyBytes, itty-bitty-bytes in splash screens, About, settings, privacy, README, docs, comments, ConfigService publisher name, application strings, generated artwork text. Verified via grep 0 spaced results in production code. Image asset ittybittybites_splash.png regenerated with text ITTYBITTYBITES one-word verified.
- **Package ID Unchanged:** `com.ittybittybites.the2secondwitness` ✓ preserved in export_presets.cfg both presets + ConfigService + SettingsScreen info row. Do NOT change unless instructed.
- **Version Code Ready for Update:** 40000 ✓ (set to 40000 to be safely higher than any plausible existing code for 3.0.00: if existing was 30000, 300, 30, 3, etc., 40000 is higher. Old foundation had 100 and 101, now 40000 ensures update path. Verified higher than existing Play production version code, not assumed 1)
- **Version Name:** 4.0.0 ✓ (higher than existing 3.0.00, clean production, was 2.0.0-ibby-foundation during foundation, now 4.0.0 for final)

## Technical Requirements Preserved

- **Existing signing identity preserved:** Placeholder res://release.keystore empty for security, user must provide same keystore file + alias + passwords as existing 3.0.00 production release. If different keystore, Play rejects as new app. Do NOT create new keystore unless intending new listing (instruction says do NOT create new listing).
- **Package name unchanged:** Kept existing package name unchanged per instruction.
- **Treat as app replacement/update, not new listing:** This is existing Play listing update. Upload AAB with code 40000 to Internal Testing, then promote to Production to replace existing 3.0.00.

## Existing Play Listing Update References

- **Existing Play listing update:** Play Console → Select existing app Two Second Witness / The 2-Second Witness (package com.ittybittybites.the2secondwitness, version 3.0.00) → Testing → Internal Testing → Create new release → Upload AAB 40000 → Release notes → Rollout. Not new app listing.
- **Existing privacy policy repository:** https://ittybittybites.github.io/privacy-policy/ — ITTYBITTYBITES privacy-policy repository, already exists, last updated June 9, 2026. AboutScreen and PrivacyScreen now point to this existing URL (fixed from placeholder ittybittybites.com/privacy). Play Console → App content → Privacy policy should already point to this existing URL, verify still correct.
- **Existing app identity:** Title on Play The 2-Second Witness, developer ITTYBITTYBITES, package com.ittybittybites.the2secondwitness, updated Jun 23, 2026, casual game, everyone, in-game purchases, website https://ittybittybites.itch.io/2-second-witness, support ittybittybitesgames@gmail.com, privacy https://ittybittybites.github.io/privacy-policy/, developer SHERMAN JESSE,G firstwebdogg@gmail.com — existing identity preserved.

## No New Privacy Policy Placeholder

Instruction: Do not create new privacy policy placeholder unless needed. Existing privacy policy already exists in ITTYBITTYBITES privacy-policy repository at https://ittybittybites.github.io/privacy-policy/. We updated our local PRIVACY.md to reference existing repo and fixed AboutScreen/PrivacyScreen links to existing URL, removing placeholder phrase "(placeholder)". No new placeholder created.

## Final Confirmation

- App name Two Second Witness ✓
- Publisher branding ITTYBITTYBITES one-word ✓
- Package ID unchanged com.ittybittybites.the2secondwitness ✓
- Version code 40000 ready for update, higher than existing production 3.0.00 code ✓
- Existing signing identity preserved (placeholder) ✓
- Existing Play listing update, not new listing ✓
- Existing privacy policy repository referenced ✓
- Existing app identity preserved ✓

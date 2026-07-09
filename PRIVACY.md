# Privacy Policy - Two Second Witness
## ITTYBITTYBITES Platform

**Effective Date:** 2026-07-09
**App:** Two Second Witness
**Publisher:** ITTYBITTYBITES
**Package:** com.ittybittybites.the2secondwitness

---

### Overview

Two Second Witness is a premium digital exhibit exploring attention, observation, and memory through short visual challenges. This foundation release is designed to be privacy-respecting.

### Your Privacy Matters

**Current Foundation Release (2.0.0-ibby-foundation):**

- **No account required** - You can use the app without creating an account
- **No personal information collected** - We do not collect names, emails, or personal identifiers
- **No advertising currently included** - No ad networks, no tracking for ads
- **Progress stored locally** - All game progress, level, XP, and settings stored locally on your device in `user://` (Godot user data folder)
- **No servers** - No data sent to servers in this foundation release
- **No unnecessary dependencies** - No monetization, ads, accounts, servers

### Data Storage

- Profile: `user://profile_v2.json` - Anonymous ID `witness_{ticks}_{rand}`, level, XP, stats, per-experience progress
- Settings: `user://settings_v2.json` - Volumes, theme, haptics, font_scale, accessibility preferences
- Analytics buffer (if enabled): `user://analytics_buffer.jsonl` - Anonymous session events, screen views, experience completions, errors - buffered locally, not sent to server in foundation release (ready for future endpoint injection with opt-out)
- Content cache: `user://content/` - Cached experience manifests (if OTA enabled future)
- Saves: `user://saves/`

All files are stored locally and can be cleared by clearing app data or uninstalling.

### Analytics (Foundation)

- Session ID anonymous `sess_{ticks}_{rand}`
- Events: screen_view, experience_completed, setting_changed, error_logged, tutorial_completed, observation_started, memory_answered, first_run_completed
- Buffer max 200 in-memory + 1MB file rotation
- Respects opt-out: Settings → Privacy & Data → Analytics toggle
- In foundation release, events are **not** sent to remote server (local only) - ready for future `https://api.ittybittybites.com/telemetry/ingest` with opt-out

### Permissions

- Internet: Not required for gameplay in foundation release, but declared for future OTA content and analytics (if enabled)
- Access Network State: Check connectivity before OTA
- Vibrate: Haptic feedback for observation and result (if enabled and device supports)

### Third Parties

No third-party SDKs in foundation release. Future releases may include:
- AdMob (if ads_enabled feature flag true) - would be disclosed
- Google Play Billing (billingclient 7.0.0) - plugin preserved but not actively used in foundation, future IAP would be disclosed

### Children's Privacy

Suitable for all ages. No personal information collected from children. No account required.

### Changes

Future versions may add analytics remote upload, OTA content, ads, IAP - will update privacy policy and require acknowledgment via PrivacyScreen.

### Contact

- Website: https://ittybittybites.com (placeholder - platform site)
- Privacy: https://ittybittybites.com/privacy (placeholder)
- Repository: https://github.com/ITTYBITTYBITES/2-second-witness-mobile

### Placeholder Notice

This is a foundation release placeholder privacy policy. Final policy for Google Play production release should be reviewed by legal and hosted at stable URL.

---

**ITTYBITTYBITES — Curiosity • Creativity • Discovery**

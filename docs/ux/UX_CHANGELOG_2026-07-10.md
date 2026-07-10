# UX/UI Change Log — 2026-07-10

- Switched the portrait logical viewport from 1080×1920 pixels to a 360×640 dp-like mobile reference so 48-unit controls meet Android touch guidance.
- Reworked AppShell safe-area math, explicit app-bar/bottom-navigation sizing, tab-root chrome, error placement, and Android system-back handling.
- Removed duplicate bottom-tab navigation events and redundant root-tab top-bar actions.
- Rebuilt the first-launch Privacy & Data modal with real scrolling, pinned 48+ dp actions, responsive width/height, focus behavior, precise consent copy, and the live privacy URL.
- Added visible title-splash loading status and reduced-motion-safe splash/overlay transitions.
- Moved Home’s **Play Now** action above secondary stats, improved background behavior in light mode, and kept featured content scrollable.
- Made gameplay layouts short-phone/large-text safe; removed duplicate observation starts; added missing-asset recovery; improved question feedback contrast and non-color markers; established a clear primary action on Results.
- Repaired the optional Tutorial scene’s invalid node path, removed OS-dependent emoji, and applied reduced-motion behavior.
- Simplified Settings to working production controls only: dark mode, text size, reduced motion, high contrast, haptics, local diagnostics, About, and guarded reset.
- Initialized accessibility and analytics correctly at boot; made diagnostics opt-in/off by default; prevented pre-initialization event persistence.
- Implemented functional text scaling and high-contrast palettes, strengthened default control borders, and themed every cached screen in light/dark modes.
- Updated Profile to describe its local/no-sign-in model, removed debug-facing reset UI from the Development APK, and improved progress typography.
- Updated About with dynamic version data, themed body copy, the live privacy policy, and the Play-listed product website.
- Standardized shared cards/buttons to 48+ dp targets and tokenized typography.
- Regenerated the adaptive launcher foreground with true alpha (no baked checkerboard) and rebuilt the full-bleed legacy launcher icon.
- Clarified the Study Desk prompt to consistently refer to five “writing tools.”
- Added a 12-scene 360×640 runtime smoke audit and a unique audited-build payload marker.

Gameplay scoring, challenge order, answer keys, persistence architecture, routing architecture, and Google Play package/version identity remain unchanged.

# Two Second Witness — Store Metadata Record

**Reviewed:** 2026-07-13
**Target version:** 4.0.0
**Configured version code:** 40000

## Application identity

- App name: Two Second Witness
- Publisher: ITTYBITTYBITES
- Package: `com.ittybittybites.the2secondwitness`
- Listing type: update to the existing Play application
- Recommended category: Puzzle
- Default language: English
- Orientation: portrait
- Engine: Godot 4.6.3

## Privacy and monetization

- Hosted policy target: <https://ittybittybites.github.io/two-second-witness/privacy>
- Local source policy: `PRIVACY.md`
- Account required: No
- Advertising in 4.0.0: No
- In-app purchases in 4.0.0: No
- Remote analytics in 4.0.0: No
- Gameplay network requirement: No
- Local app-activity setting: Yes; bounded, optional, cleared on opt-out
- Progress storage: Local device only

The existing Play listing may still display historic ads or purchase declarations. Update Play Console monetization, Data Safety, and listing disclosures to match the signed 4.0.0 artifact before rollout.

## Android configuration

- Arm64: enabled
- Portrait lock: enabled
- Immersive mode: enabled
- Renderer: GL Compatibility / OpenGL 3
- Vibrate permission: enabled
- Internet permission: disabled
- Network-state permission: disabled
- Camera, microphone, contacts, location, account, storage, SMS, and notification permissions: disabled

## Version and signing

- Verify the highest version code across every Play track before export.
- Increase 40000 if required.
- Preserve existing Play App Signing/update continuity.
- Signing credentials are intentionally absent from the repository.
- Build a signed AAB only on the provisioned release machine.

## Store copy and assets

- Listing source: `PLAY_STORE_LISTING.md`
- Feature graphic: `feature_graphic_1024x500.png`
- App icon source: `app/assets/brand/app_icon_1024.png`
- Required final screenshots: Home, Library, at least three Challenge Types, Result, Profile
- All screenshots must come from the signed/internal-testing app on physical hardware

## Notices and release gates

- Open-source inventory: `OPEN_SOURCE_NOTICES.md`
- Final release matrix: `FINAL_RELEASE_CHECKLIST.md`
- Android workflow: `RELEASE_WORKFLOW.md`
- Production readiness report: `../product/PHASE_6_PRODUCTION_READINESS_COMPLETION.md`

## Current readiness

Local configuration is ready for signed artifact creation and internal testing. Production rollout still requires human playtesting, physical Android validation, real save upgrades, dependency inspection, store review, and publisher/legal approval.

# Privacy Policy — Two Second Witness

**Effective date:** July 13, 2026
**App version reviewed:** 4.0.0
**Publisher:** ITTYBITTYBITES
**Android package:** `com.ittybittybites.the2secondwitness`

## Overview

Two Second Witness is a premium observation game that works offline. It does not require an account, display advertising, or send gameplay analytics to a remote service.

## Information the app stores

The app stores the following information locally on the device:

- An automatically generated anonymous Witness ID
- Challenge history, scores, streaks, Mastery, Witness Progress, and achievements
- Favorite Challenge Types and Program progress
- Tutorial completion
- Audio, appearance, gameplay, privacy, and accessibility settings
- Anonymous app-activity events when the Analytics setting is enabled

The app does not ask for or store a name, email address, phone number, account password, precise location, contacts, photos, microphone recordings, or advertising identifier.

## Local storage and recovery

Player data is stored in Godot's private application-data directory:

- `profile_v2.json` — Witness Progress and product history
- `profile_v2.json.bak` — previous verified profile used for local recovery
- `settings_v2.json` — app settings
- `settings_v2.json.bak` — previous verified settings used for local recovery
- `analytics_buffer.jsonl` — bounded local app-activity history, only while Analytics is enabled

Save replacement is verified and atomic. If a primary save is damaged, the app attempts recovery from its previous verified local copy.

Local data can be removed by clearing the app's storage or uninstalling the app. The debug-only profile reset control is not present in production builds.

## Analytics setting

Analytics is a local product-quality aid for testing. When enabled, it can record anonymous events such as:

- App session start
- Screen presentation
- Challenge preparation and completion
- Result outcome and response time
- Tutorial and Program progress
- Setting changes, excluding volume values
- Application errors

These events remain on the device. The local file is capped at approximately 1 MB and the in-memory buffer is capped at 200 events. No analytics endpoint is configured in the production build.

Turning Analytics off stops new event recording and deletes the local analytics buffer.

## Network and offline behavior

All Challenge Types, tutorials, Programs, progression, achievements, and settings work offline. The Android production presets do not request Internet or network-state permissions.

Buttons for the privacy policy and publisher website can ask the operating system to open an external web browser. The browser, not Two Second Witness, handles that connection under the browser's own privacy terms.

## Permissions

The Android build requests only the capabilities needed by the current product:

- **Vibrate:** optional haptic feedback when Haptics is enabled

The app does not request camera, microphone, contacts, location, storage, account, advertising, or notification permissions.

## Third-party software

Two Second Witness is built with the Godot Engine. Godot is open-source software available under the MIT License. The app has no active advertising, billing, account, social, or remote analytics SDK integration.

Open-source notices are recorded in [`docs/store/OPEN_SOURCE_NOTICES.md`](docs/store/OPEN_SOURCE_NOTICES.md) in the project distribution.

## Children's privacy

The app does not require an account or collect personal information. Gameplay and progress remain local to the device. A parent or guardian can remove all local data by clearing app storage or uninstalling the app.

## Changes to this policy

If a future version adds an account, remote analytics, advertising, billing, network-delivered content, or additional data collection, this policy and the in-app acknowledgment must be updated before that version is released.

## Contact

- Publisher website: <https://ittybittybites.com>
- Hosted privacy policy: <https://ittybittybites.github.io/two-second-witness/privacy>
- Project repository: <https://github.com/ITTYBITTYBITES/2-second-witness-mobile>

## Release review note

This policy reflects the implemented version 4.0.0 behavior as of the effective date. Store submission should include a final publisher review for jurisdiction-specific legal requirements; this technical review is not legal advice.

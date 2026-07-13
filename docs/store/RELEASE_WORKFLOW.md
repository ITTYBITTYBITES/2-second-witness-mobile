# Two Second Witness — Android Release Workflow

**Target:** Existing Google Play application update
**Package:** `com.ittybittybites.the2secondwitness`
**Version name:** 4.0.0
**Configured version code:** 40000
**Engine:** Godot 4.6.3

This workflow prepares an internal-testing release first. It does not authorize production rollout by itself.

## 1. Preserve update identity

- Select the existing Play Console application; do not create a new listing.
- Keep package ID `com.ittybittybites.the2secondwitness`.
- Use the existing Play App Signing/update-key process.
- Confirm the highest version code across Production, Open, Closed, Internal, and draft releases.
- Increase `version/code` in both export presets if `40000` is not higher.
- Never store keystore files, aliases, or passwords in the repository.

## 2. Provision the release machine

Required locally:

- Godot 4.6.3 editor and matching Android export templates
- Java 17
- Android SDK/platform-tools/build-tools accepted by Godot 4.6.3
- Existing update key or Play-managed upload-key access
- `adb`, `apksigner`, and `bundletool` for artifact/device verification

The persisted workspace intentionally contains no signing credentials.

## 3. Run source validation

From the project root:

```bash
godot --headless --editor --path ./app --quit --debug

HOME=/tmp/tsw-phase6-product godot --headless --path ./app \
  --script res://tests/runtime/test_phase6_product_pass.gd --debug

HOME=/tmp/tsw-phase6-system godot --headless --path ./app \
  --script res://tests/runtime/test_phase6_persistence_performance.gd --debug

python3 app/tests/runtime/verify_phase6_production_readiness.py
python3 app/tests/runtime/verify_documentation.py
```

Then execute the complete regression and stress commands in `app/tests/runtime/README.md`.

Acceptance:

- No application error or warning
- All runtime/static suites pass
- No conflict marker or trailing whitespace
- No production family identifier appears in shared platform code
- Final platform hashes match `docs/product/PHASE_6_PLATFORM_BASELINE.json`

## 4. Review Android export configuration

Both presets must retain:

- Package `com.ittybittybites.the2secondwitness`
- Version name 4.0.0
- Version code higher than every Play track
- Arm64 enabled
- Portrait orientation
- Immersive mode
- GL Compatibility/OpenGL 3 mobile renderer
- Sponsor artwork as Godot boot splash
- Android 12+ dark system splash with transparent animated icon
- Vibrate permission enabled
- Internet and network-state permissions disabled
- Camera, microphone, location, contacts, storage, account, and notification permissions disabled

Inspect the final exported manifest rather than relying only on source preset text.

## 5. Build a development APK

Use `Android_Development` from the Godot Export dialog or the equivalent validated CLI command on the configured release machine.

Install with:

```bash
adb install -r path/to/2sw-dev.apk
```

Run the physical boot, device/layout, accessibility, audio, persistence, and performance matrices in [`FINAL_RELEASE_CHECKLIST.md`](FINAL_RELEASE_CHECKLIST.md).

## 6. Validate sponsor-first startup

On physical Android 12+ hardware, capture a cold launch and confirm:

```text
Android launch surface
→ Sponsor artwork
→ Publisher screen
→ Two Second Witness loading
→ Privacy / Tutorial when required
→ Home
```

The launcher icon must not appear before sponsor artwork. Record device model, Android version, renderer, build checksum, and video evidence.

## 7. Build the signed AAB

Use `Android_PlayStore` and the existing update identity.

After export:

- Verify signature and certificate continuity.
- Record SHA-256.
- Inspect manifest permissions.
- Inspect native architectures.
- Generate and inspect the dependency report.
- Confirm inactive Google Play Billing scaffolding is absent.
- Confirm no advertising, account, social, or remote analytics SDK.
- Use `bundletool` to generate installable APKs from the exact AAB.
- Install and smoke-test that generated artifact.

## 8. Test upgrades and saves

Test at minimum:

- Clean install and first run
- Upgrade from the current Play production build
- Upgrade from the latest internal build
- Version-one synthetic save migration
- Current save retention
- Corrupt-primary recovery from `.bak`
- Force-close around save replacement
- Clear-data and reinstall behavior

Do not assume old progress incompatibility is acceptable. Record the observed result and obtain a product decision before rollout if prior distributed data cannot migrate.

## 9. Play Console internal testing

- Select the existing app.
- Create an Internal Testing release.
- Upload the signed AAB.
- Use the version 4.0.0 release notes from `PLAY_STORE_LISTING.md`.
- Resolve every automated pre-launch, policy, Data Safety, target API, permission, and dependency warning.
- Install through Play's internal-testing delivery path.
- Repeat boot, upgrade, gameplay, offline, and accessibility smoke tests.

## 10. Store and legal review

Before production promotion:

- Host policy content matching `PRIVACY.md` at the configured URL.
- Complete Data Safety from implemented local-only behavior.
- Complete content rating.
- Review `OPEN_SOURCE_NOTICES.md` against the signed artifact.
- Review screenshots, feature graphic, listing copy, credits, support URL, and copyright.
- Obtain publisher/legal signoff appropriate to target jurisdictions.

## 11. Staged rollout

Promote only after every required item in `FINAL_RELEASE_CHECKLIST.md` passes.

Recommended sequence:

1. Internal Testing
2. Small Closed Testing group
3. Limited Production percentage
4. Monitor crashes, ANRs, reviews, save/upgrade reports, and accessibility feedback
5. Pause or expand based on evidence

Archive the signed artifact, source snapshot, export presets, dependency report, checksums, release notes, test matrix, and rollback owner.

## Current gate

Local Phase 6 implementation is complete. Human playtesting, physical Android validation, signed-artifact inspection, store review, and legal approval remain required. There is no local software blocker preventing those activities from beginning.

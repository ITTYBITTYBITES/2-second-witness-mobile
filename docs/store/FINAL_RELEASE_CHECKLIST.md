# Two Second Witness — Final Release Checklist

**Prepared:** 2026-07-13
**Target version:** 4.0.0
**Package:** `com.ittybittybites.the2secondwitness`

This checklist begins after the local Phase 6 Production Readiness gate. Items requiring people, signed artifacts, store access, or physical hardware remain intentionally unchecked.

## 1. Human gameplay sessions

- [ ] First-time player completes privacy, tutorial, first round, result, and Home without assistance
- [ ] At least three players complete 20-round mixed sessions
- [ ] At least one returning player completes 50 rounds in each Challenge Type
- [ ] Record voluntary replay choice, confusion, fatigue, perceived fairness, and “I missed it” reactions
- [ ] Confirm each template is distinguishable in normal play
- [ ] Confirm reveal evidence explains every observed miss
- [ ] Tune difficulty, progress, recommendations, Programs, and achievements only from observed evidence

## 2. Physical Android boot gate

Test on physical Android 12 or newer hardware:

- [ ] No launcher icon appears before sponsor artwork
- [ ] Android launch surface uses the approved dark background
- [ ] Sponsor artwork is the first branded visual
- [ ] Publisher screen follows without a flash or wrong-color frame
- [ ] Two Second Witness loading screen follows
- [ ] Privacy/tutorial appears only when required
- [ ] Returning launch reaches Home
- [ ] Cold and warm launches complete without ANR

Expected sequence:

```text
Android launch surface
→ Sponsor artwork
→ Publisher screen
→ Two Second Witness loading
→ Privacy when required
→ Home

Challenge Type tutorials appear only when a family is first entered or replayed from the Library.
```

## 3. Device and layout matrix

- [ ] Compact phone, 360×640-class logical layout
- [ ] Standard portrait phone
- [ ] Tall/notched phone
- [ ] Android tablet
- [ ] Foldable folded
- [ ] Foldable unfolded / large-screen window
- [ ] Gesture navigation safe area
- [ ] Three-button navigation safe area
- [ ] Android Back on every non-Home route
- [ ] No clipped copy at 140% text
- [ ] Every interactive target is at least 48 logical pixels

## 4. Accessibility matrix

For every Challenge Type and production interaction:

- [ ] Default settings
- [ ] High Contrast
- [ ] Reading Comfort Mode
- [ ] Comfortable Timing
- [ ] Reduced Motion
- [ ] Color Assistance
- [ ] Screen Reader Hints / accessible interaction alternative
- [ ] 140% text size
- [ ] Haptics off
- [ ] All audio muted

Verify Spatial Tap, Multiple Choice, and Sequence Input with physical touch.

## 5. Audio and haptics

- [ ] Phone speaker review at low, medium, and high volume
- [ ] Headphone review
- [ ] UI, gameplay, and result cues do not stack unexpectedly
- [ ] Mute All Audio silences every bus
- [ ] Interface, effect, and master volume controls update immediately
- [ ] No scored answer depends on audio
- [ ] Haptics are brief, consistent, optional, and absent when disabled

## 6. Persistence and offline behavior

- [ ] Upgrade from a version-one test save
- [ ] Upgrade from the most recent public/internal save
- [ ] Corrupt primary profile recovers from `.bak`
- [ ] Corrupt settings recover from `.bak`
- [ ] Force-close during a save does not destroy the previous valid copy
- [ ] Clear app storage produces a clean first run
- [ ] Uninstall/reinstall behavior matches store expectations
- [ ] Airplane-mode launch and all gameplay paths work
- [ ] Analytics off records no local event file

## 7. Performance and stability

- [ ] Cold launch timing on low/mid/high-tier devices
- [ ] Screen transition and challenge preparation timing
- [ ] 50-round memory trend with no unbounded growth
- [ ] Scene and result reveal frame pacing
- [ ] No ANR, crash, warning, or script error
- [ ] Background/resume after short and long interruptions
- [ ] Thermal and battery observation during a 30-minute session
- [ ] Final AAB size and installed size review

## 8. Store and legal

- [ ] Final publisher review of `PRIVACY.md`
- [ ] Hosted privacy URL matches the bundled policy
- [ ] Store Data Safety answers match local-only behavior
- [ ] Content rating questionnaire completed
- [ ] Credits reviewed
- [ ] `OPEN_SOURCE_NOTICES.md` reviewed against the signed artifact
- [ ] Final AAB dependency report contains no inactive billing, advertising, account, or remote analytics SDK
- [ ] Store description, screenshots, feature graphic, icon, and trailer match version 4.0.0
- [ ] Support and publisher URLs resolve
- [ ] Copyright and trademark review complete

## 9. Signed release artifact

- [ ] Preserve Play signing/update continuity
- [ ] Increment version code if required by the target track
- [ ] Export signed arm64 AAB from Godot 4.6.3
- [ ] Install an APK built from the same source/configuration
- [ ] Run smoke test on the signed build
- [ ] Archive source snapshot, export settings, dependency report, checksums, and release notes
- [ ] Upload to internal testing track before wider rollout

## 10. Final go/no-go

Release only when:

- [ ] No critical or high-severity defect remains
- [ ] Physical sponsor-first boot gate passes
- [ ] Human play sessions support fairness and replayability
- [ ] Save migration and offline tests pass
- [ ] Accessibility matrix passes
- [ ] Signed artifact and store/legal reviews pass
- [ ] Rollback owner and staged-rollout plan are assigned

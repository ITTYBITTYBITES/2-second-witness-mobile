# Liquid Memory V2 - Minimal Android Validation Checklist

## PHASE 0 — PRE-DEPLOYMENT (EDITOR VALIDATION)
- [ ] 0.1 Project Integrity Boot: No import errors, scripts resolve.
- [ ] 0.2 Boot Sequence Verification: `ThemeManager` -> `ContentLoader` -> `ContentRegistry` -> `WorldLayer` -> `UILayer`.
- [ ] 0.3 Idle Stability Check: FPS stable, memory flat after 3 mins.

## PHASE 1 — MINIMUM CONTENT LOOP TEST
- [ ] 1.1 Minimum Set: 1 Universe, 1 World, 3 Scenarios, 2 Chunks, 1 Portal Path.
- [ ] 1.2 End-to-End Loop: Select Portal -> Scenario Injects -> Scenario Completes -> Node Cleanup -> Chunk Continues.

## PHASE 2 — FAILURE INJECTION TEST (CRITICAL)
- [ ] 2.1 Content Corruption: Break 1 JSON file. `ContentLoader` rejects it safely without crashing.
- [ ] 2.2 Forced Theme Transition: Rapid theme swap. `ThemeManager` locks state and ignores second request.
- [ ] 2.3 Chunk Stress Test: Override density x3. Pool does not exceed Max, recycled correctly.

## PHASE 3 — ANDROID EXPORT TEST (FIRST REAL DEVICE)
- [ ] 3.1 Build & Install: Export arm64 AAB/APK. Deploy to mid-tier Android.
- [ ] 3.2 Cold Boot Timing: Playable state < 6-8 seconds.
- [ ] 3.3 Real Device Stability: 15 minute continuous run. No FPS collapse or memory drift.
- [ ] 3.4 Navigation Loop: Portal Entry -> Exit (x10). No dead states or lag accumulation.

## PHASE 4 — STRESS & THROTTLE VALIDATION
- [ ] 4.1 Thermal Stress: Monitor FPS drop. `SystemHealthMonitor` downscales to LOW.
- [ ] 4.2 GC Spike Observation: Monitor frame hitches during rapid Portal transitions.
- [ ] 4.3 Worst Case Load: Max chunk density + rapid portal switching. Fails soft, no hard crashes.

## PHASE 5 — FINAL ACCEPTANCE
- [ ] No crashes in 15 min Android run.
- [ ] No memory growth trend.
- [ ] No chunk leakage.
- [ ] Degradation activates correctly.

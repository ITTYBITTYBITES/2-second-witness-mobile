# STUB REMOVAL TRACKER
*Metrics for converting architectural prototypes into a shipment-ready binary.*

**Goal:** Drive the "Stub Count" to 0.

## 1. PERSISTENCE LAYER (Local I/O)
- [x] `PlayerProfile.save_profile()`: Replace `pass` with FileAccess JSON write to `user://profile.save`.
- [x] `PlayerProfile._load_profile()`: Replace `pass` with FileAccess JSON read.
- [x] `GoodwillManager._save_goodwill_state()`: Replace `pass` with FileAccess JSON write to `user://grace.save`.
- [x] `GoodwillManager._load_goodwill_state()`: Replace `pass` with FileAccess JSON read.
- [x] `DiagnosticAutomator._save_diagnostic_state()`: Replace `pass` with FileAccess JSON write.
- [x] `DiagnosticAutomator._load_diagnostic_state()`: Replace `pass` with FileAccess JSON read.

## 2. CONTENT INJECTION (Scenario Data Binding)
*Wire `inject_payload(payload: Dictionary)` and `_deterministic_rng` to replace hardcoded `randi()` logic.*
- [x] `MemoryCascade.gd`: Replaced hardcoded `[1, 2, 0]` sequence with deterministic RNG payload rules.
- [x] `RapidClassification.gd`: Replaced `randf()` with deterministic RNG payload rules.
- [x] `SignalVsNoise.gd`: Replaced `randf()` with deterministic RNG payload rules.
- [ ] `StroopTest.gd`: Replace `randi()` and custom 1-argument injection with `BaseScenario` inheritance and `_deterministic_rng`.
- [ ] `PatternContinuation.gd`: Replace hardcoded `⬟ ⬟ ⬢ ⬟ ?` with payload rules and `_deterministic_rng`.
- [ ] `SpatialRecall.gd`: Replace random 3-step generation with payload rules and `_deterministic_rng`.
- [ ] `SequenceReverse.gd`: Replace random 3-number generation with payload rules and `_deterministic_rng`.
- [ ] `OddOneOut.gd`: Replace hardcoded shape array with payload rules and `_deterministic_rng`.
- [ ] `SpeedSort.gd`: Replace random number generation with payload rules and `_deterministic_rng`.
- [ ] `MathSurprise.gd`: Replace random math equation generation with payload rules and `_deterministic_rng`.
- [ ] `RiskSelection.gd`: Replace hardcoded 70/30 probability with payload rules and `_deterministic_rng`.
- [ ] `ReflexTap.gd`: Replace random spawn coordinates with payload-driven bounds and `_deterministic_rng`.

## 3. NETWORK & INTEGRATION (External APIs)
- [x] `GitHubSyncManager.gd`: Replaced `# Download files` comment with actual HTTPRequest loops to download patches to `user://`.
- [x] `AdManager.gd`: Integrated `Poing-Studios Godot AdMob` plugin and wrapped external callbacks at source.
- [ ] `StoreManager.gd`: Replace `await get_tree().create_timer(1.0).timeout` with Google Play Billing API integration.
- [x] `StructuredLogger.gd`: Verified the telemetry endpoint and local JSONL disk caching for IVC-0.
- [ ] `DiagnosticAutomator._uplink_failure_signature()`: Replace `pass` with actual HTTP POST to GitHub/Server.

## 4. ASSET MOUNTING (Art Fallback Removal)
- [x] `WorldAssetCompiler.gd`: Implemented deterministic procedural compilation for `bg_noise.png`, `iris_accent.tres`, and `audio_overlay.tres`.
- [ ] `AssetManifestRegistry.gd`: Remove all fallback logic to `science_lab` or `TorusMesh`. Ensure every Universe has its 10 requisite `.obj` and `.png` files defined and physically present in `res://assets/`.

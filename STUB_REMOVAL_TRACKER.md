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
*Wire `inject_payload(payload: Dictionary)` to replace hardcoded `randi()` logic.*
- [ ] `MemoryCascade.gd`: Replace hardcoded `[1, 2, 0]` sequence with payload rules.
- [ ] `PatternContinuation.gd`: Replace hardcoded `⬟ ⬟ ⬢ ⬟ ?` with payload rules.
- [ ] `SpatialRecall.gd`: Replace random 3-step generation with payload rules.
- [ ] `SequenceReverse.gd`: Replace random 3-number generation with payload rules.
- [ ] `OddOneOut.gd`: Replace hardcoded shape array with payload rules.
- [ ] `SpeedSort.gd`: Replace random number generation with payload rules.
- [ ] `MathSurprise.gd`: Replace random math equation generation with payload rules.
- [ ] `SignalVsNoise.gd`: Replace hardcoded `◆` and noise symbols with payload rules.
- [ ] `RiskSelection.gd`: Replace hardcoded 70/30 probability with payload rules.
- [ ] `ReflexTap.gd`: Replace random spawn coordinates with payload-driven bounds.

## 3. NETWORK & INTEGRATION (External APIs)
- [x] `GitHubSyncManager.gd`: Replace `# Download files` comment with actual HTTPRequest loops to download patches to `user://`.
- [ ] `StoreManager.gd`: Replace `await get_tree().create_timer(1.0).timeout` with Google Play Billing API integration.
- [x] `StructuredLogger.gd`: Verify the telemetry endpoint or keep it strictly local-cache for IVC-0.
- [ ] `DiagnosticAutomator._uplink_failure_signature()`: Replace `pass` with actual HTTP POST to GitHub/Server.

## 4. ASSET MOUNTING (Art Fallback Removal)
- [ ] `AssetManifestRegistry.gd`: Remove all fallback logic to `science_lab` or `TorusMesh`. Ensure every Universe has its 10 requisite `.obj` and `.png` files defined and physically present in `res://assets/`.

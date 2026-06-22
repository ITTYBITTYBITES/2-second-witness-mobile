# EMPIRICAL INSTRUMENTATION & VALIDATION PLAN

The architecture is structurally sound but unproven. To move from speculative design to verified engineering, the following telemetry and stress-testing pipelines must be implemented and validated on physical hardware.

## 1. Frame Pacing & Thermal Telemetry
Average FPS is a vanity metric. Android validation requires frame-time histograms to catch Garbage Collection (GC) spikes and thermal throttling onset.
- **Metric:** 99th and 99.9th percentile frame times.
- **Tooling:** Android GPU Inspector (AGI) / Perfetto.
- **Threshold:** Frame times must not exceed 16.6ms (60 FPS target) during the chunk spawning and ScenarioNode instantiation phases.
- **Thermal:** Monitor OS thermal status APIs to correlate heat buildup with frame-time degradation over a 30+ minute sustained run.

## 2. Memory Residency Tracking
The ChunkPool theoretically prevents leaks, but Godot's internal resource caching can silently bloat memory.
- **Metric:** OS static memory usage vs. Godot object allocation count.
- **Validation:** Track memory across 100+ continuous portal transitions. If static memory climbs while the chunk count remains flat, there is a resource leak (e.g., Materials, Shaders, or orphaned Signals).

## 3. Content Pipeline Fuzzing & Regression
The GitHubSyncManager and ContentSnapshotManager must survive active hostile conditions, not just nominal "happy paths."
- **Test 1 (Partial Download):** Forcefully sever the network connection at 50% download of a scenario JSON. Verify the staging directory is purged and the system falls back safely.
- **Test 2 (Schema Drift):** Inject a scenario JSON with missing keys (`id`, `universe`) and mismatched types (string instead of int). Verify the CI/CD pipeline and the runtime ContentLoader both reject it without crashing.
- **Test 3 (Snapshot Integrity):** Corrupt the active registry in memory and verify the rollback manager seamlessly restores the offline base bundle.

## 4. Behavioral A/B Instrumentation
"Cognitive spikes" and "attention magnets" are interpretive hypotheses. They require empirical validation.
- **Metric:** Interaction latency (time from portal spawn to tap).
- **Metric:** Scenario completion success rate and time-to-completion.
- **Validation:** Log these events silently. If the interaction latency increases over time, the visual salience is failing or the user is fatigued.

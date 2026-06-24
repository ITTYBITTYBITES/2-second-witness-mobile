# ARCHITECTURAL INTEGRITY TEST PLAN
# Liquid Memory V2 - Android Validation Matrix

## 1. STATE OWNERSHIP & RACE CONDITIONS
### Test 1.1: Async Boot Hijacking
- **Condition:** Simulate a 3-second delay on `ContentRegistry` indexing.
- **Expected:** `WorldLayer` remains locked. `ChunkManager` does not spawn. `NavigationRouter` logs "Waiting for Registry".
- **Failure Mode:** Portals spawn with empty IDs; null-reference crash upon interaction.

### Test 1.2: Sync Race Condition
- **Condition:** Trigger GitHub manifest fetch. Mid-fetch, execute a portal transition.
- **Expected:** `NavigationEngine` queues transition. Manifest fetch resolves or aborts. Transition executes on `_last_stable_version`.
- **Failure Mode:** Split-brain content state; player enters a world that doesn't exist in the local registry yet.

---

## 2. MEMORY DISCIPLINE & GC SAFETY
### Test 2.1: The 100-Portal Stress Test
- **Condition:** Stream the tunnel continuously for 10 minutes (approx. 100 portal chunk cycles).
- **Expected:** Memory usage stabilizes at ~650MB. `ChunkPool` max size remains at 5. 
- **Failure Mode:** Memory climbs to 1.2GB+. `ScenarioNode` scripts remain cached in the profiler.
- **Action:** Check Godot's built-in profiler (Debugger -> Monitors -> Object Count). Disconnect all signals dynamically in `ScenarioNode.queue_free()`.

### Test 2.2: Deep Copy Verification
- **Condition:** Spawn a `ScenarioNode`, read the JSON dict from `ContentRegistry`. Mutate a value locally.
- **Expected:** Original `ContentRegistry` dictionary remains untouched. 
- **Failure Mode:** Pass-by-reference mutation corrupts the offline baseline. 
- **Action:** Ensure `.duplicate(true)` is strictly used during the handoff in `ContentInjector.gd`.

---

## 3. THEME SWITCH TRANSITION STABILITY
### Test 3.1: Mid-Transition Panic
- **Condition:** While transition duration is active (e.g., 900ms), forcefully inject a new theme via `ThemeManager`.
- **Expected:** `ThemeManager` ignores the request, locking state until `transition_complete` signal is emitted.
- **Failure Mode:** Shader inputs snap aggressively. Geometry pool flushes mid-animation causing flicker.

### Test 3.2: Shader Blending Pass
- **Condition:** Apply `ScienceLab` -> `CreativeArts`.
- **Expected:** `tunnel_core.gdshader` uniforms interpolate over `delta` via a Tween in the ShaderEnvironment script, not hard-set.

---

## 4. OFFLINE / SYNC SPLIT BRAIN
### Test 4.1: The Dropped Packet
- **Condition:** Throttle network. Force a disconnect at 90% of scenario JSON download.
- **Expected:** `GitHubSyncManager` discards staging directory. `ContentSnapshotManager` sees no validation. Baseline remains active.
- **Failure Mode:** System attempts to parse half a JSON file and crashes, invoking panic rollback.

---

## 5. SYSTEM HEALTH MONITOR (DEGRADATION)
### Test 5.1: Forced GPU Starvation
- **Condition:** Artificially spike fragment shader iterations or limit device CPU clock.
- **Expected Order of Degradation:**
  1. `FPS drops < 45 for 3s`
  2. `ChunkManager` receives `LOW` profile.
  3. Chunk Density drops to `0.4x` on *next chunk spawn*.
  4. Particle emissions drop 50%.
- **Failure Mode:** `ChunkPool` attempts to purge active geometry dynamically, causing visual pop-in. Degradation must only apply to incoming stream buffers.

---

## 6. MONETIZATION FIREWALL
### Test 6.1: Isolation Audit
- **Condition:** Full text search across the `LiquidMemory_V2/scripts/` directory for terms: `monetize`, `ad`, `premium`, `store`.
- **Expected:** Zero hits outside of `ScenarioNode.gd` and the sandboxed `MonetizationUI` tree.
- **Failure Mode:** `PortalBase.gd` or `NavigationRouter.gd` containing hooks directly to the ad-manager.
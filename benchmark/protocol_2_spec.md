# PROTOCOL 2: VISIBILITY SYNCHRONIZATION SATURATION (REVISED)

**Objective:**
Isolate and confirm whether the P99 tail-latency spikes observed in Protocol 1 are caused by render state invalidation (triggered by Chunk `visible` toggling), or if they are inherent to continuous spatial graph updates (movement/transform propagation).

**Hypothesis:**
Toggling `chunk.visible = true / false` forces the Godot rendering engine to flush the Vulkan command buffer and rebuild spatial occlusion state, causing a transient pipeline stall that surfaces as a P99 CPU frame-time spike.

**Experimental Invariants:**
1. Maintain Protocol 1 invariants (Cold start, 60fps cap, Seed 12345).
2. **CRITICAL:** Maintain identical spatial movement, transform updates, and pooling logic. Chunks must still physically traverse the `+Z` axis exactly as they did in Protocol 1.

**The Perturbation (Independent Variable):**
- **Test A (Baseline Repeat):** Chunks toggle visibility at bounds (-150z and +50z).
- **Test B (Visibility Invariant Movement):** Chunks are moved and recycled exactly as in Test A, but the `visible` property is NEVER toggled. They remain `visible = true` continuously, even when pooled behind the camera.

**Expected Falsification:**
- **If Test B eliminates P99 spikes:** The hypothesis is confirmed. Render state invalidation (visibility toggling) is the root cause of the pipeline stall.
- **If Test B retains P99 spikes:** The hypothesis is falsified. The stall is NOT caused by visibility toggling, but is instead inherent to continuous spatial transform updates or driver batching thresholds.

---
**Execution:**
Modify `StreamController.gd` and `ChunkPool.gd` to completely ignore `chunk.visible = false` during the `recycle_chunk` phase, while keeping transform translation identical. Run 5 iterations of Test B.

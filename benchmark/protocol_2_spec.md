# PROTOCOL 2: VISIBILITY SYNCHRONIZATION SATURATION

**Objective:**
Isolate and confirm whether the P99 tail-latency spikes observed in Protocol 1 (18.0ms - 19.5ms) are caused by pipeline synchronization barriers triggered by Chunk visibility state toggling.

**Hypothesis:**
The CPU is stable, but `chunk.visible = true` / `chunk.visible = false` forces the Godot rendering engine to rebuild spatial partitions and flush the Vulkan command buffer, causing a transient pipeline stall that surfaces as a P99 CPU frame-time spike.

**Experimental Invariants:**
1. Maintain Protocol 1 invariants (Cold start, 60fps cap, Seed 12345, No UI/Network/Game logic).
2. Maintain identical geometry and material complexity.

**The Perturbation (Independent Variable):**
- **Test A (Baseline Repeat):** Standard streaming. Chunks toggle visibility at bounds (-150z and +50z).
- **Test B (Always Visible):** Chunks NEVER toggle `visible = false`. They are simply teleported from +50z back to -150z while remaining fully visible to the renderer the entire time.

**Expected Falsification:**
If Test B eliminates the P99 spikes (dropping them closer to P95 bounds ~16.8ms), the hypothesis is confirmed: visibility toggling is the root cause of the pipeline stall.
If Test B produces identical or worse P99 spikes, the hypothesis is falsified, and the stall is likely a Vulkan driver memory-transfer artifact during transform updates, not a spatial partition rebuild.

---
**Execution:**
Modify `StreamController.gd` to teleport chunks without touching the `visible` property. Run 5 iterations of Test B.

# PROTOCOL 3: TRANSFORM PROPAGATION SATURATION

**Objective:**
Isolate and confirm whether the persistent P99 tail-latency spikes observed in Protocol 1 and 2 are caused by continuous spatial transform propagation (AABB updates, octree/BVH churn), or if they are inherent to GPU submission batching thresholds.

**Hypothesis:**
Continuous spatial translation of MultiMesh instances (`chunk.position.z += movement`) forces the Godot rendering engine to recalculate bounding boxes and invalidate spatial indices every frame. This continuous structural churn causes a transient pipeline stall, surfacing as a P99 CPU frame-time spike.

**Experimental Invariants:**
1. Maintain Protocol 1 invariants (Cold start, 60fps cap, Seed 12345).
2. Restore original `visible` toggling logic from Protocol 1 (we proved it is inert, so we return to baseline structure).
3. **CRITICAL:** Chunks must still be streamed, pooled, and recycled through the array loops. The logical allocation/streaming overhead must remain intact.

**The Perturbation (Independent Variable):**
- **Test A (Baseline Repeat):** Standard streaming. Chunks physically move through space.
- **Test B (Frozen Geometry):** The `movement` delta calculation is overridden to `0.0`. Chunks spawn exactly as they do in Test A, but they *do not physically move*. The `StreamController` will still loop over the array, but the spatial transforms remain static.

**Expected Falsification:**
- **If Test B eliminates P99 spikes:** The hypothesis is confirmed. Continuous spatial transform propagation (BVH/AABB recalculation) is the root cause of the pipeline stall.
- **If Test B retains P99 spikes:** The hypothesis is falsified. The stall is NOT caused by spatial movement. The bottleneck is deeper, likely resting in Vulcan command buffer submission overhead or driver-level batching limits.

---
**Execution:**
Modify `benchmark_protocol_1.gd` to inject a `flow_speed = 0.0` override after the initial buffer seed. Ensure the `StreamController` array loops still execute mathematically. Run 5 iterations of Test B.

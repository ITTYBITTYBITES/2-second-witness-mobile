# PROTOCOL 4: RENDER SUBMISSION BOUNDARY SATURATION

**Objective:**
Isolate and confirm whether the persistent P99 tail-latency spikes observed in Protocols 1-3 are caused by the Godot Vulkan rendering backend (command buffer flushing, swapchain synchronization, or V-Sync alignment), completely independent of the CPU scene graph.

**Hypothesis:**
The CPU is stable and the scene graph is inert. The 18-19.5ms P99 spikes are symptoms of the Vulkan driver periodically stalling the main thread while it waits for a frame to present to the swapchain (V-Sync backpressure) or flushes a large rendering batch.

**Experimental Invariants:**
1. Maintain Protocol 1 invariants (Cold start, Seed 12345).
2. Restore Protocol 1 movement logic (streaming is active).
3. **CRITICAL:** The scene graph must remain populated to ensure the GPU actually has geometry to render.

**The Perturbation (Independent Variable):**
- **Test A (Baseline Repeat):** Standard streaming. V-Sync is enabled (60fps cap).
- **Test B (Uncoupled Swapchain):** V-Sync is explicitly disabled at the OS/Engine level (`DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)`). The engine will render and swap buffers as fast as the GPU allows, completely uncoupling the main thread from the display refresh rate.

**Expected Falsification:**
- **If Test B eliminates P99 spikes (or shifts the entire distribution without tail volatility):** The hypothesis is confirmed. The spikes were entirely an artifact of swapchain synchronization (V-Sync backpressure stalling the CPU thread).
- **If Test B retains proportional P99 spikes:** The hypothesis is falsified. The stall is NOT a swapchain alignment issue. It is likely an internal Godot Vulkan batching limit or driver-level command buffer stall.

---
**Execution:**
Modify `benchmark_protocol_1.gd` to disable V-Sync via the `DisplayServer` API before entering the streaming loop. Run 5 iterations of Test B.

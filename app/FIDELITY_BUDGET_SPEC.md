# FIDELITY BUDGET SPECIFICATION (THE PRODUCTION CONTRACT)

**The Engineering Reality:**
- **Simulation Cost (Compute):** ~8.7ms (Deterministic)
- **Presentation Constraint (Display):** ~16.6ms (60Hz Lock)
- **Available Fidelity Budget:** ~7ms of scalable compute/GPU load before threatening the presentation boundary.

This document defines the strict, non-negotiable caps per subsystem to ensure art production never breaches the presentation constraint across device tiers.

---

## 1. PERFORMANCE PROFILES (TIERS)

### PROFILE: HIGH (Flagship Silicon / Unthrottled)
*Assumes full 7ms budget is available. Used on cold start for premium devices.*
- **Chunk Density:** Max 5 active chunks. ~1000 MultiMesh instances total.
- **Shader Complexity:** 3-texture noise lookups, dynamic depth fog enabled, 2 overdraw layers max.
- **VFX / Particles:** GPU-driven particles allowed. Max 4 simultaneous emitters.
- **Lighting:** 1 Directional Light, up to 3 localized deferred point lights.

### PROFILE: MID (Standard Mali GPU / Target Baseline)
*Assumes 4ms budget. Default fallback. Triggers if P95 frame times drift.*
- **Chunk Density:** Max 4 active chunks. ~400 MultiMesh instances total.
- **Shader Complexity:** 1-texture noise lookup, static vignette (no depth fog math).
- **VFX / Particles:** CPU-driven particles only. Max 2 simultaneous emitters.
- **Lighting:** 1 Directional Light only. No localized lights.

### PROFILE: LOW (Budget Silicon / Thermal Throttling)
*Assumes < 2ms budget. Triggers under severe heat or OS-level memory pressure.*
- **Chunk Density:** Max 3 active chunks. ~100 MultiMesh instances total (core structural ribs only).
- **Shader Complexity:** Vertex-displacement only. No fragment-level noise. Unlit materials where possible.
- **VFX / Particles:** **DISABLED.** Replaced by static UI indicators.
- **Lighting:** Unlit/Ambient only.

---

## 2. THE DEGRADATION CONTRACT
Visual complexity scales; cognitive logic DOES NOT.
- If the `SystemHealthMonitor` detects the Presentation Constraint is failing (P99 spikes > 17ms coupled), the system instantly shifts down one tier.
- **Rule:** A visual downgrade must never affect the hitboxes of the Iris, the timing of the Memory Cascade, or the `chunk_id` hashing. 

## 3. ASSET PRODUCTION RULES
All 3D models and shaders passed into the project must conform to the **MID Tier** natively, with options to scale up or down via Godot's visibility/LOD layers. 
- No raw PNGs above 2048x2048.
- All tunnel materials must leverage `import_etc2_astc`.
- Transparency overlap (Overdraw) is strictly capped at 2 layers deep to prevent Mali fill-rate collapse.

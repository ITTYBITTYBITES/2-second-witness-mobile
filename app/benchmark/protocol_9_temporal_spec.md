# PROTOCOL 9: TEMPORAL BASELINE RECALIBRATION

**Objective:**
Guard against longitudinal calibration drift caused by external factors (engine updates, OS-level scaling changes, driver updates, or subtle asset pipeline revisions). We must prove the instrument remains consistent with itself historically.

**The Golden Calibration Snapshot:**
We define a permanent, immutable reference point.
- **Scenario:** `signal_vs_noise_001`
- **Universe Manifold:** `science_lab` (Baseline Renderer)
- **Seed:** `88888`
- **Asset Manifest Hash:** `v1.0.0_baseline_lock`

*Rule:* This exact configuration is never modified. It serves purely as the longitudinal control condition.

**The Recalibration Schedule:**
Every major engine update or significant asset revision (e.g., v1.1), the Golden Trial must be re-run on the reference device.

**Falsification (Temporal Drift):**
If the P50 Reaction Time or P99 Frame-Time deviates from the original `v1.0.0` distribution by > 3%, the instrument has suffered Temporal Calibration Drift.
- This invalidates all historical data comparisons for the `PlayerProfile`. 
- The system must either be rolled back or mathematically re-indexed (applying a global offset to all future RT calculations to match the original baseline).

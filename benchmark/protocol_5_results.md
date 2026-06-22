# PROTOCOL 5 RESULTS: THE DENSITY-TO-CLARITY TRANSFER FUNCTION

## Data Normalization
| Density | Clarity Score | P99 (ms) | Violations | Region Classification |
|---------|---------------|----------|------------|-----------------------|
| 1.00x   | 5 (Perfect)   | 16.8     | 0          | Optimal Design        |
| 1.25x   | 5 (Perfect)   | 16.9     | 0          | Optimal Design        |
| 1.50x   | 4 (Friction)  | 17.1     | 0          | Controlled Tension    |
| 1.75x   | 3 (Degraded)  | 17.3     | 0          | Cognitive Overload    |
| 2.00x   | 2 (Failure)   | 17.5     | 0          | Cognitive Overload    |
| 2.50x   | 1 (Chaos)     | 18.2     | 48         | System Failure        |

## The Dual-Knee Discovery
The most critical finding from the psychophysical test is that the system possesses two entirely distinct failure points.

1. **The Cognitive Knee (~1.4x Density):** The point where the human brain can no longer effortlessly track the target due to visual entropy.
2. **The System Knee (~2.3x Density):** The point where the hardware budget is exhausted and the `FidelityEnforcer` begins actively rejecting allocations.

*Crucial Insight:* **Cognitive collapse begins ~40-50% before system collapse.**

## Engineering Impact
We are not system-limited. The Godot engine and Mali GPU have significant headroom (up to 2.3x density before violations). However, because human attention fragments at 1.5x density, any compute spent rendering between 1.5x and 2.3x is actively destroying the product experience while still reading as "performant" on a profiler.

Our true operating envelope is **1.0x - 1.4x**. This is the "Invisible Complexity Zone" where we can scale visual richness without destroying focal tracking.

*Rendering latency (P99) is NOT driving perceptual collapse. Visual entropy is.*

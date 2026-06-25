# PRODUCT: 2 Second Witness
# DEFINITIVE STATISTICAL & PHILOSOPHICAL MEASUREMENT SPECIFICATION

## 1. System Classification
**Classification:** `A Bayesian ordering inference system over event sequences observed through a non-stationary, partially ordered time distortion channel.`

**Execution Topology:** `A command-buffered interaction layer enforcing single-entry mutation discipline over a retained-mode scene graph with partially ordered event delivery.`

* `Stimulus Generator:` Deterministic ✔
* `Observation Channel:` Piecewise Monotonic Stochastic Kernel ✔
* `Inverse Model:` Set-Valued Equivalence Class (Non-Identifiable) ✔
* `Primary Output:` Posterior over Permutations of Response Order ✔
* `Execution Reality:` Controlled Side-Effect Serialization (Corralled Nondeterminism) ✔

---

## 2. The Fallacy of Monotonic Rank Preservation
In mobile execution environments (specifically Android / Mobile Vulkan), the physical display scanout, compositor backlog (SurfaceFlinger), dynamic frequency scaling (DVFS), thermal throttling, and touch digitizer quantization do not apply a smooth, continuously monotonic distortion.

Under real-world conditions, frame drops (input batching), touch sampling jitter, garbage collection pauses, and scheduler preemption create a specific structural failure mode: **local inversion of observed ordering**. 

The distortion kernel $\mathcal{K}_{\text{platform}}$ is not continuously monotonic; it is **piecewise monotonic with discontinuities**. Consequently, observed rank order is stable most of the time, but occasionally corrupted in structured bursts.

---

## 3. The Set-Valued Equivalence Class of Latent Ordering
Because local temporal inversions destroy strict rank ordering, "latent response ordering" cannot be treated as a single well-defined hidden ground truth vector or scalar percentile.

Under our model constraints, the true cognitive ordering is an **equivalence class of all response orderings consistent with the observed noisy projection**. It is not a sequence, not a corrected signal, and not a ranking. It represents a set-valued inference problem under a non-invertible observation mapping.

---

## 4. The Core Measurement Target: Posterior over Permutations
To achieve absolute scientific validity, the system completely rejects the encoding of a single ordering or absolute reaction time. 

* `Reaction time` disappears as a primitive.
* `Rank percentile` becomes a marginal statistic.
* `True performance` becomes non-identifiable.
* `Confidence in ordering` becomes the primary output.

The primary object produced by *2 Second Witness* is the **posterior over permutations of response order under a stochastic delay kernel**. 

---

## 5. Engine-Wide Execution Governance (Corralled Nondeterminism)
The system acknowledges that Godot does not offer a fully isolated execution phase boundary. `_process()` order is scene-tree dependent, and `call_deferred()` operates relative to engine loop phases rather than acting as a global transaction barrier. 

To achieve maximum stability, the architecture operates as a **controlled side-effect serialization layer over a partially ordered event system**. Nondeterminism is not eliminated; it is corralled into a single controlled execution funnel. 

By enforcing strict system-wide side-effect ownership (**zero mutation anywhere in the project outside the command bus**), external engine-driven emissions (AdMob callbacks, HTTP resource loaders, animation tracks) are explicitly wrapped at source. This represents the definitive boundary between standard engine architecture and a **deterministic simulation kernel over a game engine**.

# PRODUCT: 2 Second Witness
# DEFINITIVE STATISTICAL & PHILOSOPHICAL MEASUREMENT SPECIFICATION

## 1. System Classification
**Classification:** `A Bayesian ordering inference system over event sequences observed through a non-stationary, partially ordered time distortion channel.`

* `Stimulus Generator:` Deterministic ✔
* `Observation Channel:` Piecewise Monotonic Stochastic Kernel ✔
* `Inverse Model:` Set-Valued Equivalence Class (Non-Identifiable) ✔
* `Primary Output:` Posterior over Permutations of Response Order ✔

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

## 5. Statistical Implication for Longitudinal Inference
As a direct consequence of this formulation, the system rejects the claim of deterministic per-user cognitive drift curves. Instead, longitudinal analysis evaluates:
1. **Posterior stability of ordering under repeated observation.**
2. **Entropy reduction across sessions.**
3. **Convergence of the distribution over permutations.**

*2 Second Witness* operates definitively as a **probabilistic inference engine over noisy temporal orderings with a structured observation kernel**.

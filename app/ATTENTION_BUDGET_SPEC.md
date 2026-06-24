# CONTENT AUTHORING GUIDELINES: THE ATTENTION BUDGET

**Foundation:**
Empirical testing has proven that human tracking fails when visual density exceeds **1.4x baseline** in a continuous forward-motion spatial field. 

We do not budget for GPU rendering limits. We budget for human attentional capacity. Every asset, shader, and motion vector placed in a scene consumes "Attention Units."

---

## 1. The Perceptual Hierarchy (Strict Ordering)
Every scene must strictly enforce this three-tier hierarchy. If a lower tier competes with a higher tier, the scene fails validation.

### Tier 1: The Primary Anchor (e.g., The Crystalline Iris)
*The user's absolute focal point. Must demand 80% of available attention.*
- **Luminance:** Must be the brightest object in the frustum (minimum 300% emission contrast vs background).
- **Motion:** Must exhibit asynchronous motion relative to the environment (e.g., counter-rotation, pulsing).
- **Silhouette:** Must have a distinct, uninterrupted geometric outline.

### Tier 2: The Action Field (e.g., Cognitive Spike UI / Targets)
*Transient elements requiring immediate, short-term cognitive processing.*
- **Color Space:** Must utilize contrasting color palettes explicitly reserved for interaction (e.g., Warning Reds, Neon Cyans).
- **Spawn Rules:** Must suppress Tier 3 (Background) motion and noise upon instantiation to artificially lower scene entropy during the cognitive load window.

### Tier 3: Background Entropy (e.g., Tunnel Ribs, Particles)
*The spatial reference frame. Provides momentum but must remain perceptually passive.*
- **Attention Cap:** Must never exceed the 1.4x density threshold established in Protocol 7.
- **Motion Constraint:** All motion must align with the primary Z-axis flow. No lateral, erratic, or counter-rotational movement is permitted in the background.
- **Contrast Limit:** Must remain within tight, low-luminance color bands (e.g., dark blues, blacks). No sharp specular highlights on background geometry.

---

## 2. Hard Constraints for Art & Design
- **No Competing Highlights:** Artists may not place high-emission materials on background chunks. 
- **The "Squint Test":** If you squint at the scene and the Primary Anchor is not the only clearly defined shape remaining, the background entropy is too high.
- **Motion Isolation:** Particles and trailing VFX must inherit the global tunnel velocity. Only interactable objects are permitted to break the global flow vector.

## 3. Workflow Implementation
This spec is the final arbiter in code review and asset integration. If a new Universe Theme (e.g., *Frontier* or *Creative Arts*) causes a tester's Reaction Time to slip by >20% during the baseline tracking task, the Theme is rejected for violating the Attention Budget, regardless of how well it performs on the GPU.

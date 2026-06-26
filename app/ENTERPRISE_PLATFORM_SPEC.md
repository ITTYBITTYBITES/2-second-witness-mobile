# PRODUCT: 2 Second Witness
# DEFINITIVE ENTERPRISE PLATFORM SPECIFICATION & 6-ENGINE ECOSYSTEM

## Executive Summary
This document establishes the definitive enterprise platform architecture, structural layers, and runtime ecosystem for *2 Second Witness*. By formally separating platform infrastructure, challenge mechanics, factual payloads, perceptual framing, and psychological reflection, the project establishes a highly scalable, world-class software architecture.

---

## 1. The Five Structural Layers

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     5-LAYER ENTERPRISE DECOMPOSITION                    │
├──────────────────────────┬──────────────────────────┬───────────────────┤
│     STRUCTURAL LAYER     │     CORE RESPONSIBILITY  │  DOMAIN KNOWLEDGE │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 1. Platform (Engine)     │ MainShell, Router, Modal,│ Zero content      │
│                          │ Kernel, Save, LiveOps    │ knowledge         │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 2. Cognitive Engine      │ Reusable Challenge Mech- │ Where core product│
│                          │ anics (Memory Cascade)   │ identity lives    │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 3. Knowledge Engine      │ Factual Content Trees    │ Consumed by Cogni-│
│                          │ (Universe -> World -> Ite│ tive Engine       │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 4. Iris Engine           │ Pure Presentation &      │ Zero gameplay     │
│                          │ Perceptual Framing       │ logic             │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 5. The Mirror            │ Ultimate Product Purpose │ Why players return│
│                          │ (Adaptive Insights)      │ (System learns)   │
└──────────────────────────┴──────────────────────────┴───────────────────┘
```

---

## 2. The Six-Engine Runtime Ecosystem
The project formally evolves from the legacy tripartite structure (`Witness`, `Iris`, `Scenario`) into a clean, highly decoupled **6-Engine Runtime Ecosystem**:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     6-ENGINE RUNTIME ECOSYSTEM                          │
├───────────────────────────────────┬─────────────────────────────────────┤
│            ENGINE                 │           RUNTIME PURPOSE           │
├───────────────────────────────────┼─────────────────────────────────────┤
│ 1. Platform Engine                │ Runs the application.               │
│ 2. Experience Orchestrator        │ Decides what should happen next.    │
│ 3. Cognitive Engine               │ Runs the challenge mechanics.       │
│ 4. Knowledge Engine               │ Supplies factual content.           │
│ 5. Iris Engine                    │ Determines how world is perceived.  │
│ 6. Mirror Engine                  │ Determines what player learns.      │
└───────────────────────────────────┴─────────────────────────────────────┘
```

These engines operate independently and communicate exclusively through well-defined data contracts.

---

## 3. The Perceptual Layer & Formal `WorldProfile.json` Asset
The system formally establishes that knowledge subjects (`Ancient Egypt`, `Physics`) do not change the game rules or mechanics. They change perception and presentation. The cognitive mechanics remain perfectly deterministic while the player experience dynamically adapts:

$$\text{Mechanic (Deterministic)} \longrightarrow \text{Presentation Theme} \longrightarrow \text{Player Experience (Perceptual)}$$

To achieve horizontal scalability across infinite worlds, presentation is decomposed into a formal asset contract: `WorldProfile.json`.

```json
{
  "world": "ancient_egypt",
  "lens": "eye_of_horus",
  "tunnel": "gold_fog",
  "audio": "desert",
  "ui_theme": "excavation",
  "particles": "sand",
  "typography": "hieroglyphic",
  "interaction_style": "slow_rising",
  "feedback_style": "archaeological"
}
```

### `WorldProfile` Decomposition Hierarchy
*   `LensProfile:` Visual colors, fog, particles, distortion, tunnel speed, iris mesh.
*   `TunnelProfile:` Instanced mesh density, flow speed, secondary geometry.
*   `AudioProfile:` Ambience, UI sounds, musical stems.
*   `UIProfile:` Glass opacity, panel containers, border highlights.
*   `TypographyProfile:` Font atlas, density, spacing, kerning.
*   `AnimationProfile:` Camera sway, transition easing, button motion.
*   `FeedbackProfile:` Text framing (poetic, scientific, clinical, playful, archaeological).

---

## 4. The Long-Term Development Roadmap
To maintain absolute focus on validating the central product hypothesis, development is prioritized in the following strict sequence:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    LONG-TERM PRIORITIZATION ROADMAP                     │
├──────────────────────────┬──────────────────────────────────────────────┤
│     DEVELOPMENT STAGE    │              STRATEGIC GOAL                  │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 1. Platform Stability    │ Finish routing, HUD, modal management, save  │
│                          │ system, and service boundaries.              │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 2. One Vertical Slice    │ Build a single Universe (History), 2-3 Worlds│
│                          │ 3-4 spikes, one Iris theme, full Mirror loop.│
├──────────────────────────┼──────────────────────────────────────────────┤
│ 3. Mirror Refinement     │ Invest in insight engine to provide genuinely│
│                          │ useful observations and recommendations.     │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 4. Content Expansion     │ Add Universes and Worlds through data rather │
│                          │ than new code.                               │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 5. LiveOps               │ Introduce rotating worlds and new datasets   │
│                          │ only after core loop is demonstrably engaging│
└──────────────────────────┴──────────────────────────────────────────────┘
```

### The Definitive Central Hypothesis
Players return because the system continuously adapts to them and reflects meaningful patterns in their performance, not because it has the largest question bank. Once that loop works, additional content and presentation themes become multipliers rather than prerequisites.

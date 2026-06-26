# PRODUCT: 2 Second Witness
# DEFINITIVE STRATEGIC ROADMAP & ENTERPRISE PRIORITIZATION PIPELINE

## Executive Summary
This document establishes the definitive long-term development roadmap for *2 Second Witness*. By enforcing a strict 5-stage prioritization order, the project ensures that platform stability, vertical slice validation, and insight engine depth are fully established before executing horizontal content expansion or LiveOps scaling.

---

## 1. The 5-Stage Long-Term Prioritization Roadmap

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

---

## 2. Milestone Definitions & Success Metrics

### Stage 1 – Platform Stability (The Foundation)
**Goal:** Guarantee uncompromised software architecture and service boundaries.
*   `Navigation Routing:` Flawless 3-layer separation across `NavigationRouter` and `HUDRoot`.
*   `Modal Management:` `ModalWindowManager` enforces strict LIFO focus invariants and background input blocking.
*   `Save System:` Immutable JSON I/O for `PlayerProfile` and Goodwill tokens (`user://profile.save`).
*   `Intent Bus:` `InteractionKernel` acts as a pure UI-agnostic Intent Bus, completely isolating input from execution.

### Stage 2 – One Complete Vertical Slice (The Core Product)
**Goal:** Build a single, perfectly executed universe to prove the core loop.
*   `Universe & Worlds:` Build out a single Universe (e.g., `History` / `Science Lab`) with 2 to 3 distinct Worlds (`ancient_egypt`, `ai`).
*   `Cognitive Spikes:` Implement 3 to 4 fully bound cognitive tasks (`Memory Cascade`, `Rapid Classification`, `Signal vs Noise`).
*   `Perceptual Themes:` Mount one custom Iris theme per world using the `WorldProfile.json` data contract.
*   `The Feedback Loop:` Connect the complete Mirror feedback loop to prove value delivery.

### Stage 3 – Mirror Refinement (Experience Depth)
**Goal:** Transition from reporting arbitrary scores to providing genuine psychological reflection.
*   `Insight Engine:` Expand `PlayerProfile.gd` to generate actionable observations and recommendations based on hesitation, error deltas, and load indices.
*   `The Mirror UI:` Polish `PlayerProfileScreen.tscn` to render beautifully formatted, color-coded BBCode insights that players actively seek out after every loop.

### Stage 4 – Content Expansion (Horizontal Scaling)
**Goal:** Multiply the validated loop through pure data injection.
*   `Data-Driven Expansion:` Populate the remaining 5 universes (`Life Sciences`, `Tech Ops`, `Creative Arts`, `Society Mind`, `Frontier`) entirely through JSON descriptor vectors (`WorldProfile.json`, `stroop_042.json`).
*   `Zero New Code:` Guarantee that new content streams cleanly through the existing 12 flagship cognitive rendering manifolds without altering any C++ or GDScript code.

### Stage 5 – LiveOps (The Horizon)
**Goal:** Introduce continuous dynamic content rotation and community updates.
*   `Discovery Rotation:` Activate `SamplingController` and `WeeklyFeaturedScreen` to rotate free featured universes based on server seeds.
*   `OTA Ingestion:` Wire `GitHubSyncManager` to automatically download patch manifests and new knowledge datasets to `user://live_content/`.
*   `Longitudinal Telemetry:` Maintain silent cohort logging (`StructuredLogger`) to verify ongoing psychometric validity across global installations.

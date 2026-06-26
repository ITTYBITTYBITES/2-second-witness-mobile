# PRODUCT: 2 Second Witness
# DEFINITIVE STRATEGIC ROADMAP & PRODUCT-FIRST EXECUTION PIPELINE

## Executive Summary
This document establishes the definitive development roadmap for *2 Second Witness*, evaluating the project as a product rather than just a codebase. By reordering priorities around experience maturity, the project ensures that the core retention loop (`Play -> Mirror -> Insight -> Want to play another`) is fully proven before investing in commercial integration or horizontal art expansion.

---

## 1. The Product-First Prioritization Roadmap

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   PRODUCT-FIRST PRIORITIZATION ROADMAP                  │
├──────────────────────────┬──────────────────────────────────────────────┤
│       DEVELOPMENT PHASE  │               STRATEGIC GOAL                 │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 1. Complete Vertical Slic│ History -> Ancient Egypt -> 3 spikes ->      │
│                          │ Mirror -> Insights -> Adaptive recommendation│
├──────────────────────────┼──────────────────────────────────────────────┤
│ 2. Mirror Refinement     │ Enhance interpretation depth. This is where  │
│                          │ differentiation lives (not more questions).  │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 3. Content Pipeline      │ Enable adding Universe -> World -> Knowledge │
│                          │ without touching code.                       │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 4. Visual Expansion      │ Expand into Physics, Astronomy, Medicine,    │
│                          │ Programming, etc.                            │
├──────────────────────────┼──────────────────────────────────────────────┤
│ 5. Billing Integration   │ Mount billing APIs only after the retention  │
│                          │ loop is proven.                              │
└──────────────────────────┴──────────────────────────────────────────────┘
```

### The Definitive Central Hypothesis
Players return because the system continuously adapts to them and reflects meaningful patterns in their performance, not because it has the largest question bank. Once that loop works, additional content and presentation themes become multipliers rather than prerequisites.

---

## 2. Milestone Definitions & Success Metrics

### Stage 1 – Complete Vertical Slice (The Foundation)
**Goal:** Build a single, perfectly executed universe to prove the core loop end-to-end.
*   `Universe & Worlds:` Build out a single Universe (`History`) with 1 to 2 distinct Worlds (`ancient_egypt`).
*   `Cognitive Spikes:` Implement 3 fully bound cognitive tasks (`Memory Cascade`, `Rapid Classification`, `Signal vs Noise`).
*   `Perceptual Themes:` Mount one custom Iris theme per world using the `WorldProfile` data contract.
*   `The Feedback Loop:` Connect the complete Mirror feedback loop to prove value delivery.

### Stage 2 – Mirror Refinement (Experience Depth)
**Goal:** Transition from reporting arbitrary scores to providing genuine psychological reflection.
*   `Insight Engine:` Expand `PlayerProfile.gd` to generate actionable observations and recommendations based on hesitation, error deltas, and load indices.
*   `The Mirror UI:` Polish `PlayerProfileScreen.tscn` to render beautifully formatted, color-coded BBCode insights that players actively seek out after every loop.

### Stage 3 – Content Pipeline (The Horizon)
**Goal:** Enable adding `Universe -> World -> Knowledge` without touching code.
*   `Data-Driven Ingestion:` Build out the complete content pipeline (Knowledge validation, difficulty calibration, content tagging, distractor generation, localization readiness, duplicate prevention, versioning, LiveOps publishing, metadata).
*   `Zero New Code:` Guarantee that new content streams cleanly through the existing 12 flagship cognitive rendering manifolds without altering any C++ or GDScript code.

### Stage 4 – Visual Expansion (Horizontal Scaling)
**Goal:** Multiply the validated loop through pure visual injection.
*   `Data-Driven Expansion:` Populate the remaining universes (`Physics`, `Astronomy`, `Medicine`, `Programming`, `Tech Ops`) entirely through JSON descriptor vectors (`WorldProfile.json`, `stroop_042.json`).

### Stage 5 – Billing Integration (Commercialization)
**Goal:** Mount commercial APIs only after the retention loop is proven.
*   `Live Billing Integration:` Replace the mock async timer in `StoreManager.gd` with the official `GodotGooglePlayBilling` plugin.

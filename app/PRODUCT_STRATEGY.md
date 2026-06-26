# 2 SECOND WITNESS: PRODUCT & RETENTION STRATEGY

**Product Name:** 2 Second Witness
**Underlying Engine:** Liquid Memory V2

## The Definitive Platform Classification
*2 Second Witness* is not a "game with levels" or an "ambitious trivia game with cognitive mechanics." 

It is definitively classified as:
**`An adaptive cognitive experience platform where knowledge domains provide the content, reusable cognitive challenges provide the measurement, the Iris Engine provides the perceptual context, and the Mirror Engine synthesizes player performance into personalized insights that shape future sessions.`**

---

## The Product-First Optimization Target
The project explicitly evaluates development as a product, not just a codebase. A codebase can have clean routing and still have major unknowns in persistence, performance, memory usage, Android lifecycles, scene loading, save migrations, telemetry correctness, balancing, and user experience.

The definitive optimization target for all active agents and developers is:
**`Can a first-time user complete the entire gameplay loop without confusion?`**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      RELEASE ENGINEERING QUESTIONS                      │
├───────────────────────────────────┬─────────────────────────────────────┤
│         NAVIGATION & UI           │       GAMEPLAY & PERSISTENCE        │
├───────────────────────────────────┼─────────────────────────────────────┤
│ • Does Play work?                 │ • Does every Universe launch?       │
│ • Does Discovery work?            │ • Does every Scenario finish?       │
│ • Does Profile work?              │ • Does scoring work?                │
│ • Can player immediately start    │ • Does progression save?            │
│   another scenario?               │                                     │
└───────────────────────────────────┴─────────────────────────────────────┘
```

---

## The Definitive Definition of "Done"
The project formally retires the technical milestone of `Architecture Complete`. True completion is defined exclusively by the first-time user experience flow:

$$\text{Install App} \longrightarrow \text{Understand It} \longrightarrow \text{Play in 10s} \longrightarrow \text{Complete Scenario} \longrightarrow \text{Receive Insight} \longrightarrow \text{Want to Play Another}$$

If this sequence executes consistently, we have a product.

---

## The Dual-Layer Content Architecture

### 1. The Featured Layer (Discovery)
- **Rotation:** Changes weekly based on a server-synced `weekly_rotation_seed`.
- **Purpose:** Content discovery and novelty.
- **Mechanics:** Highlights 6 specific universes, new worlds, and special events. Surfaces monetized unlocks without gating the baseline experience.

### 2. The Personal Layer (Continuity)
- **Persistence:** Never resets.
- **Purpose:** Player affinity and psychological investment.
- **Mechanics:** Tracks lifetime sessions, dominant universes, and cognitive affinities. 

**The Golden Rule of Monetization:**
*Featured = Rotating. Ownership = Persistent.* 
If a player unlocks "Science Lab -> Neural Mapping", that purchase is permanently etched into their `PlayerProfile`. A weekly calendar rollover must never destroy player investment.

## The Player Experience
When a user opens the app, the engine should communicate continuity:
> *Welcome back.*
> *Your dominant universe: Science Lab*
> *Lifetime sessions: 487*
> *New discoveries available: 6*

This transforms the platform from a disposable testing app into a persistent cognitive habit.

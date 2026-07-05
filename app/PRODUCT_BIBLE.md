# 2 SECOND WITNESS — THE PRODUCT BIBLE
**Authoritative Architectural & Pedagogical Specification**

## Executive Summary
This document serves as the single, canonical product specification for **2 Second Witness** (operating commercially as *2 Second Witness*). Its primary purpose is to halt conceptual drift, establishing an uncompromised definition of product ontology, content hierarchy, dual persistence layers, and behavior-driven monetization. 

Every future feature, refactor, or architectural binding must be evaluated directly against the definitions in this Product Bible.

---

## 1. Core Architectural Ontology

```
┌───────────────────────────────────────────────────────────────────────────┐
│                      THE CANONICAL PRODUCT HIERARCHY                      │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   [UNIVERSE] (e.g., History)                                              │
│       │                                                                   │
│       └──> [WORLD] (e.g., Ancient Egypt)                                  │
│               │                                                           │
│               └──> [SCENARIO SET] (e.g., Life Along the Nile)             │
│                       │                                                   │
│                       ├──> [KNOWLEDGE EXPOSURE 1] (e.g., Nile Inundation) │
│                       │       └──> [COGNITIVE MECHANIC] (Memory Cascade)  │
│                       │                                                   │
│                       ├──> [KNOWLEDGE EXPOSURE 2] (e.g., Akhet Season)    │
│                       │       └──> [COGNITIVE MECHANIC] (Stroop Test)     │
│                       │                                                   │
│                       └──> [KNOWLEDGE EXPOSURE 3] (e.g., Shaduf System)   │
│                               └──> [COGNITIVE MECHANIC] (Signal vs Noise) │
│                                       │                                   │
│                                       └──> [MIRROR LEARNS]                │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

### 1. What is a Universe?
A **Universe** is a top-level macro-domain of human knowledge and inquiry (e.g., `History`, `Science Lab`, `Creative Arts`, `Frontier`, `Society & Mind`, `Technology`, `Life Sciences`). A Universe governs the macro visual identity, color palettes, emotional profiles, audio stems, and thematic ubershader behaviors within the Iris Engine. It is the primary container for individual Worlds.

### 2. What is a World?
A **World** is a specific, cohesive sub-discipline or historical epoch contained within a Universe (e.g., `Ancient Egypt` within `History`, `Cellular Biology` within `Life Sciences`, `Disaster Response` within `Frontier`). A World represents a dedicated learning environment containing specific lore, factual ontologies, and distinct presentation contracts (`WorldProfile.json`).

### 3. What is a Scenario?
A **Scenario** is a discrete, interactive educational encounter within a World. It acts as the narrative and pedagogical wrapper for a specific body of knowledge. In the 2 Second Witness paradigm, the educational content drives the experience; the Scenario establishes the context, lore, and factual baseline before any cognitive stress testing begins.

### 4. What is a Scenario Set?
A **Scenario Set** is a curated, multi-part episodic lesson plan (e.g., `Scenario Set: Building the Pyramids`). It aggregates multiple related Scenarios into a coherent thematic journey. A Scenario Set functions as an interactive chapter of a "living textbook," taking the player through a progression of related knowledge exposures under varying cognitive stresses.

### 5. What is a Curated Mission?
A **Curated Mission** is an explicit, pre-authored sequencing contract within a World that links a specific Scenario Set to a fixed progression of cognitive mechanics (e.g., `Life Along the Nile` bound strictly to `Memory Cascade -> Stroop -> Signal vs Noise -> Spatial Recall`). Curated Missions ensure that a first-time player experiences a highly polished, intentionally paced narrative encounter rather than a random assortment of prompts.

### 6. What is a Cognitive Mechanic?
A **Cognitive Mechanic** is a pure, domain-agnostic psychometric measuring instrument (`MemoryCascade`, `StroopTest`, `RapidClassification`, `SignalVsNoise`, `SpatialRecall`, `SequenceReverse`, `ReflexTap`, `SpeedSort`). Cognitive Mechanics contain zero educational lore or universe-specific logic. They act strictly as the interactive stimulus medium through which the underlying knowledge exposures are processed and measured under time pressure.

### 7. What is a Knowledge Exposure?
A **Knowledge Exposure** is a 2-second flash of factual stimulus (a concept, artifact, symbol, or term) presented to the player inside a Cognitive Mechanic. The objective of the exposure is not to test memorized trivia, but to act as the raw cognitive substrate upon which reaction time, hesitation index, decision confidence, and pattern stability are empirically observed.

---

## 2. The Dual Persistence Layers

The 2 Second Witness architecture strictly isolates data persistence into two orthogonal operational layers: **Permanent** and **Weekly**.

```
┌───────────────────────────────────────────────────────────────────────────┐
│                          DUAL PERSISTENCE LAYERS                          │
├─────────────────────────────────────┬─────────────────────────────────────┤
│         PERMANENT LEDGER            │           WEEKLY LEDGER             │
├─────────────────────────────────────┼─────────────────────────────────────┤
│ • Player Profile (`profile.save`)   │ • Active Scenario Pool              │
│ • Cognitive Traits & Baselines      │ • Weekly Leaderboard Rankings       │
│ • The Mirror Insights     │ • Featured Free Worlds              │
│ • Append-Only Purchase Ledger       │ • Daily & Weekly Challenges         │
│ • Unlocked Achievements & Mastery   │ • Live Local Content Cache          │
└─────────────────────────────────────┴─────────────────────────────────────┘
```

### 8. What is stored permanently?
*   **The Player Profile & Mirror:** All 6 core cognitive trait baselines (`Pattern Recognition`, `Recall`, `Rapid Classification`, `Spatial Tracking`, `Decision Confidence`, `Processing Speed`), longitudinal performance histories, Bayesian drift vectors, and generated psychological insights.
*   **The Entitlement Ledger:** An append-only, event-sourced transaction log (`purchase_receipt_log`) recording every unlocked Universe, Director's Pass ownership status, and physical store receipt.
*   **Lifetime Milestones:** Total lifetime session counts, accumulated World mastery affinity scores, and unlocked achievements.

### 9. What resets weekly?
*   **The Competition Layer:** All weekly leaderboard rankings, competitive percentiles, and weekly challenge completion statuses reset to zero every Monday at 00:00 UTC.
*   **The Free Rotation:** The active pool of featured free Universes and Worlds rotates, locking previously featured content and unlocking a fresh set of weekly exploration targets.
*   **Dynamic Scenario Pools:** The active sampling buffer of available scenario chunks is flushed and repopulated with freshly generated weekly content distributions.

---

## 3. The Content & LiveOps Pipeline

```
┌───────────────────────────────────────────────────────────────────────────┐
│                       THE LIVING TEXTBOOK PIPELINE                        │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   [BASE APK INSTALL] (Playable Forever Offline via `base_bundle/`)        │
│       │                                                                   │
│       └──> [WEEKLY GITHUB GENERATOR] (Automated CI Content Synthesis)     │
│               │                                                           │
│               └──> [MANIFEST UPDATE] (Bumps `manifest.json` version)      │
│                       │                                                   │
│                       └──> [GITHUB SYNC MANAGER] (Pings remote manifest)  │
│                               │                                           │
│                               └──> [DOWNLOAD & VALIDATE] (JSON Linter)    │
│                                       │                                   │
│                                       └──> [LOCAL CACHE REPLACEMENT]      │
│                                               │                           │
│                                               └──> [LEADERBOARD RESET]    │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

### 10. What ships in the APK?
The physical application package (APK) ships with a fully realized, immutable baseline content set (`res://data/content/base_bundle/`). This includes:
*   Starter Universes (`History`, `Science Lab`).
*   Starter Worlds (`Ancient Egypt`, `Cognitive Bias`).
*   The complete 250-item Ancient Egypt knowledge catalog (`spikes_catalog_250.json`).
*   All essential 3D meshes, ubershaders, environmental noise textures, and `.wav` audio stems.
**Core Rule:** The app must function flawlessly offline forever on first launch without requiring a single network request.

### 11. What is downloaded later?
Over-The-Air (OTA) patches, new JSON scenario sets, dynamic world profiles, and expanded knowledge catalogs are downloaded asynchronously into `user://live_content/patches/` by the `GitHubSyncManager`. These files cleanly overwrite or expand the base runtime registry without mutating the physical APK assets.

### 12. What is generated automatically?
Every week, an automated remote content synthesis pipeline (the GitHub Generator) parses factual ontologies to generate fresh JSON scenario bundles, newly balanced challenge prompts, and updated version manifests (`manifest.json`), publishing them directly to the remote master repository.

---

## 4. Behavior-Driven Monetization

```
┌───────────────────────────────────────────────────────────────────────────┐
│                        BEHAVIOR-DRIVEN MONETIZATION                       │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   [PLAYER PLAYS FREE WORLDS] (Engages with Weekly Rotations)              │
│       │                                                                   │
│       └──> [HIGH AFFINITY DETECTED] (Mirror tracks dominant Universe)     │
│               │                                                           │
│               └──> [RECOMMEND PREMIUM UNIVERSE] (Targeted unlocking)      │
│                       │                                                   │
│                       └──> [PURCHASE ONCE] (Immediate runtime unlock)     │
│                               │                                           │
│                               └──> [RECEIVE LARGER WEEKLY UPDATES FOREVER]│
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

### 13. What is premium?
*   **Permanent Universe Ownership ($2.99):** Unlocking a premium Universe grants permanent, unrestricted access to all current and future Worlds within that Universe, bypassing the weekly rotation lock entirely. Unlocked premium Universes receive larger, dedicated weekly OTA content updates forever.
*   **The Director's Pass ($7.99):** A one-time premium entitlement that permanently strips all interstitial advertisements, forced banner displays, and monetization gates from the experience without bypassing gameplay locks or altering content progression.

### 14. What is free?
*   **The Base Bundled Slice:** Permanent free access to the flagship starter Worlds (`History -> Ancient Egypt` and `Science Lab -> Cognitive Bias`).
*   **Weekly Featured Content:** Free exploration access to 3 dynamically rotating Universes and their respective featured Worlds every week.
*   **The Mirror:** Unrestricted, permanent access to the player's evolving psychological profile, trait baselines, and weekly observation trends.

---

## 5. Longitudinal Mirror Evolution

### 15. How does the Mirror evolve over months?
The Mirror is engineered to transform from a simple onboarding guide into a profound psychological dashboard over extended months of play.

```
┌───────────────────────────────────────────────────────────────────────────┐
│                      LONGITUDINAL MIRROR EVOLUTION                        │
├──────────────────────┬────────────────────────────────────────────────────┤
│   LIFECYCLE STAGE    │             ACTIVE MIRROR PRESENTATION             │
├──────────────────────┼────────────────────────────────────────────────────┤
│ Day 1 (0 Sessions)   │ • Onboarding Welcome Copy                          │
│                      │ • Progress Metrics: `0 Universes, 0 Worlds`        │
│                      │ • `BEGIN JOURNEY` Onboarding Action                │
├──────────────────────┼────────────────────────────────────────────────────┤
│ Week 1 (5+ Sessions) │ • 6 Cognitive Trait Summaries (Attempts, Avg RT)   │
│                      │ • Initial Observation Trends (`Working Memory: ↑`) │
│                      │ • Single Universe Adaptive Recommendations         │
├──────────────────────┼────────────────────────────────────────────────────┤
│ Month 3 (50+ Sessions│ • Rich Longitudinal Drift Vectors & Radar Maps     │
│                      │ • Cross-Universe Behavioral Archetype Insights     │
│                      │ • E.g., `"You tend to solve structured problems.   │
│                      │   Creative Arts explores divergent thinking."`     │
└──────────────────────┴────────────────────────────────────────────────────┘
```

**Definitive Framing Rule:** Nothing in the Mirror is ever framed as a static intelligence score, pass/fail grade, or judgment. Everything is presented exclusively as an empirical, non-judgmental observation of the player's interaction patterns under time pressure.

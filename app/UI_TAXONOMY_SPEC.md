# PRODUCT: 2 Second Witness
# DEFINITIVE UI TAXONOMY & 3-LAYER SEPARATION SPECIFICATION

## Executive Summary
This document establishes the definitive user interface taxonomy and architectural separation for *2 Second Witness*. By formalizing the boundary between persistent global utilities and simulation state routing, the project enforces a clean **3-Layer Separation (HUD / Navigation / Simulation)**. This structure resolves all cognitive ambiguity regarding the placement of the Cognitive Mirror and establishes the exact structural ownership of `WorldSelectScreen`.

---

## 1. The Three UI Classes & Structural Ownership

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     3-LAYER UI SEPARATION HIERARCHY                     │
├──────────────────────────┬──────────────────────────┬───────────────────┤
│     ARCHITECTURAL LAYER  │   TARGET NODE CONTAINER  │  UI SCREEN SCOPE  │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 1. HUD Layer             │ MainShell/UILayer/       │ • Persistent HUD  │
│    (Persistent Utility)  │ HUDRoot                  │ • Leave Stream Btn│
│                          │                          │ • Mirror Button   │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 2. Navigation Layer      │ MainShell/UILayer/       │ • LandingScreen   │
│    (State Progression)   │ NavigationUI             │ • WeeklyFeatured  │
│                          │                          │ • WorldSelectScree│
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ 3. Simulation Layer      │ MainShell/WorldLayer &   │ • Crystalline Iris│
│    (Deep Runtime Task)   │ ScenarioUI               │ • Memory Cascade  │
│                          │                          │ • Active Scenarios│
└──────────────────────────┴──────────────────────────┴───────────────────┘
```

---

## 2. The Orthogonality of the Two Graphs
The system explicitly rejects the assumption that the Cognitive Mirror (`PlayerProfileScreen`) is part of the state progression flow. The architecture enforces two completely orthogonal graphs that intersect exclusively through `ModalWindowManager` stack control:

### A. The Navigation Graph (State Progression)
$$\text{LandingScreen} \longrightarrow \text{WeeklyFeaturedScreen (Universe)} \longrightarrow \textbf{WorldSelectScreen (World)} \longrightarrow \text{ScenarioNode (Spike)}$$
*   `Router Authority:` Governed exclusively by `NavigationRouter`.
*   `Core Principle:` Every transition mutates the active simulation state. These screens never sit floating at the top layer unless contextually active.

### B. The Utility Graph (Persistent Global Modals)
$$\text{HUDRoot Buttons} \longrightarrow \text{PlayerProfileScreen (Mirror)} \quad \big| \quad \text{MonetizationGate (Store)}$$
*   `Modal Authority:` Governed exclusively by `ModalWindowManager`.
*   `Core Principle:` The Cognitive Mirror is deliberately global. It must be accessible from multiple states, does not depend on universe or world context, and does not mutate the active navigation state graph.

---

## 3. Resolving the "Missing Middle" Ambiguity
The historical perception that the Cognitive Mirror button was misplaced or "too high" in the menu hierarchy was an optical illusion caused by the missing `WorldSelectScreen`. 

By establishing `WorldSelectScreen` as the mandatory intermediate abstraction layer within `NavigationUI`, the navigation hierarchy is fully restored. The Cognitive Mirror is formally confirmed as a persistent global modal utility operating perfectly in the topmost HUD layer.

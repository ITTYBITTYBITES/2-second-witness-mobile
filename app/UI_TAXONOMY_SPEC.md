# PRODUCT: 2 Second Witness
# DEFINITIVE UI TAXONOMY & 3-LAYER SEPARATION DOCUMENTATION

## 1. Architectural Documentation (Not Runtime Governance)
This document provides a definitive mental model and architectural documentation for the user interface taxonomy of *2 Second Witness*. In accordance with Godot's underlying scene tree physics, nothing in this specification possesses runtime authority unless explicitly parsed and enforced by active scene instancing rules and singleton scripts. This file serves strictly as documentation, not governance.

---

## 2. The Three-Layer Separation Hierarchy

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

## 3. The Mandatory Constraints of HUD Utility Classification
The Mirror (`PlayerProfileScreen`) is classified as a pure HUD utility. This classification is valid only because `Mirror` satisfies three strict runtime constraints simultaneously:
1. **Zero Navigation Dependency:** It does not depend on navigation state (world or world-select context).
2. **Zero Simulation Mutation:** It does not mutate simulation state directly (zero gameplay-altering writes).
3. **Zero Uninvoked Blocking:** It does not block HUD interaction flow (no persistent modal lock unless explicitly invoked by the player).

---

## 4. The Orthogonality of the Two Graphs (Eliminating Stack Ambiguity)
The architecture formally rejects the practice of calling `scene_shift` to invoke HUD utility actions. Calling `scene_shift` for the Mirror represents a scene transition that silently collapses the 3-layer model into a 2-layer navigation system with overlays. 

To maintain absolute long-term stability, the system enforces two completely orthogonal graphs that intersect **exclusively via `ModalWindowManager`**:

### A. The Navigation Graph (Reachable & Linear)
$$\text{LandingScreen} \longrightarrow \text{WeeklyFeaturedScreen} \longrightarrow \text{WorldSelectScreen} \longrightarrow \text{ScenarioNode}$$
*   `Routing Mechanism:` Governed exclusively by `NavigationRouter` via `scene_shift` intents.

### B. The HUD Utility Graph (Orthogonal Quick Access)
$$\text{HUDRoot Buttons (Mirror, Leave, Store, Profile)} \longrightarrow \text{ModalWindowManager.push("mirror")}$$
*   `Instancing Rule:` The Mirror is instanced once under `HUDRoot` and toggled via `visible` or `ModalWindowManager.push("mirror")`. Zero overlap, zero routing crossover.

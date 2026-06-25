# PRODUCT: 2 Second Witness
# DEFINITIVE STRATEGIC ROADMAP & TWO-PHASE PRODUCT LIFECYCLE

## Executive Summary
This document establishes the definitive product roadmap for *2 Second Witness*. By separating infrastructure validation from spatial presentation, the project adopts a pragmatic, two-phase product lifecycle. This strategy ensures that the core psychometric value proposition (`Play -> Insight -> Progress -> Repeat`) is fully validated in a shipment-ready binary before transitioning to an immersive spatial interaction model.

---

## 1. The Two-Phase Product Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     TWO-PHASE PRODUCT LIFECYCLE                         │
├───────────────────────────────────┬─────────────────────────────────────┤
│   VERSION 1.x (BUILD THE PRODUCT) │   VERSION 2.x (IMMERSION UPDATE)    │
├───────────────────────────────────┼─────────────────────────────────────┤
│ • Proves cognitive engine works   │ • 2D CanvasLayer UI disappears      │
│ • Conventional 2D button menus    │ • Menu buttons become 3D constructs │
│ • Complete 12-scenario matrix     │ • Discovery grid becomes orbiting   │
│ • Production monetization wiring  │   3D universe map                   │
│ • Flawless 60FPS Android lock     │ • Profile becomes living 3D Mirror  │
└───────────────────────────────────┴─────────────────────────────────────┘
```

### Version 1.x (Build the Product)
The primary objective of Version 1.x is proving that the cognitive engine works. The application utilizes a clean, conventional 2D button interface (`CanvasLayer`) that acts as an uncompromised gateway to the psychometric engine. 
*   `Core Value Loop:` Open App $\rightarrow$ Play $\rightarrow$ Complete Scenario $\rightarrow$ Receive Insight $\rightarrow$ Progress $\rightarrow$ Unlock $\rightarrow$ Repeat.
*   `Success Criteria:` Stable navigation, complete gameplay loop, all 12 scenarios fully implemented, persistent player profile saving/loading, weekly discovery rotations, production monetization wiring (`AdMob` / `Google Play Billing`), and visual polish.

### Version 2.x (The Immersion Update)
Version 2.x represents a monumental feature update where the 2D user interface disappears entirely, transitioning the application into a true immersive spatial cognitive simulation.
*   `Spatial Menu:` `[Play]`, `[Discover]`, and `[Profile]` buttons become three floating holographic constructs suspended in the 3D tunnel void.
*   `Orbiting Discovery:` The `WeeklyFeaturedScreen` grid dissolves as the tunnel blossoms into six floating 3D universe portals orbiting around the player.
*   `Living Cognitive Mirror:` The `PlayerProfileScreen` text panel is replaced by a 3D "Cognitive Mirror" where psychological traits orbit like constellations and statistics become living visualizations.
*   `Continuous Traversal:` `Return` buttons vanish; the camera actively navigates world space to transition between game states.

---

## 2. The 3-Milestone Execution Strategy

### Milestone 1 – Functional Beta
**Goal:** Complete the core value loop and eliminate all technical debt.
*   Complete every navigation path across `NavigationRouter`.
*   Ensure every button hitbox functions flawlessly with zero input swallowing.
*   Verify every universe launches cleanly via `PortalLayerManager`.
*   Finish the data binding and payload injection for all 12 flagship scenarios.
*   Enforce local I/O persistence (`user://profile.save`).
*   Fix all remaining 2D Control alignment and layout issues.
*   Eliminate dead ends, empty containers, and placeholder screens.

### Milestone 2 – Public Release
**Goal:** Polish the vertical slice and ship to the Google Play Store.
*   Improve UI tween animations and ubershader transitions.
*   Refine the visual glass styleboxes and typography.
*   Optimize multi-mesh buffer pooling to guarantee a flawless 60FPS lock on Android hardware.
*   Mount production AdMob keys and Google Play Billing bridges.
*   **Ship Version 1.0.0.**

### Milestone 3 – "Immersion Update" (Version 2.x)
**Goal:** Transform the application into an immersive spatial simulation.
*   Replace 2D buttons with 3D spatial interaction hitboxes (`Area3D`).
*   Replace 2D CanvasLayer menus with floating world portals.
*   Replace profile screens with the 3D Cognitive Mirror.
*   Replace discovery screens with the living universe map.
*   Replace dialogs with diegetic holographic overlays.
*   Replace scene swapping with continuous world traversal.

---

## 3. Architectural Readiness for V2
The backend architecture (`InteractionKernel`, `WorldAssetCompiler`, `RuntimeMeasurementIsolation`, `NavigationRouter`, `ModalWindowManager`) is fully decoupled from the presentation layer. 

Because the singletons operate on explicit intent dictionaries (`commit_intent({"type": "enter_stream"})`) and maintain separate modal locks per input modality, transitioning from 2D `Button` nodes to 3D `Area3D` RayCasts in Version 2.x requires zero modifications to the underlying control flow or telemetry singletons. The foundation is 100% complete and fully scalable.

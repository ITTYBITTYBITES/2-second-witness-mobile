# PRODUCT: 2 Second Witness
# DEFINITIVE INTERACTION DESIGN UNDER CONSTRAINT SPECIFICATION

## 1. System Classification
**Classification:** `A multi-domain state orchestration system with serialized mutation guarantees and phase-local consistency enforcement over a retained-mode engine.`

**Definitive Invariant:** `Causally consistent within a constrained mutation boundary.`

* `Input Layer (Arbiter):` Filters and Scopes Intent ✔
* `Mutation Layer (Ledger):` Serializes Side Effects ✔
* `Navigation Layer (Router):` Interprets Intent ✔
* `Presentation Layer (ModalManager):` Reflects State (Controlled Stack Machine) ✔

---

## 2. Stability from Constraint (Not Synchronization)
The system formally acknowledges that Godot's retained-mode scene graph operates across interleaved subsystems (`MODAL PUSH`, `AD STATE CHANGE`, `ARBITER TRANSITION RESOLUTION`, `ROUTER EXECUTION`). There is no single point where the entire system state is globally synchronized or coherent at a single instant. 

Instead, the architecture achieves **ordering consistency, not temporal atomicity**. Each subsystem is coherent when observed in isolation. 

The definitive truth of the platform is that **stability emerges from constraint, not synchronization**. By restricting where state can change, controlling when state is allowed to propagate, and preventing cross-layer mutation leakage, the system successfully eliminates uncontrolled mutation paths and enforces a single directional state flow.

---

## 3. Visual Inconsistency Tolerance Matrix (Interaction Design)
To maintain a visceral, high-performance interaction machine, the architecture formally defines which visual inconsistencies are permitted to exist during transitions without becoming user-observable failure states:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                 VISUAL INCONSISTENCY TOLERANCE MATRIX                   │
├──────────────────────────┬──────────────────────────┬───────────────────┤
│    TRANSITION WINDOW     │   VISUAL INCONSISTENCY   │   DESIGN JUSTIFICATION  │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ • Menu UI Fade-Out       │ • Hitboxes visible while │ • Arbiter lock active.  │
│   (Landing / Discovery)  │   alpha > 0 (up to 500ms)│   Ghost clicks prevented│
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ • World Lens Spawning    │ • 3D tunnel active while │ • Unbroken momentum.    │
│   (PortalLayerManager)   │   Iris expands (900ms)   │   Spatial immersion lock│
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ • AdMob Interstitial     │ • Video canvas (Layer 110│ • Seamless ad handoff.  │
│   (AdManager / Ledger)   │   spawns over active UI  │   Zero black-screen flash│
└──────────────────────────┴──────────────────────────┴───────────────────┘
```

### A. Transitional Alpha Masking (Tolerance: 500ms)
During menu hide transitions (`LandingScreen.hide_screen`), button hitboxes remain visually present on screen while `modulate:a` tweens to `0.0` over 500ms. This temporary divergence between visual state and input state is fully permitted because `UIInputArbiter` asserts `TRANSITIONAL_LOCK`, instantly stripping input authority from the panel to permanently prevent ghost clicks.

### B. Asynchronous Tunnel Geometry Continuity (Tolerance: 900ms)
When `NavigationRouter` spawns a World Lens portal, the 3D hexagonal multi-mesh stream continues to render at the background flow rate while the Crystalline Iris expands over 900ms. The visual overlap between the idle menu state and active stream state is intentionally preserved to maintain unbroken spatial momentum.

### C. Ad Gate Handoff Interleaving (Tolerance: 3000ms)
During interstitial video triggers (`AdManager`), the simulated video canvas layer (`layer = 110`) spawns directly over the active UI before the underlying screens are freed. This visual layering overlap is actively embraced to prevent single-frame black flashes during the asynchronous ad callback.

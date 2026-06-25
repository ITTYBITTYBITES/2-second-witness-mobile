# PRODUCT: 2 Second Witness
# FORMAL CONSISTENCY CONTRACT & SIMULATION DESIGN PHILOSOPHY

## 1. System Classification
**Classification:** `A staged interaction orchestration runtime over a retained-mode engine.`

**Operating Model:** `A multi-stage deterministic interpreter over engine events.`

* `Modal Layer:` Defines Visibility + Exclusivity Domain ✔
* `Arbiter Layer:` Defines Input Eligibility Domain ✔
* `Ledger Layer:` Defines Mutation Serialization Domain ✔
* `Router Layer:` Defines Navigation Semantics Domain ✔

---

## 2. The Time-Sliced Consistency Model
The system explicitly rejects the assumption of a globally synchronized, atomic execution graph. Godot's underlying retained-mode scene graph operates across decoupled engine loop phases (`_input`, `_gui_input`, `_process`, `_physics_process`). 

To achieve absolute runtime stability without fighting the engine's inherent nondeterminism, *2 Second Witness* operates on a **time-sliced consistency model**. Each subsystem is completely consistent within its own execution phase, but is not required to be globally synchronized at all instants.

The system is not "fully deterministic"—it is **deterministically structured**. It operates definitively as a `controlled event-to-command-to-mutation pipeline layered over a non-deterministic engine runtime`.

---

## 3. Contract of Permissible State Incoherence
To maintain a high-performance interaction machine, the architecture formally defines what parts of state are permitted to be temporarily incoherent between execution phases:

### A. Transitional UI Instantiation Incoherence
During active scene shifts (e.g., `NavigationRouter` swaps), visual instantiation of new CanvasLayers and tween fades may interleave in time with the central Arbiter unlock. Intermediate visual states are fully permissible during transition windows, provided that the `UIInputArbiter` maintains active transitional lock buffer suppression (`TRANSITIONAL_LOCK`).

### B. Frame-Boundary Mutation Lag
UI button intent (`SIGNAL PRESSED`) and physical scene tree mutations (`queue_free()`, `add_child()`) are strictly decoupled. The scene tree reflects the last committed state until the `InteractionLedger` drains its command buffer during `_process()`. This frame-boundary lag is an intentional buffer designed to permanently eradicate use-after-free pointer race conditions.

---

## 4. Unified Control Plane Governance
To eliminate divergence between "visible modal state" and "allowed input state," the architecture establishes a strict unidirectional control pipeline:

$$\text{Modal Stack} \longrightarrow \text{UIInputArbiter} \longrightarrow \text{InteractionLedger} \longrightarrow \text{NavigationRouter}$$

`ModalWindowManager` surrenders all independent input arbitration logic, operating strictly as a visibility and stack ownership graph that delegates input eligibility entirely to the central `UIInputArbiter`. This unifies the control plane under a single, unassailable authority model.

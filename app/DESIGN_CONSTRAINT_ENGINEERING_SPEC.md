# PRODUCT: 2 Second Witness
# DEFINITIVE DESIGN CONSTRAINT ENGINEERING SPECIFICATION

## 1. System Classification
**Classification:** `A command-governed interaction layer enforcing explicit mutation contracts over a retained-mode engine.`

**Operating Model:** `A governed mutation substrate over a partially ordered execution environment.`

* `Timing Authority:` Godot Engine (Partially Ordered Execution Environment) ✔
* `Mutation Authority:` Governed Mutation Substrate (Intentional Project-Level Mutations) ✔
* `Core Principle:` Stability Emerges from Elimination of Untracked Side Effects ✔
* `Definitive Invariant:` Consistency Guaranteed at Mutation Surface (Not Instantaneous Engine State) ✔

---

## 2. The Limits of Authority & Traceability of Mutation
The system explicitly acknowledges that Godot's underlying execution layer injects state outside the project control plane (`_notification()` callbacks during tree changes, deferred frees executed between frames, animation tracks invoking methods mid-cycle, asynchronous resource completion). 

Because rendering, physics, input, and signals are fundamentally **not synchronized domains in Godot**, the architecture rejects the claim of an "unassailable authority layer over everything." 

Instead, the system operates as an authority layer exclusively over **all intentional project-level mutations**. The architecture does not enforce global execution order; it enforces **traceability of mutation**. By funneling all explicit state changes through a single command bus, the governed mutation substrate transforms a non-deterministic engine into a predictably behaved application layer.

---

## 3. Subsystem Incoherence Tolerance Matrix
To achieve maximum performance without fighting the irreducible temporal inconsistencies between engine subsystems, the architecture formally defines the maximum permissible incoherence lag per domain before it becomes visible to the player:

```
┌─────────────────────────────────────────────────────────────────────────┐
│               SUBSYSTEM INCOHERENCE TOLERANCE THRESHOLDS                │
├──────────────────────────┬──────────────────────────┬───────────────────┤
│     SUBSYSTEM PAIR       │   TOLERANCE THRESHOLD    │ ENFORCEMENT LAYER │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ • Rendering vs. Input    │ • 33.3 ms (1-2 frames)   │ • UIInputArbiter  │
│   (Modal push visual lag)│   (Transitional masking) │   (TRANSITIONAL)  │
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ • Physics vs. UI         │ • 50.0 ms (3 frames)     │ • NavigationRouter│
│   (Slingshot momentum)   │   (Immersion continuity) │   (Async dispatch)│
├──────────────────────────┼──────────────────────────┼───────────────────┤
│ • Signal vs. Navigation  │ • 0.0 ms (Hard Boundary) │ • InteractionLedge│
│   (Teardown re-entrancy) │   (Zero re-entrancy)     │   (Execution Lock)│
└──────────────────────────┴──────────────────────────┴───────────────────┘
```

### A. Rendering vs. Input Incoherence (Tolerance: 33.3 ms)
During modal window pushes (`ModalWindowManager`), visual instantiation of glass panels and button hitboxes may lag behind input locking by 1 to 2 frames. This temporary incoherence is fully tolerated because `UIInputArbiter` asserts `TRANSITIONAL_LOCK`, masking the visual lag from the player's hit testing.

### B. Physics vs. UI Incoherence (Tolerance: 50.0 ms)
When a Cognitive Spike resolves (`_on_cascade_completed`), the 200% velocity slingshot re-entry impulse in `TunnelController` operates on the physics step (`_physics_process`), while the UI menu fades operate on the idle frame (`_process`). Up to 50ms of interleaving is tolerated because the visceral momentum impulse actively preserves player immersion during the asynchronous handoff.

### C. Signal Teardown vs. Navigation Incoherence (Tolerance: 0.0 ms)
During active scene transitions (`change_scene`), old nodes emitting teardown signals (`_exit_tree`) represent a severe risk of mixed-frame execution. The system enforces a **0.0 ms hard boundary**. `InteractionLedger` asserts `_is_committing_side_effects`, instantly trapping and suppressing any re-entrant signal attempting to mutate the navigation graph.

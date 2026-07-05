# ARCHITECTURE_STABLE_v1

**Phase:** 7 — Semantic Freeze Protocol · **Mode:** READ-ONLY (NO STRUCTURAL CHANGES) · **Effective:** 2026-07-05

> This document is a **permanent interpretation layer** over the existing codebase. It does not change code, rename systems, remove duplicates, merge architecture, or refactor anything. It freezes how humans interpret the system as it exists right now — so the meaning cannot quietly drift while the project grows on top of it.

---

## 1. ARCHITECTURAL TRUTH STATEMENT

- The runtime system is considered **production-stable as of Phase 6**.
- **No system restructuring is permitted in Phase 7.** This phase is interpretation-only.
- All prior ambiguity has been resolved via **classification and documentation**, not via refactor.
  - The navigation three-way split (Router / Engine / State) is a valid, documented boundary — not a defect to be merged.
  - The content pipeline is locked and validated (zero bypasses found in Phases 4–5).
  - The single progression authority (`PlayerProfile`) and single content authority (`ContentRegistry`) are confirmed.
- The structure is what it is. Phase 7 locks *what that means*.

---

## 2. LOCKED SYSTEM MODEL

The runtime is interpreted as **5 conceptual layers**. Every autoload fits exactly one layer. A system that does not fit is rejected (see §3).

```
┌──────────────────────────────────────────────────────────────┐
│ 2.1 INPUT LAYER        InteractionKernel                     │
│                        (canonical input routing)             │
├──────────────────────────────────────────────────────────────┤
│ 2.2 NAVIGATION LAYER   NavigationRouter (authority)          │
│                        NavigationEngine (presentation flow)   │
│                        NavigationState (context only)        │
├──────────────────────────────────────────────────────────────┤
│ 2.3 CONTENT LAYER      ContentRegistry (single truth)        │
│                        ObservationCollection (access layer)   │
│                        ObservationBuilder (stateless)         │
│                        ScenarioExecutionEngine (execution)    │
│                        ContentLoader (sole ingestion path)    │
├──────────────────────────────────────────────────────────────┤
│ 2.4 PROGRESSION LAYER  PlayerProfile (sole authority)        │
│                        derived systems only (read-only)       │
├──────────────────────────────────────────────────────────────┤
│ 2.5 SUPPORT LAYER      assets, diagnostics, instrumentation, │
│                        validation, presentation, monetization │
└──────────────────────────────────────────────────────────────┘
```

### 2.1 Input Layer
- **`InteractionKernel`** — canonical implementation. Handles all player input routing. 1 physical input → 1 consumable token. No system arbitrates its own input eligibility independently.

### 2.2 Navigation Layer
- **`NavigationRouter`** — authority. Owns which screen is active; owns scene_shift intents.
- **`NavigationEngine`** — presentation flow. Owns transition animation + portal sequencing. Reacts to Router.
- **`NavigationState`** — context only. Immutable enum + transition data; cannot trigger transitions.

### 2.3 Content Layer
- **`ContentRegistry`** — single source of truth for all content (universes, worlds, scenarios, playability).
- **`ObservationCollection`** — runtime access layer (selection, filtering, replay protection, deterministic seeding).
- **`ObservationBuilder`** — stateless transform (observation → gameplay payload). No state, no side effects.
- **`ScenarioExecutionEngine`** — execution authority (gameplay lifecycle, measurement-locked timing).
- **`ContentLoader`** — sole ingestion path (JSON → normalize → register_scenario). No other system reads bank files.

### 2.4 Progression Layer
- **`PlayerProfile`** — sole authority. Writes all progression state (XP, level, title, coins, unlocks, cognitive baseline).
- **Derived systems (read-only):** `MirrorNarrator`, `ProgressionInterpreter`, `SessionTracker`. These may read PlayerProfile but must never write progression state.

### 2.5 Support Layer
- **Asset loading:** `AssetManifestRegistry` (path resolution — distinct domain from ContentRegistry).
- **Presentation:** `ThemeManager`, `VisualIdentityManager`, `WorldProfileCustodian`, `FeedbackManager`, `LensMorphology`, `PresentationToolkit`.
- **Instrumentation:** `StructuredLogger`, `DiagnosticAutomator`, `BootTracer`, `IVC0_InstrumentConfig`, `RuntimeMeasurementIsolation`, `SystemHealthMonitor`.
- **Governance:** `ExperienceOrchestrator`, `FidelityEnforcer`, `RuntimeInvarianceMonitor`, `ModalWindowManager`.
- **Sampling/rotation:** `SamplingController`, `WeeklyRotationManager`.
- **Monetization/external:** `StoreManager`, `StoreTransactionState`, `AdManager`, `GoodwillManager`, `AudioManager`, `GameplayDirector`, `GitHubSyncManager`.

---

## 3. IMMUTABILITY RULES

These are the load-bearing invariants of the frozen architecture. Any future change that violates one is **rejected by definition** unless it ships under a new versioned freeze document (v2, v3, …).

1. **No new system may bypass `ContentRegistry`.** All content queries go through the registry; all scenario registration goes through `ContentRegistry.register_scenario()`, called only by `ContentLoader`.
2. **No new input system may bypass `InteractionKernel`.** Input eligibility is centralized; no system may self-arbitrate input.
3. **No new navigation system may bypass `NavigationRouter`.** All screen transitions go through the Router. `change_scene` / `change_scene_to` calls outside Router/Engine are forbidden.
4. **No new progression system may be introduced without replacing ALL derived logic.** `PlayerProfile` is the sole write authority. Introducing a competing progression writer requires retiring every dependent derived reader (`MirrorNarrator`, `ProgressionInterpreter`, `SessionTracker`) — i.e. a full versioned migration, not an additive change.
5. **All new systems must fit into an existing layer (§2) or be rejected.** A system that spans layers or introduces a sixth layer is rejected unless covered by a new freeze version.
6. **All scenarios must extend `BaseScenario`.** No scenario may load its own content or hold its own observation data.
7. **All new content is data + registry only.** Adding a universe/world/observation requires no engine-code change and no new system — only data files and a registry entry.

---

## 4. ALIAS RESOLUTION IS NOW LOCKED

From this point forward, the following resolutions are frozen. **No further renaming is permitted** in this or any subordinate phase without a new versioned freeze.

| Concept | Locked Resolution |
|---|---|
| `UIInputArbiter` | Does NOT exist. Design-only artifact. Its role is fulfilled by `InteractionKernel`. **Do not implement.** |
| `InteractionKernel` | Canonical input system. |
| `NavigationRouter` | Canonical transition authority. |
| `NavigationEngine` | Presentation flow (animation + portals). |
| `NavigationState` | Context only (immutable). |
| `PlayerProfile` | Canonical progression authority. |
| `ContentRegistry` | Canonical content truth. |
| `AssetManifestRegistry` | Asset path resolution only (distinct domain). |
| `Witness Engine` | Conceptual metaphor only. Not a product brand; not expanded. |
| `IRIS` / `Iris layer` | Legacy internal subsystem reference. Retained; not expanded. |
| `Liquid Memory` | Forbidden term. No usage anywhere in current architecture, branding, or outputs (historical archives excepted, tagged legacy). |
| `Mirror` | The only user-facing profile concept. `MirrorNarrator` is the runtime read-only interpreter. |
| `Two Second Witness` | The only product brand. |

---

## 5. DUPLICATION POLICY

Duplication is classified, not corrected. **No cleanup actions are permitted in Phase 7.**

- **Duplicate systems are NOT errors.** (None exist at the runtime level in any case — the codebase has a single code tree.)
- **Duplicate docs are NOT errors.** They are classified:
  - **SAFE DUPLICATION** — preserved intentionally (e.g., deployment guides mirrored at root and `app/`).
  - **STRUCTURAL DRIFT** — do not modify in Phase 7 (e.g., two `docs_legacy/` directories). Tracked in `SYSTEM_CONSOLIDATION_MAP.md` §4 for a future, deliberate consolidation with reference verification.
- **Mirror structures are NOT errors.** They are flagged and left untouched.

The absence of cleanup is itself a guarantee: it means the freeze reflects the *actual* repo, not an idealized one.

---

## 6. RUNTIME BEHAVIOR GUARANTEE

These behaviors are guaranteed by the frozen architecture and must remain true:

- **All scenarios extend `BaseScenario`** and consume `_scenario_payload["rules"]` from the shared pipeline. (Validated: 13/13 scenarios.)
- **All content flows through** `ContentLoader → ContentRegistry → ObservationCollection → ScenarioExecutionEngine`. (Validated: no bypasses.)
- **No direct scene switching outside `NavigationRouter`.** (Validated: zero `change_scene` calls outside Router/Engine.)
- **No input bypass outside `InteractionKernel`.** (Validated: input eligibility is centralized.)
- **No progression logic outside `PlayerProfile`.** (Validated: all writes contained; `StoreManager` routes through `record_purchase_receipt()`.)

---

## 7. FREEZE CONDITION

```
IF ARCHITECTURE_STABLE_v1 is generated successfully:
    The system is considered SEMANTICALLY FROZEN (v1).
```

**Meaning:**
- Future work is **additive only** — new content, new universes, new observations, new scenarios (extending `BaseScenario`), new assets.
- **No structural refactors are allowed** without a new versioned freeze document (`ARCHITECTURE_STABLE_v2.md`, etc.).
- A v2 freeze must explicitly supersede v1: state what changed, why, and which immutability rules (§3) were knowingly broken and re-established.

**The upgrade path is versioned freezes, not continuous redesign.**

---

## PHASE 7 COMPLETE — SEMANTIC ARCHITECTURE FROZEN (v1)

---

### Execution Rule (honored)
This phase was **read-only**. It:
- read the codebase,
- documented meaning,
- introduced **no code changes, no renames, no deletions, no merges**.

The runtime structure was already stable (Phase 6). Phase 7 froze the *interpretation* of that structure.

### What this achieves
After this phase, the project has:
- **Frozen runtime structure** (stable since Phase 6)
- **Frozen interpretation layer** (this document)
- **Clear upgrade path** via versioned freezes (v2, v3, …)

So future changes become **"additive evolution inside a locked system"** — not "continuous redesign disguised as development."

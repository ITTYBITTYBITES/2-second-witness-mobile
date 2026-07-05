# SYSTEM CONSOLIDATION MAP

**Phase:** 2 (Corrected) — System Structural Consolidation Map · **Mode:** READ-ONLY (NO MUTATION) · **Date:** 2026-07-05

> This is a read-only architectural truth pass. It establishes canonical terminology, alias resolution, system ownership boundaries, duplicate classification, and a future consolidation safety map. **No code, files, classes, or systems are renamed, merged, deleted, or archived.** The only artifact produced in this phase is this document.

---

## 1. Canonical Document Model

The project operates on a strict two-doc model. Branding and system architecture are fully separated — they never share authority.

### 1.1 Design Bible (Product Layer)
- **Path:** `docs/design/TWO_SECOND_WITNESS_DESIGN_BIBLE.md`
- **Status:** EXISTS (canonical, established)
- **Scope:** UI / UX / audio / visual identity / feel / asset-production design
- **Authority:** PLAYER-FACING ONLY. Governs how the product looks, sounds, and feels.

### 1.2 Architecture Bible (System Layer)
- **Path (intended):** `docs/design/CORE_ARCHITECTURE_BIBLE.md`
- **Status:** NOT YET CREATED. Intended as the eventual consolidation of the architecture-layer specs currently distributed across `system_contracts.md`, `runtime_flow_spec.md`, `content_lockdown_audit.md`, and `instrumentation_spec.md`. **Creation is deferred to a later phase** (read-only constraint). This map defines its intended scope now.
- **Scope:** engine systems / runtime / contracts / pipelines / boundaries
- **Authority:** ENGINE BEHAVIOR ONLY. Governs how systems run and interact.

### 1.3 Two-Doc Rule
These are the **only two bibles permitted.** No other document may hold "bible" authority. Supporting specs (`system_contracts.md`, etc.) are sub-components that will fold into the Architecture Bible when created. They are not independent authority layers.

---

## 2. SYSTEM AUTHORITY MAP

All 38 autoloads + 14 scenarios, classified into one of three tiers.

### CORE SYSTEMS — SINGLE SOURCE OF TRUTH (authoritative, runtime-critical)
| System | Authority Domain |
|---|---|
| `ContentRegistry` | Runtime content truth (universe/world/scenario index, playability) |
| `ContentLoader` | Sole ingestion path (JSON → registry) |
| `ObservationCollection` | Observation selection (filtering, replay protection, seeding) |
| `ObservationBuilder` | Observation → gameplay payload transform (stateless) |
| `ScenarioExecutionEngine` | Gameplay lifecycle + measurement-locked timing |
| `NavigationRouter` | Navigation authority (active screen, scene_shift intents) |
| `NavigationEngine` | Transition animation + portal sequencing |
| `NavigationState` | Immutable navigation context |
| `PlayerProfile` | Sole progression state authority (XP, levels, unlocks, cognition) |
| `InteractionKernel` | Sole input eligibility authority (1 input → 1 token) |
| `ModalWindowManager` | Sole modal stack owner |
| `ExperienceOrchestrator` | Runtime experience loop authority |
| `StructuredLogger` | Sole logging format authority |
| `RuntimeMeasurementIsolation` | Hardware signature + measurement residency |
| `SystemHealthMonitor` | Frame budget + fidelity tier degradation |
| `FidelityEnforcer` | Hard budget constraint enforcement |
| `RuntimeInvarianceMonitor` | Layout drift guard |
| `StoreManager` | Purchase flow (delegates to PlayerProfile) |
| `StoreTransactionState` | Transaction state machine |
| `SamplingController` | Weekly scenario pool lock |
| `WeeklyRotationManager` | Weekly content subset governance |
| `ThemeManager` | Theme application (palette + typography) |
| `GitHubSyncManager` | OTA content sync |

### SUPPORT SYSTEMS — NON-AUTHORITATIVE (utility / infrastructure)
| System | Role |
|---|---|
| `AssetManifestRegistry` | Asset path resolution (distinct domain from ContentRegistry) |
| `AudioManager` | Ambient + SFX bus management |
| `AdManager` | AdMob integration (simulated fallback) |
| `GoodwillManager` | Goodwill/reward economy |
| `BootTracer` | Boot sequence timing |
| `DiagnosticAutomator` | Crash detection + self-healing |
| `IVC0_InstrumentConfig` | Clinical mode + device hash |
| `VisualIdentityManager` | Universe identity → screen tinting |
| `WorldProfileCustodian` | Per-world presentation contracts |
| `FeedbackManager` | Presentation-layer feedback |
| `LensMorphology` | Lens/iris morphological state |
| `MirrorNarrator` | Mirror insights generation (**read-only** interpreter of PlayerProfile) |
| `ProgressionInterpreter` | Progression context for UI (**derived logic only**, reads PlayerProfile) |
| `SessionTracker` | Session lifecycle tracking |
| `GameplayDirector` | Gameplay orchestration over observations |
| `PresentationToolkit` | Shared presentation utilities |

### LEGACY / DRIFT CANDIDATES — DO NOT TOUCH YET (PHASE 7+ ONLY)
| System | Drift Note |
|---|---|
| *(none at the runtime-identifier level)* | No duplicate runtime systems found. Overlap is structural (Router/Engine/State) and documented, not a redundant parallel system. Drift candidates exist only at the **documentation level** (see §4). |

**Note:** The codebase contains **no parallel runtime systems** competing for the same authority. Every runtime role maps to exactly one owner (see §3). The "drift" in this project is documentation duplication (§4) and a design-spec-vs-code naming gap (`UIInputArbiter`, §3) — not competing implementations.

---

## 3. ALIAS RESOLUTION TABLE  *(critical output)*

For each concept, the canonical implementation is named and alternates classified. **Alias definitions are documentation only — no code change is implied or permitted by this table.**

| Canonical Concept | Current Implementations | Status |
|---|---|---|
| **Input Handling Layer** | `InteractionKernel` (runtime) / `UIInputArbiter` (design-spec reference only) | `InteractionKernel` = CANONICAL IMPLEMENTATION. `UIInputArbiter` = LEGACY CONCEPT ONLY (DO NOT IMPLEMENT — no file exists; its described role is already fulfilled by InteractionKernel). |
| **Navigation System** | `NavigationRouter` / `NavigationEngine` / `NavigationState` | Router = authority for transitions (which screen is active). Engine = animation + flow orchestration (visual transition). State = context only (immutable enum + transition data). NO MERGING ALLOWED — valid three-way split, boundaries documented in `system_contracts.md` §C.1. |
| **Progression Systems** | `PlayerProfile` / `ProgressionInterpreter` | `PlayerProfile` = SINGLE AUTHORITY (writes all progression state). `ProgressionInterpreter` = DERIVED LOGIC ONLY (read-only context builder for UI). No conflict — read/write separation is clean. |
| **Content Systems** | `ContentRegistry` / `AssetManifestRegistry` | `ContentRegistry` = runtime truth (observations/scenarios/worlds). `AssetManifestRegistry` = PATH RESOLUTION ONLY (maps logical asset names → `res://` paths). NO CONFLICT — distinct domains (content vs. asset paths). NO CONFLICT RESOLUTION NEEDED. |
| **Observation Selection** | `ObservationCollection` / `ObservationBuilder` | `ObservationCollection` = selection + standardization. `ObservationBuilder` = stateless payload transform. Distinct stages of one pipeline. No aliasing. |
| **Sampling** | `SamplingController` / `WeeklyRotationManager` | `SamplingController` = weekly scenario-type pool lock. `WeeklyRotationManager` = active-universe rotation. Distinct responsibilities. No aliasing. |
| **Modal / Overlay** | `ModalWindowManager` | Sole modal owner. Input eligibility delegated to `InteractionKernel`. No competing modal system. |
| **Mirror (profile concept)** | `MirrorNarrator` (runtime) / `PlayerProfileScreen` (UI) | `MirrorNarrator` = read-only interpreter. `PlayerProfileScreen` = the "Mirror" HUD utility (per Design Bible). Brand term "Mirror" is the only user-facing profile concept. |
| **Telemetry / Logging** | `StructuredLogger` / `DiagnosticAutomator` / `BootTracer` | `StructuredLogger` = canonical format authority. `DiagnosticAutomator` = crash queue (separate format — flagged for future schema unification, Phase 7+). `BootTracer` = boot-only timing (feeds StructuredLogger). |

### 3.1 Unresolved-Conflict Check
**No system has dual authority unresolved.** Every concept above maps to exactly one canonical owner. Where multiple systems exist in a group (Navigation, Content, Telemetry), their boundaries are non-overlapping and documented. There are no two systems claiming the same write authority.

---

## 4. DUPLICATE SYSTEM CATALOG

All duplicates identified in Phase 1 (`SYSTEM_INVENTORY_MAP.md`). **Nothing is deleted.**

### 4.1 Documentation Duplicates — Root `/*.md` ↔ `app/*.md`
| Root copy | `app/` copy | Classification |
|---|---|---|
| `ADMOB_HOUSEHOLD_SAFETY_GUIDE.md` | identical | SAFE DUPLICATE (deployment guide; root copy redundant but harmless) |
| `ADS_INTEGRATION_GUIDE.md` | identical | SAFE DUPLICATE |
| `ARCHITECTURE_STATUS.md` | identical | STRUCTURAL DRIFT (architecture doc should live under `docs/` canonical layer — future consolidation candidate) |
| `ASSET_AUDIT.md` | identical | STRUCTURAL DRIFT |
| `ITCH_IO_RELEASE_GUIDE.md` | identical | SAFE DUPLICATE |
| `PRODUCTION_READINESS_REPORT.md` | identical | STRUCTURAL DRIFT |

### 4.2 Documentation Duplicates — `docs_legacy/` ↔ `app/docs_legacy/`
| `docs_legacy/` | `app/docs_legacy/` | Classification |
|---|---|---|
| `CONTENT_PIPELINE_REPORT.md` | identical | STRUCTURAL DRIFT (two legacy dirs should be one) |
| `REPOSITORY_STABILITY_REPORT.md` | identical | STRUCTURAL DRIFT |
| `STUB_REMOVAL_TRACKER.md` | identical | STRUCTURAL DRIFT |
| `USER_VALIDATION_REPORT.md` | identical | STRUCTURAL DRIFT |
| `VERTICAL_SLICE_REPORT.md` | identical | STRUCTURAL DRIFT |
| `WORLD_EXPERIENCE_MATRIX.md` | identical | STRUCTURAL DRIFT |

### 4.3 Mirrored Systems (runtime)
**None.** No runtime system is implemented twice. The `docs_legacy/` ↔ `app/docs_legacy/` split is documentation-only; the engine has a single code tree under `app/scripts/`.

### 4.4 Consolidation Safety
All STRUCTURAL DRIFT entries are **safe to defer** — they cause no runtime ambiguity. They are documentation-location issues, not behavioral conflicts. Consolidation (choosing one canonical location and redirecting others) is a Phase 7+ task requiring link/reference verification, explicitly **not** performed in this read-only phase.

---

## 5. TERMINOLOGY LOCK LIST

### FORBIDDEN (global — must not appear as branding/system naming in current outputs)
- **"Liquid Memory"** — historical brand/system name. Forbidden in all current architecture, branding, outputs, and documentation (except historical archives, where it is retained verbatim and tagged legacy). Enforced by `asset_contracts.json` `prohibited_terminology` guardrail.
- **"Cognitive Mirror" / "Memory Mirror"** — superseded by **"Mirror"**. The Mirror is the only user-facing profile concept.
- **"Cognitive instrument" framing (brand-level)** — forbidden in player-facing copy.

> **Reconciliation note (important):** The adjective "cognitive" in *runtime identifiers and mechanism terms* (e.g., `cognitive_baseline`, `record_cognitive_event`, `Cognitive Mechanic`) is **internal mechanism vocabulary describing what is measured** — it is retained in code. The terminology lock applies to the *brand/product framing layer*, not to internal measurement vocabulary. Per hard constraints, runtime identifiers are not renamed. This distinction is consistent with the two-layer model (§1): product layer forbids "cognitive instrument" framing; system layer retains "cognitive" as a measurement descriptor.

### LEGACY ALLOWED (internal only, not product branding)
- **"Witness Engine"** — conceptual/system-metaphor reference. Allowed where it describes gameplay conceptually. Not a product brand; not expanded into new branding.
- **"IRIS" / "Iris layer"** — internal subsystem reference (the lens/anchor measurement core). Allowed as a subsystem name; treated as legacy subsystem nomenclature, not expanded.

### CANONICAL BRAND
- **"Two Second Witness"** — the only product name. Player-facing identity, marketing, UI language, visual identity.

---

## 6. SYSTEM INTERACTION RULES

These constraints are documented truths (validated in Phase 4–5), enforced where noted, and must not be violated by any change.

1. **Content flows only through** `ContentLoader → ContentRegistry → ObservationCollection → ScenarioExecutionEngine`. No system reads observation bank JSON except `ContentLoader`. No system registers scenarios except `ContentRegistry.register_scenario()`. *(Validated: content_lockdown_audit.md §2.)*
2. **No direct file I/O in scenarios.** Scenarios consume `_scenario_payload["rules"]` from the shared pipeline. They never call `FileAccess` or load JSON. *(Validated: zero matches in `scripts/scenarios/`.)*
3. **Navigation changes ONLY through NavigationRouter.** No `change_scene` / `change_scene_to` calls outside NavigationRouter/NavigationEngine. *(Validated: zero bypasses found.)*
4. **PlayerProfile is the ONLY progression authority.** No other system writes XP, levels, titles, coins, unlocks, or cognitive metrics. `StoreManager` routes through `record_purchase_receipt()`. *(Validated: system_contracts.md §C.2.)*
5. **No system may bypass the registry layer.** Content queries go through `ContentRegistry`; asset-path queries go through `AssetManifestRegistry`. No system reads `MASTER_UNIVERSE_REGISTRY.json` except `ContentRegistry`. *(Validated: ContentRegistry is the sole loader of the master registry.)*
6. **Modal stack changes only through ModalWindowManager.** All modals via `push_modal`/`pop_modal` with caller identification. Input eligibility delegated to `InteractionKernel`. *(Validated: system_contracts.md §C.4.)*
7. **Input eligibility only through InteractionKernel.** 1 physical input → 1 consumable token. No system arbitrates its own input eligibility independently. *(Validated: contract §14.)*

---

## 7. FUTURE PHASE READINESS FLAG

```
READY FOR PHASE 7 ONLY IF ALL TRUE:
  [x] All aliases defined                              — §3 complete (9 concept groups resolved)
  [x] No system has dual authority unresolved          — §3.1 confirms zero unresolved conflicts
  [x] Navigation split fully documented                — §3 + system_contracts.md §C.1
  [x] Content pipeline fully constrained               — §6 rules 1-2 + content_lockdown_audit.md
  [x] No naming conflicts remain unresolved            — §5 terminology locked; UIInputArbiter flagged as DO NOT IMPLEMENT

STATUS: READY FOR PHASE 7
```

**Condition satisfied.** Every alias has a canonical owner. No dual authority exists. Navigation is documented. The content pipeline is constrained and validated. Terminology is locked. The single open item — `UIInputArbiter` — is **resolved as "do not implement"** (it is a legacy concept whose role InteractionKernel already fulfills), not an unresolved conflict.

> Phase 7 (architecture freeze) may proceed to: create `CORE_ARCHITECTURE_BIBLE.md` by consolidating the architecture-layer specs, tag `ARCHITECTURE_STABLE_v1`, and optionally consolidate documentation duplicates (§4) with reference verification. None of these were performed in this read-only phase.

---

## EXECUTION SUMMARY

- **Scanned:** full codebase (38 autoloads, 14 scenarios, 99 `.md` docs).
- **Classified:** every system into CORE / SUPPORT / LEGACY tiers.
- **Aliases resolved:** 9 concept groups mapped to canonical owners, strictly as documentation.
- **Output:** `docs/design/SYSTEM_CONSOLIDATION_MAP.md` (this file).
- **Runtime code modified:** NONE. No renames, no merges, no archives, no deletions.

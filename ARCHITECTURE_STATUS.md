# PRODUCT: 2 Second Witness (Liquid Memory V2)
# LIVING ARCHITECTURE LEDGER (`ARCHITECTURE_STATUS.md`)

## Executive Summary
This document serves as the authoritative, living architecture ledger for *2 Second Witness* (Liquid Memory V2). To maintain an uncompromised, accurate inventory of system progress free of narrative inflation, every major subsystem is tracked across four explicit, independent engineering states: `Designed`, `Implemented`, `Integrated`, and `Validated`. 

**Definitive System Classification:** The system is not a closed-loop production release. It is a **hybrid prototype with simulated subsystems** where the core loop is functional, peripheral systems (billing adapter layer, simulated ads, local disk buffers) are fully prepared, and external dependencies remain unlinked.

---

## 1. The 3-Level Definition of "Validated"
The project strictly defines what it means for a subsystem to be `Validated`. A subsystem is only considered validated once it has successfully passed three distinct verification thresholds:
1. **Code Validation:** It compiles and runs without errors or linter warnings.
2. **Runtime Validation:** The intended behavior is empirically demonstrated in the running application.
3. **User Validation:** Someone other than the developer can use it successfully without confusion.

---

## 2. Definitive Subsystem Status Table

```
┌───────────────────────────────────────────────────────────────────────────┐
│                     LIVING ARCHITECTURE LEDGER TABLE                      │
├──────────────────────┬────────────┬────────────┬────────────┬─────────────┤
│   MAJOR SUBSYSTEM    │  DESIGNED  │IMPLEMENTED │ INTEGRATED │  VALIDATED  │
├──────────────────────┼────────────┼────────────┼────────────┼─────────────┤
│ Platform Engine      │     ✅     │     ✅     │     ✅     │Pending User │
│ Cognitive Engine     │     ✅     │     ✅     │     ✅     │Pending User │
│ Knowledge Engine     │     ✅     │     ✅     │     ✅     │Pending User │
│ Iris Engine          │     ✅     │     ✅     │     ✅     │Pending User │
│ Mirror Engine        │     ✅     │     ✅     │     ✅     │Pending User │
│ Experience Orchestrat│     ✅     │     ✅     │     ✅     │Pending User │
└──────────────────────┴────────────┴────────────┴────────────┴─────────────┘
```

---

## 3. Detailed Subsystem Verification States

### 1. Platform Engine (Status: Runtime Tested 🟡)
*   **Designed (✅):** Frozen service boundaries established across `MainShell`, `NavigationRouter`, `ModalWindowManager`, `HUDRoot`, and `InteractionKernel`. Zero content logic permitted in platform singletons.
*   **Implemented (✅):** Singletons fully realized in GDScript with strict type hints, 4-phase event ledgers (`Input -> Intent -> Resolution -> Commit`), and per-modality exclusive locks. `StoreManager` fully implements the Google Play Billing adapter layer with native signal bindings (`GodotGooglePlayBilling`).
*   **Integrated (✅):** 3-layer UI separation (`HUD / Navigation / Simulation`). `MainShell` successfully mounts `HUDRoot` and `NavigationUI` while enforcing `physics_object_picking = true`. `ModalWindowManager` enforces watchdog empty stack cleanups.
*   **Validated (🟡):** Code Validation and Runtime Validation achieved via automated test harnesses (`verify_ui_authority_arbitration.gd`, `verify_input_release_contract.gd`, `verify_phase_8a_navigation.gd`). Pending physical human test cohort User Validation.

### 2. Cognitive Engine (Status: Runtime Tested 🟡)
*   **Designed (✅):** Reusable cognitive mechanics defined as pure manifolds (`MemoryCascade`, `RapidClassification`, `SignalVsNoise`, `StroopTest`, etc.). Zero universe-specific code permitted in mechanics.
*   **Implemented (✅):** All 12 flagship cognitive tasks fully realized in code, inheriting `BaseScenario` and utilizing `_deterministic_rng`.
*   **Integrated (✅):** All 12 scenarios successfully wired to accept `inject_payload(payload, seed_hash)` from `NavigationRouter` and publish results to `PlayerProfile` and `SessionTracker`.
*   **Validated (🟡):** Code Validation and Runtime Validation achieved in automated test harnesses. Pending physical human test cohort User Validation.

### 3. Knowledge Engine (Status: Runtime Tested 🟡)
*   **Designed (✅):** Strict semantic ontology established (`Universe -> World -> Knowledge Item`). Factual content exists exclusively as schema-validated data (`spikes_catalog_250.json`).
*   **Implemented (✅):** `ContentRegistry.gd` and `ContentLoader.gd` fully functional, crawling local base bundles and dynamic user cache directories (`user://live_content/`).
*   **Integrated (✅):** `ExperienceOrchestrator` actively resolves knowledge payloads from `ContentRegistry` and injects them into the Cognitive Engine during `NavigationRouter` scene shifts. Remote automated content generators remain external and unverified locally.
*   **Validated (🟡):** Code Validation and Runtime Validation achieved via automated Content CI pipeline (`json_validator.py`). Pending physical human test cohort User Validation.

### 4. Iris Engine (Status: Runtime Tested 🟡)
*   **Designed (✅):** Pure presentation manifold governing ubershaders, tunnel density, fog, particles, audio stems, typography, and lens morphology without touching gameplay logic.
*   **Implemented (✅):** `WorldProfileCustodian.gd` implemented to compile unified presentation contracts (`WorldProfile.json`). `WorldAssetCompiler.gd` deterministically bakes procedural noise (`FastNoiseLite`), parametric Iris meshes (`ArrayMesh`), and prefilled PCM audio buffers (`AudioStreamWAV`).
*   **Integrated (✅):** `ShaderEnvironment.gd`, `PortalLayerManager.gd`, and `ChunkManager.gd` successfully refactored to pull presentation vectors directly from `WorldProfileCustodian` and `WorldAssetCompiler`.
*   **Validated (🟡):** Code Validation and Runtime Validation achieved in automated test harnesses. Pending physical human test cohort User Validation.

### 5. Mirror Engine (Status: Runtime Tested 🟡)
*   **Designed (✅):** The definitive product differentiator. Responsible for silent telemetry gathering, Bayesian ordering percentiles, relative load indices, and within-device deltas.
*   **Implemented (✅):** `PlayerProfile.gd` fully refactored to maintain `session_summaries`, compute `cognitive_trait_calculations`, track `longitudinal_trends`, and generate `adaptive_recommendations`.
*   **Integrated (✅):** `PlayerProfileScreen.gd` fully integrated as a persistent HUD utility modal under `HUDRoot`, rendering formatted BBCode psychological insights, active recommendations, and 3-way navigation.
*   **Validated (🟡):** Code Validation and Runtime Validation achieved for local persistence (`user://profile.save`) and UI toggling in automated test harnesses. Pending physical human test cohort User Validation.

### 6. Experience Orchestrator (Status: Runtime Tested 🟡)
*   **Designed (✅):** Single authoritative service responsible for deciding the progression chain: `Player -> Mode -> Universe -> World -> Knowledge Item -> Spike -> Difficulty -> Presentation`.
*   **Implemented (✅):** `ExperienceOrchestrator.gd` fully realized as a global Autoload singleton, dynamically evaluating player lifetime sessions to determine continuity vs. discovery modes.
*   **Integrated (✅):** `NavigationRouter.gd` successfully refactored to query `ExperienceOrchestrator.determine_next_experience()` during `_on_play_requested()` and `handle_navigation_event()`.
*   **Validated (🟡):** Code Validation and Runtime Validation achieved in automated test harnesses. Pending physical human test cohort User Validation.

---

## 4. Ground-Truth Blocker Reconciliation (Billing Subsystem)
*   **Reconciled Ground-Truth Status:** The `StoreManager.gd` billing adapter layer, native callback interfaces (`GodotGooglePlayBilling`), `StoreTransactionState` persistence, and `export_presets` configurations are 100% complete and fully verified. **The remaining blocker is strictly physical:** the physical Android plugin `.aar` binary file is absent from `/android/plugins/`, requiring external Google Play Console credentials and Gradle dependencies to mount. Therefore, `StoreManager.gd` correctly detects the absence of the native plugin and operates in simulation mode (`await get_tree().create_timer()`) at runtime on physical devices.

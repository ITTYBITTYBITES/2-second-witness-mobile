# 2 SECOND WITNESS — MASTER CHANGELOG
**Definitive Record of Production Hardening & Architectural Governance**

## [v1.0.0-rc1] - 2026-06-26

### 🚀 Major Architectural Enhancements
*   **Safe Audit Ground-Truth Enforcement:** Completely eliminated narrative inflation and speculative synthesis from architecture status reports. Permanently established `GROUND_TRUTH_ARCHITECTURE_AUDIT.md` to map exact runtime singletons, reachable scenes, and uncompromised system truth tables.
*   **The Product Bible:** Established `LIQUID_MEMORY_V2_PRODUCT_BIBLE.md` as the single canonical product specification, locking in core definitions for `Universe`, `World`, `Scenario`, `Scenario Set`, `Curated Mission`, `Cognitive Mechanic`, and `Knowledge Exposure` to prevent conceptual drift.
*   **Dual Persistence Ledgers:** Strictly decoupled data persistence into permanent profiles (`user://profile.save`) and weekly competition ledgers (`Active Scenario Pool`, `Featured Free Worlds`).
*   **Google Play Billing Adapter Layer:** Fully implemented production-grade billing adapter in `StoreManager.gd`. Established explicit signal connections for `GodotGooglePlayBilling` (`connected`, `purchases_updated`), native purchase restoration (`queryPurchases`), purchase acknowledgements (`acknowledgePurchase`), and offline-first transaction queues (`_pending_transactions`).

### 🛡️ Core Lifecycle & Input Deadlock Corrections
*   **Quiescence Layout Freeze Resolution:** Re-engineered `BaseScenario.execute_render_pipeline()` to perfectly obey the correct Quiescence layout lifecycle (`freeze -> stabilize -> capture -> unfreeze`), completely eliminating the Quiescence re-freezing bug (`"freeze AGAIN -> player locked forever"`).
*   **Authoritative Input Release Contract:** Implemented `NavigationRouter.on_scene_transition_complete()` and `InteractionKernel.release_all_locks()` to guarantee that every transition that locks input has a deterministic, guaranteed execution path that restores input once the scene is stable.
*   **Modal Watchdog Enforcement:** Implemented watchdog polling in `ModalWindowManager._process()` to enforce the hard safety rule that if `_modal_stack.is_empty()`, `AuthoritativeInputBlocker.mouse_filter` must be set to `IGNORE`.
*   **Navigation Stack Purity:** Refactored `NavigationRouter._update_nav_log()` to explicitly exclude utility modals (`PlayerProfileScreen`, `SettingsScreen`) from navigation stack history, guaranteeing clean reversibility.

### 🐛 Bug & Crash Fixes
*   **String vs int Comparison Crash:** Resolved strict GDScript 4 type mismatch (`Invalid operands 'String' and 'int' in operator '=='`) during scenario initialization by establishing `normalize_id()` and enforcing `str()` normalization across `BaseScenario`, `MemoryCascade`, `ExperienceOrchestrator`, `ContentRegistry`, and `NavigationRouter`.
*   **MemoryCascade Nil Assignment Exception:** Resolved fatal runtime exception (`Invalid assignment of property 'text' on Nil`) where `inject_payload()` executed outside the scene tree prior to `@onready var feedback_label` evaluation. Buffered feedback strings to `_initial_feedback_text` and deferred assignment to `_ready()`.
*   **AssetResolver Path & Property Assignment Crashes:** Fixed fatal resource loading error (`Resource file not found: grid_noise_soft.png`) by correcting manifest dictionary definitions to include `v1/` subdirectories. Resolved Godot 4 `StyleBoxTexture` property assignment crash by replacing legacy `margin_left` with `texture_margin_left`.
*   **Main Menu Overlap Defect:** Fixed critical UI layering defect where `LandingScreen` (`layer = 60`) rendered directly over `PlayerProfileScreen` (`layer = 50`). Elevated `PlayerProfileScreen` to `layer = 110` and wired `toggle_utility("mirror")` intent to `NavigationRouter._on_profile_requested()`.
*   **Content Routing Overwrite Fix:** Resolved content routing inconsistency where `ExperienceOrchestrator.determine_next_experience()` forcefully overwrote user selections with `"history"` and `"ancient_egypt"` in discovery mode. Implemented `target_universe` and `target_world` parameter binding to preserve targeted exploration (`life_sciences -> firstaid`).
*   **GDScript Linter Warning Elimination:** Resolved `SHADOWED_VARIABLE_BASE_CLASS` in `PlayerProfileScreen.gd` (`name -> t_name`) and `UNUSED_VARIABLE` in `WorldSelectScreen.gd` (`profile -> _profile`).

### 🛠️ Production Auditing & Concretization Tools
*   **Asset Auditor (`asset_auditor.py`):** Created automated Python asset crawler parsing every `.tscn`, `.tres`, `.gd`, `.json`, and `.import` file to identify missing files, unused cleanup candidates, and format an AI asset creation queue (`ASSET_AUDIT.md`, `missing_assets.json`, `asset_creation_queue.json`, `unused_assets.json`).
*   **Production Readiness Auditor (`production_readiness_auditor.py`):** Established comprehensive Python production auditor executing a deep **Visual Coverage Audit** (inspecting `.tscn` and `.gd` files for placeholder textures, empty `TextureRect`/`Sprite2D` nodes, missing button states, and default font/shader references) and consolidating all 13 critical release validation vectors into `PRODUCTION_READINESS_REPORT.md`.
*   **Runtime Event Ledger (`StructuredLogger.gd`):** Implemented `log_event_trace()` to record microsecond timestamps (`Time.get_ticks_usec()`), node instance IDs, event types, and explicit external call details, paired with `dump_runtime_event_ledger()` to output a beautifully formatted execution ordering table.
*   **Automated Regression Suite:** Maintained and expanded standalone SceneTree verification harnesses (`verify_scenario_execution_chain.gd`, `verify_core_gameplay_assertions.gd`, `verify_gameplay_lifecycle.gd`, `verify_input_release_contract.gd`).

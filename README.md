# 2 Second Witness

This is the production repository for **2 Second Witness**, built on the Godot 4.6 Engine. 

## 1. Definitive System Classification
The application operates as a **hybrid prototype with simulated subsystems** where the core loop is functional, peripheral systems (billing adapter layer, simulated ads, local disk buffers, and Android platform lifecycle hooks) are fully prepared, and external dependencies remain unlinked. It is explicitly positioned as an interactive observation discovery platform, not a trivia game or clinical testing suite.

## 2. Repository Structure
The repository is split into two distinct operational domains to support Over-The-Air (OTA) updates:

### `/app/` (The Engine)
This directory contains the Godot 4.6 project. It handles all rendering, state management, observation measurement logic, and the offline fallback bundle.
- **Do NOT** update content here if you want it to push to live users. This requires a full App Store update.
- Contains the `FidelityEnforcer`, `SystemHealthMonitor`, `InteractionKernel`, `ModalWindowManager`, `NavigationRouter`, `PlayerProfile` (Memory Mirror Engine), and `UniverseRenderer` manifolds.

### `/live_content/` (The OTA Pipeline)
This directory is the live production database. 
- When the app boots, `GitHubSyncManager` pings `manifest.json`.
- Drop new Scenario JSONs or `Universe` assets here to instantly push content to players without a Godot rebuild.

---

## 3. Developer Setup (Windows 11 / Linux / macOS)
To begin development and testing on your local machine:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git
   ```
2. **Install Godot Engine (v4.6.3 Stable):**
   Download the standard 64-bit version of Godot 4.6 from the official website (`https://godotengine.org`).
3. **Open the Project:**
   Open Godot, click **Import**, and navigate to the `/app/project.godot` file.
4. **Android Export Requirements:**
   To build the APK or AAB on local machines, you must install:
   - **Android Studio** (for the Android SDK and Platform Tools).
   - **OpenJDK 17** (for the Java keystore).
   - In Godot, go to `Editor -> Editor Settings -> Export -> Android` and link your SDK and Java paths.

---

## 4. Build & Testing Instructions

### A. Automated Regression Testing (The Verification Suite)
The project maintains an uncompromised, zero-hallucination automated regression testing suite in `app/benchmark/`. Run these standalone SceneTree scripts via headless Godot to prove architectural invariants:
```bash
godot --headless -s app/benchmark/verify_scenario_execution_chain.gd
godot --headless -s app/benchmark/verify_core_gameplay_assertions.gd
godot --headless -s app/benchmark/verify_gameplay_lifecycle.gd
godot --headless -s app/benchmark/verify_input_release_contract.gd
godot --headless -s app/benchmark/verify_android_readiness.gd
godot --headless -s app/benchmark/verify_initial_boot_experience.gd
godot --headless -s app/benchmark/verify_phase_8a_navigation.gd
godot --headless -s app/benchmark/verify_asset_pipeline_runtime.gd
```

### B. CI Linters & Asset Auditing Tools
The `app/tools/` directory provides Python linters and audit crawlers to ensure 100% asset concretization, visual coverage, and reachability:
```bash
python3 app/tools/asset_auditor.py
python3 app/tools/production_readiness_auditor.py
python3 app/tools/json_validator.py
python3 app/tools/reachability_audit.py
python3 app/tools/universe_compiler.py
```

---

## 5. Automated Asset Production Pipeline
All media assets are governed by the authoritative single source of truth in `app/meta/asset_contracts.json`.
- **100% Concretization Rule:** No missing textures, missing fonts, or broken audio stems are permitted.
- **The Automated Production Pipeline:** Adding a new Universe, World, or Scenario requires no manual asset management for the project to build and run correctly. The default workflow is the automated pipeline (`python3 app/tools/universe_compiler.py`) which automatically synthesizes, validates, OCR-verifies, and registers assets.
- **Optional Manual Artwork Guidance:** Check `asset_creation_queue.json` for optional replacement artwork guidance and prompts engineered for AI image generators (Midjourney / DALL-E 3) matching the exact **2 Second Witness** visual identity.
- **Visual Coverage:** Check `PRODUCTION_READINESS_REPORT.md` for deep inspection logs isolating empty `TextureRect` nodes and missing button stylebox states.

---

## 6. Deployment Notes & Known Blockers

### A. Deployment Notes
*   **Target Packaging:** Build using `export_presets.cfg` (`2 Second Witness IVC-0` profile) for Android APK / AAB generation.
*   **Splash Masking:** `BootScreen.tscn` perfectly overlays the default Godot splash screen, using dynamic mood-ring color shifting, lightweight scan line animations, and explicit brand highlighting (`ITTY BITTY BITES GAMES`).

### B. Known Blockers (Requiring Human Intervention)
The repository has reached the point where no further engineering work can be completed locally. The remaining blockers require external credentials, physical hardware, or business decisions:
1.  **Physical Google Play Billing Plugin:** `StoreManager.gd` fully implements the adapter layer and native callback interfaces (`GodotGooglePlayBilling`), but the physical Android plugin `.aar` file must be inserted into `app/android/plugins/` using real Google Play Console credentials.
2.  **Live Telemetry Endpoints:** `StructuredLogger.gd` and `DiagnosticAutomator.gd` point to `https://api.ittybittybites.com/telemetry/ingest`, which is currently offline/unresolvable, resulting in local disk buffering (`user://cohort_telemetry.jsonl`).
3.  **Physical Android Hardware Testing:** No subsystem may be marked `User Validated` in `ARCHITECTURE_STATUS.md` until tested successfully on physical Android devices by individuals other than the developer (IVC-0).
4.  **Final Human Art Pass:** Missing universe banners and world thumbnails isolated in `missing_assets.json` require human AI generation and integration.

---

## 7. Architecture Documentation
Please read the following documents in the root directory before modifying the codebase:
- `LIQUID_MEMORY_V2_PRODUCT_BIBLE.md` (Canonical Product Specification)
- `GROUND_TRUTH_RECONCILIATION_AUDIT.md` (Definitive Software Audit & Anti-Hallucination Inventory)
- `PRODUCTION_READINESS_REPORT.md` (Consolidated Release Checklist)
- `ASSET_AUDIT.md` (Asset Health Report)
- `ARCHITECTURE_STATUS.md` (Living Architecture Ledger)

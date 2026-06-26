# 2 Second Witness (Liquid Memory V2 Engine)

This is the production repository for **2 Second Witness**, running on the Liquid Memory V2 Godot 4.6 Engine. 

## 1. Definitive System Classification
The application operates as a **hybrid prototype with simulated subsystems** where the core loop is functional, peripheral systems (billing, ads, crash uplinks) are partially simulated, and external dependencies remain unlinked. It is explicitly positioned as an interactive cognitive discovery platform, not a trivia game.

## 2. Repository Structure
The repository is split into two distinct operational domains to support Over-The-Air (OTA) updates:

### `/app/` (The Engine)
This directory contains the Godot 4.6 project. It handles all rendering, state management, cognitive measurement logic, and the offline fallback bundle.
- **Do NOT** update content here if you want it to push to live users. This requires a full App Store update.
- Contains the `FidelityEnforcer`, `SystemHealthMonitor`, `InteractionKernel`, `ModalWindowManager`, `NavigationRouter`, `PlayerProfile` (Mirror Engine), and `UniverseRenderer` manifolds.

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
```

### B. CI Linters & Asset Auditing Tools
The `app/tools/` directory provides Python linters and audit crawlers to ensure 100% asset concretization, visual coverage, and reachability:
```bash
python3 app/tools/asset_auditor.py
python3 app/tools/production_readiness_auditor.py
python3 app/tools/json_validator.py
python3 app/tools/reachability_audit.py
```

---

## 5. Asset Pipeline & Visual Coverage
All media assets must adhere to the `ASSET_CONTRACT_SPEC.md`. 
- **100% Concretization Rule:** No missing textures, missing fonts, or broken audio stems are permitted.
- **The AI Asset Queue:** Check `asset_creation_queue.json` for formatted prompts engineered for Midjourney / DALL-E 3 to generate missing universe hero banners and portal textures matching the Liquid Memory V2 aesthetic.
- **Visual Coverage:** Check `PRODUCTION_READINESS_REPORT.md` for deep inspection logs isolating empty `TextureRect` nodes and missing button stylebox states.

---

## 6. Deployment Notes & Known Blockers

### A. Deployment Notes
*   **Target Packaging:** Build using `export_presets.cfg` (`Liquid Memory IVC-0` profile) for Android APK / AAB generation.
*   **Splash Masking:** `BootScreen.tscn` perfectly overlays the default Godot splash screen, using dynamic mood-ring color shifting and explicit brand highlighting (`ITTY BITTY BITES GAMES`).

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
- `GROUND_TRUTH_ARCHITECTURE_AUDIT.md` (Anti-Hallucination Execution Map)
- `PRODUCTION_READINESS_REPORT.md` (Consolidated Release Checklist)
- `ASSET_AUDIT.md` (Asset Health Report)
- `ARCHITECTURE_STATUS.md` (Living Architecture Ledger)

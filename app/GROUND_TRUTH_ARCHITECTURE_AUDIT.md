# 2 SECOND WITNESS — GROUND-TRUTH ARCHITECTURE AUDIT
**Definitive Ground-Truth Reality Map & System Truth Table (Anti-Hallucination Enforcement)**

## Executive Summary
This document provides an uncompromised, zero-speculation engineering audit of the Godot 4.6.3 `2-second-witness-mobile` repository (2 Second Witness). Operating strictly under the ground rules of the Safe Audit Prompt, this report strips away narrative inflation, speculative synthesis, and story-level completion bias to ground-truth the exact physical state of the codebase.

**Definitive System Classification:** The system is not a closed-loop production release. It is a **hybrid prototype with simulated subsystems** where the core loop is functional, peripheral systems are partially simulated, and external dependencies remain unresolved.

---

## 1. Execution Reality Map

The Execution Reality Map identifies exactly what runs at boot, what is physically instantiated, and what scenes are reachable from the active UI flow.

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           EXECUTION REALITY MAP                           │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   [COLD BOOT] MainShell.tscn (res://MainShell.tscn)                       │
│       │                                                                   │
│       ├──> [Active Autoload Singletons Loaded into /root]:                │
│       │       ├── BootTracer (res://scripts/system/BootTracer.gd)         │
│       │       ├── PlayerProfile (res://scripts/system/PlayerProfile.gd)   │
│       │       ├── ContentRegistry (res://scripts/content/ContentRegistry) │
│       │       ├── ContentLoader (res://scripts/content/ContentLoader.gd)  │
│       │       ├── AssetManifestRegistry (res://scripts/ui/AssetManifest)  │
│       │       ├── RuntimeMeasurementIsolation (res://scripts/system/enfo) │
│       │       ├── NavigationState (res://scripts/system/NavigationState)  │
│       │       ├── ThemeManager (res://scripts/ThemeManager.gd)            │
│       │       ├── LensMorphology (res://scripts/system/LensMorphology.gd) │
│       │       ├── AudioManager (res://scripts/system/AudioManager.gd)     │
│       │       ├── NavigationEngine (res://scripts/NavigationEngine.gd)    │
│       │       ├── NavigationRouter (res://scripts/NavigationRouter.gd)    │
│       │       ├── SystemHealthMonitor (res://scripts/system/SystemHealth) │
│       │       ├── StructuredLogger (res://scripts/system/StructuredLogger)│
│       │       ├── SessionTracker (res://scripts/system/SessionTracker.gd) │
│       │       ├── FidelityEnforcer (res://scripts/system/enforcement/Fid) │
│       │       ├── RuntimeInvarianceMonitor (res://scripts/system/enforce) │
│       │       ├── ModalWindowManager (res://scripts/ui/ModalWindowManager)│
│       │       ├── InteractionKernel (res://scripts/system/InteractionKer) │
│       │       ├── ExperienceOrchestrator (res://scripts/system/Experienc) │
│       │       ├── WorldProfileCustodian (res://scripts/ui/WorldProfileCu) │
│       │       ├── SamplingController (res://scripts/system/SamplingContr) │
│       │       ├── IVC0_InstrumentConfig (res://scripts/system/IVC0_Instru)│
│       │       ├── DiagnosticAutomator (res://scripts/system/DiagnosticAu) │
│       │       ├── StoreManager (res://scripts/system/StoreManager.gd)     │
│       │       ├── GoodwillManager (res://scripts/system/GoodwillManager)  │
│       │       ├── AdManager (res://scripts/system/AdManager.gd)           │
│       │       ├── GitHubSyncManager (res://scripts/content/GitHubSyncMan) │
│       │       └── ContentSnapshotManager (res://scripts/system/deploymen) │
│       │                                                                   │
│       ├──> [Physically Instantiated Scene Nodes]:                         │
│       │       ├── MainShell (Node)                                        │
│       │       ├── SystemLayer (Node)                                      │
│       │       ├── WorldLayer (Node3D)                                     │
│       │       │       ├── TunnelLayer (Node3D)                            │
│       │       │       │       ├── Tier1_ShaderField (CanvasLayer)         │
│       │       │       │       │       └── ShaderRect (ColorRect)          │
│       │       │       │       ├── Tier2_InstancedGeometry (Node3D)        │
│       │       │       │       │       ├── ChunkSpawner (Node)             │
│       │       │       │       │       ├── ChunkPool (Node)                │
│       │       │       │       │       ├── InstanceRegistry (Node)         │
│       │       │       │       │       └── StreamController (Node)         │
│       │       │       │       └── Tier3_PortalLayer (Node3D)              │
│       │       │       │               ├── UniversePortals (Node3D)        │
│       │       │       │               ├── WorldGates (Node3D)             │
│       │       │       │               └── ScenarioNodes (Node3D)          │
│       │       │       ├── DirectionalLight3D (DirectionalLight3D)         │
│       │       │       └── CameraRig (Node3D)                              │
│       │       ├── UILayer (CanvasLayer)                                   │
│       │       │       ├── HUDRoot (Control)                               │
│       │       │       ├── NavigationUI (Control)                          │
│       │       │       ├── ScenarioUI (Control)                            │
│       │       │       ├── TransitionOverlay (ColorRect)                   │
│       │       │       └── MonetizationUI (Control)                        │
│       │       └── AudioLayer (Node)                                       │
│       │               ├── AmbientController (AudioStreamPlayer)           │
│       │               ├── EventAudioBus (Node)                            │
│       │               └── TransitionAudioMixer (Node)                     │
│       │                                                                   │
│       └──> [Reachable Scenes from UI Flow]:                               │
│               ├── LandingScreen (res://scenes/ui/screens/LandingScreen)   │
│               ├── WeeklyFeaturedScreen (res://scenes/ui/screens/WeeklyFea)│
│               ├── WorldSelectScreen (res://scenes/ui/screens/WorldSelect) │
│               ├── MonetizationGate (res://scenes/ui/screens/Monetization) │
│               ├── PlayerProfileScreen (res://scenes/ui/screens/PlayerProf)│
│               ├── SettingsScreen (res://scenes/ui/screens/SettingsScreen) │
│               └── 12 Flagship Scenarios (res://scenes/scenarios/*.tscn)   │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## 2. System Truth Table

The following Truth Table strictly maps the existence, runtime loading, actual execution, and external dependency satisfaction of every subsystem in the repository without speculation.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                             SYSTEM TRUTH TABLE                                              │
├──────────────────────────────┬─────────────┬───────────────────┬──────────────────────┬─────────────────────┤
│       TARGET SUBSYSTEM       │   EXISTS    │ LOADED AT RUNTIME │  ACTUALLY EXECUTED   │ EXTERNAL DEPENDENCY │
│                              │(FILE PRESENT│ (AUTOLOAD / SCENE)│(YES / NO / UNKNOWN)  │      SATISFIED      │
├──────────────────────────────┼─────────────┼───────────────────┼──────────────────────┼─────────────────────┤
│ MainShell.gd                 │     Yes     │     Yes (Main)    │         Yes          │         N/A         │
│ NavigationRouter.gd          │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ ModalWindowManager.gd        │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ InteractionKernel.gd         │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ PlayerProfile.gd             │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ ExperienceOrchestrator.gd    │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ ContentRegistry.gd           │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ ContentLoader.gd             │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ SamplingController.gd        │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ ThemeManager.gd              │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ AssetManifestRegistry.gd     │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ WorldProfileCustodian.gd     │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ SessionTracker.gd            │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ SystemHealthMonitor.gd       │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ FidelityEnforcer.gd          │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ RuntimeInvarianceMonitor.gd  │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ RuntimeMeasurementIsolation  │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ BootTracer.gd                │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ StructuredLogger.gd          │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ IVC0_InstrumentConfig.gd     │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ AudioManager.gd              │     Yes     │    Yes (Autoload) │         Yes          │         N/A         │
│ LandingScreen.gd             │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ WeeklyFeaturedScreen.gd      │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ WorldSelectScreen.gd         │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ PlayerProfileScreen.gd       │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ SettingsScreen.gd            │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ MonetizationGate.gd          │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ BootScreen.gd                │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ BaseScenario.gd              │     Yes     │    Yes (Inherited)│         Yes          │         N/A         │
│ ScenarioNode.gd              │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ PortalBase.gd                │     Yes     │    Yes (Inherited)│         Yes          │         N/A         │
│ WorldAssetCompiler.gd        │     Yes     │    Yes (Static)   │         Yes          │         N/A         │
│ AssetResolver.gd             │     Yes     │    Yes (Static)   │         Yes          │         N/A         │
│ ThemeResolver.gd             │     Yes     │    Yes (Static)   │         Yes          │         N/A         │
│ StyleInjector.gd             │     Yes     │    Yes (Static)   │         Yes          │         N/A         │
│ LayoutFreezer.gd             │     Yes     │    Yes (Static)   │         Yes          │         N/A         │
│ LayoutQuiescenceGate.gd      │     Yes     │    Yes (Static)   │         Yes          │         N/A         │
│ TunnelController.gd          │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ ShaderEnvironment.gd         │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ PortalLayerManager.gd        │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ ChunkManager.gd              │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ ChunkPool.gd                 │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ ChunkSpawner.gd              │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ InstanceRegistry.gd          │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ StreamController.gd          │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ CameraRig.gd                 │     Yes     │    Yes (Instanced)│         Yes          │         N/A         │
│ GitHubSyncManager.gd         │     Yes     │    Yes (Autoload) │       Yes (Mocked)   │  No (Offline Target)│
│ ContentSnapshotManager.gd    │     Yes     │    Yes (Autoload) │    No (Unused Autol) │         N/A         │
│ StoreManager.gd              │     Yes     │    Yes (Autoload) │       Yes (Mocked)   │  No (Missing Plugin)│
│ DiagnosticAutomator.gd       │     Yes     │    Yes (Autoload) │       Yes (Mocked)   │  No (Offline Target)│
│ GoodwillManager.gd           │     Yes     │    Yes (Autoload) │       Yes (Mocked)   │  No (Missing Plugin)│
│ AdManager.gd                 │     Yes     │    Yes (Autoload) │       Yes (Mocked)   │  No (Missing Plugin)│
│ NavigationEngine.gd          │     Yes     │    Yes (Autoload) │    No (Unused Autol) │         N/A         │
│ CognitiveController.gd       │   No (Dead) │         No        │         No           │         N/A         │
│ ContentInjector.gd           │   No (Dead) │         No        │         No           │         N/A         │
│ BudgetStressVisualizer.gd    │   No (Dead) │         No        │         No           │         N/A         │
│ UniversePortal.gd            │   No (Dead) │         No        │         No           │         N/A         │
│ WorldGate.gd                 │   No (Dead) │         No        │         No           │         N/A         │
│ TelemetryOverlay.gd          │   No (Dead) │         No        │         No           │         N/A         │
│ CrossUniverseRunner.gd       │   No (Dead) │         No        │         No           │         N/A         │
│ Remote Content Generator     │      No     │         No        │      Unknown         │  No (External Target│
└──────────────────────────────┴─────────────┴───────────────────┴──────────────────────┴─────────────────────┘
```

---

## 3. Broken Assumption Detector

The Broken Assumption Detector explicitly calls out architectural drift, synthetic completion claims, and mocked systems masquerading as production code.

### 1. Mocked Systems Masquerading as Production Systems
*   **StoreManager.gd (Google Play Billing):** Claimed as a stable production billing layer in earlier reports. **Ground-Truth Reality:** The native `GodotGooglePlayBilling` Android plugin is physically absent from `app/android/plugins/`. `StoreManager.gd` relies entirely on a synthetic async timer (`await get_tree().create_timer(1.0).timeout`) and mock transaction ID string generation.
*   **AdManager.gd & GoodwillManager.gd (Ads & Grace):** Claimed as a production monetization firewall. **Ground-Truth Reality:** Native AdMob and Adsterra plugins are absent. Banners and ad finished callbacks are simulated via print statements (`[AD MANAGER] AdMob Simulation: Showing Banner`).
*   **DiagnosticAutomator.gd (HTTP Crash Uplink):** Claimed as a live HTTP POST crash uplink. **Ground-Truth Reality:** The target remote endpoint `https://api.ittybittybites.com/telemetry/crash_uplink` is offline/unresolvable, resulting in a permanent fallback that buffers payloads locally to `user://crash_queue.jsonl`.

### 2. Unreachable but Still Registered Autoloads
*   **NavigationEngine.gd:** Registered as an active Autoload in `project.godot`. Contains 3D portal selection logic (`process_selection()`). **Ground-Truth Reality:** It is completely bypassed by the active 2D Control UI flow (`WeeklyFeaturedScreen` and `WorldSelectScreen`), which routes button clicks directly to `NavigationRouter.handle_navigation_event()`. It operates as a partially referenced, unused Autoload singleton.
*   **ContentSnapshotManager.gd:** Registered as an active Autoload in `project.godot`. **Ground-Truth Reality:** While it contains `create_snapshot()` methods, its rollback execution hook (`trigger_rollback()`) is disconnected in `GitHubSyncManager.gd`.

### 3. Claims of "Replacement" Without Wiring Evidence
*   **Weekly Rotation & Leaderboard Reset:** Claimed in earlier reports as a fully solved, stable architecture. **Ground-Truth Reality:** While `SamplingController.gd` successfully flushes and locks weekly scenario pools and featured universes based on system time week hashes (`Time.get_date_dict_from_system()["week"]`), **there is zero code evidence of leaderboard reset logic, competitive percentile calculations, or ranking flushes anywhere in the repository.**

---

## 4. Vertical Slice Verification (STRICT)

```
┌───────────────────────────────────────────────────────────────────────────┐
│                    VERTICAL SLICE VERIFICATION (STRICT)                   │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   [STRICT VERIFICATION STATUS]: COMPLETE                                  │
│                                                                           │
│   [EVIDENCE OF DIRECT EXECUTION CHAIN]:                                   │
│   1. BOOT: MainShell._ready() -> show_landing_screen()                    │
│   2. PLAY: BtnPlay pressed -> WeeklyFeaturedScreen opens                  │
│   3. UNIVERSE: Universe card clicked -> WorldSelectScreen opens           │
│   4. WORLD: World card clicked -> GameplayHUD attaches / Scenario spawns  │
│   5. SCENARIO: 3-scenario chain executes -> Answer submitted              │
│   6. MIRROR: toggle_mirror_modal() -> PlayerProfileScreen opens           │
│   7. RETURN HOME: RETURN HOME button clicked -> LandingScreen restored    │
│                                                                           │
│   [EMPIRICAL LOG EVIDENCE]: Verified directly in runtime logs and         │
│   automated test harness `verify_scenario_execution_chain.gd`             │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```
**Qualitative Statement Ban Compliance:** This vertical slice is strictly verified as a functioning execution chain within a hybrid prototype. It operates with simulated peripheral subsystems (mock billing, mock ads, local content bundles). It is not a fully verified closed-loop production release.

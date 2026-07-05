# System Inventory Map

**Phase:** 1 (Repository Design Audit + Inventory) · **Status:** Mapping only — no changes made · **Date:** 2026-07-05

## 1. Core Systems (38 autoloads)

### Navigation (3 systems — overlapping responsibility, flagged)
| System | Path | Role |
|---|---|---|
| NavigationRouter | scripts/NavigationRouter.gd | Screen routing + scene_shift intents (canonical router) |
| NavigationEngine | scripts/NavigationEngine.gd | Portal/transition sequencing (overlaps Router) |
| NavigationState | scripts/system/NavigationState.gd | Navigation mode enum + immutable transition context |

### Content (7 systems)
| System | Path | Role |
|---|---|---|
| ContentRegistry | scripts/content/ContentRegistry.gd | Content authority — universe/world/scenario index + playability API |
| ContentLoader | scripts/content/ContentLoader.gd | Lazy JSON ingestion -> normalize -> register_scenario |
| ObservationCollection | scripts/content/ObservationCollection.gd | Selection engine: filtering, replay protection, deterministic seeding |
| ObservationBuilder | scripts/content/ObservationBuilder.gd | CKO -> gameplay payload transform |
| GameplayDirector | scripts/content/GameplayDirector.gd | Gameplay orchestration over observations |
| GitHubSyncManager | scripts/content/GitHubSyncManager.gd | OTA content sync |
| AssetManifestRegistry | scripts/ui/AssetManifestRegistry.gd | Asset path resolution |

### Progression / Profile (4 systems)
| System | Path | Role |
|---|---|---|
| PlayerProfile | scripts/system/PlayerProfile.gd | Progression state authority (XP, ranks, cognitive baseline) |
| ProgressionInterpreter | scripts/system/ProgressionInterpreter.gd | Progression context for UI |
| MirrorNarrator | scripts/system/MirrorNarrator.gd | Mirror insights generation (read-only) |
| SessionTracker | scripts/system/SessionTracker.gd | Session lifecycle tracking |

### UI / Presentation (6 systems)
| System | Path | Role |
|---|---|---|
| ModalWindowManager | scripts/ui/ModalWindowManager.gd | Modal stack + visibility graph |
| ThemeManager | scripts/ThemeManager.gd | Applies palette + typography per universe |
| VisualIdentityManager | scripts/system/VisualIdentityManager.gd | Resolves universe identity -> tints |
| WorldProfileCustodian | scripts/ui/WorldProfileCustodian.gd | Presentation contracts per world |
| FeedbackManager | scripts/system/FeedbackManager.gd | Presentation-layer feedback |
| LensMorphology | scripts/system/LensMorphology.gd | Lens/iris morphological state |

### Instrumentation (6 systems — scattered, flagged for Phase 6)
| System | Path | Role |
|---|---|---|
| StructuredLogger | scripts/system/StructuredLogger.gd | Logging format authority |
| DiagnosticAutomator | scripts/system/DiagnosticAutomator.gd | Crash detection + self-healing |
| BootTracer | scripts/system/BootTracer.gd | Boot sequence timing |
| IVC0_InstrumentConfig | scripts/system/IVC0_InstrumentConfig.gd | Clinical mode + device hash |
| RuntimeMeasurementIsolation | scripts/system/enforcement/RuntimeMeasurementIsolation.gd | HW signature + residency |
| SystemHealthMonitor | scripts/system/SystemHealthMonitor.gd | Frame budget + tier degradation |

### Runtime Governance (5 systems)
| System | Path | Role |
|---|---|---|
| ExperienceOrchestrator | scripts/system/ExperienceOrchestrator.gd | Runtime experience loop authority |
| ScenarioExecutionEngine | scripts/system/ScenarioExecutionEngine.gd | Gameplay lifecycle + timing |
| InteractionKernel | scripts/system/InteractionKernel.gd | Input eligibility (1 input -> 1 token) |
| FidelityEnforcer | scripts/system/enforcement/FidelityEnforcer.gd | Hard budget constraints |
| RuntimeInvarianceMonitor | scripts/system/enforcement/RuntimeInvarianceMonitor.gd | Layout drift guard |

### Monetization / External (5 systems)
| System | Path | Role |
|---|---|---|
| StoreManager | scripts/system/StoreManager.gd | Google Play Billing adapter |
| StoreTransactionState | scripts/system/StoreTransactionState.gd | Transaction state machine |
| AdManager | scripts/system/AdManager.gd | AdMob (simulated fallback) |
| GoodwillManager | scripts/system/GoodwillManager.gd | Goodwill/reward economy |
| AudioManager | scripts/system/AudioManager.gd | Ambient + SFX buses |

### Sampling / Rotation (2 systems)
| System | Path | Role |
|---|---|---|
| SamplingController | scripts/system/SamplingController.gd | Weekly scenario pool lock |
| WeeklyRotationManager | scripts/system/WeeklyRotationManager.gd | Weekly content subset |

## 2. Scenarios (14 scripts)
BaseScenario + 13 mechanics, all consume _scenario_payload["rules"] from the shared pipeline.

## 3. Documentation (99 .md total)
- docs/design/ (5 canonical design docs)
- app/*.md (31 living specs)
- Instrumentation specs scattered: app/ (2) + app/benchmark/ (9 protocols)
- Historical: docs_legacy/ + app/docs_legacy/ + PHASE_*/ALPHA/RC1 (tagged)

## 4. Duplicates (12 byte-identical pairs)
- 6 root <-> app/ identical .md pairs
- 6 docs_legacy/ <-> app/docs_legacy/ identical pairs

## 5. Ambiguity Clusters
1. Navigation split (Router/Engine/State)
2. Instrumentation scatter (6 systems + 11 specs, no unified schema)
3. Progression authority (PlayerProfile vs ProgressionInterpreter)
4. Two registries (ContentRegistry vs AssetManifestRegistry)
5. Four identity docs (Product Bible, Platform Constitution, Product Strategy, Architecture Status)

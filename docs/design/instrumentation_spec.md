# Instrumentation Specification

**Phase:** 6 | **Status:** Unification schema (additive documentation) | **Date:** 2026-07-05

## 1. Current Systems (6, scattered)
| System | Role | Schema |
|---|---|---|
| StructuredLogger | Event ledger + trial logging | {timestamp_usec, instance_id, node_name, event_type, details} |
| DiagnosticAutomator | Crash + self-heal + uplink | Crash signature -> offline queue |
| BootTracer | Boot timing | {system_name, timestamp_ms} |
| IVC0_InstrumentConfig | Clinical mode + device hash | Device fingerprint |
| RuntimeMeasurementIsolation | HW signature + residency | GPU adapter + shader mode |
| SystemHealthMonitor | Frame budget + thermal | P95/P99 frame times |

## 2. Unified Telemetry Schema
### Authority: StructuredLogger
### Canonical event:
{schema_version:1, timestamp_usec, session_id, device_hash, event_category:"boot|trace|trial|crash|health", event_type, payload:{...}}

### Payloads by category:
- boot: {system_name, timestamp_ms, order_index}
- trace: {instance_id, node_name, details}
- trial: {scenario_id, universe_id, raw_rt_ms, corrected_rt_ms, success, familiarity, cognitive_trait}
- crash: {failure_vector, signature, self_heal_applied}
- health: {p95_frame_ms, p99_frame_ms, active_tier, thermal_state}

### Offline buffering: cohort_telemetry.jsonl (trials), crash_uplink_queue.json (crashes)

## 3. Measurement Pipeline (single path)
RuntimeMeasurementIsolation (HW sig, residency) -> IVC0_InstrumentConfig (hash, cohort) -> ScenarioExecutionEngine (cascade, collect RT) -> StructuredLogger.log_trial() (ledger + disk buffer) -> endpoint (offline=buffer, online=POST)

## 4. Calibration Loop: MCT-0 (Protocol 10)
1. Device fingerprint -> 2. Baseline trial -> 3. Variance detection -> 4. Correction factor -> 5. Validation (Protocol 8)
One calibration loop, one output (corrected_rt). Protocols 2-9 consume it.

## 5. Protocol Catalog
| Protocol | Spec | Measures |
|---|---|---|
| 2-4, 6 | protocol_{n}_spec.md | Measurement dimensions |
| 5 (CBM) | protocol_5_cbm_spec.md | Cognitive Battery Module |
| 7 | protocol_7_identifiability_spec.md | Stimulus identifiability / 1.4x attention threshold |
| 8 | protocol_8_calibration_spec.md | Calibration tolerance |
| 9 | protocol_9_temporal_spec.md | Temporal stability |
| 10 (MCT-0) | protocol_10_mct0_spec.md | THE calibration loop |

## 6. Findings
- StructuredLogger is already de facto authority
- Pipeline is unidirectional and well-sequenced
- Offline buffering implemented
- Protocol specs not cross-referenced (this spec indexes them)
- DiagnosticAutomator uses separate crash format (deferred unification)
- Endpoint offline (known blocker, not defect)

## 7. Recommendations (future)
1. Route DiagnosticAutomator through StructuredLogger (crash category)
2. Consolidate protocols under instrumentation/ dir
3. Unified uploader draining jsonl when endpoint live

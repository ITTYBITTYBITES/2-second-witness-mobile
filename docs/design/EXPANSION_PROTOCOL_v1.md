# EXPANSION_PROTOCOL_v1

**Phase:** 8 — Controlled Expansion Protocol (CEP v1) · **Mode:** Read-only governance document · **Effective:** 2026-07-05 · **Governs:** content growth only (not structure) · **Supersedes:** none · **Respects:** `ARCHITECTURE_STABLE_v1` (Phase 7), `system_contracts.md` (Phase 3), `runtime_flow_spec.md` (Phase 4), `content_lockdown_audit.md` (Phase 5), `instrumentation_spec.md` (Phase 6)

---

## PURPOSE

This protocol defines how new content and universes are safely added to a **frozen-architecture system** without violating the Phase 7 semantic freeze, the Phase 3 system contracts, the Phase 4 runtime flow constraints, or the Phase 5 content pipeline rules.

**This phase governs growth only, not structure.** The architecture is frozen (v1); expansion happens entirely within the locked system.

---

## HARD CONSTRAINTS (ABSOLUTE)

### You MUST NOT
- modify existing architecture
- rename systems
- change navigation structure
- bypass `ContentRegistry`
- bypass `ObservationCollection`
- bypass `ScenarioExecutionEngine`
- introduce new top-level systems outside the 5 defined layers
- alter Phase 7 semantic definitions

### You MAY ONLY
- add content
- add universes
- extend observation banks
- add scenarios (if they extend `BaseScenario`)
- validate ingestion safety
- classify content quality

---

## 1. UNIVERSAL EXPANSION MODEL

### Pipeline Rule
All content enters the system **only** through:

```
ContentLoader → ContentRegistry → ObservationCollection → ScenarioExecutionEngine
```

- **No exceptions.** No direct injection. No bypass ingestion.
- `ContentLoader._load_and_register_file()` is the sole file-reader; `ContentRegistry.register_scenario()` is the sole mutator of the content index.
- Enforced today: no other system reads bank JSON or writes to `runtime_index` (validated Phase 5).

---

## 2. UNIVERSE ADDITION RULE

A new universe is valid **only if** it includes:

### Required Structure
| Requirement | Enforcement |
|---|---|
| `world_order` defined in `MASTER_UNIVERSE_REGISTRY.json` | ContentRegistry loads the master registry; missing `world_order` → world list empty |
| At least 1 world populated in the `worlds` dict | Empty `worlds` → universe is scaffolded, never playable |
| Each world has ≥ 1 observation bank file under `data/content/base_bundle/<universe>/<world>/` | ContentLoader indexes by directory presence; missing bank → world shows "no observations" |
| Each observation conforms to the validated schema | Gate A (§4) |

### Forbidden
- empty universes in production state (`status: complete` with zero playable worlds)
- placeholder-only worlds (status `scaffolded`/`spike_catalog_only` are allowed but never player-visible)
- synthetic filler entries ("Test", "Spike", "Placeholder", "Knowledge Spike" patterns)

### Universe Status Lifecycle
```
spike_catalog_only  →  scaffolded  →  complete
     (no content)       (banks exist,    (all worlds have real
                          not all worlds)   content; player-visible)
```
A universe reaches `complete` (player-visible) only when **all** `world_order` worlds pass Gates A–D. Flipping `status` to `complete` is the only step that exposes content; it requires no engine code change.

---

## 3. OBSERVATION QUALITY STANDARD

Each observation MUST pass all three sub-checks.

### 3.1 Structural Validity (Gate A)
- Valid schema: has resolvable `id` (or `observation_id`), `universe`, `world`, and a scenario `type` (or a format the loader normalizes to one).
- Correct scenario-type mapping: `observation_type` (v2_compiled) maps via `_OBS_TYPE_TO_MECHANIC`; v3 entity items register as `dynamic`.
- No missing required fields.
- **Enforced by:** `ContentLoader._validate_schema()` + `_normalize_item()`.

### 3.2 Cognitive Validity (non-functional but enforced)
- Must be meaningful to gameplay (a real prompt + answer + distractors, or a real entity/features payload).
- Must not be decorative noise.
- Must support at least one gameplay mechanic (i.e., produce non-empty `rules` via `ObservationBuilder.build_payload()`).
- **Enforced by:** runtime probe — `build_payload()` must return a non-empty `rules` dict for at least one valid mechanic.

### 3.3 Uniqueness Rule
- No duplicate observation IDs across the full system (global uniqueness).
- No semantically identical entries across worlds (same prompt + same correct_answer in the same universe is flagged).
- **Enforced by:** `observation_content_validator.py` (duplicate-ID check + repeated-answer warning).

---

## 4. CONTENT INTEGRITY GATES

Before ingestion, all content must pass these four gates. Failure of any gate rejects the entire batch (§10).

### Gate A — Schema Gate
- Validates structure compliance (§3.1).
- **Tool:** `ContentLoader._validate_schema()` at load + `observation_content_validator.py` (offline scan).
- **Rejects:** items missing `id`/`universe`/`type` after normalization.

### Gate B — Gameplay Gate
- Ensures each observation maps to a valid scenario type and produces a playable payload.
- **Tool:** runtime `ObservationBuilder.build_payload()` probe + `observation_content_validator.py` (answer/distractor validity).
- **Rejects:** items whose `observation_type` doesn't resolve to a mechanic and aren't v3-entity; items with the correct answer appearing in distractors; items with fewer than 2 distractors (where distractors are required).

### Gate C — Redundancy Gate
- Rejects exact duplicates and flags near-duplicates.
- **Tool:** `observation_content_validator.py` (duplicate ID detection across all banks).
- **Rejects:** exact duplicate observation IDs. **Flags (does not reject):** repeated correct-answer strings within a universe (semantic near-duplication — author review).

### Gate D — Placeholder Gate
- Rejects synthetic/filler content.
- **Tool:** `ContentLoader._is_placeholder()` (runtime) + `observation_content_validator.py` (offline).
- **Rejects patterns:** "Verified Observation #", "Anomaly A#", "Distractor B#", "PROTOCOL SEQUENCE", "Knowledge Spike", and any item whose `id` contains `spikes_catalog`.
- **Also rejects:** items matching the placeholder patterns "test", "example", "placeholder", "spike" as meaningful content text.

---

## 5. WORLD DESIGN RULE

Each world MUST:
- belong to exactly one universe.
- define a consistent thematic axis (e.g., `ancient_rome` → Roman civilization; not a grab-bag).
- support at least 2 scenario types (recommended; not strictly enforced — single-mechanic worlds are valid but mechanically thin).
- avoid mechanical identity drift (no mixed incoherent domains within one world).

**Valid example:**
- `history/ancient_rome` → rapid_classification, signal_vs_noise, memory_cascade (emperors, gods, architecture, military).

**Invalid example:**
- `history/world_7` → mixed unrelated domains with no thematic axis.

**Authoring tool:** `tools/generate_observation_bank.py` produces banks from a curated TSV, enforcing per-row validity (answer-not-in-distractors, ≥2 distractors, difficulty 1–5). A new world = one TSV + one command.

---

## 6. SCENARIO COMPATIBILITY RULE

All new content MUST map to:
- **existing `BaseScenario` types only.** The 13 valid mechanics: `rapid_classification`, `signal_vs_noise`, `odd_one_out`, `stroop_test`, `memory_cascade`, `sequence_reverse`, `spatial_recall`, `pattern_continuation`, `speed_sort`, `math_surprise`, `reflex_tap`, `risk_selection` (+ `dynamic` for v3-entity items, JIT-mapped).
- **No new scenario classes** without a Phase 7 override (i.e., `ARCHITECTURE_STABLE_v2`).
- **No ad-hoc gameplay logic embedded in content.** Content is data only — never logic.

**Content is data only — never logic.** A scenario type is a label that selects a mechanic; the mechanic's behavior is defined in code (frozen), not in the bank JSON.

---

## 7. EXPANSION SAFETY RULE

Before adding any universe, confirm **all** of the following:

| Check | Required state |
|---|---|
| No structural modification required | Adding universe = registry entry + data files only |
| No new system layer required | Content fits the Content Layer (Phase 7 §2.3) |
| No new registry introduced | Uses `ContentRegistry` + `AssetManifestRegistry` only |
| No navigation changes required | Universe appears via `get_playable_universes()` when `status=complete`; no router edit |

**If any check fails:** `BLOCK EXPANSION — REQUIRE ARCHITECTURE_STABLE_v2`. The expansion cannot proceed under v1 and must be deferred to a new versioned freeze that explicitly re-establishes the affected immutability rule(s).

---

## 8. CONTENT BALANCE RULE

Prevents overconcentration that would skew the player experience or the selection engine.

| Limit | Rationale |
|---|---|
| No single universe may exceed **70%** of total system content | Prevents one domain from dominating discovery |
| No world may exceed **50%** of its universe's content in one scenario type | Ensures mechanical diversity within a world |
| Distribution must remain mechanically diverse across the system | No mechanic may be the sole type available in a playable universe |

**Current state (as of freeze):** `creative_arts` holds ~98% of content (20,000 of 20,186 observations). This is **acceptable under v1** (only one playable universe exists; balance rules apply once multiple universes reach `complete`). As additional universes are authored to `complete`, the 70% cap becomes binding and `creative_arts` naturally falls below it.

**Enforcement:** `observation_content_validator.py` should be extended (future, additive) with a balance report. Not blocking under v1 freeze.

---

## 9. VALIDATION OUTPUT REQUIREMENT

Every expansion run MUST output:

| Metric | Source |
|---|---|
| Number of items added | `ContentLoader` load log (registered count) |
| Universes affected | Validator universe tally |
| Worlds affected | Validator world tally |
| Schema pass/fail count | Gate A (`observation_content_validator.py`) |
| Duplicates rejected | Gate C |
| Placeholders rejected | Gate D |
| Final system totals | `ContentRegistry.get_scenario_count()` (runtime) |

**Minimum command sequence for an expansion batch:**
```bash
# 1. Generate bank from curated source (if using TSV authoring)
python3 tools/generate_observation_bank.py <universe> <world> <source.tsv>

# 2. Validate (Gates A, C, D — offline)
python3 tools/observation_content_validator.py

# 3. Runtime verify (Gate B — payload produces valid rules)
godot --headless --path app [probe or verification suite]

# 4. Expose (only when all worlds pass)
# Edit MASTER_UNIVERSE_REGISTRY.json: status -> "complete"
```

---

## 10. FAILURE HANDLING RULE

If any gate (A–D) fails:
- **Reject the entire batch.** No partial ingestion. Either all items in a world's bank pass, or none are trusted.
- **Log the failure reason** (validator error output / loader "0 registered, N skipped" message).
- **Do NOT modify existing content.** A failed batch leaves the registry exactly as it was.
- **Require correction and re-submission.** Fix the source data (TSV or bank JSON), re-run validation, re-attempt.

**Atomicity guarantee:** `ContentLoader` registers items one at a time, but a world is only considered "loaded" after its bank file is fully parsed. A parse failure on any item logs the error and skips that item; the world is marked loaded but may be incomplete. The validator (run before exposing via `status=complete`) catches incompleteness. **Never flip a universe to `complete` unless the validator reports zero errors for all its worlds.**

---

## 11. SAFE STATE GUARANTEE

After each expansion batch, the system MUST remain:
- **structurally unchanged** — no code, no system, no layer added or modified.
- **fully compatible with the Phase 7 freeze** — all 7 immutability rules intact.
- **fully compliant with Phase 3–6 contracts** — content authority, progression authority, navigation flow, instrumentation schema all honored.

If any post-expansion check fails, the batch is considered unsafe and the universe's `status` must remain below `complete` (not player-visible) until corrected.

---

## 12. EXPANSION PRINCIPLE

> **The system grows only by addition of validated content, never by modification of architecture.**

Content is added as data. Architecture is changed only via versioned freezes. These two truths are separable, and Phase 8 enforces the separation.

---

## PHASE 8 COMPLETE — CONTROLLED EXPANSION PROTOCOL ACTIVE (v1)

---

### What this enables
After Phase 8, the system:
- **cannot structurally drift** (Phase 7 freeze)
- **cannot semantically drift** (Phase 7 aliases locked)
- **cannot silently degrade via content** (Phase 8 gates A–D + balance rules)
- **can still scale indefinitely** via controlled ingestion

### The next step (Phase 9)
Phase 9 becomes the first **real production operation layer**: run the expansion pipeline on all 13 incomplete universes safely. The system stops being a framework and becomes a living content machine — each universe authored through the CEP, validated against all four gates, and exposed only when complete.

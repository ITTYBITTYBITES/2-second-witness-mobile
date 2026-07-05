# UNIVERSE_COMPLETION_RUNBOOK_v1

**Phase:** 9 — Universe Completion Runbook (UCR v1) · **Mode:** Execution-level operational runbook · **Date:** 2026-07-05 · **Governs:** content population only (not structure) · **Respects:** `ARCHITECTURE_STABLE_v1` (Phase 7), `EXPANSION_PROTOCOL_v1` (Phase 8), all Phase 3–6 contracts

---

## PURPOSE

This runbook defines the **exact operational sequence** for completing all 13 incomplete universes using the already-frozen architecture (Phases 7–8). It is procedural, repeatable, batch-safe, and validation-driven.

**It is NOT architectural, structural, or exploratory.** The system does not evolve during Phase 9 — it is populated.

---

## HARD CONSTRAINTS

### You MUST NOT
- modify architecture (Phase 7 locked)
- bypass ingestion gates (Phase 8 enforced)
- introduce new validation systems
- alter scenario system definitions
- add new system layers

### You MAY ONLY
- author observation content
- run the validation pipeline (existing tools)
- classify results
- mark completion state in the registry (`status` field only)
- retry failed batches

---

## 1. EXECUTION ORDER (GLOBAL)

Universes are completed in risk-ascending tiers. Tier 1 calibrates the process on universes that already have *some* real content; Tier 2 handles empty-but-structured scaffolds; Tier 3 handles placeholder-only universes (cleanest slate, most authoring volume).

> **Registry reconciliation note:** The execution spec referenced universes named "astronomy / engineering / language_systems / social_structures." Those IDs do not exist in `MASTER_UNIVERSE_REGISTRY.json`. The actual Tier 3 universes (verified against the registry) are listed below. The mapping is:
> `astronomy` → `space_astronomy`; the others map to `nature_environment`, `science_discovery`, `travel_tourism`. `engineering` / `language_systems` / `social_structures` do not correspond to any registered universe and are not processed.

### Tier 1 — Partial Content (low-risk calibration)
| Universe | Status | Worlds | Current real observations | Purpose |
|---|---|---|---|---|
| `history` | scaffolded | 20 | 74 (`ancient_rome`=71 + 3 sparse) | Calibrate on a universe with proven content (`ancient_rome` is the authoring template) |
| `science_lab` | scaffolded | 20 | 96 (6 worlds, sparse) | Calibrate on multi-world sparse content |
| `society_mind` | scaffolded | 20 | 16 (1 world) | Calibrate on single-world seed content |

### Tier 2 — Empty Scaffolds (medium complexity)
| Universe | Status | Worlds | Current real observations |
|---|---|---|---|
| `frontier` | scaffolded | 20 | 0 |
| `life_sciences` | scaffolded | 22 | 0 |
| `tech_ops` | scaffolded | 20 | 0 |

### Tier 3 — Placeholder Universes (clean slate)
| Universe | Status | `world_order` | Current real observations |
|---|---|---|---|
| `animals_wildlife` | spike_catalog_only | 10 | 0 |
| `food_cuisine` | spike_catalog_only | 10 | 0 |
| `geography` | spike_catalog_only | 10 | 0 |
| `nature_environment` | spike_catalog_only | 10 | 0 |
| `science_discovery` | spike_catalog_only | 10 | 0 |
| `space_astronomy` | spike_catalog_only | 10 | 0 |
| `travel_tourism` | spike_catalog_only | 10 | 0 |

**Totals:** 13 universes · 232 worlds to populate · 186 real observations to grow into full coverage.

---

## 2. PER-UNIVERSE EXECUTION LOOP

For EACH universe, run all seven steps before advancing to the next universe.

### Step 1 — Inventory Scan
```bash
# List the universe's worlds and their current observation counts
python3 -c "
import json, glob, os
U='<universe>'
reg=json.load(open('app/MASTER_UNIVERSE_REGISTRY.json'))['universes'][U]
print('world_order:', reg.get('world_order', []))
for w in reg.get('world_order', []):
    banks=glob.glob(f'app/data/content/base_bundle/{U}/{w}/*_observation_bank_compiled.json')
    total=0
    for b in banks:
        d=json.load(open(b)); total += len(d) if isinstance(d,list) else 1
    print(f'  {w}: {len(banks)} bank(s), {total} items')
"
```
Classify each world: **empty** (0 items), **partial** (1–99), **complete** (≥ threshold, see Step 6).

### Step 2 — World Targeting
Process **one world at a time.** For the selected world:
- Determine dominant scenario types from existing patterns in the universe (or, for a clean-slate world, pick 2–3 mechanics that fit the theme — e.g., `rapid_classification` + `signal_vs_noise` + `memory_cascade`).
- Define the thematic axis (e.g., `ancient_rome` → Roman civilization; `mammals` → mammalian biology).

### Step 3 — Content Authoring
Generate observation banks using the established authoring tool:
```bash
python3 tools/generate_observation_bank.py <universe> <world> <source.tsv>
```
**Requirements per observation:**
- Schema-compliant (resolves to `id` + `universe` + `type` after loader normalization).
- Gameplay-valid (produces non-empty `rules` via `build_payload()`).
- Non-placeholder (passes Gate D).
- Mechanically relevant (maps to a real BaseScenario type).
- Consistent within the world theme (conceptual domain cohesion).

**Authoring standard:** ≥ 50 observations per world (target 100+ for rich worlds). Source TSV is the editable canonical input; the generated JSON is the build artifact.

### Step 4 — Pre-Ingestion Validation (CEP Gates)
```bash
python3 tools/observation_content_validator.py
```
Must pass **all four gates** (Phase 8 §4):
| Gate | Checks | On failure |
|---|---|---|
| **A — Schema** | id + universe + type present; valid fields | reject batch |
| **B — Gameplay** | observation_type maps to a mechanic; answer not in distractors; ≥2 distractors | reject batch |
| **C — Redundancy** | no duplicate observation IDs globally | reject batch |
| **D — Placeholder** | no "test/spike/placeholder/Knowledge Spike" patterns | reject batch |

**FAIL = reject entire batch.** Return to Step 3. Do not modify existing content.

### Step 5 — Runtime Verification
Execute a headless probe to confirm `build_payload()` produces valid rules:
```bash
godot --headless --path app [probe: next_observation(u,w,'',mechanic) -> build_payload()]
```
Verify for at least 2 distinct mechanics:
- valid question generation (non-empty `prompt`)
- valid distractors (≥2, none equal to the answer)
- no null outputs
- scenario compatibility (payload has `rules` dict)

### Step 6 — Commit Batch
Only if ALL gates pass AND runtime verification passes:
- The bank is already ingested by `ContentLoader` on next load (data-only; no code change).
- Update world registry counts (validator confirms the new totals).
- A world reaches the **completion threshold** when: ≥ 50 real observations, ≥ 2 scenario types represented, 100% validation pass.

### Step 7 — Universe Completion Check
A universe is **COMPLETE** when:
- all `world_order` worlds meet the completion threshold (Step 6),
- no empty worlds remain,
- validation pass rate = 100% (`observation_content_validator.py` exit 0),
- no placeholder content exists (Gate D clean),
- runtime verification passes for every world.

When complete, flip `status` in `MASTER_UNIVERSE_REGISTRY.json`:
```json
"<universe>": { "status": "complete", ... }
```
This is the **only** registry field changed in Phase 9, and it requires no engine code change.

---

## 3. CONTENT QUALITY STANDARD (STRICT)

Each observation must satisfy:

### Gameplay Relevance
Must be usable in at least one of:
- memory recall (`memory_cascade`, `sequence_reverse`)
- classification (`rapid_classification`)
- pattern recognition (`signal_vs_noise`, `pattern_continuation`)
- sequence logic (`sequence_reverse`)
- odd-one-out logic (`odd_one_out`)

### No Decorative Data — REJECTED:
- trivia-only entries with no gameplay function
- purely encyclopedic noise (no prompt/answer/distractor structure)
- filler repetition sets

### Semantic Consistency
Within a world, all observations must share conceptual domain cohesion. A world with mixed incoherent domains is rejected (Phase 8 §5).

---

## 4. FAILURE HANDLING

If ANY gate (A–D) fails:
- **reject the entire batch** — no partial ingestion (Phase 8 §10).
- **log the failure reason** (validator output / loader "0 registered, N skipped").
- **return to Step 3** (authoring) — fix the source TSV, regenerate, re-validate.
- **do NOT modify existing content** — a failed batch leaves the registry exactly as it was.
- **retry until clean** — there is no "partial credit" path.

---

## 5. COMPLETION MARKING RULE

A world may be marked `status = complete` **only if**:
- validation pass = 100%,
- no placeholder entries,
- no schema violations,
- runtime verification passed.

A universe may be marked `status = complete` **only if** all its `world_order` worlds are complete. Flipping the status is the final action for that universe; it exposes the universe to players via `get_playable_universes()`.

---

## 6. PROGRESSION SAFETY RULE

At no point may Phase 9:
- alter scenario logic,
- alter registry structure (only the `status` field value changes),
- alter navigation flow,
- introduce new systems.

**This phase is strictly: data completion inside a frozen architecture.**

---

## 7. OUTPUT REQUIREMENTS PER BATCH

Each ingestion batch MUST output (and these are recorded in the expansion log):

| Metric | Source |
|---|---|
| Universe name | batch header |
| World name | batch header |
| Number of observations added | `ContentLoader` registered count |
| Number rejected (by gate type) | validator report |
| Runtime validation result | probe output (pass/fail per mechanic) |
| Final world status | `complete` or `scaffolded` |

---

## 8. GLOBAL SUCCESS CONDITION

Phase 9 is complete when:
- all 13 incomplete universes are in `complete` state,
- no empty worlds remain across the system,
- all content passes CEP v1 gates (validator exit 0),
- the system remains fully compliant with `ARCHITECTURE_STABLE_v1`,
- the content balance rule (Phase 8 §8) is satisfied — no single universe exceeds 70% of total content once multiple universes are complete.

---

## 9. PRINCIPLE OF OPERATION

> **The system does not evolve during Phase 9. It is populated.**

Content is added as data through the frozen pipeline. Architecture is untouched. Validation gates enforce integrity. Completion is a registry flag, not a code change.

---

## PHASE 9 COMPLETE — UNIVERSAL CONTENT COMPLETION RUNBOOK ACTIVE (v1)

---

### What this enables
After Phase 9 execution (the actual population work, which is the first *real production operation*):
- all universes are playable,
- the content machine has been exercised end-to-end,
- every gate has been load-tested,
- the system is ready for live operational governance (Phase 10).

### Execution estimate
- 13 universes × ~10–22 worlds each ≈ 232 worlds to author.
- At ≥50 observations/world target, that is ~11,600+ observations to author.
- Tier 1 (3 universes) calibrates the process; Tiers 2–3 scale it.

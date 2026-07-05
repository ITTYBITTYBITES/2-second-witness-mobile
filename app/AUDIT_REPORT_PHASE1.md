# Phase 1 Audit Report — Liquid Memory V2 Observation System

**Date:** 2026-07-05 · **Status:** Pre-change audit complete · **Scope:** All observation content, registry, and engine contract

---

## 1. Topology & Content Inventory

| Metric | Count |
|---|---|
| Universes in `MASTER_UNIVERSE_REGISTRY.json` | 14 |
| Universes with **populated** `worlds` (active) | 7 |
| Universes with `world_order` only (no populated worlds) | 7 |
| Active worlds (7 universes) | 142 |
| `*_observation_bank_compiled.json` files | 142 |
| Observations in compiled banks | 20,000 |
| `spikes_catalog_2000.json` files (placeholder) | 70 |
| Synthetic placeholder items in spikes catalogs | ~140,000 |

**Active universes (real content):** `creative_arts`, `frontier`, `history`, `life_sciences`, `science_lab`, `society_mind`, `tech_ops`

**Placeholder-only universes (spikes_catalogs):** `animals_wildlife`, `food_cuisine`, `geography`, `nature_environment`, `science_discovery`, `space_astronomy`, `travel_tourism`

---

## 2. Issues Found

### 🔴 CRITICAL — 100% of real observations silently dropped by engine contract
`ContentLoader._validate_schema()` requires items to have `id` AND `universe` AND `type`. The 20,000 compiled-bank observations use **different field names**:
- **v3_entity format (16,000 items):** `observation_id`, `entity`, `features`, `dimensions`, `confusions` — no `id`, no `type`
- **v2_compiled format (4,000 items):** `observation_id`, `observation_type`, `prompt`, `correct_answer`, `distractors` — no `id`, `type` is `observation_type`

**Runtime proof:** registry `scenario_count: 0`; every `next_observation()` returns `{}`. **Zero observations reach gameplay.**

### 🔴 HIGH — Synthetic placeholder content is live and reachable
The 7 placeholder universes each have `world_order` listing 10 worlds, and `spikes_catalog_2000.json` files containing auto-generated garbage:
- `correct_answer: "Verified Observation #1"`
- distractors: `["Anomaly A#1", "Distractor B#1"]`
- prompts: `"[Amphibians] ANALYZE AMPHIBIANS PROTOCOL SEQUENCE #1 // TRACE ..."`

These are v1-legacy format, **pass `_validate_schema`**, and are indexed by `ContentLoader`. If a player navigates to these universes, they receive fake content. This violates the "no placeholder content" gate.

### 🟠 MED — `observation_type` values do not map to engine mechanics
The 4,000 v2_compiled items label their `observation_type` with question-style names that don't correspond to the engine's gameplay mechanics (`rapid_classification`, `signal_vs_noise`, `memory_cascade`, etc.):

| observation_type | count | → snake_case | valid mechanic? |
|---|---|---|---|
| Rapid Recognition | 3,000 | rapid_recognition | ❌ |
| Rapid Classification | 355 | rapid_classification | ✅ |
| Visual Identification | 190 | visual_identification | ❌ |
| Tool/Technique Recognition | 165 | tool_technique_recognition | ❌ |
| Artwork → Artist | 75 | artwork_artist | ❌ |
| (others) | 215 | various | ❌ |

### 🟠 MED — Two canonical formats with no shared normalization
`v3_entity` and `v2_compiled` coexist with no single ingestion path. `ObservationBuilder` has `_build_v3_payload` and `_build_legacy_v1_payload` but no v2_compiled path; `ObservationCollection.standardize()` has a CKO branch but it triggers on `concept`/`recognized_answer` (absent from both compiled formats).

### 🟢 LOW — Phase-2 metadata fields largely absent
Most observations lack `title`, `description`, `category`, `rarity`. `tags` present only in the 4,000 v2_compiled items (under `metadata.tags`). `difficulty` is `int` in v3_entity but `{"label","tier"}` dict in v2_compiled (type drift).

---

## 3. What Is Already Healthy (no action needed)

- ✅ **0 duplicate IDs** across 20,000 observations (all `observation_id`s unique)
- ✅ **0 missing IDs** — every item has an `observation_id`
- ✅ **0 empty/thin banks** — all 142 compiled banks have substantial content
- ✅ **0 hardcoded observation/world/question data in scenarios** — all 13 scenario classes (`RapidClassification`, `SignalVsNoise`, `PatternContinuation`, `MemoryCascade`, etc.) `extend BaseScenario` and consume `_scenario_payload["rules"]` from the shared pipeline
- ✅ **Registry ↔ disk perfectly reconciled** for the 7 active universes (no orphan banks, no missing banks)
- ✅ **Selection engine (Phase 5) substantially present** — `ObservationCollection` supports difficulty filtering (`min/max_difficulty`), replay protection (`_recent_by_scope`/`_recent_global`), deterministic seeded selection (`sort_custom` with `seed_value.hash()`), and scope filtering (universe/world/subcategory/mechanic)
- ✅ **Project compiles clean** (post earlier fixes) and boots with 0 errors / 0 warnings headless

---

## 4. Recommended Remediation Plan

| # | Issue | Fix | Phases |
|---|---|---|---|
| 1 | Data contract drop | **Adapter in `ContentLoader`**: normalize bank-native fields to registry schema at load. v3→`type:"dynamic"`, v2→map `observation_type`→mechanic + bundle `rules`. Relax mechanic filter to include `dynamic`. | P2/P4 |
| 2 | Placeholder content | Add content-quality gate rejecting synthetic patterns; placeholder universes become empty-world (flagged by validation) rather than shipping fakes. | P1 |
| 3 | observation_type mapping | Explicit map table for the 8 question-types → real mechanics; unmapped → `dynamic` (JIT). | P3 |
| 4 | Format fragmentation | Adapter produces one canonical intermediate dict; `standardize()` consumes it. | P2 |
| 5 | Metadata gaps | Validator flags gaps; does not block (real content has enough to play). | P6 |
| 6 | Validation tooling | Add `observation_content_validator.py` (Phase 6) enforcing integrity + detecting placeholders/empties. | P6 |

**Engine code change surface:** ~3 files (`ContentLoader.gd`, `ObservationCollection.gd`, `ContentRegistry.gd`). After this, **new universes/worlds/observations are added purely via registry data** — no engine edits (Phase 8).

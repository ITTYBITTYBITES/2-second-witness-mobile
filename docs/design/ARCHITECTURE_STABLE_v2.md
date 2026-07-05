# ARCHITECTURE_STABLE_v2

**Phase:** 7 (versioned update) · **Mode:** Semantic freeze update · **Effective:** 2026-07-05 · **Supersedes:** `ARCHITECTURE_STABLE_v1.md`

> This document supersedes v1. It documents a single, deliberate change to the Content Layer and re-establishes the immutability rules accordingly. All other v1 definitions remain in force.

---

## 1. WHAT CHANGED

### ObservationBuilder upgraded: v3 implicit projection → v4 contract-driven projection

**Before (v1/v3):** `_build_v3_payload` used implicit, ad-hoc branching with eager default-argument evaluation. This caused a runtime crash when `features.visual` was a Dictionary (the v3_entity standard format) and the `signal_vs_noise` branch tried `features.get("visual", ["Observation"])[0]` — evaluating `Dictionary[0]` as an eager default.

**After (v4):** A three-stage deterministic pipeline:

```
ENTITY → EDGE NORMALIZATION → COMPATIBILITY CHECK → PROJECTION
```

1. **`_normalize_entity(raw)`** — the single place format ambiguity is resolved. Safely converts any v3 entity (Dict-visual, Array-visual, String-visual, or missing) into a canonical internal representation. Never crashes.
2. **`_is_compatible(norm, mechanic)`** — checks the normalized entity against the mechanic's `MECHANIC_CONTRACTS` entry (required features). Deterministic: same entity + mechanic = same result.
3. **`_project(norm, mechanic)`** — produces structurally distinct rules per mechanic, using only the normalized fields. If incompatible, `_project_fallback(norm)` produces a safe identification payload (never empty, never crashes).

**New public API:** `get_compatible_mechanics(cko)` — returns the list of mechanics an entity can fully satisfy. Enables future mechanic coverage maps per universe.

---

## 2. WHY IT CHANGED

- **Bug fix (required):** signal_vs_noise crashed on all v3_entity content. This is a correctness defect, not a feature request.
- **Polymorphism guarantee:** the v3 projection was "mostly polymorphic" (4/5 mechanics). v4 makes it **deterministically polymorphic** — every entity either satisfies a contract or falls back gracefully, with no runtime guessing.
- **No data migration:** the 16,000 existing v3_entity observations are unchanged. The normalization layer handles their format at the projection boundary.

---

## 3. IMMUTABILITY RULES UPDATED

### Rule 3 (content authority) — UPDATED
> No new system may bypass `ContentRegistry`. `ObservationBuilder` remains the sole projection authority for entity → payload transformation. The v4 contract layer (`MECHANIC_CONTRACTS`, `_normalize_entity`, `_is_compatible`) is an internal subsystem of `ObservationBuilder`, not a new top-level system.

### Rule 7 (scenario compatibility) — CLARIFIED
> The 13 valid BaseScenario mechanics remain unchanged. `ObservationBuilder` now determines mechanic compatibility per-entity via contracts, but the mechanic set itself is frozen. Adding a new mechanic requires a new `MECHANIC_CONTRACTS` entry AND a new `BaseScenario` subclass — a v3 freeze.

### All other v1 rules — UNCHANGED
Rules 1, 2, 4, 5, 6 remain exactly as defined in `ARCHITECTURE_STABLE_v1.md`.

---

## 4. ALIAS RESOLUTION — UPDATED

| Concept | v1 Resolution | v2 Update |
|---|---|---|
| `ObservationBuilder` | v3 implicit projector | **v4 contract-driven projector** (sole projection authority) |
| `MECHANIC_CONTRACTS` | (did not exist) | **New internal const** defining each mechanic's required features |
| `_normalize_entity` | (did not exist) | **New edge normalization layer** (single point of format resolution) |
| `get_compatible_mechanics` | (did not exist) | **New public API** for mechanic coverage queries |

All other v1 aliases remain locked.

---

## 5. VERIFICATION (post-change)

| Check | Result |
|---|---|
| Boot (0 errors/warnings) | ✅ PASS |
| Validator (0 errors) | ✅ PASS (20,200 observations) |
| Full suite (40/40 compile & execute) | ✅ PASS (no regression) |
| signal_vs_noise crash | ✅ FIXED (produces valid output for all entity formats) |
| All 5 mechanics produce valid output | ✅ space_astronomy: 35/35 compatible; creative_arts: 4/5 compatible + 1 graceful fallback |
| Legacy v3_entity content unaffected | ✅ 16,000 creative_arts observations work unchanged |

---

## 6. SYSTEM REMAINS FROZEN

The system is **still semantically frozen**. This v2 update was a correctness fix (crash + determinism), not a structural redesign. The 5-layer model, the authority boundaries, the interaction rules, and the alias locks from v1 all remain in force. Future changes continue to require versioned freeze documents.

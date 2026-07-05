# World Definition of Done

**Date:** 2026-07-05 · **Governs:** every world before it becomes "published"

> A world is not done when it has content. A world is done when it has *validated, complete, balanced, tested* content. Each world is a permanent asset — it should never need revisiting unless a genuine content issue is found.

---

## 1. Definition of Done (all must be true)

| # | Criterion | Verification |
|---|---|---|
| 1 | **All entities validate successfully** | `observation_content_validator.py` exit 0, zero errors for this world |
| 2 | **Feature Graph Snapshot generated with zero unresolved required features** | `FeatureGraphCompiler.compile_batch()` — every entity's required features resolved |
| 3 | **Coverage meets target for every intended mechanic** | Coverage report: ≥ 50% for each intended mechanic (≥ 80% target) |
| 4 | **No placeholder observations remain** | Gate D clean — no test/spike/placeholder patterns |
| 5 | **Difficulty distribution is balanced** | No single difficulty tier exceeds 60% of the world's content |
| 6 | **World metadata, assets, and localization are complete** | Registry entry present, observation_count/world_count updated, localization keys present |
| 7 | **World passes the full regression suite unchanged** | 40/40 benchmarks compile & execute, 0 new errors |

## 2. Execution Strategy

- **One world at a time.** Not one universe at a time. Each completed world is a shippable milestone.
- Each world is authored, validated, compiled, coverage-checked, and regression-tested as a discrete batch.
- A world is either Done or Not Done. No partial credit.

## 3. Execution Order (Tier 1 calibration first)

1. Complete remaining worlds in **history** (19 worlds — ancient_rome done, 19 remaining)
2. Complete **science_lab** (20 worlds — physics done, 19 remaining)
3. Complete **society_mind** (20 worlds)
4. Continue through Tier 2 (frontier, life_sciences, tech_ops)
5. Continue through Tier 3 (placeholder universes)

## 4. Per-World Workflow

```
1. Author observations (TSV → generate_observation_bank.py)
2. Validate (observation_content_validator.py — Gates A, C, D)
3. Compile snapshot (FeatureGraphCompiler.compile_batch — Gate B + trace)
4. Review coverage report (≥50% per intended mechanic)
5. Check difficulty distribution
6. Run regression suite (40/40 unchanged)
7. Mark world done — permanent asset
```

When ALL worlds in a universe are Done → flip `status: complete` in the registry.

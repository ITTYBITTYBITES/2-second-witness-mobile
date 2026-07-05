# COMPILER_FREEZE_v1

**Date:** 2026-07-05 · **Status:** FROZEN · **Governs:** ObservationBuilder (v4.2) + FeatureGraphCompiler (feature-graph-v1)

> The observation compiler is now frozen. Only the four change types defined in §1 are permitted. Everything else is rejected at review.

---

## 1. Compiler Change Policy

| # | Change type | Permitted? | Conditions |
|---|---|---|---|
| 1 | **Bug fix** | ✅ | Existing entities were compiled incorrectly; existing snapshots were objectively wrong. Must reproduce via snapshot diff before fix; must show the diff after fix. |
| 2 | **Schema extension** | ✅ | New features added without changing the meaning of existing ones. Existing snapshots remain valid. Feature resolver additions only — no redefinition of existing resolvers. |
| 3 | **Compiler version upgrade** | ✅ (breaking) | Intentionally breaking change. Increment `SCHEMA_VERSION` and `RESOLVER_VERSION`. Regenerate all snapshots. Never compare snapshots across compiler versions. |
| 4 | **Performance improvement** | ✅ | Faster compilation or lower memory. Zero observable behavioral change. Snapshot diff must show zero feature or projection changes. |
| — | *Anything else* | ❌ | Rejected at review. "Small improvements" that destabilize the compiler over months are the failure mode this policy prevents. |

---

## 2. Frozen Artifacts

| Artifact | Version | State |
|---|---|---|
| `ObservationBuilder.gd` | v4.2 (feature-contract substrate) | FROZEN |
| `FeatureGraphCompiler.gd` | feature-graph-v1 | FROZEN |
| `FEATURE_RESOLVERS` mapping | v4.2 | FROZEN (extensions allowed under policy §2) |
| `MECHANIC_CONTRACTS` definitions | v4.2 | FROZEN (extensions allowed under policy §2) |
| Feature Graph Snapshot schema | feature-graph-v1 | FROZEN |

---

## 3. Regression Guard Protocol

Every content batch (Phase 9 execution) must pass:
1. `observation_content_validator.py` — schema + redundancy + placeholder gates
2. `FeatureGraphCompiler.compile_batch()` — produces a batch snapshot
3. Coverage report reviewed — any mechanic below 50% coverage in a world flagged for authoring attention
4. Snapshot archived — if a future change breaks compatibility, the diff points to the exact feature

---

## 4. Pivot Declaration

The observation subsystem is **feature-complete**. Engineering effort now moves to content production (Phase 9 execution). The compiler supports content creation; it no longer competes with it.

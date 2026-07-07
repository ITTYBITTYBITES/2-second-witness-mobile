# Phase 2.1 Validation Report

## Input
- 61 worlds
- 22,059 observations
- 7 universes
- 4 characters
- Export manifest: `2026-07-06T19:17:21.193652Z`
- Export hash (build_state): `sha256:fcea97ba788fd2b6f57ba3a2fbb7ef276fa326850d6050f46707273e7c74d1da`

## Ranking
**PASS**
- Generated: `/shared/evolution/ranking.json`
- Schema: `1.0.0`
- Model: `ranking-v1`
- Weights:
  - observation_density: 0.40
  - entity_diversity: 0.25
  - recency_bonus: 0.20
  - network_overlap: 0.15
- Worlds ranked: 61
- Top 5: animation (0.756757), architecture (0.756757), art_history (0.756757), calligraphy_lettering (0.756757), comics_manga (0.756757)
- SHA256: `fc9a1cf6d02813bfbf71da1176eb56afca03348f4368e75c6222f5caa0ac46d6`

## Lifecycle
**PASS**
- Generated: `/shared/evolution/lifecycle.json`
- Schema: `1.0.0`
- Model: `lifecycle-v1`
- Active: 20
- Cooling: 20
- Archived: 21
- Active cap enforced: YES
- Cooling threshold: 30 days
- SHA256: `b4f3806beb6d78172662dd35b4128f12c2c6cbac252d41b7fe75e4269ba56ff0`

## Placement
**PASS**
- Generated: `/shared/evolution/placement.json`
- Schema: `1.0.0`
- Model: `placement-v1`
- App: 20
- Website: 20
- Archive: 21
- Rank vs placement separation verified: YES
- SHA256: `3f8594228dea7d6787ec9c43ac1291dea968324fec5efafa52cd17a60dec70fa`

## Determinism
**PASS**
- Run 001 hash (ranking): fc9a1cf6d02813bfbf71da1176eb56afca03348f4368e75c6222f5caa0ac46d6
- Run 002 hash (ranking): fc9a1cf6d02813bfbf71da1176eb56afca03348f4368e75c6222f5caa0ac46d6
- Run 001 hash (lifecycle): b4f3806beb6d78172662dd35b4128f12c2c6cbac252d41b7fe75e4269ba56ff0
- Run 002 hash (lifecycle): b4f3806beb6d78172662dd35b4128f12c2c6cbac252d41b7fe75e4269ba56ff0
- Run 001 hash (placement): 3f8594228dea7d6787ec9c43ac1291dea968324fec5efafa52cd17a60dec70fa
- Run 002 hash (placement): 3f8594228dea7d6787ec9c43ac1291dea968324fec5efafa52cd17a60dec70fa
- Byte-identical outputs: YES
- Deterministic sort (score desc, world_id asc): YES

## Side Effects
- Export changed: **NO**
- Contracts changed: **NO**
- Pipeline changed: **NO**
- App behavior changed: **NO**
- Website changed: **NO**

## Artifacts
- `app/tools/evolution/evolution_ranker.py` – 6.9 KB
- `app/tools/evolution/evolution_lifecycle.py` – 3.7 KB
- `app/tools/evolution/evolution_placement.py` – 3.9 KB
- `/shared/evolution/ranking.json` – 30 KB
- `/shared/evolution/lifecycle.json` – 24 KB
- `/shared/evolution/placement.json` – 15 KB

## Status
**PHASE 2.1 COMPLETE**

**STOP**

Evolution Intelligence Foundation is proven. The system can evaluate itself without side effects. Ranking, lifecycle, and placement are deterministic, versioned, and isolated from the export pipeline.

Next: Review outputs, then proceed to Phase 2.2 (Website awareness) only after explicit approval.

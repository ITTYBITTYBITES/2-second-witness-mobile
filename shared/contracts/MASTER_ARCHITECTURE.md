# Master Architecture

## Data Flow (Directed Acyclic Graph)

```
[ APP REPO ]
    │
    ▼
[ EXPORT PIPELINE ]  ← frozen (pipeline.yml)
    │
    ▼
[ /shared/ CANONICAL DATASET ]
    │
    ├── export/          ← immutable after export
    ├── contracts/       ← versioned, append-only freeze
    ├── evolution/       ← NEW — mutable intelligence layer
    │
    ▼
[ EVOLUTION LAYER ]  ← Phase 2 (adaptive)
    │
    ├── evolution_ranker.py
    ├── evolution_lifecycle.py
    ├── evolution_placement.py
    │
    ▼
[ WEBSITE GENERATION ]  ← presentation only
    │
    ▼
[ GITHUB PAGES ]  ← live projection
```

## Repository Roles

| Repo | Role | Writes From |
|------|------|-------------|
| 2-second-witness-mobile | Source of truth / engine | CI pipeline |
| ITTYBITTYBITES.github.io | Public projection layer | CI pipeline (via PAT) |

## Layer Boundaries

| Layer | Status | Content |
|-------|--------|---------|
| Deterministic Engine | ❌ Frozen | export + CI + schemas |
| Semantic Memory | 🟢 Accumulates | worlds, universes, observations |
| Adaptive Cortex | 🆕 Phase 2.1 | ranking, lifecycle, placement |
| Presentation | 🟢 Regenerates | website HTML pages |

## Key Constraints
- Export never reads evolution data
- Evolution never modifies export data
- Website is a pure renderer of shared state
- Every build produces auditable build_state.json

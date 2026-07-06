# Project Constitution

## Identity
This is the **Chronicle System** — a deterministic universe compiler with a live public projection surface.
Owner: ITTYBITTYBITES

## Core Principle
The pipeline never changes to generate growth. Growth only happens through data expansion.

## Frozen Layers (v1.0-stable)
These may NOT be modified without a version bump:
- `pipeline.yml` — CI structure
- `chronicle_export_v1.py` — export engine
- `generate_build_state.py` — build state tracking
- `build_website.py` — website generation
- `_ci_guardrail.yml` — workflow count enforcement
- All schemas under `/shared/contracts/`

## Mutable Layers
These MAY evolve:
- `/shared/evolution/` — ranking, lifecycle, placement
- `/shared/worlds.json` — content expansion
- `/shared/universes.json` — universe expansion
- Website presentation logic (read-only from shared)

## Three-Layer Separation
1. Deterministic Engine — frozen
2. Semantic Memory — accumulated truth
3. Adaptive Cortex — evolution intelligence

## Guardrails
- Max 2 workflow files per repo
- No `git push` or `git commit` in workflow YAML
- No `godot --headless` or `universe_compiler` in workflow YAML
- Export never imports evolution layer
- Evolution layer never modifies export data

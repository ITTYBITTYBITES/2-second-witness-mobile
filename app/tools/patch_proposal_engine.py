#!/usr/bin/env python3
"""LAYER 2 — PATCH PROPOSAL ENGINE (NO EXECUTION)

Input: Audit findings (direct filesystem inspection against registry)
Purpose: Design minimal corrective actions to restore compliance.

HARD CONSTRAINTS:
- NEVER executes changes, modifies filesystem, or modifies registry.
- ONLY produces a structured PATCH PLAN.
"""
import json
import sys
from pathlib import Path
from datetime import datetime, timezone

PROJECT_ROOT = Path(__file__).resolve().parents[2]
APP_DIR = PROJECT_ROOT / "app"
REGISTRY_PATH = APP_DIR / "MASTER_UNIVERSE_REGISTRY.json"
BANK_ROOT = APP_DIR / "data" / "observation_banks"
BUNDLE_ROOT = APP_DIR / "data" / "content" / "base_bundle"
PLAN_OUTPUT = APP_DIR / "logs" / "patch_plan.json"

def load_registry():
    return json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))

def get_fs_worlds(universe_id):
    worlds = set()
    bundle_dir = BUNDLE_ROOT / universe_id
    if bundle_dir.exists():
        worlds.update(d.name for d in bundle_dir.iterdir() if d.is_dir())
    return worlds

def propose():
    registry = load_registry()
    batches = []
    batch_id = 0

    for universe_id, spec in sorted(registry["universes"].items()):
        spec_worlds = set(spec.get("world_order", []))
        fs_worlds = get_fs_worlds(universe_id)
        orphan_worlds = sorted(fs_worlds - spec_worlds)

        if not orphan_worlds:
            continue

        batch_id += 1
        affected = []
        for world_id in orphan_worlds:
            world_dir = BUNDLE_ROOT / universe_id / world_id
            affected.append(str(world_dir.relative_to(PROJECT_ROOT)))

        batches.append({
            "batch_id": batch_id,
            "operation_type": "delete",
            "affected_files": affected,
            "description": f"Remove {len(orphan_worlds)} orphan world directorie(s) from base_bundle/{universe_id} that are not listed in MASTER_UNIVERSE_REGISTRY.json world_order.",
            "risk_level": "HIGH",
            "reason": "world_drift: base_bundle contains worlds not present in canonical spec"
        })

    plan = {
        "schema_version": 1,
        "generated_at": datetime.now(datetime.now().astimezone().tzinfo).strftime("%Y-%m-%dT%H:%M:%S%z"),
        "canonical_source": str(REGISTRY_PATH.relative_to(PROJECT_ROOT)),
        "batches": batches,
        "dependencies": [
            "MASTER_UNIVERSE_REGISTRY.json must remain unchanged during execution",
            "Patch Executor must validate each deletion against registry before execution"
        ],
        "impact_summary": {
            "total_batches": len(batches),
            "total_operations": sum(len(b["affected_files"]) for b in batches),
            "risk_levels": [b["risk_level"] for b in batches]
        }
    }

    PLAN_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    PLAN_OUTPUT.write_text(json.dumps(plan, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print("=" * 70)
    print("PATCH PLAN")
    print("=" * 70)
    print(json.dumps(plan, indent=2))
    print("\n" + "=" * 70)
    print(f"Plan written to: {PLAN_OUTPUT.relative_to(PROJECT_ROOT)}")
    print("ACTION: Submit plan to Patch Executor for review and execution.")
    print("=" * 70)

if __name__ == "__main__":
    propose()

#!/usr/bin/env python3
"""LAYER 3 — PATCH EXECUTOR (CONTROLLED MUTATION ENGINE)

Input: app/logs/patch_plan.json
Purpose: Execute approved patch operations exactly as specified.

HARD CONSTRAINTS:
- ONLY layer allowed to modify filesystem.
- Must validate plan against MASTER_UNIVERSE_REGISTRY.json before execution.
- Must maintain rollback log: app/logs/patch_rollback.json
- Must NOT generate new plans or perform additional fixes.
"""
import json
import shutil
import sys
from pathlib import Path
from datetime import datetime, timezone

PROJECT_ROOT = Path(__file__).resolve().parents[2]
APP_DIR = PROJECT_ROOT / "app"
REGISTRY_PATH = APP_DIR / "MASTER_UNIVERSE_REGISTRY.json"
PLAN_PATH = APP_DIR / "logs" / "patch_plan.json"
ROLLBACK_LOG = APP_DIR / "logs" / "patch_rollback.json"
ROLLBACK_DIR = APP_DIR / "logs" / "rollback"

def load_registry():
    return json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))

def load_plan():
    if not PLAN_PATH.exists():
        print("FATAL: patch_plan.json not found")
        sys.exit(1)
    return json.loads(PLAN_PATH.read_text(encoding="utf-8"))

def validate_plan(plan, registry):
    """Ensure every delete target is an orphan world per registry."""
    errors = []
    canonical_worlds = {
        uid: set(spec.get("world_order", []))
        for uid, spec in registry["universes"].items()
    }

    for batch in plan.get("batches", []):
        if batch.get("operation_type") != "delete":
            errors.append(f"Unsupported operation: {batch.get('operation_type')}")
            continue
        for rel_path in batch.get("affected_files", []):
            p = PROJECT_ROOT / rel_path
            parts = p.relative_to(APP_DIR / "data" / "content" / "base_bundle").parts
            if len(parts) != 2:
                errors.append(f"Invalid path depth: {rel_path}")
                continue
            universe_id, world_id = parts
            if universe_id not in canonical_worlds:
                errors.append(f"Unknown universe in path: {rel_path}")
                continue
            if world_id in canonical_worlds[universe_id]:
                errors.append(f"REFUSAL: cannot delete canonical world {rel_path}")
            if not p.exists():
                errors.append(f"Path does not exist: {rel_path}")

    return errors

def execute():
    registry = load_registry()
    plan = load_plan()

    print("=" * 70)
    print("PATCH EXECUTOR")
    print("=" * 70)

    # Validate
    errors = validate_plan(plan, registry)
    if errors:
        print("\nVALIDATION FAILED:")
        for e in errors:
            print(f"  - {e}")
        print("\nEXECUTION ABORTED")
        return 1

    print("\nPlan validated against registry. Proceeding with execution...")

    ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    rollback = {
        "schema_version": 1,
        "executed_at": ts,
        "patch_plan": str(PLAN_PATH.relative_to(PROJECT_ROOT)),
        "operations": []
    }

    total_deleted = 0
    for batch in plan.get("batches", []):
        print(f"\nBatch {batch['batch_id']}: {batch['operation_type']} ({batch['risk_level']} risk)")
        print(f"  {batch['description']}")
        for rel_path in batch.get("affected_files", []):
            source = PROJECT_ROOT / rel_path
            if not source.exists():
                print(f"  SKIP (missing): {rel_path}")
                continue

            # Backup to rollback storage
            backup = ROLLBACK_DIR / rel_path
            if backup.exists():
                shutil.rmtree(backup)
            backup.parent.mkdir(parents=True, exist_ok=True)
            shutil.copytree(source, backup)

            # Delete source
            shutil.rmtree(source)
            total_deleted += 1

            rollback["operations"].append({
                "operation_type": "delete",
                "source": rel_path,
                "backup": str(backup.relative_to(PROJECT_ROOT)),
                "batch_id": batch["batch_id"]
            })
            print(f"  DELETED: {rel_path} -> backup: {backup.relative_to(PROJECT_ROOT)}")

    # Write rollback log
    ROLLBACK_LOG.parent.mkdir(parents=True, exist_ok=True)
    ROLLBACK_LOG.write_text(json.dumps(rollback, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print("\n" + "=" * 70)
    print(f"EXECUTION COMPLETE: {total_deleted} operations performed")
    print(f"Rollback log: {ROLLBACK_LOG.relative_to(PROJECT_ROOT)}")
    print("=" * 70)
    return 0

if __name__ == "__main__":
    sys.exit(execute())

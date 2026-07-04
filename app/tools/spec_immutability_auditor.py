#!/usr/bin/env python3
"""LAYER 1 — SPEC IMMUTABILITY AUDITOR (READ ONLY)

Reads MASTER_UNIVERSE_REGISTRY.json as the immutable canonical spec and audits
filesystem reality against it with zero tolerance for drift.

HARD CONSTRAINTS:
- Strictly read-only.
- NEVER creates, deletes, moves, quarantines, or modifies files/registry.
- ONLY reports findings.
"""
import json
import sys
from pathlib import Path
from collections import defaultdict

PROJECT_ROOT = Path(__file__).resolve().parents[2]
APP_DIR = PROJECT_ROOT / "app"
REGISTRY_PATH = APP_DIR / "MASTER_UNIVERSE_REGISTRY.json"
BANK_ROOT = APP_DIR / "data" / "observation_banks"
BUNDLE_ROOT = APP_DIR / "data" / "content" / "base_bundle"
UNIVERSES_DIR = APP_DIR / "universes"

EXIT_CLEAN = 0
EXIT_DIRTY = 1

def load_registry():
    if not REGISTRY_PATH.exists():
        print("FATAL: MASTER_UNIVERSE_REGISTRY.json missing")
        sys.exit(EXIT_DIRTY)
    data = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or "universes" not in data:
        print("FATAL: MASTER_UNIVERSE_REGISTRY.json invalid structure")
        sys.exit(EXIT_DIRTY)
    return data

def scan_filesystem_universes():
    found = set()
    for root in [BANK_ROOT, BUNDLE_ROOT, UNIVERSES_DIR]:
        if root.exists():
            for d in root.iterdir():
                if d.is_dir() and not d.name.startswith("."):
                    found.add(d.name)
    return found

def get_fs_worlds(universe_id):
    worlds = set()
    worlds_dir = BANK_ROOT / universe_id / "worlds"
    if worlds_dir.exists():
        worlds.update(d.name for d in worlds_dir.iterdir() if d.is_dir())
    bundle_dir = BUNDLE_ROOT / universe_id
    if bundle_dir.exists():
        worlds.update(d.name for d in bundle_dir.iterdir() if d.is_dir())
    return worlds

def get_fs_subcategory_files(universe_id, world_id):
    subcats_dir = BANK_ROOT / universe_id / "worlds" / world_id / "subcategories"
    if not subcats_dir.exists():
        return set()
    return {f.stem for f in subcats_dir.glob("*.json")}

def get_fs_compiled_bank_count(universe_id, world_id):
    bank_file = BUNDLE_ROOT / universe_id / world_id / f"{world_id}_observation_bank_compiled.json"
    if not bank_file.exists():
        return None
    try:
        data = json.loads(bank_file.read_text(encoding="utf-8"))
        return len(data) if isinstance(data, list) else 0
    except Exception:
        return -1

def audit():
    registry = load_registry()
    canonical = set(registry["universes"].keys())
    fs = scan_filesystem_universes()

    orphans = sorted(fs - canonical)
    missing = sorted(canonical - fs)
    audited = canonical & fs

    world_drift = []
    schema_drift = []

    for uid in sorted(audited):
        spec = registry["universes"][uid]
        spec_worlds = set(spec.get("world_order", []))
        fs_worlds = get_fs_worlds(uid)

        if spec_worlds != fs_worlds:
            world_drift.append({
                "universe": uid,
                "spec_worlds": sorted(spec_worlds),
                "fs_worlds": sorted(fs_worlds),
                "only_in_spec": sorted(spec_worlds - fs_worlds),
                "only_in_fs": sorted(fs_worlds - spec_worlds)
            })
            continue  # further checks meaningless while worlds drift

        status = spec.get("status", "unknown")

        if status in ("complete", "scaffolded"):
            for world_id in spec.get("world_order", []):
                bank_count = get_fs_compiled_bank_count(uid, world_id)
                if status == "complete":
                    if bank_count is None:
                        schema_drift.append(f"{uid}/{world_id}: compiled_bank_missing")
                    elif bank_count == 0:
                        schema_drift.append(f"{uid}/{world_id}: compiled_bank_empty")
                    elif bank_count < 0:
                        schema_drift.append(f"{uid}/{world_id}: compiled_bank_unparseable")

                    wm_path = BANK_ROOT / uid / "worlds" / world_id / "world_manifest.json"
                    if wm_path.exists():
                        wm = json.loads(wm_path.read_text())
                        manifest_subcats = {s["id"] for s in wm.get("subcategories", [])}
                        fs_subcats = get_fs_subcategory_files(uid, world_id)
                        if manifest_subcats != fs_subcats:
                            schema_drift.append(f"{uid}/{world_id}: subcategory_manifest_mismatch")
                else:  # scaffolded
                    if bank_count is None:
                        schema_drift.append(f"{uid}/{world_id}: placeholder_missing")

        if not (BANK_ROOT / uid / "universe_manifest.json").exists():
            schema_drift.append(f"{uid}: universe_manifest_missing")

        # observation count match for complete universes
        if status == "complete":
            total_obs = 0
            for world_id in spec.get("world_order", []):
                cnt = get_fs_compiled_bank_count(uid, world_id)
                if cnt and cnt > 0:
                    total_obs += cnt
            if total_obs != spec.get("observation_count", 0):
                schema_drift.append(f"{uid}: observation_count_drift registry={spec.get('observation_count')} fs={total_obs}")

    # Output in mandated Layer 1 format
    print("=" * 70)
    print("DRIFT REPORT")
    print("=" * 70)

    print("\norphan universes:")
    if orphans:
        for uid in orphans:
            locations = []
            if (BANK_ROOT / uid).exists(): locations.append("observation_banks")
            if (BUNDLE_ROOT / uid).exists(): locations.append("base_bundle")
            if (UNIVERSES_DIR / uid).exists(): locations.append("universes")
            print(f"  - {uid} ({', '.join(locations)})")
    else:
        print("  none")

    print("\nmissing universes:")
    if missing:
        for uid in missing:
            print(f"  - {uid}")
    else:
        print("  none")

    print("\nworld drift:")
    if world_drift:
        for item in world_drift:
            print(f"  - {item['universe']}:")
            if item["only_in_fs"]:
                print(f"      orphan worlds: {item['only_in_fs']}")
            if item["only_in_spec"]:
                print(f"      missing worlds: {item['only_in_spec']}")
    else:
        print("  none")

    print("\nschema drift:")
    if schema_drift:
        for item in schema_drift:
            print(f"  - {item}")
    else:
        print("  none")

    dirty = bool(orphans or missing or world_drift or schema_drift)
    print("\n" + "=" * 70)
    print(f"SYSTEM STATE: {'DIRTY' if dirty else 'CLEAN'}")
    print(f"ACTION REQUIRED: {'PATCH PROPOSAL REQUIRED' if dirty else 'NONE'}")
    print("=" * 70)

    return EXIT_DIRTY if dirty else EXIT_CLEAN

if __name__ == "__main__":
    sys.exit(audit())

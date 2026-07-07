#!/usr/bin/env python3
"""Compile source observation banks into runtime ContentLoader-compatible bundles.
V3.0 Standard: Aggregates Canonical Knowledge Objects without expansion.

Source hierarchy:
  app/data/observation_banks/<universe>/worlds/<world>/subcategories/<subcategory>.json

Runtime output:
  app/data/content/base_bundle/<universe>/<world>/<world>_observation_bank_compiled.json
"""
import argparse
import json
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
APP_DIR = PROJECT_ROOT / "app"
SOURCE_ROOT = APP_DIR / "data" / "observation_banks"
RUNTIME_ROOT = APP_DIR / "data" / "content" / "base_bundle"

def compile_universe(universe_id: str, world_filter: str = "") -> dict:
    universe_root = SOURCE_ROOT / universe_id / "worlds"
    if not universe_root.exists():
        raise FileNotFoundError(f"Observation bank universe not found: {universe_root}")

    compiled_by_world: dict[str, list[dict]] = {}
    total_items = 0
    
    for world_dir in sorted(p for p in universe_root.iterdir() if p.is_dir()):
        world_id = world_dir.name
        if world_filter and world_filter != world_id:
            continue
            
        subcat_dir = world_dir / "subcategories"
        if not subcat_dir.exists():
            continue
            
        world_items = []
        for bank_path in sorted(subcat_dir.glob("*.json")):
            try:
                data = json.loads(bank_path.read_text(encoding="utf-8"))
                
                # V3 Standard: Data is a list of CKOs
                if isinstance(data, list):
                    for item in data:
                        # Force synchronization with current compilation context
                        item["universe"] = universe_id
                        item["world"] = world_id
                        if "subcategory" not in item:
                            item["subcategory"] = bank_path.stem
                        world_items.append(item)
                        total_items += 1
                
                # Legacy Support: Data is a dict with 'observations' key
                elif isinstance(data, dict) and "observations" in data:
                    scenario_type = data.get("scenario_preferences", {}).get("preferred", ["rapid_classification"])[0]
                    for obs in data["observations"]:
                        # Convert to minimal CKO if not already
                        item = obs.copy()
                        item["universe"] = universe_id
                        item["world"] = world_id
                        item["subcategory"] = data.get("subcategory", bank_path.stem)
                        world_items.append(item)
                        total_items += 1
            except Exception as e:
                print(f"[ERROR] Failed to compile {bank_path}: {e}")

        if world_items:
            compiled_by_world[world_id] = world_items

    written = []
    for world_id, items in compiled_by_world.items():
        out_dir = RUNTIME_ROOT / universe_id / world_id
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"{world_id}_observation_bank_compiled.json"
        out_path.write_text(json.dumps(items, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        written.append(str(out_path.relative_to(PROJECT_ROOT)))

    return {
        "universe": universe_id, 
        "total_items": total_items, 
        "worlds_compiled": len(written), 
        "files": written
    }

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("universe", help="Universe ID, e.g. creative_arts")
    parser.add_argument("--world", default="", help="Optional world ID filter")
    args = parser.parse_args()
    result = compile_universe(args.universe, args.world)
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()

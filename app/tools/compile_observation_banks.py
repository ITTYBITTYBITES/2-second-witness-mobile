#!/usr/bin/env python3
"""Compile source observation banks into runtime ContentLoader-compatible bundles.

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


def _primary_scenario(bank: dict) -> str:
    preferred = bank.get("scenario_preferences", {}).get("preferred", [])
    return preferred[0] if preferred else "rapid_classification"


def compile_universe(universe_id: str, world_filter: str = "") -> dict:
    universe_root = SOURCE_ROOT / universe_id / "worlds"
    if not universe_root.exists():
        raise FileNotFoundError(f"Observation bank universe not found: {universe_root}")

    compiled_by_world: dict[str, list[dict]] = {}
    source_observations = 0
    for world_dir in sorted(p for p in universe_root.iterdir() if p.is_dir()):
        world_id = world_dir.name
        if world_filter and world_filter != world_id:
            continue
        subcat_dir = world_dir / "subcategories"
        if not subcat_dir.exists():
            continue
        for bank_path in sorted(subcat_dir.glob("*.json")):
            bank = json.loads(bank_path.read_text(encoding="utf-8"))
            scenario_type = _primary_scenario(bank)
            subcategory = bank.get("subcategory", bank_path.stem)
            for obs in bank.get("observations", []):
                source_observations += 1
                obs_id = obs["observation_id"]
                item = {
                    "id": f"{obs_id}_{scenario_type}",
                    "observation_id": obs_id,
                    "universe": universe_id,
                    "world": world_id,
                    "subcategory": subcategory,
                    "type": scenario_type,
                    "rules": {
                        "prompt": obs["prompt"],
                        "legacy_prompt": obs["prompt"],
                        "correct_answer": obs["correct_answer"],
                        "wrong_answers": obs["distractors"],
                    },
                    "presentation": {
                        "title": f"{world_id.replace('_', ' ').title()} — {bank.get('display_name', subcategory)}",
                        "difficulty_tier": obs.get("difficulty", {}).get("tier", 1),
                        "subcategory": subcategory,
                        "observation_type": obs.get("observation_type", "Rapid Classification"),
                    },
                    "metadata": obs.get("metadata", {}),
                }
                compiled_by_world.setdefault(world_id, []).append(item)

    written = []
    for world_id, items in compiled_by_world.items():
        out_dir = RUNTIME_ROOT / universe_id / world_id
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"{world_id}_observation_bank_compiled.json"
        out_path.write_text(json.dumps(items, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        written.append(str(out_path.relative_to(PROJECT_ROOT)))

    return {"universe": universe_id, "source_observations": source_observations, "worlds_compiled": len(written), "files": written}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("universe", help="Universe ID, e.g. creative_arts")
    parser.add_argument("--world", default="", help="Optional world ID filter")
    args = parser.parse_args()
    result = compile_universe(args.universe, args.world)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()

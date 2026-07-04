#!/usr/bin/env python3
"""Validate source observation-bank hierarchy and metadata."""
import json
import sys
from pathlib import Path
from collections import Counter

PROJECT_ROOT = Path(__file__).resolve().parents[2]
BANK_ROOT = PROJECT_ROOT / "app" / "data" / "observation_banks"
REQUIRED_OBS = {"observation_id", "universe", "world", "subcategory", "difficulty", "observation_type", "prompt", "correct_answer", "distractors", "localization", "metadata"}
REQUIRED_PREF = {"preferred", "secondary", "rare", "disabled"}


def validate() -> int:
    errors: list[str] = []
    obs_ids: set[str] = set()
    prompts: set[str] = set()
    world_count = 0
    subcat_count = 0
    obs_count = 0
    by_world = Counter()

    for world_manifest_path in BANK_ROOT.glob("*/worlds/*/world_manifest.json"):
        world_count += 1
        manifest = json.loads(world_manifest_path.read_text(encoding="utf-8"))
        for key in ["universe", "world", "subcategories"]:
            if key not in manifest:
                errors.append(f"{world_manifest_path}: missing {key}")
        for sub in manifest.get("subcategories", []):
            subcat_count += 1
            if "id" not in sub or "scenario_preferences" not in sub:
                errors.append(f"{world_manifest_path}: subcategory missing id/scenario_preferences")
            pref = sub.get("scenario_preferences", {})
            if not REQUIRED_PREF.issubset(pref.keys()):
                errors.append(f"{world_manifest_path}: subcategory {sub.get('id')} has incomplete scenario preferences")

    for bank_path in BANK_ROOT.glob("*/worlds/*/subcategories/*.json"):
        bank = json.loads(bank_path.read_text(encoding="utf-8"))
        pref = bank.get("scenario_preferences", {})
        if not REQUIRED_PREF.issubset(pref.keys()):
            errors.append(f"{bank_path}: incomplete scenario_preferences")
        for obs in bank.get("observations", []):
            obs_count += 1
            missing = REQUIRED_OBS - obs.keys()
            if missing:
                errors.append(f"{bank_path}: observation missing {sorted(missing)}")
            oid = obs.get("observation_id", "")
            if oid in obs_ids:
                errors.append(f"{bank_path}: duplicate observation_id {oid}")
            obs_ids.add(oid)
            prompt_key = f"{obs.get('world')}:{obs.get('subcategory')}:{obs.get('prompt')}"
            if prompt_key in prompts:
                errors.append(f"{bank_path}: duplicate prompt {obs.get('prompt')}")
            prompts.add(prompt_key)
            by_world[obs.get("world", "unknown")] += 1
            if not isinstance(obs.get("distractors"), list) or len(obs.get("distractors", [])) < 2:
                errors.append(f"{bank_path}: observation {oid} needs at least two distractors")

    print("--- OBSERVATION BANK VALIDATION ---")
    print(f"World manifests: {world_count}")
    print(f"Subcategories:   {subcat_count}")
    print(f"Observations:    {obs_count}")
    print(f"By world:        {dict(by_world)}")
    if errors:
        print("\nFAILURES:")
        for err in errors[:200]:
            print(" -", err)
        return 1
    print("PASS: observation-bank hierarchy and metadata are valid.")
    return 0


if __name__ == "__main__":
    sys.exit(validate())

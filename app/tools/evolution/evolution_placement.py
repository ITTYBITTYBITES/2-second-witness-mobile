#!/usr/bin/env python3
"""
Evolution Placement v1
Phase 2.1 – Evolution Intelligence Foundation

Separates ranking (popularity) from placement (presentation location).
Ranking decides popularity. Placement decides location. Never combine.

Placement targets:
  app     – active worlds, in-app experience
  website – active + cooling worlds, public projection
  archive – archived worlds, historical record, resurrectable
"""
import json
import os
from pathlib import Path
from datetime import datetime, timezone

_GW = os.environ.get("GITHUB_WORKSPACE")
if _GW:
    SHARED_DIR = Path(_GW) / "shared"
else:
    for cand in [Path("/home/user/workspace/shared"), Path(__file__).resolve().parents[5] / "shared", Path(__file__).resolve().parents[4] / "shared"]:
        if (cand / "evolution" / "lifecycle.json").exists():
            SHARED_DIR = cand
            break
    else:
        SHARED_DIR = Path("/home/user/workspace/shared")

RANKING_PATH = SHARED_DIR / "evolution" / "ranking.json"
LIFECYCLE_PATH = SHARED_DIR / "evolution" / "lifecycle.json"
OUTPUT_DIR = SHARED_DIR / "evolution"
OUTPUT_PATH = OUTPUT_DIR / "placement.json"

MODEL_VERSION = "placement-v1"
SCHEMA_VERSION = "1.0.0"

def placement_for_state(state: str) -> str:
    if state == "active":
        return "app"
    elif state == "cooling":
        return "website"
    else:  # archived
        return "archive"

def get_generated_at():
    env_ts = os.environ.get("EVO_TIMESTAMP")
    if env_ts:
        return env_ts
    manifest_path = SHARED_DIR / "export" / "manifest.json"
    try:
        with open(manifest_path) as f:
            m = json.load(f)
            ts = m.get("timestamp")
            if ts:
                if ts.endswith("Z"):
                    ts = ts[:-1] + "+00:00"
                return ts
    except Exception:
        pass
    return datetime.now(timezone.utc).isoformat()

def main():
    with open(RANKING_PATH, "r", encoding="utf-8") as f:
        ranking = json.load(f)
    with open(LIFECYCLE_PATH, "r", encoding="utf-8") as f:
        lifecycle = json.load(f)

    lifecycle_map = {w["world_id"]: w for w in lifecycle["worlds"]}

    now_iso = get_generated_at()

    placements = []
    counts = {"app": 0, "website": 0, "archive": 0}

    for r in ranking["worlds"]:
        world_id = r["world_id"]
        lc = lifecycle_map.get(world_id, {})
        state = lc.get("state", "archived")
        target = placement_for_state(state)
        counts[target] += 1

        placements.append({
            "world_id": world_id,
            "universe_id": r["universe_id"],
            "placement_target": target,
            "lifecycle_state": state,
            "rank": r["rank"],
            "score": r["score"],
            "priority": r["rank"],  # lower rank = higher priority
            "slot": None  # reserved for Phase 2.2
        })

    # sort by placement_target then rank for stable output
    target_order = {"app": 0, "website": 1, "archive": 2}
    placements.sort(key=lambda x: (target_order.get(x["placement_target"], 9), x["rank"]))

    output = {
        "schema_version": SCHEMA_VERSION,
        "model_version": MODEL_VERSION,
        "generated_at": now_iso,
        "inputs": {
            "ranking_model": ranking.get("model_version"),
            "ranking_generated_at": ranking.get("generated_at"),
            "lifecycle_model": lifecycle.get("model_version"),
            "lifecycle_generated_at": lifecycle.get("generated_at")
        },
        "rules": {
            "rank_vs_placement_separation": True,
            "mapping": {
                "active": "app",
                "cooling": "website",
                "archived": "archive"
            }
        },
        "counts": counts,
        "placements": placements
    }

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    print(f"Placement complete: app={counts['app']} website={counts['website']} archive={counts['archive']} → {OUTPUT_PATH}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

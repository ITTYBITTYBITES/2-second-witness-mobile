#!/usr/bin/env python3
"""
Evolution Lifecycle v1
Phase 2.1 – Evolution Intelligence Foundation

Assigns lifecycle states based on ranking.
Export NEVER reads evolution. Evolution NEVER modifies export.

States:
  active   – max 20 worlds, top ranked
  cooling  – rank 21-40, eligible for archive after 30 days inactive
  archived – rank 41+, resurrectable

For Phase 2.1, assignment is rank-driven and deterministic.
Future phases will incorporate time-based cooling transitions.
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
        if (cand / "evolution" / "ranking.json").exists() or (cand / "worlds.json").exists():
            SHARED_DIR = cand
            break
    else:
        SHARED_DIR = Path("/home/user/workspace/shared")

RANKING_PATH = SHARED_DIR / "evolution" / "ranking.json"
OUTPUT_DIR = SHARED_DIR / "evolution"
OUTPUT_PATH = OUTPUT_DIR / "lifecycle.json"

MODEL_VERSION = "lifecycle-v1"
SCHEMA_VERSION = "1.0.0"

ACTIVE_CAP = 20
COOLING_DAYS_THRESHOLD = 30

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

    now_iso = get_generated_at()

    worlds_out = []
    counts = {"active": 0, "cooling": 0, "archived": 0}

    for entry in ranking["worlds"]:
        rank = entry["rank"]
        world_id = entry["world_id"]
        raw = entry.get("raw", {})
        days_inactive = raw.get("days_inactive", 0)
        last_activity = raw.get("last_activity")

        # Phase 2.1 deterministic assignment by rank
        if rank <= ACTIVE_CAP:
            state = "active"
        elif rank <= 40:
            state = "cooling"
        else:
            state = "archived"

        # cooling metadata
        cooling_days_remaining = None
        if state == "cooling":
            cooling_days_remaining = max(0, COOLING_DAYS_THRESHOLD - days_inactive)

        resurrectable = state == "archived"

        counts[state] += 1

        worlds_out.append({
            "world_id": world_id,
            "universe_id": entry["universe_id"],
            "state": state,
            "rank": rank,
            "score": entry["score"],
            "last_activity": last_activity,
            "days_inactive": days_inactive,
            "cooling_days_remaining": cooling_days_remaining,
            "resurrectable": resurrectable,
            "state_changed_at": now_iso,
            "previous_state": None
        })

    output = {
        "schema_version": SCHEMA_VERSION,
        "model_version": MODEL_VERSION,
        "generated_at": now_iso,
        "ranking_model": ranking.get("model_version"),
        "ranking_generated_at": ranking.get("generated_at"),
        "rules": {
            "active_cap": ACTIVE_CAP,
            "cooling_days_threshold": COOLING_DAYS_THRESHOLD,
            "assignment": "rank_driven_v1"
        },
        "counts": counts,
        "worlds": worlds_out
    }

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    print(f"Lifecycle complete: active={counts['active']} cooling={counts['cooling']} archived={counts['archived']} → {OUTPUT_PATH}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

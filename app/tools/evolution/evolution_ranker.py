#!/usr/bin/env python3
"""
Evolution Ranker v1
Phase 2.1 – Evolution Intelligence Foundation

Deterministic ranking of worlds based on content signals.
Export NEVER reads evolution. Evolution NEVER modifies export.

Ranking formula (model_version: ranking-v1):
  score = obs_density*0.40 + entity_diversity*0.25 + recency_bonus*0.20 + network_overlap*0.15

Signals are normalized 0..1 across the current corpus.
"""
import json
import os
from pathlib import Path
from datetime import datetime, timezone
from collections import defaultdict

# Path resolution: GITHUB_WORKSPACE in CI, fallback to local layout
_GW = os.environ.get("GITHUB_WORKSPACE")
if _GW:
    SHARED_DIR = Path(_GW) / "shared"
else:
    # try common local roots
    for cand in [Path("/home/user/workspace/shared"), Path(__file__).resolve().parents[5] / "shared", Path(__file__).resolve().parents[4] / "shared"]:
        if (cand / "worlds.json").exists():
            SHARED_DIR = cand
            break
    else:
        SHARED_DIR = Path("/home/user/workspace/shared")

WORLDS_PATH = SHARED_DIR / "worlds.json"
OBS_DIR = SHARED_DIR / "export" / "observations"
OUTPUT_DIR = SHARED_DIR / "evolution"
OUTPUT_PATH = OUTPUT_DIR / "ranking.json"

MODEL_VERSION = "ranking-v1"
SCHEMA_VERSION = "1.0.0"
WEIGHTS = {
    "observation_density": 0.40,
    "entity_diversity": 0.25,
    "recency_bonus": 0.20,
    "network_overlap": 0.15
}
MAX_INACTIVE_DAYS = 365

def load_worlds():
    with open(WORLDS_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data["worlds"]

def load_observations():
    """Aggregate observations per world: entity_types, last_updated
    Supports both legacy per-observation JSON files and modern JSONL per-world files.
    If worlds.json already contains statistics.entity_types_unique / last_activity,
    callers should prefer those (faster, no I/O amplification).
    """
    per_world = defaultdict(list)
    if not OBS_DIR.exists():
        return per_world
    # Legacy: individual observation JSON files
    for p in sorted(OBS_DIR.glob("*.json")):
        try:
            with open(p, "r", encoding="utf-8") as f:
                d = json.load(f)
            obs = d.get("observation", {})
            world_id = obs.get("world")
            if world_id:
                per_world[world_id].append(obs)
        except Exception:
            continue
    # Modern: per-world JSONL files – observations/{universe}.{world}.jsonl
    for p in sorted(OBS_DIR.glob("*.jsonl")):
        try:
            # infer world_id from filename: {universe}.{world}.jsonl
            stem = p.stem  # e.g. "creative_arts.animation"
            world_id = stem.split(".", 1)[-1] if "." in stem else stem
            with open(p, "r", encoding="utf-8") as f:
                for line in f:
                    line=line.strip()
                    if not line:
                        continue
                    d = json.loads(line)
                    obs = d.get("observation", d)  # support raw observation or export envelope
                    # world_id from filename is authoritative if missing in payload
                    if "world" not in obs:
                        obs["world"] = world_id
                    per_world[world_id].append(obs)
        except Exception:
            continue
    return per_world

def parse_ts(ts_str):
    if not ts_str:
        return None
    try:
        # Handle Z suffix
        if ts_str.endswith("Z"):
            ts_str = ts_str[:-1] + "+00:00"
        return datetime.fromisoformat(ts_str)
    except Exception:
        return None

def get_generated_at():
    # Deterministic timestamp: EVO_TIMESTAMP env > export manifest > now
    env_ts = os.environ.get("EVO_TIMESTAMP")
    if env_ts:
        return env_ts
    manifest_path = SHARED_DIR / "export" / "manifest.json"
    try:
        with open(manifest_path) as f:
            m = json.load(f)
            ts = m.get("timestamp")
            if ts:
                # normalize to iso with +00:00
                if ts.endswith("Z"):
                    ts = ts[:-1] + "+00:00"
                return ts
    except Exception:
        pass
    return datetime.now(timezone.utc).isoformat()

def main():
    worlds = load_worlds()
    obs_map = load_observations()

    generated_at = get_generated_at()
    # Use generated_at as the reference time for recency – makes ranking deterministic
    # Parse generated_at (ISO with +00:00) to datetime
    try:
        ts = generated_at
        if ts.endswith("Z"):
            ts = ts[:-1] + "+00:00"
        now = datetime.fromisoformat(ts)
        if now.tzinfo is None:
            now = now.replace(tzinfo=timezone.utc)
    except Exception:
        now = datetime.now(timezone.utc)

    # First pass: collect raw signals
    raws = []
    for w in worlds:
        world_id = w["id"]
        universe_id = w.get("universe_id", "")
        stats = w.get("statistics", {})
        obs_count = stats.get("observation_count", 0)
        overlap_regions = w.get("embodiment", {}).get("overlap_regions", [])
        network_overlap_raw = len(overlap_regions)

        # Prefer pre-aggregated statistics from worlds.json (export v1.1+)
        # Fall back to scanning observation files for backward compat
        entity_diversity_raw = stats.get("entity_types_unique")
        last_activity_str = stats.get("last_activity")
        last_updated = parse_ts(last_activity_str) if last_activity_str else None

        if entity_diversity_raw is None or last_updated is None:
            # Fallback: aggregate from observation files
            observations = obs_map.get(world_id, [])
            entity_types = set()
            if last_updated is None:
                for o in observations:
                    et = o.get("entity_type")
                    if et:
                        entity_types.add(et)
                    ts = parse_ts(o.get("updated_at") or o.get("created_at"))
                    if ts and (last_updated is None or ts > last_updated):
                        last_updated = ts
                if entity_diversity_raw is None:
                    entity_diversity_raw = len(entity_types)
            else:
                # we have last_activity from stats, still need entity diversity
                for o in observations:
                    et = o.get("entity_type")
                    if et:
                        entity_types.add(et)
                entity_diversity_raw = len(entity_types)

        if entity_diversity_raw is None:
            entity_diversity_raw = 0

        if last_updated:
            days_inactive = (now - last_updated).days
            if days_inactive < 0:
                days_inactive = 0
        else:
            days_inactive = MAX_INACTIVE_DAYS

        recency_bonus_raw = 1.0 - (min(days_inactive, MAX_INACTIVE_DAYS) / MAX_INACTIVE_DAYS)

        raws.append({
            "world_id": world_id,
            "universe_id": universe_id,
            "observation_count": obs_count,
            "entity_diversity_raw": entity_diversity_raw,
            "network_overlap_raw": network_overlap_raw,
            "days_inactive": days_inactive,
            "recency_bonus_raw": recency_bonus_raw,
            "last_activity": last_updated.isoformat() if last_updated else None,
        })

    # Normalization bases
    max_obs = max((r["observation_count"] for r in raws), default=1)
    max_entity = max((r["entity_diversity_raw"] for r in raws), default=1)
    max_network = max((r["network_overlap_raw"] for r in raws), default=1)
    if max_obs == 0: max_obs = 1
    if max_entity == 0: max_entity = 1
    if max_network == 0: max_network = 1

    # Second pass: compute normalized signals and score
    ranked = []
    for r in raws:
        obs_density = r["observation_count"] / max_obs
        entity_diversity = r["entity_diversity_raw"] / max_entity
        network_overlap = r["network_overlap_raw"] / max_network
        recency_bonus = r["recency_bonus_raw"]

        score = (
            obs_density * WEIGHTS["observation_density"] +
            entity_diversity * WEIGHTS["entity_diversity"] +
            recency_bonus * WEIGHTS["recency_bonus"] +
            network_overlap * WEIGHTS["network_overlap"]
        )

        ranked.append({
            "world_id": r["world_id"],
            "universe_id": r["universe_id"],
            "rank": 0,  # placeholder
            "score": round(score, 6),
            "signals": {
                "observation_density": round(obs_density, 6),
                "entity_diversity": round(entity_diversity, 6),
                "recency_bonus": round(recency_bonus, 6),
                "network_overlap": round(network_overlap, 6)
            },
            "raw": {
                "observation_count": r["observation_count"],
                "entity_types_unique": r["entity_diversity_raw"],
                "overlap_regions": r["network_overlap_raw"],
                "days_inactive": r["days_inactive"],
                "last_activity": r["last_activity"]
            }
        })

    # Deterministic sort: score desc, then world_id asc
    ranked.sort(key=lambda x: (-x["score"], x["world_id"]))
    for i, entry in enumerate(ranked, start=1):
        entry["rank"] = i

    output = {
        "schema_version": SCHEMA_VERSION,
        "model_version": MODEL_VERSION,
        "generated_at": generated_at,
        "weights": WEIGHTS,
        "normalization": {
            "max_observation_count": max_obs,
            "max_entity_diversity": max_entity,
            "max_network_overlap": max_network,
            "max_inactive_days": MAX_INACTIVE_DAYS
        },
        "counts": {
            "worlds_ranked": len(ranked)
        },
        "worlds": ranked
    }

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, sort_keys=False)

    print(f"Ranking complete: {len(ranked)} worlds → {OUTPUT_PATH}")
    print(f"Top 5: {', '.join([f'{e['world_id']} ({e['score']})' for e in ranked[:5]])}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

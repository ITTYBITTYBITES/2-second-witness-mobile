#!/usr/bin/env python3
"""
Evolution Proposals v1
Phase 2.3 – Evolution Proposal Layer

Analyzes current content and produces ranked growth recommendations.
Does NOT generate worlds. Does NOT modify content. Does NOT modify pipeline.
Proposals only.

Proposal types:
  - coverage_gap
  - expansion
  - balance
  - seasonal
"""
import json
import os
from pathlib import Path
from datetime import datetime, timezone
from collections import defaultdict, Counter

# Path resolution: GITHUB_WORKSPACE in CI, fallback to local layout
_GW = os.environ.get("GITHUB_WORKSPACE")
if _GW:
    SHARED_DIR = Path(_GW) / "shared"
else:
    for cand in [Path("/home/user/workspace/shared"), Path(__file__).resolve().parents[5] / "shared", Path(__file__).resolve().parents[4] / "shared"]:
        if (cand / "worlds.json").exists():
            SHARED_DIR = cand
            break
    else:
        SHARED_DIR = Path("/home/user/workspace/shared")

WORLDS_PATH = SHARED_DIR / "worlds.json"
UNIVERSES_PATH = SHARED_DIR / "universes.json"
RANKING_PATH = SHARED_DIR / "evolution" / "ranking.json"
LIFECYCLE_PATH = SHARED_DIR / "evolution" / "lifecycle.json"
PLACEMENT_PATH = SHARED_DIR / "evolution" / "placement.json"
OUTPUT_DIR = SHARED_DIR / "evolution"
OUTPUT_PATH = OUTPUT_DIR / "growth_proposals.json"

MODEL_VERSION = "proposals-v1"
SCHEMA_VERSION = "1.0.0"

def load_json(p, default=None):
    try:
        with open(p, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default if default is not None else {}

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
    worlds_data = load_json(WORLDS_PATH, {"worlds":[]})
    universes_data = load_json(UNIVERSES_PATH, {"universes":[]})
    ranking_data = load_json(RANKING_PATH, {"worlds":[], "model_version":"none"})
    lifecycle_data = load_json(LIFECYCLE_PATH, {"worlds":[], "model_version":"none"})
    placement_data = load_json(PLACEMENT_PATH, {"placements":[], "model_version":"none"})

    worlds = worlds_data.get("worlds", [])
    universes = universes_data.get("universes", [])

    rank_map = {w.get("world_id"): w for w in ranking_data.get("worlds", [])}
    lifecycle_map = {w.get("world_id"): w for w in lifecycle_data.get("worlds", [])}

    # Universe world counts
    world_counts = Counter(w.get("universe_id") for w in worlds)
    universe_ids_defined = [u.get("id") for u in universes]
    # Also include universes that appear in worlds but not in universes list
    for uid in world_counts:
        if uid not in universe_ids_defined:
            universe_ids_defined.append(uid)
    universe_ids_defined = sorted(set(universe_ids_defined))

    max_worlds_in_universe = max(world_counts.values()) if world_counts else 1
    avg_worlds = sum(world_counts.values()) / len(world_counts) if world_counts else 0

    proposals = []
    pid_counter = 1

    def add_proposal(ptype, target, title, reason, score, confidence, evidence, related_worlds=None, related_universe=None, tags=None):
        nonlocal pid_counter
        proposal = {
            "proposal_id": f"prop-{pid_counter:03d}",
            "type": ptype,
            "target": target,
            "title": title,
            "reason": reason,
            "score": round(max(0.0, min(1.0, score)), 4),
            "confidence": round(max(0.0, min(1.0, confidence)), 4),
            "evidence": evidence,
            "related_worlds": related_worlds or [],
            "related_universe": related_universe,
            "status": "proposed",
            "created_at": generated_at,
            "tags": tags or []
        }
        proposals.append(proposal)
        pid_counter += 1

    generated_at = get_generated_at()

    # 1. Coverage Gaps
    # Universes with 0 worlds, or < 5 worlds
    coverage_targets = [
        ("frontier", "Frontier Exploration", ["space exploration", "deep_sea", "arctic_research"]),
        ("life_sciences", "Life Sciences", ["medical", "genomics", "ecology_advanced"]),
        ("society_mind", "Society & Mind", ["behavioral_psychology", "economics", "linguistics"]),
        ("tech_ops", "Tech Ops", ["systems_engineering", "cybersecurity", "devops"]),
    ]
    for uid, display, suggested_worlds in coverage_targets:
        count = world_counts.get(uid, 0)
        if count < 5:
            missing = max(0, int(avg_worlds) - count)
            score = 0.80 + min(0.15, missing * 0.02)
            confidence = 0.75
            evidence = [
                f"universe {uid} has {count} worlds",
                f"global average is {avg_worlds:.2f} worlds/universe",
                f"max universe size is {max_worlds_in_universe} worlds",
                "high activity in neighboring universes with missing related categories"
            ]
            for sw in suggested_worlds[:1]:
                add_proposal(
                    ptype="coverage_gap",
                    target=sw,
                    title=f"Coverage gap: {display} – {sw.replace('_',' ')}",
                    reason="high activity with missing related categories",
                    score=score,
                    confidence=confidence,
                    evidence=evidence,
                    related_worlds=[],
                    related_universe=uid,
                    tags=["coverage", uid, "gap"]
                )
    
    # Also check space_astronomy which has only 1 world in data
    if world_counts.get("space_astronomy", 0) > 0 and world_counts.get("space_astronomy", 0) < 5:
        count = world_counts["space_astronomy"]
        add_proposal(
            ptype="coverage_gap",
            target="space exploration",
            title="Coverage gap: Space Astronomy – space exploration",
            reason="high activity with missing related categories",
            score=0.78,
            confidence=0.72,
            evidence=[
                f"universe space_astronomy has {count} worlds",
                "solar_system is active with low entity diversity",
                "related categories missing"
            ],
            related_worlds=["solar_system"],
            related_universe="space_astronomy",
            tags=["coverage", "space_astronomy", "gap"]
        )

    # 2. Expansion Opportunities
    # Top-ranked active worlds suggest adjacent content
    ranked_worlds = sorted(ranking_data.get("worlds", []), key=lambda x: x.get("rank", 999))
    expansion_map = {
        "animation": ("animation_principles_advanced", "Animation Principles Advanced"),
        "architecture": ("architectural_history", "Architectural History"),
        "art_history": ("contemporary_art", "Contemporary Art"),
        "drawing": ("illustration", "Illustration"),
        "photography": ("cinematography", "Cinematography"),
    }
    expansions_added = 0
    for rw in ranked_worlds:
        if expansions_added >= 5:
            break
        wid = rw.get("world_id")
        if wid in expansion_map:
            target, title_suffix = expansion_map[wid]
            world_score = rw.get("score", 0.5)
            # entity diversity signal if available
            signals = rw.get("signals", {})
            entity_div = signals.get("entity_diversity", 0.5)
            score = world_score * 0.9
            confidence = 0.65 + (entity_div * 0.1)
            evidence = [
                f"high ranking neighboring worlds",
                f"source_world={wid}",
                f"rank={rw.get('rank')}",
                f"score={world_score:.4f}"
            ]
            add_proposal(
                ptype="expansion",
                target=target,
                title=f"Expansion: {title_suffix}",
                reason="high ranking neighboring worlds",
                score=score,
                confidence=confidence,
                evidence=evidence,
                related_worlds=[wid],
                related_universe=rw.get("universe_id"),
                tags=["expansion", rw.get("universe_id", ""), wid]
            )
            expansions_added += 1

    # 3. Balance Opportunities
    # Universes underrepresented compared with others
    balance_targets = [
        ("life_sciences", "medical", "Life Sciences – Medical", ["creative_arts", "history", "science_lab"]),
        ("society_mind", "behavioral_psychology", "Society Mind – Behavioral Psychology", ["creative_arts", "history"]),
        ("tech_ops", "systems_engineering", "Tech Ops – Systems Engineering", ["science_lab", "creative_arts"]),
        ("frontier", "space_exploration", "Frontier – Space Exploration", ["science_lab"]),
    ]
    for uid, target, title, strong_universes in balance_targets:
        count = world_counts.get(uid, 0)
        balance_ratio = count / max_worlds_in_universe if max_worlds_in_universe else 0
        score = round(1.0 - balance_ratio, 4)
        # clamp to reasonable range
        score = max(0.55, min(0.92, score))
        confidence = 0.70
        evidence = [
            f"universe {uid} has {count} worlds",
            f"max universe size is {max_worlds_in_universe}",
            f"balance_ratio={balance_ratio:.3f}",
            "underrepresented compared with other universes",
            f"strong_universes={', '.join(strong_universes)}"
        ]
        add_proposal(
            ptype="balance",
            target=target,
            title=f"Balance: {title}",
            reason="underrepresented compared with other universes",
            score=score,
            confidence=confidence,
            evidence=evidence,
            related_worlds=[],
            related_universe=uid,
            tags=["balance", uid, "underrepresented"]
        )

    # 4. Seasonal Opportunities
    # Placeholders only, no external APIs
    seasonal_proposals = [
        ("winter_survival", "Winter Survival", "existing compatible content", ["viking_age", "feudal_japan"], "history"),
        ("harvest_festival", "Harvest Festival", "existing compatible content", ["ancient_china", "mesoamerica"], "history"),
        ("ocean_exploration", "Ocean Exploration", "existing compatible content", ["marine_biology", "ecology"], "science_lab"),
    ]
    for target, title, reason, related, universe in seasonal_proposals:
        # Check if related worlds exist in our corpus
        existing_related = [w for w in related if w in rank_map]
        confidence_base = 0.35
        if existing_related:
            confidence_base += 0.05 * len(existing_related)
        add_proposal(
            ptype="seasonal",
            target=target,
            title=f"Seasonal: {title}",
            reason=reason,
            score=0.45,
            confidence=min(0.6, confidence_base),
            evidence=[
                "seasonal placeholder – no external API",
                f"compatible_content={', '.join(existing_related) if existing_related else 'none'}",
                "existing compatible content"
            ],
            related_worlds=existing_related,
            related_universe=universe,
            tags=["seasonal", "placeholder", universe]
        )

    # Sort proposals by score desc, then proposal_id asc (deterministic)
    proposals.sort(key=lambda p: (-p["score"], p["proposal_id"]))

    # Re-assign proposal_ids after sorting? Keep original for traceability – no, keep stable IDs but sorted output is fine.
    # For strict determinism, keep IDs as created, output sorted.

    counts_by_type = Counter(p["type"] for p in proposals)

    output = {
        "schema_version": SCHEMA_VERSION,
        "model_version": MODEL_VERSION,
        "generated_at": generated_at,
        "inputs": {
            "ranking_model": ranking_data.get("model_version", "none"),
            "ranking_generated_at": ranking_data.get("generated_at"),
            "lifecycle_model": lifecycle_data.get("model_version", "none"),
            "lifecycle_generated_at": lifecycle_data.get("generated_at"),
            "placement_model": placement_data.get("model_version", "none"),
            "placement_generated_at": placement_data.get("generated_at"),
            "worlds_count": len(worlds),
            "universes_count": len(universes)
        },
        "scoring": {
            "deterministic": True,
            "randomness": False,
            "external_data": False,
            "note": "Score is content-derived, reproducible"
        },
        "approval_boundary": {
            "allowed_statuses": ["proposed", "approved", "rejected", "implemented"],
            "engine_may_create": ["proposed"],
            "engine_may_not": ["approved", "rejected", "implemented"],
            "current_status_all": "proposed"
        },
        "counts": {
            "total": len(proposals),
            "coverage_gap": counts_by_type.get("coverage_gap", 0),
            "expansion": counts_by_type.get("expansion", 0),
            "balance": counts_by_type.get("balance", 0),
            "seasonal": counts_by_type.get("seasonal", 0)
        },
        "proposals": proposals
    }

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    print(f"Proposals complete: {len(proposals)} total "
          f"(coverage_gap={counts_by_type.get('coverage_gap',0)}, "
          f"expansion={counts_by_type.get('expansion',0)}, "
          f"balance={counts_by_type.get('balance',0)}, "
          f"seasonal={counts_by_type.get('seasonal',0)}) → {OUTPUT_PATH}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

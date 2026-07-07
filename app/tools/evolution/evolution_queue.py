#!/usr/bin/env python3
"""
Evolution Queue v1
Governance Layer – Generation Queue Builder

Builds a deterministic execution queue from approved proposals.
- ONLY approved proposals enter the queue
- No content generation
- Preserve deterministic ordering
"""
import json
import os
import hashlib
from pathlib import Path
from datetime import datetime, timezone

_GW = os.environ.get("GITHUB_WORKSPACE")
if _GW:
    SHARED_DIR = Path(_GW) / "shared"
else:
    for cand in [Path("/home/user/workspace/shared"), Path(__file__).resolve().parents[5] / "shared", Path(__file__).resolve().parents[4] / "shared"]:
        if (cand / "evolution" / "growth_proposals.json").exists():
            SHARED_DIR = cand
            break
    else:
        SHARED_DIR = Path("/home/user/workspace/shared")

PROPOSALS_PATH = SHARED_DIR / "evolution" / "growth_proposals.json"
APPROVALS_PATH = SHARED_DIR / "evolution" / "approvals.json"
OUTPUT_PATH = SHARED_DIR / "evolution" / "generation_queue.json"

MODEL_VERSION = "queue-v1"
SCHEMA_VERSION = "1.0.0"

def get_generated_at():
    env_ts = os.environ.get("EVO_TIMESTAMP")
    if env_ts:
        return env_ts
    # chain from approvals
    for p in [APPROVALS_PATH, PROPOSALS_PATH, SHARED_DIR / "export" / "manifest.json"]:
        try:
            with open(p) as f:
                d = json.load(f)
                ts = d.get("generated_at") or d.get("timestamp")
                if ts:
                    if ts.endswith("Z"):
                        ts = ts[:-1] + "+00:00"
                    return ts
        except Exception:
            continue
    return datetime.now(timezone.utc).isoformat()

def main():
    with open(PROPOSALS_PATH, "r", encoding="utf-8") as f:
        proposals_data = json.load(f)
    with open(APPROVALS_PATH, "r", encoding="utf-8") as f:
        approvals_data = json.load(f)

    proposals = {p["proposal_id"]: p for p in proposals_data.get("proposals", [])}
    approvals = {a["proposal_id"]: a for a in approvals_data.get("approvals", [])}

    generated_at = get_generated_at()

    queue_items = []
    for pid, appr in sorted(approvals.items()):
        if appr.get("status") != "approved":
            continue
        prop = proposals.get(pid)
        if not prop:
            continue  # approved proposal no longer exists – skip, will be marked expired next approvals run
        # Determine generation type from proposal type
        type_map = {
            "coverage_gap": "world_expansion",
            "expansion": "world_expansion",
            "balance": "world_expansion",
            "seasonal": "seasonal_world"
        }
        gen_type = type_map.get(prop.get("type"), "world_expansion")
        # Priority = score * confidence, higher first – then proposal_id for determinism
        score = prop.get("score", 0)
        confidence = prop.get("confidence", 0)
        priority = round(score * confidence, 6)
        # Checksum over proposal content – auditable
        checksum_src = json.dumps(prop, sort_keys=True, separators=(",", ":")).encode()
        checksum = "sha256:" + hashlib.sha256(checksum_src).hexdigest()
        queue_items.append({
            "queue_id": f"q-{prop['proposal_id']}",
            "proposal_id": pid,
            "status": "queued",
            "generation_type": gen_type,
            "target": prop.get("target"),
            "priority": priority,
            "score": score,
            "confidence": confidence,
            "dependencies": [],  # reserved – no dependencies in v1
            "checksum": checksum,
            "approved_at": appr.get("updated_at"),
            "queued_at": generated_at,
            "attempts": 0,
            "notes": f"Approved proposal queued for generation – {prop.get('reason','')}"
        })

    # Deterministic ordering: priority desc, then proposal_id asc
    queue_items.sort(key=lambda x: (-x["priority"], x["proposal_id"]))
    # Assign queue_position
    for i, item in enumerate(queue_items, start=1):
        item["queue_position"] = i

    # Queue checksum – hash of ordered proposal_ids
    queue_content = "|".join([q["proposal_id"] for q in queue_items])
    queue_checksum = "sha256:" + hashlib.sha256(queue_content.encode()).hexdigest()

    output = {
        "schema_version": SCHEMA_VERSION,
        "model_version": MODEL_VERSION,
        "generated_at": generated_at,
        "inputs": {
            "proposals_model": proposals_data.get("model_version"),
            "proposals_count": len(proposals),
            "approvals_model": approvals_data.get("model_version"),
            "approved_count": sum(1 for a in approvals.values() if a.get("status") == "approved")
        },
        "queue_policy": {
            "only_approved_enter_queue": True,
            "ordering": "priority_desc_then_proposal_id_asc",
            "content_generation": False,
            "execution_authority": "approval_state"
        },
        "checksum": queue_checksum,
        "counts": {
            "queued": len(queue_items),
            "total_approved_input": sum(1 for a in approvals.values() if a.get("status") == "approved")
        },
        "queue": queue_items
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    print(f"Generation queue complete: {len(queue_items)} items queued → {OUTPUT_PATH}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

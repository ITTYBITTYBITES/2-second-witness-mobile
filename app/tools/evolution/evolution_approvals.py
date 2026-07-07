#!/usr/bin/env python3
"""
Evolution Approvals v1
Governance Layer – Approval Registry

Tracks proposal state transitions, separate from proposal generation.
- Proposal generator never edits approvals
- Approvals never edit proposals
- Approval state is the only authority for execution
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
        if (cand / "evolution" / "growth_proposals.json").exists() or (cand / "worlds.json").exists():
            SHARED_DIR = cand
            break
    else:
        SHARED_DIR = Path("/home/user/workspace/shared")

PROPOSALS_PATH = SHARED_DIR / "evolution" / "growth_proposals.json"
APPROVALS_PATH = SHARED_DIR / "evolution" / "approvals.json"

MODEL_VERSION = "approvals-v1"
SCHEMA_VERSION = "1.0.0"

def get_generated_at():
    env_ts = os.environ.get("EVO_TIMESTAMP")
    if env_ts:
        return env_ts
    # Use proposals timestamp if available, else export manifest
    try:
        with open(PROPOSALS_PATH) as f:
            p = json.load(f)
            ts = p.get("generated_at")
            if ts:
                return ts
    except Exception:
        pass
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
    with open(PROPOSALS_PATH, "r", encoding="utf-8") as f:
        proposals_data = json.load(f)

    proposals = {p["proposal_id"]: p for p in proposals_data.get("proposals", [])}
    
    # Load existing approvals to preserve human decisions
    existing = {}
    if APPROVALS_PATH.exists():
        try:
            with open(APPROVALS_PATH, "r", encoding="utf-8") as f:
                old = json.load(f)
                for a in old.get("approvals", []):
                    existing[a["proposal_id"]] = a
        except Exception:
            pass

    generated_at = get_generated_at()
    approvals_out = []
    
    for pid in sorted(proposals.keys()):
        prop = proposals[pid]
        if pid in existing:
            # Preserve existing approval state – human authority
            # Update only metadata that is safe (e.g., proposal still exists)
            old_rec = existing[pid].copy()
            # Ensure status is valid
            if old_rec.get("status") not in ("proposed", "approved", "rejected", "expired", "completed"):
                old_rec["status"] = "proposed"
            approvals_out.append(old_rec)
            continue
        # New proposal – register as proposed
        approvals_out.append({
            "proposal_id": pid,
            "proposal_type": prop.get("type"),
            "proposal_target": prop.get("target"),
            "status": "proposed",
            "score": prop.get("score"),
            "confidence": prop.get("confidence"),
            "updated_at": generated_at,
            "actor": "system",
            "notes": "auto-registered from growth_proposals.json – awaiting human review",
            "history": [
                {
                    "status": "proposed",
                    "timestamp": generated_at,
                    "actor": "system",
                    "notes": "initial registration"
                }
            ]
        })
    
    # Mark approvals for proposals that no longer exist as expired
    proposal_ids = set(proposals.keys())
    for pid, old_rec in existing.items():
        if pid not in proposal_ids and old_rec.get("status") not in ("completed", "rejected", "expired"):
            expired_rec = old_rec.copy()
            expired_rec["status"] = "expired"
            expired_rec["updated_at"] = generated_at
            expired_rec.setdefault("history", []).append({
                "status": "expired",
                "timestamp": generated_at,
                "actor": "system",
                "notes": "proposal no longer in growth_proposals.json"
            })
            approvals_out.append(expired_rec)

    # Counts
    from collections import Counter
    counts = Counter(a["status"] for a in approvals_out)
    counts_dict = {
        "proposed": counts.get("proposed", 0),
        "approved": counts.get("approved", 0),
        "rejected": counts.get("rejected", 0),
        "expired": counts.get("expired", 0),
        "completed": counts.get("completed", 0),
        "total": len(approvals_out)
    }

    output = {
        "schema_version": SCHEMA_VERSION,
        "model_version": MODEL_VERSION,
        "generated_at": generated_at,
        "inputs": {
            "proposals_model": proposals_data.get("model_version"),
            "proposals_generated_at": proposals_data.get("generated_at"),
            "proposals_count": len(proposals)
        },
        "approval_authority": {
            "proposal_generator_may_edit": False,
            "approvals_may_edit_proposals": False,
            "approval_state_is_execution_authority": True,
            "allowed_statuses": ["proposed", "approved", "rejected", "expired", "completed"]
        },
        "counts": counts_dict,
        "approvals": sorted(approvals_out, key=lambda x: x["proposal_id"])
    }

    OUTPUT_DIR = APPROVALS_PATH.parent
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(APPROVALS_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    print(f"Approvals registry complete: proposed={counts_dict['proposed']} approved={counts_dict['approved']} rejected={counts_dict['rejected']} expired={counts_dict['expired']} completed={counts_dict['completed']} → {APPROVALS_PATH}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

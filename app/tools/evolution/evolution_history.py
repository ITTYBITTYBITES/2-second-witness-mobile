#!/usr/bin/env python3
"""
Evolution History v1
Governance Layer – Execution History

Append-only permanent audit trail.
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
        if (cand / "evolution").exists():
            SHARED_DIR = cand
            break
    else:
        SHARED_DIR = Path("/home/user/workspace/shared")

HISTORY_PATH = SHARED_DIR / "evolution" / "generation_history.json"

MODEL_VERSION = "history-v1"
SCHEMA_VERSION = "1.0.0"

def get_generated_at():
    env_ts = os.environ.get("EVO_TIMESTAMP")
    if env_ts:
        return env_ts
    return datetime.now(timezone.utc).isoformat()

def load_history():
    if HISTORY_PATH.exists():
        try:
            with open(HISTORY_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return None

def init_history():
    """Initialize empty append-only history if missing"""
    if HISTORY_PATH.exists():
        return False
    generated_at = get_generated_at()
    output = {
        "schema_version": SCHEMA_VERSION,
        "model_version": MODEL_VERSION,
        "created_at": generated_at,
        "updated_at": generated_at,
        "policy": {
            "append_only": True,
            "deletion_forbidden": True,
            "permanent_audit_trail": True
        },
        "counts": {
            "total_executions": 0,
            "success": 0,
            "failure": 0
        },
        "executions": []
    }
    HISTORY_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(HISTORY_PATH, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)
    return True

def main():
    # Initialize history file if missing – append-only, never overwrite existing history
    created = init_history()
    if created:
        print(f"Execution history initialized → {HISTORY_PATH}")
    else:
        # Verify existing history is valid and report counts – do NOT modify
        hist = load_history()
        counts = hist.get("counts", {}) if hist else {}
        print(f"Execution history exists: total={counts.get('total_executions',0)} success={counts.get('success',0)} failure={counts.get('failure',0)} → {HISTORY_PATH}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

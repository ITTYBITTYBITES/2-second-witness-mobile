#!/usr/bin/env python3
"""
Build State Generator
Produces /shared/build_state.json – versioned, comparable, rollback-safe
Every pipeline run leaves an auditable fingerprint.
"""
import json
import hashlib
import os
import subprocess
import sys
from pathlib import Path
from datetime import datetime, timezone

# Path resolution: GITHUB_WORKSPACE in CI, fallback to local layout
_GW = os.environ.get("GITHUB_WORKSPACE")
if _GW:
    SHARED_DIR = Path(_GW) / "shared"
else:
    SHARED_DIR = Path("/home/user/workspace/shared")
MANIFEST_PATH = SHARED_DIR / "export" / "manifest.json"
STATE_PATH = SHARED_DIR / "build_state.json"

def get_git_commit(repo_path="."):
    """Get git commit hash. APP_COMMIT env overrides app repo; GITHUB_SHA is fallback."""
    rp = str(repo_path)
    if "website" in rp.lower():
        env_val = os.environ.get("WEBSITE_COMMIT")
        if env_val:
            return env_val
    elif "app" in rp.lower():
        env_val = os.environ.get("APP_COMMIT") or os.environ.get("GITHUB_SHA")
        if env_val:
            return env_val
    try:
        result = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            capture_output=True, text=True, cwd=repo_path, timeout=10
        )
        return result.stdout.strip() if result.returncode == 0 else "unknown"
    except Exception:
        return "unknown"

def get_git_commit_short(repo_path="."):
    long_hash = get_git_commit(repo_path)
    return long_hash[:7] if len(long_hash) > 7 else long_hash

def compute_export_hash(manifest):
    counts = manifest.get("counts", {})
    validation = manifest.get("validation", {})
    seed = f"{counts.get('observations_exported',0)}|{counts.get('worlds',0)}|{counts.get('universes',0)}|{counts.get('characters',0)}|{validation.get('duplicate_identifiers',0)}|{validation.get('schema_violations',0)}"
    h = hashlib.sha256(seed.encode())
    for path in sorted(SHARED_DIR.rglob("*.json")):
        if "build_state" in str(path):
            continue
        try:
            h.update(path.name.encode())
            h.update(str(os.path.getsize(path)).encode())
        except OSError:
            pass
    return "sha256:" + h.hexdigest()
def next_run_id():
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    if STATE_PATH.exists():
        try:
            prev = json.loads(STATE_PATH.read_text(encoding="utf-8"))
            prev_rid = prev.get("run_id", "")
            if prev_rid.startswith(today):
                parts = prev_rid.split("-")
                seq = int(parts[-1]) + 1
                return f"{today}-{seq:03d}"
        except (json.JSONDecodeError, ValueError, IndexError):
            pass
    return f"{today}-001"
def load_json_safe(p, default=None):
    try:
        with open(p, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default

def main():
    if not MANIFEST_PATH.exists():
        print(f"ERROR: manifest not found at {MANIFEST_PATH}")
        print("Run chronicle_export_v1 first.")
        return 1

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    counts = manifest.get("counts", {})
    # Resolve app and website repo directories relative to shared
    app_repo = (SHARED_DIR / ".." / "app").resolve()
    website_repo = (SHARED_DIR / ".." / "website").resolve()
    app_commit = get_git_commit(str(app_repo))
    website_commit = get_git_commit(str(website_repo))

    run_id = next_run_id()
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    export_hash = compute_export_hash(manifest)

    # Governance layer – read-only, optional (Phase 2.3+)
    def gov_count(path, key=None):
        d = load_json_safe(SHARED_DIR / path, {})
        if not d:
            return 0, "none"
        if key:
            c = d.get("counts", {}).get(key, 0)
        else:
            c = d.get("counts", {}).get("total", len(d.get("proposals", d.get("approvals", d.get("queue", d.get("executions", []))))))
        model = d.get("model_version", "none")
        return c, model

    proposals_count, proposals_model = gov_count("evolution/growth_proposals.json", None)
    # approvals counts – sum all states
    approvals_data = load_json_safe(SHARED_DIR / "evolution/approvals.json", {})
    approvals_counts = approvals_data.get("counts", {}) if approvals_data else {}
    approvals_total = approvals_counts.get("total", 0)
    approvals_model = approvals_data.get("model_version", "none") if approvals_data else "none"
    # queue
    queue_data = load_json_safe(SHARED_DIR / "evolution/generation_queue.json", {})
    queue_count = queue_data.get("counts", {}).get("queued", 0) if queue_data else 0
    queue_model = queue_data.get("model_version", "none") if queue_data else "none"
    # history
    history_data = load_json_safe(SHARED_DIR / "evolution/generation_history.json", {})
    execution_count = history_data.get("counts", {}).get("total_executions", 0) if history_data else 0
    history_model = history_data.get("model_version", "none") if history_data else "none"
    # evolution core models
    ranking_data = load_json_safe(SHARED_DIR / "evolution/ranking.json", {})
    lifecycle_data = load_json_safe(SHARED_DIR / "evolution/lifecycle.json", {})
    placement_data = load_json_safe(SHARED_DIR / "evolution/placement.json", {})

    state = {
        "schema_version": "1.1.0",
        "run_id": run_id,
        "pipeline_version": "1.1.0",
        "timestamp": now,
        "app_commit": app_commit,
        "app_commit_short": app_commit[:7] if len(app_commit) > 7 else app_commit,
        "website_commit": website_commit,
        "website_commit_short": website_commit[:7] if len(website_commit) > 7 else website_commit,
        "export_hash": export_hash,
        "manifest_timestamp": manifest.get("timestamp", ""),
        "counts": {
            "observation_banks": counts.get("observation_banks", 0),
            "observations_exported": counts.get("observations_exported", 0),
            "worlds": counts.get("worlds", 0),
            "universes": counts.get("universes", 0),
            "characters": counts.get("characters", 0),
            "proposals": proposals_count,
            "approvals": approvals_total,
            "queue": queue_count,
            "executions": execution_count
        },
        "evolution": {
            "ranking_model": ranking_data.get("model_version", "none") if ranking_data else "none",
            "lifecycle_model": lifecycle_data.get("model_version", "none") if lifecycle_data else "none",
            "placement_model": placement_data.get("model_version", "none") if placement_data else "none",
            "proposals_model": proposals_model,
            "approvals_model": approvals_model,
            "queue_model": queue_model,
            "history_model": history_model
        },
        "governance": {
            "approvals_breakdown": {
                "proposed": approvals_counts.get("proposed", 0),
                "approved": approvals_counts.get("approved", 0),
                "rejected": approvals_counts.get("rejected", 0),
                "expired": approvals_counts.get("expired", 0),
                "completed": approvals_counts.get("completed", 0)
            } if approvals_counts else {},
            "queue_depth": queue_count,
            "execution_success_rate": None
        },
        "validation": {
            "duplicate_identifiers": manifest.get("validation", {}).get("duplicate_identifiers", 0),
            "schema_violations": manifest.get("validation", {}).get("schema_violations", 0),
            "orphaned_references": manifest.get("validation", {}).get("orphaned_references", 0),
            "private_data_leakage": manifest.get("private_data_leakage_check", ""),
        },
        "source_provenance": "app",
        "authority_tier": "tier_1_projection",
        "provenance": {
            "generated_by": "generate_build_state.py",
            "pipeline": "chronicle_export -> evolution_ranker -> evolution_lifecycle -> evolution_placement -> evolution_proposals -> evolution_approvals -> evolution_queue -> build_state -> build_website -> deploy"
        }
    }

    STATE_PATH.write_text(json.dumps(state, indent=2), encoding="utf-8")
    print(f"✓ build_state.json written: {STATE_PATH}")
    print(f"  run_id:         {run_id}")
    print(f"  app_commit:     {app_commit[:12]}...")
    print(f"  website_commit: {website_commit[:12]}...")
    print(f"  export_hash:    {export_hash[:20]}...")
    print(f"  observations:   {counts.get('observations_exported',0)}")
    print(f"  worlds:         {counts.get('worlds',0)}")
    print(f"  universes:      {counts.get('universes',0)}")
    print(f"  characters:     {counts.get('characters',0)}")
    print(f"  proposals:      {proposals_count}")
    print(f"  approvals:      {approvals_total}")
    print(f"  queue:          {queue_count}")
    print(f"  executions:     {execution_count}")
    return 0

if __name__ == "__main__":
    sys.exit(main())

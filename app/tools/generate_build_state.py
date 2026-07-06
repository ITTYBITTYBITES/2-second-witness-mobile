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

    state = {
        "schema_version": "1.0.0",
        "run_id": run_id,
        "pipeline_version": "1.0.0",
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
            "characters": counts.get("characters", 0)
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
            "pipeline": "chronicle_export -> build_state -> build_website -> deploy"
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
    return 0

if __name__ == "__main__":
    sys.exit(main())

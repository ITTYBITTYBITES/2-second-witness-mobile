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
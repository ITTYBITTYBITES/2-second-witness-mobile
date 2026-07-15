#!/usr/bin/env python3
"""Verify logic files are unchanged after visual style migration."""
from __future__ import annotations
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASELINE = Path("/tmp/must_not_change_baseline.sha256")
CHANGELIST = Path("/tmp/must_not_change.txt")

if not BASELINE.exists():
    print("SAFETY: No baseline exists — run checksum capture first")
    sys.exit(1)

baseline: dict[str, str] = {}
for line in BASELINE.read_text().strip().splitlines():
    if not line.strip():
        continue
    parts = line.strip().split("  ", 1)
    if len(parts) == 2:
        baseline[parts[1]] = parts[0]

failures: list[str] = []
missing: list[str] = []
modified: list[str] = []

for line in CHANGELIST.read_text().strip().splitlines():
    path = line.strip()
    if not path or path.startswith("#"):
        continue
    full = ROOT / path
    if not full.exists():
        missing.append(path)
        continue
    import hashlib
    current = hashlib.sha256(full.read_bytes()).hexdigest()
    expected = baseline.get(path, "")
    if not expected:
        missing.append(f"{path} (no baseline)")
    elif current != expected:
        modified.append(path)

if missing:
    for m in missing:
        print(f"LOGIC_MISSING: {m}")
        failures.append(m)

if modified:
    for m in modified:
        print(f"LOGIC_TAMPERED: {m}")
        failures.append(m)

if failures:
    print(f"\nSAFETY FAILED: {len(failures)} logic files differ from baseline")
    sys.exit(1)

print(f"SAFETY PASSED: {len(baseline)} logic files unchanged")

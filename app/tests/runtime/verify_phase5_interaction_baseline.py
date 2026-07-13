#!/usr/bin/env python3
"""Preserves the Phase 5 interaction baseline while accepting documented,
family-agnostic Phase 6 production-readiness evolution."""

from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[3]
phase5 = json.loads((ROOT / "docs/product/PHASE_5_INTERACTION_BASELINE.json").read_text())
phase6_path = ROOT / "docs/product/PHASE_6_PLATFORM_BASELINE.json"
phase6 = json.loads(phase6_path.read_text()) if phase6_path.exists() else {}
approved = set(phase6.get("approved_evolved_files", []))
phase6_hashes = phase6.get("files", {})
errors: list[str] = []
evolved = 0
for relative, expected in phase5["files"].items():
    path = ROOT / relative
    if not path.exists():
        errors.append("removed: " + relative)
        continue
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual == expected:
        continue
    if relative in approved and phase6_hashes.get(relative) == actual:
        evolved += 1
    else:
        errors.append("changed without Phase 6 approval record: " + relative)
shared: list[Path] = []
for folder in ("app/src/gameplay/runtime", "app/src/gameplay/interactions", "app/src/core", "app/src/systems"):
    shared += list((ROOT / folder).rglob("*.gd"))
shared += [ROOT / "app/src/ui/screens/MemoryQuestionScreen.gd"]
text = "\n".join(path.read_text() for path in shared)
for forbidden in ("spot_the_difference", "object_recall", "pattern_recall", "SpotDifference", "ObjectRecall", "PatternRecall"):
    if forbidden in text:
        errors.append("family-specific shared code: " + forbidden)
if errors:
    for error in errors:
        print("PHASE5 INTERACTION BASELINE FAIL:", error)
    raise SystemExit(1)
print(f'PHASE5_INTERACTION_BASELINE_PASS files={len(phase5["files"])} phase6_evolved={evolved}')

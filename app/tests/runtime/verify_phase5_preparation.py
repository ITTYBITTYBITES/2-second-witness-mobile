#!/usr/bin/env python3
"""Static completeness checks for the Phase 5 preparation gate."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
DOCS = ROOT / "docs/product"
errors: list[str] = []

contract_path = DOCS / "challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md"
template_path = DOCS / "challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md"
matrix_path = DOCS / "challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md"
report_path = DOCS / "PHASE_5_PREPARATION_REPORT.md"
roadmap_path = DOCS / "PRODUCT_DEVELOPMENT_ROADMAP.md"
spot_spec_path = DOCS / "challenge-types/SPOT_THE_DIFFERENCE_SPEC.md"

for path in (contract_path, template_path, matrix_path, report_path, roadmap_path, spot_spec_path):
    if not path.exists():
        errors.append(f"missing preparation deliverable: {path.relative_to(ROOT)}")

contract = contract_path.read_text()
required_contract_topics = (
    "Why does this exist?",
    "intentionally choose",
    "Intended player feeling",
    "Core gameplay objective",
    "Observation task",
    "Primary mechanic",
    "Player actions",
    "Challenge flow",
    "Templates",
    "Generator contract",
    "Validator and fairness contract",
    "Difficulty axes",
    "Exposure timing policy",
    "Scoring and result presentation",
    "Tutorial requirements",
    "Accessibility requirements",
    "Audio and haptic profile",
    "Visual style",
    "Progress and recommendation integration",
    "Replay Value score",
    "Template variety",
    "Long-term freshness",
    "Expansion potential",
    "Marketing/screenshot recognition potential",
    "Success criteria",
    "Implementation authorized: YES / NO",
)
for topic in required_contract_topics:
    if topic.lower() not in contract.lower():
        errors.append(f"acceptance contract missing topic: {topic}")

if "CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md" not in template_path.read_text():
    errors.append("specification template does not reference the acceptance contract")

matrix = matrix_path.read_text()
required_columns = (
    "Observation focus",
    "Primary mechanic",
    "Information presented",
    "Memory demand",
    "Decision type",
    "Interaction type",
    "Typical exposure style",
    "Primary difficulty axes",
    "Replay characteristics",
    "Approx. round length",
)
for column in required_columns:
    if column not in matrix:
        errors.append(f"portfolio matrix missing column: {column}")

implemented = ("Scene Investigation", "Flash Words")
planned = (
    "Spot the Difference",
    "Object Recall",
    "Pattern Recall",
    "Motion Tracking",
    "Hidden Detail",
    "Color Recall",
    "Direction Recall",
    "Symbol Recognition",
    "Number Recall",
    "Sound Recognition",
)
for challenge_type in implemented + planned:
    if not re.search(rf"\|\s*{re.escape(challenge_type)}\s*\|", matrix):
        errors.append(f"portfolio matrix missing Challenge Type row: {challenge_type}")

report = report_path.read_text()
positions: list[int] = []
for index, challenge_type in enumerate(planned, start=1):
    marker = f"### {index}. {challenge_type}"
    position = report.find(marker)
    if position < 0:
        errors.append(f"implementation order missing: {marker}")
    positions.append(position)
if positions != sorted(positions):
    errors.append("implementation order is not sequential")

coverage_targets = (
    "Static observation",
    "Dynamic observation",
    "Visual recall",
    "Sequential recall",
    "Spatial awareness",
    "Motion tracking",
    "Pattern recognition",
    "Symbol recognition",
    "Number recognition",
    "Audio recognition",
    "Mixed attention",
)
for target in coverage_targets:
    if target not in report:
        errors.append(f"portfolio coverage missing: {target}")

roadmap = roadmap_path.read_text()
for phase_name in (
    "Phase 5 — Challenge Type Expansion",
    "Phase 5.5 — Content & Quality Pass",
    "Phase 6 — Production Readiness",
):
    if phase_name not in roadmap:
        errors.append(f"roadmap phase missing: {phase_name}")
if "Phase 5 Challenge Type Expansion" not in roadmap and "Phase 5 — Challenge Type Expansion" not in roadmap:
    errors.append("roadmap does not record Phase 5 implementation")

spot_spec = spot_spec_path.read_text()
required_spot_sections = (
    "Why does this exist?",
    "Interaction architecture",
    "Side-by-Side Presence",
    "Sequential Switch",
    "Exactly one change",
    "Replay Value",
    "22/25",
    "Expansion Potential",
    "Recognizable composition",
    "160,000 validated instances",
    "Implementation authorized: COMPLETED",
)
for section in required_spot_sections:
    if section not in spot_spec:
        errors.append(f"Spot the Difference specification missing: {section}")
if "Scene Investigation" not in matrix.split("## Signature Challenge Type strategy", 1)[-1]:
    errors.append("portfolio does not identify the current flagship candidate")

manifest = json.loads((APP / "src/gameplay/families/manifest.json").read_text())
manifest_ids = {str(item.get("id", "")) for item in manifest.get("families", [])}
expected_manifest = {"scene_investigation", "flash_words", "spot_the_difference", "object_recall", "pattern_recall", "scene_investigation_fixtures"}
if manifest_ids != expected_manifest:
    errors.append(f"Phase 5 family manifest mismatch: {sorted(manifest_ids)}")
remaining_planned = planned[3:]
planned_slugs = {name.lower().replace(" ", "_") for name in remaining_planned}
family_dirs = {path.name for path in (APP / "src/gameplay/families").iterdir() if path.is_dir()}
leaked = sorted(planned_slugs & family_dirs)
if leaked:
    errors.append(f"deferred family implementation started unexpectedly: {leaked}")

for path in (contract_path, matrix_path, report_path):
    text = path.read_text()
    for prohibited in ("brain training", "cognitive score", "IQ score"):
        if re.search(rf"\b{re.escape(prohibited)}\b", text, flags=re.IGNORECASE):
            errors.append(f"assessment-oriented phrase in {path.relative_to(ROOT)}: {prohibited}")

if errors:
    for error in errors:
        print(f"PHASE5 PREPARATION FAIL: {error}")
    raise SystemExit(1)

print("PHASE5_PREPARATION_PASS")
print(f"portfolio_types={len(implemented) + len(planned)} planned={len(planned)} manifest_families={len(manifest_ids)}")

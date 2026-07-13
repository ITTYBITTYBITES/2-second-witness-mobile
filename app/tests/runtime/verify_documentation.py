#!/usr/bin/env python3
"""Documentation consistency checks for the current Product Development gate."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
DOCS = ROOT / "docs"

errors: list[str] = []
markdown_files = [ROOT / "README.md", ROOT / "PRIVACY.md"]
markdown_files.extend(DOCS.rglob("*.md"))
markdown_files.extend((APP / "src/gameplay").rglob("*.md"))
markdown_files.extend((APP / "tests").rglob("*.md"))

link_pattern = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
for path in markdown_files:
    text = path.read_text(errors="ignore")
    for raw_link in link_pattern.findall(text):
        link = raw_link.split("#", 1)[0].strip()
        if not link or "://" in link or link.startswith("mailto:"):
            continue
        target = (path.parent / link).resolve()
        if not target.exists():
            errors.append(f"broken local link in {path.relative_to(ROOT)}: {raw_link}")

active_docs = [
    ROOT / "README.md",
    DOCS / "product/README.md",
    DOCS / "product/ARCHITECTURE_BOUNDARIES.md",
    DOCS / "product/CHALLENGE_CONTRACTS.md",
    DOCS / "product/PRODUCT_DEVELOPMENT_ROADMAP.md",
    DOCS / "foundation/ARCHITECTURE_SUMMARY.md",
    DOCS / "foundation/IMPLEMENTED_SYSTEMS.md",
    DOCS / "foundation/NEXT_STEPS.md",
]
active_text = "\n".join(path.read_text() for path in active_docs)
for obsolete in ("universes", "departments"):
    if re.search(rf"\b{obsolete}\b", active_text, flags=re.IGNORECASE):
        errors.append(f"obsolete architecture term remains in active documentation: {obsolete}")

current_status_files = [
    ROOT / "README.md",
    DOCS / "product/README.md",
    DOCS / "foundation/ARCHITECTURE_SUMMARY.md",
    DOCS / "foundation/IMPLEMENTED_SYSTEMS.md",
    DOCS / "foundation/NEXT_STEPS.md",
]
for path in current_status_files:
    text = path.read_text()
    if "Phase 5" not in text or not any(term in text for term in ("Challenge Type Expansion", "five-family", "Five-family")):
        errors.append(f"current status is missing the Phase 5 expansion milestone in {path.relative_to(ROOT)}")

player_copy_files = [ROOT / "README.md", DOCS / "store/PLAY_STORE_LISTING.md"]
player_copy_files.extend((APP / "src/ui").rglob("*.gd"))
player_copy_files.extend((APP / "src/ui").rglob("*.tscn"))
for path in player_copy_files:
    text = path.read_text(errors="ignore")
    for prohibited in ("cognitive", "brain training", "assessment", "diagnostic", "evaluation"):
        if re.search(rf"\b{re.escape(prohibited)}\b", text, flags=re.IGNORECASE):
            errors.append(f"assessment-oriented player copy in {path.relative_to(ROOT)}: {prohibited}")

required = [
    APP / "src/gameplay/contracts/ChallengeFamily.gd",
    APP / "src/gameplay/contracts/ChallengeTemplate.gd",
    APP / "src/gameplay/contracts/ChallengeInstance.gd",
    APP / "src/gameplay/contracts/PresentationProfile.gd",
    APP / "src/gameplay/contracts/ChallengeValidationResult.gd",
    APP / "src/gameplay/contracts/ChallengeResult.gd",
    APP / "src/gameplay/runtime/ChallengeSessionService.gd",
    APP / "src/gameplay/families/manifest.json",
    DOCS / "product/PHASE_2_GATE_1_COMPLETION.md",
    DOCS / "product/PHASE_2_GATE_2_COMPLETION.md",
    DOCS / "product/CHALLENGE_RUNTIME_API.md",
    DOCS / "product/SCORING_POLICY_CONTRACT.md",
    DOCS / "product/challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md",
    DOCS / "product/challenge-types/SCENE_INVESTIGATION_SPEC.md",
    DOCS / "product/challenge-types/SCENE_INVESTIGATION_STYLE_GUIDE.md",
    DOCS / "product/challenge-types/SCENE_INVESTIGATION_VISUAL_REVIEW.md",
    DOCS / "product/PHASE_2_GATE_3_PREPARATION.md",
    DOCS / "product/PHASE_2_GATE_3_COMPLETION.md",
    DOCS / "product/FAMILY_TUTORIAL_CONTRACT.md",
    DOCS / "product/challenge-types/FLASH_WORDS_SPEC.md",
    DOCS / "product/challenge-types/FLASH_WORDS_STYLE_GUIDE.md",
    DOCS / "product/PHASE_2_GATE_4_PREPARATION.md",
    DOCS / "product/PHASE_2_GATE_4_TUTORIAL_CORRECTION_COMPLETION.md",
    DOCS / "product/challenge-types/FLASH_WORDS_VISUAL_REVIEW.md",
    DOCS / "product/PHASE_2_GATE_4_COMPLETION.md",
    DOCS / "product/PHASE_3_HOME_EXPERIENCE_SPEC.md",
    DOCS / "product/PHASE_3_HOME_EXPERIENCE_COMPLETION.md",
    APP / "src/gameplay/progression/AchievementService.gd",
    APP / "src/gameplay/progression/achievements.json",
    APP / "src/ui/screens/AchievementsScreen.gd",
    APP / "tests/runtime/test_phase3_home_experience.gd",
    APP / "tests/runtime/verify_phase3_home_architecture.py",
    DOCS / "product/PHASE_3_5_PRODUCTION_POLISH_SPEC.md",
    DOCS / "product/PHASE_3_5_DEVICE_VALIDATION_MATRIX.md",
    DOCS / "product/PHASE_3_5_PRODUCTION_AUDIT.md",
    DOCS / "product/PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md",
    APP / "src/ui/layout/ResponsiveLayout.gd",
    APP / "tests/runtime/test_phase35_production_polish.gd",
    APP / "tests/runtime/verify_phase35_production_polish.py",
    DOCS / "product/PHASE_4_PLAYER_JOURNEY_SPEC.md",
    DOCS / "product/PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md",
    APP / "src/gameplay/programs/ProgramService.gd",
    APP / "src/gameplay/programs/programs.json",
    APP / "src/ui/screens/ProgramsScreen.gd",
    APP / "tests/runtime/test_phase4_product_experience.gd",
    APP / "tests/runtime/verify_phase4_product_architecture.py",
    DOCS / "product/PHASE_5_PREPARATION_REPORT.md",
    DOCS / "product/challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md",
    DOCS / "product/challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md",
    DOCS / "product/challenge-types/SPOT_THE_DIFFERENCE_SPEC.md",
    DOCS / "product/challenge-types/OBJECT_RECALL_SPEC.md",
    DOCS / "product/challenge-types/PATTERN_RECALL_SPEC.md",
    DOCS / "product/INTERACTION_ADAPTER_CONTRACT.md",
    DOCS / "product/PHASE_5_COMPLETION.md",
    DOCS / "product/PHASE_5_INTERACTION_BASELINE.json",
    DOCS / "product/PHASE_5_5_CONTENT_QUALITY_COMPLETION.md",
    DOCS / "product/PHASE_5_5_REPLAY_QUALITY_AUDIT.md",
    DOCS / "product/PHASE_5_5_PLATFORM_FREEZE_BASELINE.json",
    APP / "tests/runtime/test_phase55_replay_quality.gd",
    APP / "tests/runtime/verify_phase55_content_quality.py",
    DOCS / "product/PHASE_6_PRODUCTION_READINESS_COMPLETION.md",
    DOCS / "product/PHASE_6_PLATFORM_BASELINE.json",
    DOCS / "store/OPEN_SOURCE_NOTICES.md",
    DOCS / "store/FINAL_RELEASE_CHECKLIST.md",
    APP / "tests/runtime/test_phase6_persistence_performance.gd",
    APP / "tests/runtime/test_phase6_product_pass.gd",
    APP / "tests/runtime/verify_phase6_production_readiness.py",
    APP / "tests/runtime/verify_phase5_preparation.py",
    APP / "tests/runtime/test_phase5_interaction_system.gd",
    APP / "tests/runtime/test_phase5_challenge_types.gd",
    APP / "tests/runtime/test_phase5_stress.gd",
    APP / "tests/runtime/verify_phase5_architecture.py",
    APP / "tests/runtime/verify_phase5_content.py",
    APP / "tests/runtime/verify_phase5_interaction_baseline.py",
]
for path in required:
    if not path.exists():
        errors.append(f"required Gate 1 deliverable missing: {path.relative_to(ROOT)}")

if errors:
    for error in errors:
        print(f"DOCUMENTATION FAIL: {error}")
    raise SystemExit(1)

print(f"DOCUMENTATION_CONSISTENCY_PASS markdown_files={len(markdown_files)}")

#!/usr/bin/env python3
"""Static Phase 2 Gate 1 architecture checks."""

from __future__ import annotations

import json
import re
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
RUNTIME = APP / "src/gameplay/runtime"
UI = APP / "src/ui"
FAMILY_MANIFEST = APP / "src/gameplay/families/manifest.json"
PROJECT = APP / "project.godot"

errors: list[str] = []
manifest = json.loads(FAMILY_MANIFEST.read_text())
family_ids = [str(entry["id"]) for entry in manifest.get("families", [])]

runtime_text = "\n".join(path.read_text() for path in RUNTIME.glob("*.gd"))
for family_id in family_ids:
    if family_id in runtime_text:
        errors.append(f"shared runtime contains concrete family id: {family_id}")

for forbidden in ("SceneInvestigation", "challenge_01", "challenge_02", "challenge_03", "challenge_04", "challenge_05"):
    if forbidden in runtime_text:
        errors.append(f"shared runtime contains family/fixture identifier: {forbidden}")

if re.search(r'(preload|load)\("res://src/gameplay/families/', runtime_text):
    errors.append("shared runtime imports a concrete family implementation")

for entry in manifest.get("families", []):
    module_path = str(entry.get("module_script", ""))
    if not module_path.startswith("res://"):
        errors.append(f"family module path is not res:// based: {module_path}")
        continue
    local_path = APP / module_path.removeprefix("res://")
    if not local_path.exists():
        errors.append(f"family module does not exist: {module_path}")

ui_text = "\n".join(path.read_text() for path in UI.rglob("*.gd"))
if re.search(r'ChallengeRegistry\.(start_run|launch_challenge|replay_current|go_to_next_challenge)', ui_text):
    errors.append("player-facing UI calls a legacy ChallengeRegistry launch method")
if re.search(r'navigate_to\("(observation|memory_question|result)"', ui_text):
    errors.append("player-facing UI directly navigates between gameplay routes")

shared_tutorial_files = [
    UI / "screens/TutorialScreen.gd",
    UI / "screens/TitleSplashScreen.gd",
    UI / "screens/ExperiencesScreen.gd",
]
shared_tutorial_text = "\n".join(path.read_text() for path in shared_tutorial_files)
for forbidden in ("scene_investigation", "office_v1", "flash_words", "single_word_v1"):
    if forbidden in shared_tutorial_text:
        errors.append(f"shared tutorial/onboarding UI contains family-specific identifier: {forbidden}")

session_text = (RUNTIME / "ChallengeSessionService.gd").read_text()
for method in (
    "start_recommended_session",
    "start_template_session",
    "start_family_session",
    "advance_to_response",
    "submit_response",
    "present_result",
    "replay_current",
    "continue_recommended",
    "return_home",
):
    if not re.search(rf"^func {method}\(", session_text, flags=re.MULTILINE):
        errors.append(f"frozen ChallengeSessionService API method missing: {method}")

family_module_text = (RUNTIME / "ChallengeFamilyModule.gd").read_text()
if not re.search(r"^func get_scoring_policy\(", family_module_text, flags=re.MULTILINE):
    errors.append("ChallengeFamilyModule is missing family-owned ScoringPolicy")
if not re.search(r"^func get_tutorial_profile\(", family_module_text, flags=re.MULTILINE):
    errors.append("ChallengeFamilyModule is missing family-owned TutorialProfile")
if not (APP / "src/gameplay/contracts/TutorialProfile.gd").exists():
    errors.append("TutorialProfile contract is missing")

scoring_text = (RUNTIME / "ScoringPolicy.gd").read_text()
for method in ("calculate_result", "calculate_score", "calculate_progress", "calculate_mastery_change", "explain_outcome"):
    if not re.search(rf"^func {method}\(", scoring_text, flags=re.MULTILINE):
        errors.append(f"ScoringPolicy method missing: {method}")

registry_text = (RUNTIME / "ChallengeFamilyRegistry.gd").read_text()
for method in ("register_module", "unregister_family", "get_visible_family_ids", "get_module", "find_family_id_for_template"):
    if not re.search(rf"^func {method}\(", registry_text, flags=re.MULTILINE):
        errors.append(f"frozen ChallengeFamilyRegistry API method missing: {method}")

if any(str(entry.get("id", "")).startswith("synthetic_") for entry in manifest.get("families", [])):
    errors.append("synthetic test family leaked into production family manifest")

project_text = PROJECT.read_text()
for autoload in (
    "ChallengeFamilyRegistry",
    "PlayerProgressService",
    "RecommendationService",
    "ResultService",
    "ChallengeSessionService",
):
    if f'{autoload}="*res://' not in project_text:
        errors.append(f"required runtime autoload missing: {autoload}")

if errors:
    for error in errors:
        print(f"ARCHITECTURE FAIL: {error}")
    raise SystemExit(1)

print("RUNTIME_ARCHITECTURE_PASS")
print(f"registered_families={len(family_ids)} runtime_files={len(list(RUNTIME.glob('*.gd')))}")

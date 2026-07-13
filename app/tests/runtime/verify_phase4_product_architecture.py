#!/usr/bin/env python3
"""Static architecture and product checks for Phase 4."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
SRC = APP / "src"
errors: list[str] = []

manifest = json.loads((SRC / "gameplay/families/manifest.json").read_text())
family_ids = {str(entry.get("id", "")) for entry in manifest.get("families", [])}
program_service = (SRC / "gameplay/programs/ProgramService.gd").read_text()
program_screen = (SRC / "ui/screens/ProgramsScreen.gd").read_text()
program_text = program_service + "\n" + program_screen
for family_id in family_ids:
    if family_id and family_id in program_text:
        errors.append(f"Programs hardcode a concrete family ID: {family_id}")

program_data = json.loads((SRC / "gameplay/programs/programs.json").read_text())
programs = program_data.get("programs", [])
required_programs = {
    "Daily Witness",
    "Observation Bootcamp",
    "Rapid Recall",
    "Mixed Rotation",
    "Favorites Run",
    "Weekend Challenge",
}
actual_programs = {str(item.get("title", "")) for item in programs}
if not required_programs <= actual_programs:
    errors.append(f"Original Program catalog entries missing: {sorted(required_programs - actual_programs)}")
for item in programs:
    for field in ("id", "title", "description", "selection_policy", "round_count", "required_level"):
        if field not in item:
            errors.append(f"Program {item.get('id', '?')} missing {field}")
    if int(item.get("round_count", 0)) <= 0:
        errors.append(f"Program {item.get('id', '?')} has no finite round count")

session = (SRC / "gameplay/runtime/ChallengeSessionService.gd").read_text()
for required in (
    "start_program_session",
    "ProgramService.recommend_for_program",
    "ProgramService.record_result",
    '"session_context"',
    '"program_complete"',
):
    if required not in session:
        errors.append(f"ChallengeSessionService Program integration missing: {required}")
if re.search(r'navigate_to\("(observation|memory_question|result)"', program_text):
    errors.append("Programs bypass ChallengeSessionService gameplay routing")

project = (APP / "project.godot").read_text()
boot = (SRC / "core/app/AppBoot.gd").read_text()
if 'ProgramService="*res://' not in project:
    errors.append("ProgramService autoload is missing")
if "ProgramService.initialize()" not in boot:
    errors.append("ProgramService boot initialization is missing")

routes = (SRC / "core/navigation/AppRoutes.gd").read_text()
shell = (SRC / "ui/shell/AppShell.gd").read_text()
if '"programs": {' not in routes:
    errors.append("Programs route is missing")
if '"programs":        "res://src/ui/screens/ProgramsScreen.tscn"' not in shell:
    errors.append("AppShell Programs mapping is missing")

home = (SRC / "ui/screens/HomeScreen.gd").read_text() + (SRC / "ui/screens/HomeScreen.tscn").read_text()
for required in ("ProgramsButton", 'navigate_to("programs")', "PROGRAMS · CURATED RUNS"):
    if required not in home:
        errors.append(f"Home Programs entry missing: {required}")
if "PROGRAMS · COMING SOON" in home:
    errors.append("Home still presents Programs as Coming Soon")

card = (SRC / "ui/components/ExperienceCard.gd").read_text() + (SRC / "ui/components/ExperienceCard.tscn").read_text()
for required in ("FavoriteButton", "favorite_toggled", "favorite"):
    if required not in card:
        errors.append(f"Challenge Type favorite integration missing: {required}")

profile = (SRC / "ui/screens/ProfileScreen.gd").read_text() + (SRC / "ui/screens/ProfileScreen.tscn").read_text()
for required in (
    "WITNESS RECORD",
    "RecentlyPlayed",
    "FavoritesList",
    "ProgramSummary",
    "COLLECTION PROGRESS",
    "Challenge Types discovered",
    "Curated runs completed",
):
    if required not in profile:
        errors.append(f"Profile lifecycle surface missing: {required}")

achievement_data = json.loads((SRC / "gameplay/progression/achievements.json").read_text())
achievement_titles = {str(item.get("title", "")) for item in achievement_data.get("achievements", [])}
for title in ("Versatile Witness", "Curator", "First Journey", "All Angles"):
    if title not in achievement_titles:
        errors.append(f"Phase 4 achievement missing: {title}")

recommendations = (SRC / "gameplay/runtime/RecommendationService.gd").read_text()
for required in ("gameplay_focus", "recommendation_weight", "favorite", "featured_program"):
    if required not in recommendations:
        errors.append(f"Recommendation/catalog Phase 4 field missing: {required}")
for family_path in (
    SRC / "gameplay/families/scene_investigation/SceneInvestigationFamily.gd",
    SRC / "gameplay/families/flash_words/FlashWordsFamily.gd",
):
    if "recommendation_weight" not in family_path.read_text():
        errors.append(f"family recommendation weight missing: {family_path.relative_to(ROOT)}")

player_copy_paths = [
    SRC / "ui/screens/HomeScreen.gd",
    SRC / "ui/screens/HomeScreen.tscn",
    SRC / "ui/screens/ProgramsScreen.gd",
    SRC / "ui/screens/ProgramsScreen.tscn",
    SRC / "ui/components/ProgramCard.gd",
    SRC / "ui/components/ProgramCard.tscn",
    SRC / "ui/screens/ProfileScreen.gd",
    SRC / "ui/screens/ProfileScreen.tscn",
    SRC / "gameplay/programs/programs.json",
]
player_copy = "\n".join(path.read_text() for path in player_copy_paths)
for prohibited in ("cognitive", "brain training", "assessment", "evaluation", "diagnostic", "IQ", "learning path"):
    if re.search(rf"\b{re.escape(prohibited)}\b", player_copy, flags=re.IGNORECASE):
        errors.append(f"prohibited player-facing language in Phase 4: {prohibited}")

required_files = [
    SRC / "gameplay/programs/ProgramService.gd",
    SRC / "gameplay/programs/programs.json",
    SRC / "ui/components/ProgramCard.gd",
    SRC / "ui/components/ProgramCard.tscn",
    SRC / "ui/screens/ProgramsScreen.gd",
    SRC / "ui/screens/ProgramsScreen.tscn",
    APP / "tests/runtime/test_phase4_product_experience.gd",
]
for path in required_files:
    if not path.exists():
        errors.append(f"Phase 4 file missing: {path.relative_to(ROOT)}")

if errors:
    for error in errors:
        print(f"PHASE4 ARCHITECTURE FAIL: {error}")
    raise SystemExit(1)

print("PHASE4_PRODUCT_ARCHITECTURE_PASS")
print(f"programs={len(programs)} achievements={len(achievement_titles)} families={len(family_ids)}")

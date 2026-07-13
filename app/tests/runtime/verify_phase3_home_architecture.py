#!/usr/bin/env python3
"""Static architecture and product checks for Phase 3 — Home Experience."""

from __future__ import annotations

import json
import re
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
SRC = APP / "src"
errors: list[str] = []

home_paths = [SRC / "ui/screens/HomeScreen.gd", SRC / "ui/screens/HomeScreen.tscn"]
home_text = "\n".join(path.read_text() for path in home_paths)
manifest = json.loads((SRC / "gameplay/families/manifest.json").read_text())
visible_family_scripts: list[Path] = []
for entry in manifest.get("families", []):
    script_path = APP / str(entry.get("module_script", "")).removeprefix("res://")
    if script_path.exists() and '"player_visible": false' not in script_path.read_text():
        visible_family_scripts.append(script_path)

for script_path in visible_family_scripts:
    script_text = script_path.read_text()
    family_match = re.search(r'const FAMILY_ID: String = "([^"]+)"', script_text)
    title_match = re.search(r'"title": "([^"]+)"', script_text)
    for concrete in (
        family_match.group(1) if family_match else "",
        title_match.group(1) if title_match else "",
    ):
        if concrete and concrete.lower() in home_text.lower():
            errors.append(f"Home hardcodes concrete Challenge Type data: {concrete}")

for forbidden_dependency in ("ChallengeFamilyRegistry", "FlashWords", "SceneInvestigation"):
    if forbidden_dependency in home_text:
        errors.append(f"Home depends on concrete catalog implementation: {forbidden_dependency}")

home_gd = home_paths[0].read_text()
for required_call in (
    "RecommendationService.get_home_snapshot",
    'start_recommended_session("play_now")',
    'start_continue_session("continue")',
    'navigate_to("experiences")',
    'navigate_to("achievements")',
    'navigate_to("profile")',
    'navigate_to("settings")',
):
    if required_call not in home_gd:
        errors.append(f"Home integration missing: {required_call}")

for required_copy in (
    "PLAY NOW",
    "CONTINUE",
    "CHALLENGE LIBRARY",
    "ACHIEVEMENTS",
    "PROFILE",
    "SETTINGS",
    "PROGRAMS",
):
    if required_copy not in home_text:
        errors.append(f"Home surface missing: {required_copy}")

recommendation_text = (SRC / "gameplay/runtime/RecommendationService.gd").read_text()
for method in (
    "recommend_start",
    "recommend_continue",
    "recommend_featured",
    "get_available_challenge_types",
    "get_home_snapshot",
):
    if not re.search(rf"^func {method}\(", recommendation_text, flags=re.MULTILINE):
        errors.append(f"RecommendationService missing Phase 3 API: {method}")
for entry in manifest.get("families", []):
    family_id = str(entry.get("id", ""))
    if family_id and family_id in recommendation_text:
        errors.append(f"RecommendationService hardcodes family ID: {family_id}")

session_text = (SRC / "gameplay/runtime/ChallengeSessionService.gd").read_text()
if not re.search(r"^func start_continue_session\(", session_text, flags=re.MULTILINE):
    errors.append("ChallengeSessionService is missing start_continue_session")
if "RecommendationService.recommend_continue" not in session_text:
    errors.append("Continue does not resolve through RecommendationService")

library_text = (SRC / "ui/screens/ExperiencesScreen.gd").read_text()
if "RecommendationService.get_available_challenge_types" not in library_text:
    errors.append("Challenge Library is not catalog-data-driven")
for entry in manifest.get("families", []):
    family_id = str(entry.get("id", ""))
    if family_id and family_id in library_text:
        errors.append(f"Challenge Library hardcodes family ID: {family_id}")

card_text = "\n".join(
    (SRC / f"ui/components/{name}").read_text()
    for name in ("ExperienceCard.gd", "ExperienceCard.tscn")
)
for required in (
    "Artwork",
    "Witness Level",
    "Mastery",
    "progress_points",
    "accuracy",
    "Best streak",
    "REPLAY TUTORIAL",
):
    if required not in card_text:
        errors.append(f"Challenge Type card missing product field: {required}")

achievement_path = SRC / "gameplay/progression/achievements.json"
achievement_data = json.loads(achievement_path.read_text())
expected_achievements = {
    "First Witness",
    "Keen Eye",
    "Perfect Memory",
    "Sharp Shooter",
    "Word Watcher",
    "Scene Specialist",
    "Consistency",
    "Comeback",
    "Marathon",
    "Flawless Finish",
}
actual_achievements = {
    str(definition.get("title", ""))
    for definition in achievement_data.get("achievements", [])
}
if not expected_achievements.issubset(actual_achievements):
    errors.append(
        "Original achievement catalog is incomplete: "
        f"missing={sorted(expected_achievements - actual_achievements)}"
    )

project_text = (APP / "project.godot").read_text()
boot_text = (SRC / "core/app/AppBoot.gd").read_text()
if 'AchievementService="*res://' not in project_text:
    errors.append("AchievementService autoload is missing")
if "AchievementService.initialize()" not in boot_text:
    errors.append("AchievementService is not boot-initialized")

routes_text = (SRC / "core/navigation/AppRoutes.gd").read_text()
shell_text = (SRC / "ui/shell/AppShell.gd").read_text()
navigation_text = (SRC / "core/navigation/NavigationService.gd").read_text()
if '"achievements": {' not in routes_text:
    errors.append("Achievements route definition is missing")
if '"achievements":    "res://src/ui/screens/AchievementsScreen.tscn"' not in shell_text:
    errors.append("AppShell does not map the Achievements screen")
if '"achievements":\n\t\t\tAppState.set_phase(AppState.AppPhase.ACHIEVEMENTS)' not in navigation_text:
    errors.append("Achievements route does not update app phase")

profile_text = "\n".join(
    (SRC / f"ui/screens/{name}").read_text()
    for name in ("ProfileScreen.gd", "ProfileScreen.tscn")
)
for required in (
    "Witness Level",
    "witness_rank",
    "WITNESS RECORD",
    "Accuracy",
    "Fastest Response",
    "Current Streak",
    "Best Streak",
    "CHALLENGE HISTORY",
    "CHALLENGE TYPE MASTERY",
    "ACHIEVEMENTS",
    "COLLECTIONS",
):
    if required not in profile_text:
        errors.append(f"Profile surface missing: {required}")

settings_text = "\n".join(
    (SRC / f"ui/screens/{name}").read_text()
    for name in ("SettingsScreen.gd", "SettingsScreen.tscn")
)
for required in (
    "Audio",
    "Music",
    "Haptics",
    "Reading Comfort Mode",
    "Text Size",
    "Reduced Motion",
    "High Contrast",
    "Privacy",
    "Credits",
    "About",
):
    if required not in settings_text:
        errors.append(f"Settings surface missing: {required}")

player_copy_files = [
    SRC / "ui/screens/HomeScreen.gd",
    SRC / "ui/screens/HomeScreen.tscn",
    SRC / "ui/screens/ExperiencesScreen.gd",
    SRC / "ui/screens/ProfileScreen.gd",
    SRC / "ui/screens/SettingsScreen.gd",
]
for path in player_copy_files:
    text = path.read_text()
    for prohibited in ("cognitive", "brain training", "IQ", "assessment", "evaluation", "diagnostic"):
        if re.search(rf"\b{re.escape(prohibited)}\b", text, flags=re.IGNORECASE):
            errors.append(f"assessment-oriented player copy in {path.relative_to(APP)}: {prohibited}")

if errors:
    for error in errors:
        print(f"PHASE3 ARCHITECTURE FAIL: {error}")
    raise SystemExit(1)

print("PHASE3_HOME_ARCHITECTURE_PASS")
print(f"challenge_types={len(visible_family_scripts)} achievements={len(actual_achievements)}")

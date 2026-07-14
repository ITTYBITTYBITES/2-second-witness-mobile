#!/usr/bin/env python3
"""Static acceptance checks for the production gameplay immersion pass."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SRC = ROOT / "app" / "src"
errors: list[str] = []

shell = (SRC / "ui/shell/AppShell.gd").read_text()
observation = (SRC / "ui/screens/ObservationChallengeScreen.gd").read_text()
observation_scene = (SRC / "ui/screens/ObservationChallengeScreen.tscn").read_text()
recall = (SRC / "ui/screens/MemoryQuestionScreen.gd").read_text()
recall_scene = (SRC / "ui/screens/MemoryQuestionScreen.tscn").read_text()
result = (SRC / "ui/screens/ResultScreen.gd").read_text()
result_scene = (SRC / "ui/screens/ResultScreen.tscn").read_text()
exit_control = (SRC / "ui/components/GameplayExitButton.gd").read_text()

if "top_bar.visible = not is_splash and not is_gameplay" not in shell:
    errors.append("generic app top bar remains visible during active gameplay")
if "nav_bar.visible = is_tab and not is_splash and not is_gameplay" not in shell:
    errors.append("tab navigation is not explicitly hidden during gameplay")

for name, scene in (("observation", observation_scene), ("recall", recall_scene)):
    if "GameplayExitButton.gd" not in scene or 'node name="ExitButton"' not in scene:
        errors.append(f"{name} phase lacks its always-available exit control")
    if "custom_minimum_size = Vector2(48, 48)" not in exit_control:
        errors.append("gameplay exit control is not touch-safe")
if "ConfirmationDialog" not in exit_control or "KEEP PLAYING" not in exit_control:
    errors.append("gameplay exit does not protect against accidental taps")
if "ChallengeSessionService.return_home()" not in exit_control:
    errors.append("gameplay exit does not provide a complete return path")

for marker in (
    "HUD/CountdownLabel",
    'text = "OBSERVE"',
    "size_flags_vertical = 3",
    "The stage is a clipping boundary",
):
    if marker not in observation + observation_scene:
        errors.append(f"immersive observation surface missing: {marker}")
for marker in (
    "QuestionAccent",
    "_family_title",
    "_family_accent",
    "_style_interaction_tree",
    "ResponsiveLayout.enforce_touch_targets",
):
    if marker not in recall + recall_scene:
        errors.append(f"focused recall surface missing: {marker}")

for action in (
    "ContinueButton",
    "ReplayButton",
    "LibraryButton",
    "MenuButton",
):
    if action not in result_scene:
        errors.append(f"result destination missing: {action}")
for marker in (
    "ProgressSummary",
    "EVIDENCE & REFLECTION",
    "RETRY CHALLENGE",
    "CHALLENGE LIBRARY",
    "RETURN HOME",
    'navigate_to("experiences")',
):
    if marker not in result + result_scene:
        errors.append(f"reflective result state missing: {marker}")

family_views = {
    "scene_investigation": SRC / "gameplay/families/scene_investigation/SceneInvestigationSceneView.gd",
    "flash_words": SRC / "gameplay/families/flash_words/FlashWordsSceneView.gd",
    "spot_the_difference": SRC / "gameplay/families/spot_the_difference/SpotDifferenceView.gd",
    "object_recall": SRC / "gameplay/families/object_recall/ObjectRecallView.gd",
    "pattern_recall": SRC / "gameplay/families/pattern_recall/PatternRecallView.gd",
}
for family_id, path in family_views.items():
    text = path.read_text()
    if "set_scene_data" not in text:
        errors.append(f"family presentation binding missing: {family_id}")
    if "is_high_contrast_enabled" not in text:
        errors.append(f"high-contrast presentation missing: {family_id}")

identity_markers = {
    "flash_words": "FlashWordFocusField",
    "spot_the_difference": "panel_height: float = size.y * 0.88",
    "object_recall": "Objects sit directly in the environment",
    "pattern_recall": "size.x * 0.88",
}
for family_id, marker in identity_markers.items():
    if marker not in family_views[family_id].read_text():
        errors.append(f"family immersion treatment missing: {family_id}")

if errors:
    for error in errors:
        print("GAMEPLAY_IMMERSION_FAIL:", error)
    raise SystemExit(1)

print("GAMEPLAY_IMMERSION_PASS")
print(f"families={len(family_views)} active_phases=2 result_actions=4")

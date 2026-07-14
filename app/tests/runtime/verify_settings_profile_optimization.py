#!/usr/bin/env python3
"""Static acceptance checks for the production Settings and Profile UX pass."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCREENS = ROOT / "app" / "src" / "ui" / "screens"
settings = (SCREENS / "SettingsScreen.gd").read_text()
settings_scene = (SCREENS / "SettingsScreen.tscn").read_text()
profile = (SCREENS / "ProfileScreen.gd").read_text()
profile_scene = (SCREENS / "ProfileScreen.tscn").read_text()
errors: list[str] = []

# Every retained control must continue to use the existing persisted key.
required_setting_keys = {
    "theme_mode",
    "reduced_motion",
    "font_scale",
    "volume_master",
    "volume_bgm",
    "volume_sfx",
    "volume_ui",
    "mute_master",
    "haptics_enabled",
    "reading_comfort_mode",
    "high_contrast",
    "color_assist_mode",
    "accessibility_screen_reader_hints",
    "show_tutorials",
    "comfortable_timing",
    "analytics_enabled",
}
for key in required_setting_keys:
    if f'"{key}"' not in settings:
        errors.append(f"retained setting lost its persisted key: {key}")

for label in (
    "More Observation Time",
    "Assistive Controls",
    "On-device Activity",
    "About, Privacy & Credits",
    "Restore Default Settings",
):
    if label not in settings:
        errors.append(f"production settings copy missing: {label}")

for technical_row in ('"Package ID"', '"Build"', '"Engine"', '"App Version"'):
    if technical_row in settings or technical_row in settings_scene:
        errors.append(f"technical row remains on main Settings: {technical_row}")
if "Nothing is uploaded" not in settings or "turning this off clears the log" not in settings:
    errors.append("on-device activity control does not explain its privacy behavior")
if "ConfirmationDialog" not in settings or "Witness Progress stays intact" not in settings:
    errors.append("settings reset is not clearly confirmed and progress-safe")

# Profile should lead with identity and progression, without exposing an internal ID.
for marker in (
    "YOUR WITNESS PROFILE",
    "WITNESS PROGRESS",
    "WITNESS RECORD",
    "CHALLENGE TYPE MASTERY",
    "EXPLORE ACHIEVEMENTS",
    "Missed detail",
):
    if marker not in profile + profile_scene:
        errors.append(f"optimized Profile marker missing: {marker}")
if "IdLabel" in profile_scene or "id_label" in profile:
    errors.append("internal Witness ID remains on Profile")
if '"Fastest Response"' in profile or '"Current Streak"' in profile:
    errors.append("secondary record metrics remain in the visible Profile definitions")
if 'get_recent_history(6)' not in profile:
    errors.append("recent history was not reduced to a mobile-friendly limit")

# Redundant or speculative sections remain in the scene only as hidden compatibility
# bindings; they must never reappear in production UI without a deliberate decision.
for node_name in (
    "RecentlyPlayedHeader",
    "RecentlyPlayed",
    "FavoritesHeader",
    "FavoritesList",
    "CollectionsHeader",
    "CollectionsCard",
):
    pattern = rf'\[node name="{node_name}"[^\]]*\]\nvisible = false'
    if not re.search(pattern, profile_scene):
        errors.append(f"secondary Profile section is not explicitly hidden: {node_name}")

if 'node name="ResetButton"' in profile_scene:
    errors.append("debug reset ships as a Profile scene control")
if "if OS.is_debug_build():\n\t\t_create_debug_reset_button()" not in profile:
    errors.append("debug reset is not gated behind a debug-build check")
if "if not OS.is_debug_build():\n\t\treturn" not in profile:
    errors.append("debug reset handler lacks a release-build guard")

if errors:
    for error in errors:
        print("SETTINGS_PROFILE_OPTIMIZATION_FAIL:", error)
    raise SystemExit(1)

print("SETTINGS_PROFILE_OPTIMIZATION_PASS")
print(f"persisted_settings={len(required_setting_keys)} profile_priority_sections=5")

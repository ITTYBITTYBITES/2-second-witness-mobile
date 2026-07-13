#!/usr/bin/env python3
"""Static production-readiness and frozen-architecture verification."""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
SRC = APP / "src"
DOCS = ROOT / "docs"
errors: list[str] = []

manifest = json.loads((SRC / "gameplay/families/manifest.json").read_text())
visible = [item.get("id") for item in manifest.get("families", []) if item.get("content_role") == "production"]
expected_visible = ["scene_investigation", "flash_words", "spot_the_difference", "object_recall", "pattern_recall"]
if visible != expected_visible:
    errors.append(f"production family portfolio changed: {visible}")
for deferred in ("motion_tracking", "hidden_detail", "color_recall", "direction_recall", "symbol_recognition", "number_recall", "sound_recognition"):
    if (SRC / "gameplay/families" / deferred).exists():
        errors.append(f"deferred family was implemented: {deferred}")

# Frozen architecture remains family-agnostic even where production defects were corrected.
shared_paths = [SRC / "gameplay/runtime", SRC / "gameplay/interactions", SRC / "core", SRC / "systems"]
shared_paths += [SRC / "ui/screens/HomeScreen.gd", SRC / "ui/screens/ExperiencesScreen.gd", SRC / "ui/screens/ProfileScreen.gd", SRC / "ui/screens/ProgramsScreen.gd"]
shared_text_parts: list[str] = []
for entry in shared_paths:
    paths = [entry] if entry.is_file() else list(entry.rglob("*.gd"))
    shared_text_parts.extend(path.read_text() for path in paths)
shared_text = "\n".join(shared_text_parts)
for family_id in expected_visible:
    if family_id in shared_text:
        errors.append(f"frozen shared platform contains family identifier: {family_id}")

save_text = (SRC / "systems/save/SaveService.gd").read_text()
for marker in ("TEMP_SUFFIX", "BACKUP_SUFFIX", "Temporary save verification failed", "_recover_backup", "display_name"):
    if marker not in save_text:
        errors.append(f"atomic save/recovery marker missing: {marker}")
profile_text = (SRC / "systems/save/ProfileService.gd").read_text()
if "_merge_dictionary" not in profile_text:
    errors.append("nested profile defaults are not migration-safe")

analytics_text = (SRC / "systems/analytics/AnalyticsService.gd").read_text()
for marker in ("MAX_BUFFER_FILE_BYTES", "if not _is_enabled", "clear_buffer()", "_buffer_file_size"):
    if marker not in analytics_text:
        errors.append(f"local analytics readiness marker missing: {marker}")
audio_text = (SRC / "systems/audio/AudioService.gd").read_text()
for marker in ("PACKAGED_SOUND_IDS", "_stream_cache", "_preload_packaged_sounds", "if not _initialized", "mute_master"):
    if marker not in audio_text:
        errors.append(f"audio readiness marker missing: {marker}")

config_text = (SRC / "systems/config/ConfigService.gd").read_text()
for marker in ('"environment": "production"', '"auto_update": false', '"base_url": ""'):
    if marker not in config_text:
        errors.append(f"offline production configuration missing: {marker}")
export_text = (APP / "export_presets.cfg").read_text()
for marker in (
    'permissions/internet=false',
    'permissions/access_network_state=false',
    'permissions/vibrate=true',
    'screen/orientation=1',
    '"[splash]android:windowSplashScreenBackground": "#0E0E14"',
    '"[splash]windowSplashScreenAnimatedIcon": "@android:color/transparent"',
):
    if marker not in export_text:
        errors.append(f"Android readiness setting missing: {marker}")
project = (APP / "project.godot").read_text()
for marker in ('window/handheld/orientation=1', 'renderer/rendering_method.mobile="gl_compatibility"', 'rendering_device/driver.android="opengl3"'):
    if marker not in project:
        errors.append(f"project mobile setting missing: {marker}")

shell = (SRC / "ui/shell/AppShell.gd").read_text()
for marker in ("CACHEABLE_ROUTES", "_retire_current_screen", "_record_screen_presented", "_on_session_failed"):
    if marker not in shell:
        errors.append(f"screen lifecycle polish missing: {marker}")
cache_match = re.search(r"const CACHEABLE_ROUTES[^=]*=\s*\[(.*?)\]", shell, re.S)
if cache_match and any(route in cache_match.group(1) for route in ("observation", "memory_question", "result", "tutorial")):
    errors.append("heavy gameplay/tutorial routes remain permanently cached")

screen_names = {
    "PublisherSplashScreen", "TitleSplashScreen", "HomeScreen", "ProgramsScreen",
    "ExperiencesScreen", "AchievementsScreen", "ProfileScreen", "SettingsScreen",
    "AboutScreen", "TutorialScreen", "ObservationChallengeScreen",
    "MemoryQuestionScreen", "ResultScreen",
}
for name in screen_names:
    if not (SRC / "ui/screens" / f"{name}.tscn").exists():
        errors.append(f"production screen missing: {name}")
for name in ("HomeScreen", "ProgramsScreen", "ExperiencesScreen", "AchievementsScreen", "ProfileScreen", "SettingsScreen", "AboutScreen", "ObservationChallengeScreen", "MemoryQuestionScreen", "ResultScreen"):
    text = (SRC / "ui/screens" / f"{name}.gd").read_text()
    if "ResponsiveLayout.apply_centered_margin" not in text:
        errors.append(f"responsive layout missing from {name}")

settings_text = (SRC / "ui/screens/SettingsScreen.gd").read_text()
for marker in (
    "SETTING_HELP", "Interface Sounds", "Mute All Audio", "Offline Play",
    "ConfirmationDialog", "comfortable_timing", "reading_comfort_mode",
    "high_contrast", "color_assist_mode", "reduced_motion",
):
    if marker not in settings_text:
        errors.append(f"production settings surface missing: {marker}")
if "Crash Reporting" in settings_text or "Auto Play Next" in settings_text:
    errors.append("unused player-facing settings remain visible")

memory_text = (SRC / "ui/screens/MemoryQuestionScreen.gd").read_text()
for marker in ("_style_interaction_tree", "ResponsiveLayout.enforce_touch_targets", "get_animation_duration(0.25)"):
    if marker not in memory_text:
        errors.append(f"interaction polish missing: {marker}")
multiple_text = (SRC / "gameplay/interactions/adapters/MultipleChoiceAdapter.gd").read_text()
for marker in ("selection_count", "Select exactly", "_required_count"):
    if marker not in multiple_text:
        errors.append(f"Multiple Choice usability marker missing: {marker}")
sequence_text = (SRC / "gameplay/interactions/adapters/SequenceInputAdapter.gd").read_text()
if "_selected.clear()" not in sequence_text or "_refresh()" not in sequence_text:
    errors.append("Sequence Input does not reset cleanly on mount")

family_views = [
    SRC / "gameplay/families/scene_investigation/SceneInvestigationSceneView.gd",
    SRC / "gameplay/families/spot_the_difference/SpotDifferenceView.gd",
    SRC / "gameplay/families/object_recall/ObjectRecallView.gd",
    SRC / "gameplay/families/pattern_recall/PatternRecallView.gd",
]
for path in family_views:
    if "is_high_contrast_enabled" not in path.read_text():
        errors.append(f"family renderer lacks explicit High Contrast treatment: {path.name}")
if 'get_value("show_tutorials", true)' not in (SRC / "gameplay/runtime/ChallengeSessionService.gd").read_text():
    errors.append("Show Tutorials preference is not honored by runtime gating")

about_scene = (SRC / "ui/screens/AboutScreen.tscn").read_text()
for marker in ("CreditsSection", "Open-source notices", "Godot Engine is available under the MIT License"):
    if marker not in about_scene:
        errors.append(f"credits/license UI missing: {marker}")
active_ui = "\n".join(path.read_text(errors="ignore") for path in (SRC / "ui").rglob("*.*") if path.suffix in {".gd", ".tscn"})
for prohibited in ("polished placeholder", "privacy policy placeholder", "Museum-quality digital exhibits"):
    if prohibited.lower() in active_ui.lower():
        errors.append(f"active placeholder copy remains: {prohibited}")

phase6_baseline_path = DOCS / "product/PHASE_6_PLATFORM_BASELINE.json"
if phase6_baseline_path.exists():
    phase6_baseline = json.loads(phase6_baseline_path.read_text())
    for relative, expected_hash in phase6_baseline.get("files", {}).items():
        path = ROOT / relative
        if not path.exists() or hashlib.sha256(path.read_bytes()).hexdigest() != expected_hash:
            errors.append(f"Phase 6 platform baseline mismatch: {relative}")

required_phase6 = [
    APP / "tests/runtime/test_phase6_persistence_performance.gd",
    APP / "tests/runtime/test_phase6_product_pass.gd",
    APP / "tests/runtime/verify_phase6_production_readiness.py",
    DOCS / "product/PHASE_6_PLATFORM_BASELINE.json",
    DOCS / "product/PHASE_6_PRODUCTION_READINESS_COMPLETION.md",
    DOCS / "store/OPEN_SOURCE_NOTICES.md",
    DOCS / "store/FINAL_RELEASE_CHECKLIST.md",
    ROOT / "PRIVACY.md",
]
for path in required_phase6:
    if not path.exists():
        errors.append(f"Phase 6 deliverable missing: {path.relative_to(ROOT)}")

if errors:
    for error in errors:
        print("PHASE6 READINESS FAIL:", error.rstrip())
    raise SystemExit(1)
print("PHASE6_PRODUCTION_READINESS_PASS")
print(f"screens={len(screen_names)} families={len(visible)} offline_permissions=3 phase6_tests=2")

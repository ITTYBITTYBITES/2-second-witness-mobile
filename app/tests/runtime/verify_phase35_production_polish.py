#!/usr/bin/env python3
"""Static acceptance checks for Phase 3.5 production polish."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
SRC = APP / "src"
errors: list[str] = []

project = (APP / "project.godot").read_text()
exports = (APP / "export_presets.cfg").read_text()
boot = (SRC / "core/app/AppBoot.gd").read_text()
shell = (SRC / "ui/shell/AppShell.gd").read_text()
theme = (SRC / "systems/theme/ThemeService.gd").read_text()
accessibility = (SRC / "systems/accessibility/AccessibilityService.gd").read_text()
settings = (SRC / "systems/settings/SettingsService.gd").read_text()

if 'boot_splash/image="res://assets/splash/ittybittybites_splash.png"' not in project:
    errors.append("Godot boot splash does not use sponsor artwork")
if 'boot_splash/image="res://assets/brand/app_icon_1024.png"' in project:
    errors.append("app icon remains configured as the engine boot splash")
if 'renderer/rendering_method.mobile="gl_compatibility"' not in project:
    errors.append("Android mobile renderer is not explicitly gl_compatibility")
if 'rendering_device/driver.android="opengl3"' not in project:
    errors.append("Android rendering driver is not explicitly opengl3")
if 'boot_splash/stretch_mode=4' not in project:
    errors.append("sponsor boot artwork does not use full-screen cover mode")
if 'window/handheld/orientation=1' not in project:
    errors.append("project portrait lock is missing")
if exports.count("screen/orientation=1") != 2:
    errors.append("both Android presets must lock portrait orientation")
if exports.count("gradle_build/use_gradle_build=true") != 2:
    errors.append("both Android presets must use Gradle custom builds")
if exports.count('"[splash]windowSplashScreenAnimatedIcon": "@android:color/transparent"') != 2:
    errors.append("Android 12+ system splash icon is not transparent in both presets")
if exports.count('"[splash]android:windowSplashScreenBackground": "#0E0E14"') != 2:
    errors.append("Android system splash background does not match sponsor artwork")

publisher = (SRC / "ui/screens/PublisherSplashScreen.tscn").read_text()
if "SponsorArtwork" not in publisher or "ittybittybites_splash.png" not in publisher:
    errors.append("publisher route does not continue the sponsor artwork")

for service in ("AnalyticsService", "AccessibilityService"):
    if f"{service}.initialize()" not in boot:
        errors.append(f"AppBoot does not initialize {service}")

for required in (
    "scale_safe_area_insets",
    "ResponsiveLayout.enforce_touch_targets",
    "_animate_screen_in",
    "screen_presented",
    "_unhandled_input",
    "Preparing…",
):
    if required not in shell:
        errors.append(f"AppShell production polish missing: {required}")
if "⟳" in shell:
    errors.append("stock rotating loading spinner remains")

responsive_files = [
    SRC / "ui/screens/HomeScreen.gd",
    SRC / "ui/screens/ExperiencesScreen.gd",
    SRC / "ui/screens/ProfileScreen.gd",
    SRC / "ui/screens/ProgramsScreen.gd",
    SRC / "ui/screens/AchievementsScreen.gd",
    SRC / "ui/screens/SettingsScreen.gd",
    SRC / "ui/screens/AboutScreen.gd",
    SRC / "ui/screens/TitleSplashScreen.gd",
    SRC / "ui/screens/MemoryQuestionScreen.gd",
    SRC / "ui/screens/ResultScreen.gd",
    SRC / "ui/screens/ObservationChallengeScreen.gd",
]
for path in responsive_files:
    if "ResponsiveLayout" not in path.read_text():
        errors.append(f"responsive max-width handling missing: {path.relative_to(ROOT)}")

for required in ("get_scaled_size", "high_contrast", "text_secondary", "border_strong"):
    if required not in theme:
        errors.append(f"ThemeService accessibility support missing: {required}")
for required in ("color_assist_mode", "font_scale"):
    if required not in accessibility or required not in settings:
        errors.append(f"persisted accessibility setting missing: {required}")
if "get_animation_duration" not in accessibility:
    errors.append("Reduced Motion animation-duration policy is missing")

player_progress = (SRC / "gameplay/runtime/PlayerProgressService.gd").read_text()
scene_difficulty = (SRC / "gameplay/families/scene_investigation/SceneInvestigationDifficultyPolicy.gd").read_text()
scene_generator = (SRC / "gameplay/families/scene_investigation/SceneInvestigationGenerator.gd").read_text()
for text, label in (
    (player_progress, "player snapshot"),
    (scene_difficulty, "Scene difficulty"),
    (scene_generator, "Scene generator"),
):
    if "color_assist_mode" not in text:
        errors.append(f"Color Assistance is not connected to {label}")

session = (SRC / "gameplay/runtime/ChallengeSessionService.gd").read_text()
if "challenge_prepared" not in session or "duration_ms" not in session:
    errors.append("challenge preparation performance timing is missing")
if "cold_start_services_ready" not in boot:
    errors.append("cold-start performance timing is missing")

size_limit_expectations = {
    APP / "assets/gameplay/featured_desk_scene_landscape.png.import": 1280,
    APP / "assets/gameplay/scene_investigation/office_background.png.import": 1280,
    APP / "assets/gameplay/scene_investigation/kitchen_background.png.import": 1280,
    APP / "assets/gameplay/scene_investigation/workshop_background.png.import": 1280,
    APP / "assets/brand/witness_eye_glow.png.import": 1024,
}
for path, limit in size_limit_expectations.items():
    if f"process/size_limit={limit}" not in path.read_text():
        errors.append(f"runtime texture size limit missing: {path.relative_to(ROOT)}")

required_deliverables = [
    ROOT / "docs/product/PHASE_3_5_PRODUCTION_POLISH_SPEC.md",
    ROOT / "docs/product/PHASE_3_5_DEVICE_VALIDATION_MATRIX.md",
    ROOT / "docs/product/PHASE_3_5_PRODUCTION_AUDIT.md",
    ROOT / "docs/product/PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md",
    APP / "tests/runtime/test_phase35_production_polish.gd",
    APP / "android/README.md",
]
for path in required_deliverables:
    if not path.exists():
        errors.append(f"Phase 3.5 deliverable missing: {path.relative_to(ROOT)}")

ui_text = "\n".join(path.read_text(errors="ignore") for path in (SRC / "ui").rglob("*.gd"))
ui_text += "\n" + "\n".join(path.read_text(errors="ignore") for path in (SRC / "ui").rglob("*.tscn"))
for prohibited in ("cognitive", "brain training", "assessment", "evaluation", "diagnostic"):
    if re.search(rf"\b{re.escape(prohibited)}\b", ui_text, flags=re.IGNORECASE):
        errors.append(f"assessment-oriented player copy remains: {prohibited}")

if errors:
    for error in errors:
        print(f"PHASE35 POLISH FAIL: {error}")
    raise SystemExit(1)

print("PHASE35_PRODUCTION_POLISH_PASS")
print(f"responsive_screens={len(responsive_files)} android_presets=2 texture_limits={len(size_limit_expectations)}")

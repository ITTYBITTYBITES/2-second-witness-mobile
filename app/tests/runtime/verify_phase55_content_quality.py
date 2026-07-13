#!/usr/bin/env python3
"""Static Phase 5.5 content depth, quality, and platform-freeze checks."""

from __future__ import annotations

import hashlib
import json
import re
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
DOCS = ROOT / "docs/product"
errors: list[str] = []

baseline_path = DOCS / "PHASE_5_5_PLATFORM_FREEZE_BASELINE.json"
if not baseline_path.exists():
    errors.append("platform freeze baseline is missing")
else:
    baseline = json.loads(baseline_path.read_text())
    phase6_path = DOCS / "PHASE_6_PLATFORM_BASELINE.json"
    phase6 = json.loads(phase6_path.read_text()) if phase6_path.exists() else {}
    approved_phase6 = set(phase6.get("approved_evolved_files", []))
    phase6_hashes = phase6.get("files", {})
    for relative, expected in baseline.get("files", {}).items():
        path = ROOT / relative
        if not path.exists():
            errors.append(f"frozen platform file removed: {relative}")
            continue
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != expected and not (relative in approved_phase6 and phase6_hashes.get(relative) == actual):
            errors.append(f"frozen platform file changed without Phase 6 record: {relative}")

scene_content = APP / "src/gameplay/families/scene_investigation/content"
scene_files = sorted(scene_content.glob("*.json"))
if len(scene_files) != 5:
    errors.append(f"Scene Investigation has {len(scene_files)} templates instead of 5")
scene_objects = 0
for path in scene_files:
    data = json.loads(path.read_text())
    objects = data.get("objects", [])
    scene_objects += len(objects)
    if len(objects) < 24:
        errors.append(f"{path.name} has fewer than 24 object archetypes")
    image_path = str(data.get("background", {}).get("image_path", ""))
    if not image_path.startswith("res://") or not (APP / image_path.removeprefix("res://")).exists():
        errors.append(f"{path.name} background art is missing")

flash_templates = json.loads((APP / "src/gameplay/families/flash_words/content/templates_v1.json").read_text()).get("templates", [])
flash_words = json.loads((APP / "src/gameplay/families/flash_words/content/words_v1.json").read_text()).get("words", [])
if len(flash_templates) != 4 or not any(item.get("id") == "position_catch_v1" for item in flash_templates):
    errors.append("Flash Words Position Catch expansion is incomplete")
if len(flash_words) < 373:
    errors.append("Flash Words reviewed pool regressed")

spot_source = (APP / "src/gameplay/families/spot_the_difference/SpotDifferenceGenerator.gd").read_text()
spot_objects = set(re.findall(r'\{"id":"([a-z_]+)","name":', spot_source))
for required in ("CONTENT_VERSION := \"spot-difference-v2\"", "target_regions", "state_duration", "_different_color"):
    if required not in spot_source:
        errors.append(f"Spot the Difference quality feature missing: {required}")
if len(spot_objects) < 48:
    errors.append(f"Spot the Difference pool contains only {len(spot_objects)} objects")

object_data = json.loads((APP / "src/gameplay/families/object_recall/content/objects_v2.json").read_text())
object_pool = object_data.get("objects", [])
if len(object_pool) != 48:
    errors.append(f"Object Recall pool contains {len(object_pool)} objects instead of 48")
if len({item.get("kind") for item in object_pool}) < 30:
    errors.append("Object Recall silhouettes are not sufficiently varied")
object_family = (APP / "src/gameplay/families/object_recall/ObjectRecallFamily.gd").read_text()
if "bookends_v1" not in object_family:
    errors.append("Object Recall Bookends template is missing")

pattern_source = (APP / "src/gameplay/families/pattern_recall/PatternRecallGenerator.gd").read_text()
pattern_symbols = set(re.findall(r'\{"token": "([A-Za-z]+)", "kind":', pattern_source))
if len(pattern_symbols) != 12:
    errors.append(f"Pattern Recall has {len(pattern_symbols)} symbols instead of 12")
pattern_family = (APP / "src/gameplay/families/pattern_recall/PatternRecallFamily.gd").read_text()
for style in ("single_step", "symbol_pulse", "cumulative_build"):
    if style not in pattern_family:
        errors.append(f"Pattern Recall template style missing: {style}")

programs = json.loads((APP / "src/gameplay/programs/programs.json").read_text()).get("programs", [])
program_titles = {str(item.get("title", "")) for item in programs}
for title in ("Detail Detective", "Set & Sequence", "Five-Type Tour"):
    if title not in program_titles:
        errors.append(f"expanded Program missing: {title}")
if len(programs) != 9:
    errors.append(f"Program catalog contains {len(programs)} entries instead of 9")

achievements = json.loads((APP / "src/gameplay/progression/achievements.json").read_text()).get("achievements", [])
achievement_titles = {str(item.get("title", "")) for item in achievements}
for title in ("Scene Surveyor", "Word Collector", "Change Tracker", "Set Specialist", "Sequence Specialist", "Five Strong", "Hundred Moments", "Journey Regular"):
    if title not in achievement_titles:
        errors.append(f"expanded achievement missing: {title}")
if len(achievements) != 26:
    errors.append(f"Achievement catalog contains {len(achievements)} entries instead of 26")

for filename in ("difference_switch.wav", "object_settle.wav", "pattern_step.wav"):
    path = APP / "assets/audio" / filename
    if not path.exists():
        errors.append(f"family audio cue missing: {filename}")
        continue
    with wave.open(str(path), "rb") as stream:
        duration = stream.getnframes() / float(stream.getframerate())
        if stream.getnchannels() != 1 or stream.getsampwidth() != 2 or not 0.12 <= duration <= 0.50:
            errors.append(f"family audio cue has invalid production bounds: {filename}")

for filename in ("spot_difference_preview.svg", "object_recall_preview.svg", "pattern_recall_preview.svg"):
    text = (APP / "assets/gameplay" / filename).read_text()
    if "http://www.w3.org/2000/svg" not in text or "href=\"http" in text:
        errors.append(f"preview is not self-contained: {filename}")

contact_sheet = DOCS / "artifacts/phase55_content_quality/phase55_contact_sheet.png"
if not contact_sheet.exists() or contact_sheet.stat().st_size < 10000:
    errors.append("Phase 5.5 visual review contact sheet is missing or empty")

spatial_surface = (APP / "src/gameplay/interactions/adapters/SpatialTapSurface.gd").read_text()
if 'scene_data["interaction_phase"] = "response"' not in spatial_surface:
    errors.append("generic response render-context defect correction is missing")
for forbidden in ("spot_the_difference", "SpotDifference"):
    if forbidden in spatial_surface:
        errors.append(f"response-context correction contains family knowledge: {forbidden}")

if errors:
    for error in errors:
        print(f"PHASE55 QUALITY FAIL: {error}")
    raise SystemExit(1)

print("PHASE55_CONTENT_QUALITY_PASS")
print(
    f"scene_templates={len(scene_files)} scene_objects={scene_objects} "
    f"flash_templates={len(flash_templates)} flash_words={len(flash_words)} "
    f"spot_objects={len(spot_objects)} object_pool={len(object_pool)} "
    f"pattern_symbols={len(pattern_symbols)} programs={len(programs)} achievements={len(achievements)}"
)

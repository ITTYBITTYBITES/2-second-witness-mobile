#!/usr/bin/env python3
"""Static production-content checks for Scene Investigation Gate 3."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
CONTENT = APP / "src/gameplay/families/scene_investigation/content"

expected_templates = {"office_v1", "kitchen_v1", "workshop_v1", "travel_desk_v1", "garden_bench_v1"}
allowed_questions = {"count", "attribute", "position", "adjacency", "presence"}
allowed_colors = {"blue", "sky", "green", "mint", "red", "orange", "yellow", "violet", "brown", "gray", "black", "cream"}
errors: list[str] = []
seen_templates: set[str] = set()

for path in sorted(CONTENT.glob("*.json")):
    data = json.loads(path.read_text())
    template_id = str(data.get("id", ""))
    seen_templates.add(template_id)
    objects = data.get("objects", [])
    if len(objects) < 24:
        errors.append(f"{template_id} has fewer than 24 object archetypes")
    ids = [str(item.get("id", "")) for item in objects]
    names = [str(item.get("name", "")) for item in objects]
    if len(ids) != len(set(ids)) or "" in ids:
        errors.append(f"{template_id} object IDs are missing or duplicated")
    if len(names) != len(set(names)) or "" in names:
        errors.append(f"{template_id} object names are missing or duplicated")
    for item in objects:
        colors = set(map(str, item.get("colors", [])))
        unknown = colors - allowed_colors
        if unknown:
            errors.append(f"{template_id}/{item.get('id')} uses unknown colors: {sorted(unknown)}")
        if not item.get("visual_kind"):
            errors.append(f"{template_id}/{item.get('id')} has no visual_kind")
        if not item.get("groups"):
            errors.append(f"{template_id}/{item.get('id')} has no groups")
    questions = set(map(str, data.get("question_types", [])))
    if len(questions) < 4 or not questions <= allowed_questions:
        errors.append(f"{template_id} question types are incomplete or unsupported: {sorted(questions)}")
    required = set(map(str, data.get("required_groups", [])))
    represented = {str(group) for item in objects for group in item.get("groups", [])}
    if not required <= represented:
        errors.append(f"{template_id} required groups are not represented: {sorted(required - represented)}")
    background = data.get("background", {})
    image_path = str(background.get("image_path", ""))
    if not image_path.startswith("res://"):
        errors.append(f"{template_id} background image path is invalid")
    else:
        local_image = APP / image_path.removeprefix("res://")
        if not local_image.exists():
            errors.append(f"{template_id} background image is missing: {image_path}")
        else:
            try:
                from PIL import Image
                with Image.open(local_image) as image:
                    width, height = image.size
            except ModuleNotFoundError:
                import struct
                header = local_image.read_bytes()
                width, height = struct.unpack('>II', header[16:24])
            if width < 700 or height < 900:
                errors.append(f"{template_id} background resolution is too small: {(width, height)}")
    surface_y = float(background.get("surface_y", 0.0))
    if not 0.25 <= surface_y <= 0.60:
        errors.append(f"{template_id} surface_y is outside approved composition range")

if seen_templates != expected_templates:
    errors.append(f"production template set mismatch: expected={sorted(expected_templates)} actual={sorted(seen_templates)}")

family_root = CONTENT.parent
for deferred in ("museum", "vehicle", "outdoor"):
    if any(deferred in path.name.lower() for path in family_root.rglob("*")):
        errors.append(f"deferred template implementation leaked into Gate 3: {deferred}")

for sound in ("ui_click.wav", "observation_start.wav", "conceal.wav", "reveal_correct.wav", "reveal_incorrect.wav"):
    if not (APP / "assets/audio" / sound).exists():
        errors.append(f"required understated audio asset is missing: {sound}")

if errors:
    for error in errors:
        print(f"CONTENT FAIL: {error}")
    raise SystemExit(1)

print("SCENE_INVESTIGATION_CONTENT_PASS")
print("templates=5 object_archetypes=%d" % sum(len(json.loads(path.read_text()).get("objects", [])) for path in CONTENT.glob("*.json")))

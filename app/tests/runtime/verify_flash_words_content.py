#!/usr/bin/env python3
"""Static production-content validation for Flash Words."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "app"
FAMILY = APP / "src/gameplay/families/flash_words"
words_data = json.loads((FAMILY / "content/words_v1.json").read_text())
templates_data = json.loads((FAMILY / "content/templates_v1.json").read_text())
errors: list[str] = []

words = words_data.get("words", [])
if len(words) < 300:
    errors.append(f"word database contains only {len(words)} words")
ids = [str(entry.get("id", "")) for entry in words]
rendered = [str(entry.get("word", "")) for entry in words]
if len(ids) != len(set(ids)) or "" in ids:
    errors.append("word IDs are missing or duplicated")
if len(rendered) != len(set(rendered)) or "" in rendered:
    errors.append("rendered words are missing or duplicated")
required_metadata = {"length", "frequency", "letter_uniqueness", "visual_similarity_group", "syllable_count", "category", "safe", "orthographic_neighbors"}
prohibited = {"doctor", "disease", "cancer", "court", "legal", "lawyer", "police", "weapon", "rifle", "pistol", "trademark"}
for entry in words:
    missing = required_metadata - set(entry)
    if missing:
        errors.append(f"{entry.get('id')} missing metadata: {sorted(missing)}")
    word_id = str(entry.get("id", ""))
    if not word_id.isalpha() or not word_id.islower():
        errors.append(f"invalid word ID: {word_id}")
    if str(entry.get("word", "")) != word_id.upper():
        errors.append(f"rendered word mismatch: {word_id}")
    if word_id in prohibited:
        errors.append(f"prohibited word present: {word_id}")
    if not bool(entry.get("safe", False)):
        errors.append(f"word not approved safe: {word_id}")
    if int(entry.get("length", 0)) != len(word_id):
        errors.append(f"length metadata mismatch: {word_id}")

expected_templates = {"single_word_v1", "word_pair_order_v1", "word_stream_presence_v1", "position_catch_v1"}
templates = templates_data.get("templates", [])
actual_templates = {str(template.get("id", "")) for template in templates}
if actual_templates != expected_templates:
    errors.append(f"template set mismatch: {sorted(actual_templates)}")
for template in templates:
    if not template.get("allowed_distractors"):
        errors.append(f"template has no distractor categories: {template.get('id')}")

required_files = [
    FAMILY / "FlashWordsFamily.gd",
    FAMILY / "FlashWordsGenerator.gd",
    FAMILY / "FlashWordsValidator.gd",
    FAMILY / "FlashWordsDifficultyPolicy.gd",
    FAMILY / "FlashWordsExposurePolicy.gd",
    FAMILY / "FlashWordsScoringPolicy.gd",
    FAMILY / "FlashWordsSceneView.gd",
    FAMILY / "tutorial/FlashWordsTutorial.tscn",
    APP / "assets/gameplay/flash_words/flash_words_preview.svg",
]
for path in required_files:
    if not path.exists():
        errors.append(f"required Flash Words file missing: {path.relative_to(ROOT)}")
for sound in ("flash_pulse.wav", "flash_interval.wav", "flash_reveal_click.wav", "flash_correct.wav", "flash_incorrect.wav"):
    if not (APP / "assets/audio" / sound).exists():
        errors.append(f"Flash Words audio missing: {sound}")

if errors:
    for error in errors[:200]:
        print(f"FLASH CONTENT FAIL: {error}")
    raise SystemExit(1)

print(f"FLASH_WORDS_CONTENT_PASS words={len(words)} templates={len(templates)}")

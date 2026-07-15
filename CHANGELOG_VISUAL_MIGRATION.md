# Visual Style Migration — CHANGELOG

## Phase 2 — Scene Investigation: COMPLETE

### Coverage: 65/65 (100%)
Every visual_kind referenced by the 5 Scene Investigation content JSONs
has a matching sprite asset. Per-template coverage:
- office_v1: 22/22
- kitchen_v1: 21/21
- workshop_v1: 21/21
- travel_desk_v1: 19/19
- garden_bench_v1: 21/21

### Pipeline
1. Generate on solid flat #FF00FF (magenta) background
2. Connected-component flood-fill from 4 image corners (10% fuzz)
3. RGBA PNG with transparent background, 512×512 max
4. Godot ETC2 compression (compress/mode=2)
5. Code-side draw_shadow() provides consistent shadows
6. Vector fallback renders original shapes for any missing sprite

### Assets (65 sprites, 3335KB total)
See `app/assets/gameplay/sprites/scene_investigation_sprite_grid.png`

### Prompt lock
`app/assets/gameplay/sprites/PROMPT.md` (v2, magenta background)

### Processing script
`tools/process_sprite.py` — flood-fill pipeline with 7-point verification

### Files created
- `app/src/gameplay/families/_shared/VisualStyleSystem.gd` (330 lines)
- `app/tests/runtime/verify_visual_style_migration.py`
- `app/assets/gameplay/sprites/PROMPT.md`
- `tools/process_sprite.py`
- 65 sprite PNGs + 65 .import files
- 1 composite grid PNG

### Files modified
- `app/src/gameplay/families/scene_investigation/SceneInvestigationSceneView.gd`
  (sprite-first draw with vector fallback, grounded canvas backgrounds,
   warm gold accent, code-side drop shadows)

### Logic safety
- 120 logic files verified byte-for-byte unchanged
- All Python verification scripts pass
- Generators, validators, policies, contracts, shared runtime: untouched
- Data contract (generated_scene dict, set_scene_data signature): unchanged

### Next loops (deferred)
- Flash Words
- Object Recall
- Pattern Recall
- Spot the Difference (vector-only; color passthrough)

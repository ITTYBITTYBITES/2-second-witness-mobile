# Visual Style Migration — CHANGELOG

## Phase 2 — Scene Investigation asset pipeline

### Resolution standard
- Max 512×512 for all sprites (non-square within 512 bound)
- Mobile VRAM: Godot ETC2 compression (`compress/mode=2`) on all imports
- Individual files (not atlas) — simplicity wins, batch if profiling demands it

### Shadow rule (v2)
- **Sprites are transparent cutouts with NO baked shadow.**
- `draw_shadow()` in code provides consistent shadow direction/opacity/scale
- Documented in `VisualStyleSystem.gd` header and `PROMPT.md`

### Prompt lock
- `app/assets/gameplay/sprites/PROMPT.md` — exact template for all object sprites
- Isometric 3/4 top-down, realistic 3D illustration, muted palette, no shadow, transparent BG

### Coverage gate
- Scene Investigation NOT done until 65/65 content-referenced kinds have sprites
- Current: 20/65 (31%) → 45 remaining

---

## Batch 2 — 10 sprites (priority by frequency)
| visual_kind | frequency | sprite |
|---|---|---|
| paper | 8x | ✓ |
| hardware | 6x | ✓ |
| glasses | 4x | ✓ |
| towel | 4x | ✓ |
| block | 3x | ✓ |
| coil | 3x | ✓ |
| fruit_round | 3x | ✓ |
| board | 2x | ✓ |
| bracket | 2x | ✓ |
| brush | 2x | ✓ |

## Batch 1 — 10 sprites (previously committed)
phone, book, mug, folder, pencil, clock, calculator, stapler, bottle, scissors

## Verification
- verify_visual_style_migration.py: 107/107 logic files unchanged ✓
- All sprites 512×512 max, ETC2 compressed
- Manifest matching disk: 20/20 ✓

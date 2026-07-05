# Recommended Asset Directory Structure

**Companion to:** `TWO_SECOND_WITNESS_DESIGN_BIBLE.md` §17 · **Status:** Recommendation (Phase 1)

This document defines a scalable asset layout that supports all current universes and unlimited future growth. It is a recommendation only — no migration is performed in Phase 1.

## Design rules
1. **Build once, theme everywhere.** Reusable art lives in `_shared/` and is tinted by registry palette at runtime. Universes never duplicate component art.
2. **Tri-layer isolation** (`ASSET_CONTRACT_SPEC`): Layer-1 (universe base), Layer-2 (world overlay), and Layer-3 (task-kernel / measurement-locked) assets live in clearly separated locations.
3. **Migration is intentional, not free.** Reorganizing existing assets is *intended* to preserve runtime behavior, but in practice it requires coordinated manifest and asset-path updates, import-metadata regeneration, and validator-confirmed path verification. (Adding *new* content is data + registry only — see below.)
4. ** snake_case everywhere.** All folder/file names match the conventions in the Bible §12.

## Target structure

```
app/assets/
├── _shared/                    # ONE copy of every reusable (tinted at runtime)
│   ├── icons/                  # icon_check.png, icon_play.png, icon_lock.png ...
│   ├── ui/                     # NeonButton frames, ModalFrame, UniverseCard/WorldCard templates
│   ├── audio/                  # ui_click.wav, ui_error.wav, iris_heartbeat.wav, slingshot_drop.wav
│   ├── meshes/                 # iris_crystalline.obj, degraded_fallback.obj, data_node.obj
│   ├── shaders/                # tunnel_core.gdshader
│   └── materials/              # lab_data_node.tres, lab_structure.tres, portal_glow.tres, optimized_noise.tres
│
├── brand/                      # App-store identity (universe-agnostic)
│   ├── app_icon_1024.png
│   ├── promo_header_1920.png
│   └── android/                # icon_background.png, icon_foreground.png (adaptive)
│
├── universes/                  # Per-universe bespoke art (Layers 1 & 2 only)
│   ├── _default/               # Fallback theme for scaffolded universes
│   │   ├── bg_default.png
│   │   ├── rib_default.obj
│   │   └── ambience_default.wav
│   ├── creative_arts/
│   │   ├── bg_creative_arts.png
│   │   ├── rib_creative_arts.obj
│   │   ├── ambience_creative_arts.wav
│   │   └── stimuli/            # Layer-3 stimulus set (universe-themed)
│   ├── frontier/
│   ├── history/
│   ├── life_sciences/
│   ├── science_lab/
│   ├── society_mind/
│   ├── tech_ops/
│   └── <future_universe>/      # Adding a universe = add a folder here + registry entry
│
└── vfx/                        # Particle/animation scenes (cross-universe)
    ├── iris_fracture.tscn
    └── slingshot_warp.tscn
```

## Layer-to-folder mapping
| Asset layer | Lives in | Why |
|---|---|---|
| Layer 1 — Universe base (rib_mesh, base_iris_mesh, ambient drone) | `universes/<u>/` | Defines the universe's foundational geometry/mood |
| Layer 2 — World overlay (bg_noise_texture, particle_textures, audio_overlay) | `universes/<u>/` (world-named files) | Modulates feel, never alters geometry |
| Layer 3 — Task kernel (UIButtonFrame, StimulusSprite) | `_shared/ui/` and `universes/<u>/stimuli/` | Measurement-locked; shared frames + per-universe stimulus art |

## Adding a new universe (zero engine edits)
1. Add the universe to `MASTER_UNIVERSE_REGISTRY.json` (palette, typography, status).
2. Create `app/assets/universes/<new_universe>/` with its Layer-1/2 assets.
3. Drop observation banks into `app/data/content/base_bundle/<new_universe>/`.
4. Register assets in `AssetManifestRegistry`.
5. Run `python3 tools/observation_content_validator.py` to confirm.

## Current-state gaps (flagged for Phase 2 migration)
- `assets/audio/`, `assets/textures/env/`, `assets/textures/sprites/` mix shared and per-universe assets flatly.
- No `_shared/` separation exists yet.
- Some Layer-3 stimulus sprites live under `textures/sprites/<universe>/` rather than a unified `universes/<u>/stimuli/`.

# 2 SECOND WITNESS — IMPLEMENTATION ROADMAP

**Status:** Living document (implementation-specific) · **Companion to:** `TWO_SECOND_WITNESS_DESIGN_BIBLE.md`

> The Design Bible is intentionally *timeless* — it defines what the product *is*. This document holds the *transitional* material: current inconsistencies to resolve and concrete recommendations for upcoming phases. It will change often; the Bible should not. Bible section numbers below refer to the canonical Bible.

---

## R1. Conflicts & Inconsistencies Currently Discovered

These are identified gaps, not yet fixed:

1. **Duplicated documentation (root vs `app/`).** `ADMOB_HOUSEHOLD_SAFETY_GUIDE.md`, `ADS_INTEGRATION_GUIDE.md`, `ASSET_AUDIT.md`, and `ITCH_IO_RELEASE_GUIDE.md` exist **byte-identically** in *both* the repo root and `app/`. Recommend removing the root copies and keeping `app/` canonical (or vice-versa) in Phase 2.
2. **No font files ship.** All typography profiles (TECHNICAL/SPARSE/HEAVY) are defined but unmapped to actual `.ttf`/`.otf` resources — the project uses Godot's default font. Phase 2 must introduce a font family. (Bible §5.)
3. **Flat asset mixing.** `assets/audio/`, `assets/textures/env/`, `assets/textures/sprites/` intermingle shared and per-universe assets with no `_shared/` separation (see Bible §17 / `ASSET_DIRECTORY_STRUCTURE.md`). A reorganization is needed.
4. **7 universes use the default palette.** animals_wildlife, food_cuisine, geography, nature_environment, science_discovery, space_astronomy, travel_tourism all carry the identical `#0B1320/#00D4FF/#80E5FF` clinical-cyan default — they will look indistinguishable until given bespoke palettes. (Bible §6.)
5. **Two `assets/` doc-subtree copies.** Beyond the 4 duplicated guides above, the repo also carries a duplicate `app/.github/`, `app/ADMOB_*`, etc. subtree — likely a stale workspace sync artifact.

---

## R2. Recommendations for Phase 2 (Global UI Asset Pack)

1. **Establish `_shared/` and reorganize** per Bible §17 — coordinated with manifest + asset-path updates and import-metadata regeneration, validator-confirmed. This is a deliberate migration, not a free file move.
2. **Introduce one geometric sans font family** (variable weight) and bind the three typography profiles (Bible §5) to weight/tracking. Replace reliance on Godot's default.
3. **Produce the shared component set** (Bible §16): `UniverseCard`, `WorldCard`, `NeonButton`, `ModalFrame`, `MetricLabel` as reusable themed scenes — authored neutral, tinted by `ThemeManager`.
4. **Generate the Layer-1/Layer-2 asset pack** for the 6 bespoke-palette universes (creative_arts, frontier, history, life_sciences, society_mind, tech_ops) using the Bible §15 AI standards: rib mesh, bg texture, ambient drone, stimulus set each.
5. **De-duplicate root-vs-app docs** (R1.1) and consolidate all design specs under `docs/design/`.
6. **Author bespoke palettes** for the 7 default-palette universes (R1.4) so each is visually distinct.
7. **Wire the validator** to enforce the Bible §14 dimension/format contract on every asset in `assets/` (currently the validator covers observations only).

---

*Update this document as items are completed or as new inconsistencies surface. Keep the Design Bible stable.*

# Reusable UI Components & Shared Assets

**Companion to:** `TWO_SECOND_WITNESS_DESIGN_BIBLE.md` §14 · **Status:** Inventory + spec (Phase 1)

The component philosophy: **build once, theme everywhere.** Components are authored visually neutral and tinted by registry palette (`ThemeManager` / `VisualIdentityManager`) at runtime. Universes never ship duplicate component art.

## Existing runtime theming (already in place — do not duplicate)
| System | Role |
|---|---|
| `ThemeManager` (autoload) | Applies `palette` + `typography` profile for the active universe |
| `VisualIdentityManager` (autoload) | Resolves universe identity → tints screens/components |
| `AssetManifestRegistry` (autoload) | Single registry of all asset paths (no hardcoded `res://` in components) |

These three are the **tinting backbone** — every component below defers to them. No component should bake in a color.

## Components to produce in Phase 2

| # | Component | Visual spec | Reused by |
|---|---|---|---|
| 1 | **`UniverseCard`** | 280×138 frosted-glass card; `primary` 4px bottom border; title (uppercase) + description + mastery trend; corner-radius 12 | Universe-selection grid |
| 2 | **`WorldCard`** | 270×124 variant; world name + scenario count + mastery %; same border treatment | World-selection grid |
| 3 | **`NeonButton`** | Layer-3 `UIButtonFrame` (256×96), border-only; StyleBox states (normal/hover/pressed); `primary` font color lightened 0.6 on hover | All scenarios + menus |
| 4 | **`ModalFrame`** | Frosted-glass modal via `ModalWindowManager`; semi-transparent `bg` (~15% alpha); `primary` border; 12px radius | All modal dialogs |
| 5 | **`MirrorPanel`** | Cognitive Mirror HUD utility; must satisfy 3 constraints (zero nav dependency, zero sim mutation, zero uninvoked blocking) | HUD (always-present) |
| 6 | **`StimulusSprite`** | Layer-3 128×128, centered origin, no padding; **positionally locked** at cascade start | Every cognitive scenario |
| 7 | **`MetricLabel`** | Tabular-figure micro-label (10–12px); monospaced numerals; letter-spaced | HUD + Mirror + cards |
| 8 | **`SectionHeader`** | Small-caps / uppercase title rule with `primary` underline accent | All screen headers |

## Shared global assets (one copy, tinted per universe)
- **Icon set** — `icon_check`, `icon_play`, `icon_lock`, `icon_back`, `icon_mirror`, `icon_settings`, `icon_store`. Tinted, never duplicated.
- **SFX bank** — `ui_click.wav`, `ui_error.wav`, `iris_heartbeat.wav`, `slingshot_drop.wav`.
- **Measurement core** — `iris_crystalline.obj`, `tunnel_core.gdshader` (identical across all universes — this is the test apparatus).
- **Default palette** — `#0B1320` / `#00D4FF` / `#80E5FF` (scaffolded-universe fallback).

## Component authoring rules
1. **No hardcoded colors.** Read from `VisualIdentityManager.get_universe_identity()`.
2. **No hardcoded IDs.** Universes/worlds resolve through `ContentRegistry`.
3. **StyleBox-driven state.** Buttons change state via StyleBox color, never geometry.
4. **Responsive insets.** All screens use the clamped proportional insets (Bible §5).
5. **Accessibility.** Touch targets ≥48×48dp; contrast ≥4.5:1; color never the sole encoder.

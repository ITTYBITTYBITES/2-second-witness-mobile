# 2 SECOND WITNESS — DESIGN BIBLE
### The Permanent Visual & Interaction Design Foundation

**Status:** Canonical design foundation (Phase 1) · **Scope:** Project-wide · **Last reviewed:** 2026-07-05

> This Bible is the single source of truth for all visual, UI, audio, and asset-production decisions in *2 Second Witness*. It **consolidates and supersedes** the scattered design specifications previously living under `app/` (see §16 — *Incorporated Documentation*). When this document and an older spec disagree, **this Bible governs** for visual/design matters; the older engineering specs remain authoritative only for their narrow runtime-engineering concerns.

---

## Table of Contents
1. [Product Identity & Visual Design Principles](#1-product-identity--visual-design-principles)
2. [UI Design System](#2-ui-design-system)
3. [Typography Standards](#3-typography-standards)
4. [Color Palette](#4-color-palette)
5. [Layout & Spacing Guidelines](#5-layout--spacing-guidelines)
6. [Iconography Standards](#6-iconography-standards)
7. [Animation Principles](#7-animation-principles)
8. [Audio Style Guidelines](#8-audio-style-guidelines)
9. [Accessibility Guidelines](#9-accessibility-guidelines)
10. [Asset Naming Conventions](#10-asset-naming-conventions)
11. [Folder Organization](#11-folder-organization)
12. [Technical Asset Specifications](#12-technical-asset-specifications)
13. [AI Asset Generation Standards](#13-ai-asset-generation-standards)
14. [Reusable UI Components & Shared Assets](#14-reusable-ui-components--shared-assets)
15. [Recommended Asset Directory Structure](#15-recommended-asset-directory-structure)
16. [Incorporated Documentation](#16-incorporated-documentation)

---

## 1. Product Identity & Visual Design Principles

**Product:** *2 Second Witness* — an interactive observation-discovery platform built on the "Liquid Memory" concept: a clinical, high-tech cognitive instrument wrapped in a mysterious, flowing sci-fi atmosphere.

**Core metaphor:** *The Cognitive Mirror.* The player flies through a forward-motion tunnel toward a luminous geometric ring (the **Iris** / Lens) and performs rapid 2-second cognitive observations. The interface is a measurement instrument, not a decoration.

### The Five Design Pillars
1. **The Instrument Is Honest.** Every visual element either *measures* or *reports*. Ornament that does not serve cognition is forbidden. (Source: `ASSET_CONTRACT_SPEC` — "Art is a perceptual substitution layer only.")
2. **Attention Is a Budget, Not a Resource.** Human tracking fails above 1.4× visual density. We budget for *perception*, not GPU. (Source: `ATTENTION_BUDGET_SPEC`.)
3. **The Iris Owns the Frame.** A single luminous anchor must command ~80% of attention. Background is a passive reference frame, never a competitor. (Source: `ATTENTION_BUDGET_SPEC` Tier 1.)
4. **Stability Emerges from Constraint.** Timing, layout geometry, and hitboxes are measurement invariants. Visual themes may modulate *aesthetics* but must never alter *interaction geometry*. (Source: `ASSET_CONTRACT_SPEC` Layer 3 — "The Measurement Lock.")
5. **Dark, Neon, Clinical.** Deep voids punctuated by precise neon emission. High contrast, sharp edges, no drop shadows on task elements. Mystery over clutter.

### The Three-Tier Perceptual Hierarchy (mandatory in every scene)
| Tier | Role | Example | Rule |
|---|---|---|---|
| **1 — Primary Anchor** | Focal point | Crystalline Iris | Brightest object; ≥300% emission vs background; asynchronous motion |
| **2 — Action Field** | Cognitive targets | Spike UI, answer buttons | Reserved contrast colors; suppress Tier-3 motion on spawn |
| **3 — Background Entropy** | Spatial frame | Tunnel ribs, particles | ≤1.4× density; Z-axis flow only; low-luminance; no specular |

> **The Squint Test (final arbiter):** Squint at any scene. If the Iris is not the *only* clearly defined shape remaining, the background entropy is too high and the scene is rejected.

---

## 2. UI Design System

The UI is organized as a **3-layer separation** (source: `UI_TAXONOMY_SPEC`). Each layer has a fixed container and may not bleed into another.

```
┌─────────────────────────────────────────────────────────────┐
│ 1. HUD LAYER        → MainShell/UILayer/HUDRoot             │
│    Persistent utility: Leave-Stream btn, Mirror btn, Store   │
├─────────────────────────────────────────────────────────────┤
│ 2. NAVIGATION LAYER → MainShell/UILayer/NavigationUI        │
│    State progression: Landing → Weekly → World → Scenario   │
├─────────────────────────────────────────────────────────────┤
│ 3. SIMULATION LAYER → MainShell/WorldLayer & ScenarioUI     │
│    Deep task: Iris, Memory Cascade, active scenarios         │
└─────────────────────────────────────────────────────────────┘
```

### Control-plane governance
Two **orthogonal** graphs intersect *only* through `ModalWindowManager`:
- **Navigation Graph** (linear, reachable): `LandingScreen → WeeklyFeaturedScreen → WorldSelectScreen → ScenarioNode`, governed by `NavigationRouter`.
- **HUD Utility Graph** (quick-access): HUD buttons → `ModalWindowManager.push()`. The Cognitive Mirror is a HUD utility (zero navigation dependency, zero simulation mutation, zero uninvoked blocking) — it is *never* a scene transition.

### Surface treatment
- **Panels:** Frosted-glass / holographic. Semi-transparent dark base (`bg` color at ~15% alpha), neon `primary` border (4px bottom accent).
- **Buttons:** Border-only frames (Layer-3 `UIButtonFrame`, 256×96). No baked internal illusions. State changes via StyleBox color, not geometry.
- **Corner radii:** 12px on cards/panels. Sharp edges on stimuli & task buttons (measurement integrity).
- **Feedback tone:** Success = `primary` pulse; Error = dedicated warning red; Neutral = subtle scale tween. Tone varies per universe `feedback_tone` (diagnostic / poetic / organic / archaeological / mechanical).

---

## 3. Typography Standards

The project uses a **typography-profile system** (not a single font) bound per-universe via the registry field `typography`. Profiles are applied by `ThemeManager`.

> **Current gap (flagged, not fixed in Phase 1):** no font files (`.ttf`/`.otf`) ship yet — the project relies on Godot's built-in default font. **Phase 2 must introduce one neutral geometric sans family** (e.g., a variable-weight font) and map the profiles below to weights/tracking.

### Typography profiles
| Profile | Used by | Character | Treatment |
|---|---|---|---|
| **TECHNICAL** | science_lab, frontier, tech_ops, + 7 scaffolded | Clinical, precise, instrumentation | Uppercase for HUD/labels; tabular figures for metrics; tight tracking |
| **SPARSE** | creative_arts, life_sciences | Airy, considered, editorial | Wide tracking; mixed case for titles; generous line height |
| **HEAVY** | history, society_mind | Dense, weighted, archival | Bold weights; small caps for section headers; condensed where space-limited |

### Scale (baseline, px — Godot `font_size` overrides)
| Role | Size | Weight |
|---|---|---|
| Universe/Screen title | 28–32 | Bold, uppercase (TECHNICAL/HEAVY) |
| Card title / world name | 18–22 | Semibold |
| Body / button label | 14 | Regular |
| Metric / micro-label | 10–12 | Medium, tabular, letter-spaced |

- **Minimum readable size:** 12px. Nothing critical below this.
- **Figures:** Always tabular/monospaced numerals for any cognitive metric, timer, or count (prevents digit jitter).
- **Localization:** Every observation carries `localization.prompt_key` / `answer_key`. Text must remain short — the **2-second window** is the hard constraint on prompt length.

---

## 4. Color Palette

Colors are **data-driven** from `MASTER_UNIVERSE_REGISTRY.json` (field `palette: {bg, primary, accent}`) and resolved by `VisualIdentityManager`. There is **no hardcoded color in engine code** — themes come purely from registry data.

### Core token semantics (consistent across all universes)
| Token | Role | Usage rule |
|---|---|---|
| `bg` | Void background | Tunnel base, panel fill (~15% alpha). Darkest value in the scene. |
| `primary` | Identity emission | Iris core glow, borders, active-state accents, primary data. |
| `accent` | Secondary emission | Hover/highlight, sub-accents, particle tints. Lighter companion to `primary`. |

### Per-universe palette (canonical — from registry)
| Universe | `bg` | `primary` | `accent` | Emotion |
|---|---|---|---|---|
| science_lab (+ 6 defaults) | `#0B1320` | `#00D4FF` | `#80E5FF` | CLINICAL cyan |
| creative_arts | `#180A22` | `#B833FF` | `#D175FF` | SATURATED violet |
| frontier | `#081218` | `#33CCFF` | `#80DFFF` | DEEP_SPACE ice |
| history | `#1A1400` | `#E6B800` | `#FFD700` | WARM gold |
| life_sciences | `#0A1A10` | `#2ECC71` | `#70DB93` | NATURAL green |
| society_mind | `#120818` | `#FF3366` | `#FF8099` | UNCANNY magenta |
| tech_ops | `#050505` | `#00FF41` | `#66FF88` | UNCANNY matrix-green |

> **Reserved (engine-global, not universe-tinted):**
> - **Warning/Error red** — for error SFX + invalid-input feedback (consistent regardless of universe).
> - **Success signal** — a brief `primary` pulse (universe-tinted), never a fixed green/red.
> - **Pure black `#000000`** — reserved exclusively for the Iris interior ("pitch-black nothingness").

### Contrast & accessibility
- All task text must clear **WCAG AA** (4.5:1) against its immediate background. Because backgrounds are very dark and `primary`/`accent` are high-luminance neon, this is generally satisfied — verify for the lowest-luminance palette (history gold on `#1A1400`).
- Never lower a button's opacity to increase difficulty — that violates the measurement lock (`ASSET_CONTRACT_SPEC`).

---

## 5. Layout & Spacing Guidelines

### The responsive shell
Screens use a `PanelContainer` inset from the viewport by a clamped proportional margin (source: existing `WeeklyFeaturedScreen` / `WorldSelectScreen`):
- **Inset X:** `clamp(viewport.w × 0.035, 24px, 64px)`
- **Inset Y:** `clamp(viewport.h × 0.04, 20px, 48px)`

### Grid system
- **Card grid:** responsive columns = `clamp(floor(usable_width / column_target), 1, 4)`. Target column pitch ~286–296px.
- **Card size:** Universe card `280×138`; World card `270×124`.
- **Base spacing unit:** 8px. All paddings/margins are multiples of 8 (8, 16, 24, 32, 48, 64).

### Measurement-invariant zone (Layer 3 lock)
During the active 2-second cognitive window:
- **Stimulus sprites** (`128×128`) and **answer buttons** (`256×96`) are **positionally locked** the instant the timer starts.
- The spatial distance between `[Button A]` and `[Button B]` is a **constant** so Fitts's-Law traversal time is invariant across worlds. Layout changes that affect this distance are forbidden.

### Safe areas
- Account for Android notch / gesture bars via Godot's `DisplayServer.get_display_safe_area()`. HUD controls must never sit under system gestures.

---

## 6. Iconography Standards

### Style
- **Flat, minimalist, vector.** High contrast against pure black. **No drop shadows, no baked gradients** on task icons.
- Single-color emission (universe `primary`), filled or stroke-only — pick one and stay consistent within a set.
- Geometric clarity over decoration; a shape must read at 64×64.

### Stimulus icons (Layer 3 — measurement)
- **Size:** exactly `128×128`, centered origin, **no transparent padding**, **no baked shadows** (source: `ASSET_CONTRACT_SPEC`).
- Sets are universe-themed: hexagons/diamonds (science), organic cell blobs (life sciences), Rorschach ink blots (society & mind). See §13 for generation prompts.

### UI icons
- **Size:** 64×64 master, displayed at 32/48.
- **Set:** `icon_check`, plus a minimal semantic set (play, lock, back, mirror, settings, store). Each universe *tints* the shared icon set rather than shipping its own.

### App icon
- Glowing geometric neon ring (iris) in a deep-blue void; pitch-black center. "Cognitive Mirror" must read instantly at 512×512 and down to 48×48. (See `BRANDING_PROMPT_GENERATOR.md` §1, incorporated.)

---

## 7. Animation Principles

### Timing budget (the hard floor)
The architecture is a **time-sliced consistency model** over Godot's non-deterministic loop (source: `CONSISTENCY_CONTRACT_SPEC`, `DESIGN_CONSTRAINT_ENGINEERING_SPEC`). Permitted incoherence:
| Pair | Tolerance | Enforced by |
|---|---|---|
| Rendering ↔ Input (modal push) | 33.3 ms (1–2 frames) | `UIInputArbiter` TRANSITIONAL_LOCK |
| Physics ↔ UI (slingshot momentum) | 50.0 ms (3 frames) | `NavigationRouter` async dispatch |
| Signal teardown ↔ Navigation | **0.0 ms** (hard boundary) | `InteractionLedger` execution lock |

### Motion principles
- **Motion scale** is per-universe data (`motion_scale`: 0.8 tech_ops → 1.5 creative_arts). All tween durations multiply by this scalar.
- **Directional integrity:** all background motion aligns to the primary Z-axis flow (forward tunnel). Only interactable objects may break the global flow vector.
- **Easing:** ease-out for UI entrances (glass panels, cards), ease-in for exits. The slingshot re-entry uses an impulse (visceral, not eased) to preserve momentum.
- **The 2-second cascade** is untouchable: animation may *mask* the timer start, never *delay* it. Visual instantiation lag (≤33ms) is tolerated and masked by transitional lock.

### Performance profiles (motion degrades, logic does not)
From `FIDELITY_BUDGET_SPEC`: HIGH/MID/LOW profiles scale particles, shader complexity, chunk density. A visual downgrade must **never** affect Iris hitboxes, cascade timing, or chunk hashing.

---

## 8. Audio Style Guidelines

### Bus architecture (from `AudioManager`)
- **Ambient** bus: single looping `AudioStreamPlayer`, base volume `-10 dB`. One ambient drone per universe (`ambient_base_audio`, Layer 1).
- **SFX** bus: pool of 5 `AudioStreamPlayer`s, round-robin. Supports per-event pitch shift.

### Sound categories
| Category | Examples | Character |
|---|---|---|
| **UI** | `ui_click`, `ui_error` | Short, crisp, digital. Click = confirmation tick; error = warning buzz. |
| **Mechanic** | `slingshot_drop`, `iris_heartbeat` | Visceral. Heartbeat = tension/anchor pulse; slingshot = re-entry momentum. |
| **Ambient** | `ambience_<universe>` (Layer 1) | Low-frequency drone; defines universe mood; loops seamlessly; ≤30s preferred. |
| **Overlay** (Layer 2) | wind, digital static, particles | Secondary SFX layers; must never mask Tier-1 heartbeat or UI clicks. |

### Audio rules
- **Format:** `.wav` (uncompressed) for SFX (low latency is critical in a 2-second window); `.ogg` acceptable for long ambient loops if size pressures.
- **Sample rate:** 44.1 kHz, mono for SFX, stereo for ambient.
- **Loudness target:** normalize SFX to **-16 LUFS integrated**; peaks ≤ -1 dBTP. Ambient sits ~6 dB under UI clicks.
- **Measurement lock applies to audio:** an audio cue may *reinforce* a cognitive event but must not *replace* the visual/timing signal. Never delay a cascade on an audio finish.

---

## 9. Accessibility Guidelines

### Cognitive accessibility (this product's core concern)
- The 2-second window is the design constant; **do not** add "accessibility options" that extend it (that would invalidate the measurement). Instead, accommodate via:
  - **Difficulty tiering** (1–5) within the window — easier tiers use higher-contrast distractors, not more time.
  - **No time-pressure on navigation/menus** — only the cascade itself is timed.
- **Color is never the sole encoder.** Distractors differ in shape/label, not just hue (supports color-blind users; gold-on-dark history palette is the risk case — verify shape differentiation).

### Motor accessibility
- Touch targets ≥ **48×48 dp** (Android standard). Answer buttons (256×96) vastly exceed this.
- Generous tap slop; no precision-aiming required during the cascade.

### Visual accessibility
- WCAG AA contrast (4.5:1) for all text (see §4).
- **Reduced-motion:** respect OS reduced-motion preference — collapse particle/VFX tiers and shorten tweens, but never alter Iris hitboxes or timing.
- Photosensitivity: no strobing > 3 Hz. Iris pulse is a slow breath, not a flash.

### Audio accessibility
- All audio cues have a visual counterpart (heartbeat ↔ pulse; click ↔ color flash). The game is fully playable muted.
- Subtitles/captions not required (no spoken dialogue), but all SFX should be visually mirrored.

---

## 10. Asset Naming Conventions

All identifiers are **snake_case**, ASCII only. No spaces, no camelCase in filenames.

### Tokens
| Prefix/Token | Meaning | Example |
|---|---|---|
| `<universe>` | universe id (registry key) | `creative_arts`, `science_lab` |
| `<world>` | world id | `painting`, `ancient_rome` |
| `bg_` | background texture | `bg_creative_arts.png` |
| `banner_` | UI banner | `banner_history.png` |
| `stim_` | stimulus sprite (Layer 3) | `stim_hex.png`, `stim_cell.png` |
| `rib_` | tunnel rib mesh (Layer 1) | `rib_science_lab.obj` |
| `btn_` | UI button frame | `btn_frame_scilab.png` |
| `icon_` | UI icon | `icon_check.png` |
| `ambience_` | ambient audio | `ambience_life_sciences.wav` |
| `iris_` | Iris-related asset | `iris_crystalline.obj`, `iris_heartbeat.wav` |

### Observation IDs
`<universe>_<world>_<subcategory>_<NNNN>` — e.g. `history_ancient_rome_emperors_0001`. (Authoritative; emitted by `generate_observation_bank.py`.)

### Scene/script
- Scenes: `PascalCase.tscn` (`MainShell.tscn`, `BootScreen.tscn`).
- Scripts: `PascalCase.gd` matching their scene/role.
- Universes/worlds: always `snake_case` to match registry keys exactly.

---

## 11. Folder Organization

The project uses a **two-domain split** (source: `README.md`):

```
2-second-witness-mobile/
├── app/                  ← THE ENGINE (Godot 4.6 project). Full app update to change.
│   ├── assets/           ← Engine-bundled art/audio/meshes/shaders
│   ├── data/content/     ← Compiled observation banks (base bundle)
│   ├── scripts/          ← GDScript (engine + scenarios)
│   ├── benchmark/        ← Headless verification suite
│   ├── tools/            ← Python authoring/validation tooling
│   └── MASTER_UNIVERSE_REGISTRY.json   ← Canonical universe spec
├── live_content/         ← OTA pipeline (pushes to live users w/o rebuild)
└── docs/design/          ← This Bible + design foundation
```

> **Naming inconsistency (flagged):** the engine project lives in `app/`, but multiple `*.md` docs and a duplicate `app/` subtree of docs exist at the repo root. See §17 — *Conflicts & Inconsistencies*.

---

## 12. Technical Asset Specifications

### Image / texture
| Asset | Size | Format | Notes |
|---|---|---|---|
| App icon | 1024×1024 master | PNG (lossless) | Export Android adaptive fg/bg separately |
| Background noise (Layer 2) | 512×512 or 1024×1024 | PNG, seamless tile | **No perspective** (breaks shader math) |
| Stimulus sprite (Layer 3) | **128×128** | PNG, centered, no padding | Measurement-locked |
| UI button frame (Layer 3) | **256×96** | PNG, lossless, border-only | No internal illusions |
| UI icon | 64×64 master | PNG | Display 32/48 |
| Promo hero | 1920×1080 | PNG/JPG | App store / itch.io |

- **Max texture:** no raw PNG above **2048×2048** (`FIDELITY_BUDGET_SPEC`).
- **Compression:** tunnel materials use `import_etc2_astc`. Transparency overdraw capped at **2 layers**.

### 3D / mesh
| Asset | Polys | Format |
|---|---|---|
| `rib_mesh` (Layer 1) | ≤ 500 | `.obj` |
| `base_iris_mesh` (Layer 1) | moderate | `.obj` |
| `iris_accent_geometry` (Layer 2) | non-colliding decor | `.obj` |

- Models conform to **MID tier** natively; LOD/scale via Godot visibility layers.
- Must contain **zero semantic meaning or textual data** (Layer 1 constraint).

### Audio
| Asset | Format | Rate | Channels |
|---|---|---|---|
| SFX | `.wav` | 44.1 kHz | mono |
| Ambient loop | `.wav` (or `.ogg` if large) | 44.1 kHz | stereo |

### Animation resources
- Tween-driven in GDScript (no imported animation clips for UI).
- The tunnel is shader-driven (`tunnel_core.gdshader`); VFX as `.tscn` particle scenes (`iris_fracture.tscn`, `slingshot_warp.tscn`).

---

## 13. AI Asset Generation Standards

To guarantee a consistent *Liquid Memory* identity across AI-generated assets, **every generation prompt must include the style lock + the specific asset contract**. (Consolidated from `BRANDING_PROMPT_GENERATOR.md`.)

### The universal style lock (append to EVERY prompt)
> *Minimalist, clinical, high-tech, dark-mode, high-contrast, UI/UX design, vector art style, flat with intense neon bloom, no drop shadows, sharp edges, masterpiece. Aesthetic: "Liquid Memory" — clinical yet mysterious.*

### Per-asset-type prompts (authoritative examples)
**App icon:** glowing perfect geometric neon-cyan ring (iris) in deep dark-blue void, pitch-black center.
**Background (tiling):** seamless, flat, 2D, repeating pattern — **explicitly forbid perspective** in the prompt.
**Stimulus sprites:** simple flat shapes glowing bright neon on pure black; strip backgrounds to transparency post-generation.
**Promo hero:** first-person high-speed flight through dark liquid-plasma tunnel; massive cyan ring center; frosted-glass UI panels.

### Post-generation pipeline (mandatory)
1. Generate.
2. Strip messy backgrounds to pure transparency (`remove.bg` / equivalent) for icons/stimuli.
3. Resize to **exact** contract dimensions (§12).
4. Drop into `assets_incoming/`.
5. Run `PreImportAssetValidator` → on PASS, asset moves to `assets/` and registers in `AssetManifestRegistry`.

> **The Rejection Rule:** if a generated asset's theme causes tester reaction-time to slip >20% on the baseline tracking task, it is rejected for violating the Attention Budget — regardless of aesthetic quality.

---

## 14. Reusable UI Components & Shared Assets

**Principle:** build once, theme everywhere. A component is authored neutral and tinted by registry palette at runtime — universes never ship duplicate component art.

### Shared UI components (to be produced in Phase 2)
| Component | Spec | Reuse |
|---|---|---|
| `ThemeManager` (exists) | Applies `palette` + `typography` per active universe | All screens |
| `VisualIdentityManager` (exists) | Resolves universe identity → tints | All screens |
| `UniverseCard` | 280×138 frosted-glass card, `primary` border, title/desc/mastery | Universe grid |
| `WorldCard` | 270×124 variant; world name + scenario count + mastery % | World grid |
| `MirrorPanel` | Cognitive Mirror HUD utility (3-rule compliant) | HUD |
| `ModalFrame` | Frosted-glass modal via `ModalWindowManager` | All modals |
| `NeonButton` | Layer-3 button frame (256×96), StyleBox states | Scenarios + menus |
| `StimulusSprite` | Layer-3 128×128, positionally locked | All scenarios |
| `MetricLabel` | Tabular-figure micro-label | HUD + mirror |

### Shared global assets (one copy, tinted per universe)
- **Icon set** (`icon_*`) — tinted, not duplicated.
- **Default ambient** + SFX bank (`ui_click`, `ui_error`, `iris_heartbeat`, `slingshot_drop`).
- **Iris mesh/shader** (`iris_crystalline.obj`, `tunnel_core.gdshader`) — the measurement core, identical everywhere.
- **Default palette** (`#0B1320` / `#00D4FF` / `#80E5FF`) — the scaffolded universes all inherit this until given bespoke palettes.

---

## 15. Recommended Asset Directory Structure

A scalable layout supporting all 14 universes and future growth. It preserves the existing `assets/` root (so no engine import paths break) while introducing per-universe content folders.

```
app/assets/
├── _shared/                       ← ONE copy of every reusable (tinted at runtime)
│   ├── icons/                     ← icon_check.png, icon_play.png, ...
│   ├── ui/                        ← NeonButton frames, ModalFrame, card templates
│   ├── audio/                     ← ui_click.wav, ui_error.wav, iris_heartbeat.wav
│   ├── meshes/                    ← iris_crystalline.obj, degraded_fallback.obj
│   ├── shaders/                   ← tunnel_core.gdshader
│   └── materials/                 ← lab_data_node.tres, portal_glow.tres
│
├── brand/                         ← App-store-facing identity (universe-agnostic)
│   ├── app_icon_1024.png
│   ├── promo_header_1920.png
│   └── android/                   ← adaptive icon fg/bg
│
├── universes/                     ← Per-universe bespoke art (Layer 1 + Layer 2)
│   ├── _default/                  ← fallback theme (current scaffolded palette)
│   │   ├── bg_default.png
│   │   ├── rib_default.obj
│   │   └── ambience_default.wav
│   ├── creative_arts/
│   │   ├── bg_creative_arts.png
│   │   ├── rib_creative_arts.obj
│   │   ├── ambience_creative_arts.wav
│   │   └── stimuli/               ← Layer-3 stimulus set for this universe
│   │       ├── stim_violet_hex.png
│   │       └── stim_palette.png
│   ├── history/
│   ├── life_sciences/
│   ├── science_lab/
│   ├── society_mind/
│   ├── tech_ops/
│   └── frontier/
│
└── vfx/                           ← Particle/animation scenes (cross-universe)
    ├── iris_fracture.tscn
    └── slingshot_warp.tscn
```

### Migration note (do NOT execute in Phase 1)
The current `assets/textures/env/`, `assets/textures/sprites/`, `assets/audio/` mix shared and per-universe assets flatly. Phase 2 (Global UI Asset Pack) should reorganize into the structure above. Because all asset paths resolve through `AssetManifestRegistry`, this is a **path-registry migration**, not an engine-code change — but it must be done deliberately with the validator guarding it.

---

## 16. Incorporated Documentation

This Bible **merges** (does not duplicate) the following existing specs. They remain in place as deeper engineering references but defer to this Bible on visual/design matters:

| Source doc | Incorporated as |
|---|---|
| `app/UI_TAXONOMY_SPEC.md` | §2 UI Design System (3-layer separation, orthogonality) |
| `app/ASSET_CONTRACT_SPEC.md` | §1 pillars, §6 iconography, §12 specs, §14 components (tri-layer contract) |
| `app/ATTENTION_BUDGET_SPEC.md` | §1 pillars, §1 three-tier hierarchy, §13 rejection rule |
| `app/FIDELITY_BUDGET_SPEC.md` | §7 animation (performance profiles), §12 specs (texture/mesh caps) |
| `app/CONSISTENCY_CONTRACT_SPEC.md` | §7 animation (time-sliced consistency, control plane) |
| `app/DESIGN_CONSTRAINT_ENGINEERING_SPEC.md` | §7 animation (incoherence tolerance matrix) |
| `app/BRANDING_PROMPT_GENERATOR.md` | §6 app icon, §13 AI generation standards |
| `app/LIQUID_MEMORY_V2_PRODUCT_BIBLE.md` | §1 product identity (Cognitive Mirror concept) |
| `app/INTERACTION_DESIGN_UNDER_CONSTRAINT_SPEC.md` | §2, §7 (2-second timing invariant) |
| `app/MASTER_UNIVERSE_REGISTRY.json` | §4 color palette (authoritative source of all palette values) |
| `app/FINAL_ASSET_MANIFEST.md` | §12 specs, §15 structure |

---

## 17. Conflicts & Inconsistencies Discovered

These were **identified, not fixed** (Phase 1 is documentation only):

1. **Duplicated documentation (root vs `app/`).** `ADMOB_HOUSEHOLD_SAFETY_GUIDE.md`, `ADS_INTEGRATION_GUIDE.md`, `ASSET_AUDIT.md`, and `ITCH_IO_RELEASE_GUIDE.md` exist **byte-identically** in *both* the repo root and `app/`. Recommend removing the root copies and keeping `app/` canonical (or vice-versa) in Phase 2.
2. **No font files ship.** All typography profiles (TECHNICAL/SPARSE/HEAVY) are defined but unmapped to actual `.ttf`/`.otf` resources — the project uses Godot's default font. Phase 2 must introduce a font family.
3. **Flat asset mixing.** `assets/audio/`, `assets/textures/env/`, `assets/textures/sprites/` intermingle shared and per-universe assets with no `_shared/` separation (see §15). A reorganization is needed.
4. **7 universes use the default palette.** animals_wildlife, food_cuisine, geography, nature_environment, science_discovery, space_astronomy, travel_tourism all carry the identical `#0B1320/#00D4FF/#80E5FF` clinical-cyan default — they will look indistinguishable until given bespoke palettes.
5. **Two `assets/` doc-subtree copies.** Beyond the 4 duplicated guides above, the repo also carries a duplicate `app/.github/`, `app/ADMOB_*`, etc. subtree — likely a stale workspace sync artifact.

---

## 18. Recommendations for Phase 2 (Global UI Asset Pack)

1. **Establish `_shared/` and reorganize** per §15 — guarded by the content validator so no import path breaks.
2. **Introduce one geometric sans font family** (variable weight) and bind the three typography profiles to weight/tracking. Replace reliance on Godot's default.
3. **Produce the shared component set** (§14): `UniverseCard`, `WorldCard`, `NeonButton`, `ModalFrame`, `MetricLabel` as reusable themed scenes — authored neutral, tinted by `ThemeManager`.
4. **Generate the Layer-1/Layer-2 asset pack** for the 6 bespoke-palette universes (creative_arts, frontier, history, life_sciences, society_mind, tech_ops) using the §13 AI standards: rib mesh, bg texture, ambient drone, stimulus set each.
5. **De-duplicate root-vs-app docs** (§17.1) and consolidate all design specs under `docs/design/`.
6. **Author bespoke palettes** for the 7 default-palette universes (§17.4) so each is visually distinct.
7. **Wire the validator** to enforce the §12 dimension/format contract on every asset in `assets/` (currently the validator covers observations only).

---

*End of Design Bible. This is a living document — update via pull request, and keep §16–18 current as the foundation evolves.*

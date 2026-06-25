# ASSET CONTRACT SPECIFICATION (PRIORITY 5)
*The Tri-Layer Integration Hierarchy*

**The Paradigm:**
Artists do not "add assets to the game." Artists submit asset candidates to a constrained measurement instrument. The interaction geometry is mathematically locked. Art is a perceptual substitution layer only.

To prevent perceptual drift from corrupting the cognitive measurement, all assets must be explicitly classified and validated against one of three structural tiers.

---

## LAYER 1: UNIVERSE BASE ASSETS
*The Structural Identity. These assets define the foundational geometry and physics of the environment. They are global to all Worlds within a Universe.*

**Allowed Assets:**
- `rib_mesh` (`.obj`): The core tunnel streaming geometry (e.g., Hexagonal ribs). Max 500 polys.
- `base_iris_mesh` (`.obj`): The foundational 3D structure of the Lens (e.g., A simple brass ring).
- `ambient_base_audio` (`.wav`): The root low-frequency drone for the Universe.

**Constraints:**
- Must contain zero semantic meaning or textual data.
- Must be geometrically stable (no erratic runtime deformation).

---

## LAYER 2: WORLD OVERLAY ASSETS
*The Perceptual Modulation Layer. These assets change how the Universe "feels" without altering its physical boundaries.*

**Allowed Assets:**
- `bg_noise_texture` (`.png`): 512x512 or 1024x1024 seamless noise for the tunnel shader (e.g., Sandstorm vs Plasma).
- `iris_accent_geometry` (`.obj`): Non-colliding decorative meshes attached to the Iris to denote mastery (e.g., Extra clockwork gears).
- `particle_textures` (`.png`): 64x64 sprites for non-interactive atmospheric dust.
- `audio_overlay` (`.wav`): Secondary SFX layers (e.g., wind, digital static).

**Constraints (The Hard Boundary):**
- **NO FUNCTIONAL MODIFICATION:** World overlays are strictly forbidden from altering the bounds, hitboxes, or timing of any object in Layer 3. 
- Overlays must be purely aesthetic (Colors, Shaders, Particles).

---

## LAYER 3: TASK KERNEL ASSETS (STRICT INVARIANT)
*The Cognitive Measurement Core. These assets ARE the test. They must remain absolute constants across all Universes and Worlds.*

**Allowed Assets:**
- `UIButtonFrame` (`.png`): Exactly `256x96` pixels. Lossless. Border-only designs. No internal spacing illusions.
- `StimulusSprite` (`.png`): Exactly `128x128` pixels. Centered origin. No transparent padding. No baked shadows.

**Constraints (The Measurement Lock):**
- **ZERO MOTION:** Stimulus sprites and buttons must be completely locked in position the millisecond the 2-second timer begins.
- **ZERO OBFUSCATION:** You cannot use "alien" fonts or lower the opacity of a button to make a World "harder." 
- **STATIC LAYOUT:** The spatial distance between `[Button A]` and `[Button B]` must remain identical, ensuring Fitts's Law traversal time is a constant across all Worlds.

---

## THE PRODUCTION PIPELINE
1. Artist exports asset to `res://assets_incoming/`.
2. Developer runs `PreImportAssetValidator.gd`.
3. If FAIL: Asset is rejected and deleted.
4. If PASS: Asset is moved to `res://assets/` and registered in `AssetManifestRegistry.gd` under its specific Layer category.

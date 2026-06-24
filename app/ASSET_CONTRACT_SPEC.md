# ASSET CONTRACT SPECIFICATION (PRIORITY 5)

**The Paradigm:**
Artists do not "add assets to the game." Artists submit asset candidates to a constrained measurement instrument. The interaction geometry is mathematically locked. Art is a perceptual substitution layer only.

## 1. The Invariant Boundary
- **Functional Layer (Immutable):** Hitboxes, Control bounds, Layout containers, Stimulus anchor positions. *These are owned by the code.*
- **Perceptual Layer (Variable):** Textures, Shaders, Color grading. *These are owned by the art team.*
- **The Rule:** Perceptual assets must *never* redefine functional geometry. A button's clickable area is defined by the engine, not the PNG's alpha channel.

## 2. Canonical Asset Definitions & Constraints
All incoming visual assets must strictly adhere to the following classes. Deviations will be rejected by the Pre-Import Validator.

### Class: StimulusSprite (e.g., Cognitive Targets, Memory Nodes)
- **Dimensions:** Exactly `128x128` pixels.
- **Anchor:** Centered origin only.
- **Padding Rule:** No transparent padding allowed. The visible pixels must touch the edge of the bounding box (or remain within a mathematically uniform circle).
- **Shadows:** No baked drop-shadows that extend the bounding box.

### Class: UIButtonFrame (e.g., Scenario Answers, Safe/Risk Decisions)
- **Dimensions:** Exactly `256x96` pixels.
- **Design Rule:** Border-only or solid fills. No interior spacing illusions that make the button "look" smaller than its physical hitbox.
- **Format:** Lossless PNG only.

### Class: BackgroundTile (e.g., Void Grids, Liquid Noise)
- **Dimensions:** `512x512` or `1024x1024`.
- **Design Rule:** Seamless tile only. No baked perspective distortion (perspective is handled by the 3D spatial stream or Shader math).

## 3. The Production Pipeline
1. Artist exports asset to `res://assets_incoming/`.
2. Developer runs `PreImportAssetValidator.gd`.
3. If FAIL: Asset is rejected and deleted.
4. If PASS: Asset is moved to `res://assets/` and registered in `AssetResolver.gd`.

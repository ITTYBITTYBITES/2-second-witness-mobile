# FINAL ASSET PRODUCTION MANIFEST
*The complete list of all missing art and audio assets required to bring 2 Second Witness to a fully polished, launch-ready state.*

---

## 1. THE PRIMARY ANCHOR (GLOBAL)
*The focal point of the entire application. Must be instantly recognizable and highly emissive.*
- [ ] **The Crystalline Iris (3D Model):** Low-poly geometric ring. Needs a clean UV unwrap for the emissive material.
- [ ] **Iris Core Void (Material/Shader):** The absolute black center that swallows the camera.

## 2. UNIVERSE ENVIRONMENTS (x6)
*The 6 Universes: Science Lab, Tech Ops, Life Sciences, Society & Mind, Frontier, Creative Arts.*
For **EACH** of the 6 Universes, the following must be produced:

**3D Geometry (Tunnel Streaming)**
- [ ] **Structural Rib (3D Model):** The repeating tunnel shape (e.g., Hexagon for Science Lab, Organic Membrane for Life Sciences). Max ~500 polys per chunk. `.glb` format.
- [ ] **Data Nodes (3D Model):** Small floating particles/debris that populate the inside of the tunnel chunk to give a sense of speed.

**2D Textures (ASSET_CONTRACT_SPEC: BackgroundTile)**
- [ ] **Seamless Background Noise:** `512x512` or `1024x1024` lossless `.png`. Must tile seamlessly for the shader to sample. (e.g., Soft Grid, Plasma Static, Nebula Dust).

## 3. COGNITIVE STIMULI (2D SPRITES)
*The icons and shapes used inside the Cognitive Spikes. (ASSET_CONTRACT_SPEC: StimulusSprite)*
- **Format Constraint:** Exactly `128x128` pixels, lossless `.png`, centered origin, NO transparent padding.
- [ ] **Science Lab / Tech Ops Set (x10):** Geometric, hard-angled shapes, neural nodes, circuitry icons.
- [ ] **Life Sciences Set (x10):** Organic shapes, cellular structures, bio-symbols.
- [ ] **Society & Mind / Creative Arts Set (x10):** Abstract ink shapes, Rorschach blots, philosophical symbols.
- [ ] **General UI Symbols (x5):** Warning icons, Checkmarks, Lock icons.

## 4. UI & TYPOGRAPHY
*The interface elements overlaying the simulation. (ASSET_CONTRACT_SPEC: UIButtonFrame)*
- **Format Constraint:** Exactly `256x96` pixels for standard buttons, border-only/glass designs.
- [ ] **Universe Button Frames (x6):** One specific button frame style per Universe (e.g., Frosted Glass for Science Lab, Sharp Neon for Tech Ops).
- [ ] **Typography (Fonts):** 2-3 `.ttf` or `.otf` font files.
    - 1x Primary "Technical/Diagnostic" Font (Monospace/Sans-serif).
    - 1x Secondary "Poetic/Organic" Font (For Creative Arts / Society).

## 5. VFX & PARTICLES (GPU/CPU DRIVEN)
*The visceral feedback systems. Must obey the 2-layer overdraw cap.*
- [ ] **The Slingshot Impulse:** Particle burst material triggered when ejecting from a scenario at 200% velocity.
- [ ] **Iris Tap Fracture:** A shattering particle effect when the player taps the Iris and the void opens.
- [ ] **Scenario Success Spark:** A clean, satisfying glow pulse for correct answers.
- [ ] **Scenario Error Glitch:** A harsh, visual chromatic aberration or glitch pulse for incorrect answers.

## 6. AUDIO DESIGN (THE PERCEPTUAL RHYTHM)
*Audio is 50% of the cognitive feedback loop. Must be compressed `.ogg` format.*
**Ambient Environment**
- [ ] **Universe Ambience Loops (x6):** Low-frequency, drone/ambient loops (30-60 seconds each). One for each universe.

**Interaction Stingers**
- [ ] **Iris Heartbeat:** A low, rhythmic mechanical pulse that speeds up as the camera gets closer to the Iris.
- [ ] **Iris Plunge:** A heavy, vacuum/suction sound when the player taps the Iris.
- [ ] **UI Success Hit:** A sharp, satisfying mechanical click (Tech) or organic chime (Life).
- [ ] **UI Error Buzz:** A jarring, low-frequency rejection buzz.
- [ ] **The Slingshot Drop:** A massive bass-drop/whoosh sound for the 200% velocity re-entry into the tunnel.

---
**PRODUCTION NOTE TO ARTISTS:**
Every 2D asset must pass the `PreImportAssetValidator.gd` tool. Any asset that deviates from the pixel dimensions or includes baked drop-shadows will be automatically rejected by the engine.

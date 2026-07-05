# 2 SECOND WITNESS: AI ART DIRECTION & BRANDING MANIFEST

If you are feeding this into an AI image generator (like Midjourney, DALL-E 3, or Stable Diffusion) to lock in the final visual identity of the app, use the following prompts. They are engineered to produce assets that perfectly match the *2 Second Witness* architecture.

---

## 1. THE APP ICON (The App Store Face)
*This is the most important asset. It must communicate "Mirror" instantly.*

**AI Prompt:**
> A sleek, minimalist, ultra-modern app icon design for a sci-fi cognitive testing application. A glowing, perfect geometric neon-cyan ring (an iris) hovering in a deep, dark blue void. Inside the center of the ring is absolute, pitch-black nothingness. The aesthetic is "2 Second Witness" — clinical, high-tech, yet mysterious. Vector art style, flat but with intense neon bloom, dark mode, high contrast, UI/UX design, masterpiece.

---

## 2. THE BACKGROUND TEXTURES (The Tunnel Noise)
*These must be seamless 1024x1024 tiles. Do not use perspective in the prompt, or it will break the Godot shader math.*

**AI Prompt - Science Lab (Grid):**
> A seamless, tiling background texture. A deep, dark space-blue void overlaid with a very faint, glowing neon-cyan geometric wireframe grid. Minimalist, clinical, high-tech, UI background, flat, 2D, repeating pattern. 

**AI Prompt - Life Sciences (Organic):**
> A seamless, tiling background texture. A pitch-black void filled with extremely faint, overlapping organic cellular rings glowing in soft neon green. Abstract, microscopic, bio-tech, minimalist UI background, flat, 2D, repeating pattern.

**AI Prompt - Tech Ops (Mechanical):**
> A seamless, tiling background texture. Absolute black background overlaid with sharp, horizontal glowing neon green scanlines and faint binary data noise. Cyberpunk, hacking interface, minimalist UI background, flat, 2D, repeating pattern.

---

## 3. THE COGNITIVE STIMULI (The Scenario Targets)
*These are the 128x128 icons the player interacts with during the cognitive spikes.*

**AI Prompt - Geometric Shapes (Science Lab):**
> A set of simple, minimalist, flat geometric shapes (hexagon, diamond, circle) glowing in bright neon cyan against a pure black background. UI/UX iconography, vector art, high contrast, sharp edges, no drop shadows, clean, modern sci-fi.

**AI Prompt - Organic Shapes (Life Sciences):**
> A set of simple, minimalist, flat organic cellular blob shapes glowing in bright neon green against a pure black background. UI/UX iconography, vector art, high contrast, smooth curves, no drop shadows, clean, modern bio-tech.

**AI Prompt - Rorschach Blots (Society & Mind):**
> A set of simple, minimalist, flat abstract ink blots and Rorschach shapes glowing in warm pale gold against a pure black background. UI/UX iconography, vector art, high contrast, mysterious, no drop shadows, clean.

---

## 4. THE PROMOTIONAL HERO IMAGE (For the App Store / Itch.io)
*This is the screenshot/banner that sells the product.*

**AI Prompt:**
> A first-person view flying at high speed through a dark, flowing, liquid-plasma sci-fi tunnel. The lighting is deep blue and neon cyan. In the exact center of the screen, floating in the tunnel, is a massive, glowing, razor-sharp cyan ring with a pitch-black center. The ring is surrounded by sleek, frosted-glass holographic UI panels displaying cognitive data metrics. Unreal Engine 5 style, cinematic lighting, masterpiece, video game screenshot, visceral momentum.

---

### HOW TO USE THESE ASSETS IN GODOT
1. Generate the images.
2. If the AI adds messy backgrounds to the UI icons or App Icon, use a tool like `remove.bg` to strip the background to pure transparency.
3. Resize them to the exact dimensions specified in `ASSET_CONTRACT_SPEC.md` (e.g., 512x512 for Backgrounds, 128x128 for Stimuli).
4. Drop them into the `assets_incoming/` folder.
5. Run the `PreImportAssetValidator` tool in Godot.

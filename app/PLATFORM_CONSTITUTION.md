# 2 SECOND WITNESS: PLATFORM CONSTITUTION
**The Immutable Laws of the 2 Second Witness Engine**

This document is not a guide. It is the hard constraint layer that prevents structural decay as the platform scales. Any Pull Request or code change that violates these axioms must be immediately rejected.

---

## 1. THE PERCEPTUAL VS. FUNCTIONAL BOUNDARY (THE WORLD CONTRACT)
A World is permitted to drastically alter the *perception* of a cognitive task, but it is strictly forbidden from altering the *functional geometry* or *timing* of the task in a way that invalidates cross-world psychometric data.

**A. Allowed (Perceptual Modulation):**
- **Colors & Lighting:** Altering palettes, fog density, bloom, and shaders.
- **Audio:** Pitch-shifting UI sounds, changing ambient tracks, adding reverb.
- **Entry Animations:** Altering how UI elements appear on screen (e.g., drifting up from the bottom vs. snapping into place), provided the animation completes *before* the 2-second timer begins.
- **Spatial Positioning (With Strict Constraints):** Moving buttons further apart or closer together, provided the relative Fitts's Law traversal distance (Mouse/Thumb travel time) remains within a globally accepted standard deviation.

**B. Forbidden (Functional Corruption):**
- **Hitbox Alteration:** A World cannot make a button smaller or larger to "increase difficulty." Hitbox sizes are globally invariant (defined by the Asset Contract).
- **Timer Manipulation:** A World cannot shorten the 2-second cognitive spike timer.
- **Continuous Motion During Task:** A World cannot cause UI buttons to drift or move *after* the 2-second timer has started. (e.g., The Physics "velocity trajectories" concept may animate the buttons *into* place, but they must lock position the moment the player is allowed to answer). 
- **Information Obfuscation:** A World cannot use a font that is mathematically harder to read, or reduce the opacity of a button below the global accessibility threshold. 

---

## 2. IMMUTABILITY RULES (THE SEPARATION OF CONCERNS)

**A. The WITNESS ENGINE (Logic & State) MUST NEVER:**
- Render pixels, shaders, or UI elements.
- Define universe-specific behavior or aesthetics.
- Interpret Iris Lens Profiles.

**B. The IRIS ENGINE (Perception & Rendering) MUST NEVER:**
- Mutate global state or player progression.
- Validate scenario answers or enforce the 2-second rule.
- Emit cognitive events beyond display mapping.

**C. The SCENARIO LAYER (Content) MUST NEVER:**
- Define its own rendering logic or custom shaders.
- Access or modify persistent player state directly.
- Bypass the Event Reducer.

---

## 3. ALLOWED COMMUNICATION PATHS
Lateral communication between subsystems is strictly forbidden. 
The data flow is a one-way street:

1. `SCENARIO DATA` -> `WITNESS ENGINE`
2. `WITNESS ENGINE` -> `EVENT REDUCER` -> `STATE UPDATE`
3. `STATE` -> `IRIS ENGINE` (Rendering Only)

---

## 4. FORBIDDEN PATTERNS (ANTI-REGRESSION)
- **UI-Triggered State Mutation:** A button click cannot update the `PlayerProfile` directly. It must emit an event to the Reducer.
- **Scenario-Specific Shaders:** A scenario cannot bundle its own `.gdshader`. It must request an Intensity Level from the Iris Engine.
- **Ad-Hoc Event Types:** Do not invent new signals for a specific world. Use the established Event Taxonomy.
- **Per-Universe Logic in Core:** Do not write `if universe == "tech_ops"` inside the Witness Engine. Core logic is universal.

---

## 5. THE OBSERVABILITY MANDATE
To ensure the 2-Second rule remains valid at scale, the **Engine Telemetry Layer** must silently track:
- Reaction time distributions (P50/P95/P99).
- Scenario failure rates across different Universes (to detect perceptual bias).
- Iris Intensity frequency.
*If "Tech Ops" scenarios show a 20% higher failure rate than "Science Lab" scenarios on identical data, the Iris Engine is failing its optical neutrality requirement.*

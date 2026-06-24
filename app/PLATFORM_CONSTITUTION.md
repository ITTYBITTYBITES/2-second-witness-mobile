# 2 SECOND WITNESS: PLATFORM CONSTITUTION
**The Immutable Laws of the Liquid Memory Engine**

This document is not a guide. It is the hard constraint layer that prevents structural decay as the platform scales. Any Pull Request or code change that violates these axioms must be immediately rejected.

---

## 1. IMMUTABILITY RULES (THE SEPARATION OF CONCERNS)

**A. The WITNESS ENGINE (Logic & State) MUST NEVER:**
- Render pixels, shaders, or UI elements.
- Define universe-specific behavior or aesthetics.
- Interpret Iris Lens Profiles.
- *Role:* It is the pure mathematical core. It processes events, validates truth, and updates state.

**B. The IRIS ENGINE (Perception & Rendering) MUST NEVER:**
- Mutate global state or player progression.
- Validate scenario answers or enforce the 2-second rule.
- Emit cognitive events beyond display mapping.
- *Role:* It is a dumb optical subsystem. It receives data and renders it.

**C. The SCENARIO LAYER (Content) MUST NEVER:**
- Define its own rendering logic or custom shaders.
- Access or modify persistent player state directly.
- Bypass the Event Reducer.
- *Role:* It is a read-only data packet fed into the Witness Engine.

---

## 2. ALLOWED COMMUNICATION PATHS
Lateral communication between subsystems is strictly forbidden. 
The data flow is a one-way street:

1. `SCENARIO DATA` -> `WITNESS ENGINE`
2. `WITNESS ENGINE` -> `EVENT REDUCER` -> `STATE UPDATE`
3. `STATE` -> `IRIS ENGINE` (Rendering Only)

*Bypass channels or "quick UI hooks" into the state machine are banned.*

---

## 3. FORBIDDEN PATTERNS (ANTI-REGRESSION)
The following architectural anti-patterns will destroy the scalability of the platform and are explicitly banned:
- **UI-Triggered State Mutation:** A button click cannot update the `PlayerProfile` directly. It must emit an event to the Reducer.
- **Scenario-Specific Shaders:** A scenario cannot bundle its own `.gdshader`. It must request an Intensity Level from the Iris Engine.
- **Ad-Hoc Event Types:** Do not invent new signals for a specific world. Use the established Event Taxonomy.
- **Per-Universe Logic in Core:** Do not write `if universe == "tech_ops"` inside the Witness Engine. Core logic is universal.

---

## 4. THE OBSERVABILITY MANDATE
To ensure the 2-Second rule remains valid at scale, the **Engine Telemetry Layer** must silently track:
- Reaction time distributions (P50/P95/P99).
- Scenario failure rates across different Universes (to detect perceptual bias).
- Iris Intensity frequency.
*If "Tech Ops" scenarios show a 20% higher failure rate than "Science Lab" scenarios on identical data, the Iris Engine is failing its optical neutrality requirement.*

# Canonical Knowledge Object (CKO) Specification v3.0
**Project:** 2 Second Witness  
**Status:** AUTHORITATIVE STANDARD  
**Version:** 3.0 (Entity-Centric Recognition Model)

## 1. Overview
The CKO v3.0 is a universe-agnostic knowledge representation designed for high-speed cognitive recognition. It moves away from trivia (Questions/Answers) toward **Entity Modeling**. Every CKO describes a real-world object, concept, or phenomenon in a way that an Observation Engine can transform into multiple gameplay mechanics (Stroop, OddOneOut, Classification) at runtime.

## 2. Core Schema Structure

| Field | Type | Description |
| :--- | :--- | :--- |
| `observation_id` | String | Global unique identifier (`[universe]_[world]_[sub]_[index]`). |
| `entity` | String | The primary subject name (e.g., "Carrara Marble"). |
| `entity_type` | String | The functional category (Material, Technique, Tool, Failure, Style). |
| `features` | Object | High-density recognition traits (Visual, Physical, Semantic). |
| `dimensions` | Object | Standardized mapping for cross-cutting comparison (Creator, Period, Region). |
| `confusions` | Array | Highly confusable entities for uncertainty-driven distractors. |
| `difficulty` | Integer | 1 (Immediate Recognition) to 5 (Expert Discrimination). |
| `confidence` | Object | Weighting of feature recognizability (High, Medium, Low). |

---

## 3. The Features Block
CKOs must separate features by their cognitive recognition type:

### 3.1 Visual Features
*Computer-vision style traits.*
- Examples: `{"grain": "fine_sugary", "luster": "waxy", "color": "#F8F8FF"}`

### 3.2 Physical Features
- Hard properties/data.*
- Examples: `{"hardness_mohs": 3.0, "composition": "calcite", "fracture": "cleavage"}`

### 3.3 Semantic/Contextual Features
*Abstract meanings, origins, and temporal data.*
- Examples: `{"origin": "Apuan Alps", "prestige": "high", "usage": "statuary"}`

---

## 4. Standardized Recognition Dimensions
Every world must map its entities to these standard dimensions to allow the `ObservationBuilder` to pivot scenarios:

- **Entity**: The unique subject.
- **Category**: The group it belongs to.
- **Material**: What it is made of.
- **Technique**: How it is formed/made.
- **Style/Movement**: The aesthetic fingerprint.
- **Period**: When it existed.
- **Region**: Where it originated.
- **Signature**: The single most recognizable visual cue.

---

## 5. Confidence Weighting
Maps specific attributes to their "Observational Clarity":
- **High**: Instant recognition (The "Signal").
- **Medium**: Requires focused attention.
- **Low**: Expert-level nuance (The "Noise").

---

## 6. Transformation Logic (Observation Engine)
The `ObservationBuilder` uses the CKO to synthesize mechanics:

- **Stroop Test**: Pits `dimensions.Material` (Semantic) vs `features.visual.color` (Visual).
- **Odd One Out**: Takes 3 entities from `confusions` and 1 `entity`.
- **Rapid Classification**: Validates if `entity` belongs to `dimensions.Category`.
- **Signal vs Noise**: Presents `features.visual` traits with increasing `confidence` levels based on difficulty.

---

## 7. Example CKO (Marble Pilot)
```json
{
  "observation_id": "creative_arts_sculpture_marble_0006",
  "entity": "Sugaring",
  "entity_type": "Failure Mode",
  "features": {
    "visual": ["granular crystalline breakdown", "loss of surface polish", "sand-like texture"],
    "physical": ["intergranular decohesion", "thermal expansion shock"],
    "semantic": ["weathering", "disintegration", "terminal decay"]
  },
  "dimensions": {
    "Category": "Conservation Issues",
    "Material": "Marble",
    "Signature": "Granulated crystalline surface"
  },
  "confusions": ["Salt Efflorescence", "Surface Spalling", "Acid Etching"],
  "difficulty": 3,
  "confidence": {
    "granular_breakdown": "High",
    "decohesion": "Low"
  }
}
```

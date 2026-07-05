# World Content Template

**Purpose:** Reusable authoring specification for every world. World #190 should feel identical to World #2.

---

## Format Decision: v3_entity

All new worlds use **v3_entity format** — one entity serves all 5 mechanics via polymorphic projection. This is the format the frozen compiler, snapshot system, and coverage maps are built for.

```json
{
  "observation_id": "<universe>_<world>_<subcategory>_<NNNN>",
  "universe": "<universe>",
  "world": "<world>",
  "subcategory": "<theme>",
  "entity": "<the thing being observed>",
  "entity_type": "<classification>",
  "features": {
    "visual": {"color": "#hex", "pattern": "<descriptive>"},
    "physical": {"<key>": "<value>"}
  },
  "dimensions": {
    "Category": "<taxonomic group>",
    "Signature": "<distinguishing feature>",
    "Material": "<composition>"
  },
  "confusions": ["<distractor1>", "<distractor2>", "<distractor3>"],
  "difficulty": <1-5>,
  "confidence": {"classification": "High|Medium"}
}
```

**Why v3_entity over v1 (rules-based):** one entity automatically serves rapid_classification, signal_vs_noise, odd_one_out, stroop_test, and memory_cascade. No per-observation mechanic assignment. Authoring volume = number of entities, not number of mechanic-specific questions.

---

## Per-World Authoring Specification

| Section | Purpose | Required? |
|---|---|---|
| **Historical scope** | Exact time period and geographic focus | Yes |
| **Learning goals** | What the player should recognize or distinguish | Yes |
| **Entity inventory** | People, objects, places, symbols, architecture, etc. | Yes |
| **Feature coverage** | Which observable features are represented (Category, Signature, Material, visual color) | Yes |
| **Mechanic coverage** | Which mechanics the world intentionally supports (target: ≥3) | Yes |
| **Difficulty progression** | How entities evolve from introductory (tier 1) to expert (tier 5) | Yes |
| **Validation notes** | Sources, ambiguities, exclusions | Yes |

---

## Subcategory Pattern (target 6-8 per world)

Each world is organized into thematic subcategories. For a history world:

| Subcategory type | Examples |
|---|---|
| **People** | rulers, philosophers, military leaders |
| **Mythology/Religion** | gods, temples, rituals |
| **Architecture** | buildings, monuments, engineering |
| **Military** | battles, weapons, tactics |
| **Daily life** | clothing, food, currency, writing |
| **Geography** | cities, rivers, regions |

---

## Difficulty Distribution Target

| Tier | Label | Target % | Content type |
|---|---|---|---|
| 1 | beginner | 15-20% | Most recognizable entities |
| 2 | easy | 25-30% | Well-known facts |
| 3 | intermediate | 25-30% | Requires some knowledge |
| 4 | advanced | 15-20% | Specialist knowledge |
| 5 | expert | 5-10% | Obscure but verifiable |

No single tier exceeds 60% (DoD criterion #5).

---

## Entity Count Target

| World density | Entity count | Notes |
|---|---|---|
| Minimum (DoD) | 50 | Bare minimum for coverage |
| Standard | 70-100 | Rich world, good variety |
| Reference quality | 100+ | Exemplary world |

---

## Validation Checklist (per world, before publishing)

- [ ] All entities have: observation_id, universe, world, entity, entity_type, features, dimensions, confusions, difficulty
- [ ] All dimensions present: Category, Signature, Material
- [ ] All features.visual entries have color + pattern
- [ ] All confusions arrays have ≥3 entries
- [ ] No duplicate observation IDs
- [ ] No placeholder patterns
- [ ] Difficulty distribution within targets
- [ ] Feature Graph Snapshot: zero unresolved required features
- [ ] Coverage: ≥50% per intended mechanic
- [ ] Regression suite: 40/40 unchanged

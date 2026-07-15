# Scene Creation Guidelines — Flagship Scene Investigation

**Purpose:** provide a content and fairness framework for future Witness Moments.
**Scope:** scene categories, visual identity, density, targets, questions, difficulty, and acceptance standards.

---

# 1. Scene purpose

A flagship scene is not a decorative background and not a hidden-object puzzle. It is an **ordinary moment arranged so that broad attention can uncover one fair, memorable fact after the moment is gone.**

Every scene must support three experiences:

1. a readable first glance;
2. a surprising but fair question;
3. an evidence reveal that makes the player see the scene differently.

---

# 2. Scene categories

## Current category family

The existing categories are the correct starting world because they are ordinary, legible, and expandable:

| Scene category | Witness fantasy | Current content basis | Good question territory |
|---|---|---|---|
| **Office / Desk** | Notice the trace of work and routine. | Office scene/object set. | Writing tools, folders, desk relationships, counts, positions. |
| **Kitchen / Counter** | Notice the arrangement of preparation and everyday use. | Kitchen scene/object set. | Containers, utensils, food groups, item placement. |
| **Workshop / Bench** | Notice tools, materials, and practical relationships. | Workshop scene/object set. | Tool identity, direction, grouped hardware, adjacency. |
| **Travel Desk** | Notice preparation, documents, and packed essentials. | Travel Desk scene/object set. | Documents, accessories, containers, positional relations. |
| **Garden Bench** | Notice care, materials, and outdoor work. | Garden Bench scene/object set. | Plant-care tools, containers, grouped materials, presence/count. |

## Future category rule

A new scene category should be added only if it creates a new **ordinary observation grammar**, not merely new art. It must answer:

- What familiar anchor surface organizes the player’s scan?
- What object groups create meaningful fair questions?
- What relationships are unique to this place?
- What kind of reveal will make the player look again?
- Does it avoid specialist knowledge, small-text reading, cultural ambiguity, or visual clutter?

Do not add scenes only to imitate the trailer’s darker detective imagery. The playable product’s strength is ordinary evidence made interesting.

---

# 3. Visual style direction

## Desired identity: editorial evidence, not noir simulation

The visual direction should feel premium, grounded, and tactile:

- ordinary surfaces with clear material character;
- warm, restrained scene palettes;
- objects with readable silhouettes and directional shadows;
- a calm dark surrounding stage that makes the scene feel important;
- evidence accents that are distinct without looking like a game-show reward.

The current sprite-first pipeline, vector fallback, grounded scene backgrounds, and warm evidence accent provide a practical base. The gameplay scene should feel more like a carefully composed witnessed moment than a flat icon tray or a photoreal crime drama.

## Scene/world consistency

- The eye/witness motif belongs to the product frame, not inside every object scene.
- The scene should not imply a crime/story event the player is never asked to understand.
- Scene art must support the nouns used in questions and explanations.
- Decorative atmosphere is allowed only when it improves place/readability; it cannot become camouflage.

---

# 4. Composition standards

## Required composition elements

Every scene needs:

1. **One primary anchor** — desk, counter, bench, table, shelf, or work surface.
2. **Three scan zones** — left/center/right, foreground/middle/background, or an equally legible structure.
3. **Two to four object groups** — visually separated collections with meaningful relations.
4. **Protected evidence space** — question-eligible objects remain inside safe visual bounds and clear of overlap/crop.
5. **Intentional negative space** — enough breathing room that a player can parse the scene in a short exposure.

## Object placement rules

- Place objects because they form a readable relationship, not to fill empty pixels.
- Avoid severe overlap for question-eligible objects.
- Keep small target candidates near a larger anchor or group; no isolated tiny item in background texture.
- Use repeated objects only when count/repetition is the intended fair challenge.
- Keep decorative items semantically distinct from answer options when possible.
- Do not make one visual zone materially denser than all others unless the question/reveal supports that choice fairly.

## Scale and contrast rules

- The target must occupy a meaningful portion of the scene at its declared tier.
- Target/background contrast must survive common mobile displays and high-contrast modes.
- Do not rely on hue alone; reinforce key distinctions with silhouette, position, grouping, label, luminance, or state.
- Preserve readable outlines/shadows under the active renderer and fallback renderer.

---

# 5. Detail density and difficulty tiers

## Density is not difficulty by itself

More objects do not automatically create a better Witness Moment. A scene is difficult only when its question requires a more demanding but still fair observation decision.

| Tier | Question-eligible objects | Decoration | Typical question | Exposure direction | Primary design lesson |
|---|---:|---:|---|---|---|
| **First / onboarding** | 6–8 | Minimal | Presence, clear count, direct position. | 4.0 s | Learn scene zones and evidence reveal. |
| **Familiar** | 8–10 | Light | Attribute, simple adjacency, grouped count. | 3.0 s | Learn broad scanning. |
| **Standard** | 8–12 | Light–moderate | Position, adjacency, clear relation. | 2.0 s | Deliver the signature Witness Moment. |
| **Advanced** | 12–16 | Moderate | One precise relation or plausible similarity. | 1.8–2.0 s | Reward structured scanning. |
| **Expert** | 16–20 | Moderate, never foggy | High-similarity but unambiguous relation/count. | 1.6–2.0 s | Test efficient broad observation, not eye strain. |

## Difficulty sequencing rule

Increase one main burden axis at a time:

- density;
- similarity;
- relationship complexity;
- target scale;
- exposure duration.

Never combine maximum density, minimum exposure, high similarity, small target, and deep relationship in one round. The current difficulty policy supports independent axes; content tuning must use that flexibility responsibly.

---

# 6. Fair versus unfair details

## Fair target characteristics

A target is fair when it is:

- visible in full during the observation interval;
- clear in silhouette and player naming;
- located in a stable scan zone;
- distinct enough at the declared difficulty;
- not hidden by a UI element, crop, shadow, or object overlap;
- supported by a precise scene truth entry and reveal geometry;
- answerable through visible information, not inference/special knowledge.

## Unfair target characteristics

Do not create questions whose answer depends on:

- tiny printed labels or unreadable text;
- almost identical colors without redundant distinction;
- highly ambiguous object names;
- edge cropping, unsafe display areas, or background clutter;
- a difference only visible during a decorative animation frame;
- a question phrased more cleverly than the scene can support;
- cultural/specialist knowledge that is not visibly represented.

---

# 7. Memory target and question framework

## Target selection hierarchy

Choose a question only after scene truth is complete. The question generator should prefer, in order:

1. a relation anchored to an obvious object;
2. a grouped count with clear members;
3. a visible attribute on a distinct object;
4. direct presence/absence;
5. a more precise position/relation only at higher familiarity.

## Question rules

- One fact per round.
- One correct answer.
- Distinct, plausible distractors drawn from visible scene semantics.
- The question must be resolvable from the actual generated scene, never a content assumption.
- The explanation must be generated from the same truth used to score the answer.
- The reveal must identify every object/relationship required by the question.

## Distractor rules

Good distractors make the player consult memory. Bad distractors make the answer obvious or ambiguous.

- Use objects from the same scene category when plausible.
- Do not use multiple labels for the same visible object.
- Do not include bizarre/unrelated nouns merely to make options easy.
- For counts, choose nearby plausible numbers; ensure the visible group is countable.
- For relationships, use stable anchors and mutually exclusive positions.

---

# 8. Scene acceptance checklist

A scene/template/content set is ready for a Witness Moment only when:

- [ ] It has a clear ordinary-place identity and anchor surface.
- [ ] It supports at least three legal question categories with distinct player decisions.
- [ ] Question-eligible objects have readable art, naming, scale, and contrast.
- [ ] The scene has three scan zones and protected evidence space.
- [ ] Decorative density cannot obscure legal targets.
- [ ] Generation produces a truth graph before question selection.
- [ ] Validator checks overlap, unique answer, distractor quality, exposure, and reveal completeness.
- [ ] It works in High Contrast, Color Assistance where relevant, Reduced Motion, text scaling, and target device safe areas.
- [ ] A representative seed batch passes structural validation.
- [ ] First-time and returning players judge misses as fair at the declared tier.
- [ ] The scene adds a distinct observation grammar or content world, not merely a new background.

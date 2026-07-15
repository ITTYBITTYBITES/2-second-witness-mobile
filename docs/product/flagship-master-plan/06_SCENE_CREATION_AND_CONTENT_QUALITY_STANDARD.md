# Scene Creation and Content Quality Standard

**Purpose:** the production bible for flagship Scene Investigation content.
**Rule:** a scene is not ready because it renders or validates. It is ready when it creates a fair, surprising, explainable, replayable Witness Moment.

---

# 1. Scene quality promise

Every flagship scene should make a player feel that an ordinary place contains more to notice than it first appears.

A scene must deliver four outcomes:

1. **Visual quality:** it is interesting and place-specific.
2. **Fairness:** the relevant detail can reasonably be noticed at its declared tier.
3. **Surprise:** the reveal changes how the player sees the scene.
4. **Explanation:** the player understands why the answer was true.

Replay value comes from varied but coherent evidence relationships, not from random clutter or hidden trivia.

---

# 2. Required scene grammar

## Ordinary-world categories

Current scene worlds—Office, Kitchen, Workshop, Travel Desk, Garden Bench—are the production baseline. New worlds require a distinct observation grammar, not only a new background.

A category proposal must answer:

- What stable anchor surface/place makes this scene instantly readable?
- What object groups and relationships naturally belong here?
- What visible question types can be fair in this world?
- What does the player see again differently at reveal?
- How is it distinct from existing worlds without requiring specialized knowledge?

## Three-zone composition

Every scene contains:

1. **Anchor zone:** large familiar structure establishing the place.
2. **Action zone:** primary group where meaningful objects/relations occur.
3. **Peripheral zone:** secondary evidence that rewards complete scan but never becomes a trap.

The zones teach a fair macro-to-micro scan without exposing the answer.

## Required visual hierarchy

| Layer | Role | Rule |
|---|---|---|
| Anchor landmarks | Orient player/place. | 1–2 large readable forms. |
| Question-eligible objects | Supply possible truth. | Visible, named, contrast-safe, inside legal bounds. |
| Relationship groups | Support count/position/adjacency/container questions. | 2–4 distinct clusters with protected space. |
| Decoration | Add lived-in atmosphere. | Never obscure, duplicate, or outcompete evidence. |
| Scene stage | Supports focus/contrast. | Frame must not crop or cover legal evidence. |

---

# 3. Difficulty and density standard

## Independent difficulty axes

Difficulty may vary:

- number of question-eligible objects;
- decorative density;
- object similarity;
- target scale;
- relationship depth;
- exposure duration;
- distractor plausibility.

It must not increase every axis at once.

| Tier | Eligible objects | Decoration | Question demand | Exposure guidance |
|---|---:|---:|---|---|
| First moment | 6–8 | Minimal | Presence, clear count, direct position | 4.0 s |
| Familiar | 8–10 | Light | Attribute, simple adjacency/grouped count | 3.0 s |
| Standard | 8–12 | Light–moderate | Position, adjacency, clear relation | 2.0 s |
| Advanced | 12–16 | Moderate | One precise relation/plausible similarity | 1.8–2.0 s |
| Expert | 16–20 | Moderate, never foggy | High similarity but unambiguous relation/count | 1.6–2.0 s |

Comfortable Timing remains an equivalent accessibility accommodation, not a separate progression track.

---

# 4. Fairness standard

## A legal target must be

- fully visible during observation;
- readable in shape, contrast, and player-language naming;
- placed inside safe display bounds;
- large enough for declared tier;
- not hidden by overlap, crop, overlay, or decorative effect;
- answerable without tiny text, specialized knowledge, or hue-only discrimination;
- represented in resolved scene truth and precise reveal data;
- supported by plausible but distinct distractors.

## Prohibited content patterns

- microscopic labels, dates, serial numbers, brand names, or readable fine print;
- color-only correct answers without redundant cue;
- edge-clipped/unsafe-area evidence;
- one-frame animation state as answer truth;
- objects with ambiguous player names/options;
- repeated visual shapes that make one answer unknowable;
- non-diegetic decoration mistaken for target evidence;
- question wording more clever than the scene supports.

---

# 5. Question and explanation standard

## Approved question categories

| Category | Good use | Explanation form |
|---|---|---|
| Presence | Early onboarding/direct recognition. | Object + location. |
| Count | Small visible groups. | Number + visible group/anchor. |
| Attribute | Clearly visible state/material/color with redundancy. | Object + attribute + location. |
| Position | Stable anchor relation. | Object + left/right/on/near relation. |
| Adjacency | Two readable objects. | Both object names + relation. |
| Container/region | Clear boundary/containment. | Item + container/region. |

## Question rules

- One fact per Witness Moment.
- One unambiguous correct answer.
- Generated from completed truth graph, not rendering inference.
- Uses nouns the art clearly supports.
- Keeps options short, plausible, distinct, and readable.
- Does not disclose target category during normal observation.
- Has a one-sentence factual reveal explanation and target geometry before shipping.

---

# 6. Asset standard

## Backgrounds

- Establish place/anchor with enough material character to feel ordinary and premium.
- Leave protected object zones; avoid texture noise behind likely targets.
- Work in portrait scene stage and target safe areas.
- Have versioned source, processed output, import settings, and review state.

## Objects

- Stable content/object IDs and player-readable names.
- Consistent visual scale and silhouette quality.
- Transparent processed sprites when used; vector fallback remains legible.
- No baked evidence highlight that conflicts with dynamic reveal.
- State/color variants documented with accessibility constraints.
- Asset references resolve in packaged Android build.

## Evidence states

- Generated from truth/reveal data, not manually guessed after rendering.
- High-contrast and Reduced Motion equivalents documented.
- Must not cover object/anchor relationship.
- Count/group evidence marks all required members.

---

# 7. Review process

```text
Scene concept
→ composition prototype
→ object/anchor/density review
→ question/reveal design
→ generated-seed validation
→ visual contact-sheet review
→ device/accessibility review
→ human fairness/replay review
→ production approval
```

## Required reviewers

| Review | Owner focus |
|---|---|
| Content design | Distinct observation grammar, question variety, replay value. |
| Art direction | Ordinary-world quality, hierarchy, assets, scene coherence. |
| Gameplay/fairness | Truth graph, targets, distractors, difficulty axes, reveal completeness. |
| Accessibility | Contrast, color independence, text, motion, touch/visual readability. |
| QA/engineering | Seed validation, fallback, assets/imports, memory/performance, device behavior. |
| Player research | Perceived fairness, surprise, explanation, fatigue, voluntary replay. |

---

# 8. Approval criteria

A scene/template/world is production-approved only when all are true:

## Visual quality

- [ ] Scene is immediately recognizable as an ordinary place.
- [ ] Anchor/action/peripheral zones are legible in a short glance.
- [ ] Objects/readable silhouettes maintain a cohesive art direction.
- [ ] Decoration makes the world richer without fogging evidence.

## Fairness

- [ ] All legal targets pass visibility/contrast/scale/safe-area checks.
- [ ] Difficulty changes one main burden axis at a time.
- [ ] Distractors are plausible but distinct.
- [ ] Generator/validator/fallback pass representative seed batches.

## Surprise and explanation

- [ ] Reveal changes how a player sees the scene.
- [ ] Evidence target exactly proves answer truth.
- [ ] Explanation is factual and player-readable.
- [ ] Correct/missed outcomes are equally understandable.

## Replay value

- [ ] Template has a distinct player decision.
- [ ] Scene produces meaningful variation across composition/question/seed.
- [ ] No immediate signature/template repetition in normal runtime.
- [ ] Human 20/50-round evidence shows no unacceptable fatigue/confusion.

## Release readiness

- [ ] Assets are packaged, imported, optimized, and credited where needed.
- [ ] Device/accessibility matrix is passed.
- [ ] Store/runtime screenshots reflect actual final scene quality.

---

# 9. Scope control

Do not add a new scene world merely because it is visually attractive. It must deepen the Witness Moment. Do not add content volume until existing scenes meet this standard. Do not sacrifice target fairness or device performance to create a denser-looking scene.

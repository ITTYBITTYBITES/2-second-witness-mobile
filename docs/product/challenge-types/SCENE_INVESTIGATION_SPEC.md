# Scene Investigation — Challenge Type Specification

**Status:** Production-complete; expanded in Phase 5.5
**Implementation:** Office, Kitchen, Workshop, Travel Desk, and Garden Bench complete; physical-device review pending
**Internal family ID:** `scene_investigation`
**Player-facing name:** Scene Investigation
**Specification version:** 1.0

## 1. Identity

### Player-facing description

> Study a scene for a few seconds. When it disappears, answer one question about what you noticed.

### Gameplay focus

- Observation
- Recall
- Attention to detail
- Recognition
- Spatial reasoning

### Gameplay fantasy

The player is a sharp witness examining an ordinary moment. The scene is brief, the question is specific, and the reveal makes the overlooked detail immediately understandable.

The desired reaction is:

> “I can’t believe I missed that.”

Never:

> “There was no fair way to know that.”

## 2. Player Goal

Notice enough reliable information during a short scene presentation to answer one fair question after the scene disappears.

The player is not told the exact question in advance. The scene must therefore provide a manageable amount of readable information rather than hiding one arbitrary detail among noise.

## 3. Core Gameplay Loop

```text
Brief
→ Observe generated scene
→ Scene disappears
→ Memory moment
→ One question
→ Player answer
→ Scene reveal with evidence highlight
→ Result and Witness Progress
→ Recommended next challenge
→ Play Again or Home
```

### Brief

A short label identifies the scene category without revealing the question, for example `OFFICE` or `WORKSHOP`.

### Observe

The scene appears for the resolved exposure duration. A restrained progress indicator communicates remaining time without covering scene content.

### Memory moment

A 250–400 ms neutral transition separates observation from the question. It must respect reduced-motion settings.

### Question

One question and one response set appear. Initial production templates use single-choice responses.

### Reveal

The original scene returns. The relevant object, count set, attribute, or relationship receives a clear highlight. The explanation identifies where the evidence appeared.

## 4. Initial Template Categories

Gate 3 originally implemented Office, Kitchen, and Workshop. Phase 5.5 adds Travel Desk (`travel_desk_v1`) and Garden Bench (`garden_bench_v1`) as two ordinary, non-narrative settings with unique illustrated backgrounds and 24 archetypes each. Museum, Vehicle, and the original Outdoor Scene proposal remain deferred.

### 4.1 Office

**Template ID:** `office_desk_v1`

**Composition:** Desk surface, rear wall/shelf, left work zone, center focus zone, right accessory zone.

**Required object groups:**

- Writing tools
- Paper/notebooks
- Drink container
- Timekeeping or desk device
- Personal accessory

**Object pool examples:** Pencil, pen, marker, notebook, folder, paper stack, mug, bottle, glasses, keys, calculator, stapler, tape, phone, clock, plant, ruler, paper clip container.

**Change opportunities:** Color, count, left/right placement, open/closed notebook, stacked/unstacked paper, repeated writing tool, adjacency.

**Allowed questions:** Count, color/attribute, position, adjacency, presence, repeated object.

**Difficulty variables:** Writing-tool similarity, paper clutter, small accessory count, target size, color similarity.

### 4.2 Kitchen

**Template ID:** `kitchen_counter_v1`

**Composition:** Counter surface, rear shelf/backsplash, preparation zone, serving zone.

**Required object groups:**

- Food item
- Container
- Utensil
- Drinkware
- Preparation object

**Object pool examples:** Bowl, plate, mug, glass, spoon, fork, knife, cutting board, towel, jar, kettle, fruit varieties, bread, spice container, measuring cup, whisk, pan, bottle.

**Change opportunities:** Food count, container color, utensil position, item inside/outside container, repeated fruit, adjacency to cutting board.

**Allowed questions:** Count, color/attribute, position, adjacency, presence, container relationship.

**Difficulty variables:** Similar food shapes, utensil similarity, container overlap limits, counter clutter, repeated colors.

### 4.3 Workshop

**Template ID:** `workshop_bench_v1`

**Composition:** Workbench, pegboard/tool rail, hardware tray, project zone.

**Required object groups:**

- Hand tool
- Fastener/hardware
- Safety object
- Measurement object
- Project material

**Object pool examples:** Hammer, screwdriver, wrench, pliers, tape measure, level, safety glasses, gloves, bolts, screws, nuts, drill, clamp, brush, wood piece, metal bracket, toolbox, pencil.

**Change opportunities:** Tool orientation, hardware count, handle color, pegboard position, repeated fastener, tool-material adjacency.

**Allowed questions:** Count, color/attribute, direction/orientation, position, adjacency, presence.

**Difficulty variables:** Tool silhouette similarity, small hardware count, orientation differences, visual density.

### 4.4 Museum — Deferred

**Template ID:** `museum_display_v1`

**Composition:** Display plinths, wall display, central artifact zone, side artifact zones.

**Required object groups:**

- Artifact
- Display support
- Frame or case
- Decorative motif

**Object pool examples:** Vase, mask, coin case, sculpture, framed image, fossil, bowl, figurine, textile, compass, small tool, jewelry display, book, model, plaque shape without readable text.

**Change opportunities:** Artifact color/material, plinth position, artifact count, frame shape, mirrored placement, repeated motif.

**Allowed questions:** Count, attribute, position, adjacency, presence, shape recognition.

**Difficulty variables:** Similar artifact silhouettes, restrained palette, display symmetry, detail size.

**Fairness restriction:** Do not require reading labels, dates, names, or small text.

### 4.5 Vehicle — Deferred

**Template ID:** `vehicle_interior_v1`

**Composition:** Dashboard/console or organized cargo area, left control zone, center storage zone, passenger/cargo zone.

**Required object groups:**

- Vehicle control or indicator shape
- Personal item
- Travel item
- Storage object

**Object pool examples:** Steering wheel, mirror, key fob, map, sunglasses, bottle, phone, charger, bag, flashlight, glove, hat, snack, ticket shape, first-aid pouch, umbrella, camera.

**Change opportunities:** Side placement, item count, object in holder, orientation, repeated travel item, adjacency to console/bag.

**Allowed questions:** Position, count, attribute, adjacency, presence, container relationship.

**Difficulty variables:** Dark-surface contrast, similar travel accessories, compartment count, object scale.

**Fairness restriction:** Controls are symbolic shapes; questions never require specialized vehicle knowledge.

### 4.6 Outdoor Scene — Deferred

**Template ID:** `outdoor_setup_v1`

**Composition:** Ground surface, central activity zone, left/right equipment zones, background decorative band.

**Required object groups:**

- Activity object
- Food/drink or travel object
- Personal accessory
- Natural decorative element

**Object pool examples:** Blanket, basket, bottle, camera, sunglasses, book, hat, apple, sandwich, thermos, backpack, binoculars, flashlight, compass, ball, shoe pair, flower group, stones, leaves.

**Change opportunities:** Item position, food count, accessory color, repeated natural item, object on/off blanket, camera adjacency.

**Allowed questions:** Count, color/attribute, position, adjacency, presence, region membership.

**Difficulty variables:** Natural decoration density, object-background similarity, spatial spread, repeated shapes.

## 5. Template Content Minimums

Before a template is production-ready, it requires:

- At least 14 question-eligible object archetypes
- At least 6 decorative archetypes
- At least 4 accessible color variants where color is relevant
- At least 3 legal composition variants
- At least 4 supported question types
- One known-valid fallback instance
- Seed stress tests at every difficulty tier

Across the five implemented templates, the family must provide enough combinations that a 50-round automated sample has no consecutive exact repeated instance. Deferred templates are excluded from production content minimums.

## 6. Scene Generation Rules

### 6.1 Seeded random source

Use a local seeded random-number generator. Do not use global `randi()` or timing after generation begins.

The reproduction key includes:

- Family version
- Template version
- Generator version
- Validator version
- Difficulty-policy version
- Exposure-policy version
- Content version
- Seed

### 6.2 Generation order

```text
Resolve template
→ Resolve difficulty axes
→ Resolve exposure
→ Select composition variant
→ Select required objects
→ Select optional objects
→ Select decorative objects
→ Assign attributes and states
→ Place objects in legal zones
→ Build scene truth graph
→ Select one eligible question target
→ Generate correct answer
→ Generate distractors
→ Build reveal evidence
→ Validate complete instance
```

### 6.3 Object definition

Every object definition contains:

- Stable object ID
- Player-readable name
- Semantic tags
- Eligible question types
- Allowed colors/materials/states
- Minimum rendered size
- Allowed zones and anchors
- Exclusion/overlap bounds
- Similarity group
- Accessibility metadata
- Artwork reference

### 6.4 Scene truth graph

Generation records:

- Object IDs and visible instances
- Attributes
- Counts by tag/type
- Zone and normalized position
- Orientation
- Container membership
- Nearest legal neighbors
- Duplicate groups
- Question eligibility
- Reveal highlight geometry

Question generation reads this truth graph rather than inferring answers from rendered pixels.

### 6.5 Placement constraints

- Question-eligible objects may not be clipped by safe areas.
- Required information may not be covered by another object.
- Decorative overlap may not alter a target silhouette.
- Minimum spacing applies to visually similar objects.
- Adjacent-object questions require one uniquely nearest valid neighbor.
- Left/right questions exclude objects within the center ambiguity band.
- Container questions require clearly visible boundaries.

### 6.6 Duplicate prevention

Track recent family/template seeds and a normalized scene signature containing object IDs, attributes, zones, and question type.

Do not present:

- The same seed within the retained history window
- The same scene signature within the previous 20 rounds
- The same question target in consecutive rounds when alternatives exist
- The same question type more than three times consecutively

## 7. Initial Question Types

### Count

Example: “How many pencils were in the mug?”

Requirements:

- Count set is fully visible.
- Members share an unambiguous tag.
- Correct count appears exactly once among options.
- Distractors are within a plausible range and never negative.

### Attribute

Example: “What color was the bottle?”

Requirements:

- Target is unique by name/context.
- Attribute is visually distinguishable under the active accessibility palette.
- No equivalent color labels appear as separate options.

### Position

Example: “Which side of the desk was the phone on?”

Requirements:

- Target lies outside the center ambiguity band.
- Options match the actual coordinate model.

### Adjacency

Example: “Which object was next to the notebook?”

Requirements:

- One neighbor is uniquely closest inside the adjacency threshold.
- No second neighbor is within the ambiguity margin.

### Presence

Example: “Which item appeared in the scene?”

Requirements:

- Exactly one option maps to a visible object.
- Distractors belong to the same semantic context but were absent.

### Region or Container

Example: “Which item was inside the basket?”

Requirements:

- Membership is visually explicit.
- Target center and sufficient target area lie inside the container boundary.

## 8. Exposure Policy

Exposure is family- and template-owned. Timing is resolved before generation and recorded in the instance.

| Tier | Range | Default | Fairness justification |
|---|---:|---:|---|
| Beginner | 5.0–6.0 s | 5.5 s | Provides time to scan each major composition zone and learn the loop. |
| Standard | 3.5–5.0 s | 4.25 s | Requires purposeful scanning while keeping medium scenes readable. |
| Advanced | 2.0–3.5 s | 2.75 s | Adds pressure only after familiarity and stable accuracy. |
| Expert | 1.5–2.0 s | 1.75 s | Uses very short exposure only when scene complexity and question demands remain fair. |

### Timing rules

- Exposure duration is one axis, not a universal difficulty ranking. A complex five-second scene may be harder than a simple two-second scene.
- Never shorten exposure and increase more than one other major difficulty axis in the same transition.
- Larger object counts require exposure compensation.
- Small-detail questions require minimum target-size and exposure thresholds.
- Accessibility timing adjustments may extend exposure without reducing normal progress earned.
- Tutorial demonstrations are untimed until the player chooses to continue.
- Reduced motion changes transitions, not observation time.

## 9. Difficulty Axes

Difficulty is a vector, not one number.

### Axes

- `object_count`
- `question_target_size`
- `semantic_similarity`
- `visual_similarity`
- `decorative_clutter`
- `spatial_spread`
- `relationship_complexity`
- `distractor_similarity`
- `exposure_duration`
- `question_type_complexity`

### Tier guidance

| Axis | Beginner | Standard | Advanced | Expert |
|---|---:|---:|---:|---:|
| Question-eligible objects | 8–10 | 11–14 | 15–18 | 18–22 |
| Decorative objects | 0–2 | 2–4 | 3–6 | 4–7 |
| Similarity | Low | Low–medium | Medium | Medium–high |
| Relationship depth | Direct | Direct | One relation | One precise relation |
| Distractors | Distinct | Plausible | Similar | Highly plausible but unambiguous |
| Exposure | 5.0–6.0 s | 3.5–5.0 s | 2.0–3.5 s | 1.5–2.0 s |

### Adaptation rules

- Adjust between rounds only.
- Change no more than two axes at once.
- Prefer increasing one content axis before reducing exposure.
- After two consecutive incorrect answers, reduce one contributing axis.
- After four of five correct answers with stable response time, increase one axis.
- Do not infer weakness; player-facing copy says the next round is easier, steadier, sharper, or more detailed.
- Preserve the resolved axis vector in challenge history.

## 10. Fairness Contract

Every candidate must pass all applicable rules.

### Required validators

- `instance.contract_complete`
- `scene.required_groups_present`
- `scene.object_count_within_policy`
- `scene.target_visible`
- `scene.target_size`
- `scene.overlap_limits`
- `scene.safe_area`
- `scene.contrast`
- `question.target_unique`
- `question.answer_unique`
- `question.distractors_valid`
- `question.relationship_unambiguous`
- `question.attribute_accessible`
- `exposure.within_policy`
- `reveal.evidence_available`
- `asset.required_available`
- `reproduction.version_complete`

### Candidate rejection

- Record rule ID and non-sensitive generation metadata.
- Retry with the next deterministic attempt seed.
- Stop at the shared runtime attempt limit.
- Validate the known-valid fallback before presentation.
- If fallback fails, return controlled session failure with no navigation or progress side effects.

## 11. Accessibility

- Do not use color as the only cue outside an explicitly enabled Color question.
- Color questions use tested accessible palettes and can be disabled through family accessibility settings.
- Minimum question-eligible object size is tier-dependent and never below the approved mobile threshold.
- Provide strong reveal outlines plus shape/position cues.
- Maintain minimum text and touch-target sizes through shared services.
- Support reduced motion for transitions and reveal pulses.
- Screen-reader labels describe controls, not the hidden scene while observation is active.
- Audio is supportive and never required to answer visual questions.
- Timing accommodations preserve normal progress and are stored as settings, not player evaluation.

## 12. Presentation Profile

**Profile ID:** `scene_investigation.production.v1`

- Presentation route: `observation`
- Presentation mode: `generated_scene_2d`
- Response route: `memory_question`
- Response mode: `single_choice`
- Result route: `result`
- Reveal mode: `scene_evidence_highlight`

### Layout

- Portrait-first composition
- Scene occupies the largest safe central region
- Timer/progress remains outside question-eligible content
- No gameplay target beneath top or bottom navigation safe areas
- Landscape/tablet may expand margins but may not alter scene truth

## 13. Result Contract Review

Scene Investigation must populate:

- Outcome
- Player response
- Correct answer
- Explanation
- Where to look
- Reveal highlight geometry
- Difficulty performance
- Gameplay focus
- Progress earned
- Recommended next action
- Replay metadata

### Reveal behavior

- Restore the exact generated scene.
- Dim unrelated objects slightly without making them disappear.
- Outline or softly pulse relevant evidence.
- For counts, highlight every counted member.
- For relationships, highlight both objects and their relation.
- Provide one concise explanation sentence.

Example:

> “There were five pencils in the green mug near the center of the desk.”

## 14. Scoring Architecture

Scene Investigation uses the proposed family-owned [`ScoringPolicy`](../SCORING_POLICY_CONTRACT.md).

### Gate 3 v1 scoring

- Initial question types use binary correctness.
- Internal base score: 800 correct, 0 incorrect.
- Difficulty bonus: up to 150, based on resolved axes.
- Optional speed bonus: up to 50 at Standard or above after fairness validation.
- Maximum score: 1000.
- Beginner has no speed bonus.
- Streak bonuses do not affect answer correctness and remain capped at 10% if introduced later.

### Partial credit

Not used for initial single-choice templates. The policy contract supports future multi-part or proximity responses without changing the runtime.

## 15. Witness Progress

Track game progress only:

- Scene Investigation plays
- Accuracy
- Current and best streak
- Best score
- Recent templates
- Recent difficulty axes
- Question-type history
- Template familiarity
- Scene Investigation Mastery
- Milestones

### Mastery

- Range: 0–100 game progression points
- Bounded per-round change
- Weighted by difficulty and recent sample confidence
- No single round changes mastery by more than 3 points
- Incorrect answers may reduce confidence but do not sharply remove earned mastery
- Player-facing language never implies real-world measurement

## 16. Recommendation Behavior

Recommend Scene Investigation when:

- It is the only production family available
- The player selects Continue from this family
- A Program requests observation/recall gameplay
- The recent repetition limit has not been reached

Template selection should:

- Avoid exact recent signatures
- Rotate scene categories
- Rotate question types
- Reduce one difficulty axis after repeated incorrect answers
- Increase one axis after stable success
- Prefer variety over relentless escalation

## 17. Tutorial Specification

**Tutorial ID:** `scene_investigation_tutorial`
**Tutorial version:** `2`

### First-time tutorial

1. **Brief:** “Study the whole scene. You will get one question after it disappears.”
2. **Untimed observation:** Show a simple Office demonstration. The player taps `READY` after scanning.
3. **Guided recall:** Ask one count or color question with two options.
4. **Reveal:** Restore the scene and highlight the evidence.
5. **Practice round:** Run a Beginner challenge at 6 seconds.
6. **Completion:** Explain Play Again and Home, then save tutorial version completion.

### Replay tutorial

Available from the Challenge Type detail/library entry and Settings tutorial controls. Replaying does not reset progress.

### Taught

- Scene disappears before the question
- One fair question follows
- The result reveals where to look
- Timing and detail increase gradually

### Intentionally not explained

- Upcoming question target
- Seed/generation rules
- Exact recommendation algorithm
- Mastery formula
- Validator rules

The player learns the mechanic without being taught how to game generation.

## 18. Audio Profile

**Profile ID:** `scene_investigation.audio.v1`

- Low, unobtrusive ambient layer by scene category
- Soft observation start cue
- Restrained final-second cue without alarm pressure
- Neutral conceal transition
- Quiet selection click
- Warm correct reveal sting
- Gentle incorrect reveal tone without punishment
- Subtle result bed
- Short haptics for start, selection, and reveal

Audio never resembles casino feedback and is never required to solve the challenge.

## 19. Visual Style

- Premium editorial 2D illustration
- Consistent object perspective and line weight
- Dark application chrome surrounding a readable scene card
- Category-specific scene palettes with accessible contrast
- Soft shadows and restrained texture
- No readable micro-text as challenge evidence
- Eye motif remains in application identity, not embedded as arbitrary scene lore
- Reveal uses the established purple focus color and success/error colors sparingly

All object assets in a template must share one coherent art system. The current mixed fixture art remains regression-only.

## 20. Analytics and Balancing

Privacy-respecting events:

- Tutorial start, completion, skip, replay
- Template/category selected
- Difficulty axes and exposure duration
- Candidate rejection rule ID
- Fallback use
- Round completion or abandonment
- Outcome, score band, and response time
- Replay selection
- Recommendation acceptance

Do not log scene answers as personal traits or use assessment-oriented labels.

## 21. Stress and Acceptance Testing

### Automated

For each template and difficulty tier:

- Development check: at least 2,000 deterministic seeds
- Release candidate: at least 10,000 deterministic seeds
- Zero ambiguous accepted instances
- Zero missing required assets
- Zero invalid answer sets
- Reproduction equality for sampled seeds
- Candidate rejection rate target below 5%
- Fallback presentation target below 0.1%
- No duplicate signature inside the recent-history window

### Runtime regression

- Existing deterministic fixtures continue through the shared runtime.
- Retry, fallback, and terminal-failure tests remain green.
- Exactly-once progress remains green.
- No family-specific shared-runtime identifiers.

### Manual gameplay

- At least three 20-round sessions across phone-size viewports
- Beginner session feels understandable without prior explanation
- Expert session is demanding but evidence remains visibly fair on reveal
- Incorrect results consistently produce an “I missed it” response
- No exact scene repetition in a 20-round session
- Touch, text, haptics, audio, and reduced-motion behavior verified on device

## 22. Gate 3 Deliverable Scope

Gate 3 is complete only when:

- This specification is approved.
- Family-owned ScoringPolicy is implemented and tested.
- Office, Kitchen, and Workshop meet production content minimums.
- Museum, Vehicle, and Outdoor remain specification-only and contain no production assets or generator branches.
- Tutorial version 2 is playable and replayable.
- Procedural generation and validators pass stress thresholds.
- Difficulty and exposure adapt gradually.
- Reveal explanations identify exact evidence.
- Witness Progress and recommendations update through shared services.
- A 20-round session feels varied and polished.
- Deterministic fixtures remain available for regression.

## 23. Non-Goals

- A second Challenge Type
- Narrative, characters, locations, or lore progression
- Multiplayer or leaderboards
- Daily Programs or live events
- 3D scene rendering
- Runtime-downloaded executable family code
- Medical, educational, psychological, or professional evaluation
- Partial-credit response modes in the initial production release

## 24. Approval

- Product direction: approved
- Template scope: Office, Kitchen, Workshop, Travel Desk, and Garden Bench approved; Museum, Vehicle, and the original Outdoor Scene deferred
- ScoringPolicy contract: approved
- Fairness rules: approved
- Accessibility rules: approved
- Stress thresholds: approved
- Gate 3 implementation authorization: approved

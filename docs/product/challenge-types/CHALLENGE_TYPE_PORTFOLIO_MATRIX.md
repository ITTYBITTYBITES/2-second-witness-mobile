# Challenge Type Portfolio Differentiation Matrix

**Status:** Phase 5.5 current portfolio
**Scope:** Five production and seven deferred Challenge Types

The matrix defines the gameplay space each family owns before implementation. Planned details are design hypotheses and must be completed in an approved Challenge Type Specification.

## Differentiation matrix

| Challenge Type | Status | Observation focus | Primary mechanic | Information presented | Memory demand | Decision type | Interaction type | Typical exposure style | Primary difficulty axes | Replay characteristics | Approx. round length |
|---|---|---|---|---|---|---|---|---|---|---|---:|
| Scene Investigation | Production | Broad incidental scene details and relationships | Study one generated scene, then answer one specific question | Illustrated ordinary scene with objects, positions, attributes, and relationships | Medium visual/spatial recall | Count, attribute, position, adjacency, presence | Single choice | One static scene for ~1.5–6 s, then conceal | Object count, clutter, similarity, target scale, question complexity, exposure | Generated compositions, object pools, question types, templates | 12–22 s |
| Flash Words | Production | Exact text recognition and sequence order | Catch a word or short word sequence | One word, pair, or short stream | Medium–high sequential verbal/visual recall | Exact recognition, order, stream presence | Single choice | One or more rapid typography pulses | Word length/familiarity, orthographic similarity, sequence length, interval, exposure | 373-word pool, distractor categories, three sequence modes | 8–18 s |
| Spot the Difference | Production | Comparative change detection | Compare two matched scenes and locate the changed region/detail | Paired or sequential near-identical visual compositions | Low if simultaneous; medium if sequential | Changed item/region identification | Tap region, then optional confirmation | Side-by-side or A→B comparison | Change subtlety, number of candidates, visual similarity, sequential delay, scene density | Generated legal mutations, layouts, change categories | 12–25 s |
| Object Recall | Production | Set membership and object identity | Remember an isolated set, then identify present, absent, or added object | Clean object lineup/tray without scene relationships | Medium set recall | Present/absent/replaced item | Single choice or object tap | One static object set, then conceal | Set size, item similarity, order stability, replacement similarity, exposure | Object pools, set combinations, membership questions | 9–18 s |
| Pattern Recall | Production | Abstract arrangement and structure | Remember and reconstruct/select a grid or geometric pattern | Cells, shapes, lights, or marks in an abstract grid | High visual/configural recall | Exact pattern or missing element | Grid input or pattern choice | Static pattern or short build sequence | Grid size, active cells, symmetry, transformations, sequence steps, exposure | Seeded grids, transformations, sequence variants | 10–22 s |
| Motion Tracking | Planned | Continuous attention across movement | Track a moving target or subset through crossings and identify endpoint/target | Moving shapes/objects and paths | Low snapshot memory; high continuous tracking | Target identity, endpoint, or path | Track visually, then tap/choice | Continuous animated motion | Target count, speed, crossings, occlusion, path similarity, duration | Seeded trajectories, crossings, target assignments | 10–20 s |
| Hidden Detail | Planned | Active visual search while evidence remains visible | Find one declared target/detail in a dense composition | Search scene with target visible during response | Minimal recall; high search demand | Target location | Direct tap on scene | Persistent static search with bounded timer | Target size, clutter, similarity, camouflage, search area, time limit | Generated placements, target pools, distractor density | 8–25 s |
| Color Recall | Planned | Palette and color-location binding | Remember colors or color-to-object/position assignments | Swatches, objects, or regions with controlled colors | Medium visual binding recall | Color, position-color pair, palette order | Palette choice or color placement | Brief palette/arrangement, then neutral conceal | Palette size, perceptual distance, binding count, order, exposure | Accessible palettes, assignment permutations, binding templates | 9–18 s |
| Direction Recall | Planned | Orientation and spatial sequence | Remember one direction or ordered direction path | Arrows, turns, compass-like movement, or path steps | Medium–high sequential spatial recall | Direction, endpoint, or ordered path | Swipe, directional buttons, or choice | Single cue or short direction sequence | Sequence length, rotations, mirrored distractors, interval, exposure | Direction permutations, paths, coordinate transforms | 8–18 s |
| Symbol Recognition | Planned | Fine visual form discrimination | Identify the exact symbol or changed symbol | Abstract, non-language symbols with controlled similarity | Low–medium exact visual recognition | Exact match or anomaly | Single choice or symbol tap | One brief symbol or compact symbol set | Stroke similarity, rotation, reflection, set size, exposure | Procedural symbol grammar, transformations, distractors | 7–15 s |
| Number Recall | Planned | Exact numeric sequence and grouping | Remember digits, grouped numbers, or ordered numeric flashes | Digit strings, groups, or sequential numbers | High sequential symbolic recall | Exact sequence, missing digit, order | Numeric keypad or choice | Static number group or digit stream | Digit count, grouping, similarity, interval, exposure | Seeded sequences, grouping patterns, legal distractors | 8–18 s |
| Sound Recognition | Planned | Auditory identity, order, and presence | Hear one sound or short sequence and identify what played | Nonverbal sound effects, tones, rhythms, or ordered clips | Medium auditory/sequential recall | Identity, order, presence, source match | Single choice, ordering, or visual source tap | Audio-only pulse/sequence with neutral visual stage | Clip similarity, sequence length, interval, layers, duration | Reviewed sound pool, sequence permutations, source categories | 9–20 s |

## Mechanical boundaries

### Scene Investigation vs Object Recall

- **Scene Investigation** owns incidental observation inside a composed scene and questions about relationships/attributes.
- **Object Recall** owns isolated set membership and identity. It must not become “Scene Investigation with fewer objects.”

### Scene Investigation vs Hidden Detail

- **Scene Investigation** conceals evidence before the response.
- **Hidden Detail** keeps evidence visible and tests visual search/location, not recall.

### Spot the Difference vs Hidden Detail

- **Spot the Difference** requires comparative change detection between matched states.
- **Hidden Detail** requires locating a declared target in one state.

### Pattern Recall vs Symbol Recognition

- **Pattern Recall** tests relationships among multiple cells/elements and often reconstruction.
- **Symbol Recognition** tests exact identity of one symbol or compact set using fine form discrimination.

### Flash Words vs Number Recall

- **Flash Words** uses orthographic word recognition, distractor spelling, and semantic-safe word content.
- **Number Recall** uses exact digit order/grouping and keypad-oriented response without vocabulary.

### Direction Recall vs Motion Tracking

- **Direction Recall** presents discrete orientation/path instructions for later recall.
- **Motion Tracking** demands continuous attention to actual movement and crossings.

## Accessibility readiness flags

| Challenge Type | Required pre-implementation accessibility decision |
|---|---|
| Motion Tracking | Reduced Motion cannot simply remove scored motion; define a slower/shorter-path accommodation and opt-out behavior. |
| Color Recall | Define color-vision-safe palettes, luminance separation, labels/symbol reinforcement, calibration, and recommendation opt-out. If the mechanic cannot remain equivalent, implementation must not proceed. |
| Sound Recognition | Define mute/hearing-access behavior, visual alternatives where mechanically equivalent, and recommendation/Program opt-out when audio is required. |
| Number Recall | Confirm localization and numeral-system scope without implying arithmetic ability. |
| Symbol Recognition | Validate symbols for cultural neutrality, accidental text resemblance, and transform ambiguity. |

## Portfolio status

- Production families: 5
- Remaining planned families: 7
- Total portfolio: 12
- Static visual families: strong coverage
- Dynamic visual families: one planned family, Motion Tracking
- Audio-first families: one planned family, Sound Recognition
- Direct scene-tap families: Spot the Difference and Hidden Detail
- Reconstruction/input families: Pattern Recall, Direction Recall, and Number Recall

The portfolio has broad modality coverage, but dynamic and audio gameplay remain single-family dependencies and require especially strong production proof.

## Signature Challenge Type strategy

**Current flagship candidate: Scene Investigation**

Scene Investigation most directly expresses the central witness fantasy: inspect an ordinary moment, recall one fair detail, and see exact evidence in the reveal. It should remain the default marketing and store-screenshot candidate while the portfolio expands.

Flagship status is not permanent. Every production review should compare:

- First-session clarity
- “I missed it” emotional strength
- Screenshot/video recognizability
- Replay Value after 50+ rounds
- Accessibility breadth
- Marketing response
- Retention and voluntary selection

**Spot the Difference** is a potential high-visibility secondary signature because paired panels and a subtle change communicate well in screenshots. It should not replace Scene Investigation as flagship without play and marketing evidence.

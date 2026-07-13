# Phase 5 Preparation Report — Challenge Type Expansion

**Date:** 2026-07-12
**Approval:** Preparation package approved on 2026-07-12
**Status:** Complete and superseded by locally completed Phase 5 implementation
**Phase 4:** Approved

## Outcome

Phase 5 is defined as **Challenge Type Expansion**, not generic content expansion. The next objective is to prove broad mechanical range across the established platform. Template/content volume follows in Phase 5.5 after the family portfolio exists.

No gameplay, family module, template, asset, or runtime code was added during preparation.

## Approved refinements

The acceptance package now additionally requires:

- A “Why does this exist?” answer
- A reason players would intentionally choose the family
- Intended emotions during play, after success, and after a miss
- A scored Replay Value rubric covering template variety, generation diversity, memorization resistance, strategy variety, and long-term freshness
- A recognizable visual identity before title text
- Expansion Potential covering seasonal content, code-free templates, independent art/audio expansion, and data-driven balancing
- Explicit flagship/core/specialist/experimental portfolio role

The portfolio matrix identifies **Scene Investigation** as the current flagship candidate. Spot the Difference is a potential high-visibility secondary signature family, subject to play and marketing evidence.

## Deliverables

- Updated Product Development roadmap
- [`challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md`](challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md)
- [`challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md`](challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md)
- Updated [`challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md`](challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md)
- Complete review draft: [`challenge-types/SPOT_THE_DIFFERENCE_SPEC.md`](challenge-types/SPOT_THE_DIFFERENCE_SPEC.md)
- Portfolio coverage and overlap analysis
- Recommended family implementation order

## Phase definitions

### Phase 5 — Challenge Type Expansion

Build mechanically distinct production families through the existing contracts. The target portfolio is the two implemented families plus ten planned families. The success measure is mechanical coverage and production acceptance—not raw asset count.

### Phase 5.5 — Content Expansion

After family mechanics are established:

- Expand each accepted family toward 3–6 strong templates
- Grow reviewed content pools
- Add composition/layout variants
- Expand Programs, achievements, Collections, and objectives using the broader catalog
- Balance unlocks and recommendation weights

### Phase 6 — Production Polish

Perform cohesive polish once the expanded family/template surface exists: UI, animation, transitions, audio, haptics, accessibility, performance, assets, tooling, balancing, and release validation.

## Required family gate

Every family must complete the Challenge Type Acceptance Contract before gameplay implementation. Required approvals:

1. Design specification
2. Portfolio distinction
3. Architecture review
4. Fairness contract
5. Accessibility plan
6. Validation plan
7. Implementation order
8. Explicit implementation authorization

A family may not enter code with an incomplete or unapproved gate.

## Recommended implementation order

The approved proposal prioritizes a progression from comparative observation through isolated recall, abstract structure, dynamic attention, active search, sensory binding, and new symbolic/audio modalities.

### 1. Spot the Difference

**New proof:** Comparative state/change detection and direct scene tapping.

Why first:

- Reuses mature scene composition knowledge without reusing Scene Investigation’s question mechanic.
- Proves direct spatial response and mutation validators.
- Establishes a clean fairness model: one legal, visible change with exact reveal evidence.

Primary preparation risk: prevent it from becoming a second Scene Investigation question set.

### 2. Object Recall

**New proof:** Isolated set membership rather than scene relationships.

Why second:

- Adds a clean object-set mechanic suitable for many content themes.
- Exercises present/absent/replaced decisions.
- Provides strong contrast with comparative Spot the Difference.

Primary preparation risk: must remain an isolated tray/set mechanic rather than a simplified scene.

### 3. Pattern Recall

**New proof:** Abstract grid reconstruction and multi-cell relationships.

Why third:

- Introduces non-object procedural truth and grid input.
- Exercises symmetry, transformation, and reconstruction validators.
- Reduces dependence on illustrated scene assets.

Primary preparation risk: pattern difficulty can become opaque if multiple axes increase together.

### 4. Motion Tracking

**New proof:** Continuous dynamic observation.

Why fourth:

- Breaks the static/flash presentation pattern.
- Exercises seeded trajectories, crossings, endpoints, and runtime animation.
- Provides the first major Reduced Motion design challenge.

Primary preparation risk: motion is the scored mechanic, so accessibility cannot be solved by disabling animation.

### 5. Hidden Detail

**New proof:** Active search while evidence remains visible.

Why fifth:

- Adds direct target-location play with minimal recall demand.
- Creates a different pacing profile from conceal-and-question families.
- Exercises tappable scene regions and search-time fairness.

Primary preparation risk: targets must be challenging but never camouflaged beyond fair visibility.

### 6. Color Recall

**New proof:** Color-location and palette binding.

Why sixth:

- Adds perceptual binding rather than identity-only recall.
- Exercises controlled palette generation and perceptual-distance validators.

Primary preparation risk: highest visual-accessibility gate. It must define color-vision-safe operation and opt-out behavior before authorization.

### 7. Direction Recall

**New proof:** Sequential spatial orientation and gesture/directional input.

Why seventh:

- Adds discrete spatial sequences after continuous Motion Tracking.
- Supports swipe or directional-button interaction.
- Exercises rotations, mirrored distractors, and endpoint reasoning.

Primary preparation risk: must remain direction/path recall rather than abstract Pattern Recall with arrows.

### 8. Symbol Recognition

**New proof:** Fine form discrimination with language-independent symbol grammar.

Why eighth:

- Adds exact shape recognition and procedural symbol transformations.
- Supports culturally neutral, localization-light content.

Primary preparation risk: reflected/rotated symbols require strict ambiguity and cultural-neutrality review.

### 9. Number Recall

**New proof:** Exact numeric grouping and keypad response.

Why ninth:

- Adds a familiar but mechanically precise input mode.
- Exercises grouping, digit streams, missing-position questions, and numeric keypad interaction.

Primary preparation risk: remain recall entertainment; never imply arithmetic or numerical ability measurement.

### 10. Sound Recognition

**New proof:** Audio-first observation and sequence recall.

Why tenth:

- Completes the planned modality portfolio.
- Exercises audio presentation, sequence timing, sound-pool validation, and visual source responses.

Primary preparation risk: required-audio accessibility and mute behavior must be resolved before implementation.

## Portfolio coverage analysis

| Coverage target | Primary families | Secondary families | Coverage assessment |
|---|---|---|---|
| Static observation | Scene Investigation, Hidden Detail | Spot the Difference, Object Recall | Strong |
| Dynamic observation | Motion Tracking | Spot the Difference sequential mode | Narrow; one primary family |
| Visual recall | Scene Investigation, Object Recall, Pattern Recall, Color Recall | Symbol Recognition, Direction Recall | Strong |
| Sequential recall | Flash Words, Direction Recall, Number Recall, Sound Recognition | Pattern Recall | Strong |
| Spatial awareness | Scene Investigation, Motion Tracking, Direction Recall | Spot the Difference, Hidden Detail | Strong |
| Motion tracking | Motion Tracking | None | Single-family dependency |
| Pattern recognition | Pattern Recall, Symbol Recognition | Spot the Difference | Strong if boundaries hold |
| Symbol recognition | Symbol Recognition | Direction Recall, Number Recall | Strong |
| Number recognition | Number Recall | Pattern Recall numeric templates are prohibited unless explicitly approved | One clear owner |
| Audio recognition | Sound Recognition | None | Single-family dependency |
| Mixed attention | Scene Investigation, Motion Tracking | Programs combine families | Moderate |
| Comparative change detection | Spot the Difference | Hidden Detail | One clear owner |
| Active visual search | Hidden Detail | Scene Investigation incidental scan | One clear owner |
| Exact text recognition | Flash Words | None | One clear owner |

## Overlap findings

### Highest overlap risk: Scene Investigation / Object Recall / Hidden Detail

Control with hard mechanic boundaries:

- Scene Investigation: incidental composed scene, conceal, one relationship/attribute question
- Object Recall: isolated set membership, conceal, identity/presence decision
- Hidden Detail: evidence stays visible, locate declared target

### High overlap risk: Pattern Recall / Symbol Recognition / Direction Recall

Control with response and truth boundaries:

- Pattern Recall: multi-element arrangement/reconstruction
- Symbol Recognition: exact individual form discrimination
- Direction Recall: ordered spatial orientation/path

### Medium overlap risk: Flash Words / Number Recall

Control through content and input:

- Flash Words: orthographic words and word-order recognition
- Number Recall: digit grouping/order and keypad/position response

### Medium overlap risk: Spot the Difference / Hidden Detail

Control through comparison:

- Spot the Difference: detect a mutation between two states
- Hidden Detail: locate a known target in one state

## Gap findings

1. **Dynamic observation is underrepresented.** Motion Tracking is the only primary continuous-motion family.
2. **Audio is a single-family modality.** Sound Recognition carries all audio-first coverage.
3. **Immediate anomaly categorization is not owned.** The portfolio lacks a persistent “which item breaks the rule?” mechanic with no conceal stage.
4. **Divided multi-zone attention is only partial.** Scene Investigation is broad static observation; Motion Tracking may cover dynamic tracking, but neither necessarily owns monitoring separate regions for events.
5. **Direct construction is limited.** Pattern Recall provides grid reconstruction; most other families use recognition/choice.

## Suggested future candidates

These are portfolio-gap candidates, not approved Phase 5 families:

### Odd One Out

Persistent visual set; identify the item that breaks a generated visual rule. This would own immediate anomaly categorization without conceal or scene search.

Guardrail: rules must be visually demonstrable and unambiguous, never dependent on trivia or specialized knowledge.

### Multi-Zone Watch

Monitor several simple regions for brief events, then identify where/what changed. This would own divided attention rather than single-target motion tracking.

Guardrail: event count, simultaneity, and visibility require strict fairness bounds and Reduced Motion design.

No candidate should be added until the initial planned portfolio is reviewed after several new production families.

## Phase 5 execution rules

- Implement one family gate at a time inside the overall Phase 5 objective.
- Require an approved specification before code.
- Require production flow, tutorial, policy, scoring, variety, seed, stress, content, static architecture, and visual review before the next family.
- Keep deterministic regression fixtures.
- Do not modify Engine/shared runtime for a family-specific need. If a shared contract gap is discovered, stop for architecture review.
- Do not begin Phase 5.5 template-volume expansion until the family mechanic portfolio is approved.

## Risks before Phase 5 authorization

- Ten families represent substantial content, testing, visual, audio, and accessibility work; implementation must remain gated.
- Color Recall and Sound Recognition have unresolved accessibility equivalence questions.
- Motion Tracking may expose presentation/performance constraints that static families did not.
- Two existing production families are not enough to calibrate Program variety for a twelve-family future catalog.
- The Android sponsor-first boot gate remains open and should stay visible as release work.

## Files created

- `docs/product/challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md`
- `docs/product/challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md`
- `docs/product/PHASE_5_PREPARATION_REPORT.md`
- `docs/product/challenge-types/SPOT_THE_DIFFERENCE_SPEC.md`
- `app/tests/runtime/verify_phase5_preparation.py`

## Files updated

- `docs/product/PRODUCT_DEVELOPMENT_ROADMAP.md`
- `docs/product/challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md`
- `docs/product/challenge-types/README.md`
- Active Product and Foundation status/index documentation
- Documentation consistency requirements

## Preparation validation

Preparation-time checks recorded before implementation:

| Validation | Result |
|---|---:|
| Fresh Godot 4.6.3 import | Pass, no app errors or warnings |
| Full source loading | 87 loaded, 0 failed |
| Phase 4 product regression | 61 passed, 0 failed |
| Phase 5 preparation verifier | Pass, 12 portfolio types / 10 planned / 3 unchanged manifest families |
| Phase 3/3.5/4 and runtime static architecture | Pass |
| Documentation consistency | 54 Markdown files, pass |
| Links, terminology, conflict markers, trailing whitespace | Pass |

The preparation verifier confirms:

- All required acceptance-contract topics
- All requested matrix columns
- Two implemented plus ten planned portfolio rows
- Exact recommended implementation order
- Required portfolio coverage categories
- Phase 5, Phase 5.5, and Phase 6 roadmap names
- Closed implementation gate
- No planned family directories or manifest entries
- Documentation links and terminology

## Recommendation

The preparation contract, matrix, and order were accepted. Phase 5 subsequently implemented a generic Interaction Adapter architecture plus Spot the Difference, Object Recall, and Pattern Recall. See [`PHASE_5_COMPLETION.md`](PHASE_5_COMPLETION.md). The same acceptance contract remains mandatory for future families.

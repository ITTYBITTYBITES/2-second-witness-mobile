# Phase 2 Gate 3 Completion — Production Scene Investigation

**Date:** 2026-07-11
**Status:** Local implementation and validation complete
**Physical-device review:** Required before store release

## Outcome

Scene Investigation is now the first complete production Challenge Type.

A player can:

```text
Play Now
→ Complete or replay the family tutorial
→ Receive Office, Kitchen, or Workshop
→ Observe a generated scene
→ Answer one fair question
→ See exact evidence highlighted
→ Understand the result
→ Gain Witness Progress and mastery
→ Receive the next recommendation
→ Play again or return Home
```

The five fixed challenges remain available only through the internal regression family.

## Implemented production templates

### Office

Primary onboarding environment with familiar desk items, documents, electronics, decorations, and clear hierarchy.

### Kitchen

Wider object variety with containers, food, utensils, appliances, colors, shapes, and placement relationships.

### Workshop

Advanced organized complexity with tools, parts, safety items, equipment, materials, and similar silhouettes.

### Deferred

Museum, Vehicle, and Outdoor remain approved specifications only. No Gate 3 assets or generator branches were added for them.

## Procedural content

- 54 production object archetypes
- Seeded local random generation
- Required-group composition
- Template-specific background and object pools
- Grid-assisted placement with controlled jitter
- Low-contrast decorative details
- Scene truth graph
- Unique scene signatures
- Recent-signature rejection and regeneration
- Count, attribute, position, adjacency, and presence questions
- Deterministic distractors, answers, explanations, and reveal evidence

## Premium presentation

- Approved Scene Investigation content style guide
- Premium empty illustrated backgrounds for Office, Kitchen, and Workshop
- Deterministic family vector renderer for question objects
- Separate observation and evidence-reveal rendering
- Full generated-scene presentation in Observation
- Exact scene restoration in Result
- Multiple evidence highlights for count/relationship questions
- Gameplay top bar hides unrelated actions
- Local full-flow and scene contact sheets retained as validation artifacts

## Family-owned scoring

The approved `ScoringPolicy` contract is implemented and executed by `ResultService`.

Scene Investigation scoring provides:

- Binary initial correctness
- 800-point correct base
- Up to 150 points from resolved scene/question complexity axes
- No assumption that shorter exposure is automatically harder
- Small participation progress after an incorrect response
- Bounded mastery changes
- Family-owned explanation and reveal data
- Scoring policy version in result metadata

Fixture and synthetic families provide their own policies; shared runtime code contains no response-mode scoring branch.

## Difficulty and exposure

Independent axes:

- Object count
- Decorative density
- Similarity
- Target scale
- Distractor similarity
- Question complexity
- Scene complexity
- Exposure duration

Approved exposure ranges:

- Beginner: 5–6 seconds
- Standard: 3.5–5 seconds
- Advanced: 2–3.5 seconds
- Expert: 1.5–2 seconds

Two consecutive misses reduce challenge pressure. Comfortable Timing extends exposure without changing the resolved content rules.

## Interactive tutorial

Tutorial version 2 includes:

1. Brief
2. Untimed generated Office demonstration
3. Guided recall response
4. Exact evidence reveal
5. Beginner practice launch

Completion is versioned per Challenge Type. The Challenge Library exposes tutorial replay without resetting progress.

## Witness Progress

Additive profile data now tracks:

- Witness Level
- Witness Rank
- Total progress
- Family plays and accuracy
- Current and best streak
- Incorrect streak
- Scene Investigation Mastery and confidence
- Recent templates, seeds, and signatures
- Question-type history
- Bounded challenge history

All data persists through the existing `ProfileService` and `SaveService` foundation.

## Audio

Understated local assets now cover:

- UI click
- Observation start
- Conceal transition
- Correct reveal
- Incorrect reveal
- Result settle

Audio remains optional and never reveals the answer.

## Fairness validation

Production validation checks:

- Complete instance contract
- Object count policy
- Unique object IDs
- Safe-area placement
- Minimum target size
- Overlap limits
- Unique correct answer
- Approved question type
- Unambiguous adjacency
- Reveal evidence
- Exposure bounds
- Renderer and background availability
- Complete scene signature

Invalid candidates are rejected before presentation. Retry, fallback, and controlled terminal-failure guarantees remain enforced by the shared runtime.

## Full local validation

| Validation | Result |
|---|---:|
| Godot headless import | Pass, no errors or warnings |
| Gate 1 runtime regression | 23 passed, 0 failed |
| First-run regression | 15 passed, 0 failed |
| Fixture generation/validation | 30 passed, 0 failed |
| Gate 2 Runtime Hardening | 31 passed, 0 failed |
| Production player flow | 23 passed, 0 failed |
| Interactive tutorial | 17 passed, 0 failed |
| Family scoring | 21 passed, 0 failed |
| Difficulty/exposure | 12 passed, 0 failed |
| 20-round variety | 10 passed, 0 failed |
| Source loading | 70 loaded, 0 failed |
| Production stress | 120,000 generated, 0 failed |
| Stress batch | 10,000 seeds per template/tier |
| Content schema/style assets | 3 templates, 54 archetypes, pass |
| Runtime architecture | Pass |
| Documentation consistency | Pass |
| Visual preview generation | Observation, reveal, and full flow pass |

Stress performance remained stable across templates:

- Office: approximately 27.1 seconds
- Kitchen: approximately 27.2 seconds
- Workshop: approximately 26.7 seconds

for 40,000 generated instances per template in the final local run.

## Architectural decisions

1. Production and regression content are separate family modules.
2. Only production families are visible to recommendations and the Challenge Library.
3. Family-owned ScoringPolicy is the sole response interpreter.
4. Empty premium backgrounds are fixed presentation content and never answer evidence.
5. Question truth comes from generated object data, never image inference.
6. Scene signatures prevent recent repetition.
7. Difficulty scoring uses resolved complexity axes rather than exposure labels.
8. No Museum, Vehicle, Outdoor, or second-family implementation entered Gate 3.

## Remaining release risks

These do not block local Gate 3 completion but require human/device work:

- Verify minimum silhouette recognition across physical phone densities.
- Verify OLED/LCD color appearance and high-contrast behavior.
- Balance audio and haptic levels on device.
- Conduct human 20-round sessions to confirm the intended “I missed it” feeling and player retention.
- Replace or refine individual procedural object silhouettes if device testing finds recognition ambiguity.

## Recommended next gate

**Phase 2 Gate 4 — Second Challenge Type**

Choose one mechanically different type, preferably Flash Words or Motion Tracking. It must use only new Game and Content modules. If family-specific Engine or shared-runtime changes are required, stop and correct the architecture before proceeding.

# Spot the Difference — Challenge Type Specification

**Status:** Locally production-complete in Phase 5
**Implementation authorization:** Completed under the approved generic Interaction Adapter milestone
**Internal family ID:** `spot_the_difference`
**Player-facing name:** Spot the Difference
**Specification version:** 1.0-proposal
**Proposed portfolio order:** Phase 5 family 1

This specification must pass the [`CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md`](CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md) before implementation.

## 1. Identity

### Player-facing description

> Compare two clean visual moments and find the one detail that changed.

### Gameplay focus

- Comparative observation
- Change detection
- Attention to detail
- Visual search
- Spatial matching

### Portfolio role

- Core family
- High-visibility marketing candidate
- Potential secondary signature Challenge Type

### Why does this exist?

Spot the Difference provides simultaneous or sequential **comparative change detection**, which no current Challenge Type owns.

- Scene Investigation asks what was present in one concealed scene.
- Flash Words asks what text appeared.
- Spot the Difference asks the player to compare two controlled states and locate one semantic mutation.

### Why would a player choose it?

- The objective is immediately understandable.
- The changed detail remains concrete rather than abstract.
- Direct spatial response creates a satisfying “found it” moment.
- The side-by-side presentation is visually distinct and shareable.
- Players can choose between persistent comparison and more demanding sequential comparison templates.

### Intended emotion

**During play:** Focused curiosity and mounting certainty while scanning matched regions.

**After success:** A concise “There it is” reward.

**After a miss:** “I can’t believe I missed that,” followed by immediate understanding from the exact change highlight.

### Distinction from planned families

- **Hidden Detail:** one scene and a declared target; no comparison.
- **Object Recall:** isolated set membership after conceal; no paired mutation.
- **Pattern Recall:** multi-cell arrangement reconstruction; no semantic before/after pair.
- **Scene Investigation:** one incidental scene and a later question; not direct comparison.

## 2. Player Goal

Find the one intentionally changed object or object property between two matched visual states.

### Core gameplay objective

Identify the semantic target of one legal mutation before the response window ends.

### Observation task

Systematically compare matched regions, object identities, and declared visual states.

### Primary mechanic

Before/after comparison with exactly one changed semantic target.

### Player actions

- View simultaneous A/B panels or sequential A→B states.
- Tap the object/region that changed.
- When spatial tapping is inaccessible, select the changed object from a family-provided accessible response list.

### Rewarding moment

The chosen location locks in, both states align, and a restrained outline makes the exact change visually undeniable.

## 3. Core Gameplay Loop

```text
Program / Home / Library request
→ ChallengeSessionService
→ Spot the Difference family and template
→ Difficulty and exposure
→ Generate base truth graph
→ Clone comparison state
→ Apply exactly one legal mutation
→ Validate pair, target, timing, and hit region
→ Present A/B or A→B
→ Player taps/selects changed target
→ Family scoring
→ Before/after evidence reveal
→ Witness Progress
→ Recommendation
→ Replay, Continue, or Home
```

### Interaction architecture

Phase 5 implemented the generic InteractionProfile → InteractionAdapterRegistry → InteractionAdapter architecture. Spot the Difference declares `spatial_tap` as its primary adapter and `single_choice` as its accessible alternative.

The shared Spatial Tap adapter collects normalized coordinates and forwards them through `ChallengeSessionService.submit_response()`. It contains no Spot the Difference ID, mutation rule, target truth, or scoring logic. Only SpotDifferenceScoringPolicy determines whether coordinates intersect accepted target regions.

The same registered adapter can support future spatial-response families without Engine changes.

## 4. Initial Templates

### 4.1 Side-by-Side Presence

**Template ID:** `side_by_side_presence_v1`

Two aligned panels remain visible. One object is added or removed in panel B.

- Response: tap the changed object/empty anchor region
- Initial objects: 6–12
- Change categories: added, removed
- Memory demand: low
- Search demand: medium
- Fallback: six large distinct objects with one removed object and retained anchor hit region

### 4.2 Side-by-Side Attribute

**Template ID:** `side_by_side_attribute_v1`

One matched object changes a legal visual state.

- Response: tap the changed object in either panel
- Change categories: open/closed, filled/empty, marked/unmarked, orientation, shape state
- Color-only mutation: prohibited by default; permitted only in an approved color-safe content profile
- Initial objects: 6–12
- Fallback: one large open/closed container change

### 4.3 Sequential Switch

**Template ID:** `sequential_switch_v1`

Panel A appears, conceals briefly, then panel B appears for response. One object changes.

- Response: tap changed object in panel B or use accessible object list
- Memory demand: medium
- Change categories: presence, state, orientation, position
- Initial objects: 5–10
- Fallback: five distinct objects with one large orientation change

### 4.4 Arrangement Shift

**Template ID:** `arrangement_shift_v1`

Two panels show the same object set. One object moves between legal, clearly separated anchors.

- Response: tap the moved object in either panel; both old and new bounds identify the same accepted target
- Initial objects: 6–14
- Change category: one position shift only
- Minimum movement distance: template/difficulty controlled
- Fallback: six objects in a 3×2 arrangement with one corner-to-opposite-corner move

### Template distinction

- Presence tests inventory comparison.
- Attribute tests state comparison.
- Sequential Switch adds comparative memory.
- Arrangement Shift tests spatial alignment.

Artwork changes alone do not constitute a new template.

## 5. Generation Rules

### Fixed authored data

- Panel composition definitions
- Object archetypes and art
- Legal anchors and zones
- Mutation eligibility metadata
- State pairs
- Similarity groups
- Accessible labels
- Template bounds
- Known-valid fallback definitions

### Generated data

- Composition variant
- Object set
- Object states and positions
- Decorative non-question elements
- Mutation target
- Mutation category and values
- A/B panel truth graphs
- Target hit regions
- Accessible response options
- Exact reveal evidence

### Deterministic generation order

```text
Resolve template/difficulty/exposure
→ Select composition
→ Select readable object set
→ Resolve base positions/states
→ Freeze base truth graph
→ Clone panel B from panel A
→ Select one eligible target
→ Apply one legal mutation to B
→ Build normalized target regions
→ Build accessible response options
→ Compute pair signature
→ Validate
```

### Determinism

Reproduction identity includes:

- Family/template/content versions
- Generator and validator versions
- Difficulty and exposure policy versions
- Scoring policy version
- Seed

No global randomness or post-clone random decoration is allowed. Panel B begins as an exact semantic clone; the declared mutation is the only semantic difference.

### Duplicate prevention

The scene signature includes template, composition, ordered object IDs, normalized positions/states, mutation target/category/value, and seed-derived layout identity.

Reject signatures appearing in recent family history.

## 6. Difficulty Axes

Independent axes:

- Object count
- Layout density
- Target rendered size
- Object similarity
- Mutation salience
- Movement distance
- State-pair similarity
- Panel alignment assistance
- Sequential memory delay
- Search/response duration
- Accessible response distractor similarity

### Proposed tiers

| Axis | Beginner | Standard | Advanced | Expert |
|---|---:|---:|---:|---:|
| Objects | 5–7 | 7–10 | 9–12 | 11–14 |
| Target minimum panel width | 12% | 10% | 8% | 7% |
| Similarity | 0.10–0.25 | 0.25–0.50 | 0.45–0.70 | 0.60–0.82 |
| Mutation salience | high | high–medium | medium | medium–subtle |
| Alignment guides | strong | standard | restrained | restrained |
| Sequential A exposure | 5–6 s | 4–5.5 s | 3–4.5 s | 2.5–4 s |
| Sequential gap | 0.2–0.3 s | 0.25–0.4 s | 0.3–0.5 s | 0.35–0.6 s |

### Prohibited combinations

- Minimum target size + maximum density + minimum mutation salience
- Highest object similarity + shortest exposure on first three plays
- Color-only mutation when Color Assistance is enabled
- Position change below minimum movement threshold
- Sequential Expert timing before sufficient family confidence
- Decorative changes outside the truth graph

Difficulty changes by at most one tier and one major visual-demand axis between consecutive rounds.

## 7. Exposure Timing Policy

### Simultaneous templates

Panels remain visible during the bounded response window:

- Beginner: 14–18 s
- Standard: 11–15 s
- Advanced: 9–12 s
- Expert: 7–10 s

The timer communicates remaining time without covering either panel. Timeout produces an incorrect/timeout result with evidence reveal and participation progress.

### Sequential Switch

- Panel A: 2.5–6 s by tier
- Neutral gap: 0.2–0.6 s
- Panel B response window: 8–15 s

### Comfortable Timing

- Response window +35%
- Sequential A exposure +20%
- Gap does not increase beyond 0.6 s
- Normal Witness Progress remains available

### Reduced Motion

- No sliding panel transitions
- Use immediate replacement or zero-duration opacity change
- No pulsing target/search animation before response
- Reveal outline may appear without motion

## 8. Fairness Rules

Proposed rule IDs:

- `pair.base_complete`
- `pair.semantic_clone`
- `mutation.exactly_one_target`
- `mutation.category_allowed`
- `mutation.value_distinct`
- `mutation.salience_minimum`
- `target.rendered_size_minimum`
- `target.hit_region_minimum`
- `target.position_shift_minimum`
- `layout.panel_alignment`
- `layout.object_overlap`
- `layout.safe_area`
- `distractor.response_unique`
- `exposure.within_policy`
- `accessibility.color_safe`
- `asset.required_available`
- `reproduction.complete`
- `history.signature_unique`

### Exactly one change

There must be exactly one semantic target. A position mutation changes one object’s position but still counts as one target. Both old and new target regions may be accepted.

Unchanged objects must retain:

- Identity
- State
- Position, except allowed whole-panel responsive transform
- Scale
- Orientation
- Color/material
- Layer order where visually meaningful

### Hit-region fairness

- Minimum effective touch target: 48×48 logical pixels
- Hit region may expand beyond visible bounds but may not overlap another eligible object region
- Normalized coordinates must survive responsive panel scaling
- Panel label and divider are never answer regions

### Failure semantics

Invalid pairs are rejected before presentation. If retries and fallback fail, runtime returns controlled failure without navigation or progress side effects.

## 9. Accessibility

### Color Assistance

- Color-only changes are disabled.
- State, presence, position, orientation, and shape changes remain available.
- Approved color mutations require tested luminance separation and redundant state/pattern cues.

### High Contrast

- Panel edge, A/B labels, divider, timer, and response focus use high-contrast tokens.
- Object content must meet family contrast minimums against its panel.

### Text Size

- A/B labels and accessible response list scale to 140%.
- Panels preserve usable comparison width; compact portrait may stack A above B.

### Motor/input alternative

The accessible response list names visible object categories without stating the changed property. Selecting an object submits the same target ID as spatial tapping.

### Screen readers

- Navigation and response controls receive labels.
- Hidden mutation truth is never announced before response.
- The accessible object list may be read because it contains all eligible visible objects, not the answer.

### Timing

Comfortable Timing extends search and sequential observation without score penalty.

## 10. Presentation Profile

**Proposed profile ID:** `spot_the_difference.production.v1`

- Presentation mode: `paired_change_scene_2d`
- Primary response mode: `spatial_tap`
- Accessible response mode: `target_choice`
- Result mode: `paired_change_evidence`
- Orientation: portrait-first, responsive tablet
- Compact layout: stacked A/B panels
- Wide layout: side-by-side panels
- Safe-area behavior: shared shell plus family panel insets

### Architecture result

Approved and implemented generically. Shared code understands registered adapter lifecycle and normalized tap payloads only; it does not understand mutations, changed targets, or this family.

## 11. Result Behavior

Required result data:

- Outcome: correct, incorrect, or timeout
- Player tap/selected target
- Correct target ID
- Mutation category
- Before and after target state
- Accepted target regions
- Explanation
- Where to look
- Paired reveal scene

### Reveal

- Restore both states in matched layout.
- Outline the correct target in both panels where applicable.
- Show the player tap with a neutral marker.
- Use an arrow only for position changes.
- Attribute/state changes show concise before → after labels after scoring.

Example:

```text
You chose: desk lamp
Changed: green notebook
Difference: closed → open
```

Incorrect copy follows the product standard: **“I missed it.”**

## 12. Scoring Policy

Family-owned ScoringPolicy proposal:

- Correct base score: 800
- Difficulty component: up to 150
- Response-time component: up to 50, only after a minimum fair search allowance
- Incorrect/timeout score: 0
- Correct progress: 12
- Incorrect/timeout participation progress: 2
- Mastery change: +1.5 correct, −0.25 miss, bounded 0–100
- Response time never changes correctness
- Comfortable Timing does not reduce progress

Difficulty component derives from object count, similarity, mutation salience, target size, and sequential demand.

## 13. Witness Progress

**Record key:** `spot_the_difference`

Retain:

- Plays/correct/accuracy
- Current/best/incorrect streak
- Mastery/confidence
- Template history
- Mutation-category history
- Difficulty axes
- Response time
- Recent seeds/signatures
- Timeout count
- Spatial versus accessible-list response mode
- Program context where applicable

Potential achievements are deferred until family pacing is measured.

## 14. Recommendation Behavior

Proposed family metadata:

- Witness Level requirement: 1
- Recommendation weight: 1.1
- Gameplay focus: Observation, Change Detection, Attention, Visual Search, Spatial Matching

Recommend when:

- The family is unplayed.
- The player has not recently received comparative visual play.
- Programs request Observation, Attention, Visual Search, or Spatial Matching.
- Family Mastery trails the portfolio without an active miss streak.

Reduce difficulty after two misses or repeated timeouts. Avoid immediate exact mutation/category repetition. Continue rotates templates and mutation categories.

## 15. Replay Value

| Criterion | Score | Evidence |
|---|---:|---|
| Template variety | 5 | Simultaneous presence, simultaneous state, sequential comparison, and spatial arrangement create different observation demands. |
| Generation diversity | 5 | Object pools, compositions, positions, states, mutation targets/categories, and difficulty combinations produce a large fair truth space. |
| Memorization resistance | 5 | The answer depends on a seeded mutation applied after base composition generation; recent signatures prevent immediate repeats. |
| Strategy variety | 3 | Players may scan by region, object category, or systematic A/B matching, but all strategies serve one comparison mechanic. |
| Long-term freshness | 4 | New object packs, compositions, themes, and mutation categories expand cleanly; long-term proof still requires 50-round human sessions. |
| **Total** | **22/25** | Passes proposed minimum; requires implementation evidence before production approval. |

## 16. Expansion Potential

### Seasonal content

Yes. Seasonal object packs and compositions can be content-only when they use existing mutation/state metadata.

### New templates without code

New templates can be data-only when they use existing presentation and mutation categories. A genuinely new response or mutation mechanic requires a new specification/version.

### Independent art expansion

Artists can add object archetypes, state pairs, compositions, and theme packs through reviewed content manifests. Every state pair requires matching bounds and semantic metadata.

### Data-driven balancing

Designers can tune:

- Object counts
- Similarity ranges
- Minimum target size
- Mutation-category weights
- Exposure/search timing
- Position distance
- Recent-category limits
- Recommendation weight

### Phase 5.5 path

- Additional clean comparison environments
- Seasonal object packs
- More state-pair animations for reveal only
- Additional simultaneous/sequential templates using accepted response modes
- Program and Collection sets

Routine expansion must not require Engine changes.

## 17. Audio and Haptics

Proposed family audio profile:

- Presentation settle: quiet paired-panel placement
- Sequential conceal: soft neutral tick
- Tap lock-in: restrained click
- Correct reveal: concise upward two-note cue
- Miss/timeout reveal: soft descending cue
- UI sounds: shared
- Haptic: light tap on response, existing correct/miss result pattern

Audio never indicates the changed panel, object, mutation category, or target location.

Mute preserves all visual timing cues.

## 18. Visual Identity

### Recognizable composition

Two clean framed panels labeled **A** and **B**, separated by a precise central gutter. The paired composition should identify the family before its title appears.

### Art direction

- Editorial comparison boards
- Large readable object silhouettes
- Controlled neutral panel backgrounds
- Restrained object count and clutter
- No photographic pixel-hunt noise in v1
- Matched camera, lighting, and panel scale

### Palette

- Product-dark outer shell
- Warm neutral or cool neutral panel surfaces
- Purple interaction focus
- Amber/brass reveal outline
- High-contrast A/B labels

### Animation

- Panels settle without bounce
- Sequential mode uses brief opacity conceal
- Player marker appears immediately
- Correct target outline draws only after response
- Reduced Motion removes transition animation

### Marketing recognition

Side-by-side panels and one subtle changed detail are strong screenshot/video material. Spot the Difference is a potential secondary signature family, while Scene Investigation remains the current flagship candidate.

## 19. Tutorial Flow

**Tutorial version:** 1

1. **The pair:** Explain that A and B match except for one fair change.
2. **Large demonstration:** Show four objects and one obvious missing item.
3. **Guided tap:** Player taps the changed object while both panels remain visible.
4. **Evidence reveal:** Outline the object and explain the exact mutation.
5. **State change:** Demonstrate open → closed.
6. **Sequential preview:** Briefly show A then B and explain the added memory demand.
7. **Practice:** Launch Side-by-Side Presence at Beginner.

Skip persists tutorial version but keeps replay in the Challenge Library.

## 20. Analytics and Balancing

Privacy-respecting events:

- Tutorial start/step/completion/skip
- Template and mutation-category selection
- Difficulty/exposure/search window
- Validation rejection rule ID
- Spatial versus accessible-list response
- Correct/miss/timeout
- Response time
- Tap distance from correct region after scoring
- Replay/Continue
- Recommendation and Program source

Never emit raw screen coordinates beyond normalized diagnostic buckets, content screenshots, or player identity.

Balancing controls are content/policy data rather than remote executable code.

## 21. Performance and Asset Budget

Proposed local budgets:

- Maximum total panel objects: 28 across both panels
- Generator average: <12 ms on local reference
- Validator average: <4 ms
- Pair renderer construction: <16 ms reference frame
- No per-frame allocations after presentation settles
- Object textures bounded by existing import policies
- Shared immutable art cached across panels
- Truth graphs duplicated as data, not duplicate source textures
- Responsive 360×640 through tablet layouts

Fallback uses family vector shapes and requires no optional downloaded asset.

## 22. Validation Plan

### Contract/runtime

- Registration and ownership validation
- No family IDs in shared runtime/UI response adapter
- Tutorial context and Program context
- Exactly-once progress
- Replay/Continue/Home lifecycle
- Controlled generation failure

### Generation/fairness

- All four templates × four tiers
- Exactly one semantic target
- Base/B clone equivalence outside mutation
- Target size and hit-region bounds
- No overlapping eligible hit regions
- Position-distance bounds
- Color Assistance category exclusion
- Search/exposure timing bounds
- Known-valid fallback

### Reproduction

- 100 sampled seeds regenerated at least three times
- Serialized instances, targets, regions, and scores must match

### Variety

- 20-round mixed session
- Template and mutation rotation
- No exact signature repetition
- No immediate mutation-category repetition when alternatives exist

### Stress

Default release target:

```text
4 templates × 4 tiers × 10,000 seeds = 160,000 validated instances
```

### Accessibility

- 140% Text Size
- High Contrast
- Reduced Motion
- Comfortable Timing
- Color Assistance
- Spatial tap and accessible target-choice parity
- Compact phone, notched phone, tablet, and unfolded layout checks

### Visual/human review

- Side-by-side alignment contact sheets
- Sequential flow captures
- Correct/miss/timeout reveals
- Minimum-target-size captures
- 20-round fairness/replay session
- 50-round Replay Value review before final production approval

## 23. Success Criteria

- First-time tutorial player identifies the mechanic without another family’s tutorial.
- Every accepted instance contains exactly one semantic changed target.
- Zero validator failures in the final 160,000-instance stress batch.
- Same-seed reproduction has zero differences in 100 sampled audits.
- No exact repeat in a 20-round mixed session.
- Spatial and accessible-list response modes resolve identical target truth.
- All target regions meet minimum size and non-overlap rules.
- Every miss reveal identifies exact before/after evidence.
- Replay Value retains at least 18/25 after 50-round human review.
- Generator, validator, renderer, and memory remain within declared budgets.
- Family implementation requires no concrete-family branch in shared runtime, Home, Programs, Profile, or ResultService.

## 24. Non-Goals

- Multiple simultaneous differences in v1
- Competitive leaderboards or fastest-time ranking
- Photographic pixel-hunt scenes
- User-generated images
- Online downloaded executable content
- Narrative wrapper or fictional investigation department
- Trivia or specialized object knowledge
- Color-only required play
- Reusing Scene Investigation generator or validator as the family implementation

## 25. Acceptance Review

```text
Design specification: APPROVED AND IMPLEMENTED
Portfolio distinction: APPROVED
Architecture review: APPROVED — generic Interaction Adapter architecture
Fairness contract: APPROVED LOCALLY
Accessibility plan: APPROVED LOCALLY
Visual identity: APPROVED LOCALLY
Replay Value score: 22 / 25 — local procedural evidence; long-session human review remains
Expansion potential: APPROVED
Validation plan: PASSED LOCALLY
Implementation order: COMPLETED — first Phase 5 family
Implementation authorized: COMPLETED
```

Physical-device and long-session human review remain release work rather than local implementation blockers.

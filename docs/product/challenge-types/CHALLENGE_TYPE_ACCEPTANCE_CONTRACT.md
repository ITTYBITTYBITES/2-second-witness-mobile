# Challenge Type Acceptance Contract

**Status:** Required design gate for every Phase 5 production Challenge Type
**Applies to:** New families, major family mechanic revisions, and production promotion of experimental families

A Challenge Type may not enter implementation until every required section below is complete and the final approval block is signed off. The detailed [`CHALLENGE_TYPE_SPEC_TEMPLATE.md`](CHALLENGE_TYPE_SPEC_TEMPLATE.md) is the authoring form; this contract is the acceptance gate.

## 1. Identity and portfolio role

Required:

- Internal `family_id`, version, and player-facing Challenge Type name
- One-sentence entertainment-first description
- Core gameplay objective
- Observation task
- Primary mechanic
- Intended player feeling during the challenge
- Intended player feeling after success and after a miss
- **Why does this exist?** What experience does it provide that no other Challenge Type does?
- Why would a player intentionally choose it over another Challenge Type?
- Explicit distinction from every implemented and approved planned family
- Portfolio coverage added by the family
- Portfolio role: flagship candidate, core family, specialist, or experimental
- Non-goals for its first production version

**Acceptance:** The family occupies a clear gameplay space, gives players a reason to choose it, creates a deliberate emotional arc, and does not rely on assessment-oriented positioning.

## 2. Player actions and challenge flow

Define:

- Information shown to the player
- Player actions during presentation, if any
- Response interaction: tap, choice, grid input, swipe, tracking, keypad, audio choice, or another declared mode
- Family-specific flow mapped onto the shared runtime
- Abandon, replay, Continue, and tutorial behavior
- Maximum expected round duration

Required runtime mapping:

```text
Request Session
→ Select Challenge Type
→ Select Template
→ Resolve Difficulty
→ Resolve Exposure
→ Generate
→ Validate
→ Present
→ Player Response
→ Result
→ Witness Progress
→ Recommendation
→ Home or Continue
```

**Acceptance:** No route or player action bypasses `ChallengeSessionService`.

## 3. Templates

The initial production family must propose **3–6 mechanically meaningful templates** unless an approved exception explains why fewer produce equivalent variety.

For each template define:

- Stable ID and version
- Player prompt
- Layout/presentation pattern
- Variable parameters
- Question and response modes
- Distractor rules
- Difficulty and exposure bounds
- Required content/assets
- Known-valid fallback
- What makes the template distinct inside its family

**Acceptance:** Templates change meaningful play, not merely artwork or wording.

## 4. Generator contract

Define:

- Seed and version inputs
- Generated data versus fixed authored data
- Candidate construction order
- Parameter bounds
- Duplicate/recent-content avoidance
- Determinism requirements
- Truth resolution before presentation
- Bounded retry behavior
- Known-valid fallback generation
- Content safety checks

**Acceptance:** Identical versioned inputs and seed reproduce the same `ChallengeInstance` and answer.

## 5. Validator and fairness contract

Define validator rule IDs for:

- Exactly one correct answer or one unambiguous accepted response set
- Required information visibility/audibility
- Readability and minimum target size
- Legal distractors
- Achievable timing
- Layout, overlap, path, motion, or sequence constraints
- Accessibility configuration
- Required asset availability
- Complete reproduction metadata
- Family-specific ambiguity risks

Also define:

- Rejection reason exposed to diagnostics
- Retry eligibility
- Fallback conditions
- Cases that must fail without navigation or progress side effects

**Acceptance:** Every miss should be explainable as “I missed it,” never as missing, hidden, ambiguous, or unfair information.

## 6. Difficulty axes

List independent difficulty axes and safe ranges.

For each axis define:

- Beginner, Standard, Advanced, and Expert bounds
- Increase/decrease conditions
- Maximum per-round change
- Prohibited combinations
- Interaction with accuracy, Mastery, streaks, and misses
- Accessibility overrides

**Acceptance:** Difficulty is multi-axis, bounded, and does not increase several tightly coupled demands at once without evidence of fairness.

## 7. Exposure timing policy

Define:

- Minimum, default, and maximum exposure
- Template-specific timing
- Sequence/interval timing where applicable
- Whether presentation is single, repeated, simultaneous, sequential, or continuous
- Comfortable Timing, Reading Comfort, Reduced Motion, and other relevant accommodations
- Timing conditions that invalidate an instance

**Acceptance:** Timing supports the mechanic and never substitutes surprise for difficulty.

## 8. Scoring and result presentation

Define the family-owned ScoringPolicy:

- Correctness/accepted-response resolution
- Score components and caps
- Witness Progress
- Mastery change
- Streak behavior
- Response-time use, if fair
- Incorrect-answer participation progress

Define Result behavior:

- Player response
- Correct answer/accepted response
- Exact explanation
- Reveal, comparison, path, highlight, or replay evidence
- Where to look/listen
- Near-miss treatment when meaningful
- Replay and recommended next action

**Acceptance:** The result teaches the mechanic and provides concrete evidence without family branches in `ResultService`.

## 9. Tutorial requirements

Define:

- Versioned `TutorialProfile`
- Interactive mechanic demonstration
- Guided response
- Clear reveal/explanation
- Accessibility setup where relevant
- Practice template
- Skip and replay behavior
- Completion persistence

**Acceptance:** A first-time player can understand the unique mechanic without prior knowledge of another Challenge Type.

## 10. Accessibility requirements

Declare:

- Color-independent behavior or an explicit Color Assistance policy
- Contrast and minimum visual size
- Text scaling
- Reduced Motion behavior
- Timing accommodation
- Touch target and alternative input requirements
- Audio alternatives for required sound
- Visual alternatives for required audio where the mechanic permits
- Recommendation/Program opt-out behavior when the core mechanic cannot be equivalently transformed
- Screen-reader behavior that does not reveal hidden scored information

**Acceptance:** Accessibility is designed with the mechanic. It is not retrofitted after content production.

## 11. Audio and haptic profile

Define:

- Presentation cues
- Interval/motion cues
- Conceal/reveal cues
- Correct and incorrect feedback
- Haptics
- Mute/reduced-audio behavior
- Whether audio contains scored information
- Audio asset ownership and versioning

**Acceptance:** Audio supports timing and identity without revealing an answer or using casino-style reinforcement.

## 12. Visual style

Define:

- Art direction and family identity
- Instantly recognizable pre-play silhouette/composition
- Palette and contrast
- Scene, typography, symbol, motion, or pattern style
- Signature framing, layout, and transition language
- Clutter and similarity rules
- Animation tone
- Reveal treatment
- Required artwork and responsive layouts
- Relationship to existing families
- Marketing/screenshot recognition potential

**Acceptance:** A player should recognize the Challenge Type before reading its title. The family is distinctive and premium while remaining visually cohesive with the product shell.

## 13. Progress and recommendation integration

Define:

- Record key
- Family Mastery inputs
- Accuracy and streak updates
- History metadata
- Seeds/signatures/recent content retained
- Achievement opportunities
- Collection contribution
- Witness Level requirement
- Family-owned recommendation weight
- Recommendation reasons
- Program focus tags
- Repetition limits and Continue behavior

**Acceptance:** All persistence passes through `PlayerProgressService`/`ProfileService`; selection uses existing recommendation and Program services.

## 14. Replay Value score

Define the replayability strategy:

- Combinatorial sources of variety
- Minimum content pool
- Recent-content avoidance
- Exact-instance signature
- Expected unique rounds before repetition
- Twenty-round session variety target
- Template rotation
- Content expansion path for Phase 5.5

Score each criterion from **1–5** with evidence:

| Criterion | Question |
|---|---|
| Template variety | Do templates create meaningfully different play rather than cosmetic swaps? |
| Generation diversity | How many fair combinations can generation produce? |
| Memorization resistance | Does repeated play remain uncertain without relying on arbitrary noise? |
| Strategy variety | Can attention or response approach vary while the mechanic stays clear? |
| Long-term freshness | Is the family expected to remain rewarding after 50+ rounds and future content additions? |

Required total: **18/25 or higher**, with no individual score below **3**. Any lower score requires specification revision before implementation.

**Acceptance:** Replay value is supported by evidence and meaningful mechanic/content variation, not a claim that procedural generation is automatically replayable.

## 15. Expansion potential

Define:

- Seasonal/themed content potential
- Whether designers can add templates without code
- Whether artists/audio designers can expand content independently
- Which balancing values are data-driven
- Localization/content-pack strategy
- How the family scales from initial production content to Phase 5.5 volume
- Code changes that would be required for expansion, if any

**Acceptance:** Routine content and balancing expansion must not require Engine changes. Any family-code requirement is explicit and bounded.

## 16. Analytics and balancing

Define privacy-respecting events for:

- Tutorial behavior
- Template/policy selection
- Difficulty and exposure
- Validation rejection rules
- Completion/abandonment
- Accuracy and response time
- Replay and Continue
- Recommendation acceptance

Define balancing controls and safe defaults.

**Acceptance:** Events describe game behavior and never imply medical, psychological, educational, or professional measurement.

## 17. Performance and asset budget

Define:

- Peak generated object/item count
- Texture/audio size expectations
- Scene construction budget
- Validation/generation budget
- Memory lifecycle
- Small-phone and tablet layout behavior
- Degraded/fallback behavior for missing assets

**Acceptance:** The family fits established cold-start, navigation, memory, and Android constraints.

## 18. Validation plan

Minimum local proof before production acceptance:

- Full source loading with no warnings
- Contract and architecture static checks
- Complete first-visit tutorial → practice → result flow
- Same-seed reproduction audit
- Difficulty/exposure boundary tests
- Validator rejection and fallback tests
- Accessibility configuration tests
- Exactly-once progress and immutable-result tests
- Twenty-round variety session
- At least 100 sampled reproduction comparisons
- Release stress target defined per template/tier; default target is 10,000 seeds/template/tier
- Existing platform and family regressions
- Content and terminology checks
- Visual review artifacts outside the exported app
- Physical-device checks listed separately when unavailable locally

**Acceptance:** Warnings count as failures. Known physical-only work is explicit rather than represented as locally passed.

## 19. Success criteria

The specification must state measurable success criteria for:

- Mechanical clarity
- Fairness
- Replayability
- Accessibility
- Difficulty range
- Result explanation
- Runtime integration
- Portfolio distinction
- Performance
- Content readiness

## 20. Required approval block

No implementation begins until all fields are complete:

```text
Design specification: APPROVED / NOT APPROVED
Portfolio distinction: APPROVED / NOT APPROVED
Architecture review: APPROVED / NOT APPROVED
Fairness contract: APPROVED / NOT APPROVED
Accessibility plan: APPROVED / NOT APPROVED
Visual identity: APPROVED / NOT APPROVED
Replay Value score: __ / 25 — APPROVED / NOT APPROVED
Expansion potential: APPROVED / NOT APPROVED
Validation plan: APPROVED / NOT APPROVED
Implementation order: APPROVED / NOT APPROVED
Implementation authorized: YES / NO
```

Any `NOT APPROVED` or `NO` keeps the family out of production implementation.

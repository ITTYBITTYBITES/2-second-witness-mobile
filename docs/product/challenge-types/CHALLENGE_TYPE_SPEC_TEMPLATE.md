# Challenge Type Specification Template

Complete and approve this specification before implementing a production Challenge Type. This document is the authoring form for the mandatory [`CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md`](CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md); completing the form does not authorize implementation until every acceptance gate is approved.

## 1. Identity

- Internal family ID:
- Player-facing Challenge Type name:
- Version:
- Short description:
- Gameplay focus:
- Player fantasy:
- Portfolio role: flagship candidate / core family / specialist / experimental
- Why does this Challenge Type exist?
- Why would a player intentionally choose it?
- Intended feeling during play:
- Intended feeling after success:
- Intended feeling after a miss:
- Closest existing/planned families:
- Mechanical distinction from each:

## 2. Player Goal

Describe what the player is trying to notice, remember, track, recognize, or deduce. State the goal in player-facing language without assessment-oriented claims.

Define:

- Core gameplay objective
- Observation task
- Primary mechanic
- Information presented
- Player actions during presentation
- Response interaction
- Rewarding moment

## 3. Core Gameplay Loop

```text
Launch
→ Tutorial check
→ Presentation
→ Response
→ Reveal
→ Progress
→ Recommendation
→ Replay or Home
```

Document any family-specific steps without bypassing `ChallengeSessionService`.

## 4. Templates

For every planned template, define:

- Template ID and version
- Player prompt
- Layout/presentation pattern
- Variable parameters
- Question types
- Valid response modes
- Distractor rules
- Scoring requirements
- Difficulty and exposure bounds
- Known-valid fallback

## 5. Generation Rules

- Seed inputs and version identity
- Parameter ranges
- Placement/layout constraints
- Duplicate prevention
- Candidate construction order
- Determinism requirements
- Maximum generation attempts
- Fallback behavior

All challenge truth must resolve before presentation.

## 6. Difficulty Axes

List independent axes and safe ranges. Examples include object count, similarity, clutter, motion, object size, question complexity, distractor quality, and exposure duration.

Define:

- Beginner defaults
- Adjustment step size
- Increase conditions
- Decrease conditions
- Axis combinations that are prohibited
- Maximum change between consecutive rounds

## 7. Exposure Policy

- Minimum duration
- Maximum duration
- Default duration
- Template-specific overrides
- Difficulty scaling
- Unlimited/repeated/multiple-presentation behavior, if supported
- Reduced-motion or accessibility behavior

Fairness takes priority over shorter timing.

## 8. Fairness Rules

Every instance must define validators for:

- Exactly one correct answer or one unambiguous accepted response set
- Required information visibility
- Readability
- Valid distractors
- Achievable timing
- Non-overlap and placement constraints
- Accessibility compliance
- Deterministic reproduction
- Required asset availability

List rejection rule IDs and fallback conditions.

## 9. Accessibility

- Color-independent cues
- Contrast requirements
- Minimum object/text size
- Touch targets
- Reduced-motion behavior
- Audio alternatives or visual alternatives
- Screen-reader labels where applicable
- Timing accommodations that preserve the mechanic

## 10. Presentation Profile

- Presentation mode and route
- Response mode and route
- Result mode and route
- Artwork profile
- Animation profile
- Orientation/layout requirements
- Safe-area behavior

The shared runtime must not contain a branch for this profile.

## 11. Result Behavior

Define:

- Outcome
- Correct answer or accepted response
- Player response
- Explanation
- Reveal/highlight behavior
- Where to look
- How close the player was, when meaningful
- Gameplay focus
- Recommended next action
- Replay behavior

State whether the standard scorer is sufficient or a family-supplied `ScoringPolicy` is required. Do not add family-specific scoring logic to `ResultService`.

## 12. Witness Progress

- Record key
- Progress earned
- Accuracy updates
- Streak behavior
- Challenge Type Mastery inputs
- Milestones/achievements
- Difficulty history retained
- Seed/history retention

All writes must pass through `PlayerProgressService` and the existing profile/save foundation.

## 13. Recommendation Behavior

- When this type should be recommended
- When difficulty should decrease
- When difficulty should increase
- Repetition limits
- Continue behavior
- Suggested next template rules
- Family-owned recommendation weight and rationale
- Program focus tags
- Favorite/Program behavior

Programs may select the type but may not implement its gameplay.

## 14. Replayability Strategy

- Sources of meaningful variation
- Minimum content pool
- Recent-content avoidance
- Exact-instance signature
- Expected rounds before repetition
- Template rotation
- Twenty-round variety target
- Phase 5.5 content expansion path

Score with evidence:

| Replay Value criterion | Score (1–5) | Evidence |
|---|---:|---|
| Template variety | | |
| Generation diversity | | |
| Memorization resistance | | |
| Strategy variety | | |
| Long-term freshness | | |
| **Total** | **/25** | Minimum 18; no criterion below 3 |

## 15. Expansion Potential

- Seasonal/themed content support:
- Templates addable without code:
- Artist expansion independent of code:
- Audio/content expansion independent of code:
- Data-driven balancing controls:
- Localization/content-pack strategy:
- Phase 5.5 expansion path:
- Required family-code changes, if any:

## 16. Audio Profile

- Ambient layer
- Presentation music
- Time-pressure cues
- Reveal sting
- Correct/incorrect feedback
- Result music
- UI sounds
- Haptics
- Reduced-audio behavior

Feedback must remain refined and avoid casino-style reinforcement.

## 17. Visual Style

- Scene/art direction
- Instantly recognizable pre-play silhouette/composition
- Signature framing/layout language
- Palette
- Lighting
- Object style
- Clutter rules
- Reveal treatment
- Animation tone
- Marketing/screenshot recognition potential
- Required assets

## 18. Tutorial Flow

- Tutorial version
- Mechanic taught
- Interactive steps
- Demonstration instance
- Success requirement
- Skip behavior
- Replay entry
- Completion persistence

Teach only this Challenge Type’s mechanic.

## 19. Analytics and Balancing

Define privacy-respecting events for:

- Tutorial start/completion/skip
- Template selection
- Difficulty and exposure settings
- Candidate rejection rule IDs
- Completion/abandonment
- Accuracy and response time
- Replay
- Recommendation acceptance

No event may imply medical, educational, psychological, or professional evaluation.

## 20. Validation Plan

- Minimum deterministic seeds tested per template
- Property/fairness assertions
- Difficulty-boundary cases
- Accessibility configurations
- Fallback tests
- Failure-side-effect tests
- Device/manual touch checks
- Replayability session target

## 21. Success Criteria

Define measurable acceptance for:

- Mechanical clarity
- Fairness
- Replayability
- Accessibility
- Difficulty range
- Result explanation
- Runtime integration
- Portfolio distinction
- Generation/validation performance
- Production content readiness

## 22. Non-Goals

List features explicitly excluded from the first production version of this Challenge Type.

## 23. Approval

- Design specification approved:
- Portfolio distinction approved:
- Architecture reviewed:
- Fairness contract approved:
- Accessibility plan approved:
- Visual identity approved:
- Replay Value score: /25 — approved:
- Expansion potential approved:
- Validation plan approved:
- Implementation order approved:
- Implementation authorized: YES / NO

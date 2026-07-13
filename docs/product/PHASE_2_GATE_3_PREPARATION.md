# Phase 2 Gate 3 Preparation — Design Approval Package

**Date:** 2026-07-11
**Implementation status:** Not started

## Deliverables

- [`challenge-types/SCENE_INVESTIGATION_SPEC.md`](challenge-types/SCENE_INVESTIGATION_SPEC.md)
- [`SCORING_POLICY_CONTRACT.md`](SCORING_POLICY_CONTRACT.md)
- [`challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md`](challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md)
- Updated Product Development roadmap and gate definitions

No production Scene Investigation generator, template, tutorial, scoring policy, artwork, audio, or progression code was implemented during preparation.

## Proposed Scene Investigation scope

### Core loop

```text
Brief
→ Observe
→ Memory moment
→ Question
→ Answer
→ Evidence reveal
→ Result
→ Witness Progress
→ Recommendation
→ Replay or Home
```

### Production templates

Implemented Gate 3 scope:

- Office
- Kitchen
- Workshop

Specification-only deferred scope:

- Museum
- Vehicle
- Outdoor Scene

Each template specification defines object groups, pools, composition zones, allowed questions, variation rules, difficulty variables, accessibility restrictions, and content minimums. Deferred templates have no Gate 3 assets or generator branches.

### Question types

- Count
- Attribute
- Position
- Adjacency
- Presence
- Region/container

Initial production responses remain single-choice and binary. The scoring architecture allows future partial credit without modifying shared session orchestration.

### Exposure policy

- Beginner: 5.0–6.0 seconds
- Standard: 3.5–5.0 seconds
- Advanced: 2.0–3.5 seconds
- Expert: 1.5–2.0 seconds

Timing never falls below two seconds in the proposed first production version.

### Difficulty

Independent axes include object count, target size, semantic and visual similarity, decorative clutter, spatial spread, relationship complexity, distractor similarity, exposure, and question complexity.

Adaptation changes at most two axes between rounds and prefers content complexity before reducing exposure.

### Fairness

The specification defines validators for contract completeness, required groups, visibility, size, overlap, safe areas, contrast, unique targets/answers, distractors, relationships, accessible attributes, exposure, reveal evidence, assets, and reproduction identity.

### Stress thresholds

- Development: at least 2,000 seeds per template and tier
- Release candidate: at least 10,000 seeds per template and tier
- Zero ambiguous accepted instances
- Candidate rejection below 5%
- Fallback presentation below 0.1%
- No recent-window duplicate scene signatures

## Proposed ScoringPolicy

Scoring becomes family-owned through:

- `calculate_result`
- `calculate_score`
- `calculate_progress`
- `calculate_mastery_change`
- `explain_outcome`

The runtime executes the policy and remains unaware of binary, partial-credit, time-weighted, multi-question, or streak rules.

Gate 3 v1 proposes:

- Binary correctness for initial questions
- Internal score range 0–1000
- 800 base points for a correct answer
- Up to 150 difficulty points
- Optional capped 50-point speed component at Standard or above after fairness testing
- No Beginner speed component
- No initial partial credit
- Bounded per-round mastery change

## Tutorial proposal

Tutorial version 2 includes:

1. Brief explanation
2. Untimed Office demonstration
3. Guided recall question
4. Evidence reveal
5. Six-second Beginner practice round
6. Completion and replay/Home explanation

The tutorial teaches the mechanic but not the upcoming target, generation rules, recommendation algorithm, mastery formula, or validators.

## Audio and visual proposal

- Unified premium editorial 2D artwork
- Consistent perspective and line weight across object pools
- Category-specific accessible palettes
- Soft shadows and restrained texture
- Evidence highlights using established focus colors
- Understated ambient, observation, conceal, selection, reveal, and result cues
- No casino-style feedback
- Audio never required for a visual answer

## Approved decisions

1. Gate 3 implements Office, Kitchen, and Workshop.
2. Museum, Vehicle, and Outdoor remain specification-only.
3. Exposure tiers are Beginner 5–6 s, Standard 3.5–5 s, Advanced 2–3.5 s, and Expert 1.5–2 s.
4. Exposure is one difficulty axis; shorter is not automatically harder.
5. Family-owned ScoringPolicy is approved.
6. Initial scoring remains binary with the proposed 0–1000 model.
7. Large seed batches, zero ambiguous accepted answers, reproducible failures, and stable performance are required.
8. Tutorial version 2 and unified editorial 2D direction are approved.
9. Gate 3 implementation is authorized.

## Next step

Implement the approved ScoringPolicy contract and production Scene Investigation incrementally. Do not implement a second Challenge Type during Gate 3.

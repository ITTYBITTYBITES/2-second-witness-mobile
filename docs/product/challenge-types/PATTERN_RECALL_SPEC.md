# Pattern Recall — Production Specification

**Status:** Production-complete; expanded in Phase 5.5
**Family ID:** `pattern_recall`
**Interaction:** Sequence Input

## Purpose

Pattern Recall owns abstract arrangement and ordered visual reconstruction. It does not use words, object-set membership, or scene questions.

## Templates

- `grid_path_v1` — repeat an ordered path through grid cells
- `shape_sequence_v1` — repeat an ordered sequence of abstract shapes
- `pattern_build_v1` — repeat the order in which a spatial pattern was built

## Runtime ownership

The family owns generator, validator, DifficultyPolicy, ExposurePolicy, ScoringPolicy, sequence renderer, TutorialProfile/tutorial, progress rules, and recommendation metadata. It declares `sequence_input` through InteractionProfile.

## Generation

The seeded generator resolves grid dimensions, legal token pool, sequence length/order, pulse interval, interaction tokens, correct sequence, and deterministic scene signature before presentation. Grid modes produce connected non-repeating paths. Shape Sequence draws from 12 named, custom-rendered geometric symbols without immediate repeats.

## Difficulty and exposure

- Beginner: 3×3 / 3 steps / 1.05 s pulse
- Standard: 3×3 / 4 steps / 0.86 s pulse
- Advanced: 4×4 / 5 steps / 0.72 s pulse
- Expert: 4×4 / 6 steps / 0.60 s pulse

Exposure is sequence length × pulse interval. Comfortable Timing increases total presentation by 25%.

## Fairness

- Sequence contains at least three legal tokens.
- Every response token is available in the interaction grid.
- Order is fully resolved before presentation.
- Discrete cell changes use no motion interpolation, preserving Reduced Motion behavior.
- Family scoring compares exact ordered arrays.

## Result

Result states and reveals the exact sequence in order. Grid evidence draws the complete path with numbered cells; shape evidence displays numbered symbol cards. A miss uses “I missed it.” and identifies how many leading steps matched.

## Accessibility

- Shape and grid labels supplement color
- Discrete transitions under Reduced Motion
- High Contrast grid states
- Text scaling
- Large token buttons
- Undo before submit
- Comfortable Timing

## Replay Value

Variety comes from grid size, token pool, ordered path, sequence length, shape repetition, template mode, pulse interval, and seed. Pattern truth remains reproducible.

## Validation

- Three templates and four tiers
- Runtime Sequence Input proof
- 100-seed deterministic audit per template
- Twenty-round variety proof
- 120,000-instance final stress scope (10,000 seeds/template/tier)

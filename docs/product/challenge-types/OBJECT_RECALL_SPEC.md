# Object Recall — Production Specification

**Status:** Production-complete; expanded in Phase 5.5
**Family ID:** `object_recall`
**Interaction:** Multiple Choice

## Purpose

Object Recall owns isolated set membership and position memory. Unlike Scene Investigation, it presents a clean object tray without scene relationships. Unlike Spot the Difference, it has no before/after mutation.

## Templates

- `seen_set_v1` — select every object that appeared
- `missing_set_v1` — select the two objects that did not appear
- `position_group_v1` — select every object shown on the top row
- `bookends_v1` — select the first and last objects in reading order

## Runtime ownership

The family owns generator, validator, DifficultyPolicy, ExposurePolicy, ScoringPolicy, object-tray renderer, TutorialProfile/tutorial, progress key, artwork/audio/animation profiles, and recommendation metadata. It declares `multiple_choice` through InteractionProfile and launches only through ChallengeSessionService.

## Generation

A seeded generator samples distinct objects from a 48-object data-driven pool with readable labels and more than 30 silhouette kinds, resolves a clean two-row tray layout, creates unique answer options, computes the exact correct set, and stores a deterministic scene signature.

## Difficulty and exposure

- Beginner: 3 shown / 6 options / 5.8 s
- Standard: 4 shown / 7 options / 4.9 s
- Advanced: 5 shown / 8 options / 4.1 s
- Expert: 6 shown / 9 options / 3.4 s

Comfortable Timing increases exposure by 30% without reducing progress.

## Fairness

- Correct set is nonempty and entirely present in answer options.
- Options are unique.
- Objects are large, isolated, and labeled only in the reveal/presentation art as designed.
- Multiple Choice submits one set; family scoring compares normalized sets without order dependence.
- Known-valid deterministic generation remains available.

## Result

Result reveals the tray, highlights present answers in place, adds a dedicated NOT SHOWN evidence row for absent answers, lists missed/extra choices, and uses “I missed it.” for a miss.

## Accessibility

- No color-only answer dependency
- Large isolated objects
- 48-pixel Multiple Choice controls
- Text scaling and High Contrast
- Comfortable Timing
- Reduced Motion-safe static presentation

## Replay Value

Variety comes from object combinations, set size, answer pool, template objective, arrangement, and seed. Recent signatures prevent immediate exact repeats.

## Validation

- Four templates and four tiers
- Runtime interaction proof
- 100-seed deterministic audit per template
- Twenty-round variety proof
- 160,000-instance final stress scope (10,000 seeds/template/tier)

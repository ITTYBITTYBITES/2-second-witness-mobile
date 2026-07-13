# Product Development Documentation

The validated Foundation remains stable. Product Development evolves gameplay and product presentation without replacing application infrastructure.

## Current status

**Phase 6 — Production Readiness locally complete**

Phase 5 and Phase 5.5 are approved. Five production Challenge Types run through the frozen shared Challenge Runtime and generic Interaction Adapter system. Phase 6 completes local UI, accessibility, persistence, offline, performance, Android configuration, credits, privacy, and release-workflow hardening. Human 20/50-round play review, signed-artifact review, and the physical Android hardware boot gate remain open.

## Source of truth

1. [`PRODUCT_DEVELOPMENT_ROADMAP.md`](PRODUCT_DEVELOPMENT_ROADMAP.md) — phased plan and stop gates.
2. [`ARCHITECTURE_BOUNDARIES.md`](ARCHITECTURE_BOUNDARIES.md) — Engine, Game, Content, and product UI responsibilities.
3. [`CHALLENGE_CONTRACTS.md`](CHALLENGE_CONTRACTS.md) — family, template, instance, presentation, validation, and result contracts.
4. [`CHALLENGE_RUNTIME_API.md`](CHALLENGE_RUNTIME_API.md) — shared runtime API.
5. [`PHASE_3_HOME_EXPERIENCE_SPEC.md`](PHASE_3_HOME_EXPERIENCE_SPEC.md) — Home/product-hub contract.
6. [`PHASE_3_HOME_EXPERIENCE_COMPLETION.md`](PHASE_3_HOME_EXPERIENCE_COMPLETION.md) — Phase 3 implementation and validation record.
7. [`PHASE_3_5_PRODUCTION_POLISH_SPEC.md`](PHASE_3_5_PRODUCTION_POLISH_SPEC.md) — polish scope and acceptance budgets.
8. [`PHASE_3_5_DEVICE_VALIDATION_MATRIX.md`](PHASE_3_5_DEVICE_VALIDATION_MATRIX.md) — local and physical Android matrix.
9. [`PHASE_3_5_PRODUCTION_AUDIT.md`](PHASE_3_5_PRODUCTION_AUDIT.md) — findings and resolutions.
10. [`PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md`](PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md) — local closeout and device-only remainder.
11. [`PHASE_4_PLAYER_JOURNEY_SPEC.md`](PHASE_4_PLAYER_JOURNEY_SPEC.md) — curated Programs and complete player lifecycle contract.
12. [`PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md`](PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md) — Phase 4 implementation and validation record.
13. [`PHASE_5_PREPARATION_REPORT.md`](PHASE_5_PREPARATION_REPORT.md) — implementation order and portfolio coverage analysis.
14. [`PHASE_5_COMPLETION.md`](PHASE_5_COMPLETION.md) — Interaction System and three-family production closeout.
15. [`PHASE_5_5_CONTENT_QUALITY_COMPLETION.md`](PHASE_5_5_CONTENT_QUALITY_COMPLETION.md) — five-family content/quality closeout.
16. [`PHASE_5_5_REPLAY_QUALITY_AUDIT.md`](PHASE_5_5_REPLAY_QUALITY_AUDIT.md) — 50-round quality proxies and human test gate.
17. [`PHASE_5_5_PLATFORM_FREEZE_BASELINE.json`](PHASE_5_5_PLATFORM_FREEZE_BASELINE.json) — approved pre-polish platform hashes.
18. [`PHASE_6_PRODUCTION_READINESS_COMPLETION.md`](PHASE_6_PRODUCTION_READINESS_COMPLETION.md) — local production-readiness closeout.
19. [`PHASE_6_PLATFORM_BASELINE.json`](PHASE_6_PLATFORM_BASELINE.json) — post-polish frozen platform hashes.
20. [`../store/FINAL_RELEASE_CHECKLIST.md`](../store/FINAL_RELEASE_CHECKLIST.md) — human, hardware, signed-artifact, and store gates.
21. [`INTERACTION_ADAPTER_CONTRACT.md`](INTERACTION_ADAPTER_CONTRACT.md) — generic interaction architecture.
22. [`challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md`](challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md) — required family acceptance gate.
23. [`challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md`](challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md) — implemented/planned mechanical differentiation.
24. [`challenge-types/SPOT_THE_DIFFERENCE_SPEC.md`](challenge-types/SPOT_THE_DIFFERENCE_SPEC.md) — production specification.
25. [`challenge-types/OBJECT_RECALL_SPEC.md`](challenge-types/OBJECT_RECALL_SPEC.md) — production specification.
26. [`challenge-types/PATTERN_RECALL_SPEC.md`](challenge-types/PATTERN_RECALL_SPEC.md) — production specification.
27. [`FAMILY_TUTORIAL_CONTRACT.md`](FAMILY_TUTORIAL_CONTRACT.md) — family-driven tutorial architecture.
28. [`SCORING_POLICY_CONTRACT.md`](SCORING_POLICY_CONTRACT.md) — family-owned scoring architecture.
29. [`challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md`](challenge-types/CHALLENGE_TYPE_SPEC_TEMPLATE.md) — required blueprint for each production Challenge Type.
30. [`challenge-types/SCENE_INVESTIGATION_SPEC.md`](challenge-types/SCENE_INVESTIGATION_SPEC.md) — Scene Investigation specification.
31. [`challenge-types/SCENE_INVESTIGATION_STYLE_GUIDE.md`](challenge-types/SCENE_INVESTIGATION_STYLE_GUIDE.md) — Scene Investigation art direction.
32. [`challenge-types/SCENE_INVESTIGATION_VISUAL_REVIEW.md`](challenge-types/SCENE_INVESTIGATION_VISUAL_REVIEW.md) — Scene Investigation visual review.
33. [`challenge-types/FLASH_WORDS_SPEC.md`](challenge-types/FLASH_WORDS_SPEC.md) — Flash Words specification.
34. [`challenge-types/FLASH_WORDS_STYLE_GUIDE.md`](challenge-types/FLASH_WORDS_STYLE_GUIDE.md) — Flash Words typography direction.
35. [`challenge-types/FLASH_WORDS_VISUAL_REVIEW.md`](challenge-types/FLASH_WORDS_VISUAL_REVIEW.md) — Flash Words visual review.
36. [`PHASE_1_COMPLETION.md`](PHASE_1_COMPLETION.md) — Architecture Preparation record.
37. [`PHASE_2_GATE_1_COMPLETION.md`](PHASE_2_GATE_1_COMPLETION.md) — runtime vertical slice.
38. [`PHASE_2_GATE_2_COMPLETION.md`](PHASE_2_GATE_2_COMPLETION.md) — Runtime Hardening.
39. [`PHASE_2_GATE_3_COMPLETION.md`](PHASE_2_GATE_3_COMPLETION.md) — Scene Investigation production validation.
40. [`PHASE_2_GATE_4_TUTORIAL_CORRECTION_COMPLETION.md`](PHASE_2_GATE_4_TUTORIAL_CORRECTION_COMPLETION.md) — tutorial architecture correction.
41. [`PHASE_2_GATE_4_COMPLETION.md`](PHASE_2_GATE_4_COMPLETION.md) — Flash Words and extensibility proof.
42. [`../foundation/ARCHITECTURE_SUMMARY.md`](../foundation/ARCHITECTURE_SUMMARY.md) — validated infrastructure and current transition state.

## Production Challenge Types

- **Scene Investigation:** Office, Kitchen, Workshop, Travel Desk, Garden Bench
- **Flash Words:** Single Word, Pair Order, Word Stream, Position Catch
- **Spot the Difference:** Presence, Attribute, Sequential, Arrangement
- **Object Recall:** Seen Set, Missing Set, Top Row, Bookends
- **Pattern Recall:** Grid Path, Shape Sequence, Pattern Build

A separate hidden family keeps the five deterministic fixtures executable through the same runtime.

## Product language

Two Second Witness is an entertainment product. Player-facing copy must not imply medical, psychological, educational, or professional measurement.

Preferred terms include Observation, Recall, Recognition, Attention, Focus, Witness Progress, Challenge History, Witness Level, Witness Rank, Challenge Type, Challenge, and Round.

The emotional standard is **“I missed it.”**, never **“That was unfair.”**

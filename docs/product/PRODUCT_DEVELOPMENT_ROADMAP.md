# Two Second Witness — Product Development Roadmap

The Foundation phase is complete and validated. Product Development proceeds one approved phase at a time.

Do not implement this roadmap in a single session. At the end of each phase, summarize the work, list changed files, document decisions and risks, and wait for approval.

## Product vision

Two Second Witness is a premium observation game built around short, fair, procedurally generated challenges.

Players are never taking tests. Players are solving moments.

Every challenge should create:

> “I can’t believe I missed that.”

Never:

> “That was unfair.”

## Foundation invariants

Do not rebuild:

- Boot sequence
- Splash screens
- Navigation
- Save/Profile system
- Theme system
- Accessibility
- Audio services
- Analytics transport
- Shared UI framework
- Project organization

The five fixed challenges remain deterministic regression fixtures until the new gameplay model has approved replacement coverage.

## Product language

Do not use assessment-oriented language in player-facing copy. Avoid terms such as cognitive, brain training, IQ, assessment, diagnostic, and evaluation.

Use game-oriented terms such as Observation, Recall, Recognition, Attention, Focus, Witness Progress, Challenge History, Witness Level, and Witness Rank.

## Phase 1 — Architecture Preparation

**Goal:** Prepare the project for the new gameplay model without changing player behavior.

- Document Engine, Game, and Content responsibilities.
- Create `ChallengeFamily`, `ChallengeTemplate`, and `ChallengeInstance` contracts.
- Remove obsolete lore-based architecture terminology from active application documentation.
- Designate the fixed challenge sequence as regression content.
- Update documentation.
- Do not implement new gameplay.

**Deliverables:** Updated documentation, new behavior-neutral classes, no gameplay changes.

**Gate:** Stop and wait for approval.

## Phase 2 — Challenge Runtime and Production Proof

### Gate 1 — Runtime Exists

Prove one complete Home → Play Now → Session → Family → Template → Difficulty → Exposure → Generation → Validation → Instance → Presentation → Response → Result → Player Progress → Recommendation → Home path.

The deterministic fixtures provide compatibility input. No Challenge Type-specific condition may appear in shared runtime code.

### Gate 2 — Runtime Hardening

Keep this gate short and focused on confidence rather than features:

- Synthetic in-memory Challenge Type tests
- Retry, rejection, and fallback verification
- Failure-path and side-effect testing
- Runtime API freeze
- Architecture enforcement
- A minimal synthetic family with no scene assets

After Gate 2 passes, treat the shared runtime as stable. Do not add more infrastructure unless production gameplay exposes a genuine need.

### Gate 3 — First Production Challenge Type

Build Scene Investigation as the first complete production Challenge Type, replacing fixture-backed implementation in player-facing play while retaining fixtures for regression coverage.

It must include:

- Approved Challenge Type Specification
- Family-specific tutorial
- Multiple balanced templates
- Seeded procedural scene generation
- Fairness validation
- Multi-axis difficulty
- Variable exposure timing, approximately two to six seconds where appropriate
- Clear result explanations
- Witness Progress updates
- Recommendation integration
- Extensive seed and fairness stress testing

Players should be able to spend meaningful time with Scene Investigation without it feeling like a prototype.

### Gate 4 — Second Challenge Type

Flash Words is the proposed mechanically different type.

The architecture review found one pre-existing blocker: shared Tutorial, Title, and Challenge Library code still contain Scene Investigation-specific tutorial behavior. Complete the approved family tutorial architecture correction before Flash Words gameplay implementation.

After that correction, Flash Words must require only new Game and Content modules. If further family-specific Engine or shared-runtime changes are required, stop and correct the architecture before expanding content.

### Permanent fixture requirement

Keep deterministic Challenge 01 and the remaining fixed fixtures executable through the same runtime as generated content. Preserve them as long-term regression coverage.

**Phase gate:** Stop after every gate and wait for confirmation.

## Phase 3 — Home Experience

**Status: Locally complete.**

Home is now a data-driven product hub with Play Now, Continue, a daily feature, Challenge Library, Profile, Achievements, Settings, and Programs Coming Soon. All gameplay entry points use the same Challenge Runtime. Rich catalog cards, the Observation Record, Family Mastery, Challenge History, ten persisted achievements, Collections future readiness, and the complete settings surface are included.

See [`PHASE_3_HOME_EXPERIENCE_SPEC.md`](PHASE_3_HOME_EXPERIENCE_SPEC.md) and [`PHASE_3_HOME_EXPERIENCE_COMPLETION.md`](PHASE_3_HOME_EXPERIENCE_COMPLETION.md).

**Gate:** Stop and wait for approval.

## Phase 3.5 — Production Polish

**Status: Approved locally; Android device/emulator boot gate remains open.**

Harden the completed Home product hub before expanding progression:

- Sponsor-first boot and redesigned loading
- Android safe areas, portrait lock, tablet/foldable widths, scrolling, and touch targets
- Restrained transitions and microinteractions
- Text Size, High Contrast, Reduced Motion, Reading Comfort, and Color Assistance
- Cold start, screen construction, challenge preparation, memory, and texture review
- Full Phase 1–3 regression and production stress validation

See [`PHASE_3_5_PRODUCTION_POLISH_SPEC.md`](PHASE_3_5_PRODUCTION_POLISH_SPEC.md), [`PHASE_3_5_DEVICE_VALIDATION_MATRIX.md`](PHASE_3_5_DEVICE_VALIDATION_MATRIX.md), and [`PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md`](PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md).

**Gate:** Stop and wait for approval.

## Phase 4 — Player Journey and Product Experience

**Status: Complete and approved.**

Phase 4 activates Programs as curated challenge journeys, adds unfinished-Program Continue, Challenge Type favorites, Recently Played, Program Record, meaningful Collection Progress, next-rank guidance, family recommendation weights, and four expanded achievements. Programs remain selection policies over the existing Challenge Runtime.

See [`PHASE_4_PLAYER_JOURNEY_SPEC.md`](PHASE_4_PLAYER_JOURNEY_SPEC.md) and [`PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md`](PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md).

**Gate:** Stop and wait for approval.

## Phase 5 Preparation — Portfolio and Acceptance Standards

**Status: Complete and superseded by Phase 5 implementation.**

Preparation establishes:

- Mandatory Challenge Type Acceptance Contract
- Updated Challenge Type Specification Template
- Portfolio Differentiation Matrix
- Ten-family implementation order
- Portfolio coverage, overlap, gap, accessibility, and risk analysis

See [`PHASE_5_PREPARATION_REPORT.md`](PHASE_5_PREPARATION_REPORT.md), [`challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md`](challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md), and [`challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md`](challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md).

The completed [`challenge-types/SPOT_THE_DIFFERENCE_SPEC.md`](challenge-types/SPOT_THE_DIFFERENCE_SPEC.md) is ready for acceptance review. No new family implementation is authorized by preparation or specification alone.

**Gate:** Stop and wait for Spot the Difference specification approval and explicit implementation authorization.

## Phase 5 — Challenge Type Expansion

**Status: Complete and approved (2026-07-13).**

Phase 5 implemented the generic InteractionProfile/InteractionAdapter architecture and expanded the production portfolio to five mechanically distinct Challenge Types:

1. Scene Investigation
2. Flash Words
3. Spot the Difference
4. Object Recall
5. Pattern Recall

The generic system provides Single Choice, Multiple Choice, Spatial Tap, Region Selection, Ordering, and Sequence Input adapters, with Drag and Drop and Text Entry reserved for future registration. Scene Investigation and Flash Words retain established behavior.

See [`INTERACTION_ADAPTER_CONTRACT.md`](INTERACTION_ADAPTER_CONTRACT.md) and [`PHASE_5_COMPLETION.md`](PHASE_5_COMPLETION.md).

Remaining planned families are deferred pending broader playtesting: Motion Tracking, Hidden Detail, Color Recall, Direction Recall, Symbol Recognition, Number Recall, and Sound Recognition.

**Gate:** Approved.

## Phase 5.5 — Content & Quality Pass

**Status: Complete and approved.**

Deepen the five accepted production Challenge Types rather than adding more families:

- Expand procedural variation and reviewed content pools
- Add only templates with a distinct player decision
- Improve family art, reveals, audio cues, tutorials, and accessibility evidence
- Balance difficulty and recommendation weights across the five-family catalog
- Expand Programs, achievements, and Collection Progress using existing systems
- Audit 50-round replay proxies for every family
- Keep the approved platform frozen except for documented defects

Completed scope includes five Scene Investigation settings and 120 scene archetypes, four Flash Words templates, 48-object Spot the Difference and Object Recall pools, 12 named Pattern Recall symbols, nine Programs, and 26 achievements. See [`PHASE_5_5_CONTENT_QUALITY_COMPLETION.md`](PHASE_5_5_CONTENT_QUALITY_COMPLETION.md) and [`PHASE_5_5_REPLAY_QUALITY_AUDIT.md`](PHASE_5_5_REPLAY_QUALITY_AUDIT.md).

Automated replay audits do not certify fun. Human 20/50-round play sessions remain a Production Readiness gate.

**Gate:** Approved.

## Phase 6 — Production Readiness

**Status: Local implementation complete; prepared for human and physical-device validation.**

Review and prepare the complete version 1.0 product without architectural redesign:

- UI, animation, audio, and haptic polish
- Accessibility and first-time user experience review
- Performance, memory, and asset optimization
- Android-specific, tablet, foldable, and large-screen review
- Save migration, offline behavior, and error handling
- Final balancing informed by serious human playtesting
- Authoring/debug tools and release workflow
- Release packaging, store assets, privacy/legal, credits, and open-source licenses
- Final release checklist and physical Android sponsor-first boot approval

Local implementation is recorded in [`PHASE_6_PRODUCTION_READINESS_COMPLETION.md`](PHASE_6_PRODUCTION_READINESS_COMPLETION.md). Human playtesting, physical Android validation, signed-artifact review, and store/legal signoff remain external release gates.

**Gate:** Local milestone complete; stop for release-gate review.

## Permanent principles

- Entertainment first.
- Fairness before difficulty.
- Every Challenge Type teaches itself.
- Every challenge should be replayable.
- Every result should encourage another attempt.
- Accessibility is a first-class feature.
- New Challenge Types plug into shared runtimes.
- Shared Engine code contains no family-specific rules.
- The player should feel they are becoming a better witness.
- Failure should create an “I missed it” moment, never a sense that the game was unfair.

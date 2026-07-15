# Flagship Evolution Roadmap — Ten Controlled Updates

**Purpose:** evolve the working Two Second Witness baseline into a flagship observation experience through ten deliberate updates.
**Planning rule:** each update reveals another layer of depth; none is a random feature drop or justification for a rebuild.

---

# Roadmap operating model

Each update has three gates:

1. **Documentation gate:** goals, scope, architecture boundaries, content rules, and acceptance tests approved before development.
2. **Implementation gate:** only documented systems/content change; protected systems receive regression coverage.
3. **Experience/release gate:** device, accessibility, human-player, and quality evidence demonstrates the intended player reaction.

A later update cannot compensate for an earlier unproven core. Updates may be delayed, narrowed, or stopped by evidence.

---

# UPDATE 1 — Witness Moment Foundation

## Purpose / why it exists

Make Scene Investigation unmistakably the flagship loop rather than one catalog family among five. Establish a single first-session contract and a canonical Witness Moment that proves the product’s difference.

## Player experience impact

- **Player notices:** one clear invitation, ordinary scene, scene disappearance, one fair question, evidence returned.
- **Feels better:** less onboarding ambiguity, less mode-choice burden, more immediate understanding.
- **Wow moment:** “This is different—what I saw actually mattered, and it showed me why.”
- **Target reaction:** “This is different from normal puzzle games.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | Title/Privacy handoff, Tutorial host/family tutorial, Home entry semantics, Observation, Recall, Result. |
| Systems affected | ChallengeSessionService tutorial gating/first-session context, Recommendation/Program semantics, PlayerProgress first-moment record. |
| Data changes | Additive first-Witness-Moment/Brief configuration only; no parallel profile store. |
| Content changes | One intentionally authored/configured novice first Scene Investigation instance; first-session question/exposure/distractor rules. |
| Asset requirements | Reuse approved Scene Investigation art; only add assets if the first scene requires clear readable evidence. |

## Documentation required before development

- First Session Blueprint.
- Witness Moment Design Specification.
- One documented onboarding policy resolving title intro, family tutorial, practice, and completion state.
- First-moment content acceptance sheet.
- Updated route/state map and migration/no-data-loss statement.

## Implementation tasks

- Make first Scene Investigation selection explicit rather than incidental registry order.
- Consolidate first-session teaching into one witness contract plus normal practice flow.
- Establish canonical exposure progression: first scene 4s, follow-up 3s, mature standard 2s, comfort timing preserved.
- Ensure one factual question and normal runtime lifecycle.
- Make primary entry state honest: first moment, resume brief, or current brief.
- Record first witnessed moment through existing progress/save services.

## Testing requirements

- Full first-run runtime regression, tutorial behavior, privacy persistence, and no duplicate progress.
- Scene generator/validator tests for first-moment constraints.
- New-user moderated/unmoderated walkthroughs.
- Physical Android timing/touch/safe-area/text-size/accessibility verification.
- Save migration/recovery regression.

## Acceptance criteria

- New players reach a flagship scene quickly and understand the contract without coaching.
- No duplicate conceptual tutorial is shown.
- First miss is explainable and non-shaming.
- Players voluntarily choose a second Witness Moment in research.
- All launch paths remain through ChallengeSessionService.

## Release readiness

Internal/test release only until human/device evidence passes. No store-facing claim change yet.

## Out of scope

New families, expanded narrative, achievement redesign, full Home visual redesign, economy, social systems, cloud, story content.

---

# UPDATE 2 — Evidence Reveal Transformation

## Purpose / why it exists

Turn the existing result/reveal into the signature emotional reward. The player must leave each scene feeling they discovered truth, not that they received a score.

## Player experience impact

- **Player notices:** scene returns before annotation; exact evidence and factual explanation are unmistakable.
- **Feels better:** correct and missed answers both resolve with dignity and clarity.
- **Wow moment:** the target becomes visible in full context—“that was right in front of me.”
- **Target reaction:** “That was satisfying.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | ResultScreen, Observation-to-Recall boundary where needed, family reveal renderer presentation. |
| Systems affected | ResultService data consumption, family renderers, AudioService/Haptics, Accessibility/Theme. |
| Data changes | Additive reveal choreography/content fields only if current result data cannot represent context/evidence/explanation ordering. |
| Content changes | Per-question reveal target/evidence requirements; explanation copy templates. |
| Asset requirements | Evidence outline/trace states, accessible highlight variants, optional restrained audio cues. |

## Documentation required before development

- Evidence Reveal Master Specification.
- Per-question-type evidence matrix.
- Correct/missed copy policy.
- Reduced Motion/High Contrast/audio-off equivalence plan.
- Result hierarchy/continuation decision record.

## Implementation tasks

- Enforce context return → evidence focus → explanation → continuation information order.
- Ensure count, attribute, position, adjacency, presence, and container questions show appropriate evidence.
- Reduce score/achievement/program competition during initial reveal.
- Add restrained reveal sound/haptic choreography through existing AudioService/AccessibilityService.
- Preserve generic result contract and family-owned truth/scoring.

## Testing requirements

- Visual snapshot/contact-sheet review for every scene/question category.
- Unit/runtime checks that reveal target matches generated truth.
- Reduced Motion, High Contrast, text scale, audio mute, haptic-off tests.
- Human “fair miss” comprehension sessions.
- Physical phone visual/audio/haptic review.

## Acceptance criteria

- Players can point to the evidence after a miss.
- Correct players still understand/engage with reveal evidence.
- No result relies on color, animation, or sound alone.
- Primary next action appears only after truth is readable.

## Release readiness

Eligible for internal update messaging only after reveal behavior passes device/human validation.

## Out of scope

New scoring economy, partial-credit complexity, narrative Threads, generic reward particles, leaderboard.

---

# UPDATE 3 — Scene Quality Pipeline

## Purpose / why it exists

Establish a production-quality standard so every flagship scene is intentional, fair, visually legible, and replayable—not merely valid generator output.

## Player experience impact

- **Player notices:** ordinary environments feel composed, distinct, and worth studying.
- **Feels better:** fewer ambiguous details, more memorable evidence, consistent fair difficulty.
- **Wow moment:** repeated sessions continue to produce “I did not notice that” without feeling random.
- **Target reaction:** “Every scene feels intentional.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | Observation and Result scene stages; Library previews where content identity appears. |
| Systems affected | Scene generator/validator, difficulty/exposure policy, VisualStyleSystem, Content loading, test harness. |
| Data changes | Additive scene content metadata for zones, anchors, question eligibility, evidence geometry, art/review versions. |
| Content changes | Scene composition standards, template audit, question/distractor rules, first new content packs only when approved. |
| Asset requirements | Backgrounds, processed objects, evidence states, preview assets, source/pipeline records. |

## Documentation required before development

- Scene Creation and Content Quality Standard.
- Asset and Art Pipeline Plan.
- Per-template content review sheet and scene acceptance checklist.
- Difficulty-axis matrix and fairness policy.
- Creator/QA workflow and versioning decision.

## Implementation tasks

- Audit existing five scene worlds against anchor/zone/density/contrast/question rules.
- Add content validation only where current validator coverage is insufficient for documented quality rules.
- Define reviewed asset naming/version/import standards.
- Establish seed sampling/contact-sheet review process.
- Tune content before adding new worlds; preserve fallback/anti-repeat behavior.

## Testing requirements

- Large seed validation by tier/template.
- Visual review on target phone crops and safe areas.
- 20/50-round human replay/fatigue/fairness sessions.
- Texture/memory/render fallback tests.
- Content JSON/schema/link validation.

## Acceptance criteria

- Every production scene has documented visual, fairness, explanation, and replay review.
- Difficulty increases one principal burden axis at a time.
- No question relies on tiny text, color-only distinction, unfair crop, or ambiguous naming.
- Players can distinguish scene worlds and perceive normal variation.

## Release readiness

Content-quality release gate; do not market “endless” or “premium” scene replay until human evidence supports it.

## Out of scope

New family mechanics, full narrative story content, photoreal asset overhaul, live content endpoint.

---

# UPDATE 4 — Witness Brief System

## Purpose / why it exists

Create one clear returning ritual from existing recommendation/Program infrastructure: a finite moment worth noticing, not a menu of competing systems.

## Player experience impact

- **Player notices:** Home answers “what is here for me now?” with one honest proposition.
- **Feels better:** resume, fresh brief, and exploration are understandable rather than overlapping labels.
- **Wow moment:** the product feels personally current without becoming manipulative.
- **Target reaction:** “I want to come back.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | Home V2, Result continuation, Programs secondary surface, Profile current-record summary. |
| Systems affected | RecommendationService, ProgramService, ChallengeSessionService context, PlayerProgressService. |
| Data changes | Additive Brief identity/context/selection metadata using existing Program/progress store; no second task database. |
| Content changes | Brief definitions, focus/scene-family rules, voice/copy, finite-session configuration. |
| Asset requirements | Optional Brief identity art only after semantic clarity; no calendar/reward assets. |

## Documentation required before development

- Witness Brief and Return Ritual specification.
- Selection priority/state table.
- Daily/no-FOMO policy.
- Copy/tone policy and interruption/resume rules.
- Program simplification decision record.

## Implementation tasks

- Reconcile balanced Play Now, featured, Continue, and daily Program into one player-facing current-brief concept.
- Preserve unfinished brief resume and no missed-day penalty.
- Lead Brief with Scene Investigation; use companions only intentionally.
- Keep Library and Programs as secondary discovery, not competing first choices.
- Ensure selection respects accessibility, favorites, recent signatures, and locks.

## Testing requirements

- State-matrix tests: new, returning, unfinished, completed, date changes, favorite/no favorite, accessibility modes.
- Human comprehension test: “What is this brief and why this scene?”
- No notification/FOMO/streak-pressure audit.
- Local clock/weekend behavior test.

## Acceptance criteria

- Players can explain what the current Brief is and can stop/resume without anxiety.
- “Today” has a truthful defined meaning.
- Player-selected Library exploration remains available.
- No primary flow relies on punitive streaks or forced daily return.

## Release readiness

Eligible for a player-facing update once return behavior is tested and explanation/copy are approved.

## Out of scope

Push notification strategy, live ops calendar, new reward track, narrative thread delivery, social retention loops.

---

# UPDATE 5 — Witness Record Evolution

## Purpose / why it exists

Turn existing local history/mastery/profile data into a quiet personal archive of witnessed moments, without inventing currencies, badge walls, artificial rewards, or pressure.

## Player experience impact

- **Player notices:** the product remembers scenes and discoveries, not just scores.
- **Feels better:** progress has personal continuity and a calm reason to revisit.
- **Wow moment:** “This is my Witness history.”
- **Target reaction:** “I have my own Witness Record.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | Profile/Witness Record, Home compact record signal, Result post-reveal acknowledgement. |
| Systems affected | PlayerProgressService, ProfileService, AchievementService as optional background, Program summaries. |
| Data changes | Prefer derived views from existing history/mastery/favorites; additive metadata only where needed for moment identity. |
| Content changes | Record terminology, scene-world/familiarity descriptors, archive explanation rules. |
| Asset requirements | Quiet archive references/thumbnails/evidence crops only if they preserve performance/privacy. |

## Documentation required before development

- Witness Record and Return Ritual Spec.
- Progression hierarchy decision: current brief, familiarity, archive, optional recognition.
- No-currency/no-score/no-pressure policy.
- History privacy/storage retention review.

## Implementation tasks

- Reframe current Profile around moment history and scene familiarity.
- Keep levels/ranks/achievements/collections secondary and optional.
- Make result record acknowledgement light and post-evidence.
- Preserve local save migration and existing favorites/history/Program data.
- Define archive access without making it a required menu.

## Testing requirements

- Existing profile migration and atomic recovery tests.
- Long history performance/memory tests.
- Human interpretation study: what does record/mastery/rank mean?
- Accessibility/text scaling/archive readability review.

## Acceptance criteria

- Players describe record as personal history, not a score report.
- They understand at least one meaningful long-term signal.
- No player feels pressured by rank, achievement count, or missed day.
- Existing profile data remains intact across upgrade/recovery.

## Release readiness

Player-facing update only after migration, performance, and qualitative understanding pass.

## Out of scope

Inventories, currencies, loot, collectible economy, achievement overhaul, account/cloud requirements.

---

# UPDATE 6 — Premium Presentation Layer

## Purpose / why it exists

Make the validated flagship loop feel composed, tactile, and intentionally premium across launch, Brief, scene, reveal, record, and return.

## Player experience impact

- **Player notices:** coherent typography, atmosphere, motion, sound, and scene framing.
- **Feels better:** focus is protected; state changes feel meaningful rather than generic.
- **Wow moment:** the evidence reveal, sound settle, and scene stage feel unusually polished.
- **Target reaction:** “This feels premium.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | Publisher/Title, Home, Observation, Recall, Result, Witness Record, navigation transitions. |
| Systems affected | ThemeService, VisualStyleSystem, AudioService, AccessibilityService, ResponsiveLayout, AppShell. |
| Data changes | None by default; presentation profiles/assets may receive additive versioned references. |
| Content changes | Copy tone, evidence choreography, scene art direction, sound cue direction. |
| Asset requirements | Approved scene backgrounds/objects, reveal accents, BGM/cues, typography/font decision if needed. |

## Documentation required before development

- Motion, Audio, and Haptics Specification.
- Premium Presentation Guide.
- Asset/art pipeline acceptance standards.
- Accessibility equivalence and performance budget.

## Implementation tasks

- Apply information hierarchy: scene → evidence → explanation → record → continuation.
- Harmonize dark product frame and warm scene/evidence treatment.
- Refine launch/route transitions only where they communicate state.
- Tune sound/haptic layering through existing services.
- Preserve Reduced Motion/audio-off/high contrast equivalents.

## Testing requirements

- Device visual review at compact/standard/tall/tablet/foldable widths.
- Phone speaker/headphone audio review; mute/bus/haptic checks.
- Reduced Motion/High Contrast/text size/Color Assistance validation.
- Frame pacing, memory, texture, and transition benchmarks.

## Acceptance criteria

- Players describe the app as focused, calm, intentional, and fair.
- No decorative motion/sound obscures gameplay evidence.
- Premium presentation remains accessible and performant.

## Release readiness

A major player-facing polish update after physical-device acceptance and real captured storefront assets exist.

## Out of scope

Full engine replacement, custom Android activity, unrelated visual redesign, cinematic story sequences.

---

# UPDATE 7 — Content Expansion Framework

## Purpose / why it exists

Create scalable, repeatable production of new flagship scenes after the quality pipeline is proven. Expansion must deepen familiar ordinary worlds and observation grammar, not inflate mode count.

## Player experience impact

- **Player notices:** fresh scenes continue to feel authored and fair.
- **Feels better:** variety lasts without random-looking content.
- **Wow moment:** a new ordinary place/object relationship makes the player rethink how they scan.
- **Target reaction:** “There is always something new.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | Observation/Result primarily; Library previews and Record archive secondarily. |
| Systems affected | Family content loading, scene generator/validator, difficulty/exposure, VisualStyleSystem, content tests. |
| Data changes | Versioned content/template/asset metadata; no new player economy. |
| Content changes | New or deepened Scene Investigation templates/worlds only when a distinct observation grammar is documented. |
| Asset requirements | Backgrounds, object sets, evidence variants, previews, import/compression records. |

## Documentation required before development

- Scene Creation and Content Quality Standard.
- Asset and Art Pipeline Plan.
- Template proposal/acceptance contract.
- Content capacity/QA plan.

## Implementation tasks

- Establish creator workflow: concept → prototype → fairness review → production → seed/device validation.
- Expand existing five worlds before authorizing new categories unless research identifies a gap.
- Add content tags that support Brief variety/future archive only when useful.
- Keep new templates code-free where existing family contracts suffice.

## Testing requirements

- Content schema, missing-asset, asset-size/import, seeded-generation, validator, and fallback checks.
- Per-template 20/50-round qualitative replay study.
- Device texture/memory/performance validation.
- Review for question/distractor/reveal diversity.

## Acceptance criteria

- Every added scene has distinct observation grammar and standalone replay value.
- Content passes visual/fairness/evidence/replay review before catalog visibility.
- No content expansion reduces baseline scene quality or device performance.

## Release readiness

Ship content in curated, quality-reviewed releases; store messaging must show actual new scenes rather than generic “more puzzles.”

## Out of scope

Automatically generated unreviewed content, live remote content delivery, new family implementation, narrative campaigns.

---

# UPDATE 8 — Device and Performance Excellence

## Purpose / why it exists

Make the flagship feel reliable, immediate, and fair across real Android devices and accessibility conditions. “Premium” is not credible if a timed observation moment stutters, crops, or misreads a touch.

## Player experience impact

- **Player notices:** nothing breaks, clips, lags, or feels device-dependent.
- **Feels better:** timing/tapping/audio/record states feel trustworthy.
- **Wow moment:** absence of friction—“It feels perfect.”
- **Target reaction:** “It feels perfect.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | All, with focus on launch, Observation, Recall, Result, Home, Settings. |
| Systems affected | AppShell, ResponsiveLayout, Theme/Accessibility, Audio, Save, Android project/export, renderer/assets. |
| Data changes | None except test/performance evidence; no player feature required. |
| Content changes | Asset budget/remediation where scene content causes device pressure. |
| Asset requirements | Optimized imports, texture limits, audio stream checks, device-specific fallback verification. |

## Documentation required before development

- Device, Accessibility, and Validation Plan.
- Supported-device matrix and performance budget.
- Timing fairness and input latency measurement protocol.
- Signed-release/export validation checklist.

## Implementation tasks

- Validate/fix issues found on Android device matrix—not speculative rewrites.
- Measure launch, screen construction, challenge preparation, scene stable-frame, input acknowledgement, frame pacing, memory, save recovery, audio/haptics.
- Verify 60/90/120 Hz behavior, safe areas, gesture/three-button navigation, compact/tablet/foldable layouts.
- Reconcile current renderer/baseline test expectations with validated device configuration.

## Testing requirements

- Physical Android 12+ devices across low/mid/high hardware, 60/90/120 Hz where available.
- Compact/tall/notched/tablet/foldable display matrix.
- Full accessibility configuration matrix.
- Airplane mode, interruption/resume, cold/warm start, force-close/save recovery, signed AAB install/smoke.

## Acceptance criteria

- No critical/high defects, ANR, missing assets, input loss, or timing ambiguity.
- Observation duration and reveal remain fair/legible across supported displays.
- All accessibility settings preserve core information/normal progress.
- Signed artifact passes install, dependency, permission, size, and smoke review.

## Release readiness

Hard release gate for any flagship/store release.

## Out of scope

New product features, unsupported platform expansion, performance work unrelated to validated flagship paths.

---

# UPDATE 9 — Witness Threads Preparation

## Purpose / why it exists

Prepare a future connected-evidence option without turning the product into Story Mode or shipping narrative pressure before normal retention is proven.

## Player experience impact

- **Player notices:** initially, nothing new should interrupt normal play.
- **Feels better:** future content can eventually reveal quiet depth without changing the core loop.
- **Wow moment:** future conditional prototype target: “There is something deeper here.”
- **Target reaction:** “There is something deeper here.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | None player-facing by default; future archive/reveal capability only after approval. |
| Systems affected | Content metadata, scene truth/evidence references, Witness Record archive capability. |
| Data changes | Additive, versioned content relationship metadata only when authorized; preserve one Profile/Save store. |
| Content changes | Authoring standards for a small number of recurring material details across standalone scenes. |
| Asset requirements | Recurring object/motif variants and evidence references, never story UI assets. |

## Documentation required before development

- Witness Threads Concept.
- Connected Witness Moment Structure.
- Witness Record and Evidence Reveal evolution rules.
- Narrative Content Authoring Guide.
- Implementation Boundaries and no-story-mode decision record.

## Implementation tasks

- Do not implement full narrative layer in this update.
- Prepare only approved additive content metadata/relationship capability if Phase 2 retention gate has passed.
- Preserve independent scene questions, scoring, reveal, and selection priority.
- Ensure no thread count, campaign state, completion UI, notification, or narrative route is created.

## Testing requirements

- Content review verifies thread details never affect standalone fairness.
- Archive/reveal capability tests remain opt-in and invisible until eligible.
- Human concept test confirms “connection” reads as discovery, not task/plot.
- Privacy/storage/accessibility regression review.

## Acceptance criteria

- No player-facing campaign, chapter, quest, or progress system exists.
- Any metadata is content/Game-layer, additive, versioned, and does not add a parallel runtime/profile store.
- Flagship retention remains the priority and passes prior gates.

## Release readiness

No standalone marketing or release claim. This is preparation/prototype readiness only.

## Out of scope

Story Mode, named characters, Cases as UI, narrative menu, chapter order, completion bar, FOMO, rewards, notifications.

---

# UPDATE 10 — Flagship Completion Release

## Purpose / why it exists

Define the arrival release: the product now consistently expresses its intended identity from store page through first scene, evidence reveal, return ritual, record, content quality, device performance, and future-depth readiness.

## Player experience impact

- **Player notices:** one coherent premium observation experience rather than a collection of systems.
- **Feels better:** first session is clear; return is meaningful; scenes/reveals are trustworthy; record feels personal.
- **Wow moment:** the product’s depth is felt through repeated moments, not feature quantity.
- **Target reaction:** “This has become something special.”

## Technical scope

| Area | Scope |
|---|---|
| Screens affected | End-to-end launch, Brief/Home, Observation, Recall, Result, Record, Library/Settings secondary surfaces. |
| Systems affected | All protected systems, validated through integrated release matrix. |
| Data changes | Only completed additive/migrated changes from Updates 1–9; no late parallel systems. |
| Content changes | Curated flagship scene catalog meeting quality standard. |
| Asset requirements | Final real-product icon/store graphics/screenshots/video/audio and approved content assets. |

## Documentation required before development/release

- Final target/roadmap completion review.
- Current state docs/screenshots/test baselines updated to actual release behavior.
- Store Evolution Plan and final metadata/legal/Data Safety artifacts.
- Release checklist, rollback/staged rollout plan, support ownership.

## Implementation tasks

- Resolve only launch-blocking/premium-quality defects found in final validation.
- Freeze architecture and content version for signed release.
- Produce signed AAB, real device captures, dependency report, checksums, release notes.
- Reintroduce existing users through a respectful, optional “what has evolved” message tied to the current Brief—not a forced tour.

## Testing requirements

- First-session quality study and returning-user study.
- 20/50-round flagship replay/fairness evidence.
- Full Android/device/accessibility/performance/save/offline matrix.
- Signed artifact/store/legal validation.
- Store listing/screenshot claim review against actual runtime.

## Acceptance criteria

See **Final Flagship Completion Definition** in the Risk and Scope Control document. All hard gates must pass.

## Release readiness

Production release candidate only after all acceptance evidence, publisher/legal signoff, store review, and rollback plan are complete.

## Out of scope

Late feature additions, new families, social systems, economy, cloud accounts, narrative campaign, unvalidated experiments.

---

# Roadmap rule

> The product should evolve the same way its scenes work: the depth was already there. Each update reveals another layer.

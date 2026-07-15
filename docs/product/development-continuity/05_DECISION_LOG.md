# Permanent Decision Log

**Purpose:** preserve product and technical decisions so superseded ideas do not silently return in later sessions.
**Update rule:** add a dated entry whenever a decision changes scope, architecture, player experience, validation gate, or release claim.

---

# Decision entry format

| ID | Date | Decision | Reason | Alternatives considered | Impact | Status |
|---|---|---|---|---|---|---|

**Status values:** Active, Superseded, Needs Validation, Deferred, Rejected.

---

# Active decisions

| ID | Date | Decision | Reason | Alternatives considered | Impact | Status |
|---|---|---|---|---|---|---|
| PD-001 | 2026-07-15 | Two Second Witness is a premium offline observation experience, not a brain-training/assessment product. | Product identity must create curiosity/discovery without judgment or unsupported claims. | Cognitive training, memory test, diagnostic positioning. | All player copy, progression, store claims, onboarding, and feature proposals must avoid assessment language/claims. | Active |
| PD-002 | 2026-07-15 | Scene Investigation is the working flagship, expressed as the Witness Moment. | It best matches title, ordinary-scene witness fantasy, unknown-question attention, and evidence-first reveal. | Spot the Difference as flagship; equal-family anthology. | First session, Brief, store story, content standards, and reveal quality center Scene Investigation. Must be validated against player research. | Needs Validation |
| PD-003 | 2026-07-15 | Evidence reveal is the primary emotional reward. | Fair context/evidence/explanation is the strongest differentiator and turns misses into discovery. | Score/XP, achievements, speed bonus, reward spectacle. | Result hierarchy is scene context → evidence → explanation → recognition → continuation. | Active |
| PD-004 | 2026-07-15 | The product’s central loop is Scene Investigation → Observation → Recall → Evidence Reveal → Witness Record. | Gives all product systems one purpose and prevents mini-game/dashboard drift. | Family catalog as core loop; Programs/achievements as core. | New work must strengthen this loop or be deferred. | Active |
| PD-005 | 2026-07-15 | “Two seconds” is signature standard timing, not a universal rule overriding fairness. | Current exposure already varies; novice and accessibility timing require fairness. | Literal fixed 2s for all scenes; unrestricted timing. | First scene 4s, follow-up 3s, standard 2s direction; Comfortable Timing remains equivalent. | Active |
| PD-006 | 2026-07-15 | Witness Brief is the intended return ritual. | Returning player needs one meaningful current proposition, not overlapping Play Now/featured/daily/Program semantics. | Dashboard-first Home, streak-first return, generic task list. | Reuse Recommendation/Program/runtime infrastructure; no FOMO/daily penalty. | Needs Validation |
| PD-007 | 2026-07-15 | Witness Record is private archive/familiarity, not currency/badges/artificial progression. | Long-term attachment should come from remembered moments, not grind or judgment. | Economy, loot, achievement wall, competitive ranks. | Profile/progress evolves through existing PlayerProgress/Profile/Save systems; metrics remain secondary. | Active |
| PD-008 | 2026-07-15 | Current app architecture is a protected baseline; no full rebuild. | Runtime, contracts, saves, shell, accessibility, and content systems are valuable and already support controlled evolution. | Rewrite engine/UI/runtime; parallel app architecture. | Changes must be compatible, scoped, documented, and regression-tested. | Active |
| PD-009 | 2026-07-15 | ChallengeSessionService remains the only player-facing challenge lifecycle authority. | Ensures tutorials, generation, results, progress, recommendations, and return behavior stay coherent. | Direct route launches; alternate Brief/story launch path. | All Home/Library/Program/future Brief launches must use runtime service. | Active |
| PD-010 | 2026-07-15 | Shared runtime, navigation, Home, Programs, profile, persistence, accessibility, and interaction adapters remain family-agnostic. | Family modules own mechanics/scoring/rendering; shared branches would create long-term drift. | Family-ID conditionals in shared systems. | Architecture review required for any exception. | Active |
| PD-011 | 2026-07-15 | No new Challenge Types before flagship scene quality, replay, and retention evidence. | Existing five families/20 templates are enough to learn what players value. | Implement seven planned families immediately. | Content/family expansion deferred behind Update 3/7 and player evidence. | Active |
| PD-012 | 2026-07-15 | Witness Threads are future connected evidence, not Story Mode. | Retrospective curiosity can deepen observation only if the normal Witness Moment already retains players. | Campaign, chapters, cases, characters, quests, story menus. | Document now; prototype one bounded thread only after retention/device gates; no narrative UI now. | Deferred |
| PD-013 | 2026-07-15 | Threads cannot create obligation, FOMO, progress bars, score gates, or missed-detail punishment. | The desired feeling is “what have I already seen?” not “finish story.” | Daily narrative cadence, thread completion reward, locked scenes. | Future metadata/content must be additive, standalone, optional, and below fairness/freshness selection priority. | Active |
| PD-014 | 2026-07-15 | Offline/no-account/local save posture is a product strength. | Supports calm premium trust and current privacy commitments. | Accounts, cloud, remote live content, telemetry-first design. | Any change requires explicit strategy, privacy/legal review, migration, and release justification. | Active |
| PD-015 | 2026-07-15 | Accessibility is part of fairness and release quality. | Timed visual game cannot treat comfort modes as secondary. | Default-only optimization, accessibility after polish. | Every update needs Reduced Motion, High Contrast, text, timing, audio/haptic, input/device validation. | Active |
| PD-016 | 2026-07-15 | Store/trailer claims must match real signed runtime behavior. | Current cinematic material can overpromise story/thriller identity. | Trailer-first/product-later messaging, mock screenshots. | Store evolution waits for actual device captures and validated flagship behavior. | Active |
| PD-017 | 2026-07-15 | “Witness Engine,” “Iris Engine,” “Content Registry,” and “Sampling Controller” are planning terms mapped to existing systems unless proven otherwise. | No verified exact source systems exist for all requested labels. | Creating new systems to match names. | Preserve actual runtime/registry/recommendation/presentation equivalents; do not invent architecture by terminology. | Active |
| PD-018 | 2026-07-15 | Current active development status is Update 1 planning; no implementation has begun. | Master plan is complete but requires scoped implementation plan and validation before code changes. | Starting Update 2/polish/content/Threads immediately. | Next session must inspect first-session path and propose exact Update 1 scope first. | Active |

---

# Superseded or rejected ideas

| ID | Date | Decision | Reason | Status |
|---|---|---|---|---|
| RJ-001 | 2026-07-15 | Do not treat all five Challenge Types as equal first-session identity. | Equal catalog prominence obscures Scene Investigation flagship hypothesis. | Rejected as current default direction |
| RJ-002 | 2026-07-15 | Do not use punitive daily streaks as the return mechanism. | Return should be curiosity/Brief-driven, not loss aversion. | Rejected |
| RJ-003 | 2026-07-15 | Do not add currencies, loot, shops, energy, battle pass, or reward economy. | They distract from evidence reveal and private observation identity. | Rejected |
| RJ-004 | 2026-07-15 | Do not add leaderboards/social competition now. | Alters calm/private/fairness contract without evidence of player need. | Rejected |
| RJ-005 | 2026-07-15 | Do not build Story Mode, campaigns, chapters, named characters, quests, or narrative completion. | Witness Threads must remain emergent, optional, and retrospective. | Rejected |
| RJ-006 | 2026-07-15 | Do not rebuild boot/navigation/runtime/profile/content architecture for flagship work. | Existing baseline supports controlled evolution; rewrite is unjustified risk. | Rejected |

---

# How to add a decision

Before adding an entry, confirm:

1. Is it a real decision, not a temporary implementation detail?
2. What evidence supports it?
3. Which alternatives were consciously rejected or deferred?
4. Which master-plan/update docs, systems, tests, and player claims are affected?
5. Does it require an architecture log entry, migration note, or tracker status change?

Never silently overwrite an old decision. Mark it Superseded and add a new entry with the reason.

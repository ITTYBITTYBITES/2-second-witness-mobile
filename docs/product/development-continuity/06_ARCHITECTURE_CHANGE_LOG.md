# Architecture Change Log

**Purpose:** record every approved system/architecture change so compatible evolution remains traceable and no agent accidentally replaces working foundations.
**Update rule:** add an entry whenever a system boundary, service API, persistence schema, route lifecycle, content contract, or Android/export behavior changes.

---

# Entry format

| ID | Date | Status | System change | Why | Affected files | Migration / compatibility notes | Validation |
|---|---|---|---|---|---|---|---|

**Status values:** Baseline, Planned, Implemented, Validated, Superseded, Rejected.

---

# Protected architecture baseline

| ID | Date | Status | System change | Why | Affected files | Migration / compatibility notes | Validation |
|---|---|---|---|---|---|---|---|
| ARCH-BASE-001 | 2026-07-15 | Baseline | Foundation boot/shell/navigation/save/settings/theme/accessibility/audio/analytics/content services accepted as protected baseline. | Existing product depends on stable app lifecycle, local trust, and Android behavior. | `app/src/core/`, `app/src/systems/`, `app/project.godot`, `app/export_presets.cfg` | Compatible fixes only; no parallel service implementations. | Historical project/import/runtime documentation; current device gate still open. |
| ARCH-BASE-002 | 2026-07-15 | Baseline | Challenge Family/Template/Instance contracts and ChallengeSessionService lifecycle accepted as protected baseline. | Provides generic generation, validation, presentation, result, progress, and recommendation path. | `app/src/gameplay/contracts/`, `app/src/gameplay/runtime/` | All player launches stay through ChallengeSessionService; no family IDs in shared runtime. | Architecture tests/documentation; re-run full suite before feature release. |
| ARCH-BASE-003 | 2026-07-15 | Baseline | Family-owned generator/validator/policy/scoring/tutorial/renderer boundary accepted. | Keeps mechanics/content extensible without shared system drift. | `app/src/gameplay/families/`, interactions/presentation contracts. | New family/content must add Game/Content modules; shared changes require explicit justification. | Existing phase architecture checks. |
| ARCH-BASE-004 | 2026-07-15 | Baseline | ProfileService/SaveService/PlayerProgressService remain single persistence/progression path. | Local record, atomic recovery, migration, favorites/history/program state already live. | `app/src/systems/save/`, `app/src/gameplay/runtime/PlayerProgressService.gd` | Additive schema/migration only; no second Witness Record/thread database. | Save/recovery/migration tests required for changes. |
| ARCH-BASE-005 | 2026-07-15 | Baseline | RecommendationService/ProgramService remain selection layer over runtime. | Supports start/continue/daily/catalog/program contexts without alternate gameplay flow. | `RecommendationService.gd`, `ProgramService.gd`, `ChallengeSessionService.gd` | Witness Brief must reuse/clarify these systems, not create a separate launcher/controller. | State matrix and runtime launch tests required. |
| ARCH-BASE-006 | 2026-07-15 | Baseline | AppShell/ResponsiveLayout/Theme/Accessibility/Audio remain presentation infrastructure. | Safe-area, device, motion, text, contrast, sound, haptic quality are core fairness. | `app/src/ui/`, Theme/Accessibility/Audio services. | New polish must respect settings and transient-screen lifecycle. | Device/accessibility review required. |

---

# Planned architecture changes

| ID | Date | Status | System change | Why | Affected files | Migration / compatibility notes | Validation |
|---|---|---|---|---|---|---|---|
| ARCH-PLAN-001 | 2026-07-15 | Planned | Explicit first Witness Moment configuration within existing Scene Investigation/content/runtime path. | Current first family/template selection is implicit; flagship requires deliberate first scene. | Exact files TBD after Update 1 repository inspection; likely Scene Investigation family/content, title/tutorial/session tests. | Must not bypass ChallengeSessionService or add second onboarding store. | Update 1 first-run/runtime/device/human tests. |
| ARCH-PLAN-002 | 2026-07-15 | Planned | Evidence reveal presentation hierarchy evolution using existing Result contracts and family renderer data. | Reveal must become signature emotional reward. | Exact files TBD after Update 1/2 scope; likely ResultScreen, Scene renderer, result tests, audio/accessibility wiring. | Preserve canonical result schema/family scoring; additive reveal data only if needed. | Truth/evidence, visual, accessibility, device, human fairness tests. |
| ARCH-PLAN-003 | 2026-07-15 | Planned | Witness Brief semantic consolidation over RecommendationService/ProgramService. | One truthful current/continue/fresh state is needed. | Exact files TBD after Update 4 scope. | Reuse existing profile/program state; no parallel recommendation engine. | State matrix, runtime launch, no-FOMO/user comprehension tests. |
| ARCH-PLAN-004 | 2026-07-15 | Planned | Witness Record presentation evolution over existing PlayerProgress/Profile history. | Personal archive should be meaningful without second persistence system. | Exact files TBD after Update 5 scope. | Additive data only when existing history cannot represent required moment identity; migration mandatory. | Save migration/recovery, performance, accessibility, human interpretation tests. |
| ARCH-PLAN-005 | 2026-07-15 | Deferred | Optional future Witness Thread content metadata/archive relationship support. | May enable retrospective connected evidence after flagship retention proof. | Exact files TBD only after Update 9 gate. | Content/Game metadata only; no Story Mode route, thread store, campaign state, or shared family branch. | One bounded prototype plus content/fairness/privacy/accessibility research. |

---

# Implemented changes during continuity system initialization

| ID | Date | Status | System change | Why | Affected files | Migration / compatibility notes | Validation |
|---|---|---|---|---|---|---|---|
| ARCH-DOC-001 | 2026-07-15 | Implemented | Added repository-resident development continuity layer. | Preserve product/architecture intent across AI sessions; no application architecture change. | `docs/product/development-continuity/*.md` | Documentation only; no runtime, data, route, save, or export change. | Package structure/checklist/diff validation. |

---

# Change-control rules for future entries

Before modifying architecture:

1. Identify the protected baseline entry affected.
2. Document the user/product benefit; “cleaner code” alone is insufficient for a rewrite.
3. List exact files and public APIs/contracts affected.
4. State save/profile/content migration and backward-compatibility behavior.
5. State how navigation, accessibility, audio, analytics, and error recovery remain compatible.
6. Add/update tests before or with implementation.
7. Run required runtime/device validation and record actual results.
8. Update `02_CURRENT_IMPLEMENTATION_STATE.md`, `05_DECISION_LOG.md`, `07_UPDATE_PROGRESS_TRACKER.md`, and relevant master-plan docs.

If a proposed change creates a parallel runtime, profile store, recommendation controller, content registry, or family-specific shared code, stop and seek explicit architecture approval.

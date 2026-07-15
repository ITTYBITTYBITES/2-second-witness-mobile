# Two Second Witness — Project Context Bootstrap

**Use this document first in every new development conversation.**
**Purpose:** restore product intent, technical boundaries, and current work state before implementation begins.

---

# 1. Product identity

## What Two Second Witness is

Two Second Witness is a premium, offline observation experience built around the **Witness Moment**:

```text
Scene Investigation → Observation → Recall → Evidence Reveal → Witness Record
```

The player studies an ordinary scene before it disappears, makes one honest call about what mattered, then sees the evidence return in context.

**Core promise:**

> “This was always there. You just didn’t notice it.”

The desired player response is:

- “How did I miss that?”
- “That was right in front of me.”
- “I want to see another one.”

## What it is not

- Not a cognitive assessment, diagnostic, IQ product, or brain-training claim.
- Not a generic mini-game anthology, despite having companion Challenge Types.
- Not a traditional detective story, Story Mode, campaign, chapter system, or character-driven fictional world.
- Not a leaderboard, economy, currency, loot, task, streak-pressure, or social obligation product.
- Not a feature checklist whose value comes from having more systems.

## Core experience principles

1. **A moment before a menu.** The player should enter a meaningful Witness Moment quickly.
2. **Fairness is visible.** The reveal proves the truth in scene context; a miss is discovery, not failure.
3. **Scene Investigation leads.** It is the flagship Witness Moment; other families are companion variations until research proves their roles.
4. **Private mastery, not judgment.** Progress is a personal Witness Record of in-game familiarity, not an external claim about ability.
5. **A calm return ritual.** A Witness Brief is finite, optional, fresh, and free from FOMO.
6. **Accessibility is fairness.** Timing, contrast, motion, text, audio, haptics, and input alternatives must preserve equivalent meaning.
7. **Controlled evolution.** The working app is valuable baseline infrastructure; do not rewrite it to make planning feel simpler.

---

# 2. Current flagship goal

## Current evolution phase

**Pre-implementation / Flagship Evolution Master Plan complete.**

The planning source of truth is:

`docs/product/flagship-master-plan/`

## Active update

**Update 1 — Witness Moment Foundation**

**Status:** Planning complete; implementation is not yet authorized by product validation gates.

## Current objective

Make the first Scene Investigation Witness Moment unmistakably clear and fair:

- one intentional first-session path;
- one explicit novice-friendly first scene rather than manifest-order accident;
- one concise witness contract;
- 4s → 3s → signature 2s timing progression without accessibility penalty;
- one clear recall question;
- one evidence-first result;
- one truthful primary continuation.

## Next milestone

Before code changes for Update 1:

1. Read the flagship master plan and continuity documents.
2. Inspect current runtime/tutorial/scene/result paths.
3. Produce a narrowly scoped Update 1 implementation plan identifying exact files, tests, risks, and migration implications.
4. Confirm that first-session behavior is currently understood and that no protected architecture is being bypassed.

Do not begin Update 2, new scene worlds, Witness Threads, or broad UI redesign while Update 1 is unproven.

---

# 3. Protected decisions

These decisions are active unless a new documented product decision explicitly supersedes them.

- **No full rebuild.** Evolve working systems through compatible changes.
- **Witness Moment is priority.** Scene Investigation first-session/reveal quality outranks catalog breadth.
- **Evidence reveal is the emotional reward.** Score, rank, achievements, and Program state are secondary.
- **No unnecessary mechanics.** Do not add currencies, loot, economy, social systems, leaderboards, accounts, AI scoring, or unrelated features.
- **No narrative campaigns.** Witness Threads are documentation-only future preparation; no Story Mode, chapters, cases UI, quests, characters, or completion bars.
- **No premature expansion.** Do not add Challenge Types or content worlds before current scene quality/replay evidence supports it.
- **No second player data store.** Witness Record/Brief/Threads must use compatible existing Profile/Save/PlayerProgress paths.
- **No family-specific shared-runtime branches.** Families own mechanics/scoring/rendering; shared systems remain generic.
- **No default-setting-only quality.** Reduced Motion, High Contrast, text scaling, timing comfort, muted audio, haptics-off, and assistive paths are release requirements.
- **No store claims ahead of runtime proof.** Marketing must represent the actual signed build.

---

# 4. Architecture summary

## Foundation

| Responsibility | Primary systems/files |
|---|---|
| Boot | `app/src/core/app/AppBoot.gd`, `AppState.gd` |
| Navigation/shell | `app/src/core/navigation/NavigationService.gd`, `AppRoutes.gd`, `app/src/ui/shell/AppShell.gd` |
| Save/profile | `app/src/systems/save/SaveService.gd`, `ProfileService.gd` |
| Settings/accessibility/theme | `SettingsService.gd`, `AccessibilityService.gd`, `ThemeService.gd` |
| Audio | `app/src/systems/audio/AudioService.gd` |
| Error/events | `ErrorHandler.gd`, `EventBus.gd` |
| Android/project | `app/project.godot`, `app/export_presets.cfg` |

## Witness runtime

| Responsibility | Primary systems/files |
|---|---|
| Lifecycle authority | `app/src/gameplay/runtime/ChallengeSessionService.gd` |
| Family discovery | `ChallengeFamilyRegistry.gd`, `families/manifest.json` |
| Contracts | `app/src/gameplay/contracts/` |
| Generation/validation/policies | `app/src/gameplay/runtime/` interfaces plus family modules |
| Results/progress | `ResultService.gd`, `PlayerProgressService.gd` |
| Recommendations/Programs | `RecommendationService.gd`, `programs/ProgramService.gd` |
| Interactions | `app/src/gameplay/interactions/` |

## Flagship family

| Responsibility | Primary files |
|---|---|
| Scene Investigation family | `app/src/gameplay/families/scene_investigation/SceneInvestigationFamily.gd` |
| Scene generation/validation | `SceneInvestigationGenerator.gd`, `SceneInvestigationValidator.gd` |
| Timing/difficulty/scoring | corresponding policy/scoring files in family directory |
| Scene rendering | `SceneInvestigationSceneView.gd` |
| Family tutorial | `tutorial/SceneInvestigationTutorial.*` |
| Scene content | `content/*.json` under scene-investigation |
| Visual assets | `app/assets/gameplay/scene_investigation/`, `app/assets/gameplay/sprites/` |

## Product surfaces

- First-launch/title: `PublisherSplashScreen`, `TitleSplashScreen`, `PrivacyTermsDialog`, `TutorialScreen`.
- Current Home: `app/src/ui/screens/HomeV2Screen.*`.
- Gameplay: `ObservationChallengeScreen`, `MemoryQuestionScreen`, `ResultScreen`.
- Discovery/record: `ExperiencesScreen`, `ProgramsScreen`, `ProfileScreen`, `AchievementsScreen`.
- Settings/legal: `SettingsScreen`, `AboutScreen`.

## Terminology mapping

The requested/product terms below are concepts, not necessarily literal source singleton names:

| Planning term | Actual source equivalent |
|---|---|
| Witness Engine | ChallengeSessionService + contracts + family modules + Result/PlayerProgress services. |
| Iris Engine | No exact source system; presentation concept spanning witness eye motif, Scene renderer, VisualStyleSystem, ThemeService. |
| Content Registry | Active: ChallengeFamilyRegistry/family content. Legacy: ContentService/ExperienceRegistry. |
| Sampling Controller | RecommendationService + ProgramService + difficulty/exposure + recent-signature policies. |

Never create new systems just to make these planning labels literal.

---

# 5. Current known state

## Completed work

- Product reconstruction/discovery reports.
- Core product direction: Witness Moment, Scene Investigation flagship, fair reveal, Brief/Record direction.
- Flagship Experience Reconstruction package.
- Witness Threads future concept/boundaries package.
- 10-update Flagship Evolution Master Plan.
- Existing code baseline: five production families, 20 templates, Programs, local progression, accessibility, audio, offline saves, Android/export preparation.

## Active work

- Development continuity system initialization.
- Update 1 planning/readiness only.

## Pending work

- Narrow Update 1 implementation plan.
- Current first-session route/runtime inspection before implementation.
- Evidence Reveal transformation specification implementation after Update 1 gate.
- Human first-session, 20/50-round, physical Android, accessibility, save-upgrade, and signed-artifact validation.
- Test baseline/documentation reconciliation after prior Home/mobile/visual changes.

## Blocked work

- Update 2+ implementation is blocked by Update 1 clarity/validation.
- New scene worlds/content expansion is blocked by Scene Quality Pipeline standards and replay evidence.
- Witness Threads implementation is blocked by flagship retention/device gates.
- Store flagship claims/release are blocked by physical device, signed artifact, legal/store, and human-play gates.

---

# 6. Project Command Center and Intelligence

The repository uses an internal management system to maintain continuity:

- **PROJECT_COMMAND_CENTER.md:** The primary human-readable dashboard at the root. Start here.
- **.github/project-state.yml:** Machine-readable state for automation and AI tracking.
- **docs/product/development-continuity/START_NEXT_SESSION.md:** Use this to generate the prompt for new AI sessions.
- **docs/product/development-continuity/HUMAN_PROJECT_WORKFLOW.md:** The official workflow for project owners.

# 7. Required reading order for a new agent

1. **PROJECT_COMMAND_CENTER.md** (at root).
2. This bootstrap document.
3. `02_CURRENT_IMPLEMENTATION_STATE.md`.

3. `07_UPDATE_PROGRESS_TRACKER.md`.
4. `05_DECISION_LOG.md` and `09_CHANGE_CONTROL_RULES.md`.
5. Current update section in `../flagship-master-plan/03_FLAGSHIP_EVOLUTION_ROADMAP.md`.
6. Current update’s detailed specifications in the master plan.
7. `08_REPO_ANALYSIS_CHECKLIST.md` before touching code.

Do not implement until the current milestone, scope, protected decisions, and next recommended action are confirmed.

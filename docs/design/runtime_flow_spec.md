# Runtime Flow Specification

**Phase:** 4 | **Status:** Additive documentation (behavior mapping) | **Date:** 2026-07-05

## 1. Primary Navigation Graph
LandingScreen -> WeeklyFeaturedScreen -> WorldSelectScreen -> ScenarioLoad/GameplayHUD -> (cascade complete) -> next scenario or Mirror -> WorldSelectScreen (back)

## 2. Transition Entry Paths (one per transition)
| Transition | Entry path | Systems |
|---|---|---|
| Boot -> Landing | BootLoader -> NavigationRouter.show_landing_screen() | BootLoader, Router, Kernel |
| Landing -> Weekly | PLAY tap -> InteractionKernel -> Router._on_play_requested() | Kernel, Router |
| Universe -> WorldSelect | Orchestrator.request_universe_selection() -> Router | Orchestrator, Router |
| World -> Scenario | Orchestrator -> Router._on_world_selected() -> ScenarioEngine | Orchestrator, Router, ScenarioEngine |
| Cascade complete | Router._on_cascade_completed() | Router, Profile, Narrator |
| Mirror (HUD) | ModalWindowManager.push_modal() | Modal (orthogonal graph) |

## 3. Validation Results
- 3a. Each transition has ONE entry path: CONFIRMED
- 3b. No orphan navigation calls: CONFIRMED
- 3c. No direct scene bypassing Router: CONFIRMED (zero change_scene outside Router/Engine)
- 3d. Modal cannot interrupt navigation: CONFIRMED (orthogonal graph)

## 4. Control-Plane Flow
Input -> InteractionKernel.consume_provenance() -> commit_intent() -> ExperienceOrchestrator -> NavigationRouter -> NavigationEngine -> ModalWindowManager

## 5. Findings
- No violations found. Runtime flow clean.
- NavigationRouter <-> NavigationEngine boundary implicit (formalized in contracts but not code-enforced).
- ExperienceOrchestrator is valid intermediary, not bypass.

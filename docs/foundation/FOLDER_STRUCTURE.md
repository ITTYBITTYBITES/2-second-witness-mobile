# Repository Structure

This structure reflects the validated Foundation and locally complete Phase 5 five-family platform.

```text
2-second-witness-mobile/
├── README.md
├── PRIVACY.md
├── app/
│   ├── project.godot
│   ├── export_presets.cfg
│   ├── android/plugins/
│   ├── assets/
│   │   ├── audio/
│   │   │   ├── ui_click.wav
│   │   │   ├── observation_start.wav
│   │   │   ├── conceal.wav
│   │   │   ├── reveal_correct.wav
│   │   │   └── reveal_incorrect.wav
│   │   ├── backgrounds/
│   │   ├── brand/
│   │   ├── gameplay/
│   │   │   ├── scene_investigation/ (three premium backgrounds)
│   │   │   └── flash_words/flash_words_preview.svg
│   │   └── splash/
│   ├── src/
│   │   ├── core/
│   │   ├── systems/
│   │   ├── ui/
│   │   │   └── layout/ResponsiveLayout.gd
│   │   ├── gameplay/
│   │   │   ├── contracts/
│   │   │   │   ├── ChallengeFamily.gd
│   │   │   │   ├── ChallengeTemplate.gd
│   │   │   │   ├── ChallengeInstance.gd
│   │   │   │   ├── PresentationProfile.gd
│   │   │   │   ├── TutorialProfile.gd
│   │   │   │   ├── InteractionProfile.gd
│   │   │   │   ├── ChallengeValidationResult.gd
│   │   │   │   └── ChallengeResult.gd
│   │   │   ├── runtime/
│   │   │   │   ├── ChallengeSessionService.gd
│   │   │   │   ├── ChallengeFamilyRegistry.gd
│   │   │   │   ├── ChallengeFamilyModule.gd
│   │   │   │   ├── ChallengeGenerator.gd
│   │   │   │   ├── ChallengeValidator.gd
│   │   │   │   ├── DifficultyPolicy.gd
│   │   │   │   ├── ExposurePolicy.gd
│   │   │   │   ├── ScoringPolicy.gd
│   │   │   │   ├── ResultService.gd
│   │   │   │   ├── PlayerProgressService.gd
│   │   │   │   └── RecommendationService.gd
│   │   │   ├── interactions/
│   │   │   │   ├── InteractionAdapter.gd
│   │   │   │   ├── InteractionAdapterRegistry.gd
│   │   │   │   ├── manifest.json
│   │   │   │   └── adapters/ (six generic collectors)
│   │   │   ├── families/
│   │   │   │   ├── manifest.json
│   │   │   │   ├── scene_investigation/
│   │   │   │   ├── flash_words/
│   │   │   │   ├── spot_the_difference/
│   │   │   │   ├── object_recall/
│   │   │   │   └── pattern_recall/
│   │   │   │       └── each owns family, templates, generator, validator, policies, renderer, tutorial
│   │   │   ├── progression/
│   │   │   │   ├── AchievementService.gd
│   │   │   │   └── achievements.json
│   │   │   ├── programs/
│   │   │   │   ├── ProgramService.gd
│   │   │   │   └── programs.json
│   │   │   ├── ChallengeRegistry.gd
│   │   │   ├── challenges.json
│   │   │   └── REGRESSION_FIXTURES.md
│   │   └── experiences/
│   │       └── dormant Foundation-era module scaffolding
│   └── tests/runtime/
│       ├── fixtures/
│       ├── test_challenge_runtime_gate1.gd
│       ├── test_first_run_runtime_regression.gd
│       ├── test_fixture_generation_and_validation.gd
│       ├── test_runtime_type_agnostic.gd
│       ├── test_family_tutorial_architecture.gd
│       ├── test_scene_investigation_production_flow.gd
│       ├── test_scene_investigation_tutorial.gd
│       ├── test_scene_investigation_scoring.gd
│       ├── test_scene_investigation_difficulty.gd
│       ├── test_scene_investigation_session_variety.gd
│       ├── test_scene_investigation_stress.gd
│       ├── test_flash_words_production_flow.gd
│       ├── test_flash_words_tutorial.gd
│       ├── test_flash_words_policies.gd
│       ├── test_flash_words_session_variety.gd
│       ├── test_flash_words_seed_reproducibility.gd
│       ├── test_flash_words_stress.gd
│       ├── test_phase3_home_experience.gd
│       ├── test_phase35_production_polish.gd
│       ├── test_phase4_product_experience.gd
│       ├── test_phase5_interaction_system.gd
│       ├── test_phase5_challenge_types.gd
│       ├── test_phase5_tutorials.gd
│       ├── test_phase5_reproducibility_variety.gd
│       ├── test_phase5_stress.gd
│       ├── verify_phase5_architecture.py
│       ├── verify_phase5_content.py
│       ├── verify_phase5_interaction_baseline.py
│       ├── verify_phase4_product_architecture.py
│       ├── verify_phase35_production_polish.py
│       ├── generate_phase3_home_previews.gd
│       ├── test_load_all_source_scripts.gd
│       ├── verify_phase3_home_architecture.py
│       ├── verify_runtime_architecture.py
│       ├── verify_scene_investigation_content.py
│       ├── verify_flash_words_content.py
│       ├── verify_flash_words_engine_unchanged.py
│       └── verify_documentation.py
├── docs/
│   ├── foundation/
│   ├── product/
│   │   └── challenge-types/
│   └── store/
├── trailer/
└── storyboard-example/
```

## Ownership by layer

| Path | Layer | Responsibility |
|---|---|---|
| `app/src/core/` | Engine/Foundation | Boot, app state, events, navigation |
| `app/src/systems/` | Engine/Foundation | Stable shared services |
| `app/src/ui/` | Shared presentation | Shell, components, and presentation adapters |
| `app/src/gameplay/contracts/` | Data contracts | Family, template, instance, validation, presentation, and result data |
| `app/src/gameplay/runtime/` | Shared runtime | Type-agnostic orchestration and policies |
| `app/src/gameplay/interactions/` | Shared interaction | Registered payload collectors with no family meaning |
| `app/src/gameplay/families/` | Game modules | Family-specific generation, validation, scoring, difficulty, exposure, and presentation |
| `app/src/gameplay/progression/` | Product progression | Data-driven achievement definitions and evaluation |
| `app/src/gameplay/programs/` | Product journeys | Curated selection policies and Program progress |
| `app/src/gameplay/challenges.json` | Regression content | Five deterministic compatibility fixtures |
| `app/tests/runtime/` | Verification | Runtime, production gameplay, stress, content, visual, and documentation checks |
| `docs/product/` | Product source of truth | Roadmap, API, specifications, style guides, reviews, and gate records |

## Placement rules

- Shared runtime files contain no concrete family or fixture identifiers.
- Family-specific behavior belongs under its family directory.
- Production family modules register through `families/manifest.json`.
- Test-only families remain under `app/tests/` and never enter the production manifest.
- Runtime services extend but do not replace stable Foundation services.
- Museum, Vehicle, and Outdoor remain documentation-only until a later approved content gate.

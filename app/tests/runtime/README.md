# Challenge Runtime Gate Tests

Run each test with an isolated user-data home so profile state cannot leak between runs.

```bash
HOME=/tmp/tsw-gate1-home godot --headless --path ./app \
  --script res://tests/runtime/test_challenge_runtime_gate1.gd \
  --fixed-fps 60 --debug --ignore-error-breaks

HOME=/tmp/tsw-first-run-home godot --headless --path ./app \
  --script res://tests/runtime/test_first_run_runtime_regression.gd \
  --fixed-fps 60 --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_fixture_generation_and_validation.gd \
  --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_load_all_source_scripts.gd \
  --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_runtime_type_agnostic.gd \
  --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_family_tutorial_architecture.gd \
  --fixed-fps 60 --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_scene_investigation_production_flow.gd \
  --fixed-fps 60 --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_scene_investigation_tutorial.gd \
  --fixed-fps 60 --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_scene_investigation_scoring.gd --debug

godot --headless --path ./app \
  --script res://tests/runtime/test_scene_investigation_difficulty.gd --debug

godot --headless --path ./app \
  --script res://tests/runtime/test_scene_investigation_session_variety.gd --debug

godot --headless --path ./app \
  --script res://tests/runtime/test_scene_investigation_stress.gd \
  --debug -- --seeds=10000

godot --headless --path ./app \
  --script res://tests/runtime/test_flash_words_production_flow.gd \
  --fixed-fps 60 --debug --ignore-error-breaks

godot --headless --path ./app \
  --script res://tests/runtime/test_flash_words_tutorial.gd --debug

godot --headless --path ./app \
  --script res://tests/runtime/test_flash_words_policies.gd --debug

godot --headless --path ./app \
  --script res://tests/runtime/test_flash_words_session_variety.gd --debug

godot --headless --path ./app \
  --script res://tests/runtime/test_flash_words_seed_reproducibility.gd --debug

godot --headless --path ./app \
  --script res://tests/runtime/test_flash_words_stress.gd \
  --debug -- --seeds=10000

HOME=/tmp/tsw-phase3-home godot --headless --path ./app \
  --script res://tests/runtime/test_phase3_home_experience.gd --debug

HOME=/tmp/tsw-phase35-polish godot --headless --path ./app \
  --script res://tests/runtime/test_phase35_production_polish.gd --debug

HOME=/tmp/tsw-phase4-product godot --headless --path ./app \
  --script res://tests/runtime/test_phase4_product_experience.gd --debug

HOME=/tmp/tsw-phase5-interaction godot --headless --path ./app \
  --script res://tests/runtime/test_phase5_interaction_system.gd --debug
HOME=/tmp/tsw-phase5-families godot --headless --path ./app \
  --script res://tests/runtime/test_phase5_challenge_types.gd --debug
HOME=/tmp/tsw-phase5-stress godot --headless --path ./app \
  --script res://tests/runtime/test_phase5_stress.gd --debug -- --seeds=10000

HOME=/tmp/tsw-phase55-replay godot --headless --path ./app \
  --script res://tests/runtime/test_phase55_replay_quality.gd --debug

HOME=/tmp/tsw-phase6-system godot --headless --path ./app \
  --script res://tests/runtime/test_phase6_persistence_performance.gd --debug

HOME=/tmp/tsw-phase6-product godot --headless --path ./app \
  --script res://tests/runtime/test_phase6_product_pass.gd --debug

python app/tests/runtime/verify_phase6_production_readiness.py
python app/tests/runtime/verify_phase55_content_quality.py
python app/tests/runtime/verify_phase5_preparation.py
python app/tests/runtime/verify_phase5_architecture.py
python app/tests/runtime/verify_phase5_content.py
python app/tests/runtime/verify_phase5_interaction_baseline.py
python app/tests/runtime/verify_phase4_product_architecture.py
python app/tests/runtime/verify_phase35_production_polish.py
python app/tests/runtime/verify_phase3_home_architecture.py
python app/tests/runtime/verify_runtime_architecture.py
python app/tests/runtime/verify_scene_investigation_content.py
python app/tests/runtime/verify_flash_words_content.py
python app/tests/runtime/verify_flash_words_engine_unchanged.py
python app/tests/runtime/verify_documentation.py
```

`test_challenge_runtime_gate1.gd` verifies the Home → Play Now vertical slice, exact runtime stage order, result/progress/recommendation flow, and deterministic replay by seed.

`test_first_run_runtime_regression.gd` verifies that privacy and Tutorial launch the production Office practice through the shared runtime and return to Home without duplicate progress.

`test_fixture_generation_and_validation.gd` verifies all deterministic templates, same-seed reproduction, unique answers, required assets, valid exposure, and validator rejection behavior.

`test_load_all_source_scripts.gd` loads every source script in project context and fails on compile errors; validation treats emitted GDScript warnings as failures.

`test_runtime_type_agnostic.gd` registers synthetic non-visual families and verifies public registration, type-agnostic execution, immutable results, exactly-once progress, retries, fallback, controlled failure, and contract rejection.

`test_family_tutorial_architecture.gd` proves that the generic host loads, persists, replaces, and launches practice for multiple synthetic family tutorials without family-specific shared UI changes.

`test_scene_investigation_production_flow.gd` verifies the complete player-facing Office → Recall → Reveal → Witness Progress → Kitchen recommendation path.

`test_scene_investigation_tutorial.gd` verifies the five-stage interactive tutorial, generated demonstration, guided response, reveal, version persistence, practice launch, and replay entry.

`test_scene_investigation_scoring.gd` and `test_scene_investigation_difficulty.gd` verify family-owned scoring, bounded mastery, independent difficulty axes, approved exposure ranges, and Comfortable Timing.

`test_scene_investigation_session_variety.gd` verifies a 20-round mixed session, template rotation, no exact repetition, progress, mastery, and recent-signature rejection.

`test_scene_investigation_stress.gd` validates large deterministic seed batches across five templates and four difficulty tiers.

`test_flash_words_production_flow.gd` verifies first-visit tutorial gating, Single Word play, comparison reveal, Witness Progress, and Pair Order recommendation.

`test_flash_words_tutorial.gd` verifies guided recognition, letter comparison, pair demonstration, Reading Comfort Mode, version persistence, and practice launch.

`test_flash_words_policies.gd` verifies approved timing, independent sequence/display/interval axes, Reading Comfort Mode, and family result comparison.

`test_flash_words_session_variety.gd` verifies 20-round template rotation, recent-word avoidance, signatures, progress, and mastery.

`test_flash_words_seed_reproducibility.gd` regenerates 100 sampled seeds three times and compares serialized instances, answers, and scores.

`test_flash_words_stress.gd` validates 10,000 seeds per template/tier for 120,000 final production instances.

`test_phase3_home_experience.gd` verifies the catalog, Play Now recommendation, Continue fallback/resume, daily feature, required Home destinations, rich Challenge Library cards, Profile fields, ten achievement criteria, exactly-once persistence, Settings visibility, and runtime Continue launch.

`verify_phase3_home_architecture.py` rejects concrete family knowledge in Home/Library, checks product routes and service APIs, verifies all required Profile/Settings/card surfaces, and enforces entertainment-first player copy.

`verify_phase0_witness_shell.py` verifies the Phase 0 Witness Foundation Shell boundaries: Witness/Record/Settings primary navigation, secondary Library access, reusable shell/reveal components, asset placeholders, and unchanged frozen gameplay/session files.

`test_phase35_production_polish.gd` verifies sponsor boot configuration, portrait lock, safe-area scaling, responsive device profiles, 48-pixel touch targets, 140% text, 7:1 High Contrast, Reduced Motion, Reading Comfort, Color Assistance, and local performance/memory budgets.

`verify_phase35_production_polish.py` statically enforces Android system-splash attributes, responsive screens, accessibility wiring, performance instrumentation, bounded texture imports, and Phase 3.5 deliverables.

`test_phase4_product_experience.gd` verifies Program definitions and selection, runtime Program context, unfinished-run Continue, finite completion, favorites, persistence, expanded achievements, Home/Programs/Profile surfaces, and Collection Progress.

`verify_phase4_product_architecture.py` rejects family IDs and gameplay routing in Programs, verifies family-owned focus/weight metadata, required player-lifecycle surfaces, new achievements, and entertainment-first copy.

`verify_phase5_preparation.py` verifies the acceptance contract, twelve-family portfolio matrix, implementation order, coverage categories, roadmap split, implemented first three families, and deferred remaining family scope.

`test_phase5_interaction_system.gd` verifies adapter registration and opaque Single/Multiple Choice payload collection.

`test_phase5_challenge_types.gd` verifies all three new families, ten templates, interactions, deterministic generation, scoring, runtime flow, progress, catalog, and Programs integration.

`test_phase5_tutorials.gd`, `test_phase5_reproducibility_variety.gd`, and `test_phase5_stress.gd` verify tutorials, 100-seed reproduction, 20-round variety, and 400,000 release-stress instances.

`verify_phase5_architecture.py`, `verify_phase5_content.py`, and `verify_phase5_interaction_baseline.py` enforce generic interactions, complete family ownership, content, and the versioned 47-file shared baseline.

`test_phase55_replay_quality.gd` audits 50 rounds per production family for validation, reproducibility, semantic variety, template coverage, broad content use, no consecutive repeat, and explanatory evidence. It is an automated proxy and does not certify human fun.

`verify_phase55_content_quality.py` enforces expanded pools/templates/art/audio/Programs/achievements and accepts only Phase 6 changes recorded by the post-polish baseline.

`test_phase6_persistence_performance.gd` verifies atomic replacement, recovery copies, corrupt-save recovery, version-one migration, analytics opt-out/bounds, packaged audio resolution, save timing, and memory ceilings.

`test_phase6_product_pass.gd` constructs 13 production screens, verifies compact-layout copy and touch targets, exercises all production settings, checks every family under combined accessibility modes, and audits interaction, tutorial, Program, and achievement readiness.

`verify_phase6_production_readiness.py` enforces the frozen five-family architecture, offline Android configuration, persistence/audio/analytics hardening, screen and interaction polish, legal/release deliverables, and the 58-file post-polish baseline.

`generate_phase4_product_previews.gd` captures Home, Programs, Library, Profile, and Achievements with representative local progress.

`generate_phase3_home_previews.gd` creates local portrait review artifacts for Home, Challenge Library, Profile, Achievements, and Settings outside the exported app.

`fixtures/` contains test-only family strategies. They are never registered by the production family manifest.

`verify_runtime_architecture.py` rejects concrete family identifiers in shared runtime code, missing family modules/autoloads, legacy UI launch calls, and direct UI gameplay-route navigation.

`verify_scene_investigation_content.py` validates the approved three-template content scope, object pools, question types, palettes, backgrounds, and audio assets.

`verify_flash_words_content.py` validates 373 reviewed words, balancing metadata, templates, family modules, preview, and audio.

`verify_flash_words_engine_unchanged.py` proves all 71 protected Engine/shared files still match the post-tutorial-correction baseline.

`verify_documentation.py` checks local links, active phase status, terminology, player-facing copy, and required gate deliverables.

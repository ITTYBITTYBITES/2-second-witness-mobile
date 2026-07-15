# Repository Analysis Checklist

**Use before any implementation work.**
**Goal:** verify the real repository state before relying on continuity documents or changing protected systems.

---

# 1. Repository and branch verification

- [ ] Confirm current directory is the Two Second Witness repository.
- [ ] Run `git status --short --branch`.
- [ ] Confirm branch is exactly `arena/019f6520-2-second-witness-mobile`.
- [ ] Do not switch/create/push another branch.
- [ ] Record uncommitted files; do not overwrite another session’s work.
- [ ] Run `git log --oneline -15` and compare latest work with `02_CURRENT_IMPLEMENTATION_STATE.md`.
- [ ] Inspect `git diff --stat` and `git diff --check` before editing.

**Stop condition:** branch mismatch, unexpected dirty worktree, or continuity docs materially disagree with recent commits. Resolve/document before implementation.

---

# 2. Documentation-state verification

Read in this order:

- [ ] `01_PROJECT_CONTEXT_BOOTSTRAP.md`
- [ ] `02_CURRENT_IMPLEMENTATION_STATE.md`
- [ ] `05_DECISION_LOG.md`
- [ ] `06_ARCHITECTURE_CHANGE_LOG.md`
- [ ] `07_UPDATE_PROGRESS_TRACKER.md`
- [ ] `09_CHANGE_CONTROL_RULES.md`
- [ ] Current update section in `../flagship-master-plan/03_FLAGSHIP_EVOLUTION_ROADMAP.md`
- [ ] Current update detailed specifications and validation plan.
- [ ] Previous session handoff, if one has been recorded.

Confirm:

- [ ] Active update/status.
- [ ] Exact next milestone.
- [ ] Protected decisions and explicit exclusions.
- [ ] Required acceptance criteria.
- [ ] Existing known risks/blockers.

**Stop condition:** update scope is unclear or proposed work belongs to a later/deferred update.

---

# 3. Architecture and affected-system verification

For any proposed change, identify exact systems/files before editing.

## Always inspect when touching player journey

- [ ] `app/src/core/app/AppBoot.gd`
- [ ] `app/src/core/navigation/AppRoutes.gd`
- [ ] `app/src/core/navigation/NavigationService.gd`
- [ ] `app/src/ui/shell/AppShell.gd`
- [ ] `app/src/ui/screens/TitleSplashScreen.gd`
- [ ] `app/src/ui/screens/TutorialScreen.gd`
- [ ] `app/src/gameplay/runtime/ChallengeSessionService.gd`

## Always inspect when touching flagship gameplay/reveal

- [ ] `app/src/gameplay/families/scene_investigation/SceneInvestigationFamily.gd`
- [ ] Scene Investigation generator/validator/difficulty/exposure/scoring files.
- [ ] `SceneInvestigationSceneView.gd`
- [ ] `app/src/ui/screens/ObservationChallengeScreen.gd`
- [ ] `app/src/ui/screens/MemoryQuestionScreen.gd`
- [ ] `app/src/ui/screens/ResultScreen.gd`
- [ ] relevant contracts: `ChallengeInstance`, `ChallengeResult`, `PresentationProfile`, `InteractionProfile`.

## Always inspect when touching Brief/Record/progression

- [ ] `RecommendationService.gd`
- [ ] `ProgramService.gd`
- [ ] `PlayerProgressService.gd`
- [ ] `ProfileService.gd`
- [ ] `SaveService.gd`
- [ ] `HomeV2Screen.gd`
- [ ] `ProfileScreen.gd`

## Always inspect when touching presentation/accessibility/audio

- [ ] `ThemeService.gd`
- [ ] `AccessibilityService.gd`
- [ ] `AudioService.gd`
- [ ] `ResponsiveLayout.gd`
- [ ] relevant scene `.tscn` files.
- [ ] `app/project.godot` and `app/export_presets.cfg` if Android/render/export behavior is affected.

Confirm:

- [ ] No proposed alternate launch path bypasses ChallengeSessionService.
- [ ] No family ID branch is proposed in shared runtime/Home/Programs/profile/navigation.
- [ ] No second profile/save/recommendation/content registry is being introduced.
- [ ] Existing contracts can support the change or an explicit architecture change record exists.

---

# 4. Content and asset verification

When changing scenes/content/assets:

- [ ] Inspect active family manifest and content JSON/schema.
- [ ] Identify template, question type, asset references, generator/validator/reveal impact.
- [ ] Confirm object names and asset paths resolve.
- [ ] Review existing asset/import size/compression/version conventions.
- [ ] Check current sprite/vector fallback behavior before changing renderer assets.
- [ ] Confirm scene remains standalone/fair and evidence target can be generated.
- [ ] Review current content/visual validation scripts and contact-sheet artifacts.
- [ ] Evaluate memory/device impact before adding large assets.

**Stop condition:** a scene change requires hidden truth, color-only cue, tiny text, bypassed validator, or unreviewed art pipeline.

---

# 5. Test and build verification

## Identify applicable tests

- [ ] Read `app/tests/runtime/README.md`.
- [ ] Locate tests for active update/family/system.
- [ ] Identify static architecture/content verifiers affected.
- [ ] Identify baseline/hash files that may require deliberate compatible update.
- [ ] Check availability: `command -v godot || command -v godot4 || true`.
- [ ] Check current GitHub CI/check status if needed with `gh run list` / `gh pr checks`.

## Before editing

- [ ] Record current test status and known baseline failures.
- [ ] Do not assume historical docs mean tests pass on current revision.

## After editing

- [ ] Run the narrowest relevant tests first.
- [ ] Run required architecture/content/static verification.
- [ ] Run broader regression scope required by affected protected systems.
- [ ] Run `git diff --check`.
- [ ] Record exact commands/results/not-run reasons in handoff.

**Stop condition:** an affected test/baseline fails and cannot be classified/resolved. Do not hide it by changing unrelated code or updating hashes without documented reason.

---

# 6. Device and product validation verification

For changes affecting launch, timing, scene rendering, input, reveal, audio, haptics, layout, accessibility, save, or Android export:

- [ ] Identify required physical-device matrix from `../flagship-master-plan/11_DEVICE_ACCESSIBILITY_AND_VALIDATION_PLAN.md`.
- [ ] Identify first-time/returning human test needed from current update acceptance criteria.
- [ ] State whether evidence exists, is pending, or is blocked by environment.
- [ ] Do not call a release/polish task complete from headless/static evidence alone.

---

# 7. Pre-implementation briefing output

Before changing files, the agent should summarize:

```text
Current update/status:
Relevant protected systems:
Exact files to inspect/change:
Why this supports the active update:
Expected player impact:
Tests and device/human evidence required:
Known risks / explicit out-of-scope items:
```

Only proceed after this briefing is accurate and the task is within active update scope.

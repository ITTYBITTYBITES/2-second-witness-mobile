# Next Session Generator

**Purpose:** generate a complete, repository-grounded prompt for the next development conversation at the end of every meaningful session.

---

# 1. Generation process

Before writing the next prompt:

1. Update `02_CURRENT_IMPLEMENTATION_STATE.md` with actual status, files, tests, issues, and next tasks.
2. Update `07_UPDATE_PROGRESS_TRACKER.md` with active update/status/evidence gate.
3. Add permanent product/scope decisions to `05_DECISION_LOG.md`.
4. Add architecture/system changes to `06_ARCHITECTURE_CHANGE_LOG.md`.
5. Complete a handoff using `03_SESSION_HANDOFF_TEMPLATE.md`.
6. Identify exactly one recommended next action that is inside active update scope.
7. Include all blockers and tests that the next agent must understand before implementation.

The generator must not create a vague “continue where we left off” prompt. It must make a new session feel like a shift handover.

---

# 2. Required generated output

Use this exact structure and replace bracketed fields with current facts.

```text
Continue development of Two Second Witness from the repository’s continuity system.

Current branch: arena/019f6520-2-second-witness-mobile
Current commit: [latest commit hash and subject]
Active update: Update [X] — [Update Name]
Current status: [Planning / Ready for Implementation / Implementation / Validation / Complete / Blocked]

Completed in the previous session:
- [A]
- [B]
- [C]

Remaining tasks for the active update:
1. [D]
2. [E]
3. [F]

Known blockers / risks:
- [Exact blocker or “none known”]
- [Required device/human/test evidence]

Before making changes, read:
- docs/product/development-continuity/01_PROJECT_CONTEXT_BOOTSTRAP.md
- docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md
- docs/product/development-continuity/05_DECISION_LOG.md
- docs/product/development-continuity/06_ARCHITECTURE_CHANGE_LOG.md
- docs/product/development-continuity/07_UPDATE_PROGRESS_TRACKER.md
- docs/product/development-continuity/08_REPO_ANALYSIS_CHECKLIST.md
- docs/product/development-continuity/09_CHANGE_CONTROL_RULES.md
- docs/product/flagship-master-plan/03_FLAGSHIP_EVOLUTION_ROADMAP.md (Update [X] section)
- [Current update detailed specification files]
- [Previous session handoff path or pasted summary]

Then inspect the repository and confirm:
- current branch/worktree/recent commits;
- active update and protected decisions;
- relevant source files and existing tests;
- the single next recommended action;
- exact validation required.

Do not implement until the current state is understood.

Do not:
- rebuild or replace working architecture;
- bypass ChallengeSessionService for player-facing launches;
- create parallel save/profile/recommendation/content systems;
- add family-specific branches to shared systems;
- add unrelated features, currencies, social systems, accounts, AI scoring, Story Mode, campaigns, chapters, quests, or narrative UI;
- claim validation you did not run.

At the end of the session, update continuity docs, create a handoff using 03_SESSION_HANDOFF_TEMPLATE.md, and generate the next starter using this document.
```

---

# 3. Current generated starter — next recommended session

This starter is valid immediately after continuity system initialization:

```text
Continue development of Two Second Witness from the repository’s continuity system.

Current branch: arena/019f6520-2-second-witness-mobile
Current commit: Run `git log -1 --oneline` before implementation and record the actual result in the session briefing.
Active update: Update 1 — Witness Moment Foundation
Current status: Planning

Completed in the previous session:
- Product reconstruction, product direction, flagship experience, Witness Threads, and ten-update master-plan documentation packages were completed.
- Development continuity documentation was initialized in docs/product/development-continuity/.
- No application code, content, assets, export configuration, or architecture has been changed for Update 1.

Remaining tasks for the active update:
1. Trace current first launch → privacy → title/intro tutorial → Scene Investigation tutorial/practice → Result → Home behavior in the repository.
2. Create a narrowly scoped Update 1 implementation plan with exact source/content/test/documentation files, protected-system impact, and migration analysis.
3. Confirm the one first-session onboarding policy and explicit first Witness Moment content/configuration approach before implementing code.

Known blockers / risks:
- Update 1 has not been authorized for code implementation; first create/review the scoped plan.
- First-session logic/documentation has known drift and must be inspected from source.
- Physical Android, human first-session, 20/50-round, accessibility, save-upgrade, and signed-artifact validation remain open.
- Historical test baselines may be stale after Home/mobile/visual changes; do not assume green status.

Before making changes, read:
- docs/product/development-continuity/01_PROJECT_CONTEXT_BOOTSTRAP.md
- docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md
- docs/product/development-continuity/05_DECISION_LOG.md
- docs/product/development-continuity/06_ARCHITECTURE_CHANGE_LOG.md
- docs/product/development-continuity/07_UPDATE_PROGRESS_TRACKER.md
- docs/product/development-continuity/08_REPO_ANALYSIS_CHECKLIST.md
- docs/product/development-continuity/09_CHANGE_CONTROL_RULES.md
- docs/product/flagship-master-plan/03_FLAGSHIP_EVOLUTION_ROADMAP.md (Update 1 section)
- docs/product/flagship-master-plan/02_FLAGSHIP_TARGET_EXPERIENCE.md
- docs/product/flagship-master-plan/05_EVIDENCE_REVEAL_MASTER_SPECIFICATION.md
- docs/product/flagship-master-plan/06_SCENE_CREATION_AND_CONTENT_QUALITY_STANDARD.md
- docs/product/flagship-master-plan/09_WITNESS_RECORD_AND_RETURN_RITUAL_SPEC.md
- docs/product/flagship-master-plan/11_DEVICE_ACCESSIBILITY_AND_VALIDATION_PLAN.md

Then inspect the repository and confirm:
- current branch/worktree/recent commits;
- active update and protected decisions;
- relevant source files and existing tests;
- the single next recommended action;
- exact validation required.

Do not implement until the current state is understood.

Do not:
- rebuild or replace working architecture;
- bypass ChallengeSessionService for player-facing launches;
- create parallel save/profile/recommendation/content systems;
- add family-specific branches to shared systems;
- add unrelated features, currencies, social systems, accounts, AI scoring, Story Mode, campaigns, chapters, quests, or narrative UI;
- claim validation you did not run.

At the end of the session, update continuity docs, create a handoff using 03_SESSION_HANDOFF_TEMPLATE.md, and generate the next starter using this document.
```

---

# 4. Generator quality check

Before using a generated starter, verify it includes:

- [ ] Exact active update and status.
- [ ] Latest commit/branch/worktree instruction.
- [ ] Three or fewer focused remaining tasks, ordered by dependency.
- [ ] Known blockers and required evidence.
- [ ] Required continuity/master-plan documents.
- [ ] Explicit protected-system/no-scope-drift rules.
- [ ] End-of-session documentation/handoff requirement.

If it cannot name the next action precisely, the previous session did not leave a sufficient handoff. Return to `02_CURRENT_IMPLEMENTATION_STATE.md` and `03_SESSION_HANDOFF_TEMPLATE.md` before starting new implementation.

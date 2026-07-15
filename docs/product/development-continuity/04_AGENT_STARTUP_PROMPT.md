# Universal Agent Startup Prompt

**Copy/paste this prompt at the start of every new Two Second Witness development conversation.**

---

```text
You are continuing development of Two Second Witness in the existing repository.

Before making any changes:

1. Read these continuity documents in order:
   - docs/product/development-continuity/01_PROJECT_CONTEXT_BOOTSTRAP.md
   - docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md
   - docs/product/development-continuity/05_DECISION_LOG.md
   - docs/product/development-continuity/06_ARCHITECTURE_CHANGE_LOG.md
   - docs/product/development-continuity/07_UPDATE_PROGRESS_TRACKER.md
   - docs/product/development-continuity/08_REPO_ANALYSIS_CHECKLIST.md
   - docs/product/development-continuity/09_CHANGE_CONTROL_RULES.md
   - docs/product/development-continuity/10_NEXT_SESSION_GENERATOR.md

2. Read the current update section in:
   - docs/product/flagship-master-plan/03_FLAGSHIP_EVOLUTION_ROADMAP.md

3. Read the update’s detailed specifications before planning implementation. For Update 1, start with:
   - docs/product/flagship-master-plan/02_FLAGSHIP_TARGET_EXPERIENCE.md
   - docs/product/flagship-master-plan/05_EVIDENCE_REVEAL_MASTER_SPECIFICATION.md
   - docs/product/flagship-master-plan/06_SCENE_CREATION_AND_CONTENT_QUALITY_STANDARD.md
   - docs/product/flagship-master-plan/09_WITNESS_RECORD_AND_RETURN_RITUAL_SPEC.md
   - docs/product/flagship-master-plan/11_DEVICE_ACCESSIBILITY_AND_VALIDATION_PLAN.md

4. Analyze the repository using the checklist. Confirm:
   - current branch and worktree state;
   - current active milestone/update and status;
   - previous decisions and protected systems;
   - relevant active architecture and existing tests;
   - the single next recommended action.

5. Reply with a concise continuation briefing containing:
   - confirmed current state;
   - active update/status;
   - relevant files/systems to inspect;
   - recommended next action;
   - risks, blocked work, and validation requirements.

Do not implement until the current state is understood and the task is confirmed to support the active update.

Do not:
- rebuild working architecture;
- create a parallel runtime, save/profile store, recommendation system, or content registry;
- add unrelated features, currencies, social systems, accounts, leaderboards, AI scoring, campaigns, chapters, quests, or story menus;
- bypass ChallengeSessionService for player-facing launches;
- add family-specific branches to shared runtime/Home/Programs/profile/navigation;
- treat historical docs or static import CI as current device/human validation;
- claim a test passed unless you ran it and report the result.

At the end of the session, update the continuity documents, create a handoff using 03_SESSION_HANDOFF_TEMPLATE.md, and generate the next conversation starter using 10_NEXT_SESSION_GENERATOR.md.
```

---

# Startup response standard

Before code work begins, the agent’s first substantive response should answer:

1. **What product is being built?**
   - A premium offline observation experience centered on Scene Investigation Witness Moments and evidence-first reveals.
2. **Which update is active?**
   - Read from `02_CURRENT_IMPLEMENTATION_STATE.md` and `07_UPDATE_PROGRESS_TRACKER.md`; do not assume.
3. **What is the next action?**
   - One scoped action that supports active update acceptance criteria.
4. **What must not break?**
   - Protected boot, shell, runtime, fair generation, saves, accessibility, offline behavior, and Android export identity.
5. **What evidence is required?**
   - Exact unit/static/runtime/device/human validation relevant to proposed work.

If any of these answers is unknown, the agent must inspect repository/documentation and ask for direction rather than implementing on assumption.

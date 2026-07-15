# Human Owner Operating Guide

This guide explains how the project owner should run Two Second Witness development using the Command Center, Development Continuity System, automated audit system, and Flagship Evolution documentation.

It is written for a non-developer owner. You do not need to remember previous AI conversations. The repository documentation is the project memory.

---

## 1. Daily/Session Startup Routine

Every time you return to the project, start from the same place.

1. **Open `PROJECT_COMMAND_CENTER.md`.**
   - Treat this as the main dashboard for the project.
2. **Review `Current Status`.**
   - Confirm the current product phase, active flagship update, and next milestone.
3. **Read the current work/update sections.**
   - Review `Current Situation`, `Current Work`, `Next Actions`, `Risks`, and any locked decisions that affect the work.
4. **Open `docs/product/development-continuity/START_NEXT_SESSION.md`.**
   - This file contains the standard prompt for starting a new AI session.
5. **Copy the generated AI prompt.**
   - Replace the bracketed goal with the current goal from `PROJECT_COMMAND_CENTER.md`.
6. **Start a new AI session.**
   - Paste the prompt at the beginning of the session.
7. **Ask the AI to confirm understanding before changing anything.**
   - Use a simple instruction such as: `Before making changes, summarize the active update, the exact files you plan to inspect, and the boundaries you will follow.`

The goal of this routine is to make every session start from the documented project state instead of from memory.

---

## 2. Starting a New AI Agent Session

### What prompt to use

Use the prompt in:

`docs/product/development-continuity/START_NEXT_SESSION.md`

That prompt tells the AI to initialize from the repository instead of asking you to explain the whole project again.

### What files the agent should read

At minimum, the agent should read:

1. `PROJECT_COMMAND_CENTER.md`
   - Overall status, active update, next actions, risks, and locked decisions.
2. `docs/product/development-continuity/START_NEXT_SESSION.md`
   - Standard startup instructions.
3. `docs/product/development-continuity/01_PROJECT_CONTEXT_BOOTSTRAP.md`
   - High-level project context.
4. `docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md`
   - Current implementation state.
5. `docs/product/development-continuity/05_DECISION_LOG.md`
   - Permanent decisions that should not be casually changed.
6. `docs/product/development-continuity/07_UPDATE_PROGRESS_TRACKER.md`
   - Progress through the active update.
7. `docs/product/development-continuity/09_CHANGE_CONTROL_RULES.md`
   - Rules for safe changes.
8. `.github/project-state.yml`
   - Machine-readable project state used by automation.

If the task is about the Flagship Evolution roadmap, also ask the agent to read the relevant files in:

- `docs/product/flagship-master-plan/`
- `docs/product/flagship-experience/`

### What should not need to be pasted manually

You should not need to manually paste:

- Previous AI conversations.
- The full roadmap.
- The full decision history.
- The full implementation state.
- Long explanations of the project vision.
- Lists of locked decisions.

Those details should already be in the repository documentation. If an agent asks for them, tell the agent to read the continuity files instead.

### Ask the agent to verify understanding before changing code

Before the agent modifies anything, ask for a short confirmation:

```text
Before making changes, please confirm:
1. What is the active update?
2. What is the current goal?
3. Which files are in scope?
4. Which files or systems are out of scope?
5. What documentation must be updated before the session ends?
```

Only allow the agent to continue once the answer matches the Command Center and the active update.

---

## 3. During Development

### How to keep the agent focused

Use short, specific instructions:

- `Stay within the active update.`
- `Do not add new features outside the current roadmap item.`
- `Do not redesign existing systems unless the current update requires it.`
- `Make the smallest safe change that satisfies the task.`
- `If you discover a larger issue, document it as a blocker or future item instead of fixing it now.`

If the agent starts discussing unrelated improvements, redirect it back to the active update.

### When to ask for documentation updates

Ask for documentation updates when:

- A session changes project status.
- A decision is made.
- A blocker is discovered.
- A milestone is completed.
- A scope boundary becomes clearer.
- The next session needs handoff notes.

The most common files to update are:

- `PROJECT_COMMAND_CENTER.md`
- `docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md`
- `docs/product/development-continuity/05_DECISION_LOG.md`
- `docs/product/development-continuity/07_UPDATE_PROGRESS_TRACKER.md`
- `.github/project-state.yml`

Not every task needs every file updated. For example, a documentation-only improvement may only need the relevant documentation files and Command Center link updates.

### When to request a PR

Request a pull request when:

- The work for the current task is complete.
- The changes are reviewable as one focused unit.
- Tests or relevant checks have been run when applicable.
- Documentation has been updated if the project state changed.
- The agent can clearly explain what changed and why.

Use this instruction:

```text
Please prepare a focused PR for this completed task. Include a summary, tests/checks performed, documentation updated, and any follow-up items.
```

### How to avoid scope creep

Scope creep means the task expands beyond what was approved.

To avoid it:

- Keep one AI session focused on one goal.
- Keep one PR focused on one task or one update slice.
- Do not approve surprise features.
- Do not combine unrelated cleanup with product work.
- Do not let the agent rewrite systems just because they could be cleaner.
- Put extra ideas into `Deferred Items`, `Risks`, or a future roadmap note.

A useful phrase is:

```text
That may be valuable later. For this session, document it as a future consideration and return to the current task.
```

---

## 4. Reviewing an Agent PR

Before merging, use this checklist.

### Scope and intent

- [ ] Did the change match the current update in `PROJECT_COMMAND_CENTER.md`?
- [ ] Did the agent solve the requested task?
- [ ] Did the agent avoid unrelated work?
- [ ] Did the agent avoid unapproved redesigns?
- [ ] Did the agent avoid modifying gameplay, assets, or application code unless the task required it?

### Quality and safety

- [ ] Did tests pass, or did the agent explain why tests were not applicable?
- [ ] Were relevant checks or audits run?
- [ ] Are the changed files reasonable for the task?
- [ ] Is the PR small enough to review confidently?

### Documentation and continuity

- [ ] Did documentation update if needed?
- [ ] Is `PROJECT_COMMAND_CENTER.md` still accurate?
- [ ] Is `.github/project-state.yml` still accurate if project state changed?
- [ ] Are decisions, blockers, or follow-up items recorded?
- [ ] Is the next session state clear?

### Merge decision

Merge only when you can answer yes to the important checklist items. If something is unclear, ask the agent to revise the PR before merging.

---

## 5. Ending a Work Session

Before stopping, make sure the next session can continue without relying on memory.

Ask the agent to:

1. **Update current state.**
   - The Command Center should reflect what is now true.
2. **Record decisions.**
   - Important decisions should go into the decision log or relevant planning document.
3. **Note blockers.**
   - Anything preventing progress should be written down clearly.
4. **Create handoff information.**
   - The next agent should know what was done, what remains, and what to inspect first.
5. **Confirm next action.**
   - There should be a clear next step in the Command Center or continuity docs.

Use this prompt:

```text
Before we stop, please update the relevant continuity documentation and summarize the handoff for the next session: completed work, decisions, blockers, changed files, and recommended next action.
```

---

## 6. When Something Goes Wrong

### If the agent loses context

Tell the agent to stop and re-read the continuity files:

```text
Stop making changes. Re-read PROJECT_COMMAND_CENTER.md and docs/product/development-continuity/. Then summarize the active update, current goal, locked decisions, and next action before continuing.
```

Do not continue until the summary matches the documented project state.

### If documentation conflicts

When two documents disagree:

1. Treat `PROJECT_COMMAND_CENTER.md` as the current dashboard.
2. Check `05_DECISION_LOG.md` for locked decisions.
3. Check `02_CURRENT_IMPLEMENTATION_STATE.md` and `07_UPDATE_PROGRESS_TRACKER.md` for implementation details.
4. Ask the agent to identify the conflict and propose a documentation-only correction.
5. Do not let the agent change product behavior just to resolve a documentation conflict.

### If the roadmap becomes unclear

Pause implementation work.

Ask the agent to create or update a planning note that answers:

- What is the active update?
- What is the goal of the update?
- What is in scope?
- What is out of scope?
- What is the next smallest safe step?

Resume implementation only after the roadmap is clear again.

### If a change seems too large

Ask the agent to break it down:

```text
This seems too large. Please split it into smaller steps, identify the smallest safe PR, and document the remaining work as follow-up items.
```

Large changes should become several small PRs instead of one risky PR.

### If a feature idea appears outside scope

Do not approve it immediately. Ask:

- Does this support the active update?
- Is it required for the current milestone?
- Does it conflict with locked decisions?
- Can it wait until a later update?

If it is not required now, document it as a deferred item.

---

## 7. Long-Term Workflow

Use the same cycle throughout the project:

```text
Command Center
↓
AI Session
↓
Implementation
↓
PR Review
↓
Merge
↓
Documentation Update
↓
Next Session
```

### What each step means

- **Command Center:** Start from `PROJECT_COMMAND_CENTER.md` to understand the current state.
- **AI Session:** Use `START_NEXT_SESSION.md` to give the agent the right startup instructions.
- **Implementation:** Let the agent perform only the approved, scoped work.
- **PR Review:** Review the pull request with the checklist in this guide.
- **Merge:** Merge only when the work is correct, focused, and documented.
- **Documentation Update:** Make sure the continuity system reflects the new state.
- **Next Session:** The next AI session starts from the updated repository documentation.

This cycle is how the project avoids depending on memory, chat history, or a single developer.

---

## 8. Quick Reference Card

### Every time I work on Two Second Witness:

1. Open `PROJECT_COMMAND_CENTER.md`.
2. Confirm the active update and next action.
3. Open `docs/product/development-continuity/START_NEXT_SESSION.md`.
4. Copy the startup prompt into the AI session.
5. Ask the AI to confirm understanding before changing files.
6. Keep the session focused on the current task.
7. Ask for documentation updates before stopping.
8. Review any PR using the checklist in this guide.
9. Merge only when the change is focused, tested or explained, and the next session state is clear.

If confused, return to the Command Center. It is the project's external memory.

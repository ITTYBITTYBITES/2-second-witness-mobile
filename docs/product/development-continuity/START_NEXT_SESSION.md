# Next Session Starter

This document provides the recommended prompt for the next AI coding session to ensure continuity and focus.

---

## Recommended Prompt

Copy and paste the following into the start of the next AI session:

```text
I am starting a new session on the Two Second Witness repository. 

Please perform the following initialization steps:
1. Read PROJECT_COMMAND_CENTER.md at the root to understand the current state, active update, and next actions.
2. Read the documentation in docs/product/development-continuity/ to understand the project context and decision history.
3. Inspect .github/project-state.yml for machine-readable state.
4. Confirm the current milestone and active flagship update.
5. Avoid making any changes that are unrelated to the current active update or that violate the Locked Decisions in the Command Center.

Current Goal: [INSERT CURRENT GOAL FROM COMMAND CENTER]
```

---

## AI Instructions for Context Initialization

When you (the AI) start, you should:
- **Scan the Roadmap:** See exactly where we are in the 10-update plan.
- **Check the Decision Log:** Never undo a "Locked" decision unless explicitly asked by the human owner with a valid reason.
- **Respect Boundaries:** Do not modify systems that are out of scope for the current update.
- **Update Continuity:** At the end of the session, ensure you update `PROJECT_COMMAND_CENTER.md`, `.github/project-state.yml`, and `docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md`.

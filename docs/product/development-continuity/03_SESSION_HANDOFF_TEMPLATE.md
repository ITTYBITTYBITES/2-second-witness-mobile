# Session Handoff Template

**Use at the end of every meaningful AI coding, planning, validation, or release-preparation session.**
**Goal:** a new agent should be able to continue safely without relying on chat history.

---

# How to use

1. Copy the template below into a dated handoff entry or the current session’s approved handoff location.
2. Update `02_CURRENT_IMPLEMENTATION_STATE.md`, `05_DECISION_LOG.md`, `06_ARCHITECTURE_CHANGE_LOG.md`, and `07_UPDATE_PROGRESS_TRACKER.md` first when applicable.
3. Use exact repository-relative paths and exact commit hashes.
4. State what was **not** tested and why. Never imply validation occurred when it did not.
5. Generate the exact next-conversation prompt using `10_NEXT_SESSION_GENERATOR.md`.

---

# Handoff Template

```markdown
# Session Handoff — YYYY-MM-DD — [Update X / Workstream]

## Session Summary

### What happened?

- [Concise factual summary of completed work.]
- [Describe player/product impact if relevant.]
- [State whether this was planning, implementation, validation, or release work.]

## Current Milestone

| Field | Value |
|---|---|
| Active update | Update X — [Name] |
| Status before session | [Planning / Implementation / Validation / Complete / Blocked] |
| Status after session | [Planning / Implementation / Validation / Complete / Blocked] |
| Branch | `arena/019f6520-2-second-witness-mobile` |
| Latest commit | `[hash] [message]` |

## Decisions Made

| Decision | Reason | Alternatives considered | Impact |
|---|---|---|---|
| [Exact finalized choice] | [Evidence/constraint] | [Alternatives] | [Product/technical effect] |

- [State explicitly if no permanent decision was made.]
- [State any decision requiring later validation rather than treating it as final.]

## Files Changed

### Application / content / configuration

- `path/to/file` — [exact change and why]

### Tests / validation

- `path/to/test` — [exact coverage added/updated]

### Documentation / planning

- `path/to/doc` — [exact update]

### Files intentionally not changed

- [Protected system/file left unchanged and why, if relevant.]

## Validation Completed

| Check | Command or method | Result | Notes |
|---|---|---|---|
| [Example: static formatting] | `[exact command]` | Pass/Fail/Not run | [Evidence] |
| [Example: Godot runtime] | `[exact command]` | Pass/Fail/Not run | [Reason if not run] |
| [Example: device validation] | [device/matrix] | Pass/Fail/Not run | [Evidence] |

## Validation Not Completed

- [Exact required check not run.]
- Reason: [environment, scope, blocker, or explicit deferment].
- Owner/next action: [what must happen next].

## Remaining Work

### Required before this update can advance

1. [Specific task, affected system, expected result.]
2. [Specific validation gate.]
3. [Specific documentation/state update.]

### Explicitly out of scope

- [Feature/system that must not be added in the next session.]
- [Protected architecture that must not be rewritten.]

## Known Issues / Risks

- [New or unresolved product risk.]
- [New or unresolved technical risk.]
- [Test baseline, migration, device, content, or scope concern.]

## Repository State

- `git status --short --branch`: [clean / exact modified files]
- Current branch confirmed: [yes/no]
- Commit created: [hash or no, reason]
- Pushed: [yes/no/not requested]

## Required Documentation Updates Completed

- [ ] `PROJECT_COMMAND_CENTER.md`
- [ ] `.github/project-state.yml`
- [ ] `02_CURRENT_IMPLEMENTATION_STATE.md`
- [ ] `05_DECISION_LOG.md` (if decision made)
- [ ] `06_ARCHITECTURE_CHANGE_LOG.md` (if architecture/system changed)
- [ ] `07_UPDATE_PROGRESS_TRACKER.md`
- [ ] Relevant master-plan/update specification docs

## Next Conversation Starting Prompt

[Paste the exact generated prompt from `10_NEXT_SESSION_GENERATOR.md` here.]
```

---

# Handoff quality rules

A valid handoff is:

- **Factual:** no claim without code, command output, device evidence, or explicit product decision record.
- **Specific:** names exact files, systems, branch, commit, tests, and remaining tasks.
- **Scoped:** distinguishes completed work from ideas, blockers, and out-of-scope requests.
- **Safe:** repeats protected decisions where next work could accidentally violate them.
- **Actionable:** a new agent can identify one next recommended action without rereading chat history.

A handoff is invalid if it says only “completed work,” “tests pass,” or “continue Update X” without detail.

# Change Control Rules

**Purpose:** prevent product/architecture drift across many development conversations.
**Default behavior:** defer anything that does not clearly strengthen the active flagship update.

---

# 1. Required change-control questions

Before proposing or implementing any change, answer all questions in writing.

## Product fit

1. **Does this improve the Witness Moment?**
   - Does it improve observation, fair recall, evidence reveal, Witness Record, or calm return ritual?
2. **Does this support the active update?**
   - If it belongs to a later update, document/defer it instead.
3. **What will the player notice or feel?**
   - “Cleaner code” alone is not a player experience justification.
4. **Does it preserve curiosity/discovery rather than test/judgment/pressure?**
5. **Does it make the product more like a campaign, task app, dashboard, or generic mini-game collection?**
   - If yes, stop unless an explicit product decision authorizes it.

## Architecture fit

6. **Can existing systems support it?**
   - Reuse ChallengeSessionService, family contracts, PlayerProgress/Profile/Save, Recommendation/Program, Theme/Accessibility/Audio before proposing new services.
7. **Does it preserve existing architecture?**
   - No second runtime, profile store, recommendation controller, content registry, or navigation path.
8. **Does it preserve family-agnostic shared systems?**
   - Family-specific mechanics belong in family modules, policies, renderer, and content.
9. **Does it require migration?**
   - State save/profile/content/API compatibility before writing code.
10. **What protected systems could regress?**
    - Boot, splash, privacy, route/back, save, accessibility, audio, Android/export, fair generation, result lifecycle.

## Scope and evidence fit

11. **Does it create unnecessary scope?**
    - New family, economy, social, account, story, or platform work is deferred by default.
12. **What is the smallest reversible change that can prove the hypothesis?**
13. **What tests, device checks, and human evidence are required?**
14. **What existing complexity becomes simpler or less visible in return?**
15. **Is the decision already recorded?**
    - Check `05_DECISION_LOG.md` before reviving an old idea.

If any answer is “no,” “unknown,” or “not applicable” without explanation, do not implement. Clarify, defer, or ask for approval.

---

# 2. Automatic deferrals

The following automatically defer unless the user explicitly changes product strategy and a Decision Log entry is approved:

- New Challenge Types before existing flagship/replay evidence.
- Story Mode, campaigns, chapters, cases UI, quests, named characters, narrative completion.
- Witness Threads implementation before explicit prototype gate.
- Social features, leaderboards, friend systems, chat, sharing pressure.
- Currency, inventory, shop, energy, battle pass, loot, reward economy.
- Accounts, cloud sync, remote content, remote analytics endpoint.
- AI scoring, diagnostic claims, personal ability inference.
- Full Home/Profile/Library redesign unrelated to active update.
- Replacing runtime/navigation/save/profile/content architecture.
- Custom Android activity/rendering rewrite absent a validated platform defect.
- Store copy/assets claiming unshipped feature behavior.

The correct response is usually: **record as future opportunity, explain why it is deferred, and return to active update work.**

---

# 3. Required documentation updates by change type

| Change type | Required updates |
|---|---|
| Product behavior/priority | Current State, Decision Log, Progress Tracker, affected master plan/spec. |
| Architecture/API/service boundary | Architecture Change Log, Decision Log, Current State, tests, migration notes, affected specs. |
| Save/profile/content schema | Architecture Change Log, migration note, tests, Current State, release checklist impact. |
| First-session/Brief/reveal behavior | Current State, update tracker, active update spec, human/device validation plan. |
| Scene/content/asset change | Content/asset pipeline records, quality review, tests, asset/version notes, Current State. |
| Accessibility/audio/motion change | Active spec, device/accessibility matrix, tests, Current State. |
| Android/export/store change | Architecture Change Log, device validation plan, store evolution plan, release documents. |
| Documentation-only planning | Current State and handoff; Decision/Architecture logs only if a permanent decision/boundary changed. |

---

# 4. Scope escalation protocol

When a change appears to need a new system or broad rewrite:

1. Stop implementation.
2. State the exact unmet need in player terms.
3. Identify why existing system cannot support it.
4. List minimum affected contracts/files/data/migration impacts.
5. List alternatives: content-only, policy-only, presentation-only, additive adapter, defer.
6. Update or propose an Architecture Change Log entry.
7. Request explicit approval before expanding scope.

No agent should make an architecture change because it seems cleaner in isolation.

---

# 5. End-of-session control gate

Before committing/handing off, confirm:

- [ ] Work served active update acceptance criteria.
- [ ] No automatic-deferral item entered scope.
- [ ] Protected systems were inspected/regression-tested as needed.
- [ ] Test claims include exact commands/results/not-run reasons.
- [ ] Current State/Tracker/Decision/Architecture docs are updated.
- [ ] Handoff names exact files, commit, remaining work, blockers, and next action.
- [ ] Next prompt does not ask a future agent to rediscover state from scratch.

The project remains coherent when every change makes the next Witness Moment better—or does not get built yet.

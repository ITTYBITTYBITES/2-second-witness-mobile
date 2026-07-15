# Risk Register and Scope Control

**Purpose:** protect the flagship roadmap from product drift, technical regression, content dilution, and premature complexity.
**Final section:** Flagship Completion Definition after Update 10.

---

# 1. Product risks

| Risk | Probability | Impact | Early warning | Mitigation / decision rule |
|---|---|---|---|---|
| Flagship remains one of many equal mini-games | Medium | High | Players cannot name what Two Second Witness is after first session. | Make Scene Investigation first/primary; validate family roles before equal promotion. |
| Reveal is seen as score feedback | Medium | High | Players skip reveal or only mention points/accuracy. | Enforce context → evidence → explanation hierarchy; remove competing result noise. |
| “Two Second” feels unfair or misleading | Medium | High | Players complain scene vanished before stable view or expect every round to be exactly 2s. | Teach with longer first exposure; define signature 2s standard honestly; measure device timing. |
| Daily Brief becomes chore/FOMO | Medium | High | Players mention streak/task pressure or fear missing content. | No missed-day penalty, time limit, notification pressure, or story advancement requirement. |
| Progression becomes dashboard clutter | High | Medium | Players cannot explain rank/mastery/achievements/collections. | Center current Brief + Witness Record; keep secondary metrics optional. |
| Premium trailer/store promise diverges from play | Medium | High | Users expect detective narrative/thriller or story campaign. | Use real gameplay captures; market observation/evidence, not unsupported plot. |
| Threads turn product into Story Mode | Medium if built early | High | Players ask where chapters/cases/next story are. | Document only now; hard no-campaign/no-progress rules; one bounded later prototype. |
| Accessibility treated as settings rather than fairness | Medium | High | Default build works but comfort modes feel lesser or break evidence. | Make accessibility acceptance a release gate for every update. |

---

# 2. Technical risks

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Boot/splash/Android renderer regression | Medium | Critical | Preserve boot/export settings; physical cold/warm launch matrix; no speculative rendering rewrite. |
| Save/profile loss during Record/Brief evolution | Low–medium | Critical | Keep one Profile/Save path; additive schema only; migration/backup/force-close tests. |
| Shared runtime gains family-specific branches | Medium | High | Architecture verifier/review; family modules own rules/renderers/scoring; session service stays generic. |
| Parallel selection/progression store appears | Medium | High | Reuse Recommendation/Program/PlayerProgress; reject second controller/database without justification. |
| Test baseline drift hides regression | High | High | Update hash/config/doc baselines deliberately with owner/reason; run full runtime/device suite. |
| Scene asset growth causes memory/frame issues | Medium | High | Asset budgets, import review, device texture/memory tests, current fallback behavior preserved. |
| Audio/haptic layering defects | Medium | Medium | Reuse AudioService; bus/mute/route/interruption tests; physical speaker/headphone review. |
| Route/cache lifecycle leaks dynamic scene/reveal controls | Medium | High | Preserve uncached gameplay routes/cleanup; 50-round memory trend test. |
| Physical touch differs from headless/UI assumptions | High | High | Require real device matrix for Spatial Tap, choice input, exit, Back, safe areas. |

---

# 3. Content risks

| Risk | Impact | Mitigation |
|---|---|---|
| More scenes are visually new but mechanically repetitive | Medium–high | Require distinct observation grammar/template decision before approval. |
| Detail density becomes unfair camouflage | High | Density/contrast/scale/zone rules; human fairness review. |
| Question wording/art naming mismatch | High | Truth graph + player-readable object naming + explanation review. |
| Generated variation outpaces editorial review | High | Bounded content pools, validator gates, seed contact sheets, known-valid fallback. |
| Art style fragments across families/updates | Medium | Shared editorial-evidence art direction and family-specific acceptance review. |
| Content expansion outpaces device budget | High | Asset pipeline/import/performance gate before catalog release. |
| Threads impose too much recurring-asset continuity QA | Medium–high | Limit future prototype to one three-scene material thread; standalone scene quality first. |
| Narrative callbacks imply plot/characters | High | Material/environmental echoes only; no named characters/case/campaign copy. |

---

# 4. Scope risks

## Do Not Build Yet

The following are explicitly deferred unless a later approved strategy overturns this decision with evidence:

- Social systems, friends, chat, feeds, sharing pressure.
- Leaderboards, comparative rank, competitive events.
- Economy, currency, loot, shop, energy, battle pass, reward track.
- Accounts, cloud sync, remote profile identity.
- AI scoring, diagnostic claims, personal ability inference.
- Narrative campaigns, chapters, Story Mode, named characters, quest systems.
- New Challenge Families before current five/flagship evidence proves a specific gap.
- Remote/live content delivery before offline/privacy strategy changes deliberately.
- Full engine/runtime/navigation/profile replacement.
- Custom Android activity or architecture fork without a validated platform defect.

## Scope-control questions for every proposal

1. Does this make the next Witness Moment more compelling, fair, or understandable?
2. Does it protect the evidence reveal as the emotional reward?
3. Can existing runtime/content/save/accessibility systems support it with additive change?
4. Does it introduce pressure, currency, competition, narrative obligation, or a second product identity?
5. Is there player/device evidence that this is the next constraint—not merely an interesting feature?
6. What existing system or visible complexity does it simplify in return?
7. What protected-system regression tests and migration plans are required?

If a proposal cannot answer these questions, it does not enter the roadmap.

---

# 5. Release and operational risks

| Risk | Mitigation |
|---|---|
| Store copy/screenshots overclaim | Capture from real signed build; product/legal review all claims. |
| Privacy/Data Safety drift | Preserve offline/no-account behavior; review permissions/endpoints/dependencies before every release. |
| Existing users lose context/progress | Versioned additive migration; respectful reintroduction; no forced restart/tour. |
| Signing/update continuity failure | Preserve package identity and release signing process; test upgrade early. |
| No rollback plan | Assign rollout owner, artifact archive, known-good baseline, staged release path. |
| Human testing deferred until launch | Make first-session, 20/50-round, accessibility/device evidence hard release gates. |

---

# 6. Final Flagship Completion Definition — After Update 10

Two Second Witness has arrived as the intended flagship experience only when all statements below are true.

## Core Witness Moment

- [ ] Scene Investigation is unmistakably the flagship first/return experience.
- [ ] First-time players reach a fair Witness Moment quickly and can explain the loop without coaching.
- [ ] Standard observation timing is distinctive and fair; first/comfort timing is honest and accessible.
- [ ] One scene, one question, one witness call, and one evidence reveal form a complete satisfying unit.

## Evidence Reveal

- [ ] The scene returns before evidence annotation.
- [ ] Every question type has precise visible proof and factual explanation.
- [ ] Correct and missed outcomes both create discovery rather than judgment.
- [ ] Players describe reveal as the reason they want another moment.

## Scene and content quality

- [ ] Every visible flagship scene passes visual, fairness, surprise, explanation, and replay criteria.
- [ ] Content variation is structurally and perceptually meaningful across 20/50-round sessions.
- [ ] New content follows approved art/asset/validation workflow.
- [ ] No scene relies on unfair text, color-only cue, crop, clutter, or ambiguous object naming.

## Return and record

- [ ] Returning players understand one clear Witness Brief/resume proposition.
- [ ] The Brief feels finite, optional, fresh, and free from FOMO/streak obligation.
- [ ] The Witness Record feels like private personal history, not a score dashboard.
- [ ] Progress is meaningful without currency, artificial rewards, or claims about real-world ability.

## Premium presentation

- [ ] Motion, audio, haptics, typography, scene framing, and transitions all serve attention/truth hierarchy.
- [ ] Reduced Motion, High Contrast, text scaling, comfort timing, audio-off, haptics-off, and assistive paths preserve equivalent core meaning.
- [ ] Players describe the product as calm, focused, intentional, and premium.

## Technology and release quality

- [ ] Protected boot/navigation/runtime/save/profile/content architecture remains intact or has documented compatible evolution.
- [ ] Full runtime/static/device test suite is current, green, and not dependent on stale baseline assumptions.
- [ ] Physical Android matrix confirms launch, safe areas, timing, touch, frame pacing, audio, haptics, save recovery, offline behavior, and Back navigation.
- [ ] Signed artifact, store metadata, privacy/legal, dependency, permissions, upgrade, and staged rollout checks pass.

## Store alignment

- [ ] Icon, feature graphic, screenshots, description, trailer/footage, and update messaging depict the actual flagship experience.
- [ ] Existing users can return without losing progress or being forced through a feature tour.
- [ ] Store promise is observation, fair evidence, private record, and premium calm—not unsupported assessment, story, or competition.

## Future depth

- [ ] Witness Threads remain documented and bounded; they are implemented only if research proves retrospective connection strengthens curiosity without obligation.

When these conditions are true, the product is not merely feature-complete. It has become a coherent premium observation experience in which every update has revealed another layer of depth without compromising the simple act of noticing.

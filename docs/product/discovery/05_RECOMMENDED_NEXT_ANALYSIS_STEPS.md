# Recommended Next Analysis Steps — Two Second Witness

**Discovery snapshot:** 2026-07-15
**Boundary:** These are analysis and decision steps, not a redesign plan. Do not decide interface, visual, progression, or feature solutions until the questions below are answered with evidence.

---

# 1. Questions We Need Answered Before Rebuilding

## A. Core product and player feeling

1. **What is the true core experience?**
   - Is it witnessing an ordinary scene, detecting a change, making a rapid recall decision, or mastering a varied observation anthology?
2. **Which current Challenge Type is the flagship in reality?**
   - Which one is clearest on first play, most replayed voluntarily, most fair after misses, most marketable in screenshots/video, and most aligned with the title?
3. **What should the player feel at each phase?**
   - At launch, observation, response, a correct answer, a miss, a reveal, a completed Program, and a return visit.
4. **How literal is “Two Second” meant to be?**
   - Is it a fixed mechanic, a shorthand for brief attention, a brand mood, or a promise that needs a clear player interpretation?
5. **Is the intended fantasy witness/detective, premium observation practice, daily puzzle ritual, or something else?**
   - How should the current abstract/word/set/pattern families relate to that chosen fantasy?
6. **What must make a miss satisfying instead of discouraging?**
   - Is the evidence reveal currently enough, and does it land as discovery for real players?

## B. First session and onboarding

7. **What is the exact desired first-launch journey?**
   - Does privacy lead to Home, an intro tutorial, a practice round, or another sequence?
8. **Which family should teach the first session, and why?**
   - Current source implicitly selects the first visible manifest family; is that an intentional product choice?
9. **What must a new player understand before their first round?**
   - Timing, response rules, fairness, progress, the witness identity, or only the immediate action?
10. **What constitutes successful onboarding?**
    - Completing a tutorial, finishing a round, understanding a reveal, choosing another round, or returning later?
11. **When should family tutorials recur, be skipped, or be replayed?**
    - How should the title-screen intro and per-family tutorial gating relate?

## C. Daily return, progression, and choice

12. **What should happen every day?**
    - Is there truly a daily ritual, a rotating feature, a curated run, a personal recommendation, or no daily promise at all?
13. **What should a streak represent?**
    - Consecutive correct answers, consecutive days, session momentum, or something else?
14. **What should progression mean?**
    - Familiarity, mastery, story/status, collection, access, personal record, or a mix?
15. **Which current progress signals actually matter?**
    - Witness Level, rank, mastery, accuracy, confidence, history, favorites, achievements, collections, and Program records should not be assumed equally valuable.
16. **What makes a Program worth starting and finishing?**
    - Focus, variety, challenge, discovery, daily ritual, a personal goal, or an external reward?
17. **How much choice should a returning player have?**
    - One recommendation, direct family selection, a Program, a recent round, or different choices for different states?
18. **What should be unlocked, when, and why?**
    - In particular, what is the intended meaning of Pattern Recall’s level-two gate and any future content gate?

## D. Portfolio and content

19. **Should the five current families be equal pillars?**
    - Or do they have primary, companion, specialist, or experimental roles?
20. **Which family combinations feel coherent to players?**
    - Do word and abstract pattern modes strengthen the witness brand, or feel separate from it?
21. **Which existing templates are perceived as meaningfully different?**
    - Structural template distinction must be checked against player perception.
22. **Where does variety become fatigue?**
    - For each family, at 5, 20, and 50 rounds.
23. **Do players recognize and value the ordinary-scene settings, object vocabularies, word pools, symbols, and mutation types?**
24. **Are any of the seven planned families necessary before the current five are proven?**
    - Motion Tracking, Hidden Detail, Color Recall, Direction Recall, Symbol Recognition, Number Recall, and Sound Recognition should be evaluated against observed gaps, not roadmap momentum.
25. **What content locale/language scope is intended?**
    - Flash Words is currently English-specific; future language support affects core content, not just labels.

## E. Fairness, accessibility, and trust

26. **What does “fair” mean to actual players at each difficulty tier?**
    - Does it mean enough time, visual clarity, understandable distractors, legible reveal evidence, controllable input, or all of these?
27. **Which accommodations are mechanically equivalent for each family?**
    - Especially Spatial Tap alternatives, Reduced Motion, Color Assistance, Reading Comfort, and Comfortable Timing.
28. **Do physical-device taps, text, audio, safe areas, and haptics uphold the intended fairness?**
29. **How should offline/local-only progress be explained and what continuity do players expect?**
    - Local privacy is a strength; lack of cloud recovery may still matter to some audience segments.
30. **What claims can the product make responsibly?**
    - Entertainment, observation, fair puzzle challenge, privacy, and accessibility claims must be distinguished from unproven training/ability claims.

## F. Product identity, market, and business

31. **What promise should marketing make that the playable product can fulfill in its first minute?**
32. **How should the cinematic thriller material relate to actual gameplay?**
    - Is it brand atmosphere, a future content direction, a trailer-only frame, or an expectation mismatch?
33. **Who is the initial audience and what alternative are they choosing instead?**
    - Casual daily puzzle, memory game, detective/mystery game, spot-the-difference game, premium offline game, or another category.
34. **What does “premium” mean commercially and experientially?**
    - Price/entitlement model, ad-free promise, content value, and ongoing support expectations need a shared answer.
35. **What should make this memorable enough to recommend?**
    - A specific first impression, reveal moment, family, identity, ritual, or personal record.

## G. Architecture and delivery decisions

36. **Which current systems are active product dependencies versus legacy compatibility scaffolding?**
    - In particular, what is the intended future of `ExperienceRegistry`/`ContentService` and the old Flashword model?
37. **What validation level is required before any rebuild work changes a frozen platform contract?**
38. **How will current test baselines, Home V2 documentation, rendering configuration, and release claims be reconciled?**
39. **What device/platform scope is supported at launch?**
    - Phones, tablets, folded/unfolded devices, orientation, Android versions, and accessibility constraints.
40. **What preservation/migration promise is made to existing local progress?**

---

# 2. Recommended Next Analysis Steps

## Step 1 — Establish a trustworthy current-build baseline

**Goal:** make sure future product decisions are based on the actual runnable build, not a mixture of phase documents and source assumptions.

Collect:

- A clean Godot 4.6.3 import and the full headless runtime suite on the current revision.
- Resolution of the six failing static verifiers or an explicit classification of each as obsolete, intentional, or a product defect.
- A current route map and screenshots/video of: first launch, privacy, intro tutorial, Home V2, Library with all five families, each family’s observation/response/result, Programs, Profile, Settings, error/exit states.
- A signed or installable Android build and real device evidence for the release checklist’s boot, layout, accessibility, audio/haptic, and save paths.

**Why first:** current documentation and test baselines predate recent Home/renderer/mobile changes. Product analysis cannot safely rely on old artifacts as current-state truth.

## Step 2 — Run first-session usability and comprehension research

**Goal:** learn whether the product explains itself and whether the first emotional promise lands.

Minimum evidence:

- Several first-time participants on physical Android hardware.
- Observe without coaching from launch through privacy, intro/tutorial, first round, response, result, and return to Home.
- Capture: what they think the app is, what they expect from “Two Second Witness,” whether they understand the immediate task, whether the timer feels fair, what the reveal taught them, and what they choose next.
- Compare observed behavior with the intended source flow, especially the actual title-screen intro tutorial and first-family selection.

**Decision output:** a verified first-session narrative and a list of comprehension failures ranked by evidence.

## Step 3 — Determine the core/flagship family through comparative play

**Goal:** decide what the product is before expanding it.

Use the existing five types rather than building new ones. For each family, collect:

- first-round clarity;
- voluntary replay/selection;
- perceived fairness after a miss;
- emotional strength of result/reveal;
- fatigue and freshness after 20 rounds;
- ability to explain what makes it different;
- fit with the witness identity and marketing promise;
- accessibility observations under relevant settings.

**Decision output:** an evidence-backed portfolio role for every current family—without assuming equal status or prematurely removing anything.

## Step 4 — Investigate the return loop separately from the round loop

**Goal:** separate “this was a good round” from “I want to open this tomorrow.”

Analyze through play sessions/prototypes only after Step 2/3 findings:

- Do players notice or value Home’s recommendation reason?
- Do they interpret “Today’s Witness Experience” as a daily ritual?
- Do they understand the difference between Play Now, Continue, a daily feature, and a Program?
- Do correct-answer streak, mastery, rank, achievement, favorite, and Program progress motivate the next action?
- Which post-result path do they choose and why?

**Decision output:** a clear definition of daily behavior, progression meaning, and return motivation—or evidence that some of those concepts should not be central.

## Step 5 — Conduct 20- and 50-round replay/fairness studies

**Goal:** turn automated variety claims into player experience evidence.

For every family and major template, record:

- confusion points, mis-taps, perceived unfairness, and reveal comprehension;
- repetition/fatigue/novelty over time;
- visible strategy development;
- voluntary stop and replay points;
- response to correct versus incorrect results;
- timing and difficulty perceptions;
- behavior under Comfortable Timing, Reading Comfort, Reduced Motion, High Contrast, Color Assistance, muted audio, and interaction alternatives where applicable.

**Decision output:** content/difficulty/fairness findings with actual player quotes and observed behavior, not just generator coverage.

## Step 6 — Reconcile brand, trailer, and playable-product identity

**Goal:** identify the promise the product can make honestly in its first minute.

Compare player perception of:

- witness/observation language;
- ordinary scenes versus cinematic mystery imagery;
- the eye motif and premium/dark visual language;
- the product’s five varied mechanics;
- the trailer’s changed-object/investigator atmosphere;
- offline/no-account trust messaging.

**Decision output:** an agreed product positioning statement, intended emotional tone, and a list of claims/content that do or do not belong to the same experience.

## Step 7 — Audit active architecture and migration constraints

**Goal:** protect the useful platform while making future scope legible.

Map:

- active runtime path from every player launch point;
- all calls to the dormant `ExperienceRegistry`/legacy content path and fixture registry;
- save keys/current profile schemas and migration surface;
- data contracts relied on by Home, Library, Programs, Profile, Settings, tutorials, and results;
- test baselines and the exact cause/owner of each mismatch;
- external release dependencies: Android signing, store listing, hosted legal policy, signed artifact scan.

**Decision output:** an active-system inventory with explicit “preserve,” “compatibility-only,” and “unknown” classifications. This is a technical discovery step, not a deletion plan.

---

# 3. Suggested Decision Gates Before Any Redesign Plan

A future redesign plan should wait until the team can answer all of the following with evidence:

- [ ] We know what a new player believes the product is after the first minute.
- [ ] We know which existing family is core/flagship and why.
- [ ] We know whether the evidence reveal creates the desired fairness response.
- [ ] We know whether the title, timing model, trailer, and in-app fantasy make the same promise.
- [ ] We know what “daily” and “progression” mean to the player, if they remain central.
- [ ] We have 20/50-round findings for every current family and major accessibility mode.
- [ ] We have physical Android evidence for boot, interaction, safe areas, audio, haptics, performance, and local saves.
- [ ] We have a current green/understood validation baseline rather than historical phase claims alone.
- [ ] We have separated active architecture from legacy compatibility scaffolding.
- [ ] We have a confirmed product positioning and commercial interpretation of “premium.”

Until these gates are met, the most responsible next work is **evidence collection and product decision-making**, not cosmetic changes or additional feature expansion.

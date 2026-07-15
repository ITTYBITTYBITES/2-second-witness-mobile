# Future Experience Blueprint — Two Second Witness

**Direction phase:** Core Experience Discovery
**Status:** Recommended product direction pending human/device validation. This is not a UI or feature implementation plan.

---

# Product vision

**Two Second Witness becomes the premium daily game of noticing what matters in a vanished moment.** Each visit gives the player a clear, finite Witness Brief led by an ordinary Scene Investigation moment: observe without knowing the question, make one honest call, and see the evidence return. The product earns retention through curiosity, fair reveals, private in-game mastery, and a calm offline ritual—not through competition, assessment language, or system clutter. Its companion Challenge Types refresh the act of observation, while a simple Witness Record makes the player’s history of moments feel personal and remembered.

---

# Experience pillars

## 1. A moment before a menu

The product begins with one meaningful moment to notice, not a choice architecture. Home, recommendations, Programs, and onboarding should all help the player enter a Witness Moment quickly.

## 2. Fairness is the reward contract

Every answer must have visible, understandable evidence. A correct answer is validated; a miss is transformed into a second look. The reveal is the product’s emotional center.

## 3. Scene-first witness identity

Scene Investigation defines what it means to be a witness in this product: ordinary worlds, uncertain attention, and specific evidence. Other families support and vary that identity rather than competing to define it.

## 4. Private mastery, not performance pressure

Progress means growing familiarity with the game’s moments and worlds. The product records a player’s journey without diagnosing them, comparing them publicly, or demanding an endless grind.

## 5. Calm access is part of quality

Offline/no-account access, reliable local saves, comfort controls, accessibility, and finite sessions are not support features. They make the attention ritual trustworthy and repeatable.

---

# Ideal user journey

## First launch

```text
Trust promise
→ short witness invitation
→ first Scene Investigation Witness Moment
→ evidence reveal
→ one immediate follow-up moment
→ light introduction to a personal Witness Record
→ optional discovery of companion modes
```

**Desired player conclusion:** “This is a quick game about noticing what matters, and it shows me what I missed.”

## First experience

The initial experience is not “choose a game mode.” It is a novice-friendly Scene Investigation moment with enough time, one fair question, and a precise reveal. The player should see both the tension of not knowing what matters and the trust of seeing the answer proven.

The first five minutes should establish the repeated emotional rhythm twice before presenting secondary systems as important.

## Return visit

```text
Open
→ one state-aware Witness Brief or unfinished Brief
→ immediate first moment
→ finite completion or clean exit
→ personal record updated
→ optional exploration
```

**Desired player conclusion:** “There is a fresh moment waiting for me, and I can finish it without getting pulled into a task list.”

## Long-term engagement

Over weeks/months, the player revisits familiar ordinary worlds with new compositions and questions, discovers companion variations when useful, develops in-game observation habits, and builds a private record of moments caught. The product offers novelty through fair content depth and variation—not by escalating obligation.

**Desired player conclusion:** “I know this game’s world better, but it can still surprise me.”

---

# Detailed core loop

| Stage | Product job | Player experience | Existing building blocks |
|---|---|---|---|
| **Brief** | Give one clear reason to begin now. | “Here is my moment.” | Home recommendation, Continue, Daily Witness Program, Program context. |
| **Observe** | Make attention consequential and fair. | “I should look carefully.” | Observation route, family renderers, difficulty/exposure policies, audio/haptics, accessibility. |
| **Commit** | Ask one clear witness judgment. | “This is what I saw.” | Interaction profiles/adapters, response route, family scoring. |
| **Reveal** | Return truth with proof and emotional payoff. | “Oh, there it is.” | Result contracts, family evidence views, explanations, audio. |
| **Witness Mark** | Record meaningful continuity without metric overload. | “That moment is part of my record.” | PlayerProgressService, mastery, history, rank, achievements. |
| **Continue or close** | Respect the player’s current intent. | “I can do one more or stop satisfied.” | Runtime recommendation, Program completion/resume, Home/Library routes. |

---

# Flagship experience

## Scene Investigation as the Witness Moment

Scene Investigation should be the reference experience for all product decisions because it best combines the title, the ordinary-world witness fantasy, short pressure, unknown-question attention, and evidence-first reveal.

Its five current environments already offer a content-world foundation:

- Office
- Kitchen
- Workshop
- Travel Desk
- Garden Bench

Its future value comes from making these familiar places continually worth noticing through composition, evidence relationships, question variety, fair timing, and strong reveal clarity. It does not require a separate story/economy system to become deeper.

## Supporting families

Spot the Difference should be the most prominent companion because its before/after logic is immediately understandable and visually communicable. Object Recall, Flash Words, and Pattern Recall remain valuable variations, but their role should be determined by player preference, accessibility, and the need to refresh the flagship routine.

No current family should be removed or expanded on ideology alone. The hierarchy must be tested against actual use.

---

# Existing-system direction matrix

| Existing system | Does it strengthen the core? | Current risk/distraction | Direction before implementation | Future potential it unlocks |
|---|---|---|---|---|
| **Challenge Types** | Yes: five distinct attention decisions keep the game from becoming one repetitive mechanic. | Equal early prominence can make the product feel like an unexplained mini-game collection. | Establish Scene Investigation as the working flagship; give each companion an evidence-backed role. | A coherent portfolio with purposeful variety rather than endless mode expansion. |
| **Templates** | Yes: templates are the real balancing/content unit and already express distinct decisions. | Players may not perceive internal template variety; adding templates can become content quantity without freshness. | Keep only player-distinct template intent central; validate 5/20/50-round perceived variety before expansion. | Thematic daily briefs and richer scene-world variation without new runtime work. |
| **Programs** | Yes: finite runs, resume, focus tags, favorites, and mixed rotation can organize a session. | Nine Program labels can become a taxonomy a player has to choose between. | Use one clear current Witness Brief as the primary ritual; keep other policies as secondary curation until proven useful. | Personalized/focused runs without alternate gameplay paths. |
| **Progression** | Yes: private history, mastery, ranks, and favorites give moments continuity. | Level, rank, streak, achievements, collections, and program records currently compete for meaning. | Center one understandable Witness Record; make other signals supporting/optional. | Long-term relationship based on remembered play, not a new reward economy. |
| **Recommendations** | Yes: the system already knows first-play, continue, feature, catalog, and next-round states. | Play Now, featured, daily, Continue, and Home wording have overlapping semantics. | Converge on one truthful state-aware primary proposition. | A low-friction ritual that adapts without making the player configure it. |
| **Accessibility / comfort** | Yes: it makes the fairness promise available to more players. | Source-level support without device validation can create false confidence; complex controls can be invisible when needed. | Preserve as core fairness infrastructure and validate each family/interactions physically. | Broader audience and credible fair-play differentiation. |
| **Offline / local trust systems** | Yes: no account/ads/network dependency supports a calm immediate ritual. | Local-only progress and privacy promises have not been tested for player expectation or real migration behavior. | Preserve the stance; establish the player-facing continuity/trust contract. | Premium trust differentiation and low-friction return. |
| **Content architecture** | Yes: family-owned generator/validator/policies/assets and generic runtime are a major strength. | Dormant Foundation-era ExperienceRegistry/Flashword path obscures the actual extension model. | Preserve the Challenge Family architecture; classify legacy paths through a compatibility audit. | New content/world depth with limited platform risk. |
| **Results / feedback** | Yes: evidence reveals are the central magic moment and fairness contract. | Scores, achievements, progress, and multiple exit choices can compete with the reveal. | Elevate reveal meaning; keep metrics/next actions subordinate to the resolved moment. | Stronger replay, trust, explainability, and potentially shareable proof. |

# Systems to preserve

| System | Why preserve it |
|---|---|
| **Challenge Family / Template / Instance contracts** | They make content and mechanics extensible without product fragmentation. |
| **ChallengeSessionService lifecycle** | It is the single safe authority for tutorials, generation, results, progress, and return. |
| **Seeded generation, validation, fallback, anti-repeat logic** | These are the operational basis of the fair-replay promise. |
| **Family-owned scoring, renderers, tutorials, policies** | They preserve mechanical identity while keeping shared infrastructure generic. |
| **Evidence-first result contracts** | They are the core emotional/product differentiator. |
| **Interaction adapter architecture** | It supports future mechanics without leaking scoring into shared UI. |
| **Local Profile/Witness Progress and atomic saves** | They create a personal record and protect player trust. |
| **Recommendation/Program infrastructure** | It can deliver a simple state-aware brief without parallel gameplay paths. |
| **Accessibility, theme, responsive, audio/haptic infrastructure** | Fairness and premium feel depend on them. |
| **Offline/no-account posture** | It is a strategic and experiential strength. |

---

# Systems to transform

| Existing system | Directional transformation needed | Why |
|---|---|---|
| **Home / recommendation presentation** | Resolve one truthful current proposition: first learning moment, unfinished brief, or today’s brief. | Existing recommendation semantics overlap. |
| **Daily feature and Daily Witness Program** | Define one coherent daily ritual rather than parallel daily labels. | “Today” must mean something real to the player. |
| **Onboarding/tutorial orchestration** | Define one intentional first-session flow and the role of family tutorials. | Current title logic and documents disagree. |
| **Programs** | Use only those that express a player-understood session intent; keep generic policy machinery. | Nine visible Program types may exceed current product clarity. |
| **Progression presentation** | Center a simple Witness Record; make ranks/mastery/history/achievements supporting evidence. | Current data is broad but player meaning is unproven. |
| **Portfolio presentation** | Establish Scene Investigation as flagship and companion roles for the other four. | Equal catalog treatment obscures identity. |
| **Marketing/trailer relationship** | Align first-minute gameplay promise with witness/scene play, or clearly treat thriller material as atmosphere. | Current cinematic framing and gameplay tone diverge. |
| **Verification governance** | Reconcile current source, Home V2 artifacts, Android renderer expectation, and frozen baselines. | Product direction needs a trusted runnable baseline. |

---

# Systems to remove, retire, or stop treating as core

| System/assumption | Direction |
|---|---|
| **Foundation-era ExperienceRegistry / old Flashword model** | Retire from active product thinking after a compatibility/migration audit; do not use it as the extension model. |
| **Duplicate tutorial paths without distinct purpose** | Remove the product ambiguity, whether or not the underlying generic tutorial host remains. |
| **Multiple competing daily/recommendation labels** | Converge conceptually on one player-understood current brief. |
| **Achievement/collection dashboard prominence** | Keep data but stop treating quantity of counters as the central retention plan. |
| **Equal first-session prominence for five modes** | Establish the flagship before presenting the portfolio. |
| **Assessment language and implied personal diagnosis** | Remove from all player-facing/product-direction material. |
| **Competition, economy, and pressure loops** | Exclude from the current direction. |
| **New-family expansion as the default next milestone** | Defer until existing families prove the product core. |

---

# Validation gates for this blueprint

This blueprint becomes implementation-ready only when research confirms:

1. Scene Investigation is at least competitive as the flagship on clarity, fairness, replay, identity, and accessibility.
2. The evidence reveal produces the intended discovery response.
3. A first-session flow reaches the core moment quickly and is understood without coaching.
4. A daily Witness Brief is meaningful to players, not just technically date-based.
5. Progression signals have a clear player interpretation.
6. Companion modes have evidence-backed roles.
7. Current Android/device/accessibility/release gates pass.
8. Current verification baseline and product documentation accurately describe the runnable product.

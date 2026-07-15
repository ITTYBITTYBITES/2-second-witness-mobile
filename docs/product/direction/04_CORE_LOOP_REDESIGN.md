# Core Loop Redesign — Two Second Witness

**Direction phase:** Core Experience Discovery
**Scope:** recommended future product loop. This is an experience model, not a screen specification or implementation ticket.

---

# 1. Current loop assessment

## Current loop

```text
Home / Library / Program
→ family + template selection
→ timed observation/presentation
→ recall/response
→ correct or missed result + evidence
→ progress / achievements / recommendation
→ Retry / Next / Library / Home
```

## What is already strong

- The runtime reliably moves a player through a complete challenge lifecycle.
- Each family owns its gameplay truth and scoring.
- The response is followed by an evidence reveal, not only a score.
- Progress and recommendation are persisted consistently.
- Multiple entry points all use the same session authority.

## Current loop weaknesses

| Loop stage | Weakness | Product consequence |
|---|---|---|
| **Entry** | Home, Library, Programs, Continue, daily feature, favorites, and profile surfaces expose several valid paths before the product’s core purpose is proven. | The player may choose a system instead of entering a moment. |
| **Promise** | “Today,” “Play Now,” balanced recommendation, daily feature, and accuracy streaks have overlapping but different meanings. | The product’s return proposition is unclear. |
| **First play** | Title/onboarding/family tutorial behavior is not described consistently across source and docs. | The first session can feel more procedural than inevitable. |
| **Challenge identity** | Five families are structurally different but can appear as equal catalog choices before a player understands the witness fantasy. | Breadth can obscure the core. |
| **Reward** | Result evidence is excellent, but it competes with score, progress, achievements, Program status, and four exit choices. | The strongest emotional reward may not be the most prominent product meaning. |
| **Progression** | There are many persisted signals: level, rank, family mastery, streaks, favorites, history, achievements, collections, Programs. | A player may see counters without knowing what personal progress means. |
| **Return** | The next recommendation is technically available, but no evidence proves why a player returns tomorrow rather than simply replaying now. | The product may create sessions but not a ritual. |

---

# 2. Recommended future core loop

## The Witness Moment loop

```text
ONE CLEAR BRIEF
→ OBSERVE A MOMENT
→ COMMIT TO WHAT MATTERED
→ SEE THE EVIDENCE
→ RECEIVE A PRIVATE WITNESS MARK
→ CHOOSE ONE CLEAR CONTINUATION
```

This is the recommended organizing loop for every product surface.

### 1. One clear brief

The app gives the player one understandable proposition: a moment is ready to be noticed. The brief establishes a small scene/world context but does not over-explain or ask the player to manage mode, difficulty, or a program taxonomy.

**Player feeling:** “I know what I am here to do.”

### 2. Observe a moment

The observation surface is the product’s center. It should be uncluttered, timed fairly for the player state, and visually distinctive enough to make the moment feel worth noticing.

**Player feeling:** “Something in this ordinary moment may matter.”

### 3. Commit to what mattered

The response asks for one clear judgment. The player is not asked to prove ability; they are asked to make a witness call.

**Player feeling:** “This is my best read.”

### 4. See the evidence

Truth returns in a visual, legible, concise reveal. This phase must explain both success and misses.

**Player feeling:** “That is exactly what happened.”

### 5. Receive a private Witness Mark

The reward is primarily recognition and continuity: the moment becomes part of the player’s Witness Record, with a small understandable progress signal. It is not a currency, a barrage of achievements, or a claim about real-world cognition.

**Player feeling:** “The game remembers that moment.”

### 6. Choose one clear continuation

The product should know the dominant next intent for the player’s current state: continue a finite brief, try another Witness Moment, or stop cleanly. Other routes remain available but should not compete with the immediate emotional resolution.

**Player feeling:** “I know what is next, and I can leave satisfied.”

---

# 3. First-session loop: first five minutes

## Goal

In five minutes, a new player should have experienced the product’s promise at least twice, understood that misses are fair, and formed an accurate mental model of the app—without studying a catalog or dashboard.

## Recommended sequence

| Moment | Desired experience outcome | Existing building blocks |
|---|---|---|
| **1. Trust handoff** | Player understands: no account, local/offline play, one moment is ready. Legal acknowledgment remains required but should not become the product’s dominant first memory. | Privacy modal, title screen, local profile/settings. |
| **2. One-sentence witness invitation** | Player understands that a scene will disappear and a detail may matter. | Family tutorial host and Scene Investigation tutorial. |
| **3. First novice-friendly Scene Investigation** | Player observes, answers, and sees a precise reveal. | Scene family, difficulty/exposure policy, observation/response/result routes. |
| **4. Result reflection** | Player experiences the evidence as the reward, whether correct or missed. | Current evidence reveal and result contracts. |
| **5. Second Witness Moment** | Player immediately tests the lesson once more; this is where “I want to do that again” can emerge. | Runtime continuation / next recommendation. |
| **6. Introduce the personal record lightly** | Player sees that moments are remembered and that there is a finite next return opportunity. | PlayerProgressService, history, mastery, Daily Witness Program. |
| **7. Optional discovery** | Only after the core is understood, the player can discover companion modes and Library. | Generic Challenge Library, tutorials, favorites. |

## First-session constraints

- Do not make the player choose among five families before they have played the flagship.
- Do not teach a generic onboarding plus a redundant family tutorial without a clear distinction.
- Do not lead with ranks, achievements, collections, or a long Program list.
- Do not use a failure as the first proof of product value; a fair success is the most reliable initial lesson, while a fair miss must be safe and revealing.
- Do not promise a story/investigation that the first playable moment cannot fulfill.

---

# 4. Daily loop: returning-player ritual

## Desired opening question

> “What is today’s witness moment?”

## Recommended returning loop

```text
Open app
→ see one current Witness Brief or an unfinished brief
→ enter its first moment immediately
→ complete a short finite arc
→ receive evidence + a simple record update
→ leave satisfied or continue by choice
```

## What a Daily Witness Brief should mean

A daily brief should be a coherent small session, not a generic Play Now call carrying a daily label. It may use the existing Daily Witness Program and recommendation service, but it needs a product definition:

- finite enough to complete in a few minutes;
- fresh enough to be worth opening today;
- led by a Scene Investigation Witness Moment;
- varied only when variation serves curiosity, accessibility, or a clear theme;
- resumable when unfinished;
- complete without punishment when skipped.

The current daily feature, daily Program, Program context, content tags, seeded generation, and local date support are useful building blocks. Whether a daily brief should contain one, two, or three moments is a research decision, not an assumption to ship.

## Returning states the app should resolve automatically

| Player state | Automatic product decision |
|---|---|
| New/first-time | Start the flagship learning moment. |
| Unfinished Witness Brief | Offer/resume that brief as the primary action. |
| Returning after a completed brief | Offer today’s fresh brief. |
| Player with a clear preferred companion mode | Use preference only when it improves the next moment, not merely to mirror history. |
| Player using accessibility/comfort settings | Resolve timing, interaction, and presentation without making them reconfigure the session. |
| Player who wants browsing | Make Library available as a deliberate secondary choice. |

---

# 5. Mastery loop: weeks and months

## The mastery promise

The product should invite the player to become more familiar with how to notice **within Two Second Witness**. It should not claim general cognitive improvement.

## Recommended mastery loop

```text
Repeated Witness Moments
→ encounter richer scene worlds / distinct evidence situations
→ recognize personal in-game familiarity and mastery
→ receive fair adaptation and meaningful variation
→ build a private Witness Record
→ return for the next unresolved/fresh moment
```

## What long-term mastery should feel like

- “I scan scenes differently now.”
- “I recognize this environment, but the question still surprises me.”
- “I can handle a richer moment because I understand how the game is fair.”
- “My record reflects moments I actually experienced.”

## Existing systems that can support it

- Per-family mastery and confidence.
- Difficulty and exposure policies.
- Scene templates/object pools/question categories.
- Recent-signature avoidance.
- Personal history and favorites.
- Programs with finite runs.
- Achievements as optional recognition.
- Rank thresholds and progress points.

## What must not become the mastery loop

- Grinding the same content for raw numbers.
- Speed pressure as the only definition of expertise.
- Opaque rank gates.
- A large collection checklist detached from witness moments.
- Competitive ranking or shame after a break.

---

# 6. Core loop design rules

Every future product decision should preserve these rules:

1. **The next Witness Moment is more important than the next menu choice.**
2. **The reveal is the reward; points are secondary context.**
3. **A miss is an invitation to see again, never a verdict.**
4. **One primary action is enough for the current state.**
5. **Variation must refresh observation, not create taxonomy burden.**
6. **Progress must be understandable as a record of play.**
7. **The player may leave after a finite satisfying unit.**
8. **Accessibility is part of fair observation, not an optional afterthought.**

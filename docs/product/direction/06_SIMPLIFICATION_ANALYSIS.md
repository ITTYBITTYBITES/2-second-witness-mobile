# Simplification Analysis — Two Second Witness

**Direction phase:** Core Experience Discovery
**Goal:** reduce cognitive and decision burden around the product without weakening the underlying runtime, content, accessibility, or player agency.

---

# Simplification principle

> **The app should make the player think about the moment, never about managing the app.**

The player’s attention is the product’s scarce resource. Every unnecessary choice made before observation weakens the value of the actual challenge.

---

# 1. What users should never have to think about

| User burden | Why it is unnecessary | Direction |
|---|---|---|
| Which of five modes is “correct” for a first session | The player cannot make an informed choice before understanding the witness loop. | The product should establish the flagship automatically. |
| Which Program type they should choose to have a meaningful session | Programs are implementation/curation structures, not a first-time player mental model. | The primary ritual should be self-explanatory; other programs are optional discovery. |
| Whether “Play Now,” “Today,” “Featured,” and “Continue” mean different things | Current recommendation systems have overlapping semantics. | One state-aware primary proposition should resolve the ambiguity. |
| How difficulty, exposure, seed, fallback, or accessibility mode are resolved | These are runtime fairness responsibilities. | Keep automatic policy resolution; surface only meaningful player controls. |
| Whether a miss was due to a hidden rule | This directly violates the core promise. | The reveal must answer it immediately. |
| Which statistics deserve attention after every round | Score, rank, mastery, achievements, history, Program state, and collections can compete. | The result should first resolve the moment; broader record is optional. |
| How to preserve their progress | Local persistence/recovery should be invisible until help is needed. | Preserve existing save safety and plain-language trust messaging. |

---

# 2. Decisions the app should make automatically

## Primary next action

The app should choose the primary next action from the player’s state:

1. New player: flagship learning Witness Moment.
2. Unfinished finite brief: resume it.
3. Returning player: today’s fresh Witness Brief.
4. Completed brief: a clear optional next moment or clean stopping point.

This is a product decision model. The existing `RecommendationService`, `ProgramService`, Continue logic, and runtime entry points already make it technically feasible.

## Challenge preparation

The app should continue to automatically decide:

- family/template selection where the player has not intentionally chosen one;
- difficulty axes and exposure timing;
- validation/retry/fallback;
- recent-repeat prevention;
- accessibility-compatible interaction and timing behavior;
- progress recording and recommendation refresh.

These are existing runtime strengths. They should remain invisible unless a player asks for a specific setting or chooses to browse.

## Session structure

The app should decide what constitutes a finite current session. The player should not have to infer whether a Program, daily feature, recent challenge, and Home card are competing session concepts.

## Background recognition

Achievements, collection counters, detailed history, and secondary stats should be calculated and retained automatically. They do not all need equal player-facing prominence.

---

# 3. Features better hidden, deferred, or made secondary

This section identifies visibility/role changes, not an instruction to delete useful infrastructure.

| System/feature | Recommended product role | Reason |
|---|---|---|
| **Full Challenge Library** | Secondary discovery destination after the core loop is understood. | Valuable choice, but not the starting question. |
| **Nine Programs as a set** | Secondary/advanced curation system; foreground only the one current meaningful brief. | Most players should not have to choose among program taxonomies. |
| **Detailed Profile stats** | Reflective record, not a pre-play dashboard. | Stats should explain a relationship after moments are experienced. |
| **26-achievement catalog** | Optional recognition/collection surface. | Achievement quantity can distract from fair reveals and meaningful mastery. |
| **Collections counters** | Background evidence of discovery until a player shows interest. | Current collections are derived counters, not a core reward economy. |
| **Favorites** | Optional personalization after meaningful family discovery. | A player needs exposure before preferences are useful. |
| **Advanced companion families** | Discovery/rotation after the flagship is established. | Equal first-session prominence weakens identity. |
| **Legacy ExperienceRegistry/content model** | Compatibility-only until an explicit architecture decision. | It is not part of active play and confuses the true extension path. |
| **Trailer-only thriller framing** | Brand atmosphere unless playable content validates it. | Product promise must be deliverable in the first minute. |

---

# 4. Features that should become more prominent

| Existing strength | Why it deserves prominence | Directional expression |
|---|---|---|
| **One current Witness Moment** | It is the core reason to open the app. | Make it the dominant state-aware proposition. |
| **The observation surface** | This is where the product becomes distinct. | Protect it from dashboard/chrome distraction. |
| **Evidence reveal** | It delivers the fairness/magic moment. | Treat it as the primary result reward for success and miss. |
| **A finite daily brief** | It can convert short rounds into a return ritual. | Give it one clear meaning, completion state, and resume behavior. |
| **Witness Record** | It can make persistence emotionally meaningful. | Show a simple personal continuity signal rather than every statistic. |
| **Offline/no-account promise** | It lowers friction and differentiates the product. | Explain it plainly at the appropriate trust moment. |
| **Accessibility/comfort controls** | They protect the fairness promise. | Make them reliable, understandable, and available without stigma. |

---

# 5. Systems to simplify conceptually

## Recommendation language

Current systems expose Play Now, Continue, featured type, daily Program, catalog recommendations, and next recommendations. The product should converge on a simple language model:

- **Now:** the current Witness Moment/Brief.
- **Resume:** an unfinished meaningful unit.
- **Explore:** optional Library/companion modes.
- **Record:** optional reflection on the relationship so far.

The technical services can stay broad. The player should not need to learn their internal distinctions.

## Progression language

Current progression contains levels, ranks, family mastery, confidence, progress points, accuracy, current/best streaks, achievements, collections, recent history, favorites, and Program records.

The player-facing hierarchy should answer in order:

1. What moment did I just witness?
2. What should I do now?
3. What part of this game am I becoming familiar with?
4. Where can I explore further?

Anything that does not answer one of those questions is background data or an optional record.

## Portfolio language

A player should understand the product as one game with variations, not as five unrelated “experiences.” The internal generic architecture remains correct; the player-facing product must decide whether companion modes are named as methods, places, briefs, or challenge types only after flagship research.

---

# 6. Things to remove from the future product direction

These are product-direction removals or explicit exclusions. They do not require immediate code deletion.

1. **The idea that more visible options equals more value.**
2. **Duplicate first-session teaching paths without distinct purpose.**
3. **A Home that uses daily language for a non-daily recommendation.**
4. **Equal first-session treatment for every family before the witness core is understood.**
5. **Progress dashboards that outrank the evidence reveal.**
6. **Assessment-oriented terminology, comments, docs, or marketing claims that can leak into player language.**
7. **Trailer claims that imply an interactive narrative absent from first-session play.**
8. **Competition/economy/pressure systems as substitutes for curiosity.**
9. **Legacy extension paths presented as active architecture.**
10. **Feature expansion as a response to unclear retention.**

---

# Simplification success test

A first-time or returning player should be able to answer, without help:

- What is the one thing I can do now?
- Why is this moment worth noticing?
- What did I get right or miss?
- What should I do next, if I want to continue?
- Where can I go if I want more choice?

If any answer requires explaining a Program taxonomy, profile metric, recommendation algorithm, or five-family architecture, the product is asking the player to manage complexity that the app should manage for them.

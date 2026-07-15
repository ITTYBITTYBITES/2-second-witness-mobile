# Witness Moment Design Specification

**Flagship:** Scene Investigation
**Purpose:** define the canonical observation experience that gives Two Second Witness its identity.

---

# 1. Definition

A **Witness Moment** is a short Scene Investigation round in which the player studies an ordinary, composed scene without knowing the question, commits to one answer after the scene disappears, then receives visual proof of the relevant evidence.

```text
Brief → Observe → Memory Beat → Question → Witness Call → Evidence Reveal → Record → Return
```

The player is not solving a riddle hidden in a noisy image. They are learning that attentive looking at an ordinary moment can be rewarding.

---

# 2. Timing contract: what “Two Second” means

## Product decision

**Two seconds is the signature standard rhythm, not a universal rule that overrides fairness.**

A mature standard Witness Moment should make the player feel the distinctive pressure of a two-second observation. First-session, accessibility, and difficulty policies may use longer exposures. Advanced exposure may be shorter only when scene complexity and question demand remain fair.

| Context | Recommended base exposure | Why |
|---|---:|---|
| First witnessed scene | 4.0 s | Teach scene grammar and fairness; establish success confidence. |
| First-session follow-up | 3.0 s | Introduce urgency without turning the lesson into a speed test. |
| Familiar / standard Witness Moment | 2.0 s | Deliver the product’s signature title promise. |
| Advanced mastery | 1.6–2.0 s | Increase pressure only with controlled scene/question complexity. |
| Comfortable Timing | Base exposure × existing accommodation policy | Preserve equivalent progress and remove unnecessary time pressure. |

The current Scene Investigation exposure policy, independent difficulty axes, and Comfortable Timing setting are reusable. The product change is to make the timing meaning explicit and honest.

---

# 3. Canonical round sequence

## A. Brief — 0.5–0.9 seconds

**What the player sees:** a quiet scene identity, such as Office, Kitchen, Workshop, Travel Desk, or Garden Bench. No target or question is disclosed.

**Player decision:** none.

**Purpose:** orient the player in an ordinary place, not a fictional case narrative. The brief should make the player think, “I am about to witness this moment.”

**Rule:** do not show a target icon, highlighted area, or target category. The unknown question is essential to broad observation.

## B. Observe — signature 2 seconds at standard

**What the player sees:** the entire composed scene, a restrained countdown/progress cue, and no distracting chrome.

**Player decision:** scan the full scene. A player may use any personal strategy, but the scene composition should reward a broad macro-to-micro sweep.

**Purpose:** create active attention. The player does not know which evidence will matter.

**Rule:** the timer communicates urgency but does not become the focal object. It must never obstruct a question-eligible item.

## C. Memory beat — 250–400 ms

**What the player sees:** scene concealment and a neutral, calm transition.

**Player decision:** retain the scene mentally.

**Purpose:** create a clean boundary between seeing and recalling. It should feel like the moment has passed, not like the app has stalled.

**Rule:** Reduced Motion replaces decorative transition with an immediate stable state; mechanically necessary timing remains legible.

## D. Question — one clear prompt

**What the player sees:** one factual question and clearly distinct response choices.

**Player decision:** make a witness call based on memory, not wishful guessing.

**Purpose:** turn general observation into one specific, understandable claim.

**Rule:** one question per flagship moment. No multi-question quiz after a single observation.

## E. Witness call — one committed response

**What the player sees:** a clear selected answer state and brief acknowledgment that the answer is being checked.

**Player decision:** commit once.

**Purpose:** give the answer consequence without forcing a punitive confirmation flow.

**Rule:** response collection remains generic and family-owned scoring remains untouched. The product should avoid accidental selection while keeping commitment fast.

## F. Evidence reveal

**What the player sees:** scene context returns, then the exact evidence and explanation.

**Player decision:** look again, understand, and decide whether to continue.

**Purpose:** make truth visible. See the dedicated Evidence Reveal Specification.

---

# 4. Scene composition framework

## The three-zone rule

Every flagship scene should be readable as three intentional zones:

1. **Anchor zone** — a large, familiar landmark that establishes the place.
2. **Action zone** — the primary cluster of objects where most meaningful relationships can occur.
3. **Peripheral zone** — secondary evidence that rewards a complete scan without becoming a trap.

This creates a learnable visual grammar. It is not a hidden target guide; it helps players form a fair scanning habit.

## The anchor rule

Each scene needs one stable, recognizably named anchor: desk, counter, bench, work surface, travel layout, shelf, or similar ordinary structure. The anchor gives the player spatial language for memory and reveal explanation.

## Meaningful information hierarchy

| Layer | Purpose | Standard-scene expectation |
|---|---|---|
| **Primary landmarks** | Establish scene/location. | 1–2 large, instantly readable forms. |
| **Question-eligible objects** | Supply fair possible questions. | 8–12 at standard; fewer for first session. |
| **Relationship groups** | Enable adjacency, container, position, and count questions. | 2–4 clearly separated clusters. |
| **Decorative context** | Make the scene feel lived-in without carrying answer truth. | Restrained; never conceals targets unfairly. |
| **Visual noise** | Adds atmosphere only. | Must never be mistaken for evidence or obscure a legal target. |

## Attention guidance without giving away the target

The product should not point at the answer during observation. It should guide attention through scene grammar:

- clear visual zones and anchor surfaces;
- predictable object scale hierarchy;
- readable contrast between objects and background;
- meaningful grouping rather than random scatter;
- familiar object silhouettes and player-readable naming;
- enough empty space around important relationships;
- a post-reveal explanation that models a broad scan strategy.

The player learns to observe because the reveal repeatedly makes the scene’s structure legible—not because the game overlays a tutorial arrow on the answer.

---

# 5. Information density and difficulty progression

## Difficulty must move one principal axis at a time

A Witness Moment becomes unfair when multiple burden axes spike together. The runtime already supports multi-axis difficulty; flagship tuning should deliberately constrain combinations.

| Axis | Beginner | Standard | Advanced | Expert |
|---|---|---|---|---|
| Question-eligible objects | 6–8 | 8–12 | 12–16 | 16–20 |
| Decorative density | Minimal | Light | Moderate | Moderate, never visual fog |
| Target scale | Large/readable | Normal | Smaller but distinct | Small only with high contrast/context |
| Object similarity | Clearly different | Some plausible similarity | One meaningful similarity group | High similarity only when answer remains unambiguous |
| Relationship depth | Direct presence/count | Direct position/attribute | One relationship | Precise relationship with protected readability |
| Exposure | 4.0–3.0 s | 2.0 s | 2.0–1.8 s | 1.6–2.0 s |

**Constraint:** Do not simultaneously shorten exposure, increase clutter, shrink the target, and increase similarity. Change one primary demand and, at most, one supporting demand between adjacent difficulty steps.

## How the player learns to observe

The game should teach an in-game observation practice over repeated reveals:

1. **First moments:** notice large anchors and obvious relationships.
2. **Early familiarity:** scan left/center/right or foreground/background zones.
3. **Standard rhythm:** recognize object groups, count sets, and relation cues.
4. **Advanced play:** distinguish similar objects/states while retaining scene structure.
5. **Expert play:** make efficient broad scans, not frantic single-target searches.

This is a game-specific literacy. It must never be framed as a diagnostic of the player’s real-world ability.

---

# 6. Fairness requirements

A scene may be beautiful, dense, and surprising. It cannot be unfair.

## A question-eligible detail must be

- fully visible during the observation interval;
- inside safe readable scene bounds;
- visually separable from its background and neighboring objects;
- large enough for the declared difficulty;
- named in player-language the art clearly supports;
- stable across animation and rendering modes;
- answerable without relying on color alone, tiny text, specialized knowledge, or hidden occlusion;
- represented by a precise reveal target and factual explanation.

## A scene must never require

- reading microscopic labels, numbers, or brand names;
- detecting a one-pixel/near-invisible state change;
- guessing an unfamiliar object’s name from ambiguous art;
- choosing among semantically duplicate answers;
- remembering details outside the visible crop/safe region;
- color discrimination without shape, label, luminance, or other redundant cues;
- a fast motor action during the observation phase.

## Question acceptance gate

Before a flagship scene/question combination ships, it must pass:

1. generator/validator acceptance;
2. evidence-target/reveal acceptance;
3. contrast, scale, and safe-area review;
4. accessibility mode review;
5. first-time player fairness review at its declared tier;
6. no-consecutive-repeat/runtime signature check.

---

# 7. Question design

## Preferred question categories

| Category | Good flagship use | Example grammar |
|---|---|---|
| Presence | Early teaching, clear first success. | “Which object was on the desk?” |
| Count | Use small, visually grouped sets. | “How many pencils were beside the notebook?” |
| Attribute | Use a single unambiguous visible attribute. | “What color was the folder near the mug?” |
| Position | Tie to a stable anchor. | “Where was the ruler relative to the notebook?” |
| Adjacency | Require one readable relation. | “What was beside the mug?” |
| Container/region | Use clear boundaries and labels. | “Which item was inside the tray?” |

## Prompt rules

- Ask one fact.
- Use the nouns supported by visible art.
- Name stable anchors when a relationship matters.
- Avoid trick wording, double negatives, and “all of the above.”
- Keep options mutually distinct and plausibly related to the scene.
- Never reveal the target category before observation in a standard Witness Moment.

The generated scene truth graph and family validator already provide the technical basis for these rules.

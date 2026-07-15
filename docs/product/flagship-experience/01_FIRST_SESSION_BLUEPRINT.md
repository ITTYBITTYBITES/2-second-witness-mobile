# First Session Blueprint — The First Witness Moment

**Product direction:** Scene Investigation is the flagship.
**Session objective:** In the first five minutes, a player should understand the promise, experience a fair reveal, and choose a second Witness Moment voluntarily.

---

# First-session rule

The first session is not an onboarding funnel, a catalog tour, or a profile setup flow.

It is a carefully protected proof of one idea:

> **A brief ordinary moment can contain a detail worth noticing, and Two Second Witness will always show you the truth.**

The first meaningful interaction must reach that proof before asking the player to interpret modes, Programs, ranks, achievements, or collections.

---

# Complete first-time journey

| Step | User expectation | Desired emotion | Design goal | Current implementation gap |
|---|---|---|---|---|
| **1. App launch** | “What is this app, and can I start?” | Calm curiosity. | Establish a premium witness identity quickly; avoid a long preamble. | The current sequence includes system splash, publisher splash, title/loading, privacy, and potentially an intro tutorial. Actual physical timing/first frame is unverified. |
| **2. First emotional hook** | “Why should I pay attention?” | Intrigue. | Communicate one promise: a fleeting moment will matter. Use witness language, not assessment or generic puzzle language. | Current branding has an eye/witness motif, but trailer, title, Home, and playable scenes do not yet make one consistently tested promise. |
| **3. Trust and consent** | “What do you need from me?” | Safety and low friction. | State: no account, local progress, play offline. Consent remains clear but should not become the player’s dominant first memory. | Privacy modal is implemented, but policy/browser behavior and first-session comprehension have not been researched on devices. |
| **4. One-line explanation** | “What am I about to do?” | Readiness, not instruction overload. | Explain only the contract: *Study the moment. It will disappear. One detail will matter.* | Current flow can combine title intro logic and family tutorial gating; their distinct purposes are not yet defined. |
| **5. First observation** | “I should look carefully.” | Focused tension. | Show a novice-friendly Scene Investigation scene with enough readable information and no revealed target. | Existing Scene Investigation supports this, but the first selected template is an implicit registry-order outcome rather than a deliberate authored first-moment contract. |
| **6. Memory challenge** | “What did I see?” | Honest commitment. | Ask one clear question with plainly distinct answers. The player makes one witness call; they are not graded on identity. | Generic Recall infrastructure is strong, but actual first-question wording, option construction, and device behavior have not been validated with users. |
| **7. Evidence reveal** | “Was I right, and why?” | Relief, surprise, discovery. | Return the full scene first, then the exact evidence. The reveal explains success and misses with equal care. | Evidence exists today, but result metrics, achievements, multiple actions, and inconsistent visual treatment can compete with the reveal’s emotional role. |
| **8. Result / desire to continue** | “What happens now?” | Pride or a low-pressure desire for another look. | Offer one obvious next Witness Moment. Record the first moment lightly; make browsing optional. | Current Result exposes Retry, Next, Library, and Home, while Home/Program semantics overlap. No data identifies the dominant post-result intent. |

---

# First five minutes: recommended sequence

## 0:00–0:10 — The promise

The player reaches a short witness invitation as soon as platform/legal requirements permit:

> **One moment. One detail. Did you catch it?**

The brand should establish atmosphere, but the player should not be asked to decode story, rank, catalog, or mode selection.

## 0:10–0:25 — The contract

One concise explanation is enough:

> **Study the scene. It disappears before the question. We will show you the evidence.**

This is the only universal tutorial statement. It teaches the emotional contract, not a list of controls.

## 0:25–1:15 — First Witness Moment

Use an authored, novice-safe Scene Investigation instance:

- a familiar current setting such as Office or Kitchen;
- three clearly readable visual zones;
- a small number of meaningful objects;
- one target that is visible, distinct, and not color-only;
- a single question that tests a broad, fair observation rather than a tiny detail;
- a generous first exposure (recommended **4 seconds** before any accessibility multiplier).

The player should have a strong chance of success, but a miss must still be understandable when the evidence returns.

## 1:15–1:35 — The proof

The result does not begin with score/XP. It returns the scene, identifies the evidence, and gives a factual one-line explanation. The player sees what made the answer true.

First success language should recognize observation:

> **You caught it. The blue folder was beside the mug.**

First miss language should preserve dignity:

> **A detail escaped you. The blue folder was beside the mug.**

These are directional copy examples, not final UI strings.

## 1:35–2:30 — Second Witness Moment

Immediately offer a second scene with one new observation demand—for example a simple spatial relationship after a first presence/count question. This is where the player applies the lesson rather than merely completing a tutorial.

The second exposure can move toward the product’s signature pace (recommended **3 seconds** for a first-session follow-up), but should not stack shorter timing, more clutter, and more similar distractors at once.

## 2:30–3:30 — First brief closure

After two successful/fairly revealed moments, the player sees a light continuity signal:

- their first Witness Moment is recorded;
- the current brief has a clear finite state;
- a future fresh moment exists without punishing a player for stopping.

Do not foreground a rank, 26 achievements, collection counters, or a large profile at this point.

## 3:30–5:00 — Optional third moment or discovery

The player may take one more flagship moment or choose to explore. Only now should the product introduce the existence of companion modes and the Library. The first session is successful if the player can leave after two moments knowing what the app is and wanting to return.

---

# First-session product decisions

## The first scene is a product asset, not a random default

The first playable scene should be deliberately authored/configured from existing Scene Investigation content. It needs an explicit identity, content constraints, question policy, exposure policy, and accessibility review. The runtime can still generate it deterministically; the product must specify why this instance teaches the core promise.

## There should be one teaching path

The product must decide the relationship between:

- title-screen intro tutorial;
- automatic per-family tutorial;
- family practice round;
- manual tutorial replay.

The recommended direction is **one first-session witness contract plus one Scene Investigation practice moment**, then family-specific tutorials only when a player intentionally enters a companion family. The generic tutorial host and family tutorial system should be reused; duplicate conceptual teaching should not survive.

## The first session should not test speed

The first exposure does not need to be literal two-second pressure. “Two Second” should become the recognizable mature rhythm, while first-session timing teaches fairness and confidence. Comfortable Timing must preserve normal progress.

---

# First-session success criteria

A first session is successful only if research shows that players can say, in their own words:

1. “I look at a scene, it disappears, and then I answer what I noticed.”
2. “It showed me why the answer was right.”
3. “I could have caught that” after a fair miss.
4. “I would play another one.”
5. “This is not a test of whether I am smart.”

If those outcomes do not occur, the product should fix the flagship experience before adding companion content, progression, or premium visual polish.

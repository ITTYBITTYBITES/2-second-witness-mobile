# Investigation Loop Design — Observe to Return

**Flagship loop:** Scene Investigation as the Witness Moment.
**Loop purpose:** transform a brief scene into curiosity, a committed call, visible evidence, and a reason to return.

---

# Core loop

```text
Observe → Remember → Question → Investigate → Reveal → Learn → Return
```

The word **Investigate** does not mean reopening the hidden scene or adding a detective-story system. It means the player briefly interrogates their own memory: what did the scene contain, where was it, and which answer best matches the moment they witnessed.

---

# 1. Observe

## What the user sees

- A named ordinary setting with a clear anchor surface.
- The full scene and a restrained time cue.
- No question, target marker, score, or competing chrome.

## What the user decides

Nothing explicitly. They choose how to scan: broad scene structure, object groups, relationships, or memorable anchors.

## Product job

Create the sensation that the ordinary scene may contain something meaningful. The player should feel alert, not confused or rushed into visual noise.

## Why it matters

Observation is the product’s active verb. If this phase feels like passive image viewing, the later question becomes a quiz. If it feels like a fair moment of attention, the later reveal becomes discovery.

---

# 2. Remember

## What the user sees

A brief neutral concealment/memory beat. The scene is gone; no new complexity is introduced.

## What the user decides

They hold the scene’s structure in mind.

## Product job

Make the transition feel intentional: the moment has passed, and their attention now has consequences.

## Why it matters

Without a clean break, the product becomes a visual search task. The vanished scene is what makes the player a witness rather than a spotter.

---

# 3. Question

## What the user sees

One short factual question with clear, legible options. It references a stable object/anchor or asks a direct count/presence/attribute fact.

## What the user decides

What did they genuinely notice?

## Product job

Convert broad attention into one understandable claim. The question should make the player mentally revisit the scene, not decode wording.

## Question-state rule

The question is not a second tutorial. Avoid showing mastery, achievement progress, Programs, or a large profile signal here. The user should only need to understand the question and their answer.

---

# 4. Investigate

## What the user sees

Their selectable response set and, after selection, a brief committed state. The scene remains concealed.

## What the user decides

They make one witness call.

## Product job

Give the decision weight without creating anxiety. The user should feel: “This is what I saw,” not “I am about to be judged.”

## Interaction rule

- One clear response action.
- Protection from accidental tap where necessary.
- No unnecessary confirmation dialog for ordinary answers.
- Accessible target sizing, contrast, and screen-reader-hint behavior.
- Family scoring remains the authority on correctness; the shared interaction host does not interpret the answer.

---

# 5. Reveal

## What the user sees

The scene returns in context. The relevant object, count set, attribute, or relation is then made unmistakable. A concise factual explanation connects the question, response, and evidence.

## What the user decides

They decide whether they understand the moment and whether to continue.

## Product job

Make the truth more satisfying than the score. See the Evidence Reveal Specification for timing, motion, sound, and correct/miss treatment.

## Why it matters

This phase turns a potentially discouraging miss into an invitation:

> “I could have seen that. Show me another.”

---

# 6. Learn

## What the user receives

A subtle learning signal embedded in the reveal:

- scene context before highlight;
- target/relationship shown precisely;
- factual explanation using stable scene language;
- a small clue to the observation grammar when useful (for example, “near the center of the desk” or “beside the mug”).

## What the product does not do

- It does not label the player’s mental ability.
- It does not prescribe real-world self-improvement.
- It does not flood the moment with achievement unlocks or speed bonuses.
- It does not make a miss a red failure screen with no useful evidence.

## Product job

Teach the player how this game is fair and how its scenes can be read. Over time, the player develops an internal scan strategy through repeated evidence, not formal instruction overload.

---

# 7. Return

## What the user sees

One context-aware next proposition:

- continue the current Witness Brief;
- enter today’s next Witness Moment;
- or end the session cleanly.

Secondary routes remain available but should not compete with the resolved reveal.

## What the user decides

Continue because they are curious, or stop because the finite moment felt complete.

## Product job

Respect both forms of success. A player who stops after a satisfying brief should feel completion, not loss or unfinished obligation.

---

# Feedback model by outcome

| Outcome | Player should feel | Product response |
|---|---|---|
| **Correct** | “I caught it.” | Validate the exact evidence, show it in context, record the moment lightly, offer the next moment. |
| **Incorrect but close** | “I saw part of it; now I understand the missing relation/detail.” | Show chosen answer only when it helps explain the contrast, then focus on the correct evidence without shame language. |
| **Incorrect / missed** | “That was visible. I missed it.” | Return scene context before target highlight, state the fact simply, and make another attempt feel low-pressure. |
| **Exit / interruption** | “I can leave safely.” | Preserve existing progress; do not score an incomplete moment as a failure; offer resume/return according to the current brief state. |

---

# Loop health metrics

The loop is healthy when players:

- can explain Observe → Question → Reveal after one round;
- look at the evidence reveal even after a correct answer;
- describe misses as fair and specific;
- choose a second moment without needing an external reward;
- understand why the app is offering the next moment;
- stop after a finite brief without feeling punished;
- return later because they want a fresh observation moment.

The loop is unhealthy when players:

- call it a memory test or quiz;
- rush past the reveal;
- blame timing or visual ambiguity for misses;
- cannot explain the difference between Programs, Play Now, Continue, and daily content;
- chase counters without remembering the moments;
- feel pressure from streaks, ranks, or missed days.

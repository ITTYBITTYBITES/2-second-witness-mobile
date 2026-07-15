# Evidence Reveal Specification — Truth Returns

**Product role:** The reveal is the emotional reward of a Witness Moment.
**Primary player outcome:** “I understand what happened.”

---

# 1. Reveal principle

The reveal must answer the player’s real question after a response:

> **Where was the evidence, and why was that answer true?**

It must not primarily answer:

> “How many points did I get?”

Score, progress, achievements, Program state, and next actions may exist around the reveal. They cannot outrank the scene evidence itself.

---

# 2. Reveal sequence

## Recommended timing

| Beat | Suggested duration | What happens | Why |
|---|---:|---|---|
| **A. Commitment settles** | 150–250 ms | Response controls become inactive; no long suspense pause. | The player knows their answer was received. |
| **B. Context returns** | 200–350 ms | Original scene reappears unmarked, complete, and readable. | Lets the player orient and look again before being told. |
| **C. Evidence finds itself** | 500–800 ms | Highlight/outline/spotlight resolves onto the exact target or relation. | Creates the discovery beat; evidence is spatially precise. |
| **D. Explanation lands** | 800 ms onward | One factual sentence names the truth and locates it. | Turns visual proof into understanding. |
| **E. Reflection / continuation** | Player-controlled | A modest record signal and one primary next action appear. | Protects the emotional payoff and respects player agency. |

These are presentation goals, not a demand for fixed animation duration. Reduced Motion may collapse beats B–D into a stable, immediate context-plus-highlight state while preserving the same information order.

---

# 3. Visual evidence rules

## Context before annotation

Always show the original scene in full before isolating the evidence. A player should be able to re-orient themselves: *“That was the desk. That was the mug. Ah—there.”*

A highlight that appears without context feels like an answer key. A reveal that restores the scene first feels like a second chance to see.

## Precision

The evidence treatment must identify exactly what made the answer true:

| Question type | Reveal target |
|---|---|
| Presence | The named object or its clear scene location. |
| Count | Every member of the counted set, with countable grouping. |
| Attribute | The object plus the visible attribute; never color alone if an alternative cue is available. |
| Position | Object and stable anchor/region together. |
| Adjacency | Both objects and the relevant relationship. |
| Container/region | Item plus the container/region boundary. |

## Highlight language

The highlight should read as **evidence**, not as a reward explosion:

- restrained warm focus/outline or high-contrast alternative;
- clear shape/line/label redundancy, never color-only;
- no visual effect that covers the object it is meant to reveal;
- no flashing that conflicts with Reduced Motion or attention comfort;
- no pulsing timer or unrelated animation after the answer has been resolved.

The recent sprite-first scene rendering, vector fallback, scene truth graph, and existing highlight IDs are strong implementation building blocks.

---

# 4. Explanation style

## Factual, concrete, compassionate

The explanation should make one factual claim in player-readable language:

> **The blue folder was beside the mug near the center of the desk.**

It should contain:

1. the correct object/count/attribute;
2. the relevant anchor or relationship when useful;
3. no diagnostic language;
4. no unnecessary strategy lecture;
5. no vague “pay more attention” phrasing.

## Correct response treatment

Correct answers should still receive evidence. Suggested structure:

```text
You caught it.
The blue folder was beside the mug near the center of the desk.
```

The first line recognizes the moment. The second line proves it. The scene does the real work.

## Incorrect response treatment

Incorrect responses should not lead with score loss or a harsh failure label. Suggested structure:

```text
A detail escaped you.
The blue folder was beside the mug near the center of the desk.
```

If showing the selected answer clarifies the miss, use a neutral contrast:

```text
You chose: beside the notebook.
The folder was beside the mug near the center of the desk.
```

Do not show a selected answer when it adds embarrassment without teaching anything.

## Count reveal treatment

A count needs visible grouping. The player should not be told “five” while seeing one highlighted object. Highlight each relevant item or provide a clear enumerated grouping that does not obscure the scene.

---

# 5. Emotional payoff design

## Correct

**Feeling:** quiet confidence.

- A warm, restrained confirmation sound.
- Optional brief haptic tick.
- Evidence appears in full scene context.
- One small Witness Record update follows only after the truth lands.

Do not turn correctness into a casino-like cascade of coins, badges, and explosions.

## Missed

**Feeling:** surprise without shame.

- No punishing buzz or dominant red failure screen.
- A soft resolving sound distinct from a success cue but not emotionally negative.
- The scene appears before the target annotation.
- The explanation gives the player a precise second look.
- A next moment remains inviting, not remedial.

## Near miss

**Feeling:** “I had the right area, but not the right detail.”

When scoring can distinguish near-miss information without becoming opaque, explanation can compare the player’s remembered relation to the correct relation. Do not introduce artificial partial-credit complexity into a simple one-answer flagship round merely to display nuance.

---

# 6. Sound, haptics, and motion

## Sound

The current AudioService can route BGM, preloaded cues, ducking, volume/mute settings, and result sounds. The reveal should use that system with a restrained sequence:

1. observation BGM settles/ducks at conceal;
2. response commit receives a quiet confirmation;
3. reveal context returns with minimal room tone/settle;
4. evidence highlight receives one distinctive, non-alarming cue;
5. BGM returns gently after the explanation lands.

Sound must never be required to understand the answer.

## Haptics

- Optional only.
- One light acknowledgment at observation start/response or reveal—not a stack of vibrations.
- Correct and missed outcomes may differ subtly, but neither should imply punishment.
- Honor haptics-off setting immediately.

## Motion

Motion must communicate information order, not decorate the result:

- scene return;
- evidence focus;
- stable explanation;
- optional clear handoff to next action.

Reduced Motion must preserve all evidence at rest. No mechanically important truth may be conveyed only by a pulse, zoom, flicker, or color shift.

---

# 7. What appears after the reveal

The result hierarchy should be:

1. **Evidence** — scene plus target/relation.
2. **Explanation** — one factual sentence.
3. **Moment recognition** — small, private acknowledgement.
4. **One primary continuation** — current brief/next Witness Moment.
5. **Secondary choices** — retry, Library, Home, record, as appropriate.

The player should be able to leave after the evidence with the moment resolved. The product should not force them to absorb achievement, rank, collection, or Program messaging before they can close the loop.

---

# 8. Reveal acceptance checklist

A flagship reveal is ready only when:

- [ ] The full scene returns before the target is isolated.
- [ ] The highlight exactly matches generated scene truth.
- [ ] Every question category has an appropriate evidence representation.
- [ ] Explanation names the answer in visible player-language.
- [ ] Correct and missed results receive equally clear evidence.
- [ ] Color is never the only truth cue.
- [ ] High Contrast and Reduced Motion preserve the reveal’s meaning.
- [ ] Audio/haptics are optional and do not stack unexpectedly.
- [ ] The reveal remains legible on target phone sizes and with text scaling.
- [ ] Human players describe misses as fair and can point to the evidence afterward.

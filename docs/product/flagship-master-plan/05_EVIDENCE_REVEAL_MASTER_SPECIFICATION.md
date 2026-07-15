# Evidence Reveal Master Specification

**Status:** definitive standard for the flagship Scene Investigation reveal.
**Emotional objective:** the player feels, *“You discovered something,”* never, *“You failed.”*

---

# 1. Reveal purpose

The Evidence Reveal is the product’s signature moment. It resolves the player’s witness call by returning the ordinary scene and making the relevant truth visible in context.

It answers:

- What was the correct detail?
- Where was it in the scene?
- What relationship/count/attribute made it true?
- Why was the question fair?

It does not primarily answer:

- How many points did I earn?
- Did I maintain a streak?
- What badge did I unlock?
- What should I buy/unlock next?

The evidence is the reward. Progress is supporting context.

---

# 2. Information hierarchy

```text
1. Current scene context
2. Exact evidence target / relationship
3. Factual explanation
4. Calm outcome recognition
5. Small Witness Record acknowledgement
6. One primary continuation
7. Optional secondary navigation
```

Never reverse this order. A large score, achievement, Program state, or call-to-action before the player understands the evidence weakens the flagship promise.

---

# 3. Canonical reveal choreography

| Beat | Timing target | Visual behavior | Player feeling |
|---|---:|---|---|
| **Commit settles** | 150–250 ms | Answer controls rest/disable; scene remains concealed. | “My call was received.” |
| **Context returns** | 200–350 ms | Original scene returns unmarked and stable. | “Let me see that moment again.” |
| **Evidence focuses** | 500–800 ms | Relevant object(s)/relation gain restrained focus/outline/trace. | “There it is.” |
| **Explanation lands** | From ~800 ms onward | One factual line names truth and location/relationship. | “I understand what happened.” |
| **Recognition settles** | After explanation readable | Correct/missed acknowledgement and small record signal. | “I caught it” or “I see what I missed.” |
| **Continuation becomes available** | Player-controlled | One primary current-brief/next-moment action; secondary routes quiet. | “I know what I can do next.” |

These values are design targets. Device refresh rate, Reduced Motion, presentation profile, and accessibility state may alter rendering implementation but not information order.

---

# 4. Evidence representation by question type

| Question type | Required visible proof | Explanation requirement |
|---|---|---|
| Presence | Named object in its original scene position. | Name object and stable anchor/zone. |
| Count | Every counted member visible/marked as a coherent set. | State count and grouping/location. |
| Attribute | Object plus visible attribute, reinforced beyond color where needed. | Name object and attribute; point to context. |
| Position | Object and anchor/region visible together. | State relation precisely: left/right/near/on/in. |
| Adjacency | Both related objects visible, with relation legible. | Name both objects and relation. |
| Container/region | Item plus container/region boundary visibly established. | State inclusion/placement. |

No reveal may use a generic highlight that does not explain the actual answer truth.

---

# 5. Correct and missed outcome design

## Correct response

**Outcome language:** recognition, not celebration overload.

Example structure:

> **You caught it.**
>
> The blue folder was beside the mug near the center of the desk.

Requirements:

- Show evidence even when correct.
- Validate the player’s observation through scene proof.
- Use one warm, restrained confirmation cue.
- Do not obscure evidence with confetti, badge popups, or large score effects.

## Missed response

**Outcome language:** realization, not failure.

Example structure:

> **A detail escaped you.**
>
> The blue folder was beside the mug near the center of the desk.

Requirements:

- Return full context before isolating the target.
- Explain factually; avoid “wrong,” “fail,” “poor,” or judgment language as the dominant result.
- Show selected answer only when comparison teaches something.
- Do not make missed response sound/visual language punitive.
- Make next Witness Moment feel equally available.

## Near-miss policy

Do not add complex partial-credit behavior just to make results nuanced. If family scoring can identify a useful relation between a chosen and correct answer, explain it only when it clarifies the evidence. The flagship question remains one fair witness call.

---

# 6. Animation and virtual camera language

## Camera principle

The scene should not behave like a cinematic cutscene. It is evidence. Preserve the player’s ability to re-orient in the full scene before focus is applied.

### Use

- Full-scene return at original observation framing.
- A subtle focus/outline/trace around relevant evidence.
- If a relationship needs context, retain both objects/anchor in view.
- A restrained crop/reframe only after full-scene context has been available and only if it clarifies a small relation.

### Avoid

- Fast zooms into the target before the player sees the scene again.
- Camera shake, thriller jump cuts, dramatic montage, or visual punishment on a miss.
- A target effect that covers the object or hides its relation to scene anchors.
- Any movement required to understand truth under Reduced Motion.

The current scene renderer may not use a literal camera. “Camera” here means player framing and evidence focus behavior, not a requirement for a new Camera2D system.

---

# 7. Visual evidence language

## Core treatment

- Warm evidence focus against the calm scene stage.
- Shape/outline/label/contrast redundancy; never color-only.
- Code/family renderer highlights sourced from resolved scene truth.
- Context-preserving annotation: the player sees the object and why it relates to answer.
- High Contrast alternative with explicit legibility.

## Do not use

- Red/green as sole correct/missed state.
- Flashing effects, strobing, or long looping pulses.
- Random particles, loot-style shine, emoji/glyph reward spectacle.
- Tiny labels, hidden arrows, or overlays that cover evidence.
- “Evidence board”/crime-wall visual language.

---

# 8. Typography and copy

## Typography hierarchy

1. Scene evidence remains visual hero.
2. Explanation is readable at normal and scaled text sizes.
3. Outcome line is short and secondary to factual proof.
4. Record/achievement/program copy is tertiary.
5. Continuation action is clear only after explanation has landed.

## Copy rules

- Use visible nouns and stable anchors.
- State one fact in plain language.
- No assessment, diagnostic, IQ, or brain-training language.
- No overdramatic detective/story claims.
- No vague “pay attention” advice.
- No score-first sentence.

Good: “There were three pencils beside the notebook.”
Bad: “Your visual memory score was insufficient.”

---

# 9. Sound and haptics

## Sound sequence

1. Observation BGM/ambience settles at conceal.
2. Answer commitment gets a small neutral acknowledgement.
3. Context return remains quiet enough for visual attention.
4. Evidence focus has one distinctive resolving cue.
5. Correct may add a warm confirmation layer; missed uses a neutral resolution layer.
6. BGM returns gently after truth lands.

## Haptic sequence

- Optional only.
- One subtle acknowledgment at a meaningful state, not a stack of pulses.
- Correct/missed distinction may be gentle but never reads as reward versus punishment.
- Disabled haptics preserve all meaning.

The existing AudioService, AccessibilityService, settings, and bus/mute controls are required foundations; do not create a parallel feedback framework.

---

# 10. Accessibility equivalence

| Setting/state | Reveal requirement |
|---|---|
| Reduced Motion | Stable context plus clear evidence; no truth hidden in motion sequence. |
| High Contrast | Target/anchor/annotation remain separable and readable. |
| Color Assistance | Evidence has non-color cues; current family color policy remains honored. |
| Text scaling | Explanation and action remain readable without evidence crop/overlap. |
| Audio muted | All outcome/connection information remains visual/textual. |
| Haptics off | No state depends on vibration. |
| Screen-reader hints | Response/result language remains direct and ordered. |

---

# 11. Master reveal acceptance gate

A reveal is release-ready only if:

- [ ] Scene context returns before evidence annotation.
- [ ] Evidence geometry matches the generated truth used to score the answer.
- [ ] Every supported question type has complete visual proof.
- [ ] Correct and missed responses receive equally clear explanation.
- [ ] Explanation is factual, readable, and uses player-visible language.
- [ ] Progress/achievement/Program messaging cannot obscure the reveal.
- [ ] Reduced Motion, High Contrast, color assistance, text scaling, mute, and haptics-off preserve meaning.
- [ ] Physical Android review confirms timing, sound, visual legibility, and touch flow.
- [ ] Human players call missed answers fair and can identify the evidence afterward.
- [ ] The reveal creates desire for another Witness Moment more often than desire for another reward.

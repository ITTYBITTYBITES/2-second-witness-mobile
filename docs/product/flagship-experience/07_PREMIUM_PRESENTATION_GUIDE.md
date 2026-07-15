# Premium Presentation Guide — The Witness Atmosphere

**Goal:** make every flagship Witness Moment feel calm, tense, tactile, and trustworthy.
**Important language rule:** The player-facing experience is a premium daily **observation** ritual. Avoid assessment-oriented “cognitive training” language.

---

# 1. Presentation premise

Premium presentation does not mean more decoration, more motion, or more data. It means that every visible and audible element serves the witness contract:

- the player knows where to look;
- the brief moment feels important;
- the hidden truth returns clearly;
- the app feels composed enough to trust;
- the player can stop without friction.

The desired atmosphere is **editorial evidence**: a calm dark frame around a warm, readable ordinary scene.

---

# 2. Visual language

## Product frame

- Dark, quiet surrounding surfaces establish focus and make the scene stage feel deliberate.
- The eye/witness mark is an instrument of attention, used sparingly at product transitions or brief identity—not stamped across every gameplay surface.
- Purple/violet brand tones can identify product navigation and current action.
- Warm gold/earth evidence tones can identify the truth returning in a scene.
- Colors must remain tokenized, high-contrast-capable, and never be the only source of meaning.

## Scene stage

- Ordinary scene art is the hero, not a card buried in chrome.
- Grounded materials, readable silhouettes, directional shadows, and restrained scene palettes create a tactile premium quality.
- The scene frame protects safe areas and legibility; it should not make the moment feel like a tiny website panel.
- Evidence annotation is precise and restrained, never a generic gamified particle effect.

## Tone alignment

The product may retain a subtle sense of mystery: an eye, a pause, the question of what mattered. It should not imply a noir/crime narrative, investigator plot, or psychological thriller that a first playable scene cannot fulfill. The trailer’s atmosphere must be translated into playable attention and reveal, not copied as unsupported story promise.

---

# 3. Motion direction

## Motion has three jobs

1. **State change:** scene appears, disappears, returns.
2. **Attention resolution:** evidence becomes visible after context.
3. **Continuation:** the player understands what may happen next.

Anything else is optional and should be removed if it competes with observation.

## Motion rules

| Moment | Desired motion | Avoid |
|---|---|---|
| Launch/title | One restrained wake/settle of brand signal. | Multiple splash animations, long logo holds, decorative loading loops. |
| Brief → observation | Quiet handoff that clears the stage. | Large zooms/fades that delay first look. |
| Observation timer | Stable, peripheral temporal cue. | Pulsing/flickering UI that draws attention from the scene. |
| Concealment | Clean, short removal of evidence. | Dramatic effects that become a visual clue or punish slow attention. |
| Reveal | Context returns, then evidence resolves. | Immediate answer overlays, confetti, repeated pulses, target-covering effects. |
| Result exit | A clear settle into next/close state. | Slow transitions that make a short round feel sluggish. |

## Reduced Motion

Reduced Motion is not a lesser experience. Replace animated hierarchy with stable information hierarchy:

- scene appears in full;
- evidence is already clearly marked after answer;
- explanation remains equally specific;
- no timing-critical information depends on animation.

The existing AccessibilityService and family renderer paths should be preserved and verified on devices.

---

# 4. Sound and haptics

## Sound language

The soundscape should feel like attention resolving, not an arcade reward loop.

| State | Intended sound feeling |
|---|---|
| Brief/scene arrival | Quiet readiness; subtle room/instrument wake. |
| Observation | Minimal sound so visual attention remains primary. |
| Conceal | A soft closure/held breath. |
| Answer commit | A short acknowledgment: the witness call is recorded. |
| Correct reveal | Warm confirmation, not celebration overload. |
| Missed reveal | Neutral resolving cue that invites a second look, never a punishment. |
| Brief completion | Gentle sense of closure. |

The current AudioService already has route BGM, preloaded cues, ducking, per-bus controls, mute, and optional haptics. The work is sound-direction and hardware validation, not a parallel audio system.

## Haptics

- Optional and brief.
- Used for material state changes, not every button.
- One soft response at the right moment is better than several stacked vibrations.
- Different outcome patterns must never make a missed answer feel punitive.
- No player should lose clarity or progress with haptics disabled.

---

# 5. Typography and copy

## Typography role

Typography must make the scene, question, and explanation easy to parse under time pressure:

- scene identity: small and quiet;
- countdown: visible but peripheral;
- question: immediately legible, plain language;
- answer options: large, distinct, easy to scan/tap;
- reveal explanation: concise and factual;
- progression: secondary to evidence.

## Copy rules

Use witness language:

- Observe
- Remember
- Witness Moment
- Evidence
- Detail
- You caught it
- A detail escaped you
- Witness Record
- Continue the Brief

Avoid:

- cognitive score
- brain training
- assessment
- diagnostic
- IQ
- failure language
- “improve your mind” promises
- overdramatic case/crime terminology unless actual playable content supports it.

## Accessibility

- Respect current text-size scaling without truncating questions or evidence explanations.
- Do not encode correct/missed states in color alone.
- Keep player-facing copy direct enough for assistive hints/screen readers.
- Preserve 48-pixel interactive targets, safe areas, focusability, and high-contrast tokens.

---

# 6. Transition and loading direction

A premium short-session product must not feel like it spends more time transitioning than observing.

## Transition rules

- Preload/generate before presenting a moment where possible; existing ChallengeSessionService preparation telemetry is useful.
- Use a direct, honest preparation state only when generation is actually occurring.
- Keep screen lifecycle memory-safe without visibly rebuilding the product around the player.
- Let each transition communicate a meaningful state boundary: brief → moment, moment → memory, call → truth, truth → return.
- Do not use generic loading spinners or unrelated microinteraction as the main brand experience.

---

# 7. Premium acceptance criteria

The presentation is premium when real players report that it feels:

- focused rather than busy;
- tense but not stressful;
- fair rather than obscure;
- warm/intentional rather than generic;
- private and trustworthy rather than manipulative;
- accessible without looking like a separate lesser mode;
- coherent from first launch through result.

It is not premium merely because it has dark surfaces, gradients, BGM, assets, animation, or numerous settings.

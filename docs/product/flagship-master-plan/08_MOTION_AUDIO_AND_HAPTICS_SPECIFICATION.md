# Motion, Audio, and Haptics Specification

**Purpose:** define the sensory identity of Two Second Witness as a calm, premium observation ritual.
**Principle:** sensory feedback must clarify attention and truth. It must never create pressure, obscure evidence, or reward-score spectacle.

---

# 1. Sensory identity

The desired feeling is **attention resolving**:

```text
quiet readiness
→ focused observation
→ held breath at conceal
→ committed witness call
→ truth returning
→ calm continuation or closure
```

Motion, sound, and haptics are not separate polish layers. They make this sequence legible and emotionally coherent.

---

# 2. Motion specification

## Global motion rules

- Motion communicates state change or evidence hierarchy; it does not decorate empty time.
- Keep gameplay transition duration short enough that a brief round feels immediate.
- Scene evidence remains stable/readable before, during, and after any animation.
- Reduced Motion replaces animated sequencing with stable information sequencing.
- Never use flashing, shake, zoom, or visual surprise as an answer clue or missed-answer punishment.

## Transition map

| Moment | Motion objective | Recommended behavior | Avoid |
|---|---|---|---|
| Publisher/title | Establish quiet brand readiness. | One restrained wake/settle; bounded loading feedback. | Long logo loops, multiple competing splash animations. |
| Brief → scene | Clear stage for observation. | Brief clears quickly; scene arrives stable. | Large zoom/fade delaying first readable frame. |
| Observation | Keep time legible but peripheral. | Stable countdown/progress cue. | Pulses/flicker that pull attention from scene. |
| Conceal | Mark end of seeing. | Short calm fade/cover; optional soft settle. | Thriller jump cut, shake, target-revealing transition. |
| Recall | Stabilize decision. | No unnecessary movement; answer state clear. | Animated answer shuffle or distraction. |
| Evidence reveal | Return context then focus truth. | Full scene → evidence trace/outline → explanation. | Immediate crop/answer overlay, confetti, repeated pulse. |
| Record interaction | Organize memory quietly. | Small settle/connection movement only when it explains relation. | Dashboard counters flying/incrementing. |
| Navigation | Respect session boundaries. | Brief, accessibility-aware handoff. | Generic app-like loading choreography. |

## Observation movement

The flagship observation scene should normally be still. Any visual movement must be environmental/atmospheric and cannot alter scoring truth or reduce accessibility. The player is witnessing a composition, not tracking animation.

Motion-based Challenge Types remain a separate future portfolio decision and must not be introduced to compensate for scene stillness.

---

# 3. Audio specification

## Audio hierarchy

| Layer | Role | Rule |
|---|---|---|
| Ambient/BGM | Establish quiet product/scene atmosphere. | Supports focus; ducks/settles around conceal and reveal. |
| Observation cue | Marks beginning of attention. | One subtle cue; never a countdown distraction. |
| Conceal cue | Marks evidence leaving. | Soft held-breath/closure, not a failure sound. |
| Commit cue | Confirms witness call captured. | Neutral, short, nonjudgmental. |
| Evidence cue | Marks truth becoming visible. | Signature resolving sound; more important than score sound. |
| Correct layer | Adds quiet warmth. | Never an arcade fanfare. |
| Missed layer | Adds neutral realization. | Never a buzz, alarm, or shame cue. |
| Brief completion | Signals clean closure. | Gentle, optional, no pressure to continue. |
| Navigation/UI | Supports interaction consistency. | Low-profile; respects UI mute/bus settings. |

## Existing framework reuse

Use the current AudioService:

- route-based BGM tracks;
- cached packaged sound streams;
- UI/SFX/BGM buses;
- independent volume/mute settings;
- safe linear-to-dB handling;
- BGM duck/unduck;
- cleanup/lifecycle behavior.

Do not add a second audio manager or bypass settings. Any new cue must be audited for stacking, duration, import, memory, and audio-off equivalence.

## Sound design direction

- **Publisher/title:** sparse, quiet instrument awakening.
- **Home/Brief:** warm calm bed, not productivity-app urgency.
- **Observation:** near-silence/low ambience; visual attention is primary.
- **Conceal:** a subtle closure/held breath.
- **Reveal:** a distinctive soft resolution motif that can become product-recognizable.
- **Correct:** slight harmonic warmth after evidence, not before.
- **Missed:** equally gentle resolving tone, perhaps lower/unfinished but never negative.
- **Record:** minimal archival/settle sound only when interaction creates meaning.

No scored answer may depend on audio. All product function remains available muted/offline.

---

# 4. Haptics specification

## Principles

- Haptics are optional and brief.
- Use one meaningful tactile acknowledgment rather than constant vibration.
- Haptics clarify state; they do not substitute for evidence.
- Correct and missed outcomes must not feel like reward versus punishment.

## Suggested use

| Moment | Haptic behavior |
|---|---|
| Observation begins | Optional light readiness tick. |
| Answer commits | Optional short acknowledgment. |
| Evidence focus | Optional soft resolve; primary flagship haptic if any. |
| Correct | May add a light warm confirmation after evidence. |
| Missed | May use neutral single resolve only; no long/error pattern. |
| Brief completion | Optional calm closure, never pressure. |

Respect current `haptics_enabled` state immediately. Test on varied Android hardware because vibration behavior differs materially by device.

---

# 5. Accessibility and sensory equivalence

| Preference/state | Required behavior |
|---|---|
| Reduced Motion | All state/evidence hierarchy remains visible without animation. |
| Audio muted / sound effects off | No answer/reveal understanding depends on sound. |
| Haptics off | No interaction/result state depends on vibration. |
| High Contrast | Evidence/selection hierarchy remains visible without delicate color/opacity. |
| Reading Comfort / Comfortable Timing | Timing/audio/motion remain calm; normal progress preserved. |
| Screen-reader hints | Copy is ordered, factual, and not dependent on visual-only flourish. |

A premium sensory layer that only works under default settings is not premium.

---

# 6. Performance constraints

- Do not create overlapping tweens/sound layers on repeated navigation or result transitions.
- Respect non-cached transient gameplay screen lifecycle; clean up dynamic controls/cues on unmount.
- Keep evidence animations GPU/CPU-light enough for target Android hardware.
- Do not add high-resolution video, full-screen particle systems, or long audio loops to create “premium” feel.
- Verify 60/90/120Hz behavior: timing is based on real duration, not assumed frame count.
- Verify audio start/duck/unduck after interruption/resume and mute/volume changes.

---

# 7. Sensory acceptance criteria

- [ ] Player can identify observation, concealment, answer commitment, and truth return without visual/audio overload.
- [ ] Evidence reveal remains the sensory high point, not a score animation.
- [ ] Correct/missed feedback feels different enough to be understandable but equally respectful.
- [ ] Audio/haptic cues do not stack unexpectedly across routes/results/achievements.
- [ ] Reduced Motion/audio-off/haptics-off preserve equal information and satisfaction.
- [ ] Device testing confirms no timing/frame/audio latency compromises fairness.
- [ ] Human players describe the product as calm, focused, and intentional rather than flashy or punitive.

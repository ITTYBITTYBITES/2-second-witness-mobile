# Witness Threads Implementation Boundaries

**Current authorization:** Flagship Reconstruction only.
**Narrative-layer recommendation:** **Document only now; prototype later only after validation gates pass.**

---

# Decision summary

Witness Threads are a potentially strong retention layer because they can make already-witnessed ordinary moments feel connected. They are also high-risk because they can turn the product into a detective/campaign game, burden content production, and distract from the fair Scene Investigation reveal.

Therefore:

- **Do not build narrative UI now.**
- **Do not build story infrastructure now.**
- **Do not add Cases, thread progress, narrative menus, notifications, or archive connection state now.**
- **Do not authorize additional systems until the current Witness Moment demonstrates retention.**

The only appropriate work now is documentation and future-content constraints that avoid closing off the option.

---

# Phase 1 — Current Flagship Reconstruction

## Required scope

The active work remains the existing flagship package:

1. **Witness Moment**
   - intentional first Scene Investigation moment;
   - fair observation timing and scene composition;
   - one clear question and witness call;
   - no duplicate teaching path.

2. **Evidence Reveal**
   - current scene truth returns before annotation;
   - precise evidence highlight and factual explanation;
   - correct/missed responses both feel fair;
   - result hierarchy favors understanding over score noise.

3. **Witness Record**
   - simple current brief, familiarity, and moment archive direction;
   - no currencies, reward economy, achievement wall, or narrative layer.

4. **Scene quality pipeline**
   - scene composition rules;
   - generated truth/validator/reveal quality;
   - accessibility and device review;
   - current art/audio/presentation coherence.

## Existing systems to preserve and reuse

- Scene Investigation family, templates, generator, validator, scoring, difficulty/exposure policies, renderer, tutorial, and content packs.
- ChallengeSessionService as the single lifecycle authority.
- Challenge Family/Template/Instance/Result contracts.
- Observation, Recall, Result, and Tutorial routes.
- PlayerProgressService, ProfileService, SaveService, history, favorites, and local offline data model.
- RecommendationService, ProgramService, and Continue state—only to clarify the Witness Brief.
- Interaction adapters, accessibility, theme, responsive layout, audio/haptics, error handling, and safe Android shell.

## Explicit exclusions

- `thread_id` profile state or thread completion state.
- Connected-evidence archive views.
- New player-facing narrative copy.
- Cases/chapters/episodes/quests.
- Story-specific art, scenes, characters, or lore.
- New Challenge Types.
- Any feature that tells the player to return to advance a hidden story.

---

# Phase 2 — Validation

## Required validation questions

Before a narrative-layer prototype is considered, validate the flagship with real people and real Android hardware.

### User testing

- Do first-time players understand the Witness Moment without coaching?
- Does the current evidence reveal produce “I understand what happened” after correct and missed answers?
- Do players voluntarily choose a second moment?
- Can players remember/refer to a prior ordinary scene after normal play?
- Do players find the current Witness Record meaningful without a story layer?
- Do companion modes clarify or dilute the flagship identity?

### Retention signals

- Voluntary return to a fresh Witness Brief.
- Brief start, completion, resume, and clean-stop behavior.
- Chosen post-result action.
- Scene/world preference and normal replay behavior.
- Moment/reveal recall across sessions.
- No evidence of pressure, task fatigue, or confusion from current progression.

### Qualitative feedback

Listen for:

- “I noticed that.”
- “I see why I missed it.”
- “I want another scene.”
- “I remember that desk/kitchen/travel moment.”
- “I came back to see what was next.”

Treat the following as blockers:

- “This feels like a test.”
- “I do not know what I should do next.”
- “The reveal is just a score screen.”
- “I feel pressured to maintain a streak.”
- “The scenes blur together.”

### Device/product validation

- Full physical Android boot, safe-area, touch, audio/haptic, save/recovery, and accessibility matrix.
- Current runtime suite and static baselines reconciled with active source.
- 20/50-round Scene Investigation variety/fairness sessions.
- Actual device footage confirms the product’s visible promise.

## Phase 2 exit gate

A thread prototype may be considered only when all are true:

- [ ] Scene Investigation demonstrates voluntary replay/return behavior.
- [ ] The normal evidence reveal is understood and emotionally satisfying.
- [ ] Players remember ordinary scenes or details across sessions naturally.
- [ ] Current brief/progression does not already create avoidable cognitive/choice burden.
- [ ] No critical device/accessibility/release issue compromises the core loop.
- [ ] Content team can sustain standalone scene quality before taking on thread content cost.

---

# Phase 3 — Future narrative layer, conditional

## Possible scope

If Phase 2 validates the premise, build the smallest possible research prototype:

- one three-scene material Witness Thread;
- existing Scene Investigation worlds and normal challenge lifecycle;
- no thread prompt on observation or question screens;
- normal evidence reveal first;
- one optional secondary connected-evidence beat after third scene;
- one quiet Witness Record archive relation;
- no completion bar, reward, next-thread prompt, or notification.

## Possible additive data, only when authorized

A future prototype may need small content-level metadata such as:

- `thread_id`;
- `thread_beat` role: seed/echo/reframe;
- recurring `connection_anchor_id`;
- scene-specific anchor geometry/reference;
- factual connection copy key;
- eligibility/display policy.

This must remain **Content/Game-layer metadata**. It must not create a second navigation flow, alternate save/profile service, separate gameplay launcher, or family-specific branch in the shared runtime.

## What not to build even in prototype

- Story Mode route.
- Case selector.
- Chapter/episode UI.
- Narrative progress bar.
- Named-character system.
- Quest/task tracking.
- Currency, collectible inventory, or unlock economy.
- Push notifications/return reminders tied to threads.
- A content schedule that forces beat order or creates FOMO.
- Cross-family narrative rules that compromise a family’s standalone mechanics.

## Prototype success criteria

A prototype is successful only if research shows:

- players experience a connection as a retrospective surprise, not a required task;
- players still describe the app primarily as an observation/witness experience;
- the normal scene question and reveal remain the remembered core;
- the archive relation adds curiosity without increasing session confusion;
- no player feels they need to play daily, finish a story, or collect missing content;
- standalone scene quality and accessibility do not decline;
- the emotional payoff is strong enough to justify recurring asset/QA cost.

---

# Critical build/no-build recommendation

## Build now

**No narrative layer.** Build only the existing flagship reconstruction: Witness Moment, evidence reveal, simple Witness Record, and scene quality pipeline.

## Prototype later

**Yes, conditionally.** Prototype one hidden three-scene material thread only after the Phase 2 gate passes.

## Document now

**Yes.** Preserve this package as a content/product constraint so current flagship work does not accidentally hard-code assumptions that block future connected evidence.

## Reject

Reject any version that adds story mode, campaign structures, visible Cases, quest language, narrative completion, FOMO delivery, characters as the product attraction, or a second system players must manage.

---

# Final principle

The narrative is not the thing being uncovered.

> **The act of noticing is the story.**

A future thread earns its place only if it makes a player look back at ordinary Witness Moments with more curiosity, while leaving every current and future moment complete on its own.

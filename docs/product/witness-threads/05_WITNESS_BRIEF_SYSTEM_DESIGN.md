# Witness Brief System Design — A Moment Worth Noticing

**Purpose:** define how the existing Witness Brief concept can support long-term connection without becoming a daily chore, notification system, or narrative delivery mechanism.

---

# Core brief promise

A Witness Brief is not an assignment.

It is a calm proposition offered when the player opens the app:

> **A moment worth noticing is ready.**

The brief gives a player a finite entry into the flagship experience. It should make opening the app easier, not create a task list, a streak threat, or an expectation to follow a story.

---

# 1. Selection logic

## Selection priority

The system should resolve one current brief using this priority order:

1. **Player safety and preference:** accessibility settings, valid save state, device constraints, and no forced content incompatible with selected comfort controls.
2. **Unfinished meaningful brief:** if the player intentionally left a finite brief incomplete, offer a simple resume.
3. **Fresh flagship Witness Moment:** choose a fair, non-recent Scene Investigation moment suitable for current familiarity.
4. **Ordinary variety:** avoid immediate template/scene/signature repetition; use companion modes only when they serve variety or preference intentionally.
5. **Optional thread eligibility:** choose a valid connected beat only if it is already a high-quality normal moment and does not reduce any earlier priority.

## Thread selection rule

A thread is never the primary reason a brief is selected. The player must never receive a message like:

> “Return to continue the connection.”

If a thread-compatible moment is selected, it must read exactly like any other Witness Moment. The connection remains latent until enough evidence has accumulated and the normal reveal has resolved.

## Existing system foundation

The current `RecommendationService`, `ProgramService`, ChallengeSessionService, seeded generation, recent-signature prevention, family metadata, and unfinished-Program Continue behavior are strong foundations. A future implementation may require additional content metadata, but should not create a parallel selection engine.

---

# 2. Timing rules

## Frequency

- A brief is available when the player opens the app.
- It is not a countdown-bound event.
- It is not a time-limited opportunity.
- It is not a day-streak requirement.
- Missing a day never removes content, resets a record, or makes the player catch up.

## Session length

The brief should be finite enough for the player to complete or leave comfortably. The exact number of Witness Moments must be validated; the existing Daily Witness Program’s three-round shape is a starting hypothesis, not a product truth.

A healthy brief has:

- one clear first Witness Moment;
- optional continuation with a natural stopping point;
- a clean resume state when the player leaves;
- no infinite autoplay pressure.

## Thread cadence

- Do not allow more than one newly surfaced connection in a single short brief by default.
- Separate thread beats with unrelated normal moments whenever practical.
- Do not schedule thread convergence for a particular calendar day.
- Do not make a player wait because a story cadence needs it; if no thread-compatible moment is fair/fresh, serve an ordinary moment.

---

# 3. Tone and voice

## Desired voice

The brief is invitational, concrete, and non-demanding:

- “A moment worth noticing is ready.”
- “Your next Witness Moment is here.”
- “Continue when you are ready.”
- “A fresh scene is waiting.”

## Avoid

- “Do not break your streak.”
- “Your daily task is waiting.”
- “Come back to finish the story.”
- “Only available today.”
- “You are falling behind.”
- “A clue needs you.”
- “Complete your case.”

The player should feel invited into attention, not summoned by an obligation.

---

# 4. Personalization boundaries

## What the system may use

The brief may use only in-game, local product state necessary to preserve quality:

- recently played family/template/signature;
- current familiarity/mastery state;
- favorite Challenge Types, if intentionally selected by the player;
- unfinished brief/program context;
- accessibility, timing, reading, color, audio, and haptic preferences;
- local calendar only for fresh rotation, never for punishment;
- thread beat eligibility after all core selection rules are met.

## What the system must not infer or use

- real-world location, behavior, relationships, mood, work, travel, or identity;
- private device data beyond the app’s own local record;
- manipulation based on absence or predicted vulnerability;
- hidden difficulty punishment because a player missed prior moments;
- thread delivery designed to exploit FOMO;
- a personal fictional narrative about the player.

The brief remains a local, offline product ritual. It must preserve the current privacy/trust posture.

---

# 5. Relationship to the Witness Record

A brief creates moments. The Witness Record remembers them. A future connection may reorganize those remembered moments after the player has already lived them.

The brief itself should not preview:

- upcoming connected scenes;
- a hidden-thread count;
- an archive completion percentage;
- a promise that today will advance a story.

The player’s relationship is with the current moment. The record’s later connection is a retrospective bonus.

---

# 6. Brief system acceptance criteria

A Witness Brief is succeeding when players report:

- “I knew what I could do when I opened the app.”
- “It felt like a short thing I could finish or leave.”
- “I came back because I wanted another moment, not because I was afraid to lose something.”
- “The next scene felt fresh and fair.”
- “I did not feel like I was being sent through a story.”

It is failing when players report:

- “I did not know which option I was supposed to choose.”
- “I felt like I had homework to finish.”
- “I worried I would miss something if I did not play today.”
- “The app kept pushing a mode/story I did not choose.”
- “The connection was confusing or made the normal scene feel incomplete.”

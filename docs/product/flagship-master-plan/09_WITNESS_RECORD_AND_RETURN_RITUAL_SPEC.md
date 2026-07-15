# Witness Record and Return Ritual Specification

**Purpose:** define the long-term relationship around the flagship Witness Moment without game clutter, artificial progression, currencies, or obligation.

---

# 1. Return ritual: Witness Brief

## Product proposition

When the player opens Two Second Witness, the product should answer one question:

> **What is the moment worth noticing now?**

The answer is a **Witness Brief**: a finite, optional, state-aware entry into the flagship experience.

## Selection

Use existing recommendation/program/runtime infrastructure in this order:

1. Respect accessibility, comfort, valid save state, and player-selected constraints.
2. Resume an unfinished meaningful Brief if one exists.
3. Offer a fresh Scene Investigation-led Brief.
4. Use recent-signature protection and scene/template variety.
5. Use companion modes only when deliberate variety, preference, or accessibility benefit justifies them.
6. Keep Library/Programs available as secondary exploration.

Do not select content primarily to balance opaque metrics or advance a future story. Do not override an explicit player choice to force a “better” algorithmic path.

## Timing and frequency

- Briefs are available when the player opens the app.
- A Brief has a natural finish and can be safely resumed.
- The exact number of moments must be validated; three rounds is an existing starting point, not a fixed product law.
- No missed-day penalty, reset, catch-up, expiring event, or time-limited offer.
- No push-notification requirement in the flagship direction.
- Local calendar may create fresh rotation, never FOMO.

## Tone

Use calm invitation:

- “A moment worth noticing is ready.”
- “Continue when you are ready.”
- “A fresh Witness Brief is here.”

Avoid:

- “Do not lose your streak.”
- “Complete today’s task.”
- “You are behind.”
- “Only available now.”
- “Finish the story/case.”

---

# 2. Witness Record

## Definition

The Witness Record is a private archive of a player’s in-game observation relationship. It is not a scorecard and does not claim to measure real-world ability.

It has three quiet layers:

| Layer | Player question | Content |
|---|---|---|
| Current Brief | “What can I continue?” | Brief state, current/next moment, clean completion. |
| Familiarity | “What parts of this game do I know?” | Scene worlds, question/relation familiarity, optional family mastery. |
| Moment Archive | “What have I witnessed?” | Recent meaningful scenes, evidence, favorites, completed briefs, future connected evidence if approved. |

## Existing systems reused

- PlayerProgressService observation record, family progress, recent signatures/history.
- ProfileService local persistence and compatible schema merge.
- SaveService atomic write/recovery.
- Recommendation/Program state.
- Existing favorites, challenge history, rank/mastery/achievement data.

The Record should derive from these systems wherever possible. It must not create a second player database.

---

# 3. Progression policy

## What should grow

- Familiarity with ordinary scene worlds.
- Ability to recognize the game’s fair observation grammar.
- Personal archive of witnessed moments.
- Voluntary relationship with preferred scenes/companion modes.
- Comfort with richer but still fair content variation.

## What should remain secondary

- Witness Level/rank.
- Per-family mastery percentage.
- Accuracy/fastest response/correct-answer streak.
- Achievements.
- Collections.
- Program statistics.

These are useful supporting data. They must not become the main reason a player opens, the first thing they see after a reveal, or a pressure mechanism.

## What must not exist

- Currency.
- Loot/inventory.
- Artificial reward track.
- Daily-loss streak system.
- Public comparative ranking.
- Requirement to play a mode for record completion.
- Narrative completion bar.
- Claim that player progress measures health, intelligence, diagnosis, or real-life performance.

---

# 4. Archive behavior

## Moment entries

A moment archive entry should preserve context rather than raw telemetry:

- scene world and ordinary-place identity;
- a representative evidence reference/reveal where safe and performant;
- factual explanation of what mattered;
- optional favorite state;
- personal encounter order;
- calm outcome wording.

An archive entry should not look like a spreadsheet row of score, rank, and timestamps.

## Replay relationship

Replaying a past moment is voluntary. It may refresh scene familiarity or let a player revisit evidence, but it must never be required to restore progress, finish a Brief, or unlock archive understanding.

## Future connected evidence

If Witness Threads are validated later, archive entries may gain a quiet “related evidence” relationship only after a connection has surfaced. No empty thread slots, counts, or story navigation appear before then.

---

# 5. Return and record acceptance criteria

The system is ready when players:

- know what a Brief is and why it is offered;
- can leave a Brief without concern or punishment;
- understand what the Record represents;
- value at least one personal continuity signal beyond a score;
- do not interpret rank/mastery as an external assessment;
- can revisit a past moment because it is interesting, not because it is required;
- describe the product as a private observation ritual rather than a task app;
- retain full normal progress under comfort/accessibility settings and local save recovery.

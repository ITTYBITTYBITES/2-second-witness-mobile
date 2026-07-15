# Witness Record Evolution — Personal Archive of Connected Evidence

**Purpose:** let discovered connections reorganize remembered Witness Moments without creating an achievement wall, badge collection, score system, or story menu.

---

# Core principle

The Witness Record should feel like a private archive that has become more legible over time.

It should not feel like:

- a checklist of narrative content;
- a wall of locked achievements;
- a collection album with missing silhouettes;
- a “case progress” interface;
- a score report;
- a menu the player must manage.

The archive is a place a player visits because they are curious about what they have already witnessed.

---

# Archive evolution model

## Before any connection surfaces

The Witness Record remains focused on the current flagship design:

- recent Witness Moments;
- scene worlds encountered;
- factual evidence/reveal history where appropriate;
- personal in-game familiarity;
- current/finished Witness Brief context.

No empty “Threads” section should be visible. The absence of a narrative layer is intentional.

## After a connection surfaces

A prior moment quietly gains a relational property: it is now known to be connected to another moment. The archive can organize this as **connected evidence**, not as a reward.

The player may see:

- a previously familiar scene snapshot with a subtle repeated motif;
- a current moment linked visually to one or two earlier moments;
- a date/order of personal discovery if this is meaningful;
- a factual note about the shared object, arrangement, or environmental echo.

The player should not see:

- “3 of 5 scenes found”;
- a locked next card;
- a claim that the thread is complete;
- an alert badge demanding attention;
- a reward animation or currency award.

---

# Archive structure

## 1. Moments

The basic archive unit remains the individual Witness Moment.

A moment entry should preserve the player’s experience:

- scene world/context;
- memorable evidence in its original scene context;
- whether the detail was caught or later understood;
- a short factual result explanation;
- optional favorite status.

A moment must remain meaningful even if it never belongs to a thread.

## 2. Connected evidence

When enough evidence exists, the archive can show a relationship among moments.

**Recommended behavior:** an individual moment displays a restrained “related evidence” affordance only after discovery. Opening it lets the player see connected moments together.

The connection view should be visual and archival:

```text
Current scene evidence
↔ prior witnessed scene evidence
↔ earlier witnessed scene evidence
```

It should not have episode numbers, a linear roadmap, or a next-step button.

## 3. Personal discovery history

The archive may retain a quiet chronology such as:

- “First witnessed in Office”
- “Seen again at Travel Desk”
- “Connection surfaced after Garden Bench”

This is a personal order of observation, not fictional chronology. It tells the player how *they* came to see the relationship.

---

# Visual relationship language

## The relationship should be seen before it is explained

Use the same evidence-first hierarchy as a normal reveal:

1. scene references appear in their original contexts;
2. the recurring object/motif is subtly marked in each;
3. a restrained line, shared accent, or parallel framing shows the relationship;
4. one factual sentence names the shared evidence.

The visual relation should resemble a memory becoming organized, not a detective board with red string, suspects, and tasks.

## Allowed visual devices

- Quiet line/trace between two or three evidence references.
- Shared warm evidence accent with high-contrast alternative.
- Consistent crop/anchor framing around the recurring detail.
- Repeated motif shape in the archive background.
- Side-by-side or stacked scene references that preserve full context.

## Avoid

- Corkboard, red-string, crime-wall, surveillance, dossier, or suspect imagery.
- Lock icons, chapter cards, numbered “case files,” or percentages.
- Excess animation, parallax, collectible shine, or reward particles.
- A separate narrative map that overtakes the Witness Record.

---

# Personal discovery semantics

## Correctness should not determine worthiness

The thread layer must not shame a player for missing an earlier scene detail. If a connection surfaces after a player missed the relevant object in one prior moment, archive wording remains inclusive:

> **This detail was present in a moment you witnessed before.**

If the player caught it previously, wording may celebrate observation without creating a score gate:

> **You noticed this detail before it appeared again.**

Both are valid forms of discovery. The later connection gives the player a new way to see prior play.

## Revisit, not replay requirement

The archive can invite a player to revisit a prior evidence reveal, but it must not demand replaying an old scene to unlock meaning. Replay remains a voluntary normal Witness Moment, never a remediation task.

---

# Data and privacy boundaries

The record should organize only in-game observation data:

- scene/template/instance identity;
- evidence/reveal geometry or snapshots already generated for the moment;
- thread content metadata when/if a connection is released;
- player play order and optional favorites;
- accessibility-safe presentation state.

It should not infer real-life habits, locations, personal identity, emotional state, or any outside-the-game narrative about the player. The existing local-only Profile/Save design remains the appropriate foundation.

---

# Archive acceptance criteria

A Witness Record evolution is successful only if player research finds that it:

- feels like a personal archive, not a game menu;
- makes prior moments more interesting without making them feel incomplete;
- creates curiosity without any pressure to continue;
- is understandable without a tutorial;
- does not displace the current Witness Brief or evidence reveal as the primary experience;
- remains accessible in High Contrast, text scaling, Reduced Motion, and audio-off use;
- preserves local/offline trust expectations;
- can be ignored completely without reducing normal play value.

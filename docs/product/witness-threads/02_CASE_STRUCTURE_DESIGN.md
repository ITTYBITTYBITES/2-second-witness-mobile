# Connected Witness Moment Structure

**Recommended player-facing term:** no term at first; after discovery, use **Connection** or **Witness Thread**.
**Term to avoid as the default:** **Case**.

---

# Naming decision

“Case” has useful shorthand value internally: it describes an authored set of connected evidence beats. But it also carries detective-game expectations—case files, suspects, chapters, resolution, and completion. Those expectations conflict with the intended emergent, non-obligatory layer.

## Recommended terminology

| Context | Recommended term | Reason |
|---|---|---|
| Internal content tooling | `thread_id`, `thread_beat`, `connection_anchor` | Precise and technical; does not leak product fiction. |
| Before discovery | No visible term | The player should see normal Witness Moments only. |
| First surfaced relationship | “A connection surfaced.” | Reflective, non-demanding, not plot-oriented. |
| Record/archive view | “Connected evidence” or “Witness Thread” | Describes what happened without implying a task. |
| Avoid | Case, chapter, episode, mission, clue trail, solve | These make the player expect Story Mode. |

A future player research result may justify a different word. The behavior must remain unchanged: independent moments first, connection second.

---

# Structural model

A Witness Thread is a compact relationship among independent Witness Moments.

```text
Seed moment → Echo moment → Reframe moment → optional quiet convergence
```

The player may encounter unrelated moments between any beats. No scene is presented as “Part 1,” “Part 2,” or “next in a thread.”

## Recommended size

| Parameter | Recommendation | Rationale |
|---|---:|---|
| Minimum scenes | **3** | One recurrence can be coincidence; a third moment permits genuine hindsight. |
| Preferred scenes | **3–4** | Enough repetition for meaning without becoming a hidden campaign. |
| Maximum scenes | **5** | Beyond five, the player is likely to forget early evidence or feel an obligation to track a plot. |
| Required connected facts per scene | **1 primary echo**, optionally one subtle supporting motif | Keeps the connection legible and content burden bounded. |
| Normal standalone question per scene | **1** | The current Witness Moment remains unchanged. |

A thread must never require the player to remember all earlier scene answers. The connection is editorially assembled from scene evidence after the fact.

---

# Beat structure

## 1. Seed moment

The first scene works as a complete ordinary Witness Moment. A thread detail is visible but not framed as special.

**Example:** A folded transit map sits near an Office notebook. The actual scene question may concern a ruler’s position or number of pencils. The map is incidental but legible.

**Rule:** The seed cannot be so hidden that later connection feels retroactively unfair. It also cannot be so emphasized that it looks like a target marker.

## 2. Echo moment

A later independent scene repeats or transforms the detail.

**Example:** The same folded map appears among travel items, now showing a recognizable marked corner.

**Rule:** The normal question may or may not concern the recurring object. It must be independently fair either way. The player is not asked, “Where did you see this before?”

## 3. Reframe moment

A third scene makes the relationship meaningful enough to surface.

**Example:** The marked map corner appears as a protective bookmark beside a garden-planning notebook. The archive can now show the object across three ordinary places.

**Rule:** Meaning comes from relation and visual recurrence, not a written plot explanation. The player should infer more than the product states.

## 4. Optional quiet convergence

A fourth or fifth scene may create a satisfying visual convergence—an object returns in a changed use, related items appear together, or prior scene contexts line up in the archive.

**Rule:** Convergence is not a finale, boss, reward screen, or prompt to start the next thread. It is a stronger archival connection.

---

# Spacing and delivery rules

## Recommended spacing

| Rule | Recommendation | Why |
|---|---|---|
| Between thread beats | At least **one unrelated completed Witness Moment** whenever possible. | Prevents a visible sequence/campaign feeling. |
| Between sessions | Prefer a later session or later brief for the Echo/Reframe when natural. | Supports long-term recognition without daily obligation. |
| Forced timing | None. | A thread may wait; it must not drive a player’s calendar. |
| Missed days | No effect. | Prevents FOMO and streak-like pressure. |
| Player-selected mode | Do not override a deliberate player choice solely to force a beat. | Player agency and core experience are more important than thread delivery. |
| Repeat/replay | Never consume or permanently spoil a thread beat. | Replays must remain normal Witness Moments. |

## Selection priority

The Witness Brief selection system should be ordered conceptually as:

1. safety, accessibility, and valid current brief state;
2. a fair, fresh flagship Witness Moment;
3. ordinary variety / recent-repeat protection;
4. optional thread eligibility only when it does not compromise 1–3.

A thread must **never** cause an unfair scene, repetitive template, unwanted mode change, or interruption of an unfinished brief.

---

# Evidence threading rules

## Rule 1: Independent truth

Every scene’s generated truth graph, question, scoring, and result explanation must work with no knowledge of the thread. Thread metadata never changes the correct answer.

## Rule 2: Visible recurrence

A recurring detail must be visible enough at each declared difficulty for a player to recognize in hindsight. It cannot be microscopic text, a hue-only distinction, a one-frame animation, or an off-screen/cropped asset.

## Rule 3: Meaning through transformation

Repeat an object, motif, or relationship with a small change of context, placement, state, or pairing. Exact copy-paste repetition feels like a collectible; transformed recurrence feels like a connection.

## Rule 4: No required perfect memory

Discovery eligibility must be based on witnessed/played moments, not correct answers to all beats. Correctness can influence the nuance of copy, but it cannot gate access or make a player “fail the thread.”

## Rule 5: No hidden second task

The player is never told to spot the thread during observation. If a player independently notices it, that is delightful. If they do not, the later connection must still be generous and comprehensible.

## Rule 6: Connection is factual, interpretation is open

The product may state:

> “This map appeared in three witnessed moments.”

It should not state:

> “You solved the traveler’s secret journey.”

The first is evidence. The second is plot obligation.

---

# Convergence moment

## Purpose

A convergence moment lets the player re-see separate scenes as one visual relationship. It should feel inevitable only after the product places the pieces together.

## Recommended format

After the normal third/fourth scene reveal resolves, an optional secondary beat may show:

- the current evidence in context;
- two small, calm prior-scene references or snapshots;
- one visual thread line/motif connecting the same object/feature;
- a factual sentence with no completion language.

Example:

> **This folded map was present in the Office, Travel Desk, and Garden Bench moments.**

Then stop. No percentage, no “next connection,” no unlock fanfare, no demand to investigate further.

## Resolution philosophy

Threads do not need total resolution. A good thread leaves a residue of meaning:

- an object has traveled;
- a routine repeats across places;
- a pattern of care/work/preparation becomes visible;
- separate ordinary moments feel less isolated.

The player should feel that the connection was always there, not that the game has opened a separate story system.

---

# Structural acceptance test

A connected sequence is valid only if all statements are true:

- [ ] Every scene is enjoyable and fair without the thread.
- [ ] The player can encounter beats in normal play with unrelated moments between them.
- [ ] The connection has a visible, factual basis in each scene.
- [ ] No scene question requires thread knowledge.
- [ ] No beat uses a named character, chapter, mission, or narrative task.
- [ ] The convergence appears only after normal reveal truth has been understood.
- [ ] The connection can be ignored with no loss, pressure, or locked content.
- [ ] The player feels hindsight/discovery rather than a need to complete something.

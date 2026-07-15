# Narrative Content Authoring Guide — Connected Ordinary Moments

**Audience:** content designers, scene artists, writers, and QA reviewers.
**Goal:** author hidden Witness Threads that add retrospective meaning while preserving standalone Scene Investigation quality.

---

# 1. Authoring principle

A thread is not written as a plot. It is composed as a pattern of visible evidence across ordinary moments.

> **Author the detail first. Author the connection second. Never author a task for the player.**

Every scene must pass standalone Witness Moment quality before any thread relationship is considered.

---

# 2. Thread authoring workflow

```text
Choose ordinary observation grammar
→ author independent Scene A
→ identify one legible incidental evidence anchor
→ author independent Scene B with transformed echo
→ author independent Scene C with reframing echo
→ validate each scene alone
→ validate the retrospective connection
→ author archive/reveal callback only after truth is complete
```

The flow is intentionally scene-first. Do not start with a story premise and force scenes to carry it.

---

# 3. Creating recurring details

## Good recurring detail

A recurring detail should be:

- ordinary enough to belong in multiple scene worlds;
- visually distinctive in shape, material, marking, or context;
- readable at the tier where it appears;
- meaningful in hindsight without requiring text/lore;
- able to transform naturally across contexts;
- independent of the normal question unless one scene can fairly use it.

Examples:

- a folded transit map with a recognizable corner mark;
- a botanical sketch notebook with a distinct binding;
- a repaired mug with a visible handle wrap;
- a measuring tape with a stable color/shape feature;
- a small parcel tag with a non-textual symbol;
- a familiar tool/brush that appears in work and care contexts.

## Poor recurring detail

Do not use:

- a microscopic serial number, written name, date, or code;
- a brand/logo players cannot read at observation scale;
- a color-only callback;
- a rare dramatic prop that turns normal scenes into staged mystery sets;
- a named person’s personal object requiring backstory;
- an object repeated identically with no contextual change;
- any detail that feels deliberately highlighted before discovery.

---

# 4. Creating environmental clues and visual motifs

## Environmental clues

An environmental clue is a repeated condition or material relationship, not hidden exposition.

Examples:

- a familiar paper texture/edge appears in office, travel, and garden contexts;
- a repeated arrangement of practical tools suggests a shared routine;
- a particular plant-care motif appears first as a sketch, then an item, then an observed result;
- a distinctive container travels between ordinary uses.

## Visual motifs

Use motifs sparingly. A motif can be:

- a shape relationship;
- a repeated pattern of placement;
- a stable material mark;
- a non-verbal symbol reinforced by shape and context;
- a scene-light/texture echo only when it remains accessible and nonessential.

A motif must never become a secret code players need to decode during a normal round.

---

# 5. Evidence thread design

## The three-beat rule

Every authored thread requires at least:

| Beat | Authoring purpose | Required player experience |
|---|---|---|
| **Seed** | Introduce a detail naturally. | Complete standalone scene; no thread awareness required. |
| **Echo** | Repeat the detail in a changed context. | Normal standalone scene; possible quiet familiarity. |
| **Reframe** | Present the detail so prior appearances become meaningful together. | Normal scene first; later optional retrospective connection. |

An optional fourth/fifth convergence beat may strengthen an already clear relation. It cannot exist only to provide an ending/completion reward.

## Evidence threading rules

- Give each beat a stable internal `connection_anchor_id` only if implementation is later authorized.
- Preserve separate generated truth/evidence geometry per scene.
- Do not ask the same type of question about the recurring item every time.
- Let the item be incidental in at least one beat; otherwise it reads as an obvious collectible.
- Ensure the recurring detail is not confused with scene decoration or a distractor label.
- If a beat uses the anchor as a current scene target, the question must still be fair without awareness of prior beats.
- Never make the player’s previous answer determine the next scene’s correctness or access.

---

# 6. Delayed meaning

## What delayed meaning is

Delayed meaning happens when a player sees a prior ordinary detail in a new context and realizes that it was part of a larger pattern of witnessed moments.

## What it is not

- a twist that invalidates prior scene truth;
- a plot reveal about a hidden character;
- a command to replay or collect missing scenes;
- an explanation that tells the player what to feel;
- a reward gated behind perfect memory.

## Authoring test

After reviewing all thread beats side by side, ask:

> “Does the connection make the earlier scenes feel richer, while leaving them complete as they were?”

If the answer is no, the thread is story scaffolding, not emergent meaning.

---

# 7. Content budget and production discipline

Threads increase content cost. They require:

- recurring asset variants with stable identity;
- scene composition constraints across worlds;
- generator/validator support when assets must recur;
- reveal geometry in every beat;
- archive callback/copy;
- order/replay/accessibility QA;
- human review for standalone fairness and delayed meaning.

## Budget rule

Do not thread every scene. A small number of high-quality connected sets is better than a product where every prop is suspiciously recurring.

Suggested future prototype budget:

- one three-scene thread;
- one clear material anchor;
- one optional archive connection;
- no new family, story UI, reward, or narrative progression system.

---

# 8. Quality checks

## Standalone value

- [ ] Each scene is a satisfying Witness Moment with no thread knowledge.
- [ ] Each scene has a fair scene question, distractors, and evidence reveal.
- [ ] A player who never sees another beat loses nothing essential.

## Fairness

- [ ] Recurring detail is visible/readable at declared tier.
- [ ] It is not dependent on tiny text, color-only distinction, crop, or animation.
- [ ] Thread metadata does not alter scoring, question truth, or difficulty unfairly.
- [ ] Accessible settings preserve the detail and connection meaning.

## Emotional payoff

- [ ] Reframe creates hindsight, not confusion.
- [ ] The product states a factual relation and leaves interpretation open.
- [ ] No copy implies a narrative task, completion, or missed opportunity.
- [ ] A miss in an earlier beat does not become a retrospective failure.

## Replay value

- [ ] The thread does not make scenes predictable after one discovery.
- [ ] Replays remain valid normal moments.
- [ ] Recurring anchors do not dominate all questions or visual attention.
- [ ] The connection remains interesting when seen again but does not become required content.

## Connection strength

- [ ] At least three beats share a visible, transformed relation.
- [ ] The relation is clear when evidence references are shown together.
- [ ] The connection could plausibly be noticed by an attentive player, but is not required for normal play.
- [ ] It does not demand characters, lore, a chapter structure, or a fictional campaign.

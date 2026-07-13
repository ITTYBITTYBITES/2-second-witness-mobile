# Phase 5.5 — Replay Quality Audit

**Date:** 2026-07-13
**Scope:** Five production Challenge Types, 50 generated rounds per family
**Status:** Automated quality proxies passed; human fun and fairness review remains open

## What this audit can and cannot answer

The automated suite proves deterministic generation, validation, broad content use, template coverage, evidence completeness, and resistance to immediate repetition. It cannot prove that a person still finds a family fun after 50 rounds.

Accordingly, “fun after 50 rounds” remains **not yet certified** for every family. The implementation now has substantially stronger conditions for replayability, but Phase 6 must include observed human 20-round and 50-round sessions.

## Automated results

`test_phase55_replay_quality.gd` generated 250 rounds across beginner, standard, advanced, and expert policy states.

| Challenge Type | Valid rounds | Distinct semantic signatures | Consecutive repeats | Templates covered | Evidence complete |
|---|---:|---:|---:|---:|---:|
| Scene Investigation | 50 / 50 | 50 / 50 | 0 | 5 / 5 | 50 / 50 |
| Flash Words | 50 / 50 | 49 / 50 | 0 | 4 / 4 | 50 / 50 |
| Spot the Difference | 50 / 50 | 50 / 50 | 0 | 4 / 4 | 50 / 50 |
| Object Recall | 50 / 50 | 50 / 50 | 0 | 4 / 4 | 50 / 50 |
| Pattern Recall | 50 / 50 | 49 / 50 | 0 | 3 / 3 | 50 / 50 |

A repeated semantic signature can occur non-consecutively in a raw deterministic sample. The runtime’s recent-signature protection continues to reject immediate session repetition.

## Family questions

### Scene Investigation

**Does it still feel fun after 50 rounds?**
Not human-certified. Automated variety is strong: 50 distinct signatures, five ordinary settings, 120 scene archetypes, five question categories, and four difficulty tiers.

**Does each template feel meaningfully different?**
The five settings—Office, Kitchen, Workshop, Travel Desk, and Garden Bench—have unique art, object vocabularies, required groups, and compositions. The core observation decision remains intentionally consistent across settings.

**Is there enough procedural variety?**
Strong automated evidence. Every audited round was distinct, and the expanded pools provide 24 archetypes per setting before color, layout, clutter, question, and difficulty permutations.

**Does the reveal teach the player something?**
Yes by design. The exact object, group, or relationship is highlighted; the explanation states the answer and directs attention to the evidence. Reveal focus now has a restrained motion-safe pulse.

**Is replay driven by curiosity instead of randomness?**
The seed determines composition, but curiosity comes from not knowing which ordinary detail will matter. Questions remain grounded in visible evidence and validators reject ambiguous rounds.

### Flash Words

**Does it still feel fun after 50 rounds?**
Not human-certified. The 373-word reviewed pool and four modes support long sessions without relying on a tiny vocabulary.

**Does each template feel meaningfully different?**
Yes at the decision level: identify one word, preserve pair order, recognize stream membership, or recall the word at an exact position.

**Is there enough procedural variety?**
Strong automated evidence: 49 semantic signatures in the 50-round sample, no consecutive repeat, four modes, changing lengths, sequence lengths, timings, and distractor families.

**Does the reveal teach the player something?**
Yes. The comparison identifies the correct word or sequence, the player choice, and the exact position/order difference.

**Is replay driven by curiosity instead of randomness?**
Distractors are selected by declared orthographic, length, and semantic relationships. Random selection supplies variety; reviewed comparison rules create the challenge.

### Spot the Difference

**Does it still feel fun after 50 rounds?**
Not human-certified. The automated sample produced 50 distinct valid comparisons.

**Does each template feel meaningfully different?**
Yes: disappearance, attribute/mark change, one-pass A→B comparison, and legal movement to an unoccupied slot require different scanning strategies.

**Is there enough procedural variety?**
Strong automated evidence from 48 object identities, four visual themes, eight colors, four templates, multiple mutation categories, and density scaling.

**Does the reveal teach the player something?**
Yes. Both states are shown together and both normalized evidence regions are marked, including the empty location when an object disappeared.

**Is replay driven by curiosity instead of randomness?**
Exactly one semantic target changes. Mutations are legal and explainable; unrelated differences are not introduced.

### Object Recall

**Does it still feel fun after 50 rounds?**
Not human-certified. The sample produced 50 distinct valid sets with no consecutive repetition.

**Does each template feel meaningfully different?**
Yes: remember the complete set, identify two absent options, recover the top row, or identify the first and last objects in reading order.

**Is there enough procedural variety?**
Strong automated evidence from 48 labeled object identities, more than 30 silhouette kinds, set sizes from three to six, option counts from six to nine, and four prompts.

**Does the reveal teach the player something?**
Yes. Present objects are highlighted in place. Missing-object rounds add a dedicated **NOT SHOWN** evidence row so an absent answer is visible rather than merely stated.

**Is replay driven by curiosity instead of randomness?**
The set is seeded, but the player always answers a specific membership or position request. Labels reinforce silhouettes, and correctness never depends on color alone.

### Pattern Recall

**Does it still feel fun after 50 rounds?**
Not human-certified. The sample produced 49 semantic signatures and no consecutive repeat.

**Does each template feel meaningfully different?**
Yes in presentation: Grid Path shows one connected step at a time, Shape Sequence uses named geometric symbols, and Pattern Build retains prior steps as a cumulative trail.

**Is there enough procedural variety?**
Strong automated evidence from connected 3×3 and 4×4 paths, lengths from three to six, 12 named symbols, three presentation styles, and four timing tiers.

**Does the reveal teach the player something?**
Yes. The complete path or symbol sequence appears at once with numbered evidence, making the first mismatch understandable.

**Is replay driven by curiosity instead of randomness?**
Grid sequences are legal connected paths rather than arbitrary cell lists. Shape sequences prohibit immediate repeats. The player can anticipate structure without predicting the answer.

## Required human sessions

For every family:

1. One first-time-player tutorial and 20-round session.
2. One returning-player 50-round session across all templates.
3. Record voluntary replay choice, confusion, perceived fairness, fatigue, and “I missed it” versus “That was unfair” reactions.
4. Repeat with Comfortable Timing, Reduced Motion, High Contrast, and relevant accessible interaction alternatives.
5. Review Spatial Tap, Multiple Choice, and Sequence Input on physical Android hardware.

Do not claim 50-round fun, final difficulty balance, or store readiness until these sessions are complete.

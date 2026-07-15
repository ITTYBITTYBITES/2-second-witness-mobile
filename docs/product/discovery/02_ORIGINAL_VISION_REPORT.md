# Original Vision Report — Two Second Witness

**Discovery snapshot:** 2026-07-15
**Purpose:** identify the durable original intent, the major iterations that shaped the current build, and the distinction between written aspiration and current product reality.

## Evidence used

- Product roadmap, family specifications, architecture boundaries, foundation records, store listing, and trailer material in this repository.
- GitHub pull requests #1–#34. The clone itself has a shallow local history, so it cannot independently reconstruct every historical commit.
- One open, unmerged PR (#19, “Production mobile UX audit and remediation”) was treated as historical context only, not as current product behavior.

---

# 1. Original Product Vision

## The durable premise

The most stable statement across the roadmap, family specs, store material, and trailer is:

> A premium observation game built around short, fair, highly replayable challenges.

The intended player role is a **witness**, not a test subject. The product language deliberately avoids assessment terminology and favors Observation, Recall, Recognition, Attention, Focus, Witness Progress, Challenge History, Witness Level, and Witness Rank.

The core emotional contract is not simply “remember what you saw.” It is:

- a player notices that a detail mattered;
- a miss produces surprise rather than shame;
- the reveal proves the answer was present and understandable; and
- repeated short moments become a satisfying personal practice.

The phrase **“Players are never taking tests. Players are solving moments.”** is the clearest expression of the intended experience.

## Original product pillars

| Pillar | Original intent | Evidence in the current repository |
|---|---|---|
| **Observation under pressure** | A short exposure creates attention and a memorable “I missed it” moment. | Every production family uses a presentation/response boundary, timing policy, and post-response explanation. |
| **Fairness over trickiness** | A player should be able to understand why an answer was correct. | Seeded generation, validators, answer truth resolved before rendering, known-valid fallback, and evidence reveals. |
| **Replayable variety** | The product should outlive a fixed quiz sequence. | Procedural generators, content pools, templates, difficulty axes, recent-signature rejection, Programs, and 50-round audit tooling. |
| **Premium mobile quality** | The product should feel intentional on Android, not like a generic web dashboard or a bare prototype. | Portrait configuration, safe areas, touch targets, audio, themes, splash flows, assets, store docs, and recent mobile polish PRs. |
| **A witness identity** | Progress should feel like developing an observation record, not receiving a diagnosis. | Witness levels/ranks, mastery, Challenge History, “I Missed It” copy, brand eye motif. |
| **Modular expansion** | New challenge types should add game/content modules without rewriting the application. | Engine/Game/Content boundary, family contracts, registry, interaction adapters, generic Home/Library/Programs. |
| **Trust and low friction** | No account or personal-data dependency should be required for a quick session. | Offline defaults, no Internet permission, local save, local-only analytics, privacy modal. |

---

# 2. Development History Reconstructed from Artifacts

## Major iterations

| Period | What changed | What it reveals about the product’s evolution |
|---|---|---|
| **Foundation / July 9** | PRs #1–#12 made a simple playable observation loop, stabilized boot, established publisher/title/privacy flow, safe areas, theme, touch targets, Android export identity, local saves, and a legacy Flashword/experience registry. | The product began as a small mobile observation app and spent significant early effort becoming bootable and shippable rather than broad. |
| **Onboarding and runtime fixes / July 10** | PR #14 reintroduced a tutorial path; PRs #15–#18 repaired parsing, splash, and UI freeze issues. | First-session teaching and reliable launch were recognized as foundational, but the flow changed several times. |
| **Marketing identity / July 10** | PRs #20–#21 added a 45-second cinematic trailer, storyboard tools, story plates, narration, QR/play CTA, and a psychological-thriller presentation. | The marketing vision amplified mystery, changed evidence, investigator imagery, and “What changed?” tension. |
| **Product-platform phases / July 11–13** | Product documentation records runtime contracts, first Scene Investigation, Flash Words, generic Home, Programs, achievements, interaction adapters, and three additional families. | The concept expanded from one loop to a general observation-game platform. The architectural vision became much more mature than a single mini-game. |
| **Content depth / July 13** | Phase 5.5 added five Scene settings/120 archetypes, four Flash Words modes/373 words, 48-object pools, 12 pattern symbols, nine Programs, and 26 achievements. | The team chose to deepen the initial portfolio rather than immediately add all planned modalities. |
| **Production pass / July 13–14** | Phase 6 documentation and PRs #22–#30 focused on UI stabilization, family identity, result flow, settings/profile, audio/haptics, device layout, Android rendering, and static-test repair. | The work moved toward a release candidate, but this was largely local/source validation rather than human/device proof. |
| **Home V2 and visual migration / July 15** | PR #32 replaced the routed Home with a focused recommendation card while retaining old Home as rollback. PRs #31–#33 added a sprite-first grounded asset pipeline across families. PR #34 hardened audio and warnings. | The product is still actively converging on an identity. Recent decisions shifted the entry experience and gameplay art after earlier phase documentation/screenshots were considered complete. |

## What did not change across iterations

Despite repeated UI, boot, and visual changes, several decisions remained stable:

- Android package identity and ITTYBITTYBITES publisher identity.
- Portrait mobile orientation.
- A short observe → recall → result loop.
- An offline/no-account posture.
- Local persistence.
- The eye/witness brand language.
- The belief that a fair reveal is essential.
- A generic architecture meant to accept multiple mechanics.

---

# 3. Original Vision vs. Current Reality

| Original/planned idea | Current reality | Where it improved | Where it drifted or remains unresolved |
|---|---|---|---|
| **One elegant observation game** | A five-family product with scene, words, comparative change, set memory, and pattern sequence play. | Much broader mechanical portfolio and stronger replay foundation. | It is no longer self-evident which mode is the true heart of the product. |
| **“Two seconds” as the signature tension** | Exposures vary by family and difficulty: roughly 1.5–6 seconds for Scene Investigation, longer comparison windows for Spot the Difference, and family-specific timing elsewhere. | Variable timing enables fairness and accessibility. | The title can imply a single universal two-second rule that current play does not follow. |
| **Witness/detective fantasy** | Scene Investigation most closely fulfills it; other families are abstract, typographic, comparative, or tray-based. | The portfolio broadens reach beyond one scene mechanic. | The gameplay product is less narrative/mystery-driven than the cinematic trailer’s investigator/changed-case-file world. |
| **Premium product hub** | Home, Library, Programs, Profile, Achievements, Settings, audio, legal/store assets, and responsive shell exist. | The app has a genuine product layer rather than a menu of isolated demos. | Recent Home V2 displaced earlier hub presentation, and no user evidence shows the right balance between focused action and discovery. |
| **Endless fair replay** | Generators, content pools, templates, validators, fallbacks, and automated 50-round proxies exist. | Replayability is now designed into the code, not claimed by a fixed content list. | “Fun after 50 rounds” and final pacing are explicitly not human-certified. |
| **Growing Witness Progress** | Mastery, levels, ranks, achievements, favorites, history, Programs, and collections persist. | More complete than the original simple score/streak model. | The player meaning of rank, mastery, achievements, and collections has not been established through play behavior. |
| **Polished Android release** | Configuration, assets, export presets, CI import, and checklists exist. | Good release preparation and risk awareness. | Device boot, signed artifact, accessibility matrix, legal/store, and upgrade testing are unfinished. |
| **Easy modular growth** | A generic family/runtime/adapter/catalog system supports it. Seven future families are documented. | This is one of the project’s clearest delivered strengths. | The code also retains an older `experiences/` model, making the conceptual architecture less clean than its current boundary documents imply. |

---

# 4. What the Product Improved

## From fixed challenges to a product platform

The earliest retained content is five deterministic image/question fixtures. The current player-facing product no longer depends on those fixed entries. It has a family registry, generated instances, generic presentation routes, scoring policies, content packs, and generic product surfaces. This is a substantial improvement in both replay potential and maintainability.

## From one mechanic to a differentiated portfolio

The current five modes occupy different decisions:

- incidental scene detail;
- exact word/sequence recognition;
- visual change location;
- set membership/position;
- ordered abstract reconstruction.

This is not merely five skins of the same quiz. The Phase 5 portfolio matrix explicitly protects boundaries between families.

## From score-only feedback to explainable results

The result/reveal layer carries the original fairness promise forward. It returns the relevant scene/object/sequence state and identifies the correct evidence. This is both a player-experience improvement and a defensible product distinction.

## From a foundation menu to a coherent lifecycle

Programs, Continue, favorites, mastery, achievements, history, tutorial replay, and Home recommendation create a return loop around the core rounds. The runtime remains the single launch authority, which prevents those surfaces from fragmenting gameplay behavior.

## From generic mobile UI to a more intentional release candidate

Recent work added audio, haptics, safe-area handling, error banners, dynamic touch-target enforcement, game-phase chrome removal, local save recovery, and settings/accessibility connections. These improvements are meaningful even though physical-device verification is pending.

---

# 5. Where the Product Drifted

## The identity has multiple competing expressions

There are at least three product frames in the repository:

1. **Witness observation game** — ordinary scenes, fair recall, evidence reveal.
2. **Premium daily puzzle habit** — Home V2 presents a single “Today’s Witness Experience,” progress, and Programs.
3. **Psychological mystery/thriller** — trailer imagery uses rain-dark rooms, case files, altered family photographs, investigator narration, and “What changed?”

They share observation and memory, but they do not yet describe the same emotional promise at the same intensity. The actual playable content is closest to the first frame; the trailer is closest to the third.

## The product’s canonical Home changed after the formal product phase

Phase 3/4 documents and artifacts describe a richer data hub with Play Now, Continue, featured content, achievement previews, quick access, and Programs. The currently routed Home V2 deliberately minimizes that surface to one main action. Both approaches reuse the same services, but their product hierarchy is different. Current documentation should not be mistaken for a screenshot-accurate description of current Home.

## The phrase “daily” is stronger than the actual daily system

The runtime provides a deterministic daily featured Challenge Type and a daily Program. Home V2’s main card, however, uses the regular balanced recommendation and labels it “Today’s Witness Experience.” Player streaks are accuracy streaks, not return-day streaks. The daily-habit interpretation is therefore a design aspiration, not a proven behavior loop.

## The technical history outpaced verification maintenance

Recent source changes intentionally altered renderer/mobile configuration, Home routing, audio, theme, and shell files. Several frozen-baseline verifiers still represent earlier states. Documentation also contains contradictory statements about first-launch tutorial behavior. This weakens the confidence signal around a product that otherwise emphasizes production readiness.

---

# 6. Ideas Worth Recovering or Protecting

These are existing product ideas that remain coherent with both the original vision and current implementation:

| Idea | Why it is worth protecting |
|---|---|
| **“I missed it, but now I see it.”** | It unites fairness, tension, evidence reveals, and the witness identity. |
| **Ordinary scenes as meaningful moments** | Scene Investigation gives the brand a grounded, accessible, non-test-like flagship candidate. |
| **Family-specific mechanics behind a common journey** | Variety does not require divergent navigation, saves, or product surfaces. |
| **Fairness as an explicit technical feature** | Validators, resolved truth, and evidence highlights are rare and defensible product substance. |
| **Offline/no-account trust** | It lowers first-session friction and differentiates the product in a mobile market often built around ads, data, and account loops. |
| **Short sessions with an actual result reflection** | The product has a complete emotional arc in a small amount of time. |
| **Witness language rather than assessment language** | It protects the entertainment-first promise and avoids misleading claims. |

# 7. Ideas or Assumptions That Should Not Be Treated as Current Product Truth

This is not a recommendation to remove anything. It identifies concepts that are legacy, unproven, or inconsistent enough that they should not silently shape a future rebuild plan.

| Assumption/legacy | Current evidence |
|---|---|
| **Every round is literally two seconds.** | False in the current policies; timing is intentionally variable. |
| **The trailer is a faithful depiction of current gameplay tone.** | The trailer is a cinematic marketing artifact, not captured app footage; the store docs explicitly require real runtime footage before final listing use. |
| **Home V1 artifacts describe active Home.** | False; `AppRoutes` and `AppShell` route Home to `HomeV2Screen`. |
| **“Daily” already means a tested daily habit.** | There is date-based selection, but no verified daily-return progression or retention evidence. |
| **Production readiness is fully proven.** | Local phase completion is documented, but human/device/signed-release gates are still open and several current static baselines fail. |
| **The old ExperienceRegistry is active product architecture.** | It is an uninitialized legacy path; active play uses ChallengeFamilyRegistry and ChallengeSessionService. |
| **More planned Challenge Types automatically improve the product.** | The repository’s own Phase 5.5 decision was to deepen five families first, and current fun/fairness evidence is still incomplete. |

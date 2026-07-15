# Asset and Art Pipeline Plan

**Purpose:** create a repeatable visual production pipeline for flagship Scene Investigation content.
**Principle:** art must make evidence easier to notice, scenes more worth revisiting, and reveals more satisfying. It must not become decoration that reduces fairness.

---

# 1. Asset pipeline overview

```text
Observation grammar / scene concept
→ art brief and evidence plan
→ background + object concept/prototype
→ composition prototype
→ asset processing/import
→ generated scene validation
→ visual/contact-sheet review
→ device/accessibility review
→ production approval and versioned release
```

The pipeline is content-first and evidence-first. A polished asset is not production-ready if the scene cannot ask and reveal a fair question.

---

# 2. Asset inventory

## Scene assets

| Asset class | Purpose | Required properties |
|---|---|---|
| Backgrounds | Establish ordinary place, anchor surface, zones, atmosphere. | Portrait-safe composition, readable materials, protected evidence space, versioned source/output. |
| Object sprites | Supply question-eligible and decorative objects. | Stable IDs/names, readable silhouettes, consistent scale, transparent processing where used, vector fallback compatibility. |
| Subjects | Optional people/figures only if they serve ordinary scene grammar. | Never require facial identity, emotion reading, or narrative character knowledge. |
| Environmental details | Add texture/context: papers, shelves, tools, plants, light, surfaces. | Never mimic evidence unfairly or turn scenes into visual noise. |
| Evidence states | Dynamic outlines/traces/groups/relationship references. | Generated from scene truth; accessible/high-contrast equivalents; no baked answer marks. |
| Preview assets | Library/store/Brief representation. | Honest representation of actual scene quality and witness identity. |
| Audio assets | Observation/reveal/navigation/ambient cues. | Routed through existing AudioService; mute/accessibility safe. |

---

# 3. Asset standards

## Resolution and performance

- Keep source masters separate from packaged/mobile outputs.
- Preserve current mobile-oriented import/compression discipline, including ETC2/ASTC-compatible paths where configured.
- Existing processed object sprites should remain bounded (current pipeline targets a 512px maximum); new bounds require documented device-memory evidence.
- Background resolution must survive portrait crop and high-density displays without unnecessary texture memory.
- Every asset gets tested in the actual scene stage, not only in an art viewer.
- Avoid transparent padding, oversized unused canvas, and effects that inflate package/memory cost without evidence value.

## Naming and organization

Use stable, readable, content-oriented names. Example pattern:

```text
assets/gameplay/scene_investigation/
  backgrounds/<world>_background_v<version>.png
  objects/<object_id>_v<version>.png
  evidence/<evidence_style_id>_v<version>.png (only if static asset needed)
  previews/<world>_preview_v<version>.svg/png

src/gameplay/families/scene_investigation/content/
  <world>_v<version>.json
```

Each object/content record should maintain:

- stable object ID;
- player-readable name;
- asset path/version;
- question eligibility;
- allowed states/variants;
- accessibility metadata;
- visual scale/zone constraints;
- source/review status.

Do not embed opaque asset meaning only in filenames or art documents.

## Versioning

- Version background, object pack, template, generator, validator, exposure/difficulty policy, and content JSON independently where behavior changes.
- Preserve reproducibility identity in ChallengeInstance metadata.
- Do not silently replace an object/state in a way that invalidates old replay/evidence interpretation without version increment/migration decision.
- Record prompt/process provenance for generated or externally produced assets when relevant to licensing, revisions, and visual consistency.

---

# 4. Art direction

## Visual identity: editorial evidence

The flagship scene should feel:

- ordinary but carefully composed;
- warm, grounded, tactile, and readable;
- calm enough for attention;
- rich enough that a second look reveals something new;
- premium without photoreal/noir story pressure.

The product frame may remain dark and restrained. The scene stage carries warmer materials and a limited evidence accent. The eye motif belongs to product identity; it should not be stamped into every scene.

## Composition

- One clear anchor surface/place.
- Three readable zones.
- Intentional negative space around legal evidence.
- Object groups tell the eye where to scan without revealing target.
- Depth/shadow supports separation, not visual realism for its own sake.
- Avoid flat icon scatter, visual fog, excessive symmetry, or dense decorative wallpaper.

## Lighting

- Lighting establishes time/material/context but never hides legal evidence.
- Preserve sufficient luminance contrast for target objects and reveal overlays.
- Avoid glare, deep shadow, or color cast that makes one tier dependent on premium display quality.
- High Contrast mode requires deliberate renderer/art review, not a token swap assumption.

## Visual hierarchy

```text
Scene/anchor
→ object groups and relationships
→ incidental detail
→ evidence reveal only after answer
```

The timer, header, product brand, and decorative motion are always subordinate to the scene during observation.

---

# 5. Production workflow

## Step 1 — Concept brief

Define before art starts:

- scene world and ordinary observation grammar;
- anchor/action/peripheral zones;
- legal question categories;
- proposed object groups;
- difficulty/replay contribution;
- reveal concept;
- accessibility risks;
- whether the scene is standalone only or has approved future connection potential.

## Step 2 — Composition prototype

Create a low-cost layout/prototype that proves:

- player can understand place in a glance;
- zones are distinct;
- object scale/overlap supports fair targets;
- questions and evidence can be expressed;
- portrait mobile framing works.

Do not produce a full polished asset set before this review passes.

## Step 3 — Art production

Create backgrounds, objects, variants, and optional environmental details against approved composition and asset standards. Use the current sprite-processing workflow where applicable; retain raw/source assets outside packaged output as appropriate.

## Step 4 — Import and technical validation

- Process transparent backgrounds and inspect edges/shadows.
- Check import/compression/size settings.
- Verify resource paths, fallbacks, and packaged loads.
- Test renderer with source asset and fallback behavior.
- Profile memory/texture use on target device classes.

## Step 5 — Content/gameplay validation

- Generate representative seeds/tiers.
- Check target placement, question truth, distractors, exposure, reveal geometry, signatures, fallback.
- Produce contact sheets for visual/content review.
- Validate High Contrast, Color Assistance, Reduced Motion, text scaling, safe areas.

## Step 6 — Human review and production approval

Review standalone fairness, emotional reveal payoff, replay freshness, art coherence, and device behavior. Only then mark content production-ready.

---

# 6. Review and approval artifacts

Every new scene world/template should produce:

- concept brief;
- composition board/prototype;
- asset manifest with versions/license/source notes;
- content JSON/schema validation report;
- representative generated-seed contact sheet;
- observation/recall/reveal device captures;
- fairness/difficulty review;
- accessibility review;
- memory/performance check;
- human playtest observations;
- approval decision with known limitations.

This creates a content pipeline that is auditable and reusable without turning content work into bureaucracy detached from player experience.

---

# 7. Pipeline guardrails

Do not:

- generate assets before evidence/scene grammar is approved;
- use art detail to hide weak question design;
- substitute screenshots of source art for runtime/device captures;
- add huge/uncurated object packs just to claim variety;
- remove vector fallback or truth-driven reveal safety without equivalent evidence;
- introduce a second visual system that breaks Theme/Accessibility/renderer conventions;
- build narrative-specific asset libraries before the future Threads gate is passed.

Every asset must serve the Witness Moment: it either establishes place, supports a fair detail, clarifies evidence, or reinforces calm premium atmosphere.

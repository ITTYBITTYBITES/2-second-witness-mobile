# Scene Investigation Content Style Guide

**Status:** Approved Gate 3 prerequisite
**Applies to:** Office, Kitchen, and Workshop production templates
**Deferred:** Museum, Vehicle, and Outdoor assets

## 1. Visual Objective

Scene Investigation should feel like a premium illustrated editorial puzzle, not a debug layout, generic icon grid, children’s worksheet, casino game, or collection of unrelated stock assets.

Every generated scene must feel intentionally art-directed even though its objects, attributes, and placement are procedural.

## 2. Core Style

- Clean stylized 2D illustration
- Three-quarter or gentle top-down perspective within one scene
- Consistent line weight and object perspective
- Soft geometric forms with recognizable silhouettes
- Restrained material texture
- Soft ambient shadows
- Clear foreground/background separation
- No photorealism requirement
- No readable micro-text
- No object-name labels inside scored scenes
- No lore, characters, story props, or unexplained symbols

## 3. Relationship to Application UI

The application remains dark and premium:

- Background: `#0F0F12`
- Surface: `#1E1E26`
- Primary focus: `#6A3DFF`
- Success: `#2EE6A6`
- Warning: `#FFC857`
- Error: `#FF4D5E`

Generated scenes sit inside a clear scene card and may use lighter category palettes. Application chrome must never visually merge with challenge evidence.

Purple is reserved primarily for selection, timer, focus, and reveal treatment. Do not make it the dominant color of every generated object.

## 4. Canvas and Coordinate System

- Authoring reference: 768 × 1050 logical scene canvas
- Runtime positions: normalized `0.0–1.0`
- Safe evidence region: 5% inset on every side
- Background/decorative band may extend outside the evidence region
- Question-eligible objects must remain fully inside the evidence region
- Standard object bounding boxes align to a hidden 4 × 4 or 5 × 4 composition lattice
- Final placement includes restrained jitter so scenes do not appear as obvious grids

The lattice is a fairness tool, not a visible design element.

## 5. Perspective

Each template owns one approved perspective and applies it to every object:

- Office: slight top-down desk perspective
- Kitchen: straight-on counter with slight top view
- Workshop: slight top-down workbench and vertical tool rail

Do not mix flat front-facing symbols with perspective objects in the same scene.

## 6. Shape Language

### Primary objects

- Recognizable silhouette at mobile size
- Moderate corner radius
- One dominant body shape
- One or two identifying details
- Consistent outline or edge treatment

### Small details

- Must reinforce identity or provide an approved attribute
- Never use decorative noise as required evidence
- Minimum line/detail thickness: 3 logical pixels at reference size

### Decorative objects

- Lower contrast than question-eligible objects
- Simplified detail
- Must not resemble eligible objects closely enough to create false counts

## 7. Line and Shadow Treatment

- Primary outline: 2–4 logical pixels depending on object size
- Outline color: dark neutral derived from `#24242C`, not pure black
- Interior detail line: approximately 70% of primary outline weight
- Shadow direction: consistent lower-right offset
- Shadow opacity: 12–22%
- No heavy glow on scene objects
- Reveal glow is temporary and controlled by presentation, not baked into assets

## 8. Color System

### Shared accessible object palette

- Deep blue: `#3F6FAE`
- Sky blue: `#6DAEDB`
- Forest green: `#4F8A65`
- Mint green: `#78B89A`
- Warm red: `#C95F5F`
- Orange: `#D98945`
- Golden yellow: `#D9AD4A`
- Violet: `#7660A8`
- Warm neutral: `#A98768`
- Cool neutral: `#76808F`

### Rules

- A color question uses colors separated by both hue and luminance under the active palette.
- Similar colors may increase visual difficulty only when color is not the required answer.
- No required distinction may rely only on red versus green.
- High-contrast mode substitutes approved accessible variants rather than post-processing the entire scene.
- Background colors maintain sufficient separation from every eligible object.

## 9. Template Art Direction

### Office

**Mood:** Calm, organized, inviting.

**Palette:** Cool slate, paper cream, muted green, warm wood accent.

**Composition:** Clear desk zones, limited background shelf/detail band.

**Visual hierarchy:** Large notebook/device anchors, medium containers, small writing/accessory details.

**Premium cues:** Paper layering, subtle desk grain, soft window light, restrained plant/decorative forms.

**Avoid:** Corporate logos, readable documents, tiny keyboard letters, clutter that resembles scattered garbage.

### Kitchen

**Mood:** Warm, clean, active but not busy.

**Palette:** Cream, terracotta, sage, muted appliance blue, natural wood.

**Composition:** Counter plane, backsplash band, cabinet/shelf hints, preparation and serving zones.

**Visual hierarchy:** Appliance/container anchors, medium food and utensils, small garnish/decorative details.

**Premium cues:** Ceramic highlights, soft food color variation, subtle tile/backsplash geometry.

**Avoid:** Photoreal food, brand packaging, knives presented threateningly, spills as required evidence.

### Workshop

**Mood:** Focused, capable, organized complexity.

**Palette:** Charcoal, steel blue, muted orange, wood, safety yellow accents.

**Composition:** Workbench plane, tool rail/pegboard, project and hardware zones.

**Visual hierarchy:** Large tools/equipment anchors, medium project materials, small fasteners/details.

**Premium cues:** Brushed metal highlights, clean wood grain, structured storage, intentional wear kept subtle.

**Avoid:** Dangerous action, weapons, illegible hardware piles used as required counts, excessive grime.

## 10. Object Asset Requirements

Every production object archetype requires:

- Stable object ID
- Player-readable name stored in data, not drawn on the asset
- Template/category tags
- Question eligibility
- Similarity group
- Default size class
- Minimum rendered size
- Pivot and bounding box
- Approved color variants
- Optional state variants
- Orientation support
- Container/placement permissions
- Reveal highlight bounds
- Accessibility metadata

### Gate 3 production method

- Each implemented template uses one approved empty premium raster background.
- Question-eligible objects use the family’s deterministic vector renderer.
- Fixed background geometry is never counted or used as required answer evidence.
- Reveal outlines are rendered separately from both backgrounds and objects.

### Preferred source format

- SVG or deterministic vector drawing for scalable question-eligible objects
- Transparent PNG only when texture detail cannot be represented cleanly in vectors
- Source artwork retained outside generated import caches

### PNG requirements

- At least 2× intended maximum rendered dimensions
- Transparent background
- Tight but non-clipping bounds
- No baked scene shadow beyond the approved object shadow allowance

## 11. Procedural Composition Rules

- Every scene needs one or two visual anchors.
- Eligible objects form a readable scan path across the canvas.
- Decorative density increases gradually by difficulty.
- Empty space remains intentional at every tier.
- Similar objects must retain enough separation for individual recognition.
- Repeated objects use controlled spacing rather than random piles.
- Background details never intersect reveal highlights.
- Jitter must not create accidental alignment, overlap, or adjacency ambiguity.

## 12. Scene Density Targets

### Beginner

- 8–10 eligible objects
- 0–2 decorative objects
- Strong anchors and generous spacing

### Standard

- 11–14 eligible objects
- 2–4 decorative objects
- Moderate spacing and controlled similarity

### Advanced

- 13–17 eligible objects
- 3–6 decorative objects
- Denser scan path and more competing details

### Expert

- 15–20 eligible objects
- 4–7 decorative objects
- High but organized density

Expert scenes must still look designed. Random clutter is not premium difficulty.

## 13. Reveal Style

- Restore the exact scene without regeneration.
- Reduce unrelated-object emphasis by no more than 20–30%.
- Draw a 3–5 pixel focus outline around evidence.
- Use a restrained purple pulse or sweep for no more than 700 ms unless reduced motion is enabled.
- Count questions highlight every member with matching numbered or synchronized outlines.
- Relationship questions connect relevant objects with a thin focus line.
- Incorrect answers use the same evidence reveal as correct answers; do not cover the scene with red.

## 14. Animation

- Scene entry: 150–250 ms fade/settle
- Conceal: 150–250 ms
- Reveal: 200–350 ms
- No object bounces during observation
- No continuous motion unless a later template explicitly requires it
- Reduced motion uses opacity-only transitions

Animation may polish presentation but may not change object truth or hide evidence.

## 15. Audio and Haptics Relationship

Visual events may request understated audio/haptics:

- Observation start: soft focus cue
- Final timing moment: restrained cue
- Conceal: neutral transition
- Answer: quiet selection click
- Reveal: warm confirmation or gentle correction

No sound or haptic may indicate the correct answer before submission.

## 16. Asset Naming

```text
scene_investigation/
  shared/
    object_<name>_<variant>.svg
  office/
    office_<name>_<variant>.svg
  kitchen/
    kitchen_<name>_<variant>.svg
  workshop/
    workshop_<name>_<variant>.svg
```

Use lowercase snake_case. Asset filenames never contain difficulty labels because difficulty belongs to data policies.

## 17. Quality Rejection Rules

Reject an asset or composed scene if:

- Perspective conflicts with the template
- Line weight differs visibly from the pool
- Silhouette is unclear at minimum size
- Required detail disappears on a phone viewport
- Colors fail approved contrast/palette checks
- An object resembles another outside an intentional similarity group
- Text, logos, or generation artifacts appear
- Lighting/shadow direction conflicts
- Composition looks like a raw grid or random scatter
- Reveal bounds do not align with visible evidence

## 18. Review Process

Before an object pool becomes production content:

1. Review silhouettes at minimum mobile size.
2. Review all color variants in normal and high-contrast modes.
3. Generate contact sheets for each template.
4. Generate at least 100 composition previews per template.
5. Reject visual outliers before fairness stress testing.
6. Run manual observation sessions on phone-size viewports.
7. Approve the pool as one coherent set.

## 19. Deferred Template Rule

Do not create Museum, Vehicle, or Outdoor production assets during Gate 3. Their written template specifications remain approved for later content expansion only after Office, Kitchen, and Workshop demonstrate fairness, replayability, visual quality, and retention.

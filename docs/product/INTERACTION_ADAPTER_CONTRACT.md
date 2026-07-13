# Interaction Adapter Contract

**Status:** Implemented in Phase 5

## Boundary

```text
PresentationProfile
→ InteractionProfile
→ InteractionAdapterRegistry
→ InteractionAdapter
→ generic payload
→ ChallengeSessionService
→ family ScoringPolicy
```

The shared layer collects interaction payloads. It never interprets family meaning or correctness.

## InteractionProfile

Declares:

- Stable profile ID/version
- Interaction mode
- Registered adapter ID
- Optional accessible adapter ID
- Payload schema metadata
- Adapter configuration metadata

PresentationProfile references the InteractionProfile ID. ChallengeFamilyRegistry validates profile ownership and adapter availability.

## Adapter interface

Every adapter:

- Extends `InteractionAdapter`
- Declares a stable adapter ID
- Configures from InteractionProfile plus serialized ChallengeInstance data
- Mounts into the established Recall interaction host
- Emits `interaction_submitted(payload)` exactly once
- Disables itself after submission
- Does not score or interpret the payload

## Implemented adapters

- `single_choice`
- `multiple_choice`
- `spatial_tap`
- `region_selection`
- `ordering`
- `sequence_input`

Future manifest-declared modes:

- `drag_drop`
- `text_entry`

New adapters register through `InteractionAdapterRegistry` without family branches.

## Payload ownership

- Single Choice emits the selected value.
- Multiple Choice emits an array of selected values.
- Spatial Tap emits normalized `x`/`y` coordinates and input mode.
- Region Selection emits a region ID.
- Ordering emits an ordered array.
- Sequence Input emits an ordered token array.

Family ScoringPolicy owns answer interpretation. For example, only Spot the Difference knows whether coordinates intersect its changed target.

## Accessibility

A family may declare an accessible adapter alternative. The generic host chooses it from shared accessibility preferences. Spot the Difference uses spatial tap primarily and single choice as its accessible alternative.

Adapters must preserve touch targets, text scaling, contrast, Reduced Motion, safe areas, and hidden-information rules.

## Compatibility

Scene Investigation and Flash Words explicitly declare the default Single Choice InteractionProfile. Their player behavior, answer payloads, scoring, routes, and results remain unchanged.

## Enforcement

Static architecture checks reject Phase 5 family IDs/classes in shared runtime, interaction registry/adapters, and the generic Recall host. The 47-file post-Phase-5 shared baseline protects future expansion from unreviewed shared changes.

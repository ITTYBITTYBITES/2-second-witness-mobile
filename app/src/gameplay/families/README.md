# Challenge Families

Family modules contain Challenge Type-specific behavior behind shared runtime contracts.

Families register through `manifest.json`. The registry loads module scripts generically, validates their family/template/presentation contracts, and exposes them to `ChallengeSessionService`.

## Gate 1 family

`scene_investigation/` is the reference compatibility module. It adapts the five deterministic fixtures into templates and instances. Its generator is deterministic and fixture-backed; production procedural templates are deferred.

## Boundary

A family may provide:

- Family and template definitions
- Generator and validator
- Difficulty and exposure policies
- Presentation profile
- Tutorial metadata
- Artwork/audio/animation references
- Progress-rule references

A family may not create alternate navigation, persistence, analytics transport, accessibility, audio transport, or session orchestration.

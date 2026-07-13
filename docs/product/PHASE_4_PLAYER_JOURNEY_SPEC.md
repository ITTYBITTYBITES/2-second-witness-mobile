# Phase 4 — Player Journey and Product Experience Specification

**Date:** 2026-07-12
**Status:** Implemented locally

## Goal

Complete the player-facing lifecycle around the established Challenge Runtime without creating alternate gameplay, progression, save, navigation, or recommendation systems.

## Runtime invariant

Every Program and direct play action follows the existing pipeline:

```text
Request
→ Challenge Type
→ Template
→ Difficulty
→ Exposure
→ Generation
→ Validation
→ Presentation
→ Response
→ Result
→ Witness Progress
→ Recommendation
→ Home or Continue
```

Programs select registered Challenge Types and templates. They never generate, validate, score, present, or navigate gameplay independently.

## Home

Home provides:

- Recommended Play Now with explanation
- Continue for an unfinished Program or recent Challenge Type
- Challenge Library
- Active Programs entry with a data-driven featured Program
- Profile, Achievements, and Settings

Home remains free of concrete family IDs and Challenge Type names.

## Programs

`ProgramService` loads content definitions and owns selection policy/progress only.

Initial Programs:

- Daily Witness
- Observation Bootcamp
- Rapid Recall
- Mixed Rotation
- Favorites Run
- Weekend Challenge

Supported generic policies:

- Daily deterministic rotation
- Gameplay-focus matching
- Least-used mixed rotation
- Favorite Challenge Type selection
- Weekend availability
- Witness Level requirements

Program state records current round, total rounds, accuracy, family mix, completed runs, best run accuracy, and last play. Continue prioritizes an unfinished Program. Completing the declared round count returns through the Result/runtime lifecycle and clears resume state.

## Challenge Library and favorites

Catalog records include:

- Family-owned gameplay focus
- Family-owned recommendation weight
- Favorite state
- Artwork, requirements, progress, accuracy, Mastery, best streak, tutorial, and Play

Favorites persist in the existing profile and drive Favorites Run without introducing a separate content registry.

## Witness Profile

Profile includes:

- Witness Level and current/next Witness Rank
- Witness Record
- Accuracy
- Current and best streak
- Fastest Response
- Family Mastery
- Challenge History
- Recently Played
- Favorite Challenge Types
- Program Record
- Achievements
- Collection Progress

Collection Progress derives meaningful goals from discovered Challenge Types, collected achievements, and completed curated runs. It remains additive and future-ready for Phase 5 item expansion.

## Achievements

The data-driven framework is preserved and expanded with:

- Versatile Witness
- Curator
- First Journey
- All Angles

New criteria remain generic: unique played families, favorites count, completed Program runs, and the number of families above a Mastery threshold.

## Settings

The existing premium Settings surface remains the single control point for accessibility, Reading Comfort, Color Assistance, audio, haptics, theme, privacy, analytics consent, credits, and About.

## Extensibility acceptance

- Program code contains no concrete family IDs.
- Program selection consumes the registered Challenge Type catalog.
- New families automatically participate in mixed/daily selection.
- Focus Programs use family-owned gameplay-focus tags.
- Recommendation weights come from family metadata.
- No Program directly navigates to presentation/response/result routes.
- Existing direct play and tutorial regressions remain unchanged.

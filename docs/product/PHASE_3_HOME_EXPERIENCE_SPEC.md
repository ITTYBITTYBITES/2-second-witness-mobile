# Phase 3 — Home Experience Specification

**Status:** Implemented
**Date:** 2026-07-12
**Product goal:** Make the application feel like a finished product hub while remaining ready for additional Challenge Types.

## Product principles

- Home is data-driven and contains no concrete Challenge Type IDs or titles.
- **Play Now** asks `RecommendationService` for the next round and launches only through `ChallengeSessionService`.
- **Continue** resumes the most recently played Challenge Type/template; when no recent round exists, it falls back to the current recommendation.
- Every playable family appears automatically in the **Challenge Library** when its manifest entry is enabled and its metadata is player-visible.
- Programs remain visible as **Coming Soon** and do not create a second gameplay path.
- Player-facing copy remains entertainment-first and uses Witness Progress language.

## Home data contract

`RecommendationService.get_home_snapshot(player_state)` returns:

- Play Now recommendation
- Continue recommendation and fallback state
- Daily featured Challenge Type
- Available Challenge Type catalog
- Recently played Challenge Type
- Achievements in progress
- Witness Level, Witness Rank, progress, and streak summary

Home renders the snapshot. It does not query or branch on Scene Investigation, Flash Words, template IDs, or family classes.

## Recommendation behavior

### Play Now

1. Prefer a player-visible, unlocked Challenge Type with zero plays.
2. Once all unlocked types have been introduced, balance by Mastery and play count.
3. Penalize an immediate repeat when another unlocked type is available.
4. Return a reason and player-facing reason text.

### Continue

1. Read `last_played_family_id` and `last_played_template_id` from Witness Progress.
2. Verify the family still exists and is unlocked.
3. Resume the recent template when valid; otherwise use that family's default template.
4. Fall back to Play Now when no valid recent type exists.

### Featured

Select one unlocked Challenge Type deterministically from the local calendar date. Multiple reads on the same date return the same feature.

## Challenge Library card contract

Every card displays:

- Artwork
- Challenge Type name
- Short description
- Witness Level requirement and lock state
- Rounds completed and progress points
- Accuracy
- Mastery progress
- Best streak
- Play action
- Tutorial replay action from `TutorialProfile`

A locked card is visually distinct and cannot launch gameplay. Runtime-level unlock enforcement provides a second guard behind the UI.

## Profile

Profile displays:

- Witness Level
- Witness Rank
- Observation Record
- Accuracy
- Fastest Response
- Current Streak
- Best Streak
- Family Mastery
- Challenge History
- Achievement summary and route
- Collections placeholder designed for future data

`PlayerProgressService` remains an adapter over `ProfileService`; no second save system is introduced.

## Achievements

Definitions are stored in `app/src/gameplay/progression/achievements.json` and evaluated by `AchievementService`.

Current achievements:

1. First Witness
2. Keen Eye
3. Perfect Memory
4. Sharp Shooter
5. Word Watcher
6. Scene Specialist
7. Consistency
8. Comeback
9. Marathon
10. Flawless Finish

Unlocks are retained, emitted once, persisted through `ProfileService`/`SaveService`, and exposed as full status records or a small in-progress preview for Home.

## Settings surface

Phase 3 keeps existing persisted settings and presents:

- Audio level
- Music
- Sound effects
- Haptics
- Reading Comfort Mode
- Text Size
- Reduced Motion
- High Contrast
- Privacy
- Credits
- About

Reading Comfort Mode is a shared setting consumed by Flash Words through its family-owned difficulty and exposure policies.

## Routes

- `home` — data-driven hub
- `experiences` — player-facing Challenge Library
- `profile` — Witness record and progress
- `achievements` — non-tab collection screen with Back behavior
- `settings` — preferences and information

Gameplay continues to use the existing Observation, Recall, and Result routes selected through each family's `PresentationProfile`.

## Accessibility and responsive UI

- Scroll containers protect smaller portrait displays.
- Buttons retain large touch targets.
- Text wraps where content may grow, while compact status values reserve non-wrapping width.
- Theme tokens style dark/light surfaces.
- Reduced Motion, High Contrast, Text Size, haptics, Comfortable Timing, and Reading Comfort Mode remain available.

## Acceptance criteria

- Home contains no production family IDs or names.
- Play Now and Continue route through runtime services.
- The catalog and daily feature are service-driven.
- Two production Challenge Types render without UI branches.
- All required profile, achievement, and settings fields are visible.
- Achievements persist and unlock only once.
- Existing runtime, family, content, tutorial, and first-run regressions remain green.

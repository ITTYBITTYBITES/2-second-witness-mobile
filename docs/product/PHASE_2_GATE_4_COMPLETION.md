# Phase 2 Gate 4 Completion — Flash Words

**Date:** 2026-07-12
**Status:** Local production implementation and release validation complete
**Physical-device review:** Required before store release

## Architectural milestone

Flash Words was added as the second production Challenge Type without modifying protected Engine/shared infrastructure.

Final baseline verification:

```text
FLASH_WORDS_ENGINE_UNCHANGED_PASS files=71
```

Protected areas include Core, Systems, shared UI, shared runtime, contracts, navigation, and project configuration.

## Production family

Flash Words adds only family, content, asset, test, and documentation files plus one production manifest entry.

Family modules:

- `FlashWordsFamily`
- `FlashWordsGenerator`
- `FlashWordsValidator`
- `FlashWordsDifficultyPolicy`
- `FlashWordsExposurePolicy`
- `FlashWordsScoringPolicy`
- `FlashWordsSceneView`
- Family-specific tutorial

## Production templates

### Single Word Recognition

One word flashes, disappears, and is selected from four options.

### Word Pair Order

Two sequential words must be recalled in exact order.

### Word Stream Presence

Three to five words appear sequentially; the player identifies which option appeared.

## Word database

- 373 reviewed production words
- High-frequency/familiar vocabulary
- Length metadata
- Frequency band
- Letter-uniqueness score
- Visual-similarity group
- Syllable count
- Semantic category
- Orthographic neighbors
- Safe-content approval

Static content validation rejects duplicate IDs/words, missing metadata, prohibited terms, unsupported templates, and missing assets.

## Distractor generation

Template-controlled categories:

- Orthographic neighbors
- Single-letter substitutions
- Transpositions
- Similar-length words
- Semantic neighbors
- Reversed pair order
- Single-word pair substitutions

Every accepted instance has unique options and exactly one correct answer.

## Timing and difficulty

### Single Word

- Beginner: 3–4 seconds
- Standard: 2–3 seconds
- Advanced: 1.25–2 seconds
- Expert: 0.8–1.2 seconds

### Pair Order, per word

- Beginner: 2.5–3.5 seconds
- Standard: 1.75–2.5 seconds
- Advanced: 1–1.75 seconds
- Expert: 0.75–1.1 seconds

### Word Stream

Resolves display duration, inter-word interval, and total sequence length independently.

Difficulty axes also include word length, frequency, orthographic similarity, sequence length, distractor categories, and target position.

## Reading Comfort Mode

Family-owned Reading Comfort Mode provides:

- Larger typography
- Longer exposure
- Wider spacing
- Longer intervals
- Reduced animation

It uses the existing SettingsService extension API and does not reduce Witness Progress.

## Family tutorial

Flash Words tutorial teaches:

1. Single-word flash
2. Guided recognition
3. Exact letter comparison
4. Pair order
5. Reading Comfort Mode
6. Single Word practice

It is loaded through TutorialProfile and the generic family tutorial host.

## Presentation and results

Flash Words uses a family typography renderer through the existing Observation, Recall, and Result routes.

Results explicitly show:

```text
You selected:
<player response>

Correct:
<correct response>

Difference:
<letter or order comparison>
```

The family renderer supplies rhythmic presentation pulses and comparison reveal behavior without shared UI branches.

## Audio

Family content adds:

- Flash pulse
- Inter-word interval
- Reveal click
- Correct chime
- Incorrect descending tone

Audio remains understated and never identifies the correct answer before submission.

## Witness Progress

Flash Words records:

- Plays and accuracy
- Current, best, and incorrect streaks
- Flash Words Mastery/confidence
- Template/mode history
- Recent words, seeds, and signatures
- Difficulty history
- Progress points

All persistence continues through existing PlayerProgressService, ProfileService, and SaveService.

## Release validation

| Validation | Result |
|---|---:|
| Fresh Godot import | Pass, no errors or warnings |
| Flash Words production flow | 24 passed, 0 failed |
| Flash Words tutorial | 13 passed, 0 failed |
| Flash Words policies | 16 passed, 0 failed |
| Flash Words 20-round variety | 7 passed, 0 failed |
| Seed reproducibility audit | 100 sampled seeds, 0 failures |
| Flash Words release stress | 120,000 generated, 0 failed |
| Stress scope | 10,000 seeds/template/tier |
| Word/content validation | 373 words, 3 templates, pass |
| Engine baseline | 71 protected files unchanged |
| Source loading | 81 loaded, 0 failed |
| Gate 1 runtime regression | 23 passed, 0 failed |
| First-run regression | 16 passed, 0 failed |
| Fixture compatibility | 30 passed, 0 failed |
| Runtime Hardening | 31 passed, 0 failed |
| Family Tutorial architecture | 12 passed, 0 failed |
| Scene Investigation production | 23 passed, 0 failed |
| Scene Investigation tutorial | 18 passed, 0 failed |
| Scene Investigation scoring | 21 passed, 0 failed |
| Scene Investigation difficulty | 12 passed, 0 failed |
| Scene Investigation variety | 10 passed, 0 failed |
| Static architecture enforcement | Pass |

Flash Words stress performance for 40,000 instances per template:

- Single Word: approximately 68.7 seconds
- Pair Order: approximately 96.7 seconds
- Word Stream: approximately 76.5 seconds

Single Word has a finite 373-word truth space, so arbitrary stress seeds may repeat words. Runtime recent-word and recent-signature policies prevent immediate player-session repetition.

## Visual validation

Local artifacts are stored outside the exported app under:

`docs/product/artifacts/flash_words/`

They include:

- Template observation previews
- Template comparison reveals
- Full Observation → Recall → Result captures
- Observation, reveal, and full-flow contact sheets

See [`challenge-types/FLASH_WORDS_VISUAL_REVIEW.md`](challenge-types/FLASH_WORDS_VISUAL_REVIEW.md).

## Gate 4 success criterion

Met:

> Flash Words reached production quality without changing the Engine, shared runtime, tutorial host, navigation, or other protected infrastructure.

Two production Challenge Types now run through the same platform:

- Scene Investigation
- Flash Words

## Remaining release work

- Physical-device typography review
- Reading Comfort Mode review on small phones
- Rhythmic audio/haptic balancing
- Human rapid-sequence readability sessions
- Human replay/retention feedback

These do not block local Gate 4 completion.

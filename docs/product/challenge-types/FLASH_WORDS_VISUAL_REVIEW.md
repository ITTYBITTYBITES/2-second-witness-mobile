# Flash Words — Local Visual Review

**Status:** Local rendered review passed
**Physical-device review:** Required before store release

## Reviewed artifacts

Stored under `docs/product/artifacts/flash_words/`:

- Template observation/reveal previews
- `flash_words_observation_contact_sheet.png`
- `flash_words_reveal_contact_sheet.png`
- Full 1080 × 1920 Observation, Recall, and Result captures
- `flash_words_flow_contact_sheet.png`

## Observation

- Word presentation is horizontally centered and no longer wraps letter-by-letter.
- Single words use large near-white text on a dark focused stage.
- Pair and stream modes show restrained sequence-position indicators.
- Gameplay chrome remains minimal and consistent with Two Second Witness.

## Recall

- Question and options remain readable with large touch targets.
- Answer casing is consistent and does not reveal correctness.
- Typography presentation is visually distinct from Scene Investigation.

## Result

- Exact correct word or sequence is restored.
- Result shows player selection, correct response, and explicit letter/order difference.
- Incorrect feedback remains restrained rather than punitive.
- Witness Progress, mastery, replay, next challenge, and Home remain available.

## Decision

Flash Words passes the local visual gate as a polished typography-based Challenge Type. It does not reuse Scene Investigation scene artwork or presentation behavior.

Remaining device work:

- Verify type size at all supported font scales.
- Verify Reading Comfort Mode on small phones.
- Balance rhythmic audio and haptics.
- Confirm rapid sequence readability with human players.

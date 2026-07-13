# Flash Words Content Style Guide

**Status:** Implemented and locally reviewed in Gate 4

## Visual identity

Flash Words is a premium typography challenge, not a vocabulary worksheet or reading assessment.

- Dark focused stage
- One central word or compact word sequence
- Large, clean, high-contrast typography
- Restrained eye/focus motif
- Minimal decoration during presentation
- No flashing patterns, strobing, or unnecessary motion

## Typography

- Neutral sans-serif family with highly distinct glyphs
- Medium or semibold weight
- Minimum mobile presentation size: 72 logical pixels for a single word
- Preferred single-word size: 96–132 logical pixels
- Pair/stream size: 72–104 logical pixels
- Generous letter spacing only when it improves recognition
- No condensed, script, novelty, or distressed fonts
- No mixed fonts inside one challenge

Avoid word candidates where the selected font makes glyphs ambiguous, including difficult `I/l`, `O/0`, or punctuation combinations.

## Case

Initial English production content uses uppercase consistently. Answer options use the same case so casing never reveals correctness.

## Stage

- Background: `#0F0F12`
- Word: near-white `#F5F3FA`
- Secondary instruction: `#B8B8CC`
- Focus accent: `#6A3DFF`
- No color-dependent word questions in the initial implementation

## Presentation motion

- Entry fade: 80–140 ms
- Stable full-opacity exposure
- Conceal fade: 80–140 ms
- Reduced motion: immediate opacity change
- No scale bounce, rotation, shake, or moving text

## Sequence treatment

- One word at a time
- Neutral interval between words
- Fixed central alignment
- Optional small sequence-position dots outside the word area
- No persistent previous-word ghosting

## Recall and result

- Answer options use large touch-friendly rows
- Correct reveal restores the exact word or sequence
- Incorrect reveal compares player choice and correct response without punitive color flooding
- Explanation identifies the changed letters, order, or stream position when useful

## Audio

- Soft focus cue at presentation start
- Quiet neutral tick between sequence words
- Conceal cue
- Understated correct/incorrect reveal
- Audio never encodes word identity or correctness before submission

## Accessibility

- Font scaling respects shared accessibility settings
- Comfortable Timing extends exposure and intervals
- Reading Comfort Mode uses larger text, wider spacing, longer minimum exposure, longer intervals, and reduced animation without reducing progress
- Reduced motion uses opacity-only transitions
- Screen reader describes controls but does not speak hidden word content during a scored flash
- High contrast preserves near-white text on dark stage
- No required color distinction

## Content review

Reject a word or sequence if:

- It is obscure, offensive, sensitive, or age-inappropriate
- Font rendering creates ambiguous glyphs
- A distractor could reasonably be considered equivalent
- Localization changes length beyond template bounds
- The word clips at maximum font scaling
- Letter changes are too subtle for the active tier
- The result explanation cannot clearly show the difference

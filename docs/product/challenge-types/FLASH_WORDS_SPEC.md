# Flash Words — Challenge Type Specification

**Status:** Production-complete; expanded in Phase 5.5
**Implementation:** Production family, content, tutorial, policies, presentation, scoring, progress, and validation complete
**Internal family ID:** `flash_words`
**Player-facing name:** Flash Words
**Specification version:** 1.0

## 1. Identity

### Player-facing description

> Catch a word or short sequence in a quick flash, then choose exactly what appeared.

### Gameplay focus

- Recognition
- Recall
- Focus
- Sequence order
- Attention to letter detail

### Gameplay fantasy

The player catches a fleeting signal and proves what they actually saw. A miss should feel like one letter or one position slipped past—not like an obscure spelling quiz.

## 2. Player goal

Recognize and recall visually presented words or short word sequences after they disappear.

The game never asks for definitions, educational attainment, reading level, or vocabulary evaluation.

## 3. Core loop

```text
Brief
→ Word or sequence flash
→ Neutral conceal
→ Recall question
→ Player choice
→ Exact typography reveal
→ Result and Witness Progress
→ Recommendation
→ Replay or Home
```

## 4. Initial production templates

### Single Word Recognition

**Template ID:** `single_word_v1`

One word appears, disappears, and must be selected from four options.

Generation variables:

- Word length
- Word familiarity band
- Exposure duration
- Distractor edit distance
- Shared prefix/suffix
- Letter-position changes

Question:

> “Which word appeared?”

### Word Pair Order

**Template ID:** `word_pair_order_v1`

Two words appear sequentially. The player selects the exact order.

Generation variables:

- Word lengths
- Pair semantic independence
- Per-word exposure
- Inter-word interval
- Distractor order swaps
- Similar replacement words

Question:

> “Which pair appeared, in order?”

### Word Stream Presence

**Template ID:** `word_stream_presence_v1`

Three to five words appear one at a time. The player identifies which option appeared in the stream.

Generation variables:

- Sequence length
- Per-word exposure
- Inter-word interval
- Word-length similarity
- Distractor similarity
- Target stream position

Question:

> “Which word was in the sequence?”

### Position Catch

**Template ID:** `position_catch_v1`

Three to five words appear one at a time. The player identifies the word shown at one exact numbered position.

Generation variables:

- Sequence length
- Target position
- Per-word exposure
- Inter-word interval
- Orthographic distractor similarity
- Presented-word exclusion from distractors

Question:

> “Which word appeared in position N?”

## 5. Word content

Initial English production content requires at least:

- 300 approved high-frequency, familiar words
- Stable word IDs
- Length
- Frequency band
- Letter-uniqueness score
- Visual-similarity group
- Syllable count
- Orthographic-neighbor metadata
- Safe-content approval
- Localization key

Content restrictions:

- No offensive, medical, legal, political, sexual, violent, traumatic, or discriminatory terms
- No regional slang with unstable meaning
- No obscure abbreviations
- No trademark-dependent words or brand names
- No proper names in v1
- No obscure technical terms
- No words differing only by punctuation
- No duplicate spellings

The dormant Foundation Flashword list may supply regression fixtures only. Production content uses a new reviewed word pack.

## 6. Seeded generation

```text
Resolve template and difficulty
→ Resolve timing
→ Select eligible word length/familiarity band
→ Select correct word(s)
→ Build orthographically valid distractors
→ Validate glyphs and answer uniqueness
→ Build exact reveal comparison
→ Produce ChallengeInstance
```

Reproduction identity includes family, template, generator, validator, scoring, difficulty, exposure, content versions, and seed.

## 7. Distractor generation

### Distractor categories

- **Orthographic neighbor:** same length and similar letter pattern, with at least one valid changed letter
- **Single-letter substitution:** `plant` / `plane`
- **Transposition:** `form` / `from`
- **Similar length:** `bridge` / `rocket`
- **Semantic neighbor:** `cat` / `dog`

Every template declares its allowed categories. No category may produce the presented word twice.

### Single word

- Same or adjacent length at Beginner
- Same length at Standard and above
- Controlled edit distance
- Allowed categories vary by difficulty
- No duplicate options
- No equivalent spelling variants
- Exactly one presented word

### Pair order

- Correct ordered pair
- Reversed order when words differ
- One-word substitutions
- No option may duplicate the correct sequence

### Stream presence

- Exactly one option appeared
- Absent distractors match length/familiarity band
- No morphological equivalent that creates ambiguity

## 8. Difficulty axes

- Word length
- Familiarity
- Orthographic similarity
- Shared prefix/suffix length
- Number of changed letters
- Sequence length
- Exposure duration
- Inter-word interval
- Distractor similarity
- Target position in stream

Difficulty is a vector. A longer exposure with highly similar words may be harder than a short exposure with very distinct words.

## 9. Exposure policy

### Single word

- Beginner: 3.0–4.0 seconds
- Standard: 2.0–3.0 seconds
- Advanced: 1.25–2.0 seconds
- Expert: 0.8–1.2 seconds

### Word Pair Order

Timing applies per word:

- Beginner: 2.5–3.5 seconds
- Standard: 1.75–2.5 seconds
- Advanced: 1.0–1.75 seconds
- Expert: 0.75–1.1 seconds

### Word Stream Presence

The policy resolves three independent values:

- Display duration per word
- Inter-word interval
- Total sequence length

Sequence length and display speed do not increase together automatically. A longer stream may retain longer display time.

### Reading Comfort Mode

Reading Comfort Mode is an accessibility option, not a lower score tier. It provides:

- Larger text
- Longer minimum exposure
- Increased letter and line spacing
- Longer inter-word intervals
- Reduced animation

Comfortable Timing and Reading Comfort Mode do not reduce normal Witness Progress.

## 10. Fairness contract

Every accepted instance must verify:

- All presented words exist in the approved pack
- Exactly one accepted answer
- No duplicate answer option
- Distractors were not presented
- Font can render every glyph
- Text fits the safe presentation area
- Word length is inside policy
- Exposure and intervals are inside policy
- Sequence length is inside policy
- Reveal contains exact presented order
- Complete reproduction identity
- No prohibited content

## 11. Accessibility

- Large high-contrast typography
- No color-only questions
- Comfortable Timing support
- Reduced-motion opacity transitions
- Font-scale safe layout
- Screen reader labels for controls
- Reading Comfort Mode
- Hidden scored content is not spoken during presentation
- Localized words are validated independently per language

## 12. Presentation profile

**Profile ID:** `flash_words.production.v1`

- Presentation route: existing shared Observation route through a family renderer
- Presentation mode: `flash_typography_sequence`
- Response route: existing Recall route
- Response mode: `single_choice`
- Result route: existing Result route
- Reveal mode: `word_sequence_comparison`

No new navigation route is required.

## 13. Family-owned scoring

Flash Words supplies its own ScoringPolicy.

Initial scoring:

- Binary correctness
- Base correct score
- Difficulty component based on word/sequence complexity
- Small capped response-time component only after fairness review
- No Beginner speed component
- Bounded mastery change
- Incorrect answers receive small participation progress

The shared ResultService remains unchanged.

## 14. Result behavior

Required result data:

- Outcome
- Player response
- Correct word or sequence
- Exact presented word(s)
- Letter/order comparison
- Difficulty performance
- Gameplay focus
- Witness Progress
- Flash Words Mastery
- Recommendation
- Replay metadata

Reveal restores the exact typography and emphasizes changed letters or sequence order without punitive animation.

The Result presentation explicitly shows:

```text
You selected:
<player response>

The correct word was:
<correct response>

The difference:
<letter or order comparison>
```

## 15. Witness Progress

Track:

- Plays and accuracy
- Current and best streak
- Single-word/pair/stream history
- Word-length history
- Difficulty axes
- Flash Words Mastery and confidence
- Recent seeds and signatures
- Recent words to prevent repetition

All writes use PlayerProgressService and the existing profile/save foundation.

## 16. Recommendation behavior

- Rotate templates after stable success
- Avoid recently presented words
- Reduce similarity or sequence length after repeated misses
- Increase one axis at a time
- Prefer content variety over constant speed reduction

## 17. Tutorial specification

Tutorial version 1:

1. Explain that one word will flash and disappear.
2. Show an untimed demonstration word.
3. Ask a guided two-option recognition question.
4. Reveal the exact word and changed letters.
5. Show a two-word sequence demonstration.
6. Launch a comfortable Single Word practice round.

Teach recognition, sequence order, and result comparison. Do not explain future words, word-pack selection, seed behavior, or mastery formulas.

## 18. Audio profile

- Rhythmic soft pulse before presentation
- Quiet neutral interval pulse between words
- Clean conceal click
- Clean selection click
- Short positive correct chime
- Subtle descending incorrect tone
- No spoken words in scored presentation
- No audio cue that identifies the correct option

## 19. Visual style

Follow [`FLASH_WORDS_STYLE_GUIDE.md`](FLASH_WORDS_STYLE_GUIDE.md).

No scene art assets are required. Typography, timing, spacing, and transitions carry the presentation.

## 20. Analytics

Privacy-respecting events:

- Tutorial completion/replay
- Template ID
- Difficulty axes
- Exposure/interval timing
- Candidate rejection rule ID
- Completion/abandonment
- Outcome and response time
- Replay and recommendation acceptance

Do not present or log reading assessment labels.

## 21. Stress testing

For each template and tier:

- Development: 2,000 seeds
- Release candidate: 10,000 seeds
- Zero ambiguous answers
- Zero duplicate options
- Zero prohibited words
- Zero text overflow at supported font scales
- Reproduction equality samples
- Rejection and fallback reproducible by seed
- Recent-word repetition prevented
- Stable generation performance

## 22. Gate 4 completion

Gate 4 completes when:

- Family tutorial is interactive and replayable
- Four production templates are playable
- Reviewed word content meets minimum size
- Generation and validators pass stress thresholds
- Typography renders cleanly at supported scales
- Results explain exact word/sequence differences
- Witness Progress and recommendations update
- Existing runtime and Scene Investigation tests remain green
- No family-specific Engine/runtime/navigation changes are required after tutorial architecture correction

## 23. Non-goals

- Definitions, spelling instruction, or vocabulary testing
- Spoken-word recognition
- Typed free-response input
- Sentences or paragraphs
- Color-word interference
- Multiplayer, leaderboards, or live events
- Museum, Vehicle, or Outdoor Scene Investigation content

## 24. Approval

- Challenge Type scope: approved
- Tutorial architecture correction: approved and required first
- Word-pack requirements: approved with frequency/similarity metadata
- Timing tiers: approved as revised
- Fairness rules: approved
- Reading Comfort Mode: approved
- Typography style: approved
- Gate 4 gameplay authorization: approved after tutorial architecture correction

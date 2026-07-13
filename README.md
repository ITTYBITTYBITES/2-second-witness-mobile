# Two Second Witness

> A premium observation game built around short, fair, highly replayable challenges.

**Publisher:** ITTYBITTYBITES
**Engine:** Godot 4.6.3
**Android package:** `com.ittybittybites.the2secondwitness`

## Project status

The **Foundation through Phase 5.5** are approved. **Phase 6 — Production Readiness** is locally complete. The five-family product has 20 templates, a frozen generic platform, atomic local saves, offline production defaults, and complete release-gate documentation. Human playtesting, signed-artifact review, and the physical Android sponsor-first boot gate remain open.

Five production Challenge Types run through the same shared platform:

- **Scene Investigation** — generated scenes, fair questions, and evidence reveals.
- **Flash Words** — rapid word and sequence recognition with exact comparison.
- **Spot the Difference** — paired visual comparison with Spatial Tap.
- **Object Recall** — isolated set memory with Multiple Choice.
- **Pattern Recall** — abstract ordered reconstruction with Sequence Input.

The product hub is data-driven: Play Now, unfinished-Program Continue, daily feature, Challenge Library, curated Programs, favorites, Profile, Collections, Achievements, and Settings consume runtime/catalog data rather than naming a Challenge Type.

Flash Words was added without changing 71 protected Engine/shared files. Phase 3 intentionally evolved shared product UI after that extensibility gate. Physical-device and human play review remain before store release.

## Product direction

Players are never taking tests. Players are solving moments.

Every round should create an **“I missed it.”** response, never **“That was unfair.”** Player-facing language emphasizes Observation, Recall, Recognition, Attention, Focus, Witness Progress, Challenge History, Witness Level, and Witness Rank.

## Current player journey

```text
Publisher Splash
→ Title and privacy acknowledgment
→ Family tutorial when required
→ Home product hub
   ├─ Play Now recommendation
   ├─ Continue recent Challenge Type
   ├─ Daily featured Challenge Type
   └─ Challenge Library
→ Observation / presentation
→ Recall / response
→ Result
→ Continue or Home
```

All gameplay launch paths enter `ChallengeSessionService`. The five fixed challenges remain executable as hidden deterministic regression fixtures.

## Product systems

### Validated Foundation

- Boot and splash flow
- App shell, routes, history, safe areas, and navigation chrome
- Save/Profile persistence
- Settings, accessibility, theme, audio, analytics, and content services
- Shared UI and error handling

### Shared Challenge Runtime

- Data-driven family discovery
- Session orchestration
- Difficulty and exposure policies
- Seeded generation
- Fairness validation, retries, and fallback
- Family tutorial and presentation profiles
- Family-owned scoring
- Canonical results
- Witness Progress
- Start, Continue, next-round, and daily recommendations

### Phase 3 product hub

- Data-driven Home snapshot
- Play Now and Continue through the runtime
- Rich Challenge Library cards
- Observation Record and Family Mastery profile
- Challenge History
- Ten persisted achievements
- Reading Comfort Mode and complete settings surface
- Programs and Collections future-ready placeholders
- Sponsor-first boot and redesigned loading states
- Responsive phone/tablet/foldable layouts and safe-area scaling
- Text Size, High Contrast, Reduced Motion, and Color Assistance
- Startup, screen, challenge-preparation, and memory instrumentation

## Documentation

Start with:

- [`docs/product/PRODUCT_DEVELOPMENT_ROADMAP.md`](docs/product/PRODUCT_DEVELOPMENT_ROADMAP.md)
- [`docs/product/ARCHITECTURE_BOUNDARIES.md`](docs/product/ARCHITECTURE_BOUNDARIES.md)
- [`docs/product/CHALLENGE_RUNTIME_API.md`](docs/product/CHALLENGE_RUNTIME_API.md)
- [`docs/product/PHASE_3_HOME_EXPERIENCE_SPEC.md`](docs/product/PHASE_3_HOME_EXPERIENCE_SPEC.md)
- [`docs/product/PHASE_3_HOME_EXPERIENCE_COMPLETION.md`](docs/product/PHASE_3_HOME_EXPERIENCE_COMPLETION.md)
- [`docs/product/PHASE_3_5_PRODUCTION_POLISH_SPEC.md`](docs/product/PHASE_3_5_PRODUCTION_POLISH_SPEC.md)
- [`docs/product/PHASE_3_5_DEVICE_VALIDATION_MATRIX.md`](docs/product/PHASE_3_5_DEVICE_VALIDATION_MATRIX.md)
- [`docs/product/PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md`](docs/product/PHASE_3_5_PRODUCTION_POLISH_COMPLETION.md)
- [`docs/product/PHASE_4_PLAYER_JOURNEY_SPEC.md`](docs/product/PHASE_4_PLAYER_JOURNEY_SPEC.md)
- [`docs/product/PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md`](docs/product/PHASE_4_PRODUCT_EXPERIENCE_COMPLETION.md)
- [`docs/product/PHASE_5_PREPARATION_REPORT.md`](docs/product/PHASE_5_PREPARATION_REPORT.md)
- [`docs/product/challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md`](docs/product/challenge-types/CHALLENGE_TYPE_ACCEPTANCE_CONTRACT.md)
- [`docs/product/challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md`](docs/product/challenge-types/CHALLENGE_TYPE_PORTFOLIO_MATRIX.md)
- [`docs/product/challenge-types/SPOT_THE_DIFFERENCE_SPEC.md`](docs/product/challenge-types/SPOT_THE_DIFFERENCE_SPEC.md)
- [`docs/product/INTERACTION_ADAPTER_CONTRACT.md`](docs/product/INTERACTION_ADAPTER_CONTRACT.md)
- [`docs/product/PHASE_5_COMPLETION.md`](docs/product/PHASE_5_COMPLETION.md)
- [`docs/product/PHASE_5_5_CONTENT_QUALITY_COMPLETION.md`](docs/product/PHASE_5_5_CONTENT_QUALITY_COMPLETION.md)
- [`docs/product/PHASE_5_5_REPLAY_QUALITY_AUDIT.md`](docs/product/PHASE_5_5_REPLAY_QUALITY_AUDIT.md)
- [`docs/product/PHASE_6_PRODUCTION_READINESS_COMPLETION.md`](docs/product/PHASE_6_PRODUCTION_READINESS_COMPLETION.md)
- [`docs/store/FINAL_RELEASE_CHECKLIST.md`](docs/store/FINAL_RELEASE_CHECKLIST.md)
- [`docs/store/OPEN_SOURCE_NOTICES.md`](docs/store/OPEN_SOURCE_NOTICES.md)
- [`docs/product/PHASE_2_GATE_3_COMPLETION.md`](docs/product/PHASE_2_GATE_3_COMPLETION.md)
- [`docs/product/PHASE_2_GATE_4_COMPLETION.md`](docs/product/PHASE_2_GATE_4_COMPLETION.md)

## Repository layout

```text
app/
  project.godot
  assets/
  src/
    core/                    # app state, boot, navigation, events
    systems/                 # validated Foundation services
    gameplay/
      contracts/             # family, template, instance, validation, result
      runtime/               # generic shared Challenge Runtime
      families/              # production and hidden fixture modules
      progression/           # data-driven achievements
      programs/              # curated selection policies and run progress
    ui/                      # shell, screens, product cards, dialogs
    experiences/             # dormant Foundation-era scaffolding
  tests/runtime/             # runtime, product, stress, and static checks
docs/
  foundation/                # validated infrastructure records
  product/                   # Product Development source of truth
  store/                     # store and release documentation
```

## Run locally

Open `app/project.godot` in Godot 4.6.3 and run the project.

Fresh headless import:

```bash
godot --headless --editor --path ./app --quit --debug
```

Phase 3 validation:

```bash
HOME=/tmp/tsw-phase3 godot --headless --path ./app \
  --script res://tests/runtime/test_phase3_home_experience.gd --debug
python3 app/tests/runtime/verify_phase3_home_architecture.py
```

See [`app/tests/runtime/README.md`](app/tests/runtime/README.md) for the complete regression suite.

Android export requires local Godot export templates, an Android SDK/JDK, and the existing release signing key for Play Store update continuity.

## Development rule

Complete one Product Development phase at a time. At each boundary:

1. Summarize completed work.
2. List changed files.
3. Record architectural decisions.
4. Identify risks.
5. Recommend the next phase.
6. Stop and wait for approval.

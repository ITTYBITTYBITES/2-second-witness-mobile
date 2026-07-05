# Terminology Normalization Report

**Date:** 2026-07-05 · **Scope:** Repository-wide wording pass (docs, comments, prompts, manifest descriptions, player-facing UI strings, one file rename)

## Canonical term map applied

| Legacy / variant | Canonical | Where applied |
|---|---|---|
| `Cognitive Mirror` / `Memory Mirror` / `MEMORY MIRROR` | **Mirror** | all living docs, comments, UI strings |
| `Liquid Memory` / `LiquidMemory` / `Liquid Memory V2` | **2 Second Witness** (product) / rephrased (engine/concept) | living docs, headers, prompts, tool output |
| `Liquid Master` (player rank) | **Master Witness** | `PlayerProfile.gd` title ladder |
| `LiquidMemory Asset Pipeline` (OBJ headers) | **2 Second Witness Asset Pipeline** | 9 mesh headers |
| `LIQUID_MEMORY_V2_PRODUCT_BIBLE.md` | **PRODUCT_BIBLE.md** | renamed + 4 refs updated |
| `LiquidMemory_V2` (stale dir refs in deploy guide) | `2-second-witness-mobile/app` | `DEPLOYMENT_GUIDE_IVC0.md` |
| `Cognitive Mirror` (lowercase, itch description) | `Mirror` | itch.io guides |

## Files changed (31)
30 modified + 1 renamed. Docs (`.md`): README, CHANGELOG, itch guides, app specs (BRANDING_PROMPT_GENERATOR, DEPLOYMENT_GUIDE, FINAL_ASSET_MANIFEST, GROUND_TRUTH_ARCHITECTURE_AUDIT, PLATFORM_CONSTITUTION, PRODUCT_STRATEGY, UI_TAXONOMY, PRODUCT_BIBLE, my AUDIT/FINALIZATION reports, benchmark specs), promo, Design Bible + companions. Code (comments/strings/UI): 8 `.gd` files, 1 `.tscn` (player-facing "MEMORY MIRROR"→"MIRROR" header), 1 `.py` tool, 9 `.obj` headers.

## Player-facing changes (in scope per directive)
- `PlayerProfile.gd` — rank `"Liquid Master"` → `"Master Witness"` (top of the title ladder; computed from level, so saves auto-update on next cognitive event).
- `PlayerProfileScreen.tscn` — header `"MEMORY MIRROR"` → `"MIRROR"`; the `verify_neutral_language_refactor.gd` assertion updated to match.

## Verification (post-normalization)
- ✅ Project boots headless with **0 errors, 0 warnings**.
- ✅ Full verification suite: **40/40 benchmarks compile & execute** (no regression).
- ✅ Case-insensitive sweep: **no legacy terms remain in any living doc/comment/string**.
- ✅ File rename verified: `PRODUCT_BIBLE.md` resolves; `verify_product_bible.gd` finds it.
- One regression was introduced and caught during verification: a `sed` had inserted unescaped quotes in `verify_neutral_language_refactor.gd:45` → fixed and re-verified.

---

## Legacy terms that REMAIN, and why

### 1. `prohibited_terminology` guardrails (intentional — the defense, not the leak)
- **`app/meta/asset_contracts.json`** — `project_identity.prohibited_terminology` lists `"Liquid Memory"`, `"Liquid Memory V2"`, `"Cognitive"`, `"Brain"`, etc. These must stay: the list defines exactly which legacy/clinical terms generated content must **not** contain.
- **`app/benchmark/verify_asset_pipeline_runtime.gd`** — mirrors the above as a runtime assertion that no prohibited term leaks into the active UI tree.

### 2. Historical / dated reports (retained per "clearly labeled historical" rule)
- **`docs_legacy/`** (5 files) — explicitly the historical archive; includes `TERMINOLOGY_AUDIT_REPORT.md` which should reflect the audit as-was.
- **Root milestone reports** (`PHASE_2`, `PHASE_10`, `PHASE_11`, `PHASE_12`, and other `PHASE_*`/`ALPHA_*`/`RC1_*` snapshots) — dated engineering records. `PHASE_12` in particular *documents the original Liquid Memory → 2 Second Witness purge*; rewriting it would falsify that record. Per the Design Authority Hierarchy, these are rank-5 legacy documentation.

### 3. Load-bearing identifiers (out of scope — would break runtime/compatibility)
Per the agreed boundary (engine logic, APIs, class names, script names, autoload names, resource identifiers, registry IDs, serialization keys):
- **`MirrorNarrator`** (autoload) — code identifier; prose now calls it the Mirror, but the autoload name is an API surface.
- **`MemoryCascade`** / `memory_cascade` — a live scenario mechanic ID, not the legacy brand.
- **`com.ittybittybites.liquidmemory`** — ⚠️ **stale Android package name** in `DEPLOYMENT_GUIDE_IVC0.md`. The actual app ships as `com.ittybittybites.the2secondwitness` (per Phase 12). This is a package *identifier* (affects installed apps / Play Console), so it was left untouched. **Recommend manual update** with care, since it only affects new installs.

## Recommendations
1. Manually reconcile the `com.ittybittybites.liquidmemory` package reference in the deploy guide (it's a stale identifier, not prose).
2. The benchmark `verify_neutral_language_refactor.gd` (and the runner's `--only` filter, which doesn't isolate a single benchmark) could be hardened separately — a pre-existing test-harness quirk, out of scope here.
3. `docs_legacy/` and the root `PHASE_*` reports can optionally be archived to a dedicated `docs/archive/` folder to make the "historical" carve-out structural rather than naming-convention-based.

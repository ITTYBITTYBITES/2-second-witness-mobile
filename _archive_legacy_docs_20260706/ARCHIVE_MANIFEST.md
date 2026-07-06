# Archive Manifest – Chronicle Migration
**Date:** 2026-07-06
**Phase:** Milestone 1 – Repository Modernization

## Archived from app repo root
- 26 markdown documents moved to `_archive_legacy_docs_20260706/`
  - PHASE_0 … PHASE_13 reports (13 files)
  - *_VALIDATION_REPORT.md, *_AUDIT.md, *_GUIDE.md, etc.
  - ARCHITECTURE_STATUS.md, PRODUCTION_READINESS_REPORT.md, etc.
- Reason: superseded reports, obsolete documentation, duplicate root docs (see Risk R-007)
- Preservation: files NOT deleted – moved to archive folder – recoverable via git
- Runtime impact: NONE – Godot project at `app/app/` untouched

## Archived from app repo – CI
- `.github/workflows/android_ci.yml` → `.github/workflows/archive_ci/android_ci.yml.disabled`
- `.github/workflows/fleet_self_healing.yml` → disabled
- `.github/workflows/universe-assets.yml` → disabled
- `app/app/.github/` → `/workspace/_archive_box/app_nested_.github_20260706`
- Replacement: `health.yml` + `_ci_guardrail.yml` – CI locked

## Archived from website repo
- Legacy static site → `/workspace/_archive_box/website_legacy_20260706/`
  - includes: website/, index.html (old redirect), pages/, js/, css/
  - Reason: website fully regenerated via Chronicle – legacy is artistic fork – quarantined per authority.model.json CR-004
- Replacement: Chronicle spatial simulation website – 66 pages generated from /shared

## Archive locations
- App docs: `/app/_archive_legacy_docs_20260706/` (in-repo, untracked – to be committed separately or moved to /_archive_box)
- App CI: `/app/.github/workflows/archive_ci/`
- App nested .github: `/workspace/_archive_box/app_nested_.github_20260706`
- Website legacy: `/workspace/_archive_box/website_legacy_20260706/`
- Website ontology: `/workspace/_archive_box/website_legacy_ontology.json`

## Verification
- Godot project intact: `/app/app/project.godot` → YES
- 146 GDScript files untouched
- Content banks untouched: 143 banks, 22,059 observations
- App builds: assumed YES – no code changes – export pipeline is additive at `/app/app/tools/chronicle_export_v1.py`
- No private source leakage in /shared – verified

## Recovery
To restore any archived document:
```bash
git checkout HEAD -- <path>
# or
cp /workspace/_archive_box/... <restore_path>
```

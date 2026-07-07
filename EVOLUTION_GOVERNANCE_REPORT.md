# Evolution Governance System – Validation Report

**Date:** 2026-07-07  
**System:** Chronicle System – Evolution Governance Layer  
**Phase:** 2.4 – Governance (approvals → queue → history)

---

## Implementation Summary

### 1. Approval Registry
**File:** `/shared/evolution/approvals.json`  
**Tool:** `app/app/tools/evolution/evolution_approvals.py`  
**Schema:** `approvals-v1 / 1.0.0`

- Tracks proposal state transitions separately from proposal generation
- States: `proposed`, `approved`, `rejected`, `expired`, `completed`
- Rules enforced:
  - Proposal generator never edits approvals – **PASS**
  - Approvals never edit proposals – **PASS**
  - Approval state is the only authority for execution – **PASS**
  - Deterministic output – **PASS**
  - Schema versioned – **PASS**

**Current state:**
```
proposed:  17
approved:   0
rejected:   0
expired:    0
completed:  0
total:     17
```

All 17 proposals from `growth_proposals.json` registered as `proposed`, awaiting human review. No auto-approval.

### 2. Generation Queue Builder
**Tool:** `app/app/tools/evolution/evolution_queue.py`  
**Output:** `/shared/evolution/generation_queue.json`  
**Schema:** `queue-v1 / 1.0.0`

- Inputs: `growth_proposals.json` + `approvals.json`
- Output: `generation_queue.json`
- Rules:
  - ONLY approved proposals enter the queue – **PASS** (0 approved → 0 queued – correct)
  - Deterministic ordering – priority desc, then proposal_id asc – **PASS**
  - Includes checksum, proposal_id, generation_type, priority, dependencies – **PASS**
  - No content generation – **PASS**

**Current state:**
```
queued: 0
```

Queue is empty – correct, as no proposals have been approved. The system can prepare work, but cannot generate content without human approval.

Queue checksum: `sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (empty queue)

### 3. Execution History
**File:** `/shared/evolution/generation_history.json`  
**Tool:** `app/app/tools/evolution/evolution_history.py`  
**Schema:** `history-v1 / 1.0.0`

- Append-only – **PASS**
- Permanent audit trail – **PASS**
- Nothing deleted – **PASS**
- Records: execution_id, proposal_id, timestamp, model_versions, checksum, generated_asset_ids, success/failure, notes – schema supports all fields

**Current state:**
```
total_executions: 0
success: 0
failure: 0
```

History initialized, empty – correct, no content has been generated.

### 4. Website Integration – Evolution Dashboard
**File:** `website/build_website.py` – updated  
**Page:** `/evolution.html`

Displays (read-only):
- ✅ proposal count: 17
- ✅ approved count: 0
- ✅ rejected count: 0
- ✅ queued count: 0
- ✅ completed count: 0
- ✅ proposal cards – with approval status, score, confidence, evidence
- ✅ queue contents – table with priority, target, generation_type
- ✅ execution history – table with result, timestamp, notes

- Website is read-only – **PASS**
- No editing UI – **PASS**
- No approval UI – **PASS**
- No generation UI – **PASS**

Navigation updated: Field · Worlds · Characters · Events · Releases · **Evolution** · Journal

All 61 world pages still generate, archived content preserved, active content prioritized.

### 5. Build State Integration
**Tool:** `app/app/tools/generate_build_state.py` – extended  
**Schema:** `build_state.json 1.0.0 → 1.1.0`

Added:
```json
"counts": {
  "observations_exported": 22059,
  "worlds": 61,
  "universes": 7,
  "characters": 4,
  "proposals": 17,
  "approvals": 17,
  "queue": 0,
  "executions": 0
},
"evolution": {
  "ranking_model": "ranking-v1",
  "lifecycle_model": "lifecycle-v1",
  "placement_model": "placement-v1",
  "proposals_model": "proposals-v1",
  "approvals_model": "approvals-v1",
  "queue_model": "queue-v1",
  "history_model": "history-v1"
},
"governance": {
  "approvals_breakdown": {
    "proposed": 17,
    "approved": 0,
    "rejected": 0,
    "expired": 0,
    "completed": 0
  },
  "queue_depth": 0,
  "execution_success_rate": null
}
```

- Existing fields preserved – backward compatible (schema minor bump)
- Fully auditable – every build fingerprints governance state
- Pipeline version bumped: `1.0.0 → 1.1.0`

---

## Validation

### Determinism
| Artifact | Run 1 SHA256 | Run 2 SHA256 | Identical? |
|----------|--------------|--------------|------------|
| ranking.json | d2b8… | d2b8… | **YES** |
| lifecycle.json | 9f14… | 9f14… | **YES** |
| placement.json | a1c3… | a1c3… | **YES** |
| growth_proposals.json | a6ced0… | a6ced0… | **YES** |
| approvals.json | 8e4f… | 8e4f… | **YES** |
| generation_queue.json | 4b7e… | 4b7e… | **YES** |
| generation_history.json | c9a2… | c9a2… | **YES** |
| website HTML (67 pages) | – | – | **YES – byte-identical** |

**Result: PASS – deterministic outputs**

`build_state.json` is intentionally NOT byte-identical – `run_id` increments, `timestamp` updates – this is the auditable build fingerprint, by design.

### Side Effect Checks
| Check | Result |
|-------|--------|
| Export changed | **NO** – `/shared/export/` untouched during governance runs |
| Contracts changed | **NO** – `/shared/contracts/*` untouched |
| Engine changed | **NO** – `chronicle_export_v1.py` unchanged since v1.2 export modernization |
| Gameplay changed | **NONE** – app repo `app/` – zero changes to `.gd` files |
| Pipeline changed | **NONE** – no `.github/workflows/` modifications |
| Website deterministic | **PASS** – 67 pages byte-identical consecutive builds |
| Proposal layer untouched | **PASS** – `evolution_proposals.py` not modified |
| Approval layer independent | **PASS** – reads proposals, writes approvals – never modifies proposals |
| Queue independent | **PASS** – reads approvals+proposals, writes queue – never modifies inputs |
| History append-only | **PASS** – `evolution_history.py` initializes once, never deletes, append-only policy enforced in schema |

### Workflow Verification
```
Ranking
  ↓  ranking.json – 61 worlds, deterministic
Lifecycle
  ↓  lifecycle.json – 20 active / 20 cooling / 21 archived
Placement
  ↓  placement.json – app / website / archive separation
Growth Proposals
  ↓  growth_proposals.json – 17 proposals, all "proposed"
Approvals
  ↓  approvals.json – 17 proposed, 0 approved – human authority enforced
Generation Queue
  ↓  generation_queue.json – 0 queued (correct – no approved proposals)
Execution History
  ↓  generation_history.json – 0 executions – append-only, permanent
```

✅ A human can approve a proposal – approval registry supports `approved` state, with actor/timestamp/history tracking  
✅ The system can prepare work – queue builder produces deterministic queue from approved proposals, with priority, checksum, dependencies  
✅ The system **cannot** generate content – no universe/world/scenario/observation generation code exists – queue is terminal (for now)

---

## Files Created / Modified

### New – Governance Layer
```
app/app/tools/evolution/evolution_approvals.py      4.2 KB
app/app/tools/evolution/evolution_queue.py         3.8 KB
app/app/tools/evolution/evolution_history.py       2.1 KB
shared/evolution/approvals.json                    5.8 KB
shared/evolution/generation_queue.json             0.6 KB
shared/evolution/generation_history.json           0.4 KB
```

### Modified – Integration
```
app/app/tools/generate_build_state.py  – extended with governance counts + model versions – schema 1.0 → 1.1
website/build_website.py               – added Evolution Dashboard (evolution.html) + nav link – 67 pages total
```

### Untouched – Frozen
```
app/app/tools/chronicle_export_v1.py   – v1.2 – NOT modified during governance (last modified for export modernization)
app/app/tools/evolution/evolution_ranker.py       – NOT modified
app/app/tools/evolution/evolution_lifecycle.py    – NOT modified
app/app/tools/evolution/evolution_placement.py    – NOT modified
app/app/tools/evolution/evolution_proposals.py    – NOT modified
/shared/export/*                        – NOT modified
/shared/contracts/*                     – NOT modified
app/**/*.gd                             – NOT modified
.github/workflows/*                     – NOT modified (not present in workspace snapshot – but no local edits)
```

---

## Success Criteria

- [x] Ranking → Lifecycle → Placement → Growth Proposals → **Approvals → Generation Queue → Execution History** – full DAG implemented
- [x] Human can approve a proposal – approval registry supports full state machine with audit history
- [x] System can prepare work – queue builder produces deterministic, checksummed, prioritized queue
- [x] System **cannot** generate content – no generation code exists – queue is terminal – **PASS**
- [x] Permanent audit trail – execution_history.json append-only – **PASS**
- [x] Website displays governance state – Evolution Dashboard live – read-only – **PASS**
- [x] Build state fully auditable – governance counts + model versions included – **PASS**

---

## Status

**EVOLUTION GOVERNANCE SYSTEM – COMPLETE**

- Approval Registry: **PASS**
- Generation Queue: **PASS**
- Execution History: **PASS**
- Website Integration: **PASS**
- Build State Integration: **PASS**
- Determinism: **PASS**
- Engine changes: **NONE** (since export v1.2)
- Pipeline changes: **NONE**

**STOP**

Do not begin implementing:
- automatic generation
- trend ingestion
- social media integrations
- YouTube / SEO automation
- self-growing universes

These are future capabilities built on top of this governance layer.

The system can now:
- ✅ Evaluate itself (ranking)
- ✅ Curate itself (lifecycle)
- ✅ Place itself (placement)
- ✅ Propose growth (proposals)
- ✅ Govern growth (approvals)
- ✅ Queue work (queue)
- ✅ Audit everything (history)

It **cannot** grow itself – human approval is required, and generation is not implemented.

This is the correct stopping point.

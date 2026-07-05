#!/usr/bin/env python3
"""
PHASE 6: Observation Content Validator
Validates the entire observation system against the production contract.
Exits non-zero with actionable errors if any check fails.

Usage: python3 tools/observation_content_validator.py
"""
import json, glob, os, re, sys
from collections import Counter, defaultdict

APP = os.path.dirname(os.path.abspath(__file__)).replace('/tools','')
DATA = os.path.join(APP, 'data', 'content', 'base_bundle')
REGISTRY = os.path.join(APP, 'MASTER_UNIVERSE_REGISTRY.json')

VALID_MECHANICS = {
    'rapid_classification','signal_vs_noise','odd_one_out','stroop_test',
    'memory_cascade','sequence_reverse','spatial_recall','pattern_continuation',
    'speed_sort','math_surprise','reflex_tap','risk_selection','dynamic'
}
PLACEHOLDER_PATTERNS = ["Verified Observation #", "Anomaly A#", "Distractor B#", "PROTOCOL SEQUENCE"]

errors = []
warnings = []

def err(msg): errors.append(msg)
def warn(msg): warnings.append(msg)

def load_registry():
    with open(REGISTRY) as f: return json.load(f)

def load_all_items():
    items = []
    for b in glob.glob(os.path.join(DATA, '**', '*.json'), recursive=True):
        if os.path.basename(b) == 'world_manifest.json': continue
        try:
            with open(b) as f: d = json.load(f)
        except Exception as e:
            err(f"JSON parse failed: {os.path.relpath(b, APP)} ({e})")
            continue
        if isinstance(d, dict): d = [d]
        if not isinstance(d, list): continue
        for it in d:
            if isinstance(it, dict):
                it['_file'] = os.path.relpath(b, APP)
                items.append(it)
    return items

def is_placeholder(it):
    blobs = [str(it.get('correct_answer','')), str(it.get('prompt',''))]
    rules = it.get('rules', {})
    if isinstance(rules, dict):
        blobs += [str(rules.get('correct_answer','')), str(rules.get('prompt',rules.get('legacy_prompt','')))]
    dis = it.get('distractors', rules.get('wrong_answers',[]) if isinstance(rules,dict) else [])
    if isinstance(dis, list):
        blobs += [str(x) for x in dis]
    return any(p in b for b in blobs for p in PLACEHOLDER_PATTERNS)

def mapped_mechanic(it):
    ot = str(it.get('observation_type','')).lower()
    m = {
        'rapid classification':'rapid_classification','rapid recognition':'rapid_classification',
        'true / definition':'rapid_classification','tool/technique recognition':'rapid_classification',
        'artist → artwork':'rapid_classification','visual identification':'signal_vs_noise',
        'artwork → artist':'signal_vs_noise','style recognition':'odd_one_out'
    }
    return m.get(ot, 'rapid_classification')

def resolve_type(it):
    if 'entity' in it and 'features' in it: return 'dynamic'
    if 'prompt' in it and 'correct_answer' in it: return mapped_mechanic(it)
    return str(it.get('type','')).lower()

def validate():
    reg = load_registry()
    unis = reg.get('universes', {})
    items = load_all_items()

    # --- duplicate IDs ---
    idmap = defaultdict(list)
    for it in items:
        oid = it.get('observation_id') or it.get('id')
        if oid: idmap[oid].append(it['_file'])
    dups = {k:v for k,v in idmap.items() if len(v)>1}
    for k,v in list(dups.items())[:20]:
        err(f"DUPLICATE ID '{k}' in {len(v)} files: {v[:3]}")

    # --- missing IDs ---
    missing = [it['_file'] for it in items if not (it.get('observation_id') or it.get('id'))]
    if missing: err(f"{len(missing)} items missing observation_id/id (sample: {missing[:3]})")

    # --- missing universe/world ---
    for it in items:
        if not it.get('universe'): err(f"Item {it.get('observation_id','?')} missing universe ({it['_file']})")
        if not it.get('world'): err(f"Item {it.get('observation_id','?')} missing world ({it['_file']})")

    # --- placeholder content shipping ---
    placeholders = [it for it in items if is_placeholder(it)]
    if placeholders:
        err(f"{len(placeholders)} PLACEHOLDER observations detected (synthetic spikes) - must not ship. sample: "
            + str(placeholders[0].get('observation_id') or placeholders[0].get('id')))

    # --- difficulty validity (skip placeholders; they are a separate error) ---
    for it in items:
        if is_placeholder(it): continue
        d = it.get('difficulty')
        if d is None:
            warn(f"Item {it.get('observation_id','?')} missing difficulty")
        elif isinstance(d, dict):
            if 'tier' not in d: warn(f"Item {it.get('observation_id','?')} difficulty dict has no 'tier'")
        elif not isinstance(d, (int, float)):
            warn(f"Item {it.get('observation_id','?')} difficulty not int/dict: {type(d).__name__}")

    # --- engine contract: every item must resolve to id+universe+type after normalization ---
    contract_fail = []
    for it in items:
        if is_placeholder(it): continue  # placeholders are a separate (already-flagged) error
        has_id = bool(it.get('observation_id') or it.get('id'))
        has_u = bool(it.get('universe'))
        t = resolve_type(it)
        if not (has_id and has_u and t):
            contract_fail.append(it.get('observation_id') or it.get('id'))
    if contract_fail:
        err(f"{len(contract_fail)} items fail engine contract (cannot resolve id+universe+type). sample: {contract_fail[:5]}")

    # --- question validity: items with prompt must have correct_answer + >=1 distractor ---
    bad_q = 0
    seen_answers = defaultdict(set)
    for it in items:
        if is_placeholder(it): continue
        prompt = it.get('prompt') or (it.get('rules',{}).get('prompt') if isinstance(it.get('rules'),dict) else '')
        ca = it.get('correct_answer') or (it.get('rules',{}).get('correct_answer') if isinstance(it.get('rules'),dict) else '')
        dis = it.get('distractors') or (it.get('rules',{}).get('wrong_answers') if isinstance(it.get('rules'),dict) else [])
        if prompt:
            if not ca: bad_q += 1
            if not isinstance(dis, list) or len(dis) < 1: bad_q += 1
            elif ca in dis: bad_q += 1  # answer must not appear in distractors
    if bad_q: err(f"{bad_q} observations have invalid rapid-fire questions (missing answer, <1 distractor, or answer in distractors)")

    # --- empty banks / empty worlds ---
    # Content-status aware: empty worlds in non-playable universes are expected
    # (in_development) and reported as info, not errors. Only empty worlds inside
    # universes marked playable (status complete/playable) are blocking errors.
    PLAYABLE = {"complete", "playable", "gold_standard", "production"}
    bank_counts = Counter()
    for it in items:
        if is_placeholder(it): continue
        bank_counts[(it.get('universe'), it.get('world'))] += 1
    in_dev_worlds = 0
    for u in unis:
        status = str(unis[u].get('status','')).lower()
        playable = status in PLAYABLE
        worlds = unis[u].get('worlds', {})
        wo = unis[u].get('world_order', [])
        for w in set(list(worlds.keys()) + wo):
            has = bank_counts.get((u,w),0) > 0
            if not has:
                if playable and w in worlds:
                    err(f"EMPTY WORLD in PLAYABLE universe: {u}/{w} (status={status}) marked complete but has 0 valid observations")
                else:
                    in_dev_worlds += 1
    if in_dev_worlds:
        print(f"[INFO] {in_dev_worlds} worlds are in_development (non-playable universes, content pending) -- not blocking.")

    # --- assets: referenced textures/fonts exist? (lightweight check on registry banners) ---
    missing_assets = []
    for u, uspec in unis.items():
        banner = uspec.get('banner','')
        bg = uspec.get('background','')
        for ref in [banner, bg]:
            if ref and ref.startswith('res://'):
                p = os.path.join(APP, ref.replace('res://',''))
                if not os.path.exists(p): missing_assets.append(f"{u}: {ref}")
    if missing_assets: warn(f"{len(missing_assets)} referenced universe assets missing: {missing_assets[:5]}")

    # --- report ---
    print("="*72)
    print("PHASE 6: OBSERVATION CONTENT VALIDATOR")
    print("="*72)
    print(f"Universes: {len(unis)} | Observations scanned: {len(items)} | Real (non-placeholder): {len(items)-len(placeholders)}")
    print(f"\nERRORS: {len(errors)}")
    for e in errors[:40]: print(f"  ✗ {e}")
    print(f"\nWARNINGS: {len(warnings)}")
    for w in sorted(set(warnings))[:20]: print(f"  ⚠ {w}")
    print("\n" + "="*72)
    if errors:
        print(f"RESULT: FAIL ({len(errors)} errors)")
        sys.exit(1)
    print("RESULT: PASS (no blocking errors)")
    sys.exit(0)

if __name__=='__main__':
    validate()

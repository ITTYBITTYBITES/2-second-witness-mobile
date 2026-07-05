#!/usr/bin/env python3
"""
PHASE 1 AUDIT: 2 Second Witness Observation System
Comprehensive integrity audit of observation content + registry + engine contract.
"""
import json, glob, os, re, sys
from collections import defaultdict, Counter

APP = os.path.dirname(os.path.abspath(__file__)).replace('/tools','')
DATA = os.path.join(APP, 'data', 'content', 'base_bundle')
REGISTRY = os.path.join(APP, 'MASTER_UNIVERSE_REGISTRY.json')

def load_registry():
    with open(REGISTRY) as f:
        return json.load(f)

def scan_banks():
    """Return list of (abs_path, universe, world, items_list)."""
    banks = []
    for b in glob.glob(os.path.join(DATA, '**', '*_observation_bank_compiled.json'), recursive=True):
        rel = os.path.relpath(b, DATA)
        parts = rel.split(os.sep)
        if len(parts) < 3:
            continue
        u, w = parts[0], parts[1]
        with open(b) as f:
            d = json.load(f)
        items = d if isinstance(d, list) else [d]
        banks.append((b, u, w, items))
    return banks

def classify(item):
    if 'entity' in item and 'features' in item:
        return 'v3_entity'
    if 'prompt' in item and 'correct_answer' in item:
        return 'v2_compiled'
    if 'concept' in item and 'recognized_answer' in item:
        return 'v2_raw'
    if 'rules' in item:
        return 'v1_legacy'
    return 'unknown'

def main():
    R = {}
    print("="*72)
    print("PHASE 1 AUDIT: Observation System")
    print("="*72)

    # --- 1. Registry topology ---
    reg = load_registry()
    unis = reg.get('universes', {})
    reg_worlds = {}   # universe -> set(world_id)
    for uid, u in unis.items():
        reg_worlds[uid] = set(u.get('worlds', {}).keys())

    # --- 2. Disk banks ---
    banks = scan_banks()
    disk_uni_world = defaultdict(set)
    disk_world_items = defaultdict(list)
    all_items = []
    for b, u, w, items in banks:
        disk_uni_world[u].add(w)
        for it in items:
            if isinstance(it, dict):
                it['_path'] = os.path.relpath(b, APP)
                it['_disk_u'] = u
                it['_disk_w'] = w
                disk_world_items[(u,w)].append(it)
                all_items.append(it)

    print(f"\nRegistry: {len(unis)} universes, {sum(len(v) for v in reg_worlds.values())} worlds")
    print(f"Disk:     {len(banks)} bank files, {len(all_items)} observation items, {sum(len(v) for v in disk_uni_world.values())} universe/worlds")

    # --- 3. Registry vs disk reconciliation ---
    print("\n--- REGISTRY vs DISK RECONCILIATION ---")
    orphan_disk = 0      # banks on disk not in registry
    empty_reg = []       # universes registered but no banks
    for u, wset in reg_worlds.items():
        for w in wset:
            if w not in disk_uni_world.get(u, set()):
                empty_reg.append((u,w))
    reg_no_disk_uni = [u for u in disk_uni_world if u not in unis]
    for u, ws in disk_uni_world.items():
        for w in ws:
            if u in unis and w not in reg_worlds.get(u,set()):
                orphan_disk += 1
    print(f"Registered worlds with NO bank on disk: {len(empty_reg)}")
    print(f"Bank files on disk for universe NOT in registry: {len(reg_no_disk_uni)} -> {reg_no_disk_uni[:10]}")
    print(f"Bank files on disk for world NOT in registry: {orphan_disk}")
    # universes with world_order but empty worlds
    order_only = [(u, len(unis[u].get('world_order',[]))) for u in unis if len(unis[u].get('worlds',{}))==0 and unis[u].get('world_order')]
    print(f"Universes with world_order but 0 populated worlds: {len(order_only)} -> {[u for u,_ in order_only]}")

    # --- 4. Format classification ---
    print("\n--- OBSERVATION FORMAT CLASSIFICATION ---")
    fmt = Counter(classify(it) for it in all_items)
    for k,v in fmt.most_common():
        print(f"  {k}: {v}")

    # --- 5. ID integrity ---
    print("\n--- ID INTEGRITY ---")
    ids = [it.get('observation_id') or it.get('id') for it in all_items]
    missing_id = sum(1 for i in ids if not i)
    id_counts = Counter(ids)
    dups = {k:v for k,v in id_counts.items() if v>1 and k}
    print(f"Total items: {len(all_items)}")
    print(f"Items missing observation_id/id: {missing_id}")
    print(f"Distinct IDs: {len([i for i in ids if i])}")
    print(f"Duplicate IDs: {len(dups)} (affecting {sum(v-1 for v in dups.values())} extra items)")
    if dups:
        print("  sample duplicate IDs:", list(dups.items())[:5])

    # --- 6. Metadata completeness (per Phase 2 requirement) ---
    print("\n--- METADATA COMPLETENESS (Phase 2 fields) ---")
    required = ['observation_id','universe','world','difficulty']
    present = {f: 0 for f in required}
    for it in all_items:
        for f in required:
            if f in it and it[f] not in (None,'',{},[]):
                present[f]+=1
    for f in required:
        print(f"  {f}: {present[f]}/{len(all_items)}")
    # optional Phase-2 fields almost universally absent
    opt = ['title','description','category','rarity','tags','supported_scenarios','asset_references']
    print("  Optional fields present in >0 items:")
    for f in opt:
        c = sum(1 for it in all_items if it.get(f) not in (None,'',{},[]))
        if c: print(f"    {f}: {c}")
    # tags may live under metadata
    has_tags = sum(1 for it in all_items if (it.get('metadata',{}) or {}).get('tags'))
    print(f"    metadata.tags: {has_tags}")

    # --- 7. Empty banks ---
    print("\n--- EMPTY / THIN BANKS (<5 items) ---")
    thin = [(u,w,len(its)) for (u,w),its in disk_world_items.items() if len(its)<5]
    print(f"Banks with <5 items: {len(thin)}")

    # --- 8. difficulty type drift ---
    print("\n--- DIFFICULTY TYPE DRIFT ---")
    diff_types = Counter(type(it.get('difficulty')).__name__ for it in all_items if 'difficulty' in it)
    print(f"  difficulty field types: {dict(diff_types)}")

    # --- 9. Engine contract check (the blocker) ---
    print("\n--- ENGINE CONTRACT (ContentLoader._validate_schema) ---")
    print("  _validate_schema requires: id AND universe AND type")
    def passes_validate(it):
        return bool(it.get('id')) and bool(it.get('universe')) and bool(it.get('type'))
    ok = sum(1 for it in all_items if passes_validate(it))
    print(f"  Items passing _validate_schema: {ok}/{len(all_items)}")
    print(f"  Items SILENTLY DROPPED at load: {len(all_items)-ok}")

    # --- summary ---
    print("\n" + "="*72)
    print("AUDIT SUMMARY")
    print("="*72)
    issues = []
    if len(all_items)-ok > 0: issues.append(f"CRITICAL: {len(all_items)-ok} observations silently dropped by _validate_schema (id/universe/type mismatch)")
    if len(empty_reg): issues.append(f"HIGH: {len(empty_reg)} registered worlds have no bank on disk")
    if missing_id: issues.append(f"HIGH: {missing_id} items missing IDs")
    if len(dups): issues.append(f"MED: {len(dups)} duplicate IDs")
    if len(order_only): issues.append(f"MED: {len(order_only)} universes have world_order but no populated worlds")
    if fmt.get('unknown',0): issues.append(f"MED: {fmt['unknown']} items of unrecognized format")
    issues.append(f"LOW: Phase-2 optional metadata (title/description/category/rarity) absent from most banks")
    print(f"{len(issues)} issue categories:")
    for i,iss in enumerate(issues,1):
        print(f"  {i}. {iss}")

if __name__=='__main__':
    main()

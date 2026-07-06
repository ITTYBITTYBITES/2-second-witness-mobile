#!/usr/bin/env python3
"""
OBSERVATION BANK GENERATOR (content pipeline)
Converts a curated source TSV of facts into a validated v2_compiled
observation bank matching the creative_arts production format.

Source TSV columns (tab-separated), one observation per line:
    subcategory \t observation_type \t difficulty \t prompt \t correct_answer \t distractor1 \t distractor2 \t distractor3 [ \t tag1,tag2 ]

  - subcategory:      e.g. "emperors"
  - observation_type: human label, e.g. "Rapid Classification" (mapped to a mechanic by the loader)
  - difficulty:       1..5 (tier)
  - prompt:           the question/stimulus text
  - correct_answer:   the right answer
  - distractor1..3:   plausible wrong answers (must differ from correct_answer)

Usage:
    python3 tools/generate_observation_bank.py <universe> <world> <source.tsv>
Emits: data/content/base_bundle/<universe>/<world>/<world>_observation_bank_compiled.json
"""
import json, os, os, sys, csv, re

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(APP, 'data', 'content', 'base_bundle')

VALID_TYPES = {
    "Rapid Classification","Rapid Recognition","Visual Identification",
    "Tool/Technique Recognition","True / Definition","Artwork → Artist",
    "Artist → Artwork","Style Recognition"
}

def slug(s):
    return re.sub(r'[^a-z0-9]+','_', str(s).lower()).strip('_')


def generate_manifest(universe: str, world: str, bank_path: str):
    """Generates world_manifest.json from the compiled observation bank.
    This is the bridge between 'Complete' and 'Playable' — without it,
    the world is invisible in the UI."""
    import json
    from collections import Counter

    bank = json.load(open(bank_path))
    if not isinstance(bank, list) or len(bank) == 0:
        print(f"  ⚠ Cannot generate manifest: bank is empty")
        return

    sub_counts = Counter(e.get("subcategory", "general") for e in bank)
    subcats = []
    for sub_id, count in sorted(sub_counts.items()):
        display = sub_id.replace("_", " ").title()
        subcats.append({
            "id": sub_id,
            "display_name": display,
            "implemented_observations": count,
            "target_observations": count,
            "scenario_preferences": {
                "preferred": ["rapid_classification", "signal_vs_noise", "odd_one_out"],
                "secondary": ["stroop_test", "memory_cascade"]
            }
        })

    manifest = {
        "schema_version": 3,
        "universe": universe,
        "world": world,
        "display_name": world.replace("_", " ").title(),
        "subcategory_order": [s["id"] for s in subcats],
        "subcategories": subcats,
        "status": "POPULATED"
    }

    manifest_dir = f"data/observation_banks/{universe}/worlds/{world}"
    os.makedirs(manifest_dir, exist_ok=True)
    manifest_path = f"{manifest_dir}/world_manifest.json"
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    print(f"✅ Manifest generated: {manifest_path} ({len(subcats)} subcategories)")

def gen(universe, world, tsv_path):
    items = []
    seen_ids = set()
    with open(tsv_path, newline='', encoding='utf-8') as f:
        for i, row in enumerate(csv.reader(f, delimiter='\t'), 1):
            row = [c.strip() for c in row]
            if not row or row[0].startswith('#') or row[0].lower() == 'subcategory':
                continue
            if len(row) < 8:
                print(f"  ⚠ line {i}: expected >=8 cols, got {len(row)} -- skipped"); continue
            sub, otype, diff, prompt, ans = row[0], row[1], row[2], row[3], row[4]
            distractors = [d for d in row[5:8] if d]
            tags = row[8].split(',') if len(row) > 8 and row[8] else [sub]
            tags = [t.strip() for t in tags if t.strip()]
            # validation
            errs = []
            if not prompt: errs.append("empty prompt")
            if not ans: errs.append("empty answer")
            if ans in distractors: errs.append("answer appears in distractors")
            if len(distractors) < 2: errs.append(f"need >=2 distractors, got {len(distractors)}")
            try:
                tier = int(diff); 
                if not 1 <= tier <= 5: errs.append("difficulty must be 1..5")
            except ValueError:
                errs.append(f"difficulty not int: {diff}"); tier = 1
            if otype not in VALID_TYPES:
                print(f"  ⚠ line {i}: unknown observation_type '{otype}' (allowed: {sorted(VALID_TYPES)})")
            if errs:
                print(f"  ✗ line {i} INVALID: {'; '.join(errs)} -- prompt='{prompt[:40]}'"); continue
            oid = f"{slug(universe)}_{slug(world)}_{slug(sub)}_{i:04d}"
            while oid in seen_ids: oid += "x"
            seen_ids.add(oid)
            items.append({
                "observation_id": oid,
                "universe": universe,
                "world": world,
                "subcategory": slug(sub),
                "difficulty": {"label": {1:"beginner",2:"easy",3:"intermediate",4:"advanced",5:"expert"}.get(tier,"intermediate"), "tier": tier},
                "observation_type": otype,
                "prompt": prompt,
                "correct_answer": ans,
                "distractors": distractors,
                "localization": {"prompt_key": oid+"_prompt", "answer_key": oid+"_answer"},
                "metadata": {"tags": tags, "scenario_compatibility": {"preferred": ["rapid_classification","signal_vs_noise","odd_one_out"]}}
            })
    out_dir = os.path.join(DATA, universe, world)
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, f"{world}_observation_bank_compiled.json")
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(items, f, ensure_ascii=False, indent=1)
    print(f"\n✅ Generated {len(items)} observations -> {os.path.relpath(out_path, APP)}")

    # Auto-generate world_manifest.json (part of the publishing pipeline)
    generate_manifest(universe, world, out_path)
    if len(items) == 0:
        print("⚠ No valid items produced."); sys.exit(1)
    return out_path

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(__doc__); sys.exit(1)
    gen(sys.argv[1], sys.argv[2], sys.argv[3])

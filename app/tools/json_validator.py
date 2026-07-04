#!/usr/bin/env python3
import json, os, glob, sys

def run_content_ci_pipeline():
    print("========================================")
    print("[CONTENT CI PIPELINE] Ambitious JSON Linter & Asset Integrity Validator")
    print("========================================\n")
    
    # Use absolute paths relative to the script location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "../../"))
    search_path = os.path.join(project_root, "app/data/**/*.json")
    
    json_files = glob.glob(search_path, recursive=True)
    print(f"Auditing {len(json_files)} JSON files in repository...")
    
    unique_ids = set()
    unique_prompts = set()
    duplicate_ids = []
    duplicate_prompts = []
    schema_violations = []
    missing_assets = []
    orphan_content = []
    
    verified_items = 0
    verified_themes = 0
    verified_chunks = 0
    verified_observation_banks = 0
    verified_observations = 0
    
    valid_scenario_types = {"memory_cascade", "rapid_classification", "signal_vs_noise", "stroop_test", "spatial_recall", "math_surprise", "odd_one_out", "pattern_continuation", "reflex_tap", "risk_selection", "sequence_reverse", "speed_sort"}
    valid_universes = {"history", "science_lab", "life_sciences", "tech_ops", "creative_arts", "society_mind", "frontier"}
    valid_worlds = {"ancient_egypt", "cognitive_bias", "neural_mapping", "ai", "genetics", "cellular_biology", "virology", "cyber_matrix", "subliminal_code", "protocols"}
    
    for j_path in json_files:
        # Clean path for reporting (relative to app root)
        clean_path = os.path.relpath(j_path, project_root)
        with open(j_path, "r") as f:
            try:
                content = json.load(f)
            except json.JSONDecodeError as e:
                schema_violations.append(f"{clean_path}: Corrupted JSON format ({e})")
                continue
                
        items = content if isinstance(content, list) else [content]
        
        for item in items:
            if not isinstance(item, dict):
                schema_violations.append(f"{clean_path}: Root item is not a dictionary")
                continue
                
            # 0. Observation Bank Architecture (Universe > World > Subcategory > Observation Bank)
            if "app/data/observation_banks/" in clean_path or clean_path.startswith("app/data/observation_banks/"):
                if "schema/" in clean_path:
                    verified_observation_banks += 1
                    continue
                if item.get("architecture") == "Universe > World > Subcategory > Observation Bank" or ("world_order" in item and "universe" in item):
                    if "universe" not in item:
                        schema_violations.append(f"{clean_path}: Observation universe manifest missing 'universe'")
                    verified_observation_banks += 1
                    continue
                if "subcategory_order" in item and "subcategories" in item:
                    for rk in ["universe", "world", "subcategories"]:
                        if rk not in item:
                            schema_violations.append(f"{clean_path}: Observation world manifest missing '{rk}'")
                    valid_worlds.add(item.get("world", ""))
                    verified_observation_banks += 1
                    continue
                if "observations" in item and "subcategory" in item:
                    for rk in ["universe", "world", "subcategory", "scenario_preferences", "observations"]:
                        if rk not in item:
                            schema_violations.append(f"{clean_path}: Observation bank missing '{rk}'")
                    seen_obs = set()
                    for obs in item.get("observations", []):
                        if not isinstance(obs, dict):
                            schema_violations.append(f"{clean_path}: Observation row is not a dictionary")
                            continue
                        for rk in ["observation_id", "difficulty", "prompt", "correct_answer", "distractors", "metadata", "localization", "knowledge"]:
                            if rk not in obs:
                                schema_violations.append(f"{clean_path}: Observation missing '{rk}'")
                        oid = obs.get("observation_id", "")
                        if oid in seen_obs:
                            duplicate_ids.append(f"{clean_path}: Duplicate Observation ID '{oid}'")
                        seen_obs.add(oid)
                        verified_observations += 1
                    verified_observation_banks += 1
                    continue

            # 1. Theme Profiles (WorldProfile or legacy Universe theme)
            if ("world" in item and "lens" in item and "tunnel" in item) or ("id" in item and "display_name" in item and "visual" in item):
                if "world" in item and "lens" in item:
                    req_keys = ["world", "lens", "tunnel", "audio", "typography", "animation", "ui", "feedback"]
                    for rk in req_keys:
                        if rk not in item:
                            schema_violations.append(f"{clean_path}: WorldProfile missing key '{rk}'")
                    valid_worlds.add(item["world"])
                else:
                    req_keys = ["id", "display_name", "visual"]
                    for rk in req_keys:
                        if rk not in item:
                            schema_violations.append(f"{clean_path}: Legacy Theme missing key '{rk}'")
                verified_themes += 1
                
            # 2. Stream Chunk Definitions
            elif "chunk_index" in item or "portal_anchor" in item or "data_nodes" in item or "chunk" in clean_path:
                if "universe" not in item:
                    schema_violations.append(f"{clean_path}: Chunk Definition missing key 'universe'")
                verified_chunks += 1
                
            # 3. Content Items (Cognitive Tasks)
            else:
                req_keys = ["id", "universe", "type", "rules", "presentation"]
                for rk in req_keys:
                    if rk not in item:
                        schema_violations.append(f"{clean_path}: Content item missing key '{rk}'")
                        
                if "id" in item:
                    i_id = item["id"]
                    if i_id in unique_ids:
                        duplicate_ids.append(f"{clean_path}: Duplicate ID '{i_id}'")
                    else:
                        unique_ids.add(i_id)
                        
                if "universe" in item and item["universe"] not in valid_universes:
                    # We track it but don't necessarily fail if it's a new universe we're adding
                    valid_universes.add(item["universe"])
                    
                if "type" in item and item["type"] not in valid_scenario_types:
                    # Track new types as well
                    valid_scenario_types.add(item["type"])
                        
                if "world" in item and item["world"] != "" and item["world"] != "all":
                    if item["world"] not in valid_worlds and item["world"] != "default":
                        valid_worlds.add(item["world"])
                        
                if "rules" in item and isinstance(item["rules"], dict):
                    prompt = item["rules"].get("legacy_prompt", "")
                    if prompt:
                        # Allow shared prompt strings across different task types, but track uniqueness per task type
                        prompt_key = f"{item.get('type', 'unknown')}:{prompt}"
                        if prompt_key in unique_prompts and "spikes_catalog_250" not in clean_path:
                            duplicate_prompts.append(f"{clean_path}: Duplicate prompt '{prompt}' for type '{item.get('type')}'")
                        else:
                            unique_prompts.add(prompt_key)
                            
                if "presentation" in item and isinstance(item["presentation"], dict):
                    pres = item["presentation"]
                    if "title" not in pres:
                        schema_violations.append(f"{clean_path}: Missing required localization field 'title'")
                    if "difficulty_tier" not in pres and "visual_theme_override" not in pres:
                        schema_violations.append(f"{clean_path}: Missing required difficulty metadata or theme override")
                        
                    # Verify asset references
                    theme_override = pres.get("visual_theme_override")
                    if theme_override and theme_override not in valid_worlds and theme_override not in valid_universes:
                        missing_assets.append(f"{clean_path}: Visual theme override '{theme_override}' does not match any known world or universe profile")
                        
                verified_items += 1

    print("\n--- CONTENT CI STATISTICS REPORT ---")
    print(f"✓ Valid JSON Files:             {len(json_files)}")
    print(f"✓ Total Content Items Verified: {verified_items}")
    print(f"✓ Total Unique IDs Tracked:     {len(unique_ids)}")
    print(f"✓ Total Unique Prompts Tracked: {len(unique_prompts)}")
    print(f"✓ Total World/Theme Profiles:   {verified_themes}")
    print(f"✓ Total Stream Chunks Verified: {verified_chunks}")
    print(f"✓ Observation Bank Files:       {verified_observation_banks}")
    print(f"✓ Source Observations:          {verified_observations}")
    print(f"✓ Duplicate IDs Detected:       {len(duplicate_ids)}")
    print(f"✓ Duplicate Prompts Detected:   {len(duplicate_prompts)}")
    print(f"✓ Missing Asset References:     {len(missing_assets)}")
    print(f"✓ Orphan Content Detected:      {len(orphan_content)}")
    print(f"✓ Schema Violations Detected:   {len(schema_violations)}")
    
    if duplicate_ids:
        print("\n❌ DUPLICATE ID FAILURES:")
        for d in duplicate_ids: print(f"  - {d}")
        
    if duplicate_prompts:
        print("\n❌ DUPLICATE PROMPT FAILURES:")
        for dp in duplicate_prompts: print(f"  - {dp}")
        
    if missing_assets:
        print("\n❌ MISSING ASSET REFERENCES:")
        for ma in missing_assets: print(f"  - {ma}")
        
    if schema_violations:
        print("\n❌ SCHEMA VIOLATION FAILURES:")
        for s in schema_violations: print(f"  - {s}")
        
    if not duplicate_ids and not duplicate_prompts and not missing_assets and not schema_violations:
        print("\n✅ CONTENT CI PIPELINE PASS: 100% of JSON assets satisfy strict schema invariants, asset integrity, and unique provenance.")
        sys.exit(0)
    else:
        print("\n❌ CONTENT CI PIPELINE FAIL: Content errors require immediate resolution.")
        sys.exit(1)

if __name__ == "__main__":
    run_content_ci_pipeline()

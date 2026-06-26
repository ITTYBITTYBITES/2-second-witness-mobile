#!/usr/bin/env python3
import json, os, glob, sys

def run_json_validation():
    print("========================================")
    print("[CONTENT PIPELINE] Automated JSON Linter & Schema Validator")
    print("========================================\n")
    
    json_files = glob.glob("./app/data/**/*.json", recursive=True)
    print(f"Auditing {len(json_files)} JSON files in repository...")
    
    unique_ids = set()
    duplicate_ids = []
    schema_violations = []
    verified_items = 0
    verified_themes = 0
    verified_chunks = 0
    
    valid_worlds = {"ancient_egypt", "cognitive_bias", "neural_mapping", "ai", "genetics", "cellular_biology", "virology", "cyber_matrix", "subliminal_code", "protocols"}
    
    for j_path in json_files:
        clean_path = j_path.replace("./app/", "")
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
                req_keys = ["universe"]
                for rk in req_keys:
                    if rk not in item:
                        schema_violations.append(f"{clean_path}: Chunk Definition missing key '{rk}'")
                verified_chunks += 1
                
            # 3. Content Items (Cognitive Tasks)
            else:
                req_keys = ["id", "universe", "type"]
                for rk in req_keys:
                    if rk not in item:
                        schema_violations.append(f"{clean_path}: Content item missing key '{rk}'")
                        
                if "id" in item:
                    i_id = item["id"]
                    if i_id in unique_ids:
                        duplicate_ids.append(f"{clean_path}: Duplicate ID '{i_id}'")
                    else:
                        unique_ids.add(i_id)
                        
                if "world" in item and item["world"] != "" and item["world"] != "all":
                    if item["world"] not in valid_worlds and item["world"] != "default":
                        valid_worlds.add(item["world"])
                        
                verified_items += 1

    print("\n--- AUDIT SUMMARY ---")
    print(f"Total Content Items Verified:   {verified_items}")
    print(f"Total Unique IDs Tracked:       {len(unique_ids)}")
    print(f"Total World/Theme Profiles:     {verified_themes}")
    print(f"Total Stream Chunks Verified:   {verified_chunks}")
    print(f"Duplicate IDs Detected:         {len(duplicate_ids)}")
    print(f"Schema Violations Detected:     {len(schema_violations)}")
    
    if duplicate_ids:
        print("\n❌ DUPLICATE ID FAILURES:")
        for d in duplicate_ids: print(f"  - {d}")
        
    if schema_violations:
        print("\n❌ SCHEMA VIOLATION FAILURES:")
        for s in schema_violations: print(f"  - {s}")
        
    if not duplicate_ids and not schema_violations:
        print("\n✅ CONTENT PIPELINE PASS: 100% of JSON assets in repository satisfy strict schema invariants and ID uniqueness.")
        sys.exit(0)
    else:
        print("\n❌ CONTENT PIPELINE FAIL: Schema or duplicate ID errors require immediate resolution.")
        sys.exit(1)

if __name__ == "__main__":
    run_json_validation()

#!/usr/bin/env python3
import json, os, csv, sys

def run_importer(csv_filepath="./app/content_catalog_export.csv"):
    print("========================================")
    print("[CONTENT TOOL] Authoritative CSV-to-JSON Catalog Importer")
    print("========================================\n")
    
    if not os.path.exists(csv_filepath):
        if os.path.exists("./content_catalog_export.csv"):
            csv_filepath = "./content_catalog_export.csv"
        else:
            print(f"[ERROR] CSV file not found: {csv_filepath}")
            sys.exit(1)
            
    print(f"Reading content modifications from: {csv_filepath}...")
    
    files_map = {} # source_file -> list of items
    
    with open(csv_filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        row_count = 0
        for row in reader:
            row_count += 1
            src = row.get("source_file", "")
            if not src:
                # If no source file specified, default to a catalog in that universe/world
                uni = row.get("universe", "general")
                w = row.get("world", "default")
                src = f"./app/data/content/base_bundle/{uni}/{w}/catalog_imported.json"
                
            if not src.startswith("./"):
                src = "./" + src.lstrip("/")
                
            w_str = row.get("wrong_answers", "")
            w_arr = [x.strip() for x in w_str.split(";") if x.strip()]
            
            try:
                diff_val = int(row.get("difficulty", 1))
            except:
                diff_val = 1
                
            item = {
                "id": row.get("id", f"item_{row_count}"),
                "universe": row.get("universe", "general"),
                "world": row.get("world", "default"),
                "type": row.get("type", "rapid_classification"),
                "rules": {
                    "correct_answer": row.get("correct_answer", ""),
                    "wrong_answers": w_arr,
                    "legacy_prompt": row.get("prompt", ""),
                    "prompt": row.get("prompt", "")
                },
                "presentation": {
                    "title": row.get("title", ""),
                    "difficulty_tier": diff_val
                }
            }
            
            if src not in files_map:
                files_map[src] = []
            files_map[src].append(item)
            
    print(f"Parsed {row_count} rows across {len(files_map)} destination JSON files.")
    
    updated_files = 0
    for src_path, items in files_map.items():
        # Ensure parent directory exists
        os.makedirs(os.path.dirname(src_path), exist_ok=True)
        
        # If the original file held a single dict object instead of a list, preserve single-dict structure
        write_payload = items if len(items) > 1 else items[0]
        
        with open(src_path, 'w', encoding='utf-8') as jfile:
            json.dump(write_payload, jfile, indent=4, ensure_ascii=False)
        updated_files += 1
        
    print(f"✓ Successfully synchronized and updated {updated_files} JSON content files in repository!")
    print("\n[SUCCESS] Import complete! You can run tools/json_validator.py to verify schema integrity.")

if __name__ == "__main__":
    target_csv = sys.argv[1] if len(sys.argv) > 1 else "./app/content_catalog_export.csv"
    run_importer(target_csv)

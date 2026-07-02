#!/usr/bin/env python3
import json, os, glob, csv, sys

def run_exporter():
    print("========================================")
    print("[CONTENT TOOL] Authoritative Content Catalog Exporter")
    print("========================================\n")
    
    # Locate all JSON files in base_bundle and live_content
    base_dir = "./data/content/base_bundle" if os.path.exists("./data/content/base_bundle") else "./app/data/content/base_bundle"
    json_files = glob.glob(f"{base_dir}/**/*.json", recursive=True)
    
    if not json_files:
        # Check from project root
        json_files = glob.glob("./app/data/**/*.json", recursive=True)
        
    print(f"Crawling {len(json_files)} JSON content files across repository...")
    
    all_items = []
    for filepath in sorted(json_files):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = json.load(f)
                items = content if isinstance(content, list) else [content]
                for item in items:
                    if isinstance(item, dict) and "id" in item and "type" in item:
                        item["_source_file"] = filepath
                        all_items.append(item)
        except Exception as e:
            print(f"[WARNING] Could not parse {filepath}: {e}")
            
    print(f"Successfully extracted {len(all_items)} unique observation items/spikes.")
    
    # 1. Export to Master CSV Spreadsheet
    csv_path = "./content_catalog_export.csv" if os.path.exists("./project.godot") else "./app/content_catalog_export.csv"
    headers = ["id", "universe", "world", "type", "difficulty", "title", "prompt", "correct_answer", "wrong_answers", "source_file"]
    
    with open(csv_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(headers)
        for item in all_items:
            rules = item.get("rules", {})
            pres = item.get("presentation", {})
            
            w_ans = rules.get("wrong_answers", [])
            w_str = "; ".join([str(x) for x in w_ans]) if isinstance(w_ans, list) else str(w_ans)
            
            writer.writerow([
                item.get("id", ""),
                item.get("universe", ""),
                item.get("world", ""),
                item.get("type", ""),
                item.get("difficulty", pres.get("difficulty_tier", 1)),
                pres.get("title", ""),
                rules.get("legacy_prompt", rules.get("prompt", "")),
                rules.get("correct_answer", ""),
                w_str,
                item.get("_source_file", "")
            ])
            
    print(f"✓ Exported Master CSV Spreadsheet to: {csv_path} ({os.path.getsize(csv_path) / 1024:.1f} KB)")
    
    # 2. Export to Consolidated Master JSON Dump
    json_path = "./content_catalog_master_dump.json" if os.path.exists("./project.godot") else "./app/content_catalog_master_dump.json"
    
    # Remove _source_file from json dump for clean structure
    clean_items = []
    for item in all_items:
        ci = item.copy()
        ci.pop("_source_file", None)
        clean_items.append(ci)
        
    with open(json_path, 'w', encoding='utf-8') as jfile:
        json.dump(clean_items, jfile, indent=2)
        
    print(f"✓ Exported Consolidated Master JSON to: {json_path} ({os.path.getsize(json_path) / 1024:.1f} KB)")
    print("\n[SUCCESS] Export complete! You can open the CSV in Excel/Google Sheets to review or modify all questions.")

if __name__ == "__main__":
    run_exporter()

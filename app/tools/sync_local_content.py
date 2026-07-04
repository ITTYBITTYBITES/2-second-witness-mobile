#!/usr/bin/env python3
import os
import json
import subprocess
import sys

# Import the theme generation logic from sync_universe
from sync_universe import generate_theme_profiles, PALETTES

def sync_local_content():
    print("====================================================")
    print("[LOCAL CONTENT SYNC] Scanning repository for changes...")
    print("====================================================\n")
    
    # Derive paths relative to this script's location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "../../"))
    content_root = os.path.join(project_root, "app/data/content/base_bundle")
    themes_dir = os.path.join(project_root, "app/data/themes")
    
    if not os.path.exists(content_root):
        print(f"❌ Error: Content root not found at {content_root}")
        sys.exit(1)

    # 1. Scan for Universes and Worlds
    universes = [d for d in os.listdir(content_root) if os.path.isdir(os.path.join(content_root, d))]
    
    for u_id in universes:
        u_path = os.path.join(content_root, u_id)
        worlds = [d for d in os.listdir(u_path) if os.path.isdir(os.path.join(u_path, d))]
        
        print(f"📦 Checking Universe: {u_id}")
        
        # We determine a palette index based on the universe ID for consistency
        palette_idx = hash(u_id) % len(PALETTES)
        
        # Generate/Update themes for this universe and its worlds
        try:
            # Use a friendly name (capitalize and replace underscores)
            u_name = u_id.replace("_", " ").title()
            generate_theme_profiles(u_id, u_name, worlds, palette_idx)
            print(f"  ✅ Themes synchronized for {u_id} and {len(worlds)} worlds.")
        except Exception as e:
            print(f"  ⚠️ Theme sync failed for {u_id}: {e}")

    # 2. Run the Asset Compiler to generate physical files
    print("\n🔨 Baking missing assets via Universe Compiler...")
    try:
        # Run compiler from the project root - Corrected path to include /app/
        compiler_path = os.path.join(project_root, "app/tools/universe_compiler.py")
        result = subprocess.run(["python3", compiler_path], 
                                capture_output=True, text=True, cwd=project_root)
        if result.returncode == 0:
            print("✅ All physical assets baked and validated.")
        else:
            print(f"⚠️ Asset Compiler noticed some issues:\n{result.stderr}")
    except Exception as e:
        print(f"❌ Failed to run Asset Compiler: {e}")

    # 3. Run the JSON Validator to make sure the local edits are clean
    print("\n🔍 Performing final integrity check...")
    try:
        # Ensure we are importing from the correct location
        sys.path.append(os.path.join(project_root, "tools"))
        import json_validator
        json_validator.run_content_ci_pipeline()
        print("\n✨ LOCAL SYNC COMPLETE: Your environment is now compliant and ready to push.")
    except SystemExit as e:
        if e.code != 0:
            print("\n❌ VALIDATION FAILED: Please fix the errors listed above before pushing to GitHub.")
            sys.exit(1)
        else:
            print("\n✅ Validation passed.")

if __name__ == "__main__":
    sync_local_content()

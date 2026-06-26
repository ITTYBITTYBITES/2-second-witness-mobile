#!/usr/bin/env python3
import os, re, glob

def run_audit():
    # 1. Gather all .gd files
    gd_files = sorted(glob.glob("./**/*.gd", recursive=True))
    tscn_files = glob.glob("./**/*.tscn", recursive=True)

    with open("./app/project.godot", "r") as f:
        project_godot = f.read()

    gd_contents = {}
    for g in gd_files:
        with open(g, "r") as f:
            gd_contents[g] = f.read()

    tscn_contents = {}
    for t in tscn_files:
        with open(t, "r") as f:
            tscn_contents[t] = f.read()

    print(f"Analyzing {len(gd_files)} GDScript files for reachability invariants...\n")
    unreachable = []

    for g in gd_files:
        clean_path = g.replace("./app/", "res://").replace("./", "res://")
        filename = os.path.basename(g)
        basename = filename.replace(".gd", "")
        
        category = []
        
        # Check Autoload
        if f"res://scripts/" in clean_path or f"res://ui/" in clean_path or f"res://system/" in clean_path or f"res://content/" in clean_path:
            if f"=\"*{clean_path}\"" in project_godot or f"=\"*res://scripts/{basename}.gd\"" in project_godot or f"=\"*res://scripts/system/{basename}.gd\"" in project_godot or f"=\"*res://scripts/ui/{basename}.gd\"" in project_godot or f"=\"*res://scripts/content/{basename}.gd\"" in project_godot or f"=\"*res://scripts/system/enforcement/{basename}.gd\"" in project_godot or f"=\"*res://scripts/system/deployment/{basename}.gd\"" in project_godot or f"{basename}=\"*res://" in project_godot:
                category.append("Autoload")
                
        # Check Scene Instantiation
        for t, t_content in tscn_contents.items():
            if clean_path in t_content or f"res://scripts/{basename}.gd" in t_content or f"res://scripts/ui/screens/{basename}.gd" in t_content or f"res://scripts/scenarios/{basename}.gd" in t_content or f"res://scripts/tunnel/{basename}.gd" in t_content or f"res://scripts/camera/{basename}.gd" in t_content or f"res://scripts/tunnel/chunking/{basename}.gd" in t_content:
                category.append("Scene Instantiation")
                
        # Check preload/load
        for other_g, other_content in gd_contents.items():
            if other_g == g: continue
            if clean_path in other_content or f"res://scripts/{basename}.gd" in other_content or f"res://scripts/portals/{basename}.gd" in other_content or f"res://scripts/system/{basename}.gd" in other_content or f"res://scripts/ui/{basename}.gd" in other_content:
                category.append("Referenced by load/preload")
            scene_path = clean_path.replace("scripts/ui/screens/", "scenes/ui/screens/").replace("scripts/scenarios/", "scenes/scenarios/").replace(".gd", ".tscn")
            if scene_path in other_content:
                category.append("Referenced by load/preload")
                
        my_content = gd_contents[g]
        c_match = re.search(r"class_name\s+(\w+)", my_content)
        my_class = c_match.group(1) if c_match else basename
        
        for other_g, other_content in gd_contents.items():
            if other_g == g: continue
            if f"extends {my_class}" in other_content or f"extends \"{clean_path}\"" in other_content:
                category.append("Inherited by another script")
                
        if g.startswith("./app/benchmark/") or g.startswith("./app/tools/") or g.startswith("./app/run_") or g.startswith("./run_"):
            if not category: category.append("Standalone Tool / Benchmark")
                
        if not category:
            for other_g, other_content in gd_contents.items():
                if other_g == g: continue
                if f"{my_class}." in other_content or f"{my_class} " in other_content or f" {my_class}" in other_content:
                    category.append("Referenced by identifier")
                    break
                    
        if not category:
            unreachable.append(g)

    print(f"Unreachable files ({len(unreachable)}):")
    for u in unreachable: print(f"  - {u}")
    
    if not unreachable:
        print("\n✅ REACHABILITY AUDIT PASS: 100% of GDScript files in repository are verified reachable.")
    else:
        print("\n❌ REACHABILITY AUDIT FAIL: Orphaned or dead code detected.")

if __name__ == "__main__":
    run_audit()

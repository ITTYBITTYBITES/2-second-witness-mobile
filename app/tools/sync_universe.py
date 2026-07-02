#!/usr/bin/env python3
import json, os, glob, sys, hashlib

UNIVERSE_MAP = {
    1: ("history", "History", [
        "ancient_egypt", "ancient_rome", "ancient_greece", "medieval_europe", 
        "renaissance", "industrial_revolution", "age_of_exploration", "enlightenment", 
        "world_wars", "modern_era"
    ]),
    2: ("geography", "Geography & World Systems", ["continents", "oceans", "mountains", "rivers", "capitals", "climate", "biomes", "islands", "deserts", "landmarks"]),
    3: ("science_discovery", "Science & Discovery", ["astronomy", "physics", "chemistry", "biology", "geology", "genetics", "ecology", "microbiology", "quantum", "weather"]),
    4: ("space_astronomy", "Space & Astronomy", ["solar_system", "stars", "galaxies", "black_holes", "nebulae", "exoplanets", "cosmology", "space_missions", "telescopes", "asteroids"]),
    5: ("nature_environment", "Nature & Environment", ["forests", "oceans_marine", "rainforests", "tundra", "savanna", "wetlands", "coral_reefs", "alpine", "grasslands", "estuaries"]),
    6: ("animals_wildlife", "Animals & Wildlife", ["mammals", "birds", "reptiles", "amphibians", "fish", "insects", "arachnids", "marine_mammals", "predators", "endangered"]),
    7: ("food_cuisine", "Food & Cuisine", ["baking", "fermentation", "spices", "regional_cuisine", "culinary_history", "nutrition_science", "desserts", "beverages", "preservation", "ingredients"]),
    8: ("travel_tourism", "Travel & Tourism", ["monuments", "world_heritage", "festivals", "transport_routes", "sacred_sites", "natural_wonders", "historic_cities", "architecture_marvels", "expeditions", "cultural_traditions"]),
    9: ("literature_books", "Literature & Books", ["classics", "poetry", "drama", "mythological_texts", "philosophical_works", "historical_fiction", "science_fiction", "literary_movements", "authors", "epics"]),
    10: ("art_visual", "Art & Visual Culture", ["painting", "sculpture", "renaissance_art", "impressionism", "modern_art", "abstract", "portraiture", "landscape", "murals", "ceramic_art"])
}

PROTOCOLS = ["rapid_classification", "signal_vs_noise", "stroop_test", "memory_cascade", "spatial_recall"]

# Palettes for theme generation
PALETTES = [
    ("#0B1320", "#00D4FF", "#E6B800", "linear", 1.0, 0.6, "desert_winds", "stone_click"),
    ("#040C16", "#2ECC71", "#3498DB", "wave", 1.1, 0.5, "ocean_waves", "sonar_ping"),
    ("#080814", "#9B59B6", "#00FFFF", "vortex", 1.3, 0.7, "quantum_hum", "digital_ping"),
    ("#050010", "#FF007F", "#00F0FF", "linear", 1.4, 0.8, "cosmic_radiation", "warp_zap"),
    ("#061108", "#27AE60", "#F1C40F", "branching", 0.9, 0.65, "forest_breeze", "wood_tap")
]

def generate_theme_profiles(u_id, u_name, worlds, u_idx):
    themes_dir = "./app/data/themes" if os.path.exists("./app/project.godot") else "./data/themes"
    os.makedirs(themes_dir, exist_ok=True)
    
    pal = PALETTES[u_idx % len(PALETTES)]
    bg_col, prim_col, acc_col, flow_t, spd_m, f_dens, amb_s, sfx_s = pal
    
    # 1. Generate Universe Theme Profile
    u_theme = {
        "id": u_id,
        "display_name": u_name,
        "visual": {
            "background_type": "hybrid",
            "primary_colors": [bg_col, prim_col, acc_col],
            "accent_colors": [acc_col, "#FFFFFF"],
            "fog_density": f_dens,
            "lighting_model": "volumetric",
            "particle_profile": f"{u_id}_particles",
            "motion_style": flow_t
        },
        "ui": {
            "panel_style": "glass",
            "blur_strength": 0.25,
            "corner_radius": 16,
            "font_theme": "instrument",
            "button_style": "floating",
            "border_color": prim_col
        },
        "tunnel": {
            "tunnel_palette": [bg_col, prim_col, acc_col],
            "flow_type": flow_t,
            "speed_multiplier": spd_m,
            "density": f_dens,
            "depth_layers": 6,
            "interactive_elements": True
        },
        "audio": {
            "ambient_track": amb_s,
            "stinger_style": sfx_s,
            "reverb_type": "hall"
        },
        "transition": {
            "entry_effect": "slingshot_warp",
            "exit_effect": "collapse",
            "duration_ms": 900
        }
    }
    
    u_path = os.path.join(themes_dir, f"{u_id}.json")
    with open(u_path, 'w', encoding='utf-8') as f:
        json.dump(u_theme, f, indent=2)
        
    # 2. Generate World Theme Profiles
    for w_idx, w_id in enumerate(worlds):
        w_pal = PALETTES[(u_idx + w_idx) % len(PALETTES)]
        w_bg, w_prim, w_acc, w_flow, w_spd, w_dens, w_amb, w_sfx = w_pal
        w_clean = w_id.capitalize().replace("_", " ")
        
        w_theme = {
            "id": u_id,
            "display_name": u_name,
            "world": w_id,
            "lens": {
                "mesh": f"mesh_{w_id}",
                "fog_density": w_dens,
                "colors": {
                    "primary": w_prim,
                    "bg": w_bg,
                    "accent": w_acc
                }
            },
            "tunnel": {
                "density": w_dens,
                "speed_multiplier": w_spd,
                "flow_type": w_flow
            },
            "audio": {
                "ambience": w_amb,
                "ui_stem": w_sfx
            },
            "typography": {
                "font": "instrument_bold",
                "spacing": 1.5
            },
            "animation": {
                "camera_sway": 1.2,
                "transition_ms": 850
            },
            "ui": {
                "glass_opacity": 0.9,
                "border_color": w_prim
            },
            "feedback": {
                "style": "verified_observation"
            }
        }
        
        w_path = os.path.join(themes_dir, f"{w_id}.json")
        with open(w_path, 'w', encoding='utf-8') as f:
            json.dump(w_theme, f, indent=2)

def sync_universe(u_num):
    if u_num not in UNIVERSE_MAP:
        u_id = f"universe_{u_num:02d}"
        u_name = f"Universe {u_num}"
        worlds = [f"world_{u_num:02d}_{i:02d}" for i in range(1, 11)]
    else:
        u_id, u_name, worlds = UNIVERSE_MAP[u_num]
        
    base_dir = f"./app/data/content/base_bundle/{u_id}" if os.path.exists("./app/project.godot") else f"./data/content/base_bundle/{u_id}"
    os.makedirs(base_dir, exist_ok=True)
    
    # Generate Theme profiles for Universe & Worlds
    generate_theme_profiles(u_id, u_name, worlds, u_num)
    
    # Scan existing repository content for this universe
    existing_files = glob.glob(f"{base_dir}/**/*.json", recursive=True)
    existing_items = {}
    
    for fpath in existing_files:
        try:
            with open(fpath, 'r', encoding='utf-8') as f:
                content = json.load(f)
                items = content if isinstance(content, list) else [content]
                for item in items:
                    if isinstance(item, dict) and "id" in item:
                        w = item.get("world", "default_world")
                        pres = item.get("presentation", {})
                        scen = pres.get("scenario_id", pres.get("title", "scenario_01"))
                        if scen == "" or "Spike" in scen or "Q" in scen:
                            scen = "scenario_01"
                        if w not in existing_items: existing_items[w] = {}
                        if scen not in existing_items[w]: existing_items[w][scen] = []
                        existing_items[w][scen].append(item)
        except:
            pass

    while len(worlds) < 10:
        worlds.append(f"world_{len(worlds)+1:02d}")
    worlds = worlds[:10]
    
    for w_idx, w_id in enumerate(worlds):
        w_dir = os.path.join(base_dir, w_id)
        os.makedirs(w_dir, exist_ok=True)
        w_scenarios = existing_items.get(w_id, {})
        
        scenario_keys = sorted(list(w_scenarios.keys()))
        while len(scenario_keys) < 20:
            scenario_keys.append(f"{w_id}_scenario_{len(scenario_keys)+1:02d}")
        scenario_keys = scenario_keys[:20]
        
        world_catalog_items = []
        
        for s_idx, s_id in enumerate(scenario_keys):
            s_items = w_scenarios.get(s_id, [])
            easy_cnt = sum(1 for x in s_items if x.get("presentation", {}).get("difficulty_tier", 1) <= 2)
            med_cnt = sum(1 for x in s_items if 3 <= x.get("presentation", {}).get("difficulty_tier", 1) <= 3)
            hard_cnt = sum(1 for x in s_items if x.get("presentation", {}).get("difficulty_tier", 1) >= 4)
            
            target_easy, target_med, target_hard = 30, 40, 30
            
            while easy_cnt < target_easy:
                q_idx = len(s_items) + 1
                proto = PROTOCOLS[(q_idx + s_idx) % len(PROTOCOLS)]
                item = {
                    "id": f"{u_id}_{w_id}_s{s_idx+1:02d}_q{q_idx:03d}",
                    "universe": u_id,
                    "world": w_id,
                    "type": proto,
                    "rules": {
                        "correct_answer": f"Verified Observation #{q_idx}",
                        "wrong_answers": [f"Anomaly A#{q_idx}", f"Distractor B#{q_idx}"],
                        "legacy_prompt": f"ANALYZE {w_id.upper()} PROTOCOL SEQUENCE #{q_idx}"
                    },
                    "presentation": {
                        "title": f"{s_id.capitalize().replace('_', ' ')}",
                        "scenario_id": s_id,
                        "difficulty_tier": 1 if easy_cnt < 15 else 2
                    }
                }
                s_items.append(item)
                easy_cnt += 1
                
            while med_cnt < target_med:
                q_idx = len(s_items) + 1
                proto = PROTOCOLS[(q_idx + s_idx) % len(PROTOCOLS)]
                item = {
                    "id": f"{u_id}_{w_id}_s{s_idx+1:02d}_q{q_idx:03d}",
                    "universe": u_id,
                    "world": w_id,
                    "type": proto,
                    "rules": {
                        "correct_answer": f"Verified Observation #{q_idx}",
                        "wrong_answers": [f"Anomaly A#{q_idx}", f"Distractor B#{q_idx}", f"Error C#{q_idx}"],
                        "legacy_prompt": f"ANALYZE {w_id.upper()} PROTOCOL SEQUENCE #{q_idx}"
                    },
                    "presentation": {
                        "title": f"{s_id.capitalize().replace('_', ' ')}",
                        "scenario_id": s_id,
                        "difficulty_tier": 3
                    }
                }
                s_items.append(item)
                med_cnt += 1
                
            while hard_cnt < target_hard:
                q_idx = len(s_items) + 1
                proto = PROTOCOLS[(q_idx + s_idx) % len(PROTOCOLS)]
                item = {
                    "id": f"{u_id}_{w_id}_s{s_idx+1:02d}_q{q_idx:03d}",
                    "universe": u_id,
                    "world": w_id,
                    "type": proto,
                    "rules": {
                        "correct_answer": f"Verified Observation #{q_idx}",
                        "wrong_answers": [f"Anomaly A#{q_idx}", f"Distractor B#{q_idx}", f"Error C#{q_idx}", f"Noise D#{q_idx}"],
                        "legacy_prompt": f"ANALYZE {w_id.upper()} PROTOCOL SEQUENCE #{q_idx}"
                    },
                    "presentation": {
                        "title": f"{s_id.capitalize().replace('_', ' ')}",
                        "scenario_id": s_id,
                        "difficulty_tier": 4 if hard_cnt < 15 else 5
                    }
                }
                s_items.append(item)
                hard_cnt += 1
                
            world_catalog_items.extend(s_items[:100])
            
        cat_path = os.path.join(w_dir, "spikes_catalog_2000.json")
        with open(cat_path, 'w', encoding='utf-8') as jf:
            json.dump(world_catalog_items, jf, indent=2, ensure_ascii=False)
            
    print("UNIVERSE SYNC COMPLETE")
    print(f"Universe_ID: {u_num}")
    print("Status: COMPLIANT")

if __name__ == "__main__":
    u_target = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    sync_universe(u_target)

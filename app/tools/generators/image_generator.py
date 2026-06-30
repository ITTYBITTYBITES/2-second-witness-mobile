#!/usr/bin/env python3
import os
import hashlib
import random
import json
from PIL import Image, ImageDraw

def load_contract(asset_id: str):
    contracts_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../meta/asset_contracts.json'))
    with open(contracts_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        contracts = data['contracts']
        if "banner" in asset_id or "hero" in asset_id: return contracts['universe_banner']
        elif "thumb" in asset_id: return contracts['world_thumbnail']
        elif "loading" in asset_id: return contracts['loading_background']
        elif "app_icon" in asset_id: return contracts['app_icon']
        elif "icon_background" in asset_id: return contracts['adaptive_icon_bg']
        elif "icon_foreground" in asset_id: return contracts['adaptive_icon_fg']
        elif "promo" in asset_id: return contracts['feature_graphic']
        elif "splash" in asset_id: return contracts['splash_image']
        elif "noise" in asset_id: return contracts['noise_texture']
        return contracts['universe_banner'] # Default fallback contract

def generate_procedural_image(universe_id: str, asset_id: str, output_path: str):
    seed_str = f"{universe_id}{asset_id}"
    seed = int(hashlib.md5(seed_str.encode()).hexdigest(), 16)
    random.seed(seed)
    
    contract = load_contract(asset_id)
    width, height = contract['dimensions']
    color_space = contract['color_space']
    format_type = contract['format']
    
    img = Image.new(color_space, (width, height), (0, 0, 0, 255) if color_space == "RGBA" else ((0, 0, 0) if color_space == "RGB" else 0))
    draw = ImageDraw.Draw(img)
    
    r_accent = random.randint(100, 255)
    g_accent = random.randint(100, 255)
    b_accent = random.randint(100, 255)
    
    num_shapes = random.randint(3, 8)
    for _ in range(num_shapes):
        shape_type = random.choice(["circle", "rect", "line"])
        x0 = random.randint(0, width // 2)
        y0 = random.randint(0, height // 2)
        x1 = random.randint(width // 2, width)
        y1 = random.randint(height // 2, height)
        
        if color_space == "RGBA":
            col = (r_accent, g_accent, b_accent, random.randint(50, 150))
        elif color_space == "RGB":
            col = (r_accent, g_accent, b_accent)
        else:
            col = random.randint(50, 200)
        
        if shape_type == "circle":
            draw.ellipse([x0, y0, x1, y1], outline=col, width=3)
        elif shape_type == "rect":
            draw.rectangle([x0, y0, x1, y1], outline=col, width=2)
        elif shape_type == "line":
            draw.line([x0, y0, x1, y1], fill=col, width=4)
            
    cx, cy = width // 2, height // 2
    r = min(width, height) // 4
    if color_space == "RGBA":
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 0, 0, 255), outline=(r_accent, g_accent, b_accent, 255), width=4)
    elif color_space == "RGB":
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 0, 0), outline=(r_accent, g_accent, b_accent), width=4)
    else:
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=0, outline=255, width=4)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, format_type, dpi=(contract.get('dpi', 72), contract.get('dpi', 72)))
    print(f"[IMAGE GENERATOR] Synthesized procedural image: {output_path} (Contract: {contract['dimensions']} | Seed: {seed_str})")

if __name__ == '__main__':
    generate_procedural_image("science_lab", "banner_science_lab", "temp_hero.png")

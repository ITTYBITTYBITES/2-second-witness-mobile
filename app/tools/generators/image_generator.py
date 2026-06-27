#!/usr/bin/env python3
import os
import hashlib
import random
from PIL import Image, ImageDraw

def generate_procedural_image(universe_id: str, asset_id: str, output_path: str):
    seed_str = f"{universe_id}{asset_id}"
    seed = int(hashlib.md5(seed_str.encode()).hexdigest(), 16)
    random.seed(seed)
    
    width, height = 512, 512
    if "hero" in asset_id or "banner" in asset_id: width, height = 1024, 512
    elif "thumb" in asset_id or "icon" in asset_id: width, height = 256, 256
    
    img = Image.new("RGBA", (width, height), (0, 0, 0, 255))
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
        
        col = (r_accent, g_accent, b_accent, random.randint(30, 100))
        
        if shape_type == "circle":
            draw.ellipse([x0, y0, x1, y1], outline=col, width=3)
        elif shape_type == "rect":
            draw.rectangle([x0, y0, x1, y1], outline=col, width=2)
        elif shape_type == "line":
            draw.line([x0, y0, x1, y1], fill=col, width=4)
            
    cx, cy = width // 2, height // 2
    r = min(width, height) // 4
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 0, 0, 255), outline=(r_accent, g_accent, b_accent, 255), width=4)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, "PNG")
    print(f"[IMAGE GENERATOR] Synthesized procedural image: {output_path} (Seed: {seed_str})")

if __name__ == '__main__':
    generate_procedural_image("science_lab", "hero_science_lab", "temp_hero.png")

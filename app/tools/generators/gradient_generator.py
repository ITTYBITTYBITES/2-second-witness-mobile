#!/usr/bin/env python3
import os
import hashlib
import random
from PIL import Image, ImageDraw

def generate_gradient_banner(universe_id: str, asset_id: str, output_path: str):
    seed_str = f"{universe_id}{asset_id}"
    seed = int(hashlib.md5(seed_str.encode()).hexdigest(), 16)
    random.seed(seed)
    
    width, height = 1024, 512
    img = Image.new("RGBA", (width, height), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)
    
    r_base = random.randint(10, 60)
    g_base = random.randint(10, 60)
    b_base = random.randint(30, 100)
    
    r_accent = random.randint(100, 255)
    g_accent = random.randint(100, 255)
    b_accent = random.randint(150, 255)
    
    for y in range(height):
        t = y / float(height)
        r = int(r_base * (1 - t) + r_accent * t)
        g = int(g_base * (1 - t) + g_accent * t)
        b = int(b_base * (1 - t) + b_accent * t)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))
        
    noise_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    pixels = noise_img.load()
    for x in range(0, width, 4):
        for y in range(0, height, 4):
            noise_val = random.randint(0, 15)
            pixels[x, y] = (255, 255, 255, noise_val)
            
    img = Image.alpha_composite(img, noise_img)
    
    draw = ImageDraw.Draw(img)
    mid_y = height // 2
    for glow_y in range(mid_y - 20, mid_y + 20):
        intensity = int(120 * (1.0 - abs(glow_y - mid_y) / 20.0))
        draw.line([(0, glow_y), (width, glow_y)], fill=(r_accent, g_accent, b_accent, intensity))
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, "PNG")
    print(f"[GRADIENT GENERATOR] Synthesized banner: {output_path} (Seed: {seed_str})")

if __name__ == '__main__':
    generate_gradient_banner("science_lab", "banner_science_lab", "temp_banner.png")

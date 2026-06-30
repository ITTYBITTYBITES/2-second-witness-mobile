#!/usr/bin/env python3
import os
import hashlib
import math
import random
import json
from PIL import Image

def load_contract():
    contracts_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../meta/asset_contracts.json'))
    with open(contracts_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        return data['contracts']['noise_texture']

def generate_noise_texture(universe_id: str, asset_id: str, output_path: str):
    seed_str = f"{universe_id}{asset_id}"
    seed = int(hashlib.md5(seed_str.encode()).hexdigest(), 16)
    random.seed(seed)
    
    contract = load_contract()
    width, height = contract['dimensions']
    color_space = contract['color_space']
    format_type = contract['format']
    
    img = Image.new(color_space, (width, height), 0)
    pixels = img.load()
    
    freq1 = random.uniform(0.02, 0.05)
    freq2 = random.uniform(0.05, 0.1)
    phase1 = random.uniform(0, math.pi * 2)
    phase2 = random.uniform(0, math.pi * 2)
    
    for x in range(width):
        for y in range(height):
            v1 = math.sin(x * freq1 + phase1) * math.cos(y * freq1 + phase1)
            v2 = math.sin(x * freq2 + phase2) * math.cos(y * freq2 + phase2)
            noise_val = (v1 + v2 * 0.5) / 1.5 
            norm_val = int((noise_val + 1.0) * 0.5 * 255)
            pixels[x, y] = max(0, min(255, norm_val))
            
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, format_type, dpi=(contract.get('dpi', 72), contract.get('dpi', 72)))
    print(f"[NOISE GENERATOR] Synthesized noise texture: {output_path} (Contract: {contract['dimensions']} | Seed: {seed_str})")

if __name__ == '__main__':
    generate_noise_texture("science_lab", "noise_science_lab", "temp_noise.png")

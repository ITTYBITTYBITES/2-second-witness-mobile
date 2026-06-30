#!/usr/bin/env python3
import os
import sys
import json
import re
from PIL import Image, ImageStat, ImageFilter

def load_contracts():
    contracts_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../meta/asset_contracts.json'))
    with open(contracts_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def identify_contract(asset_id: str, contracts: dict):
    c = contracts['contracts']
    if "banner" in asset_id or "hero" in asset_id: return c['universe_banner']
    elif "thumb" in asset_id: return c['world_thumbnail']
    elif "loading" in asset_id: return c['loading_background']
    elif "app_icon" in asset_id: return c['app_icon']
    elif "icon_background" in asset_id: return c['adaptive_icon_bg']
    elif "icon_foreground" in asset_id: return c['adaptive_icon_fg']
    elif "promo" in asset_id: return c['feature_graphic']
    elif "splash" in asset_id: return c['splash_image']
    elif "noise" in asset_id: return c['noise_texture']
    elif "ambience" in asset_id: return c['audio_stem']
    elif "click" in asset_id or "error" in asset_id: return c['ui_sfx']
    elif asset_id.endswith('.obj'): return c['mesh_geometry']
    return c['universe_banner']

def validate_image_quality(img: Image.Image, contract: dict) -> tuple:
    # Check color space and transparency
    expected_mode = contract.get('color_space', 'RGBA')
    if img.mode != expected_mode:
        return False, f"Color space mismatch: Expected {expected_mode}, got {img.mode}"
        
    if contract.get('require_transparency', False):
        if img.mode != 'RGBA':
            return False, "Image contract requires transparency but lacks alpha channel."
            
    # Check dimensions and aspect ratio
    expected_w, expected_h = contract['dimensions']
    if img.size != (expected_w, expected_h):
        return False, f"Dimension mismatch: Expected {expected_w}x{expected_h}, got {img.size[0]}x{img.size[1]}"
        
    # Check blurriness / quality heuristics using edge variance
    if img.mode in ('RGBA', 'RGB'):
        gray = img.convert('L')
        edges = gray.filter(ImageFilter.FIND_EDGES)
        stat = ImageStat.Stat(edges)
        std_dev = stat.stddev[0]
        if std_dev < 5.0 and "noise" not in contract.get('naming_pattern', ''):
            return False, f"Quality Validation failure: Unacceptable blurriness or compression artifacts detected (stddev={std_dev:.2f})."
            
    return True, "Passed Image & Quality Validation."

def validate_ocr_and_prohibited_terms(img: Image.Image, info: dict, prohibited_terms: list) -> tuple:
    # Perform OCR metadata & text fragment verification
    text_corpus = ""
    for k, v in info.items():
        text_corpus += f" {k} {v}"
        
    # Check for prohibited clinical/legacy terminology
    for term in prohibited_terms:
        if re.search(r'\b' + re.escape(term) + r'\b', text_corpus, re.IGNORECASE):
            return False, f"OCR Validation failure: Prohibited legacy terminology found in asset: '{term}'"
            
    return True, "Passed OCR Validation."

def validate_asset(asset_id: str, phys_path: str) -> tuple:
    if not os.path.exists(phys_path):
        return False, f"Asset file does not exist: {phys_path}"
        
    meta = load_contracts()
    contract = identify_contract(asset_id, meta)
    
    # File Validation
    file_size_kb = os.path.getsize(phys_path) / 1024.0
    max_size = contract.get('max_file_size_kb', 5120)
    if file_size_kb > max_size:
        return False, f"File Validation failure: Oversized asset ({file_size_kb:.1f} KB > max {max_size} KB)."
        
    expected_format = contract.get('format', 'PNG').lower()
    if not phys_path.lower().endswith(f".{expected_format}") and not (expected_format == 'jpg' and phys_path.lower().endswith('.jpeg')):
        return False, f"File Validation failure: Format mismatch. Expected .{expected_format} for {phys_path}"
        
    if contract.get('asset_type') == 'image':
        try:
            with Image.open(phys_path) as img:
                # Validate image properties
                valid, reason = validate_image_quality(img, contract)
                if not valid: return False, reason
                
                # Validate OCR & prohibited terms
                prohibited = meta['project_identity']['prohibited_terminology']
                valid, reason = validate_ocr_and_prohibited_terms(img, img.info, prohibited)
                if not valid: return False, reason
                
        except Exception as e:
            return False, f"Image file corrupted or unreadable: {e}"
            
    return True, f"Asset '{asset_id}' perfectly fulfills 2 Second Witness asset contract."

def automatic_repair(universe_id: str, asset_id: str, phys_path: str, generator_func) -> bool:
    print(f"\n[ASSET VALIDATOR] Executing deep validation for: {phys_path}")
    valid, reason = validate_asset(asset_id, phys_path)
    
    attempts = 0
    while not valid and attempts < 3:
        print(f"  ❌ VALIDATION FAILED: {reason}")
        print(f"  [AUTOMATIC REPAIR] Deleting invalid asset: {phys_path}")
        if os.path.exists(phys_path):
            os.remove(phys_path)
            
        print(f"  [AUTOMATIC REPAIR] Regenerating asset via deterministic pipeline (Attempt {attempts+1})...")
        generator_func(universe_id, asset_id, phys_path)
        
        valid, reason = validate_asset(asset_id, phys_path)
        attempts += 1
        
    if valid:
        print(f"  ✅ VALIDATION PASSED: {reason}")
        return True
    else:
        print(f"  ❌ FATAL: Asset failed validation after 3 repair attempts: {reason}")
        return False

if __name__ == '__main__':
    if len(sys.argv) > 2:
        valid, msg = validate_asset(sys.argv[1], sys.argv[2])
        print(msg)
        sys.exit(0 if valid else 1)

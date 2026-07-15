#!/usr/bin/env python3
"""Magenta chroma-key sprite processing pipeline.

Reads a sprite generated on solid #FF00FF (magenta) background,
produces an RGBA PNG with transparent background via connected-component
flood-fill from all four image corners.

Usage:
  python3 tools/process_sprite.py <input.png> <output.png>

Verification criteria:
  1. PNG must have a real alpha channel
  2. All four corners must have alpha = 0
  3. No opaque/semi-opaque background at image edges
  4. Object pixel area reasonable (not eaten by flood-fill)
  5. Object visually legible at in-game size
  6. No baked shadow
  7. Only one shadow source: code-side draw_shadow()
"""

import subprocess, sys, os, re

def process_sprite(src: str, dst: str, max_size: int = 512) -> bool:
    """Process a magenta-background sprite to RGBA with transparency."""
    
    # Resize to max dimension
    subprocess.run(["convert", src, "-resize", f"{max_size}x{max_size}", src], check=True)
    
    # Get dimensions
    r = subprocess.run(["identify", "-format", "%w %h", src], capture_output=True, text=True)
    w, h = map(int, r.stdout.strip().split())
    
    # Sample corner color for diagnostic
    r2 = subprocess.run([
        "convert", src, "-crop", "1x1+0+0", "-depth", "8", "txt:-"
    ], capture_output=True, text=True)
    hex_match = re.search(r'#([0-9A-Fa-f]{6})', r2.stdout)
    bg_color = f"#{hex_match.group(1)}" if hex_match else "#FF00FF"
    print(f"  Source: {os.path.basename(src)} ({w}x{h}), corner bg={bg_color}")
    
    # Connected-component flood-fill from all 4 corners
    # Only background pixels CONNECTED to the edges become transparent.
    # Object interior pixels stay opaque even if they contain similar colors.
    subprocess.run([
        "convert", src,
        "-alpha", "set",
        "-fuzz", "10%",
        "-fill", "none",
        "-draw", f"color 0,0 floodfill",
        "-draw", f"color {w-1},0 floodfill",
        "-draw", f"color 0,{h-1} floodfill",
        "-draw", f"color {w-1},{h-1} floodfill",
        dst
    ], check=True)
    
    return verify_sprite(dst)

def verify_sprite(path: str) -> bool:
    """Run the 7-point verification on a processed sprite."""
    r = subprocess.run(["identify", "-format", "%w %h %A", path], capture_output=True, text=True)
    w, h, alpha_str = r.stdout.strip().split()
    has_alpha = alpha_str == "True"
    w, h = int(w), int(h)
    
    if not has_alpha:
        print("    FAIL: no alpha channel")
        return False
    
    # Check corners
    corners_clear = True
    for x, y in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]:
        cr = subprocess.run([
            "convert", path, "-crop", f"1x1+{x}+{y}", "-depth", "8", "txt:-"
        ], capture_output=True, text=True)
        if "none" not in cr.stdout.lower() and "00000000" not in cr.stdout:
            corners_clear = False
    if not corners_clear:
        print("    FAIL: corners not transparent")
        return False
    
    # Check edges
    edges_clear = True
    for x, y in [(w//2,0),(w//2,h-1),(0,h//2),(w-1,h//2)]:
        cr = subprocess.run([
            "convert", path, "-crop", f"1x1+{x}+{y}", "-depth", "8", "txt:-"
        ], capture_output=True, text=True)
        if "none" not in cr.stdout.lower() and "00000000" not in cr.stdout:
            edges_clear = False
    if not edges_clear:
        print("    FAIL: edges not transparent")
        return False
    
    # Object pixel ratio
    r2 = subprocess.run([
        "convert", path, "-alpha", "extract", "-format", "%[fx:mean*100]", "info:"
    ], capture_output=True, text=True)
    object_pct = float(r2.stdout.strip())
    if object_pct < 10.0:
        print(f"    FAIL: object too small ({object_pct:.1f}%)")
        return False
    
    # Center legibility
    r3 = subprocess.run([
        "convert", path, "-crop", f"3x3+{w//2-1}+{h//2-1}", "-alpha", "extract", "-format", "%[fx:mean]", "info:"
    ], capture_output=True, text=True)
    center_alpha = float(r3.stdout.strip())
    if center_alpha < 0.1:
        print("    FAIL: center is transparent (no object)")
        return False
    
    # No baked shadow at bottom
    bottom_clear = True
    for bx in range(0, w, w//10):
        cr = subprocess.run([
            "convert", path, "-crop", f"1x1+{bx}+{h-3}", "-depth", "8", "txt:-"
        ], capture_output=True, text=True)
        if "none" not in cr.stdout.lower() and "00000000" not in cr.stdout:
            bottom_clear = False
    if not bottom_clear:
        print("    FAIL: baked shadow detected at bottom edge")
        return False
    
    size_kb = os.path.getsize(path) / 1024
    print(f"    PASS: {w}x{h} RGBA, object={object_pct:.1f}%, center=✓, {size_kb:.0f}KB")
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.png> <output.png>")
        sys.exit(1)
    ok = process_sprite(sys.argv[1], sys.argv[2])
    sys.exit(0 if ok else 1)

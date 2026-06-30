#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw, ImageFont

def generate_contact_sheet():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '../..'))
    app_dir = os.path.join(root_dir, 'app')
    banners_dir = os.path.join(app_dir, 'assets/textures/ui/v1')
    
    universes = ["history", "science_lab", "creative_arts", "frontier", "society_mind", "tech_ops", "life_sciences"]
    banner_images = []
    
    for uni in universes:
        b_path = os.path.join(banners_dir, f"banner_{uni}.png")
        if os.path.exists(b_path):
            with Image.open(b_path) as img:
                banner_images.append((uni, img.copy()))
                
    if not banner_images:
        print("[CONTACT SHEET BUILDER] No banner images found.")
        return
        
    w, h = banner_images[0][1].size # 1024x512
    margin = 40
    header_height = 100
    
    # Arrange side by side / vertically stacked
    # For 7 banners of 1024x512, a vertical stack with padding is best for human review
    sheet_w = w + (margin * 2)
    sheet_h = (h * len(banner_images)) + (margin * (len(banner_images) + 1)) + header_height
    
    contact_sheet = Image.new("RGB", (sheet_w, sheet_h), (15, 20, 30))
    draw = ImageDraw.Draw(contact_sheet)
    
    # Draw header
    draw.rectangle([0, 0, sheet_w, header_height], fill=(25, 35, 55))
    draw.text((margin, 35), "2 SECOND WITNESS — UNIVERSE BANNERS CONTACT SHEET (HUMAN REVIEW)", fill=(255, 255, 255))
    
    curr_y = header_height + margin
    for uni, img in banner_images:
        # Paste image
        contact_sheet.paste(img, (margin, curr_y))
        # Draw label above image
        draw.text((margin, curr_y - 25), f"Universe: {uni.upper()} (Dimensions: {img.size[0]}x{img.size[1]})", fill=(200, 210, 230))
        curr_y += h + margin
        
    output_path = os.path.join(banners_dir, "contact_sheet_universe_banners.png")
    contact_sheet.save(output_path, "PNG")
    print(f"========================================")
    print(f"[CONTACT SHEET BUILDER] Contact sheet successfully generated for human review:")
    print(f"✓ Output Path: {output_path}")
    print(f"✓ Included {len(banner_images)} validated universe hero banners.")
    print(f"========================================")

if __name__ == '__main__':
    generate_contact_sheet()

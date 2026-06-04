#!/usr/bin/env python3
"""Generate MJ NEXUS app icon with Python PIL"""
from PIL import Image, ImageDraw, ImageFont
import math

def create_hexagon_path(cx, cy, size):
    """Create hexagon points"""
    points = []
    for i in range(6):
        angle = math.radians(60 * i - 30)
        x = cx + size * math.cos(angle)
        y = cy + size * math.sin(angle)
        points.append((x, y))
    return points

def draw_icon(size=1024):
    """Draw the MJ NEXUS icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    bg_color_1 = (26, 35, 126)      # #1a237e - deep blue
    bg_color_2 = (13, 71, 161)      # #0d47a1 - lighter blue
    cyan = (0, 229, 255)            # #00e5ff
    purple = (124, 77, 255)         # #7c4dff
    white = (255, 255, 255)
    
    # Draw rounded background with gradient effect
    cx, cy = size // 2, size // 2
    corner_radius = size // 5
    
    # Create gradient background simulation
    for i in range(size):
        ratio = i / size
        r = int(bg_color_1[0] * (1 - ratio) + bg_color_2[0] * ratio)
        g = int(bg_color_1[1] * (1 - ratio) + bg_color_2[1] * ratio)
        b = int(bg_color_1[2] * (1 - ratio) + bg_color_2[2] * ratio)
        draw.line([(0, i), (size, i)], fill=(r, g, b, 255))
    
    # Draw outer hexagon (stroke)
    hex_size = size * 0.42
    outer_hex = create_hexagon_path(cx, cy, hex_size)
    draw.polygon(outer_hex, outline=cyan, width=max(2, size // 128))
    
    # Draw inner hexagon (stroke)
    inner_hex_size = size * 0.30
    inner_hex = create_hexagon_path(cx, cy, inner_hex_size)
    draw.polygon(inner_hex, outline=purple, width=max(2, size // 170))
    
    # Draw neural network nodes and lines
    node_radius = max(6, size // 85)
    nodes = []
    
    # 6 outer nodes
    for i in range(6):
        angle = math.radians(60 * i - 90)
        x = cx + hex_size * 0.88 * math.cos(angle)
        y = cy + hex_size * 0.88 * math.sin(angle)
        nodes.append((x, y))
        # Draw node
        draw.ellipse([x-node_radius, y-node_radius, x+node_radius, y+node_radius], 
                     fill=cyan, outline=cyan)
    
    # Center node (larger)
    center_radius = node_radius * 1.5
    draw.ellipse([cx-center_radius, cy-center_radius, cx+center_radius, cy+center_radius],
                 fill=cyan, outline=cyan)
    
    # Draw connection lines
    line_width = max(1, size // 340)
    for node in nodes:
        draw.line([(cx, cy), node], fill=cyan, width=line_width)
    
    # Draw "MJ NEXUS" text
    text_size = max(24, size // 7)
    small_size = max(12, size // 22)
    try:
        # Try to use a bold sans-serif font
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", text_size)
        font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", small_size)
    except Exception as e:
        print(f"Font error: {e}, using default")
        # Use a reasonable default font size
        font = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # Main text
    main_text = "MJ NEXUS"
    bbox = draw.textbbox((0, 0), main_text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    text_x = cx - text_width // 2
    text_y = cy - text_height // 2 - size // 25
    
    # Draw text with shadow for better visibility
    shadow_offset = max(2, size // 256)
    draw.text((text_x + shadow_offset, text_y + shadow_offset), main_text, 
               fill=(0, 150, 200, 180), font=font)
    draw.text((text_x, text_y), main_text, fill=white, font=font)
    
    # Bottom line
    line_y = cy + size // 8
    line_start = size // 5
    line_end = size - line_start
    draw.line([(line_start, line_y), (line_end, line_y)], fill=cyan, width=max(2, size // 256))
    
    # "AI ASSISTANT" text
    sub_text = "AI ASSISTANT"
    bbox_small = draw.textbbox((0, 0), sub_text, font=font_small)
    sub_width = bbox_small[2] - bbox_small[0]
    sub_x = cx - sub_width // 2
    sub_y = line_y + size // 25
    draw.text((sub_x, sub_y), sub_text, fill=cyan, font=font_small)
    
    # Round the corners
    mask = Image.new('L', (size, size), 255)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], 
                                 radius=corner_radius, fill=0)
    img.putalpha(mask)
    
    return img

# Generate icons
print("Generating MJ NEXUS icons...")

# Generate in memory first to check
test = draw_icon(512)
test.save('/Users/jianma/Desktop/LLM STUDIO/generated-images/mj_icon_test.png')
print("Test icon saved")

# Generate all sizes
sizes = {
    'mj_nexus_icon_512.png': 512,
    'mj_nexus_icon_192.png': 192,
    'mj_nexus_icon_144.png': 144,
    'mj_nexus_icon_96.png': 96,
    'mj_nexus_icon_72.png': 72,
    'mj_nexus_icon_48.png': 48,
}

output_dir = '/Users/jianma/Desktop/LLM STUDIO/generated-images'

for filename, size in sizes.items():
    icon = draw_icon(size)
    icon.save(f'{output_dir}/{filename}')
    print(f"  Created {filename}")

# Generate SVG alternative - a simpler design
svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1a237e"/>
      <stop offset="100%" style="stop-color:#0d47a1"/>
    </linearGradient>
    <linearGradient id="line" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#00e5ff"/>
      <stop offset="100%" style="stop-color:#7c4dff"/>
    </linearGradient>
  </defs>
  
  <!-- Background -->
  <rect width="512" height="512" rx="100" fill="url(#bg)"/>
  
  <!-- Hexagon outline -->
  <polygon points="256,50 450,150 450,362 256,462 62,362 62,150" 
           fill="none" stroke="url(#line)" stroke-width="8"/>
  
  <!-- Inner hexagon -->
  <polygon points="256,120 390,190 390,322 256,392 122,322 122,190" 
           fill="none" stroke="#7c4dff" stroke-width="4"/>
  
  <!-- Text -->
  <text x="256" y="280" font-family="Arial, sans-serif" font-size="64" 
        font-weight="bold" fill="white" text-anchor="middle">MJ NEXUS</text>
  <line x1="140" y1="310" x2="372" y2="310" stroke="#00e5ff" stroke-width="3"/>
  <text x="256" y="350" font-family="Arial, sans-serif" font-size="24" 
        fill="#00e5ff" text-anchor="middle" letter-spacing="4">AI ASSISTANT</text>
</svg>
'''

with open(f'{output_dir}/mj_nexus_icon_new.svg', 'w') as f:
    f.write(svg_content)

print("SVG icon created")
print("All icons generated successfully!")

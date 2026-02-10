#!/bin/bash

# Create app icon from emoji/text
# This creates a simple icon - you can replace with a proper icon later

ICONSET="AppIcon.iconset"
mkdir -p "$ICONSET"

# Create icon using Python (available on macOS)
python3 << 'EOF'
from PIL import Image, ImageDraw, ImageFont
import os

sizes = [16, 32, 64, 128, 256, 512, 1024]

for size in sizes:
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw rounded rectangle background
    margin = size // 10
    radius = size // 5
    
    # Blue gradient-like background
    for i in range(size):
        ratio = i / size
        r = int(59 + (37 - 59) * ratio)
        g = int(130 + (99 - 130) * ratio)
        b = int(246 + (235 - 246) * ratio)
        draw.rectangle([margin, margin + i, size - margin, margin + i + 1], fill=(r, g, b, 255))
    
    # Draw rocket emoji as text
    try:
        font_size = int(size * 0.5)
        font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", font_size)
        text = "🚀"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        x = (size - text_width) // 2
        y = (size - text_height) // 2 - size // 10
        draw.text((x, y), text, font=font, embedded_color=True)
    except:
        # Fallback: draw simple rocket shape
        center = size // 2
        draw.polygon([
            (center, margin + size//6),
            (center - size//6, size - margin - size//6),
            (center + size//6, size - margin - size//6)
        ], fill=(255, 255, 255, 255))
    
    # Save different sizes
    img.save(f"AppIcon.iconset/icon_{size}x{size}.png")
    if size <= 512:
        img_2x = img.resize((size * 2, size * 2), Image.LANCZOS)
        img_2x.save(f"AppIcon.iconset/icon_{size}x{size}@2x.png")

print("Icon images created!")
EOF

# If PIL is not available, create a simple icon with sips
if [ ! -f "$ICONSET/icon_512x512.png" ]; then
    echo "PIL not available, creating simple icon..."
    
    # Create a simple blue square icon using built-in tools
    for size in 16 32 64 128 256 512 1024; do
        # Create colored PNG using ImageMagick if available, otherwise use a placeholder
        if command -v convert &> /dev/null; then
            convert -size ${size}x${size} xc:'#3b82f6' \
                -fill white -gravity center -pointsize $((size/3)) \
                -annotate +0+0 "LH" \
                "$ICONSET/icon_${size}x${size}.png"
        else
            # Create minimal PNG header for blue square (fallback)
            printf '\x89PNG\r\n\x1a\n' > "$ICONSET/icon_${size}x${size}.png"
        fi
    done
    
    # Create @2x versions
    for size in 16 32 64 128 256 512; do
        cp "$ICONSET/icon_$((size*2))x$((size*2)).png" "$ICONSET/icon_${size}x${size}@2x.png" 2>/dev/null || true
    done
fi

# Convert to icns
iconutil -c icns "$ICONSET" -o LauncherHub.icns 2>/dev/null

if [ -f "LauncherHub.icns" ]; then
    echo "✅ LauncherHub.icns created!"
else
    echo "⚠️  Could not create .icns file. You may need to create the icon manually."
    echo "   Or install Pillow: pip3 install Pillow"
fi

# Cleanup
rm -rf "$ICONSET"

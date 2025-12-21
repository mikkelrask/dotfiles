#!/usr/bin/env python3
"""
Convert Xresources color schemes to Ghostty theme format
Usage: xres-to-ghostty <input-file> [-n <theme-name>]
"""

import sys
import re
import os
from pathlib import Path

def parse_xresources(content):
    """Parse Xresources format and extract colors"""
    colors = {}
    
    # Patterns to match
    patterns = {
        'foreground': r'\*\.foreground:\s*#([0-9a-fA-F]{6})',
        'background': r'\*\.background:\s*#([0-9a-fA-F]{6})',
        'cursor': r'\*\.cursorColor:\s*#([0-9a-fA-F]{6})',
    }
    
    # Extract special colors
    for key, pattern in patterns.items():
        match = re.search(pattern, content)
        if match:
            colors[key] = match.group(1).lower()
    
    # Extract palette colors (0-15)
    for i in range(16):
        pattern = rf'\*\.color{i}:\s*#([0-9a-fA-F]{{6}})'
        match = re.search(pattern, content)
        if match:
            colors[f'color{i}'] = match.group(1).lower()
    
    return colors

def show_color_preview(colors):
    """Display a visual preview of the color scheme"""
    print("\n" + "="*50)
    print("COLOR SCHEME PREVIEW")
    print("="*50 + "\n")
    
    # Show special colors
    if 'background' in colors:
        print(f"\033[48;2;{int(colors['background'][0:2], 16)};{int(colors['background'][2:4], 16)};{int(colors['background'][4:6], 16)}m  \033[0m  Background: #{colors['background']}")
    if 'foreground' in colors:
        print(f"\033[38;2;{int(colors['foreground'][0:2], 16)};{int(colors['foreground'][2:4], 16)};{int(colors['foreground'][4:6], 16)}m██\033[0m  Foreground: #{colors['foreground']}")
    if 'cursor' in colors:
        print(f"\033[38;2;{int(colors['cursor'][0:2], 16)};{int(colors['cursor'][2:4], 16)};{int(colors['cursor'][4:6], 16)}m██\033[0m  Cursor:     #{colors['cursor']}")
    
    print("\nPalette Colors:")
    print("-" * 50)
    
    # Color names for reference
    color_names = [
        "Black", "Red", "Green", "Yellow",
        "Blue", "Magenta", "Cyan", "White",
        "Bright Black", "Bright Red", "Bright Green", "Bright Yellow",
        "Bright Blue", "Bright Magenta", "Bright Cyan", "Bright White"
    ]
    
    # Show palette in pairs (normal + bright)
    for i in range(8):
        normal_key = f'color{i}'
        bright_key = f'color{i+8}'
        
        line = ""
        if normal_key in colors:
            hex_color = colors[normal_key]
            r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
            line += f"\033[38;2;{r};{g};{b}m████\033[0m  "
        
        if bright_key in colors:
            hex_color = colors[bright_key]
            r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
            line += f"\033[38;2;{r};{g};{b}m████\033[0m  "
        
        if normal_key in colors:
            line += f"{color_names[i]:15} #{colors[normal_key]}"
        if bright_key in colors:
            line += f"  /  #{colors[bright_key]}"
        
        print(line)
    
    print("\n" + "="*50 + "\n")

def generate_ghostty_theme(colors):
    """Generate Ghostty theme format from parsed colors"""
    lines = []
    
    # Add palette colors (0-15)
    for i in range(16):
        key = f'color{i}'
        if key in colors:
            lines.append(f'palette = {i}=#{colors[key]}')
    
    # Add special colors
    if 'background' in colors:
        lines.append(f'background = #{colors["background"]}')
    
    if 'foreground' in colors:
        lines.append(f'foreground = #{colors["foreground"]}')
    
    if 'cursor' in colors:
        lines.append(f'cursor-color = #{colors["cursor"]}')
        # Use background for cursor-text (common practice)
        if 'background' in colors:
            lines.append(f'cursor-text = #{colors["background"]}')
    
    # Add selection colors (using color0 and foreground as defaults)
    if 'color0' in colors:
        lines.append(f'selection-background = #{colors["color0"]}')
    if 'foreground' in colors:
        lines.append(f'selection-foreground = #{colors["foreground"]}')
    
    return '\n'.join(lines)

def get_theme_name(args):
    """Get theme name from args or prompt user"""
    # Check for -n flag
    if '-n' in args:
        idx = args.index('-n')
        if idx + 1 < len(args):
            return args[idx + 1]
    
    # Prompt user
    while True:
        name = input("Enter theme name: ").strip()
        if name:
            return name
        print("Theme name cannot be empty. Please try again.")

def main():
    if len(sys.argv) < 2 or sys.argv[1] in ['-h', '--help']:
        print(__doc__)
        print("\nExample:")
        print("  xres-to-ghostty exported-theme.txt")
        print("  xres-to-ghostty exported-theme.txt -n my-awesome-theme")
        sys.exit(0)
    
    input_file = sys.argv[1]
    
    # Check if input file exists
    if not os.path.isfile(input_file):
        print(f"Error: File '{input_file}' not found")
        sys.exit(1)
    
    # Read input file
    try:
        with open(input_file, 'r') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)
    
    # Parse colors
    colors = parse_xresources(content)
    
    if not colors:
        print("Error: No colors found in input file")
        sys.exit(1)
    
    # Show color preview
    show_color_preview(colors)
    
    # Generate Ghostty theme
    ghostty_theme = generate_ghostty_theme(colors)
    
    # Get theme name
    theme_name = get_theme_name(sys.argv)
    
    # Try to use /usr/share/ghostty/themes first
    output_dir = Path('/usr/share/ghostty/themes')
    
    # Create directory if it doesn't exist and check write permissions
    try:
        output_dir.mkdir(parents=True, exist_ok=True)
        # Test if we can actually write to it
        test_file = output_dir / '.write_test'
        test_file.touch()
        test_file.unlink()
    except (PermissionError, OSError):
        # Fall back to user config directory
        output_dir = Path.home() / '.config' / 'ghostty' / 'themes'
        output_dir.mkdir(parents=True, exist_ok=True)
        print(f"Note: Using {output_dir} (no write permission to /usr/share/ghostty/themes)")
    
    # Write theme file
    output_file = output_dir / theme_name
    try:
        with open(output_file, 'w') as f:
            f.write(ghostty_theme)
        print(f"\n✓ Theme '{theme_name}' created successfully!")
        print(f"  Location: {output_file}")
        print(f"\nTo use this theme in Ghostty, add to your config:")
        print(f"  theme = {theme_name}")
    except Exception as e:
        print(f"Error writing theme file: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()

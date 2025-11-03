#!/usr/bin/env python3
"""
LRC Metadata Fixer
Adds missing artist, title, and album metadata to .lrc files based on file paths.
Designed for Picard-organized music libraries with structure:
/pool/Music/{artist-name}/{album-name}/xx. {track-title}.{ext}
"""

import os
import re
import subprocess
import sys
import shutil
from pathlib import Path
from typing import List, Tuple, Optional

# Configuration - easily change this to match your setup
MUSIC_DIRECTORY = "/pool/Music"

# Tool detection and command mapping
def detect_tools():
    """Detect available tools and set up command preferences."""
    tools = {
        'find_tool': 'find',
        'grep_tool': 'grep'
    }
    
    if shutil.which('fd'):
        tools['find_tool'] = 'fd'
        print("Using fd for file finding (faster)")
    else:
        print("Using find for file finding (fd not available)")
        
    if shutil.which('rg'):
        tools['grep_tool'] = 'rg'
        print("Using ripgrep for pattern matching (faster)")
    else:
        print("Using grep for pattern matching (rg not available)")
    
    return tools

def run_command(cmd: List[str]) -> str:
    """Run a shell command and return its output."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        # For grep/rg -q commands, exit code 1 just means "not found"
        if cmd[0] in ['grep', 'rg'] and '-q' in cmd and e.returncode == 1:
            return ""
        print(f"Error running command {' '.join(cmd)}: {e}")
        return ""

def find_lrc_files(music_dir: str, find_tool: str) -> List[str]:
    """Find all .lrc files in the music directory using fd or find."""
    if find_tool == 'fd':
        cmd = ["fd", "-e", "lrc", ".", music_dir]
    else:
        cmd = ["find", music_dir, "-name", "*.lrc", "-type", "f"]
    
    output = run_command(cmd)
    return [line.strip() for line in output.splitlines() if line.strip()]

def check_existing_tags(lrc_file: str, grep_tool: str) -> Tuple[bool, bool, bool]:
    """Check if the LRC file already has ar:, ti:, and al: tags using rg or grep."""
    if grep_tool == 'rg':
        has_ar = subprocess.run(["rg", "-q", r"^\[ar:", lrc_file], capture_output=True).returncode == 0
        has_ti = subprocess.run(["rg", "-q", r"^\[ti:", lrc_file], capture_output=True).returncode == 0
        has_al = subprocess.run(["rg", "-q", r"^\[al:", lrc_file], capture_output=True).returncode == 0
    else:
        has_ar = subprocess.run(["grep", "-q", r"^\[ar:", lrc_file], capture_output=True).returncode == 0
        has_ti = subprocess.run(["grep", "-q", r"^\[ti:", lrc_file], capture_output=True).returncode == 0
        has_al = subprocess.run(["grep", "-q", r"^\[al:", lrc_file], capture_output=True).returncode == 0
        
    return has_ar, has_ti, has_al

def extract_metadata_from_path(lrc_path: str, music_root: str) -> Optional[Tuple[str, str, str]]:
    """
    Extract artist, album, and title from the file path.
    Expected structure: /pool/Music/{artist-name}/{album-name}/xx. {track-title}.lrc
    """
    try:
        # Convert to Path object for easier manipulation
        path = Path(lrc_path)
        music_root_path = Path(music_root)
        
        # Get relative path from music root
        rel_path = path.relative_to(music_root_path)
        
        # Extract components: artist/album/track_file
        parts = rel_path.parts
        if len(parts) < 3:
            print(f"Warning: Path structure unexpected for {lrc_path}")
            return None
            
        artist = parts[0]
        album = parts[1] 
        track_file = parts[2]
        
        # Extract title from filename, removing track number and extension
        # Pattern: "xx. {track-title}.lrc" -> "{track-title}"
        title_match = re.match(r'^\d+\.\s*(.+)\.lrc$', track_file)
        if title_match:
            title = title_match.group(1)
        else:
            # Fallback: just remove .lrc extension
            title = track_file.replace('.lrc', '')
            
        return artist, album, title
        
    except Exception as e:
        print(f"Error extracting metadata from path {lrc_path}: {e}")
        return None

def add_metadata_to_lrc(lrc_file: str, artist: str, album: str, title: str, 
                       has_ar: bool, has_ti: bool, has_al: bool, dry_run: bool = False):
    """Add missing metadata tags to the beginning of the LRC file."""
    
    # Build the metadata lines to prepend
    metadata_lines = []
    if not has_ar:
        metadata_lines.append(f"[ar:{artist}]")
    if not has_ti:
        metadata_lines.append(f"[ti:{title}]") 
    if not has_al:
        metadata_lines.append(f"[al:{album}]")
        
    if not metadata_lines:
        return  # Nothing to add
        
    if dry_run:
        print(f"Would add to {lrc_file}:")
        for line in metadata_lines:
            print(f"  {line}")
        return
        
    try:
        # Read existing content
        with open(lrc_file, 'r', encoding='utf-8') as f:
            existing_content = f.read()
            
        # Write metadata + existing content
        with open(lrc_file, 'w', encoding='utf-8') as f:
            for line in metadata_lines:
                f.write(line + '\n')
            f.write(existing_content)
            
        print(f"Updated {lrc_file} with: {', '.join(metadata_lines)}")
        
    except Exception as e:
        print(f"Error updating {lrc_file}: {e}")

def main():
    """Main function to process all LRC files."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Add missing metadata to LRC files")
    parser.add_argument("music_dir", nargs='?', default=MUSIC_DIRECTORY, 
                       help=f"Root music directory (default: {MUSIC_DIRECTORY})")
    parser.add_argument("--dry-run", action="store_true", 
                       help="Show what would be done without making changes")
    parser.add_argument("--verbose", "-v", action="store_true",
                       help="Verbose output")
    
    args = parser.parse_args()
    
    # Detect available tools
    tools = detect_tools()
    print()
    
    music_dir = args.music_dir
    if not os.path.exists(music_dir):
        print(f"Error: Music directory {music_dir} does not exist")
        sys.exit(1)
        
    print(f"Scanning for LRC files in {music_dir}...")
    lrc_files = find_lrc_files(music_dir, tools['find_tool'])
    print(f"Found {len(lrc_files)} LRC files")
    
    if args.dry_run:
        print("DRY RUN MODE - No files will be modified")
        print()
    
    updated_count = 0
    skipped_count = 0
    
    for lrc_file in lrc_files:
        if args.verbose:
            print(f"Processing: {lrc_file}")
            
        # Check existing tags
        has_ar, has_ti, has_al = check_existing_tags(lrc_file, tools['grep_tool'])
        
        if has_ar and has_ti and has_al:
            if args.verbose:
                print(f"  Already has all tags, skipping")
            skipped_count += 1
            continue
            
        # Extract metadata from path
        metadata = extract_metadata_from_path(lrc_file, music_dir)
        if not metadata:
            print(f"  Could not extract metadata from path, skipping")
            skipped_count += 1
            continue
            
        artist, album, title = metadata
        
        if args.verbose:
            missing_tags = []
            if not has_ar: missing_tags.append("artist")
            if not has_ti: missing_tags.append("title") 
            if not has_al: missing_tags.append("album")
            print(f"  Missing: {', '.join(missing_tags)}")
            print(f"  Artist: {artist}, Album: {album}, Title: {title}")
            
        # Add missing metadata
        add_metadata_to_lrc(lrc_file, artist, album, title, 
                           has_ar, has_ti, has_al, args.dry_run)
        updated_count += 1
        
    print(f"\nSummary:")
    print(f"  Updated: {updated_count} files")
    print(f"  Skipped: {skipped_count} files") 
    
    if args.dry_run:
        print(f"\nRe-run without --dry-run to apply changes")

if __name__ == "__main__":
    main()

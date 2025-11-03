#!/usr/bin/env python3
"""
LRC Metadata Deduplicator
Removes duplicate ar:, ti:, and al: tags from LRC files, keeping only the first occurrence.
"""

import re
import sys
from pathlib import Path

def deduplicate_lrc_metadata(lrc_file: str, dry_run: bool = False):
    """Remove duplicate metadata tags from LRC file."""
    try:
        with open(lrc_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        seen_tags = set()
        cleaned_lines = []
        removed_count = 0
        
        for line in lines:
            # Check if line is a metadata tag
            match = re.match(r'^\[(ar|ti|al):', line)
            if match:
                tag_type = match.group(1)
                if tag_type in seen_tags:
                    # Duplicate! Skip it
                    removed_count += 1
                    continue
                else:
                    seen_tags.add(tag_type)
            
            cleaned_lines.append(line)
        
        if removed_count > 0:
            if dry_run:
                print(f"{lrc_file}: Would remove {removed_count} duplicate tag(s)")
            else:
                with open(lrc_file, 'w', encoding='utf-8') as f:
                    f.writelines(cleaned_lines)
                print(f"{lrc_file}: Removed {removed_count} duplicate tag(s)")
            return removed_count
        
        return 0
        
    except Exception as e:
        print(f"Error processing {lrc_file}: {e}")
        return 0

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Remove duplicate metadata from LRC files")
    parser.add_argument("path", help="LRC file or directory to process")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be done")
    
    args = parser.parse_args()
    
    path = Path(args.path)
    
    if path.is_file():
        lrc_files = [path]
    elif path.is_dir():
        lrc_files = list(path.rglob("*.lrc"))
    else:
        print(f"Error: {path} not found")
        sys.exit(1)
    
    print(f"Processing {len(lrc_files)} file(s)...")
    if args.dry_run:
        print("DRY RUN MODE\n")
    
    total_removed = sum(deduplicate_lrc_metadata(str(f), args.dry_run) for f in lrc_files)
    
    print(f"\nTotal duplicate tags removed: {total_removed}")

if __name__ == "__main__":
    main()

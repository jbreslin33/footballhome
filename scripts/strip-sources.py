#!/usr/bin/env python3
"""
Strip every <div class="sources">...</div> block from
frontend/exhibit/lighthouse-history.html.

v2 — uses bracket counting so the matching </div> is found correctly
even when the block contains nested <div class="src"> siblings.
"""
import re
import sys
from pathlib import Path

SRC = Path("frontend/exhibit/lighthouse-history.html")
START = '<div class="sources">'

def find_matching_close(text: str, open_idx: int) -> int:
    """Return the index just past the </div> that closes the <div>
    starting at open_idx. -1 if not found."""
    depth = 0
    i = open_idx
    pattern = re.compile(r'<div\b|</div\s*>')
    while True:
        m = pattern.search(text, i)
        if not m:
            return -1
        tag = m.group(0)
        if tag.startswith('</'):
            depth -= 1
            if depth == 0:
                return m.end()
            i = m.end()
        else:
            depth += 1
            i = m.end()

def main() -> int:
    if not SRC.exists():
        print(f"ERROR: {SRC} not found", file=sys.stderr)
        return 1

    raw = SRC.read_text(encoding="utf-8")
    out_parts = []
    cursor = 0
    count = 0
    while True:
        start_idx = raw.find(START, cursor)
        if start_idx == -1:
            out_parts.append(raw[cursor:])
            break
        end_idx = find_matching_close(raw, start_idx)
        if end_idx == -1:
            print(f"WARN: unmatched <div class=\"sources\"> at offset {start_idx}", file=sys.stderr)
            out_parts.append(raw[cursor:])
            break
        # Expand left over indentation on the same line
        line_start = raw.rfind("\n", 0, start_idx) + 1
        # Expand right over trailing whitespace + one newline
        scan = end_idx
        while scan < len(raw) and raw[scan] in " \t":
            scan += 1
        if scan < len(raw) and raw[scan] == "\n":
            scan += 1
        out_parts.append(raw[cursor:line_start])
        cursor = scan
        count += 1

    new_raw = "".join(out_parts)
    # Collapse runs of 3+ blank lines down to 1 blank line
    new_raw = re.sub(r'\n[ \t]*\n[ \t]*\n+', '\n\n', new_raw)
    SRC.write_text(new_raw, encoding="utf-8")
    print(f"Stripped {count} sources blocks.")
    print(f"  {SRC} size: {len(raw)} -> {len(new_raw)} bytes "
          f"(-{len(raw) - len(new_raw)} bytes)")
    return 0

if __name__ == "__main__":
    sys.exit(main())

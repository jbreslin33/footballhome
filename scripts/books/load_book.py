#!/usr/bin/env python3
"""📚 Load a captured coaching book into the DB (mig 1928).

Pages come from the owner's phone (Coach Viewer, adb screencap) into
~/football-data/books/<slug>/raw/pNNN.png — never git.  This crops each
screenshot to the page, saves it as JPEG and upserts coaching_books +
coaching_book_pages.  Book text never lands in git; only this loader does.

  python3 -I scripts/books/load_book.py <slug> --title T --author A \
      [--subtitle S] [--team X] [--season 2011-12] [--method "…"]
"""
import argparse, base64, glob, io, os, subprocess, sys
from PIL import Image

CROP = (0, 250, 1040, 1612)   # S25 Ultra 1080x2340, page snapped to top by the ⌄ button

def q(s):
    return "NULL" if s is None else "'" + s.replace("'", "''") + "'"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("slug"); ap.add_argument("--title", required=True); ap.add_argument("--author", required=True)
    ap.add_argument("--subtitle"); ap.add_argument("--team"); ap.add_argument("--season"); ap.add_argument("--method")
    a = ap.parse_args()
    raw = os.path.expanduser(f"~/football-data/books/{a.slug}/raw")
    files = sorted(glob.glob(f"{raw}/p[0-9][0-9][0-9].png"))
    if not files: sys.exit(f"no pages in {raw}")
    out = [ "BEGIN;",
        f"INSERT INTO coaching_books (slug, title, subtitle, author, team, season, page_count, method_note) VALUES "
        f"({q(a.slug)}, {q(a.title)}, {q(a.subtitle)}, {q(a.author)}, {q(a.team)}, {q(a.season)}, {len(files)}, {q(a.method)}) "
        f"ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, subtitle = EXCLUDED.subtitle, author = EXCLUDED.author, "
        f"team = EXCLUDED.team, season = EXCLUDED.season, page_count = EXCLUDED.page_count, "
        f"method_note = COALESCE(EXCLUDED.method_note, coaching_books.method_note);",
        # Shared taxonomy (mig 1932): every book is a game_sources row, code 'book-<slug>'.
        f"INSERT INTO game_sources (code, kind, title, verified) "
        f"SELECT 'book-' || b.slug, 'book', concat_ws(', ', NULLIF(b.author, ''), b.title) || ' (' || b.publisher || ')', true "
        f"FROM coaching_books b WHERE b.slug = {q(a.slug)} "
        f"ON CONFLICT (code) DO UPDATE SET title = EXCLUDED.title;",
        f"UPDATE coaching_books b SET source_id = s.id FROM game_sources s "
        f"WHERE b.slug = {q(a.slug)} AND s.code = 'book-' || b.slug;",
        f"DELETE FROM coaching_book_pages WHERE book_id = (SELECT id FROM coaching_books WHERE slug = {q(a.slug)});" ]
    for f in files:
        n = int(os.path.basename(f)[1:4])
        buf = io.BytesIO()
        Image.open(f).convert("RGB").crop(CROP).save(buf, "JPEG", quality=80)
        b64 = base64.b64encode(buf.getvalue()).decode()
        out.append(f"INSERT INTO coaching_book_pages (book_id, page_no, bytes) SELECT id, {n}, decode('{b64}', 'base64') "
                   f"FROM coaching_books WHERE slug = {q(a.slug)};")
    out.append("COMMIT;")
    sql = "\n".join(out).encode()
    r = subprocess.run(["sudo", "podman", "exec", "-i", "footballhome_db", "psql", "-q", "-v", "ON_ERROR_STOP=1",
                        "-U", "footballhome_user", "-d", "footballhome"], input=sql)
    if r.returncode: sys.exit(r.returncode)
    print(f"loaded {len(files)} pages for {a.slug}")

if __name__ == "__main__":
    main()

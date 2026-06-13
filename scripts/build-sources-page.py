#!/usr/bin/env python3
"""
Generate frontend/exhibit/sources.html from sources.json.
A clean, mobile-friendly page hosted at
https://footballhome.org/exhibit/sources.html — visitors land here by
scanning the single global QR on Bradford (Poster 1).
"""
import json
import sys
from pathlib import Path

SRC_JSON = Path("frontend/exhibit/sources.json")
OUT_HTML = Path("frontend/exhibit/sources.html")

HEAD = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sources &amp; Further Reading — Lighthouse 1893: A Century of American Soccer</title>
  <meta name="description" content="Sources and further reading for the Lighthouse 1893 history exhibit on display at The Lighthouse, Kensington, Philadelphia.">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Montserrat:wght@600;700;800&family=Open+Sans:wght@400;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg:       #FAFAFA;
      --navy:     #0F2C59;
      --gold:     #C5A880;
      --charcoal: #2B2B2B;
      --line:     #e6e1d6;
      --muted:    #4a5a7b;
    }
    * { box-sizing: border-box; }
    html, body { margin: 0; padding: 0; background: var(--bg); color: var(--charcoal); font-family: 'Open Sans', sans-serif; line-height: 1.55; }
    .page { max-width: 880px; margin: 0 auto; padding: 32px 24px 80px; }
    header.hero {
      background: var(--navy); color: #fff;
      margin: -32px -24px 36px; padding: 48px 28px 36px;
      border-bottom: 6px solid var(--gold);
    }
    header.hero .kicker {
      font-family: 'Montserrat', sans-serif; text-transform: uppercase;
      letter-spacing: 3px; font-size: 0.8rem; color: var(--gold);
      margin: 0 0 8px; font-weight: 700;
    }
    header.hero h1 {
      font-family: 'Bebas Neue', sans-serif; margin: 0;
      font-size: clamp(1.8rem, 5vw, 2.8rem); letter-spacing: 1.5px; line-height: 1.05;
    }
    header.hero p {
      font-family: 'Montserrat', sans-serif; font-weight: 600;
      margin: 14px 0 0; max-width: 720px; color: #d8e1f0;
    }
    nav.toc {
      background: #fff; border: 1px solid var(--line); border-radius: 8px;
      padding: 18px 22px; margin: 0 0 36px;
    }
    nav.toc h2 {
      font-family: 'Montserrat', sans-serif; font-size: 0.78rem;
      letter-spacing: 2.5px; text-transform: uppercase; color: var(--navy);
      margin: 0 0 12px;
    }
    nav.toc ol {
      list-style: none; padding: 0; margin: 0;
      display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 4px 18px;
    }
    nav.toc li { font-size: 0.92rem; }
    nav.toc a {
      color: var(--navy); text-decoration: none;
      display: block; padding: 5px 0; border-bottom: 1px solid transparent;
    }
    nav.toc a:hover { border-bottom-color: var(--gold); }
    nav.toc .num {
      display: inline-block; min-width: 28px; color: var(--gold); font-weight: 700;
      font-family: 'Montserrat', sans-serif;
    }
    section.poster-block {
      margin: 0 0 36px; padding: 24px 26px; background: #fff;
      border: 1px solid var(--line); border-radius: 8px;
      scroll-margin-top: 24px;
    }
    section.poster-block .kicker {
      font-family: 'Montserrat', sans-serif; text-transform: uppercase;
      letter-spacing: 2.5px; font-size: 0.72rem; color: var(--gold);
      margin: 0 0 4px; font-weight: 700;
    }
    section.poster-block h2 {
      font-family: 'Bebas Neue', sans-serif; margin: 0 0 18px;
      font-size: 1.6rem; letter-spacing: 1px; color: var(--navy); line-height: 1.1;
    }
    section.poster-block ol.src-list {
      list-style: none; padding: 0; margin: 0;
    }
    section.poster-block ol.src-list li {
      padding: 12px 0; border-top: 1px solid var(--line);
      font-size: 0.94rem;
    }
    section.poster-block ol.src-list li:first-child { border-top: 0; }
    section.poster-block ol.src-list a { color: var(--navy); text-decoration: underline; text-decoration-color: var(--gold); text-underline-offset: 3px; }
    section.poster-block .none {
      color: var(--muted); font-style: italic; font-size: 0.92rem;
    }
    .back-top {
      display: inline-block; margin-top: 10px;
      font-family: 'Montserrat', sans-serif; font-size: 0.72rem;
      letter-spacing: 1.5px; text-transform: uppercase;
      color: var(--muted); text-decoration: none;
    }
    .back-top:hover { color: var(--navy); }
    footer.page-footer {
      margin-top: 48px; padding-top: 24px; border-top: 1px solid var(--line);
      font-size: 0.82rem; color: var(--muted); text-align: center;
    }
    footer.page-footer a { color: var(--navy); }
    @media (max-width: 600px) {
      .page { padding: 16px 14px 60px; }
      header.hero { margin: -16px -14px 24px; padding: 32px 20px 24px; }
      section.poster-block { padding: 18px 18px; }
    }
  </style>
</head>
<body>
<div class="page" id="top">
  <header class="hero">
    <p class="kicker">Lighthouse 1893 \u00b7 Exhibition Companion</p>
    <h1>Sources &amp; Further Reading</h1>
    <p>The full archive behind the on-site exhibit at The Lighthouse &mdash; newspaper clippings, archival records, oral histories, and scholarly works, organized by poster.</p>
  </header>
"""

FOOTER = """
  <footer class="page-footer">
    <p>Compiled for the <strong>Lighthouse Boys Club Fundraiser</strong>, June 19, 2026, at The Lighthouse, 152 W. Lehigh Ave., Philadelphia.</p>
    <p>Curated by <a href="https://footballhome.org">footballhome.org</a> in partnership with The Lighthouse. Print partner: <strong>Fireball Printing, Philadelphia</strong>.</p>
  </footer>
</div>
</body>
</html>
"""

def main() -> int:
    if not SRC_JSON.exists():
        print(f"ERROR: {SRC_JSON} not found. Run extract-sources.py first.", file=sys.stderr)
        return 1

    data = json.loads(SRC_JSON.read_text(encoding="utf-8"))

    parts = [HEAD]

    # TOC
    parts.append('  <nav class="toc" aria-label="Posters in this exhibit">\n')
    parts.append('    <h2>Jump to a poster</h2>\n    <ol>\n')
    for p in data:
        n = p["num"].lstrip("0") or "0"
        parts.append(f'      <li><a href="#poster-{int(n)}"><span class="num">{p["num"]}</span> {p["title"]}</a></li>\n')
    parts.append('    </ol>\n  </nav>\n')

    # Per-poster sections
    for p in data:
        n = int(p["num"].lstrip("0") or "0")
        parts.append(f'  <section class="poster-block" id="poster-{n}">\n')
        parts.append(f'    <p class="kicker">{p["kicker"]}</p>\n')
        parts.append(f'    <h2>{p["title"]}</h2>\n')
        if p["sources"]:
            parts.append('    <ol class="src-list">\n')
            for s in p["sources"]:
                # The stored html is the inner of <p class="src-text">...</p>;
                # render as-is so existing markup (anchors, em, etc.) survives.
                parts.append(f'      <li>{s["html"]}</li>\n')
            parts.append('    </ol>\n')
        else:
            parts.append('    <p class="none">No external citations on this poster.</p>\n')
        parts.append('    <a class="back-top" href="#top">\u2191 Back to top</a>\n')
        parts.append('  </section>\n')

    parts.append(FOOTER)
    OUT_HTML.write_text("".join(parts), encoding="utf-8")
    print(f"Wrote {OUT_HTML}  ({len(data)} posters, {sum(len(p['sources']) for p in data)} sources)")
    return 0

if __name__ == "__main__":
    sys.exit(main())

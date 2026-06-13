#!/usr/bin/env python3
"""
Extract per-poster sources from frontend/exhibit/lighthouse-history.html
into a JSON file that the sources-page generator and the stripper both
consume.  Pure stdlib (no BeautifulSoup4 dependency).

Output schema:
[
  {
    "num":   "01",
    "kicker": "Poster 1 \u00b7 The Founder",
    "title":  "Esther W. Kelly Bradford",
    "sources": [
      {
        "html":     "<full inner HTML of the <p class=src-text>...>",
        "text":     "stripped text version",
        "url":      "https://...",
        "qr_url":   "https://api.qrserver.com/..."
      },
      ...
    ]
  },
  ...
]
"""
import json
import re
import sys
from pathlib import Path

SRC = Path("frontend/exhibit/lighthouse-history.html")
OUT = Path("frontend/exhibit/sources.json")

ARTICLE_RE = re.compile(
    r'<article class="poster"[^>]*>(.*?)</article>',
    re.DOTALL,
)
NUM_RE       = re.compile(r'<div class="poster-num">([^<]+)</div>')
KICKER_RE    = re.compile(r'<p class="kicker">([^<]+)</p>')
TITLE_RE     = re.compile(r'<h2[^>]*>(.*?)</h2>', re.DOTALL)
SOURCES_RE   = re.compile(r'<div class="sources">(.*?)</div>\s*</div>\s*</article>', re.DOTALL)
# Looser sources extractor: any <div class="sources">...</div> at body end
SOURCES_LOOSE_RE = re.compile(
    r'<div class="sources">(.*?)</div>\s*(?=</div>|</article>)',
    re.DOTALL,
)
SRC_RE       = re.compile(r'<div class="src">(.*?)</div>', re.DOTALL)
TEXT_RE      = re.compile(r'<p class="src-text">(.*?)</p>', re.DOTALL)
QR_IMG_RE    = re.compile(r'<img class="qr"[^>]*src="([^"]+)"')
HREF_RE      = re.compile(r'href="([^"]+)"')
TAG_RE       = re.compile(r'<[^>]+>')

def strip_tags(html: str) -> str:
    return re.sub(r'\s+', ' ', TAG_RE.sub('', html)).strip()

def main() -> int:
    if not SRC.exists():
        print(f"ERROR: {SRC} not found", file=sys.stderr)
        return 1

    raw = SRC.read_text(encoding="utf-8")
    out = []

    for article_body in ARTICLE_RE.findall(raw):
        num_m    = NUM_RE.search(article_body)
        kicker_m = KICKER_RE.search(article_body)
        title_m  = TITLE_RE.search(article_body)
        if not (num_m and kicker_m and title_m):
            # Unexpected article shape — skip but warn.
            print(f"WARN: skipped article missing num/kicker/title", file=sys.stderr)
            continue

        # Find the LAST <div class="sources"> ... </div> inside the article.
        sources_blocks = SOURCES_LOOSE_RE.findall(article_body)
        srcs = []
        if sources_blocks:
            sources_html = sources_blocks[-1]
            for src_html in SRC_RE.findall(sources_html):
                text_m = TEXT_RE.search(src_html)
                if not text_m:
                    continue
                text_html = text_m.group(1).strip()
                href_m = HREF_RE.search(text_html)
                qr_m   = QR_IMG_RE.search(src_html)
                srcs.append({
                    "html":   text_html,
                    "text":   strip_tags(text_html),
                    "url":    href_m.group(1) if href_m else "",
                    "qr_url": qr_m.group(1)   if qr_m   else "",
                })

        out.append({
            "num":     num_m.group(1).strip(),
            "kicker":  kicker_m.group(1).strip(),
            "title":   strip_tags(title_m.group(1)),
            "sources": srcs,
        })

    OUT.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Extracted {len(out)} posters \u2192 {OUT}")
    print(f"  Total source citations: {sum(len(p['sources']) for p in out)}")
    for p in out:
        print(f"   {p['num']}  {p['title'][:60]:<60s}  {len(p['sources'])} src")
    return 0

if __name__ == "__main__":
    sys.exit(main())

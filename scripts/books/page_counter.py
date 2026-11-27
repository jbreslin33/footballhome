#!/usr/bin/env python3
"""📚 Read Coach Viewer's "74 / 225" page counter off a phone screenshot.

The reader draws its UI itself (no accessibility text), so the counter is
read from pixels: glyphs split on blank columns, matched to templates learnt
from a book whose page numbers are known (train()).  S25 Ultra, 1080x2340.
"""
import json, os, sys
from PIL import Image

BOX = (525, 2070, 805, 2160)
TEMPLATES = os.path.expanduser("~/football-data/books/counter-templates.json")
W, H = 16, 24

def glyphs(img):
    g = img.convert("L").crop(BOX)
    w, h = g.size
    px = g.load()
    dark = [[px[x, y] < 128 for x in range(w)] for y in range(h)]
    cols = [any(dark[y][x] for y in range(h)) for x in range(w)]
    runs, x = [], 0
    while x < w:
        if cols[x]:
            s = x
            while x < w and cols[x]: x += 1
            runs.append((s, x))
        x += 1
    out = []
    for s, e in runs:
        ys = [y for y in range(h) if any(dark[y][xx] for xx in range(s, e))]
        if not ys: continue
        top, bot = ys[0], ys[-1] + 1
        if e - s < 2 and bot - top < 6: continue          # specks
        sub = g.crop((s, top, e, bot)).resize((W, H))
        out.append([1 if v < 128 else 0 for v in sub.getdata()])
    return out

def train(raw_dir, total):
    acc = {}
    for n in range(1, total + 1):
        gs = glyphs(Image.open(f"{raw_dir}/p{n:03d}.png"))
        text = f"{n}/{total}"
        if len(gs) != len(text): continue
        for ch, gl in zip(text, gs):
            a = acc.setdefault(ch, [0] * (W * H) + [0])
            for i, v in enumerate(gl): a[i] += v
            a[-1] += 1
    tpl = {ch: [v / a[-1] for v in a[:-1]] for ch, a in acc.items()}
    json.dump(tpl, open(TEMPLATES, "w"))
    return sorted(tpl)

_tpl = None
def read(img):
    """→ (page, total) or None."""
    global _tpl
    if _tpl is None: _tpl = json.load(open(TEMPLATES))
    s = ""
    for gl in glyphs(img):
        best = min(_tpl, key=lambda ch: sum((a - b) ** 2 for a, b in zip(_tpl[ch], gl)))
        s += best
    if s.count("/") != 1: return None
    a, b = s.split("/")
    return (int(a), int(b)) if a.isdigit() and b.isdigit() else None

if __name__ == "__main__":
    if sys.argv[1] == "train": print(train(sys.argv[2], int(sys.argv[3])))
    else:
        for f in sys.argv[1:]: print(f, read(Image.open(f)))

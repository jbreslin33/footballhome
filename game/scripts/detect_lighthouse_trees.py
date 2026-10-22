#!/usr/bin/env python3
"""Build frontend/js/game/lighthouse-trees.js — tree positions around
Lighthouse Field, detected from satellite imagery.

OpenStreetMap maps only a handful of the trees here, but the tree lines
(the cemetery edge, Whitaker Ave, the Erie Ave verge, the copse round The
League Park) define how the place looks. So: fetch georeferenced Esri
World Imagery tiles (z19, ~0.23 m/px), classify tree canopy (dark,
saturated green — calibrated 2026-10-22: canopy V≈0.15, field grass
V≈0.28), and find each crown: local maxima of distance-to-canopy-edge,
so every tree is [x, z, crown radius] with x/z at the crown centre (over
the trunk). Positions are metres from the same origin as
lighthouse-site.js (x east, z south).

Tree positions derived from Esri World Imagery (© Esri, Maxar, Earthstar
Geographics, and the GIS User Community).
"""

import colorsys
import io
import json
import math
import urllib.request

from PIL import Image, ImageFilter

ORIGIN_LAT = 40.008229
ORIGIN_LON = -75.124772
Z = 19
S, W, N, E = 40.0062, -75.1278, 40.0102, -75.1205
OUT = 'frontend/js/game/lighthouse-trees.js'
KX = 111320 * math.cos(math.radians(ORIGIN_LAT))
KZ = 110540


def tile_xy(lat, lon):
    n = 2 ** Z
    x = (lon + 180) / 360 * n
    y = (1 - math.log(math.tan(math.radians(lat)) + 1 / math.cos(math.radians(lat))) / math.pi) / 2 * n
    return x, y


def main():
    x0, y0 = tile_xy(N, W)
    x1, y1 = tile_xy(S, E)
    tx0, ty0, tx1, ty1 = int(x0), int(y0), int(x1), int(y1)
    img = Image.new('RGB', ((tx1 - tx0 + 1) * 256, (ty1 - ty0 + 1) * 256))
    for tx in range(tx0, tx1 + 1):
        for ty in range(ty0, ty1 + 1):
            url = ('https://services.arcgisonline.com/ArcGIS/rest/services/'
                   f'World_Imagery/MapServer/tile/{Z}/{ty}/{tx}')
            req = urllib.request.Request(url, headers={'User-Agent': 'FootballHome-game/1.0'})
            for attempt in range(5):
                try:
                    data = urllib.request.urlopen(req, timeout=30).read()
                    break
                except Exception:
                    if attempt == 4:
                        raise
            img.paste(Image.open(io.BytesIO(data)), ((tx - tx0) * 256, (ty - ty0) * 256))

    # Half resolution (~0.46 m/px): canopy mask, then a chamfer distance
    # transform; each tree is a local maximum of distance-to-crown-edge, so
    # the point sits at the crown's centre (over the trunk for an upright
    # tree) and the distance is the crown radius. Neighbouring maxima closer
    # than ~0.8 of the larger radius are one crown (non-max suppression).
    q = img.resize((img.width // 2, img.height // 2)).filter(ImageFilter.GaussianBlur(1.2))
    px = q.load()
    w, h = q.size
    INF = 10 ** 6
    dist = [[0] * w for _ in range(h)]
    for y in range(h):
        row = dist[y]
        for x in range(w):
            r, g, b = px[x, y]
            hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            row[x] = INF if (v < 0.22 and s > 0.28 and 0.15 < hh < 0.5) else 0
    for y in range(h):                       # forward pass (3-4 chamfer)
        for x in range(w):
            if dist[y][x]:
                m = dist[y][x]
                if x: m = min(m, dist[y][x - 1] + 3)
                if y:
                    m = min(m, dist[y - 1][x] + 3)
                    if x: m = min(m, dist[y - 1][x - 1] + 4)
                    if x + 1 < w: m = min(m, dist[y - 1][x + 1] + 4)
                dist[y][x] = m
    for y in range(h - 1, -1, -1):           # backward pass
        for x in range(w - 1, -1, -1):
            if dist[y][x]:
                m = dist[y][x]
                if x + 1 < w: m = min(m, dist[y][x + 1] + 3)
                if y + 1 < h:
                    m = min(m, dist[y + 1][x] + 3)
                    if x + 1 < w: m = min(m, dist[y + 1][x + 1] + 4)
                    if x: m = min(m, dist[y + 1][x - 1] + 4)
                dist[y][x] = m

    mpp = 2 * 40075016.7 * math.cos(math.radians(ORIGIN_LAT)) / (256 * 2 ** Z)   # metres per half-res px

    def to_local(fx, fy):
        n = 2 ** Z
        lon = (fx / 256 + tx0) / n * 360 - 180
        lat = math.degrees(math.atan(math.sinh(math.pi * (1 - 2 * (fy / 256 + ty0) / n))))
        return round((lon - ORIGIN_LON) * KX, 1), round(-(lat - ORIGIN_LAT) * KZ, 1)

    cands = []
    for y in range(2, h - 2):
        for x in range(2, w - 2):
            d = dist[y][x]
            r_m = d / 3 * mpp
            if r_m < 1.5:
                continue
            if all(d >= dist[y + j][x + i] for j in (-2, -1, 0, 1, 2) for i in (-2, -1, 0, 1, 2)):
                cands.append((r_m, x, y))
    cands.sort(reverse=True)
    kept = []
    for r_m, x, y in cands:
        if all(math.hypot(x - kx, y - ky) * mpp > 0.8 * max(r_m, kr) for kr, kx, ky in kept):
            kept.append((r_m, x, y))
    trees = []
    for r_m, x, y in kept:
        lx, lz = to_local((x + 0.5) * 2, (y + 0.5) * 2)
        trees.append([lx, lz, round(min(r_m * 1.15, 12), 1)])
    trees.sort()

    with open(OUT, 'w') as fh:
        fh.write('// GENERATED by game/scripts/detect_lighthouse_trees.py — do not hand-edit.\n')
        fh.write('// Tree positions derived from Esri World Imagery (© Esri, Maxar, Earthstar\n')
        fh.write('// Geographics, GIS User Community). Metres from LIGHTHOUSE_SITE.origin; [x, z, crown radius].\n')
        fh.write('window.LIGHTHOUSE_TREES = ')
        json.dump(trees, fh, separators=(',', ':'))
        fh.write(';\n')
    print(OUT, len(trees), 'trees')


if __name__ == '__main__':
    main()

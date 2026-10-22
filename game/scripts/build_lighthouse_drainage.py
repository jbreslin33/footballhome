#!/usr/bin/env python3
"""Build frontend/js/game/lighthouse-drainage.js — where Lighthouse Field's
runoff actually goes, from USGS 3DEP lidar.

James (2026-10-22): "we get massive water run off". The bare-earth lidar
(USGS 3D Elevation Program, public domain) is resampled to 1 m cells,
pits are filled (priority-flood, so water can cross flats), each cell
drains to its steepest-descent neighbour (D8), and upstream area is
accumulated. Cells draining >= MIN_AREA m² are channels; each is written
as a segment to its downstream neighbour with its drainage area, in site
metres (x east, z south; origin = LIGHTHOUSE_SITE).

Result (2026-10-22): the main channel gathers on the field ~50 m north of
the main diamond's infield, runs south ~9 m inside today's yellow
sideline (James's 10-15 yd wet strip), crosses the vendor fence at the
stall row's east end (x ≈ -21), passes between the snack bar block and
the paved lot and reaches Erie Ave at x ≈ -22, then follows its gutter.

Also scores the planned pitch (layout realPitch) per square metre: flat
(< 0.5 % slope), pond (pit depth > 1 cm) and flow (runoff from >= 150 m²
upslope crossing it) — pitch.cells = [x, z, kind, pond cm, upslope m²,
slope %, yd from north goal, yd from east touchline].

Usage: build_lighthouse_drainage.py   (needs network; Pillow only)
"""
import heapq
import io
import re
import json
import math
import urllib.parse
import urllib.request

from PIL import Image

LAT0, LON0 = 40.008229, -75.124772
KX = 111320 * math.cos(math.radians(LAT0))
KZ = 110540
R = 6378137.0
X0, X1, Z0, Z1 = -140, 180, -160, 110
MIN_AREA = 300
OUT = 'frontend/js/game/lighthouse-drainage.js'
URL = 'https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/exportImage'
UA = {'User-Agent': 'FootballHome-game/1.0 (footballhome.org)'}


def loc2ll(x, z):
    return LAT0 - z / KZ, LON0 + x / KX


def ll2m(lat, lon):
    return math.radians(lon) * R, math.log(math.tan(math.pi / 4 + math.radians(lat) / 2)) * R


def main():
    la1, lo0 = loc2ll(X0 - 5, Z0 - 5)
    la0, lo1 = loc2ll(X1 + 5, Z1 + 5)
    mx0, my0 = ll2m(la0, lo0)
    mx1, my1 = ll2m(la1, lo1)
    res = 0.5 / math.cos(math.radians(LAT0))
    W, H = int((mx1 - mx0) / res), int((my1 - my0) / res)
    q = urllib.parse.urlencode({'bbox': f'{mx0},{my0},{mx1},{my1}', 'bboxSR': 3857, 'imageSR': 3857,
                                'size': f'{W},{H}', 'format': 'tiff', 'pixelType': 'F32',
                                'interpolation': 'RSP_BilinearInterpolation', 'f': 'json'})
    meta = json.load(urllib.request.urlopen(urllib.request.Request(URL + '?' + q, headers=UA), timeout=120))
    tif = urllib.request.urlopen(urllib.request.Request(meta['href'], headers=UA), timeout=120).read()
    dv = Image.open(io.BytesIO(tif)).load()
    e = meta['extent']
    w, h = meta['width'], meta['height']

    def elev(x, z):
        lat, lon = loc2ll(x, z)
        mx, my = ll2m(lat, lon)
        X = (mx - e['xmin']) / (e['xmax'] - e['xmin']) * w - 0.5
        Y = (e['ymax'] - my) / (e['ymax'] - e['ymin']) * h - 0.5
        i, j = int(X), int(Y)
        fx, fy = X - i, Y - j
        return (dv[i, j] * (1 - fx) * (1 - fy) + dv[i + 1, j] * fx * (1 - fy)
                + dv[i, j + 1] * (1 - fx) * fy + dv[i + 1, j + 1] * fx * fy)

    xs = list(range(X0, X1 + 1))
    zs = list(range(Z0, Z1 + 1))
    nx, nz = len(xs), len(zs)
    g = [[elev(x, z) for x in xs] for z in zs]

    filled = [[0.0] * nx for _ in range(nz)]
    seen = [[False] * nx for _ in range(nz)]
    pq, order, n = [], [], 0
    for j in range(nz):
        for i in range(nx):
            if i in (0, nx - 1) or j in (0, nz - 1):
                heapq.heappush(pq, (g[j][i], n, i, j))
                n += 1
                seen[j][i] = True
    while pq:
        hgt, _, i, j = heapq.heappop(pq)
        filled[j][i] = hgt
        order.append((i, j))
        for dj in (-1, 0, 1):
            for di in (-1, 0, 1):
                a, b = i + di, j + dj
                if 0 <= a < nx and 0 <= b < nz and not seen[b][a]:
                    seen[b][a] = True
                    n += 1
                    heapq.heappush(pq, (max(g[b][a], hgt + 1e-5), n, a, b))

    rcv = {}
    for j in range(1, nz - 1):
        for i in range(1, nx - 1):
            best, bd = None, 0.0
            for dj in (-1, 0, 1):
                for di in (-1, 0, 1):
                    if di or dj:
                        d = (filled[j][i] - filled[j + dj][i + di]) / math.hypot(di, dj)
                        if d > bd:
                            bd, best = d, (i + di, j + dj)
            if best:
                rcv[(i, j)] = best
    acc = {}
    for c in reversed(order):
        acc[c] = acc.get(c, 0) + 1
        r = rcv.get(c)
        if r:
            acc[r] = acc.get(r, 0) + acc[c]

    segs = []
    for (i, j), a in acc.items():
        r = rcv.get((i, j))
        if a >= MIN_AREA and r:
            segs += [xs[i], zs[j], xs[r[0]], zs[r[1]], a]
    # ── the planned pitch, square metre by square metre ─────────────────
    # flat  = slope < 0.5 % over 3 m (drains slowly, stays soft)
    # pond  = pit-filled depth > 1 cm (standing water; lidar ±~10 cm)
    # flow  = runoff from >= 150 m² upslope crosses this cell
    lay = open('frontend/js/game/lighthouse-layout.js').read()
    pm = re.search(r"realPitch: \{ x: ([-\d.]+), z: ([-\d.]+), rotDeg: ([-\d.]+), "
                   r"length: ([\d.]+), width: ([\d.]+)", lay)
    pcx, pcz, prot, pL, pW = (float(v) for v in pm.groups())
    th = math.radians(prot)
    ca, sa = math.cos(th), math.sin(th)
    cells = []
    stats = {'flat': 0, 'pond': 0, 'flow': 0, 'n': 0}
    u = -pL / 2 + 0.5
    while u < pL / 2:
        v = -pW / 2 + 0.5
        while v < pW / 2:
            x, z = pcx + u * ca - v * sa, pcz + u * sa + v * ca
            i, j = int(round(x - X0)), int(round(z - Z0))
            gx = (g[j][i + 3] - g[j][i - 3]) / 6
            gz = (g[j + 3][i] - g[j - 3][i]) / 6
            slope = math.hypot(gx, gz) * 100
            pond = filled[j][i] - g[j][i]
            a = acc.get((i, j), 0)
            kind = 'pond' if pond > 0.01 else 'flow' if a >= 150 else 'flat' if slope < 0.5 else None
            stats['n'] += 1
            if kind:
                stats[kind] += 1
                cells.append([round(x, 1), round(z, 1), kind, round(pond * 100, 1), a, round(slope, 2),
                              round((u + pL / 2) / 0.9144), round((v + pW / 2) / 0.9144)])
            v += 1
        u += 1
    print('pitch cells', stats)

    with open(OUT, 'w') as fh:
        fh.write('// GENERATED by game/scripts/build_lighthouse_drainage.py — do not hand-edit.\n')
        fh.write('// Runoff channels from USGS 3DEP lidar (public domain): D8 flow on 1 m cells.\n')
        fh.write('// segs = [x1, z1, x2, z2, drained area m², ...] in site metres; pitch = per-m² issues.\n')
        fh.write('window.LIGHTHOUSE_DRAINAGE = ')
        json.dump({'minArea': MIN_AREA, 'segs': segs, 'pitch': {'cells': cells, 'stats': stats}},
                  fh, separators=(',', ':'))
        fh.write(';\n')
    print(OUT, len(segs) // 5, 'channel segments; max drained area', max(acc.values()), 'm²')


if __name__ == '__main__':
    main()

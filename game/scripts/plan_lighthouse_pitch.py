#!/usr/bin/env python3
"""Plan the Lighthouse Field soccer pitch — constrained placement search.

James (2026-10-22): 115 x 74 yd; lines EXACTLY 10 ft (no closer) from the
metal vendor-protector fence (Lighthouse Village side) and the softball
3rd-base fence; >= 15 yd from the main diamond's infield dirt (floods);
off all infield dirt; clear of trees and the curved rodeo fence; and as
FAR from the cemetery tree line as possible (puddles, traffic-worn dirt).

Obstacles are site metres (x east, z south; origin = LIGHTHOUSE_SITE),
read off the City of Philadelphia 2025 orthoimagery (3-inch, PASDA
PhiladelphiaImagery2025, exported in EPSG:3857 so nothing is stretched).
Fences are traced as the polylines they really are:
  - vendor fence: pole bases every ~3.2 m; the west run sits parallel to
    the main diamond's 1st-base line (z ~ 32.3), then it bends ~6 deg
    south at x ~ -20 (west bases partly hidden in building shadow — read
    at the north-most point, so the pitch can only end up farther away);
  - softball 3rd-base fence: straight, backstop corner to its end post;
  - rodeo fence: a long curve bowing west, not a straight line.
The cemetery is the OSM outline (lighthouse-site.js). Trees are the
imagery-detected crowns (lighthouse-trees.js).

Search: both fences at exactly 10 ft are EQUALITY constraints; among the
placements meeting them (and every other rule), the one farthest from the
cemetery wins. 1 deg x 0.5 m sweep, then 0.05 deg x 5 cm refine (3 cm).
Output goes into frontend/js/game/lighthouse-layout.js (gamePitch /
realPitch / fences). Run from the repo root.
"""
import json
import math

YD = 0.9144
L, W = 115 * YD, 74 * YD
FT10 = 10 * 0.3048
YD15 = 15 * YD

MAIN_DIRT = [(-72.5, -8.8), (-62, -12.4), (-55.6, -12.6), (-45.3, -10.7), (-36.5, -6.2),
             (-30.8, 0.6), (-27.6, 10.0), (-26.8, 21.3), (-28, 27), (-30, 31), (-72.5, 31)]
SKIN = [(66, -3), (69.4, -10.5), (76.3, -14.2), (86.7, -14.6), (93.3, -9.7), (97, -4),
        (93, 4), (90, 10), (87, 16), (78.2, 11.4), (72.5, 9.2), (67.1, 4.6)]
FENCE_3B = [(82.9, 22.2), (60.1, 9.6)]
BACKSTOP_1B = [(82.9, 22.2), (91.9, 19.8), (97.6, 9.4), (103.0, -1.9)]
VENDOR = [(-60, 32.4), (-36.2, 32.5), (-33.1, 32.2), (-29.1, 32.7), (-26.0, 32.4),
          (-23.1, 32.1), (-20.1, 32.1), (-15.28, 33.07), (-12.03, 33.58), (-8.81, 33.96),
          (-5.76, 34.24), (-2.51, 34.44), (0.79, 34.77), (3.85, 35.10), (7.16, 35.41),
          (10.33, 35.74)]
VENDOR_SLOPE = 0.1043          # east of its last pole: the old rail fence / road
RODEO = [(88.6, -95.7), (91.7, -87.0), (93.2, -80.1), (96.6, -75.1), (98.2, -70.9),
         (100.5, -66.3), (103.5, -60.2), (106.6, -55.6), (111.1, -50.3), (114.9, -45.7),
         (119.5, -41.1), (124.1, -35.8), (128.7, -29.7)]


def load_js(path):
    s = open(path).read()
    return json.loads(s.split('=', 1)[1].strip().rstrip(';'))


site = load_js('frontend/js/game/lighthouse-site.js')
CEMETERY = next(f['pts'] for f in site['features'] if f['k'] == 'cemetery')
CEM_SEGS = [(CEMETERY[i], CEMETERY[(i + 1) % len(CEMETERY)]) for i in range(len(CEMETERY))]
trees = [t for t in load_js('frontend/js/game/lighthouse-trees.js') if -110 < t[0] < 170 and -150 < t[1] < 70]


def seg_d(p, a, b):
    dx, dz = b[0] - a[0], b[1] - a[1]
    l2 = dx * dx + dz * dz
    t = 0 if l2 == 0 else max(0, min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dz) / l2))
    return math.hypot(p[0] - a[0] - t * dx, p[1] - a[1] - t * dz)


def cross(a, b, c, d):
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    return o(a, b, c) * o(a, b, d) < 0 and o(c, d, a) * o(c, d, b) < 0


def rect(cx, cz, th):
    c, s = math.cos(th), math.sin(th)
    return [(cx + u * c - v * s, cz + u * s + v * c)
            for u, v in [(-L / 2, -W / 2), (L / 2, -W / 2), (L / 2, W / 2), (-L / 2, W / 2)]]


def inside(p, R):
    sg = None
    for i in range(4):
        a, b = R[i], R[(i + 1) % 4]
        cr = (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0])
        if sg is None:
            sg = cr > 0
        elif (cr > 0) != sg:
            return False
    return True


def dpoly(R, P, closed):
    pts = P + ([P[0]] if closed else [])
    d = 1e9
    for i in range(4):
        a, b = R[i], R[(i + 1) % 4]
        for j in range(len(pts) - 1):
            c, e = pts[j], pts[j + 1]
            if cross(a, b, c, e):
                return 0.0
            d = min(d, seg_d(c, a, b), seg_d(e, a, b), seg_d(a, c, e), seg_d(b, c, e))
    if any(inside(p, R) for p in P):
        return 0.0
    return d


def vendor_z(x):
    """z of the vendor fence (or its eastward rail-fence line) at x."""
    if x >= VENDOR[-1][0]:
        return VENDOR[-1][1] + VENDOR_SLOPE * (x - VENDOR[-1][0])
    if x <= VENDOR[0][0]:
        return VENDOR[0][1]
    for (x0, z0), (x1, z1) in zip(VENDOR, VENDOR[1:]):
        if x0 <= x <= x1:
            return z0 + (z1 - z0) * (x - x0) / (x1 - x0)


def rodeo_x(z):
    """x of the rodeo fence at z (the field is west of it)."""
    if z <= RODEO[0][1]:
        return RODEO[0][0]
    if z >= RODEO[-1][1]:
        return 1e9
    for (x0, z0), (x1, z1) in zip(RODEO, RODEO[1:]):
        if z0 <= z <= z1:
            return x0 + (x1 - x0) * (z - z0) / (z1 - z0)


def cem_d(R):
    return min(seg_d(p, a, b) for p in R for a, b in CEM_SEGS)


def metrics(cx, cz, th):
    R = rect(cx, cz, th)
    m = dict(main_infield=dpoly(R, MAIN_DIRT, True), softball_skin=dpoly(R, SKIN, True),
             fence_3B=dpoly(R, FENCE_3B, False), backstop_1B=dpoly(R, BACKSTOP_1B, False),
             vendor=dpoly(R, VENDOR, False), rodeo=dpoly(R, RODEO, False))
    m['north_of_vendor'] = all(p[1] < vendor_z(p[0]) for p in R)
    m['west_of_rodeo'] = all(p[0] < rodeo_x(p[1]) for p in R)
    m['trees'] = min((0 if inside(t, R) else min(seg_d(t, R[i], R[(i + 1) % 4]) for i in range(4)))
                     for t in trees)
    m['cemetery'] = cem_d(R)
    return m, R


def ok(m):
    return (m['main_infield'] >= YD15 and m['softball_skin'] >= 0.3 and m['fence_3B'] >= FT10
            and m['backstop_1B'] >= FT10 and m['vendor'] >= FT10 and m['north_of_vendor']
            and m['west_of_rodeo'] and m['rodeo'] >= FT10 and m['trees'] >= 2.0)


def search(ths, czs, cxs, tol, best=None):
    """Both fences at 10 ft (within tol), then farthest from the cemetery."""
    for thd in ths:
        th = math.radians(thd)
        for cz in czs:
            for cx in cxs:
                R = rect(cx, cz, th)
                if abs(dpoly(R, FENCE_3B, False) - FT10) > tol:
                    continue
                if abs(dpoly(R, VENDOR, False) - FT10) > tol:
                    continue
                sc = cem_d(R)
                if best and sc <= best[0]:
                    continue
                m, _ = metrics(cx, cz, th)
                if ok(m):
                    best = (sc, cx, cz, thd)
    return best


def fr(a, b, st):
    return [a + i * st for i in range(int(round((b - a) / st)) + 1)]


def main():
    b = search(fr(0, 179, 1), fr(-60, 10, 0.5), fr(-10, 70, 0.5), 0.3)
    print('coarse', b, flush=True)
    b = search(fr(b[3] - 1, b[3] + 1, 0.05), fr(b[2] - 1, b[2] + 1, 0.05),
               fr(b[1] - 1, b[1] + 1, 0.05), 0.03)
    print('best', b)
    m, R = metrics(b[1], b[2], math.radians(b[3]))
    print({k: (round(v, 2) if isinstance(v, float) else v) for k, v in m.items()})
    print('corners', [(round(x, 2), round(z, 2)) for x, z in R])


if __name__ == '__main__':
    main()

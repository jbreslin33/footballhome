#!/usr/bin/env python3
"""Export Lighthouse Field obstacles + lidar grids for fh-field-planner (C++).

Python keeps the I/O it is good at (reading the JS data files, the lidar
fetch/pit-fill/flow cache of search_lighthouse_pitch_water.py); the C++
planner does the placement sweep, which in Python took minutes (James,
10/22: "why are we using python lol and not c++").

Writes two files into OUT_DIR (default: LH_SCRATCH or /tmp/lighthouse-water/):
  obstacles.txt — one rule per line, site metres (x east, z south):
    poly    <name> <closed 0|1> <min_m> x z x z ...   rect stays >= min_m off it
    info    <name> <closed 0|1> <min_m> x z ...       shown as a distance, never checked
    inside  <name> <margin_m> x z ...                 rect inside polygon, margin
    outside <name> x z ...                            no corner/centre inside
    below   <name> <slope_east> x z ...               every corner z < line(x)
    left    <name> x z ...                            every corner x < line(z)
    points  <name> <min_m> x z ...                    e.g. tree crowns
  grid.bin     — int32 x0, z0, nx, nz, then float32 g, filled, acc (row = z)
Profiles: 'site' = every mapped obstacle (both pitch sizes; the main
infield is distance-only 'info'); 'plan' = plan_lighthouse_pitch.py's
original 11v11 rules.
Usage: export_lighthouse_planner_input.py site|plan [OUT_DIR]   (repo root)
       export_lighthouse_planner_input.py --js frontend/js/game/lighthouse-planner-data.js GRID_DIR FH_FIELD_PLANNER
         (also sweeps each plannable size for the driest/wettest legal spot)
"""
import json
import math
import os
import struct
import subprocess
import sys

sys.path.insert(0, 'game/scripts')
import plan_lighthouse_pitch as P  # noqa: E402

TRACKS = [
    [[-104.5, -47.6], [-97.7, -57.5], [-79.5, -70.4], [-64.4, -78.7], [-53, -82.5], [-41.7, -90],
     [-30.3, -97.6], [-13.6, -105.1], [0.2, -109.3], [13.1, -112.7], [28.4, -116.1], [43.6, -119.5],
     [58.8, -123], [74.1, -126.4], [78, -128], [97, -135.5], [119.8, -138.5]],
    [[-110, -30], [-108.3, -37], [-104.5, -47.6]],
]
RAILS = [[[-20.1, 34.6], [10.2, 37.9]], [[12.9, 38.1], [26, 40.4], [42.8, 42.6]]]


def line(kind, name, *head, pts):
    flat = ' '.join('%g %g' % (p[0], p[1]) for p in pts)
    return ' '.join([kind, name] + ['%g' % h for h in head]) + ' ' + flat


def layout():
    js = "global.window = {}; require('./frontend/js/game/lighthouse-layout.js');" \
         "process.stdout.write(JSON.stringify(window.LIGHTHOUSE_LAYOUT))"
    return json.loads(subprocess.run(['node', '-e', js], capture_output=True, check=True, text=True).stdout)


def box(b):
    """Footprint corners of a layout box (w along x, d along z, turned
    rotDeg the way field.js's box() turns it)."""
    th = math.radians(b.get('rotDeg', 0))
    c, s = math.cos(th), math.sin(th)
    return [[b['x'] + u * c - v * s, b['z'] + u * s + v * c]
            for u, v in [(-b['w'] / 2, -b['d'] / 2), (b['w'] / 2, -b['d'] / 2),
                         (b['w'] / 2, b['d'] / 2), (-b['w'] / 2, b['d'] / 2)]]


def rules(profile):
    """profile: 'site' = every mapped obstacle, used for both pitch sizes
    since 10/22 (11v11 and 7v7 are dragged around the same park); 'plan' =
    plan_lighthouse_pitch.py's original 11v11 rules (vendor line extended
    east, 15 yd off the main infield), kept to reproduce its search.
    In 'site' the main infield is 'info' — distance only (James: "don't do
    15 yards from main diamond just show how far"); the sweep ignores it."""
    main = 'poly' if profile == 'plan' else 'info'
    out = [line(main, 'main_infield', 1, P.YD15, pts=P.MAIN_DIRT),
           line('poly', 'softball_skin', 1, 0.3, pts=P.SKIN),
           line('poly', 'fence_3B', 0, P.FT10, pts=P.FENCE_3B),
           line('poly', 'backstop_1B', 0, P.FT10, pts=P.BACKSTOP_1B),
           line('poly', 'vendor', 0, P.FT10, pts=P.VENDOR),
           line('poly', 'rodeo', 0, P.FT10, pts=P.RODEO),
           line('left', 'west_of_rodeo', pts=P.RODEO),
           line('points', 'trees', 2.0, pts=P.trees)]
    if profile == 'plan':
        out.append(line('below', 'north_of_vendor', P.VENDOR_SLOPE, pts=P.VENDOR))
    else:
        site = P.load_js('frontend/js/game/lighthouse-site.js')
        rec = next(f['pts'] for f in site['features'] if f['k'] == 'recreation')
        out.append(line('inside', 'park', 3.0, pts=rec))
        out.append(line('outside', 'cemetery', pts=P.CEMETERY))
        out.append(line('poly', 'cemetery_edge', 1, 2.0, pts=P.CEMETERY))
        # Every mapped structure (James, 10/22: "u put 7v7 over the building
        # or play ground lol"): buildings, barn, sheds, trailers, booths,
        # canopies as rects 10 ft clear; the playground's fence as a polygon.
        lay = layout()
        for kind in ('buildings', 'sheds', 'trailers', 'booths', 'canopies'):
            for i, b in enumerate(lay.get(kind, [])):
                out.append(line('poly', '%s_%d' % (kind, i), 1, P.FT10, pts=box(b)))
        out.append(line('poly', 'barn', 1, P.FT10, pts=box(lay['barn'])))
        pg = lay['playground']
        out.append(line('poly', 'playground', 1, P.FT10, pts=pg['fence']))
        for i, r in enumerate(RAILS):
            out.append(line('poly', 'rail_fence_%d' % i, 0, P.FT10, pts=r))
        for i, t in enumerate(TRACKS):
            out.append(line('poly', 'dirt_road_%d' % i, 0, 3.5, pts=t))
        near = lambda pts: any(abs(x) < 250 and abs(z) < 250 for x, z in pts)
        for i, rd in enumerate(f['pts'] for f in site['features'] if f['k'] == 'road' and near(f['pts'])):
            out.append(line('poly', 'street_%d' % i, 0, 3.0, pts=rd))
    return out


def parse(rule_line):
    """obstacles.txt line -> the dict pitch-planner.js reads."""
    t = rule_line.split()
    r = {'k': t[0], 'n': t[1]}
    i = 2
    if r['k'] in ('poly', 'info'):
        r['c'], r['min'], i = int(t[2]), float(t[3]), 4
    elif r['k'] in ('inside', 'points'):
        r['min'], i = float(t[2]), 3
    elif r['k'] == 'below':
        r['slope'], i = float(t[2]), 3
    v = [round(float(x), 2) for x in t[i:]]
    r['pts'] = [v[j:j + 2] for j in range(0, len(v), 2)]
    return r


def sweep_ranges(binary, d):
    """Driest / wettest legal water score per m² for each plannable size,
    from the C++ sweep (2 m x 2°, whole park) — the planner's 100 % / 0 %."""
    out = {}
    for L, W in ((115, 74), (70, 35), (65, 35), (60, 35), (55, 35), (60, 30)):
        res = subprocess.run([binary, os.path.join(d, 'obstacles.txt'), os.path.join(d, 'grid.bin'),
                              '--size', '%d,%d' % (L, W), '--rot', '0,180,2', '--step', '2',
                              '--box', '-120,130,-140,95', '--top', '100000000'],
                             capture_output=True, check=True, text=True).stdout.splitlines()
        area = L * W * 0.9144 ** 2
        rows = [r.split('\t') for r in res[1:-1]]
        dens = [float(r[7]) / area for r in rows]
        b = rows[dens.index(min(dens))]   # the 100 % spot (⭐ BEST snaps here)
        out['%dx%d' % (L, W)] = {'best': round(min(dens), 5), 'worst': round(max(dens), 5), 'legal': len(dens),
                                 'at': [float(b[0]), float(b[1]), float(b[2])]}
        print(L, W, out['%dx%d' % (L, W)], flush=True)
    return out


def write_js(path, ranges):
    """Both profiles + a per-cell water class grid for the in-game
    drag-and-drop planner (frontend/js/game/pitch-planner.js): 0 dry,
    1 pond (pit-filled > 1 cm), 2 runoff (>= 150 m² upslope), 3 flat
    (< 0.5 % over 6 m) — the same classes the sweeps score."""
    import search_lighthouse_pitch_water as W
    g, f, a = W.g, W.filled, W.acc
    nz, nx = len(g), len(g[0])
    rows = []
    for j in range(nz):
        row = []
        for i in range(nx):
            c = 0
            if f[j][i] - g[j][i] > 0.01:
                c = 1
            elif a[j][i] >= 150:
                c = 2
            elif 3 <= i < nx - 3 and 3 <= j < nz - 3:
                gx = (g[j][i + 3] - g[j][i - 3]) / 6
                gz = (g[j + 3][i] - g[j - 3][i]) / 6
                if math.hypot(gx, gz) * 100 < 0.5:
                    c = 3
            row.append(str(c))
        rows.append(''.join(row))
    data = {'rules': [parse(r) for r in rules('site')], 'ranges': ranges,
            'grid': {'x0': W.X0, 'z0': W.Z0, 'nx': nx, 'nz': nz, 'cls': ''.join(rows)}}
    with open(path, 'w') as fh:
        fh.write('// GENERATED by game/scripts/export_lighthouse_planner_input.py --js — do not hand-edit.\n'
                 '// Pitch-planner rules (site metres) + lidar water classes (USGS 3DEP, public domain).\n'
                 'window.LIGHTHOUSE_PLANNER = ' + json.dumps(data, separators=(',', ':')) + ';\n')
    print('wrote', path, os.path.getsize(path), 'bytes')


def main():
    if sys.argv[1] == '--js':
        d = sys.argv[3] if len(sys.argv) > 3 else os.environ.get('LH_SCRATCH', '/tmp/lighthouse-water/')
        os.environ['LH_SCRATCH'] = d.rstrip('/') + '/'
        # --js OUT GRID_DIR fh-field-planner-binary
        export(d, 'site')
        write_js(sys.argv[2], sweep_ranges(sys.argv[4], d))
        return
    profile = sys.argv[1]
    d = sys.argv[2] if len(sys.argv) > 2 else os.environ.get('LH_SCRATCH', '/tmp/lighthouse-water/')
    os.environ['LH_SCRATCH'] = d.rstrip('/') + '/'
    export(d, profile)


def export(d, profile):
    import search_lighthouse_pitch_water as W  # cached lidar grids (fetches once)
    with open(os.path.join(d, 'obstacles.txt'), 'w') as fh:
        fh.write('\n'.join(rules(profile)) + '\n')
    nz, nx = len(W.g), len(W.g[0])
    with open(os.path.join(d, 'grid.bin'), 'wb') as fh:
        fh.write(struct.pack('<4i', W.X0, W.Z0, nx, nz))
        for arr in (W.g, W.filled, W.acc):
            for row in arr:
                fh.write(struct.pack('<%df' % nx, *row))
    print('wrote', d, profile, nx, 'x', nz)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Export Lighthouse Field obstacles + lidar grids for fh-field-planner (C++).

Python keeps the I/O it is good at (reading the JS data files, the lidar
fetch/pit-fill/flow cache of search_lighthouse_pitch_water.py); the C++
planner does the placement sweep, which in Python took minutes (James,
10/22: "why are we using python lol and not c++").

Writes two files into OUT_DIR (default: LH_SCRATCH or /tmp/lighthouse-water/):
  obstacles.txt — one rule per line, site metres (x east, z south):
    poly    <name> <closed 0|1> <min_m> x z x z ...   rect stays >= min_m off it
    inside  <name> <margin_m> x z ...                 rect inside polygon, margin
    outside <name> x z ...                            no corner/centre inside
    below   <name> <slope_east> x z ...               every corner z < line(x)
    left    <name> x z ...                            every corner x < line(z)
    points  <name> <min_m> x z ...                    e.g. tree crowns
  grid.bin     — int32 x0, z0, nx, nz, then float32 g, filled, acc (row = z)
Profiles: '11v11' = plan_lighthouse_pitch.py's rules; '7v7' = the kids'
rules from 10/22 (real rail fences, park boundary, no vendor-line
extension; the small Erie/Whitaker diamond may be played over).
Usage: export_lighthouse_planner_input.py 11v11|7v7 [OUT_DIR]   (repo root)
"""
import os
import struct
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


def rules(profile):
    out = [line('poly', 'main_infield', 1, P.YD15, pts=P.MAIN_DIRT),
           line('poly', 'softball_skin', 1, 0.3, pts=P.SKIN),
           line('poly', 'fence_3B', 0, P.FT10, pts=P.FENCE_3B),
           line('poly', 'backstop_1B', 0, P.FT10, pts=P.BACKSTOP_1B),
           line('poly', 'vendor', 0, P.FT10, pts=P.VENDOR),
           line('poly', 'rodeo', 0, P.FT10, pts=P.RODEO),
           line('left', 'west_of_rodeo', pts=P.RODEO),
           line('points', 'trees', 2.0, pts=P.trees)]
    if profile == '11v11':
        out.append(line('below', 'north_of_vendor', P.VENDOR_SLOPE, pts=P.VENDOR))
    else:
        site = P.load_js('frontend/js/game/lighthouse-site.js')
        rec = next(f['pts'] for f in site['features'] if f['k'] == 'recreation')
        out.append(line('inside', 'park', 3.0, pts=rec))
        out.append(line('outside', 'cemetery', pts=P.CEMETERY))
        out.append(line('poly', 'cemetery_edge', 1, 2.0, pts=P.CEMETERY))
        for i, r in enumerate(RAILS):
            out.append(line('poly', 'rail_fence_%d' % i, 0, P.FT10, pts=r))
        for i, t in enumerate(TRACKS):
            out.append(line('poly', 'dirt_road_%d' % i, 0, 3.5, pts=t))
        near = lambda pts: any(abs(x) < 250 and abs(z) < 250 for x, z in pts)
        for i, rd in enumerate(f['pts'] for f in site['features'] if f['k'] == 'road' and near(f['pts'])):
            out.append(line('poly', 'street_%d' % i, 0, 3.0, pts=rd))
    return out


def main():
    profile = sys.argv[1]
    d = sys.argv[2] if len(sys.argv) > 2 else os.environ.get('LH_SCRATCH', '/tmp/lighthouse-water/')
    os.environ['LH_SCRATCH'] = d.rstrip('/') + '/'
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

#!/usr/bin/env python3
"""scripts/pyramid-fine-borders.py — #apsl-pyramid borders traced from drive
times at many points (mig 1281).
Owner 2026-11-11: "then your current border is off" (Bulldogs SC, Matawan
edge of Monmouth County, is Metropolitan by drive from its ground but the
whole county went by one point) / "you need to check the x,y of these
borders from city centers at multiple points lol".
For each plan:
  * border counties = counties sharing an outline edge with a county of a
    different conference (open ground doesn't count);
  * a grid of points over them (STEP degrees of latitude: current 0.03 ≈
    3 km, proposed 0.10 ≈ 11 km — kinder to the free OSRM server), kept if inside the county outline;
  * each point's candidates = the conferences of its county and its
    neighbours; OSRM road minutes from the point to each candidate city
    (cached in pyramid_grid_drive_times — reruns fetch only new pairs);
  * the point goes to the shortest drive × the city's traffic factor
    ('travel', the coloured border) and to the shortest drive without it
    ('plain', the second line);
  * between grid neighbours of different conferences the cell edge is a
    border piece; pieces are joined (conference A kept on the left, as the
    map's two-tone offset needs) and smoothed (Chaikin ×2).
These lines replace the county-edge borders between two conferences in
pyramid_proposal_borders (fine = true); edges facing open ground stay.
Run after SELECT fh_pyramid_proposal_refresh(), before pyramid-sea-borders.py.
  python3 scripts/pyramid-fine-borders.py [current|proposed]
"""
import json
import math
import os
import shlex
import subprocess
import sys
import time
import urllib.request
from collections import defaultdict

PSQL = shlex.split(os.environ.get(
    'PSQL', 'sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome'))
STEP = {'current': 0.03, 'proposed': 0.10}
OSRM = 'https://router.project-osrm.org/table/v1/driving/'


def psql(sql, stdin=False):
    args = PSQL + ['-At', '-v', 'ON_ERROR_STOP=1']
    if stdin:
        return subprocess.run(args, input=sql, text=True, capture_output=True, check=True).stdout
    return subprocess.run(args + ['-c', sql], text=True, capture_output=True, check=True, stdin=subprocess.DEVNULL).stdout


def inside(x, y, ring):
    c = False
    n = len(ring)
    for i in range(n - 1):
        x1, y1 = ring[i][0], ring[i][1]
        x2, y2 = ring[i + 1][0], ring[i + 1][1]
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1:
            c = not c
    return c


def in_geom(lon, lat, g):
    polys = [g['coordinates']] if g['type'] == 'Polygon' else g['coordinates'] if g['type'] == 'MultiPolygon' else []
    for poly in polys:
        if poly and inside(lon, lat, poly[0]) and not any(inside(lon, lat, h) for h in poly[1:]):
            return True
    return False


def adjacency():
    rows = psql(r"""
        WITH polys AS (
            SELECT k.fips, p.ord AS pord, p.poly FROM pyramid_counties k
             CROSS JOIN LATERAL jsonb_array_elements(
                   CASE k.geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(k.geometry->'coordinates')
                                            WHEN 'MultiPolygon' THEN k.geometry->'coordinates' ELSE '[]'::jsonb END)
                   WITH ORDINALITY p(poly, ord)
             WHERE k.state NOT IN ('AK', 'HI', 'PR')
        ), rings AS (
            SELECT fips, pord * 10000 + r.ord AS ring, r.ring AS pts
              FROM polys CROSS JOIN LATERAL jsonb_array_elements(poly) WITH ORDINALITY r(ring, ord)
        ), pts AS (
            SELECT fips, ring, q.i, round((q.pt->>1)::numeric, 4) AS lat, round((q.pt->>0)::numeric, 4) AS lon
              FROM rings CROSS JOIN LATERAL jsonb_array_elements(pts) WITH ORDINALITY q(pt, i)
        ), seg AS (
            SELECT fips, lat, lon, lead(lat) OVER w AS lat2, lead(lon) OVER w AS lon2
              FROM pts WINDOW w AS (PARTITION BY fips, ring ORDER BY i)
        ), keyed AS (
            SELECT fips, CASE WHEN (lat, lon) < (lat2, lon2) THEN lat || ',' || lon || '|' || lat2 || ',' || lon2
                              ELSE lat2 || ',' || lon2 || '|' || lat || ',' || lon END AS k
              FROM seg WHERE lat2 IS NOT NULL AND (lat, lon) <> (lat2, lon2)
        )
        SELECT DISTINCT min(fips) || ',' || max(fips) FROM keyed GROUP BY k HAVING count(DISTINCT fips) = 2""")
    adj = defaultdict(set)
    for line in rows.split():
        a, b = line.split(',')
        adj[a].add(b)
        adj[b].add(a)
    return adj


def fetch(points, have):
    """points: {(lat, lon): set((to_lat, to_lon))} still missing → write to cache."""
    srcs = sorted(points, key=lambda p: (sorted(points[p])[0], p))
    batches, cur, dsts = [], [], set()
    for p in srcs:
        nd = dsts | points[p]
        if cur and (len(cur) + len(nd) > 100 or len(cur) >= 90):
            batches.append((cur, dsts))
            cur, nd = [], set(points[p])
        cur.append(p)
        dsts = nd
    if cur:
        batches.append((cur, dsts))
    for n, (ss, ds) in enumerate(batches, 1):
        dl = sorted(ds)
        coords = [f'{p[1]},{p[0]}' for p in ss] + [f'{d[1]},{d[0]}' for d in dl]
        url = (OSRM + ';'.join(coords) + '?sources=' + ';'.join(map(str, range(len(ss))))
               + '&destinations=' + ';'.join(str(len(ss) + j) for j in range(len(dl))) + '&annotations=duration')
        d = None
        for _ in range(3):
            try:
                req = urllib.request.Request(url, headers={'User-Agent': 'footballhome-pyramid/1.0'})
                with urllib.request.urlopen(req, timeout=60) as r:
                    d = json.load(r)
                break
            except Exception as e:  # noqa: BLE001
                print(f'  batch {n}: {e}; retry', file=sys.stderr)
                time.sleep(5)
        if not d or 'durations' not in d:
            continue
        vals = []
        for i, p in enumerate(ss):
            for j, q in enumerate(dl):
                if q in points[p] and d['durations'][i][j] is not None:
                    m = d['durations'][i][j] / 60
                    have[(p, q)] = m
                    vals.append(f'({p[0]}, {p[1]}, {q[0]}, {q[1]}, {m:.1f})')
        if vals:
            psql('INSERT INTO pyramid_grid_drive_times (from_lat, from_lon, to_lat, to_lon, minutes) VALUES '
                 + ','.join(vals) + ' ON CONFLICT DO NOTHING', stdin=False)
        if n % 25 == 0 or n == len(batches):
            print(f'  {n}/{len(batches)} requests', file=sys.stderr)
        time.sleep(1.05)


def chaikin(pts, it=2):
    for _ in range(it):
        if len(pts) < 3:
            return pts
        out = [pts[0]]
        for a, b in zip(pts, pts[1:]):
            out.append((0.75 * a[0] + 0.25 * b[0], 0.75 * a[1] + 0.25 * b[1]))
            out.append((0.25 * a[0] + 0.75 * b[0], 0.25 * a[1] + 0.75 * b[1]))
        out.append(pts[-1])
        pts = out
    return pts


def trace(cells, step, dlon):
    """cells: {(i, j): region} → [(a, b, [(lat, lon), …])] with a on the left."""
    segs = defaultdict(list)          # (a, b) → [((lat, lon), (lat, lon))]
    for (i, j), r in cells.items():
        for di, dj in ((0, 1), (1, 0)):
            s = cells.get((i + di, j + dj))
            if s is None or s == r:
                continue
            a, b = (r, s) if r < s else (s, r)
            if dj:     # east neighbour: vertical edge at lon j+½, lat i-½ → i+½
                x = (j + 0.5) * dlon
                p, q = ((i - 0.5) * step, x), ((i + 0.5) * step, x)
                west = r                          # going north, west is on the left
                segs[(a, b)].append((p, q) if west == a else (q, p))
            else:      # north neighbour: horizontal edge at lat i+½, lon j-½ → j+½
                y = (i + 0.5) * step
                p, q = (y, (j + 0.5) * dlon), (y, (j - 0.5) * dlon)   # going west, south is on the left
                south = r
                segs[(a, b)].append((p, q) if south == a else (q, p))
    out = []
    for (a, b), ss in segs.items():
        nxt = defaultdict(list)
        for s in ss:
            nxt[s[0]].append(s)
        used = set()
        starts = {s[0] for s in ss} - {s[1] for s in ss}
        order = [s for s in ss if s[0] in starts] + ss
        for s0 in order:
            if id(s0) in used:
                continue
            line = [s0[0], s0[1]]
            used.add(id(s0))
            while True:
                cand = [s for s in nxt[line[-1]] if id(s) not in used]
                if not cand:
                    break
                used.add(id(cand[0]))
                line.append(cand[0][1])
            if len(line) >= 2:
                out.append((a, b, [(round(p[0], 4), round(p[1], 4)) for p in chaikin(line)]))
    return out


def run(plan, adj):
    step = STEP[plan]
    reg = dict(l.split('|') for l in psql(
        f"SELECT fips || '|' || COALESCE('c' || conference_id, 'p' || proposed_id) FROM pyramid_proposal_counties WHERE plan = '{plan}'").split())
    cen = {}
    for l in psql(f"SELECT COALESCE('c' || conference_id, 'p' || proposed_id) || '|' || round(lat::numeric, 4) || '|' || round(lon::numeric, 4)"
                  f" || '|' || factor FROM pyramid_region_centers WHERE plan = '{plan}'").split():
        k, la, lo, f = l.split('|')
        cen[k] = ((f'{float(la):.4f}', f'{float(lo):.4f}'), float(f))
    border = {f for f in reg if any(n in reg and reg[n] != reg[f] for n in adj[f])}
    geo = json.loads(psql("SELECT json_object_agg(fips, geometry) FROM pyramid_counties WHERE fips IN ("
                          + ','.join(f"'{f}'" for f in border) + ')'))
    lat0 = 39.0
    dlon = step / math.cos(math.radians(lat0))
    cells_c = {}                     # (i, j) → candidates
    for f in border:
        g = geo[f]
        xs, ys = [], []
        polys = [g['coordinates']] if g['type'] == 'Polygon' else g['coordinates']
        for poly in polys:
            for x, y in poly[0]:
                xs.append(x)
                ys.append(y)
        cand = {reg[f]} | {reg[n] for n in adj[f] if n in reg}
        for i in range(math.floor(min(ys) / step), math.ceil(max(ys) / step) + 1):
            for j in range(math.floor(min(xs) / dlon), math.ceil(max(xs) / dlon) + 1):
                if (i, j) in cells_c:
                    cells_c[(i, j)] |= cand
                    continue
                if in_geom(j * dlon, i * step, g):
                    cells_c[(i, j)] = set(cand)
    print(f'{plan}: {len(border)} border counties, {len(cells_c)} grid points', file=sys.stderr)
    pt = {c: (f'{c[0] * step:.4f}', f'{c[1] * dlon:.4f}') for c in cells_c}
    have = {}
    for l in psql('SELECT from_lat || \'|\' || from_lon || \'|\' || to_lat || \'|\' || to_lon || \'|\' || minutes FROM pyramid_grid_drive_times').split():
        a, b, c, d, m = l.split('|')
        have[((f'{float(a):.4f}', f'{float(b):.4f}'), (f'{float(c):.4f}', f'{float(d):.4f}'))] = float(m)
    need = defaultdict(set)
    for c, cs in cells_c.items():
        for r in cs:
            q = cen[r][0]
            if (pt[c], q) not in have:
                need[pt[c]].add(q)
    print(f'  {sum(len(v) for v in need.values())} drives to fetch', file=sys.stderr)
    if need:
        fetch(need, have)
    lab_t, lab_p = {}, {}
    for c, cs in cells_c.items():
        sc = [(have[(pt[c], cen[r][0])], cen[r][1], r) for r in cs if (pt[c], cen[r][0]) in have]
        if not sc:
            continue
        lab_t[c] = min(sc, key=lambda x: x[0] * x[1])[2]
        lab_p[c] = min(sc, key=lambda x: x[0])[2]
    rows = []
    for kind, lab in (('travel', lab_t), ('plain', lab_p)):
        for a, b, line in trace(lab, step, dlon):
            rows.append((a, b, kind, line))
    pairs = {(a, b) for a, b, _, _ in rows}
    pre = 'c' if plan == 'current' else 'p'
    sql = ['BEGIN;']
    # drop the county-edge borders between two conferences of this plan (open-ground edges stay)
    sql.append(f"DELETE FROM pyramid_proposal_borders WHERE region_a LIKE '{pre}%' AND region_b <> 'x';")
    for a, b, kind, line in rows:
        sql.append("INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left, kind, fine) VALUES "
                   f"('{a}', '{b}', '{json.dumps([list(p) for p in line])}'::jsonb, true, '{kind}', true);")
    sql.append('COMMIT;')
    psql('\n'.join(sql) + '\n', stdin=True)
    print(f'  {len(rows)} border lines for {len(pairs)} conference pairs written', file=sys.stderr)


def main():
    plans = [a for a in sys.argv[1:] if a in STEP] or ['current', 'proposed']
    adj = adjacency()
    for plan in plans:
        run(plan, adj)


if __name__ == '__main__':
    main()

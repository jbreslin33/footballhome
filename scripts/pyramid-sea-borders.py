#!/usr/bin/env python3
"""scripts/pyramid-sea-borders.py — #apsl-pyramid proposal borders out to sea (mig 1252).

Owner 2026-11-11: "the lines for del and metro conf needs to go to ocean
right lol?".  The proposal's border lines (pyramid_proposal_borders, built by
fh_pyramid_proposal_refresh(), mig 1241/1249) follow shared county edges, so
a border stops where its counties meet water.  This carries every such loose
end on over the water and writes the result to pyramid_proposal_sea_borders:

  * the line walks midway between the two regions' SHORES — equal distance to
    the nearest edge of each region's counties — in 0.7 km steps along that
    split (Newton-corrected onto it), never onto land (except a channel
    narrower than ~1.2 km, like the Arthur Kill, which the county outlines
    are too coarse to show as water);
  * it stops once it is out past the coastline (6 km from both shores —
    owner: "where land meets the ocean", so no stretch of coast is left
    ambiguous); a bay crossing instead runs on until it meets the far shore's
    loose end of the same pair, or the line already walked from it (the two
    are joined); it also stops where a third region's shore is nearer than
    both, after ~90 km, or when only land lies ahead;
  * ends on the Canadian / Mexican land border are left alone.

Rerun after fh_pyramid_proposal_refresh() (grounds or proposed cities
changed).  Plain Python (no numpy/shapely on the server); talks to the DB
through psql — PSQL env var, default the live container.

  python3 scripts/pyramid-sea-borders.py          # recompute and replace the table
  python3 scripts/pyramid-sea-borders.py --dry    # print what it would write
"""
import json
import math
import os
import shlex
import subprocess
import sys

PSQL = shlex.split(os.environ.get(
    'PSQL', 'sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome'))
DRY = '--dry' in sys.argv
STEP = 0.7          # km per step
MAX_STEPS = 130     # ~90 km (a bay can use up much of it)
BOX = 1.0           # degrees of counties loaded around a loose end
CHANNEL = 0.6       # km: both shores this close = a channel, land test waived
OPEN = 6.0          # km from both shores = out past the coast: the line has done its job
KY = 110.57


def psql(sql, stdin_sql=False):
    args = PSQL + ['-At', '-v', 'ON_ERROR_STOP=1']
    if stdin_sql:
        return subprocess.run(args, input=sql, text=True, capture_output=True, check=True).stdout
    return subprocess.run(args + ['-c', sql], text=True, capture_output=True, check=True, stdin=subprocess.DEVNULL).stdout


def load(plan):
    """One plan's borders and counties (mig 1274: 'current' = c-keys, 'proposed' = p-keys)."""
    pre = 'c' if plan == 'current' else 'p'
    borders = json.loads(psql(
        "SELECT COALESCE(json_agg(json_build_object('id', id, 'a', region_a, 'b', region_b, 'line', line, 'a_left', COALESCE(a_left, false))), '[]')"
        f" FROM pyramid_proposal_borders WHERE kind = 'travel' AND region_a LIKE '{pre}%'"))   # the coloured border (mig 1255)
    counties = json.loads(psql(
        "SELECT json_agg(json_build_object('f', k.fips, 'r', COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id),"
        " 'lat', k.lat, 'lon', k.lon, 'g', k.geometry))"
        f" FROM pyramid_proposal_counties pc JOIN pyramid_counties k USING (fips) WHERE pc.plan = '{plan}'"))
    return borders, counties


def loose_ends(borders):
    seen = {}
    for b in borders:
        for at_end in (True, False):
            p = tuple(b['line'][-1] if at_end else b['line'][0])
            seen.setdefault(p, []).append((b, at_end))
    out = []
    for p, uses in seen.items():
        if len(uses) != 1:
            continue
        b, at_end = uses[0]
        line = b['line']
        q = line[-2] if at_end else line[1]
        lat, lon = p
        # the land border with Canada (49th parallel; 45th along NY/VT) and Mexico
        if lat >= 48.98 or (abs(lat - 45.0) < 0.02 and -75.5 < lon < -71.4) or (lat < 32.8 and lon < -104.0):
            continue
        out.append({'b': b, 'at_end': at_end, 'p': (lat, lon), 'q': tuple(q)})
    return out


class Patch:
    """The counties around one loose end, in a local km plane."""

    def __init__(self, counties, lat0, lon0):
        self.lat0, self.lon0 = lat0, lon0
        self.kx = 111.32 * math.cos(math.radians(lat0))
        self.rings = []      # (fips, [(x, y), …], (x0, y0, x1, y1))
        self.segs = {}       # region → [(ax, ay, bx, by)]
        self.local = None
        for c in counties:
            if abs(float(c['lat']) - lat0) > BOX or abs(float(c['lon']) - lon0) > BOX * 1.3:
                continue
            g = c['g']
            polys = g['coordinates'] if g['type'] == 'MultiPolygon' else [g['coordinates']]
            for poly in polys:
                for ring in poly:
                    pts = [self.xy(la, lo) for lo, la in ring]
                    xs, ys = [q[0] for q in pts], [q[1] for q in pts]
                    self.rings.append((c['f'], pts, (min(xs), min(ys), max(xs), max(ys))))
                    s = self.segs.setdefault(c['r'], [])
                    for i in range(len(pts) - 1):
                        s.append((pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1]))

    def xy(self, lat, lon):
        return ((lon - self.lon0) * self.kx, (lat - self.lat0) * KY)

    def ll(self, p):
        return (round(self.lat0 + p[1] / KY, 4), round(self.lon0 + p[0] / self.kx, 4))

    def focus(self, p, radius):
        """Only the shore within `radius` km of p counts until the next focus()."""
        px, py = p
        self.local = {r: [s for s in segs if min(s[0], s[2]) - radius <= px <= max(s[0], s[2]) + radius
                                          and min(s[1], s[3]) - radius <= py <= max(s[1], s[3]) + radius]
                      for r, segs in self.segs.items()}

    def dist(self, p, region, everywhere=False):
        best = 1e9
        px, py = p
        pool = self.segs if everywhere or self.local is None else self.local
        for ax, ay, bx, by in pool.get(region, ()):
            dx, dy = bx - ax, by - ay
            L = dx * dx + dy * dy
            t = 0.0 if L == 0 else max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / L))
            d = math.hypot(px - ax - t * dx, py - ay - t * dy)
            if d < best:
                best = d
        return best

    def on_land(self, p):
        px, py = p
        n = {}
        for f, pts, (x0, y0, x1, y1) in self.rings:
            if not (x0 <= px <= x1 and y0 <= py <= y1):
                continue
            c = 0
            for i in range(len(pts) - 1):
                (x1, y1), (x2, y2) = pts[i], pts[i + 1]
                if (y1 > py) != (y2 > py) and px < (x2 - x1) * (py - y1) / (y2 - y1) + x1:
                    c += 1
            n[f] = n.get(f, 0) + c
        return any(v % 2 for v in n.values())


def walk(patch, a, b, start, prev, others, walked=()):
    """Walk the a|b shore split out from `start` (heading away from `prev`)."""
    def F(p):
        da, db = patch.dist(p, a), patch.dist(p, b)
        return da - db, da, db

    def grad(p, h=0.05):
        return ((F((p[0] + h, p[1]))[0] - F((p[0] - h, p[1]))[0]) / (2 * h),
                (F((p[0], p[1] + h))[0] - F((p[0], p[1] - h))[0]) / (2 * h))

    p = patch.xy(*start)
    q = patch.xy(*prev)
    d = (p[0] - q[0], p[1] - q[1])
    L = math.hypot(*d) or 1.0
    d = (d[0] / L, d[1] / L)
    pts = [patch.ll(p)]
    third = [r for r in patch.segs if r not in (a, b)]
    # a bay crossing: the same border has another loose end (or walk) across
    # the water AHEAD of us (within 70 km, in front of our heading)
    def ahead(pt):
        ox, oy = patch.xy(*pt)
        vx, vy = ox - p[0], oy - p[1]
        dd = math.hypot(vx, vy)
        return 0 < dd < 70 and (vx * d[0] + vy * d[1]) / dd > 0.2
    crossing = any(ahead(o['p']) for o in others) or any(ahead(wp) for w in walked for wp in w)
    for _ in range(MAX_STEPS):
        # this step only needs the shore a little beyond the nearer of the two
        patch.local = None
        reach = min(patch.dist(p, a, True), patch.dist(p, b, True))
        patch.focus(p, max(reach, 1.0) * 1.5 + 4 * STEP + 3)
        base = []
        f0, da0, db0 = F(p)
        if min(da0, db0) > 0.05:
            gx, gy = grad(p)
            g = math.hypot(gx, gy)
            if g > 1e-6:
                t = (-gy / g, gx / g)
                if t[0] * d[0] + t[1] * d[1] < 0:
                    t = (-t[0], -t[1])
                base.append(t)
        base.append(d)
        best = None
        for t in base:
            for ang in (0, 20, -20, 45, -45):
                r = math.radians(ang)
                dx, dy = t[0] * math.cos(r) - t[1] * math.sin(r), t[0] * math.sin(r) + t[1] * math.cos(r)
                c = (p[0] + STEP * dx, p[1] + STEP * dy)
                for _n in range(4):
                    f, da, db = F(c)
                    gx, gy = grad(c)
                    g2 = gx * gx + gy * gy
                    if g2 < 1e-9:
                        break
                    c = (c[0] - f * gx / g2, c[1] - f * gy / g2)
                f, da, db = F(c)
                k = math.hypot(c[0] - p[0], c[1] - p[1])
                if k < 0.2 or k > 3 * STEP or abs(f) > 0.3:
                    continue
                dot = ((c[0] - p[0]) * d[0] + (c[1] - p[1]) * d[1]) / k
                if dot < -0.1:
                    continue
                if not (da < CHANNEL and db < CHANNEL) and patch.on_land(c):
                    continue
                if best is None or dot > best[0]:
                    best = (dot, c, da, db)
        if best is None:
            break
        _, c, da, db = best
        # out past the coastline (owner: "where land meets the ocean") — unless
        # the far shore of a bay crossing is still to be met
        if not crossing and min(da, db) > OPEN:
            pts.append(patch.ll(c))
            break
        # a third region's shore nearer than both: the split ends here
        if any(patch.dist(c, r) < min(da, db) - 0.3 for r in third):
            break
        k = math.hypot(c[0] - p[0], c[1] - p[1])
        d = ((c[0] - p[0]) / k, (c[1] - p[1]) / k)
        p = c
        pts.append(patch.ll(p))
        # an earlier walk of the same pair from the far shore: join it and stop
        for w in walked:
            for j, wp in enumerate(w):
                wx, wy = patch.xy(*wp)
                if math.hypot(wx - p[0], wy - p[1]) < 1.5:
                    pts.append(tuple(wp))
                    return pts
        # the far shore's loose end of the same pair: join it and stop
        for o in others:
            ox, oy = patch.xy(*o['p'])
            if math.hypot(ox - p[0], oy - p[1]) < 1.5:
                pts.append(tuple(o['p']))
                o['joined'] = True
                return pts
    return pts


def main():
    rows = []
    for plan in ('current', 'proposed'):   # mig 1274: both plans
        plan_rows(plan, rows)
    write(rows)


def plan_rows(plan, rows):
    borders, counties = load(plan)
    if not borders or not counties:
        return
    ends = loose_ends(borders)
    walked = {}          # pair → the lines walked so far (for bay crossings)
    for e in ends:
        if e.get('joined'):
            continue
        b = e['b']
        patch = Patch(counties, e['p'][0], e['p'][1])
        others = [o for o in ends if o is not e and not o.get('joined')
                  and {o['b']['a'], o['b']['b']} == {b['a'], b['b']}]
        pair = frozenset((b['a'], b['b']))
        pts = walk(patch, b['a'], b['b'], e['p'], e['q'], others, walked.get(pair, []))
        if len(pts) < 3:
            continue
        walked.setdefault(pair, []).append(pts)
        # keep the land line's direction so a_left still holds
        line = pts if e['at_end'] else pts[::-1]
        rows.append((b['a'], b['b'], [list(x) for x in line], b['a_left']))
        print(f"{b['a']}|{b['b']} from {e['p']}: {len(pts)} points → {pts[-1]}", file=sys.stderr)


def write(rows):
    sql = "BEGIN;\nDELETE FROM pyramid_proposal_sea_borders;\n" + "".join(
        "INSERT INTO pyramid_proposal_sea_borders (region_a, region_b, line, a_left) VALUES "
        f"('{a}', '{b}', '{json.dumps(line)}'::jsonb, {'true' if al else 'false'});\n"
        for a, b, line, al in rows) + "COMMIT;\n"
    if DRY:
        print(sql)
    else:
        psql(sql, stdin_sql=True)
        print(f"{len(rows)} sea borders written", file=sys.stderr)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""scripts/pyramid-balance.py — #apsl-pyramid: trim the long tails (mig 1272).
Owner 2026-11-11: "no part of country should be left uncovered … fit the
puzzle together" — and the nearest-base fill (mig 1270) left conferences
whose furthest populated places are 8 h+ apart.  This moves populated border
counties between neighbouring conferences to shorten the longest trips:
  * a conference's span = the furthest-apart pair of its counties where
    people live (≥ pyramid_territory_policy.span_min_population, or its two
    biggest) — the same measure fh_pyramid_proposal_refresh() stores;
  * cost = Σ over conferences of (span − balance_target_km)² where over the
    target; a move of county c from A to neighbouring B is taken when it
    lowers the cost;
  * never moves a county of a home metro area (mig 1265), never empties a
    conference, never splits one into more pieces than it had;
  * a populated county deep inside a tail moves together with the sparse
    counties beyond it (the tail past it, cut off from A once it goes).
Writes pyramid_proposal_county_pins, then runs the refresh.  Afterwards run
scripts/pyramid-sea-borders.py and scripts/pyramid-drive-times.py.
  python3 scripts/pyramid-balance.py          # recompute pins and refresh
  python3 scripts/pyramid-balance.py --dry    # report only
"""
import json
import math
import os
import shlex
import subprocess
import sys
from collections import defaultdict, deque

PSQL = shlex.split(os.environ.get(
    'PSQL', 'sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome'))
DRY = '--dry' in sys.argv


def psql(sql):
    return subprocess.run(PSQL + ['-At', '-v', 'ON_ERROR_STOP=1', '-c', sql], text=True,
                          capture_output=True, check=True, stdin=subprocess.DEVNULL).stdout


def km(a, b):
    la1, lo1, la2, lo2 = map(math.radians, (a[0], a[1], b[0], b[1]))
    h = math.sin((la2 - la1) / 2) ** 2 + math.cos(la1) * math.cos(la2) * math.sin((lo2 - lo1) / 2) ** 2
    return 12742 * math.asin(min(1, math.sqrt(h)))


def load():
    if not DRY:
        psql('DELETE FROM pyramid_proposal_county_pins')
        psql('SELECT fh_pyramid_proposal_refresh()')
    pol = json.loads(psql('SELECT row_to_json(p) FROM (SELECT span_min_population AS minpop, balance_target_km AS target'
                          ' FROM pyramid_territory_policy LIMIT 1) p'))
    rows = json.loads(psql(
        "SELECT json_agg(json_build_object('f', k.fips, 'lat', k.lat, 'lon', k.lon, 'pop', k.population,"
        " 'r', COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id),"
        " 'home', EXISTS (SELECT 1 FROM pyramid_region_homes h WHERE h.fips = k.fips)))"
        " FROM pyramid_proposal_counties pc JOIN pyramid_counties k ON k.fips = pc.fips"))
    # Neighbours: counties sharing an outline edge (as the border builder does).
    adj_rows = psql(r"""
        WITH polys AS (
            SELECT k.fips, p.ord AS pord, p.poly FROM pyramid_counties k
              JOIN pyramid_proposal_counties pc ON pc.fips = k.fips
             CROSS JOIN LATERAL jsonb_array_elements(
                   CASE k.geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(k.geometry->'coordinates')
                                            WHEN 'MultiPolygon' THEN k.geometry->'coordinates' ELSE '[]'::jsonb END)
                   WITH ORDINALITY p(poly, ord)
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
    for line in adj_rows.split():
        a, b = line.split(',')
        adj[a].add(b)
        adj[b].add(a)
    return pol, {r['f']: r for r in rows}, adj


def main():
    pol, C, adj = load()
    minpop, target = pol['minpop'], float(pol['target'])
    region = {f: c['r'] for f, c in C.items()}
    members = defaultdict(set)
    for f, r in region.items():
        members[r].add(f)
    pt = {f: (float(c['lat']), float(c['lon'])) for f, c in C.items()}

    def cands(r):
        ms = members[r]
        big = [f for f in ms if C[f]['pop'] >= minpop]
        if len(big) >= 2:
            return big
        return sorted(ms, key=lambda f: -C[f]['pop'])[:2]

    def span(fs):
        best = 0.0
        fs = list(fs)
        for i in range(len(fs)):
            for j in range(i + 1, len(fs)):
                d = km(pt[fs[i]], pt[fs[j]])
                if d > best:
                    best = d
        return best

    def cost(s):
        return max(0.0, s - target) ** 2

    def pieces(fs):
        fs, seen, n = set(fs), set(), 0
        for f in fs:
            if f in seen:
                continue
            n += 1
            q = deque([f])
            seen.add(f)
            while q:
                x = q.popleft()
                for y in adj[x]:
                    if y in fs and y not in seen:
                        seen.add(y)
                        q.append(y)
        return n

    def tail(c, r):
        """c plus the counties of r cut off from r's main body once c leaves."""
        rest = members[r] - {c}
        if not rest:
            return None
        # main body = the piece holding r's biggest county
        anchor = max(rest, key=lambda f: C[f]['pop'])
        seen, q = {anchor}, deque([anchor])
        while q:
            x = q.popleft()
            for y in adj[x]:
                if y in rest and y not in seen:
                    seen.add(y)
                    q.append(y)
        cut = rest - seen
        before = pieces(members[r])
        if pieces(seen) > before:   # shouldn't happen, guard anyway
            return None
        return {c} | cut

    spans = {r: span(cands(r)) for r in members}
    start = {r: spans[r] for r in spans}
    moves = 0
    for _ in range(4000):
        over = sorted((r for r in spans if spans[r] > target), key=lambda r: -spans[r])
        best = None
        for r in over:
            cs = cands(r)
            # the populated counties that sit in a pair longer than the target
            far = {f for f in cs if any(km(pt[f], pt[g]) > target for g in cs if g != f)}
            for c in far:
                if C[c]['home']:
                    continue
                group = tail(c, r)
                if not group or any(C[f]['home'] for f in group) or len(group) > 60:
                    continue
                nbr = {region[y] for f in group for y in adj[f]} - {r}
                for b in nbr:
                    members[r] -= group
                    members[b] |= group
                    sr, sb = span(cands(r)), span(cands(b))
                    members[b] -= group
                    members[r] |= group
                    gain = cost(spans[r]) + cost(spans[b]) - cost(sr) - cost(sb)
                    if gain > 1e-6 and (best is None or gain > best[0]):
                        best = (gain, group, r, b, sr, sb)
        if not best:
            break
        _, group, r, b, sr, sb = best
        members[r] -= group
        members[b] |= group
        for f in group:
            region[f] = b
        spans[r], spans[b] = sr, sb
        moves += 1

    moved = {f: region[f] for f in C if region[f] != C[f]['r']}
    print(f'{moves} moves, {len(moved)} counties change conference')
    for r in sorted(spans, key=lambda r: -start[r]):
        if abs(spans[r] - start[r]) > 0.5:
            print(f'  {r}: {start[r]:.0f} → {spans[r]:.0f} km')
    over = sum(1 for s in spans.values() if s > target)
    print(f'{over} of {len(spans)} still over {target:.0f} km')
    if DRY:
        return
    if moved:
        vals = ','.join(
            f"('{f}', {r[1:] if r[0] == 'c' else 'NULL'}, {r[1:] if r[0] == 'p' else 'NULL'})" for f, r in moved.items())
        psql(f'INSERT INTO pyramid_proposal_county_pins (fips, conference_id, proposed_id) VALUES {vals}')
    psql('SELECT fh_pyramid_proposal_refresh()')
    print('pins written, refreshed')


if __name__ == '__main__':
    main()

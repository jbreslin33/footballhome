#!/usr/bin/env python3
"""scripts/pyramid-county-drive.py — #apsl-pyramid: county → city drive times (mig 1278).
Owner 2026-11-11: "travel time and travel time+traffic i should say because
distance may go across water lol right?" / "the border for del and metro
should primarily factor drive time for the two".
For every lower-48 county point (pyramid_county_points) and each plan's
conference measuring points (pyramid_region_points, mig 1284), asks the public OSRM router
(OpenStreetMap roads, no traffic) for the drive to the county's K nearest
cities (straight km × traffic factor) — the ones that can win it — and
stores minutes + km in pyramid_county_drive_times.  Pairs already stored
(same two points) are skipped, so a rerun only fetches what changed.  Uses
OSRM's table service, ≤ 100 points a request, one request a second.  Only
county / city coordinates are sent.
  python3 scripts/pyramid-county-drive.py        # fetch missing pairs
Also club grounds → the 3 nearest live conference cities (mig 1279).
Then: SELECT fh_pyramid_proposal_refresh(); pyramid-sea-borders.py,
pyramid-drive-times.py.
"""
import json
import math
import os
import shlex
import subprocess
import time
import urllib.request
from collections import defaultdict

PSQL = shlex.split(os.environ.get(
    'PSQL', 'sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome'))
K = 4                 # nearest cities per county per plan
MAX_SRC = 60
MAX_DST = 40          # sources + destinations ≤ 100 (OSRM demo limit)


def psql(sql, stdin=False):
    args = PSQL + ['-At', '-v', 'ON_ERROR_STOP=1']
    if stdin:
        return subprocess.run(args, input=sql, text=True, capture_output=True, check=True).stdout
    return subprocess.run(args + ['-c', sql], text=True, capture_output=True, check=True, stdin=subprocess.DEVNULL).stdout


def km(a, b):
    la1, lo1, la2, lo2 = map(math.radians, (a[0], a[1], b[0], b[1]))
    h = math.sin((la2 - la1) / 2) ** 2 + math.cos(la1) * math.cos(la2) * math.sin((lo2 - lo1) / 2) ** 2
    return 12742 * math.asin(min(1, math.sqrt(h)))


def main():
    pts = json.loads(psql("SELECT json_agg(json_build_object('f', fips, 'lat', lat, 'lon', lon)) FROM pyramid_county_points"))
    # mig 1284: every measuring point of a conference (base metro + other big metros in it)
    cens = json.loads(psql("SELECT json_agg(json_build_object('plan', plan, 'r', COALESCE('c' || conference_id, 'p' || proposed_id),"
                           " 'lat', round(lat::numeric, 4), 'lon', round(lon::numeric, 4), 'factor', factor, 'base', is_base))"
                           " FROM pyramid_region_points"))
    pts_of = defaultdict(list)
    for c in cens:
        pts_of[(c['plan'], c['r'])].append(c)
    have = set(psql("SELECT fips || '|' || from_lat || '|' || from_lon || '|' || to_lat || '|' || to_lon FROM pyramid_county_drive_times").split())
    fmt = lambda x: f'{float(x):.4f}'
    need = defaultdict(set)      # county → set of city points
    for p in pts:
        a = (float(p['lat']), float(p['lon']))
        for plan in ('current', 'proposed'):
            cs = [c for c in cens if c['plan'] == plan and c['base']]
            cs.sort(key=lambda c: km(a, (float(c['lat']), float(c['lon']))) * float(c['factor']))
            for c in [q for b in cs[:K] for q in pts_of[(plan, b['r'])]]:
                key = f"{p['f']}|{fmt(p['lat'])}|{fmt(p['lon'])}|{fmt(c['lat'])}|{fmt(c['lon'])}"
                if key not in have:
                    need[p['f']].add((fmt(c['lat']), fmt(c['lon'])))
    P = {p['f']: (fmt(p['lat']), fmt(p['lon'])) for p in pts}
    todo = sorted(need, key=lambda f: (sorted(need[f])[0], f))   # neighbours share cities
    print(f'{sum(len(v) for v in need.values())} pairs for {len(todo)} counties')
    batches, cur, dsts = [], [], set()
    for f in todo:
        nd = dsts | need[f]
        if cur and (len(cur) >= MAX_SRC or len(nd) > MAX_DST):
            batches.append((cur, dsts))
            cur, nd = [], set(need[f])
        cur.append(f)
        dsts = nd
    if cur:
        batches.append((cur, dsts))
    written = 0
    for n, (srcs, dset) in enumerate(batches, 1):
        dl = sorted(dset)
        coords = [f'{P[f][1]},{P[f][0]}' for f in srcs] + [f'{d[1]},{d[0]}' for d in dl]
        url = ('https://router.project-osrm.org/table/v1/driving/' + ';'.join(coords)
               + '?sources=' + ';'.join(str(i) for i in range(len(srcs)))
               + '&destinations=' + ';'.join(str(len(srcs) + j) for j in range(len(dl)))
               + '&annotations=duration,distance')
        for attempt in range(3):
            try:
                req = urllib.request.Request(url, headers={'User-Agent': 'footballhome-pyramid/1.0'})
                with urllib.request.urlopen(req, timeout=60) as r:
                    d = json.load(r)
                break
            except Exception as e:  # noqa: BLE001
                print(f'batch {n}: {e}; retry')
                time.sleep(5)
        else:
            continue
        vals = []
        for i, f in enumerate(srcs):
            for j, dd in enumerate(dl):
                if dd not in need[f]:
                    continue
                dur, dist = d['durations'][i][j], d['distances'][i][j]
                if dur is None or dist is None:
                    continue
                vals.append(f"('{f}', {P[f][0]}, {P[f][1]}, {dd[0]}, {dd[1]}, {dur / 60:.1f}, {dist / 1000:.1f})")
        if vals:
            psql('INSERT INTO pyramid_county_drive_times (fips, from_lat, from_lon, to_lat, to_lon, minutes, km) VALUES '
                 + ','.join(vals) + ' ON CONFLICT (fips, to_lat, to_lon) DO UPDATE SET from_lat = EXCLUDED.from_lat,'
                 ' from_lon = EXCLUDED.from_lon, minutes = EXCLUDED.minutes, km = EXCLUDED.km, fetched_at = now()', stdin=False)
            written += len(vals)
        print(f'batch {n}/{len(batches)}: {len(vals)} pairs')
        time.sleep(1.1)
    print(f'{written} drive times written')
    venues()


def venues():
    """Club grounds → the 3 nearest live conference cities (mig 1279: a club's
    conference goes by drive time from its own ground)."""
    vs = json.loads(psql("SELECT COALESCE(json_agg(json_build_object('id', v.id, 'lat', round(v.lat::numeric, 4), 'lon', round(v.lon::numeric, 4))), '[]')"
                         " FROM pyramid_venues v WHERE v.lat IS NOT NULL AND EXISTS (SELECT 1 FROM pyramid_teams t WHERE t.venue_id = v.id AND t.removed_at IS NULL)"))
    cens = json.loads(psql("SELECT json_agg(json_build_object('r', conference_id, 'lat', round(lat::numeric, 4), 'lon', round(lon::numeric, 4),"
                           " 'factor', factor, 'base', is_base)) FROM pyramid_region_points WHERE plan = 'current'"))
    pts_of = defaultdict(list)
    for c in cens:
        pts_of[c['r']].append(c)
    have = set(psql("SELECT venue_id || '|' || from_lat || '|' || from_lon || '|' || to_lat || '|' || to_lon FROM pyramid_venue_drive_times").split())
    fmt = lambda x: f'{float(x):.4f}'
    need = {}
    for v in vs:
        a = (float(v['lat']), float(v['lon']))
        cs = sorted([c for c in cens if c['base']], key=lambda c: km(a, (float(c['lat']), float(c['lon']))) * float(c['factor']))[:3]
        cs = [q for b in cs for q in pts_of[b['r']]]
        miss = [(fmt(c['lat']), fmt(c['lon'])) for c in cs
                if f"{v['id']}|{fmt(v['lat'])}|{fmt(v['lon'])}|{fmt(c['lat'])}|{fmt(c['lon'])}" not in have]
        if miss:
            need[v['id']] = ((fmt(v['lat']), fmt(v['lon'])), miss)
    dl = sorted({d for _, ms in need.values() for d in ms})
    ids = list(need)
    written = 0
    for i in range(0, len(ids), 100 - len(dl)):
        chunk = ids[i:i + 100 - len(dl)]
        coords = [f'{need[x][0][1]},{need[x][0][0]}' for x in chunk] + [f'{d[1]},{d[0]}' for d in dl]
        url = ('https://router.project-osrm.org/table/v1/driving/' + ';'.join(coords)
               + '?sources=' + ';'.join(str(j) for j in range(len(chunk)))
               + '&destinations=' + ';'.join(str(len(chunk) + j) for j in range(len(dl)))
               + '&annotations=duration,distance')
        req = urllib.request.Request(url, headers={'User-Agent': 'footballhome-pyramid/1.0'})
        with urllib.request.urlopen(req, timeout=60) as r:
            d = json.load(r)
        vals = []
        for a, x in enumerate(chunk):
            for b, dd in enumerate(dl):
                if dd not in need[x][1] or d['durations'][a][b] is None:
                    continue
                vals.append(f"({x}, {need[x][0][0]}, {need[x][0][1]}, {dd[0]}, {dd[1]}, {d['durations'][a][b] / 60:.1f}, {d['distances'][a][b] / 1000:.1f})")
        if vals:
            psql('INSERT INTO pyramid_venue_drive_times (venue_id, from_lat, from_lon, to_lat, to_lon, minutes, km) VALUES '
                 + ','.join(vals) + ' ON CONFLICT (venue_id, to_lat, to_lon) DO UPDATE SET from_lat = EXCLUDED.from_lat,'
                 ' from_lon = EXCLUDED.from_lon, minutes = EXCLUDED.minutes, km = EXCLUDED.km, fetched_at = now()')
            written += len(vals)
        time.sleep(1.1)
    print(f'{written} club-ground drive times written')


if __name__ == '__main__':
    main()

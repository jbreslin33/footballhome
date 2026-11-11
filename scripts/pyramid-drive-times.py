#!/usr/bin/env python3
"""scripts/pyramid-drive-times.py — #apsl-pyramid pill drive times (mig 1270).
Owner 2026-11-11: "pill on each conf … with distance from furthest points
and pop" / "drive time … or dist and drive time".  For each proposal-map
region, fh_pyramid_proposal_refresh() stores its two county centres furthest
apart (pyramid_proposal_region_stats.a_fips / b_fips).  This asks the public
OSRM router (router.project-osrm.org, OpenStreetMap roads, no traffic) for
the drive between each pair not yet in pyramid_drive_times, one request a
second, and stores road km + minutes.  Only county-centre coordinates are
sent.  Rerun after every refresh; pairs already fetched are kept.
  python3 scripts/pyramid-drive-times.py
"""
import json
import os
import shlex
import subprocess
import time
import urllib.request

PSQL = shlex.split(os.environ.get(
    'PSQL', 'sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome'))
OSRM = 'https://router.project-osrm.org/route/v1/driving/{},{};{},{}?overview=false'


def psql(sql):
    return subprocess.run(PSQL + ['-At', '-v', 'ON_ERROR_STOP=1', '-c', sql], text=True,
                          capture_output=True, check=True, stdin=subprocess.DEVNULL).stdout


def main():
    rows = json.loads(psql(
        "SELECT COALESCE(json_agg(json_build_object('a', s.a_fips, 'b', s.b_fips, 'alat', ka.lat, 'alon', ka.lon,"
        " 'blat', kb.lat, 'blon', kb.lon)), '[]') FROM pyramid_proposal_region_stats s"
        " JOIN pyramid_counties ka ON ka.fips = s.a_fips JOIN pyramid_counties kb ON kb.fips = s.b_fips"
        " WHERE NOT EXISTS (SELECT 1 FROM pyramid_drive_times d WHERE d.a_fips = s.a_fips AND d.b_fips = s.b_fips)"))
    done = 0
    for r in rows:
        url = OSRM.format(r['alon'], r['alat'], r['blon'], r['blat'])
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'footballhome-pyramid/1.0'})
            with urllib.request.urlopen(req, timeout=30) as f:
                d = json.load(f)
            route = d['routes'][0]
        except Exception as e:  # noqa: BLE001 — one failed pair shouldn't stop the rest
            print(f"{r['a']}→{r['b']}: {e}")
            time.sleep(1.1)
            continue
        km, mins = route['distance'] / 1000, route['duration'] / 60
        psql(f"INSERT INTO pyramid_drive_times (a_fips, b_fips, km, minutes) VALUES ('{r['a']}', '{r['b']}', {km:.1f}, {mins:.1f})"
             " ON CONFLICT (a_fips, b_fips) DO UPDATE SET km = EXCLUDED.km, minutes = EXCLUDED.minutes, fetched_at = now()")
        print(f"{r['a']}→{r['b']}: {km:.0f} km, {mins / 60:.1f} h")
        done += 1
        time.sleep(1.1)
    print(f'{done} of {len(rows)} drive times written')


if __name__ == '__main__':
    main()

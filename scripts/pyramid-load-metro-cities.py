#!/usr/bin/env python3
"""scripts/pyramid-load-metro-cities.py — each metro area's main city point (mig 1298).
Owner 2026-11-12: "pills to select diff models. city(s) center, metro(s)
center, pop center of mass".  The City centre model needs a city point for
every metro that can become a measuring point (a conference's second big
metro, mig 1285), not only the live conferences' landmarks
(pyramid_main_cities) and proposed downtowns (pyramid_proposed_anchors).
Downloads the 2023 Census Gazetteer places file (census.gov, public, no
key), takes each metro's FIRST named city in its first named state
("Philadelphia-Camden-Wilmington, PA-NJ-DE-MD" → Philadelphia, PA) and
stores that place's internal point in pyramid_metro_areas.city_lat/lon.
A place's internal point is near the middle of the city's land, not a
landmark — the live and proposed conferences keep their own city points.
Downloads go to a fresh temp directory (untrusted data, parsed as text only).
  python3 scripts/pyramid-load-metro-cities.py
"""
import csv
import io
import os
import re
import shlex
import subprocess
import tempfile
import urllib.request
import zipfile

PSQL = shlex.split(os.environ.get(
    'PSQL', 'sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome'))
GAZ = 'https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2023_Gazetteer/2023_Gaz_place_national.zip'
# a place name = "<city> <descriptor>"; better descriptors first
RANK = ['city', 'city (balance)', 'municipality', 'town', 'village', 'borough', 'urban county', 'CDP']


def psql(sql, stdin=False):
    args = PSQL + ['-At', '-v', 'ON_ERROR_STOP=1']
    if stdin:
        return subprocess.run(args, input=sql, text=True, capture_output=True, check=True).stdout
    return subprocess.run(args + ['-c', sql], text=True, capture_output=True, check=True, stdin=subprocess.DEVNULL).stdout


def main():
    with tempfile.TemporaryDirectory() as d:
        path = os.path.join(d, 'places.zip')
        req = urllib.request.Request(GAZ, headers={'User-Agent': 'footballhome-pyramid/1.0'})
        with urllib.request.urlopen(req, timeout=300) as r, open(path, 'wb') as f:
            f.write(r.read())
        z = zipfile.ZipFile(path)
        rows = list(csv.reader(io.TextIOWrapper(z.open(z.namelist()[0]), encoding='utf-8'), delimiter='\t'))
    hdr = [h.strip() for h in rows[0]]
    ui, ni, la, lo, ar = (hdr.index(k) for k in ('USPS', 'NAME', 'INTPTLAT', 'INTPTLONG', 'ALAND'))
    by_state = {}
    for row in rows[1:]:
        by_state.setdefault(row[ui].strip(), []).append((row[ni].strip(), float(row[la]), float(row[lo]), int(row[ar])))

    metros = [l.split('|', 1) for l in psql("SELECT cbsa_code, title FROM pyramid_metro_areas ORDER BY cbsa_code").splitlines() if l]
    out, miss = [], []
    for code, title in metros:
        name, _, states = title.partition(', ')
        state = states.split('-')[0].strip()
        best = None
        # the whole name first ("Winston-Salem"), then its first city ("Philadelphia")
        for city in dict.fromkeys([name.split('--')[0].strip(), re.split(r'--|-|/', name)[0].strip()]):
          if best:
            break
          for (pn, lat, lon, aland) in by_state.get(state, []):
              if not (pn == city or pn.startswith(city + ' ') or pn.startswith(city + '-') or pn.startswith(city + '/')):
                  continue
              rest = pn[len(city):].strip(' -/')
              # "Nashville-Davidson metropolitan government (balance)" etc.: any lowercase descriptor
              rk = RANK.index(rest) if rest in RANK else (len(RANK) if (not rest or rest[0].islower() or '(balance)' in rest) else None)
              if rk is None:
                  continue
              key = (rk, -aland)
              if best is None or key < best[0]:
                  best = (key, lat, lon)
        if best:
            out.append(f"('{code}',{best[1]},{best[2]})")
        else:
            miss.append(title)
    psql("UPDATE pyramid_metro_areas a SET city_lat = v.lat, city_lon = v.lon FROM (VALUES "
         + ','.join(out) + ") AS v(code, lat, lon) WHERE a.cbsa_code = v.code;", stdin=True)
    print(f"{len(out)} metros got a city point, {len(miss)} without")
    for t in miss:
        print('  no match:', t)


if __name__ == '__main__':
    main()

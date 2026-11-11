#!/usr/bin/env python3
"""scripts/pyramid-load-tracts.py — load 2023 Census tracts into pyramid_tracts (mig 1283).
Owner 2026-11-11: "yes get more census data" — people tract by tract, so a
county the traced border splits counts on both sides, and each metro's
centre of population can be found.
Downloads (census.gov, public, no key):
  * 2023 Gazetteer tracts (internal point per tract)
  * ACS 2019-23 5-year table B01003 (total population per geography)
joins them by GEOID and replaces pyramid_tracts.  Connecticut's 2022+
planning-region tracts are placed in our 8 old counties by point-in-polygon.
Downloads go to a fresh temp directory (untrusted data, parsed as text only).
  python3 scripts/pyramid-load-tracts.py
"""
import csv
import io
import json
import os
import shlex
import subprocess
import tempfile
import urllib.request
import zipfile

PSQL = shlex.split(os.environ.get(
    'PSQL', 'sudo -n podman exec -i footballhome_db psql -U footballhome_user -d footballhome'))
GAZ = 'https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2023_Gazetteer/2023_Gaz_tracts_national.zip'
POP = 'https://www2.census.gov/programs-surveys/acs/summary_file/2023/table-based-SF/data/5YRData/acsdt5y2023-b01003.dat'


def psql(sql, stdin=False):
    args = PSQL + ['-At', '-v', 'ON_ERROR_STOP=1']
    if stdin:
        return subprocess.run(args, input=sql, text=True, capture_output=True, check=True).stdout
    return subprocess.run(args + ['-c', sql], text=True, capture_output=True, check=True, stdin=subprocess.DEVNULL).stdout


def get(url, path):
    req = urllib.request.Request(url, headers={'User-Agent': 'footballhome-pyramid/1.0'})
    with urllib.request.urlopen(req, timeout=300) as r, open(path, 'wb') as f:
        f.write(r.read())


def inside(x, y, ring):
    c = False
    for i in range(len(ring) - 1):
        x1, y1 = ring[i]
        x2, y2 = ring[i + 1]
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1:
            c = not c
    return c


def main():
    with tempfile.TemporaryDirectory() as d:
        get(GAZ, os.path.join(d, 'gaz.zip'))
        get(POP, os.path.join(d, 'pop.dat'))
        z = zipfile.ZipFile(os.path.join(d, 'gaz.zip'))
        rows = list(csv.reader(io.TextIOWrapper(z.open(z.namelist()[0])), delimiter='\t'))
        hdr = [h.strip() for h in rows[0]]
        gi, la, lo = hdr.index('GEOID'), hdr.index('INTPTLAT'), hdr.index('INTPTLONG')
        gaz = {r[gi].strip(): (float(r[la]), float(r[lo])) for r in rows[1:]}
        pop = {}
        with open(os.path.join(d, 'pop.dat')) as f:
            for line in f:
                if line.startswith('1400000US'):
                    g, e, _ = line.strip().split('|')
                    v = int(e) if e.lstrip('-').isdigit() else 0
                    pop[g[9:]] = max(v, 0)
    ours = set(psql('SELECT fips FROM pyramid_counties').split())
    ct = json.loads(psql("SELECT json_object_agg(fips, geometry) FROM pyramid_counties WHERE state = 'CT'"))
    out = []
    for g, (lat, lon) in gaz.items():
        if g not in pop:
            continue
        cf = g[:5]
        if cf.startswith('09'):
            cf = None
            for f, geo in ct.items():
                polys = [geo['coordinates']] if geo['type'] == 'Polygon' else geo['coordinates']
                if any(inside(lon, lat, p[0]) for p in polys):
                    cf = f
                    break
        if cf in ours:
            out.append(f"('{g}', '{cf}', {lat}, {lon}, {pop[g]})")
    sql = 'BEGIN;\nDELETE FROM pyramid_tracts;\n'
    for i in range(0, len(out), 5000):
        sql += 'INSERT INTO pyramid_tracts (geoid, county_fips, lat, lon, population) VALUES ' + ','.join(out[i:i + 5000]) + ';\n'
    sql += 'COMMIT;\n'
    psql(sql, stdin=True)
    print(f'{len(out)} tracts loaded ({sum(int(x.rsplit(",", 1)[1].rstrip(")")) for x in out):,} people)')


if __name__ == '__main__':
    main()

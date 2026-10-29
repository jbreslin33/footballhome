#!/usr/bin/env python3
"""Load US counties into pyramid_counties (mig 852) — the #apsl-pyramid map's
conference territories are built from them (population + distance).

Inputs (public data, downloaded by hand — not kept in git):
  counties.geojson  county shapes, Census cartographic boundaries
                    (https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json)
  pop.csv           Census county population estimates
                    (https://www2.census.gov/programs-surveys/popest/datasets/2020-2023/counties/totals/co-est2023-alldata.csv)
  pop2020.csv       optional: the 2010–2020 estimates, used for a county the
                    newer file no longer lists — Connecticut's 8 counties
                    became 9 planning regions in 2022 (new FIPS) while the
                    shapes keep the counties; a few others were renamed
                    (https://www2.census.gov/programs-surveys/popest/datasets/2010-2020/counties/totals/co-est2020-alldata.csv)

Writes SQL for psql on stdout (upsert by FIPS):

  python3 -I scripts/pyramid-counties-load.py counties.geojson pop.csv [pop2020.csv] \\
    | sudo podman exec -i footballhome_db psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1 -1

A county's centre = the area-weighted centroid of its largest polygon.
Neighbours (mig 860): two counties whose outlines share a border vertex
→ pyramid_county_neighbours (a main city's collar counties).
"""
import csv
import json
import sys

STATES = {
    '01': 'AL', '02': 'AK', '04': 'AZ', '05': 'AR', '06': 'CA', '08': 'CO', '09': 'CT', '10': 'DE', '11': 'DC',
    '12': 'FL', '13': 'GA', '15': 'HI', '16': 'ID', '17': 'IL', '18': 'IN', '19': 'IA', '20': 'KS', '21': 'KY',
    '22': 'LA', '23': 'ME', '24': 'MD', '25': 'MA', '26': 'MI', '27': 'MN', '28': 'MS', '29': 'MO', '30': 'MT',
    '31': 'NE', '32': 'NV', '33': 'NH', '34': 'NJ', '35': 'NM', '36': 'NY', '37': 'NC', '38': 'ND', '39': 'OH',
    '40': 'OK', '41': 'OR', '42': 'PA', '44': 'RI', '45': 'SC', '46': 'SD', '47': 'TN', '48': 'TX', '49': 'UT',
    '50': 'VT', '51': 'VA', '53': 'WA', '54': 'WV', '55': 'WI', '56': 'WY', '72': 'PR',
}


def ring_centroid(ring):
    """(area, cx, cy) of one ring (shoelace)."""
    a = cx = cy = 0.0
    for (x1, y1), (x2, y2) in zip(ring, ring[1:] + ring[:1]):
        f = x1 * y2 - x2 * y1
        a += f
        cx += (x1 + x2) * f
        cy += (y1 + y2) * f
    if abs(a) < 1e-12:
        xs, ys = [p[0] for p in ring], [p[1] for p in ring]
        return 0.0, sum(xs) / len(xs), sum(ys) / len(ys)
    return abs(a / 2), cx / (3 * a), cy / (3 * a)


def centre(geom):
    polys = geom['coordinates'] if geom['type'] == 'MultiPolygon' else [geom['coordinates']]
    best = max((ring_centroid(p[0]) for p in polys), key=lambda t: t[0])
    return best[2], best[1]   # lat, lon


def q(s):
    return "'" + str(s).replace("'", "''") + "'"


def read_pop(path, column):
    out = {}
    with open(path, newline='', encoding='latin-1') as f:
        for row in csv.DictReader(f):
            if row['SUMLEV'] == '050':
                out[row['STATE'] + row['COUNTY']] = (row['CTYNAME'], int(row[column]))
    return out


def main(geo_path, pop_path, pop2020_path=None):
    pop = read_pop(pop_path, 'POPESTIMATE2023')
    older = read_pop(pop2020_path, 'POPESTIMATE2020') if pop2020_path else {}
    with open(geo_path, encoding='utf-8') as f:
        features = json.load(f)['features']
    n = 0
    vertex_owners = {}
    for ft in features:
        p = ft['properties']
        fips = p['STATE'] + p['COUNTY']
        st = STATES.get(p['STATE'])
        if not st or not ft.get('geometry'):
            continue
        name, people = pop.get(fips) or older.get(fips) or (f"{p['NAME']} {p.get('LSAD', '')}".strip(), 0)
        lat, lon = centre(ft['geometry'])
        g = ft['geometry']
        for poly in (g['coordinates'] if g['type'] == 'MultiPolygon' else [g['coordinates']]):
            for ring in poly:
                for x, y in ring:
                    vertex_owners.setdefault((round(x, 4), round(y, 4)), set()).add(fips)
        print('INSERT INTO pyramid_counties (fips, name, state, population, lat, lon, geometry) VALUES '
              f"({q(fips)}, {q(name)}, {q(st)}, {people}, {lat:.7f}, {lon:.7f}, {q(json.dumps(ft['geometry'], separators=(',', ':')))}::jsonb) "
              'ON CONFLICT (fips) DO UPDATE SET name = EXCLUDED.name, state = EXCLUDED.state, population = EXCLUDED.population, '
              'lat = EXCLUDED.lat, lon = EXCLUDED.lon, geometry = EXCLUDED.geometry;')
        n += 1
    pairs = set()
    for owners in vertex_owners.values():
        if len(owners) > 1:
            for a in owners:
                for b in owners:
                    if a != b:
                        pairs.add((a, b))
    print('DELETE FROM pyramid_county_neighbours;')
    for a, b in sorted(pairs):
        print(f'INSERT INTO pyramid_county_neighbours (fips, neighbour) VALUES ({q(a)}, {q(b)}) ON CONFLICT DO NOTHING;')
    print(f'-- {n} counties, {len(pairs) // 2} borders', file=sys.stderr)


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else None)

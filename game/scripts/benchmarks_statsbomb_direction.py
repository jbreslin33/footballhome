#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_direction.py — where real passes and carries
go, by zone (game/DESIGN.md §8.102; James 11/2: "lets re model based on the data").

    benchmarks_statsbomb_direction.py <data dir> [out.json]

Open-play passes and carries, Premier League 2015/16, 380 matches, StatsBomb
Open Data (free with attribution). Zone = own, middle or final third of the
start point. Forward = gains 3 m+ toward goal, back = loses 3 m+, else square.
Pitch 120 x 80 scaled to 105 x 68.
"""
import collections, json, os, sys
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
d = sys.argv[1]
ms = json.load(open(os.path.join(d, "matches.json")))
P = collections.defaultdict(collections.Counter)
for m in ms:
    for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
        n = e["type"]["name"]
        if n == "Pass":
            if e["pass"].get("type", {}).get("name") in SET:
                continue
            end = e["pass"]["end_location"]
        elif n == "Carry":
            end = e["carry"]["end_location"]
        else:
            continue
        x0, x1 = e["location"][0] * 105 / 120, end[0] * 105 / 120
        y0, y1 = e["location"][1] * 68 / 80, end[1] * 68 / 80
        z = 0 if x0 < 35 else 1 if x0 < 70 else 2
        c = P[(n, z, bool(e.get("under_pressure")))]
        g = x1 - x0
        c["n"] += 1
        c["fwd" if g >= 3 else "back" if g <= -3 else "square"] += 1
        c["gain"] += g
        c["dist"] += ((x1 - x0) ** 2 + (y1 - y0) ** 2) ** 0.5
        c["ok"] += n == "Carry" or "outcome" not in e["pass"]
rows = []
print("kind  third   pressed      n a match  fwd% square%  back%  mean gain m  mean dist m")
for (n, z, p), c in sorted(P.items()):
    k = c["n"]
    r = dict(kind=n, third=z, pressed=p, per_team_match=round(k / len(ms) / 2, 1), fwd=round(100 * c["fwd"] / k, 1),
             square=round(100 * c["square"] / k, 1), back=round(100 * c["back"] / k, 1), gain=round(c["gain"] / k, 1), dist=round(c["dist"] / k, 1))
    rows.append(r)
    print(f"{n:5s} {['own','mid','final'][z]:6s} {'yes' if p else 'no ':6s} {r['per_team_match']:9.1f} {r['fwd']:6.1f} {r['square']:6.1f} {r['back']:6.1f} {r['gain']:10.1f} {r['dist']:11.1f}")
if len(sys.argv) > 2:
    json.dump(rows, open(sys.argv[2], "w"), indent=1)

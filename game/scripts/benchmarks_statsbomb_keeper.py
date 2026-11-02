#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_keeper.py — where a real keeper stands when
the shot is hit (game/DESIGN.md §8.102, concept narrow-angle).

    benchmarks_statsbomb_keeper.py <data dir>

Open-play shots with a keeper in the freeze frame, Premier League 2015/16, 380
matches, StatsBomb Open Data (free with attribution). Keeper depth = metres off
his goal line. Off line = metres from the straight line ball to goal centre.
Pitch 120 x 80 scaled to 105 x 68.
"""
import json, math, os, statistics as st, sys
d = sys.argv[1]
ms = json.load(open(os.path.join(d, "matches.json")))
B = [(0, 6), (6, 11), (11, 16), (16, 22), (22, 30), (30, 200)]
R = {b: [] for b in B}
for m in ms:
    for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] != "Open Play":
            continue
        k = next((p for p in e["shot"].get("freeze_frame", []) if p["position"]["name"] == "Goalkeeper" and not p["teammate"]), None)
        if not k:
            continue
        sx, sy = (120 - e["location"][0]) * 105 / 120, (e["location"][1] - 40) * 68 / 80
        kx, ky = (120 - k["location"][0]) * 105 / 120, (k["location"][1] - 40) * 68 / 80
        dist = math.hypot(sx, sy)
        off = abs(kx * sy - ky * sx) / dist if dist else 0
        R[next(b for b in B if b[0] <= dist < b[1])].append((kx, off, e["shot"]["outcome"]["name"] == "Goal"))
print("shot from m    n  keeper depth median p25 p75  off the line m  goal%")
for b, v in R.items():
    x = sorted(a[0] for a in v)
    q = st.quantiles(x, n=4)
    print(f"{b[0]:3d}-{b[1]:3d} {len(v):6d} {st.median(x):12.1f} {q[0]:6.1f} {q[2]:4.1f} {st.median(a[1] for a in v):12.1f} {100 * sum(a[2] for a in v) / len(v):7.1f}")

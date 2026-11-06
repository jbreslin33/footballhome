#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_blocks.py — bodies in the shot's lane, and how
often a real shot is blocked (game/DESIGN.md §8.138).

    python3 -I game/scripts/benchmarks_statsbomb_blocks.py <data dir>

Open-play shots with a freeze frame, Premier League 2015/16, 380 matches,
StatsBomb Open Data (free with attribution). Pitch 120 x 80 scaled to 105 x 68.
For each shot: the outfield opponents in its LANE — between the shooter and the
goal line, within W metres of the straight line from the ball to the centre of
the goal (W = 0.5 / 1 / 2). The distribution of that count, and the share of
shots blocked by count (the 1 m lane), and by distance band.
"""
import json, math, os, sys

d = sys.argv[1]
ms = json.load(open(os.path.join(d, "matches.json")))
W = (0.5, 1.0, 2.0)
tab = {w: {} for w in W}
nearest = []
near_shooter, goalside = [], 0
for m in ms:
    for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] != "Open Play":
            continue
        ff = e["shot"].get("freeze_frame")
        if not ff:
            continue
        sx, sy = e["location"][0] * 105 / 120, e["location"][1] * 68 / 80
        gx, gy = 105.0, 34.0
        L = math.hypot(gx - sx, gy - sy)
        if L < 1:
            continue
        ux, uy = (gx - sx) / L, (gy - sy) / L
        blocked = e["shot"]["outcome"]["name"] == "Blocked"
        dmin = 99.0
        for w in W:
            n = 0
            for p in ff:
                if p["teammate"] or p["position"]["name"] == "Goalkeeper":
                    continue
                px, py = p["location"][0] * 105 / 120 - sx, p["location"][1] * 68 / 80 - sy
                along = px * ux + py * uy
                perp = abs(-px * uy + py * ux)
                if 0 < along < L:
                    if perp < w:
                        n += 1
                    if w == W[0]:
                        dmin = min(dmin, perp)
            k = min(n, 3)
            c = tab[w].setdefault(k, [0, 0])
            c[0] += 1
            c[1] += blocked
        nearest.append(dmin)
        # the nearest outfield opponent to the shooter, and is he goal-side (nearer the goal line)
        best = None
        for p in ff:
            if p["teammate"] or p["position"]["name"] == "Goalkeeper":
                continue
            px, py = p["location"][0] * 105 / 120, p["location"][1] * 68 / 80
            dd = math.hypot(px - sx, py - sy)
            if best is None or dd < best[0]:
                best = (dd, px > sx)
        if best:
            near_shooter.append(best[0]); goalside += best[1]

for w in W:
    tot = sum(c[0] for c in tab[w].values())
    print(f"LANE ±{w} m: share of shots by bodies in it, and blocked % — " + "; ".join(
        f"{k}{'+' if k == 3 else ''}: {100 * tab[w][k][0] / tot:.1f}% blocked {100 * tab[w][k][1] / tab[w][k][0]:.1f}%"
        for k in sorted(tab[w])))
nearest.sort()
q = [nearest[int(len(nearest) * f)] for f in (0.25, 0.5, 0.75)]
print(f"nearest outfield opponent to the lane (between ball and goal): p25 {q[0]:.2f} m, median {q[1]:.2f}, p75 {q[2]:.2f} ({len(nearest)} shots)")

near_shooter.sort()
q = [near_shooter[int(len(near_shooter) * f)] for f in (0.25, 0.5, 0.75)]
print(f"nearest outfield opponent to the SHOOTER: p25 {q[0]:.2f} m, median {q[1]:.2f}, p75 {q[2]:.2f}; goal-side of him {100 * goalside / len(near_shooter):.0f}%")

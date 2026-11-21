#!/usr/bin/env python3
"""benchmarks_statsbomb_ownthird_dir.py — where real open-play passes from a side's own third go, 2015/16 Premier
League (G5.210, game/DESIGN.md §8.316): the real line for the harness's OWN-THIRD PASS DIRECTION.

    python3 -I game/scripts/benchmarks_statsbomb_ownthird_dir.py <events dir>

Open-play passes (pass.type none, Recovery or Interception — §8.263; corners, free kicks, throw-ins, goal kicks and
kick-offs out), not headed, from the passer's own third (< 35 m off his goal line), 5 m+ from kick to end. Outcomes
Pass Offside / Unknown / Injury Clearance dropped. By the passer's spot — outfield 0-18 / 18-35 m off his line x inside
(|y| < 20.16 m) / wide, and the keeper — a team-match, and the share that end in each zone: metres off THEIR goal
line 87+ / 70-87 / 52-70 / 35-52 / 0-35 x inside / wide (the end location: where it was received, cut out or went
out). Per zone: share of the origin's passes %, high % of them (StatsBomb High Pass; Ground + Low = ground, §8.313),
not completed % (Incomplete + Out). And by length 5-10 / 10-20 / 20-30 / 30-40 / 40-50 / 50+ m: share, high %, not
completed %. Pitch: StatsBomb 120 x 80 scaled to 105 x 68.

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Throw-in", "Goal Kick", "Kick Off")
ON = ("out 0-18 in", "out 0-18 wide", "out 18-35 in", "out 18-35 wide", "keeper")
ZN = ("87+ c", "87+ w", "70-87 c", "70-87 w", "52-70 c", "52-70 w", "35-52 c", "35-52 w", "0-35 c", "0-35 w")
LN = ("5-10", "10-20", "20-30", "30-40", "40-50", "50+")

files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
Z = collections.Counter(); L = collections.Counter(); N = collections.Counter()
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Pass" or "location" not in e: continue
        p = e["pass"]
        if p.get("type", {}).get("name") in SET or p.get("body_part", {}).get("name") == "Head": continue
        out = p.get("outcome", {}).get("name")
        if out not in (None, "Incomplete", "Out"): continue
        x0, y0 = e["location"][0] * SX, (e["location"][1] - 40) * SY
        if x0 >= 35: continue
        x1, y1 = p["end_location"][0] * SX, (p["end_location"][1] - 40) * SY
        d = math.hypot(x1 - x0, y1 - y0)
        if d < 5: continue
        o = 4 if e.get("position", {}).get("name") == "Goalkeeper" else (0 if x0 < 18 else 2) + (0 if abs(y0) < 20.16 else 1)
        tl = 105 - x1
        z = (0 if tl >= 87 else 1 if tl >= 70 else 2 if tl >= 52 else 3 if tl >= 35 else 4) * 2 + (0 if abs(y1) < 20.16 else 1)
        lb = 0 if d < 10 else min(5, int(d // 10))
        hi = p.get("height", {}).get("name") == "High Pass"
        N[o] += 1
        for C, k in ((Z, z), (L, lb)):
            C[(o, k, "n")] += 1; C[(o, k, "hi")] += hi; C[(o, k, "bad")] += out is not None
tm = 2 * len(files)
print(f"OWN-THIRD PASS DIRECTION — StatsBomb PL 15/16, {len(files)} matches, open play, not headed, 5 m+")
for o, on in enumerate(ON):
    n = max(1, N[o])
    print(f"  {on}: {N[o] / tm:.2f} a team-match — by end zone (m off THEIR line): share % | high % | not completed %")
    for z, zn in enumerate(ZN):
        k = max(1, Z[(o, z, 'n')])
        print(f"    {zn:8s} {100 * Z[(o, z, 'n')] / n:5.1f} | {100 * Z[(o, z, 'hi')] / k:5.1f} | {100 * Z[(o, z, 'bad')] / k:5.1f}")
    print("    by length m: share % | high % | not completed %")
    for b, bn in enumerate(LN):
        k = max(1, L[(o, b, 'n')])
        print(f"    {bn:8s} {100 * L[(o, b, 'n')] / n:5.1f} | {100 * L[(o, b, 'hi')] / k:5.1f} | {100 * L[(o, b, 'bad')] / k:5.1f}")
print("C++ rows {a team-match, then share/high/bad x 10 zones, then x 6 lengths}:")
for o in range(5):
    n = max(1, N[o])
    row = [f"{N[o] / tm:.2f}"]
    for C, m in ((Z, 10), (L, 6)):
        for k in range(m):
            kk = max(1, C[(o, k, 'n')])
            row += [f"{100 * C[(o, k, 'n')] / n:.1f}", f"{100 * C[(o, k, 'hi')] / kk:.0f}", f"{100 * C[(o, k, 'bad')] / kk:.0f}"]
    print("  {" + ", ".join(row) + "},")

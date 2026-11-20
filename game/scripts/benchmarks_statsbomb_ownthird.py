#!/usr/bin/env python3
"""benchmarks_statsbomb_ownthird.py — real own-third ground passes and how many the other side cuts out, 2015/16
Premier League (G5.205, game/DESIGN.md §8.311): the real line for the harness's OWN-THIRD PASS READ (§8.309).

    python3 -I game/scripts/benchmarks_statsbomb_ownthird.py <events dir>

Open-play passes (no pass.type: corners, free kicks, throw-ins, goal kicks, kick-offs out) from the passer's own
third (< 35 m off his goal line), StatsBomb height Ground Pass, 5 m+ long. A team-match each: attempted; completed;
lost = incomplete and the next on-ball event is the other side's, in play (Interception, Ball Recovery, Duel, Block,
Clearance, Pass, Carry, Dribble, Shot, Miscontrol); out = outcome Out. Also by the passer's metres off his line 0-18 /
18-35. Pitch: StatsBomb 120 x 80 scaled to 105 x 68.

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
ON_BALL = ("Interception", "Ball Recovery", "Duel", "Block", "Clearance", "Pass", "Carry", "Dribble", "Shot", "Miscontrol")

files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
C = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    for i, e in enumerate(ev):
        if e["type"]["name"] != "Pass" or "location" not in e: continue
        p = e["pass"]
        if "type" in p or p.get("height", {}).get("name") != "Ground Pass": continue
        x0 = e["location"][0] * SX
        if x0 >= 35: continue
        ex, ey = p["end_location"]
        if math.hypot((ex - e["location"][0]) * SX, (ey - e["location"][1]) * SY) < 5: continue
        z = 0 if x0 < 18 else 1
        C[("n", z)] += 1
        out = p.get("outcome", {}).get("name")
        if out is None: C[("ok", z)] += 1; continue
        if out == "Out": C[("out", z)] += 1; continue
        nxt = next((q for q in ev[i + 1:i + 8] if q["type"]["name"] in ON_BALL), None)
        if nxt is not None and nxt["team"]["id"] != e["team"]["id"]: C[("lost", z)] += 1
        else: C[("other", z)] += 1
tm = 2 * len(files)
print(f"OWN-THIRD GROUND PASSES 5 m+ — StatsBomb PL 15/16, {len(files)} matches, a team-match: attempted | completed | lost to them | out | other incomplete")
for z, zn in ((0, "0-18"), (1, "18-35"), (None, "all")):
    g = lambda k: (C[(k, 0)] + C[(k, 1)]) if z is None else C[(k, z)]
    n = max(1, g("n"))
    print(f"  {zn:5s} {g('n') / tm:6.2f} | {g('ok') / tm:6.2f} | {g('lost') / tm:5.2f} ({100 * g('lost') / n:.1f}%) | {g('out') / tm:5.2f} | {g('other') / tm:5.2f}")

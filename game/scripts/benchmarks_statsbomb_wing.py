#!/usr/bin/env python3
"""benchmarks_statsbomb_wing.py — which wing a pass into a wide zone goes to (G5.172, game/DESIGN.md §8.278).

    python3 -I game/scripts/benchmarks_statsbomb_wing.py <events dir>

The pass policy's zones as benchmarks_statsbomb_passes.py (StatsBomb PL 2015/16, open play, attempted): 5 depth bands
from their line × centre (|y| < 20.16 m) / wide. A wide zone holds both touchlines; this splits each origin zone's passes
into a wide end zone by the wing: the passer's own side of the pitch (the sign of his y) or the far one. Permille far.

§8.278: the game's policy split a wide zone's share evenly over the mates in it, both wings alike, so a far man on his
touchline was as likely a pick as a near one — ours switched 3.6-4.3% of completed passes with the far side's widest
man on his line (DFL 2.9) and 69-79% of those to him (39).
"""
import collections, glob, json, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
SX, SY = 105 / 120, 68 / 80
DEPTH = (18, 35, 52, 70)
NAMES = ("0-18", "18-35", "35-52", "52-70", "70+")
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")


def zone(x, y):
    d = (120 - x) * SX
    return sum(d >= t for t in DEPTH) * 2 + (0 if abs((y - 40) * SY) < 20.16 else 1)


files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[:-5].isdigit())
n = collections.Counter(); far = collections.Counter()
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Pass" or e["pass"].get("type", {}).get("name") in SET:
            continue
        p = e["pass"]; oy = e["location"][1] - 40; ey = p["end_location"][1] - 40
        o = zone(*e["location"]); d = zone(*p["end_location"])
        if d % 2 == 0 or oy == 0:
            continue
        n[(o, d)] += 1
        if (oy > 0) != (ey > 0):
            far[(o, d)] += 1
print(f"{len(files)} matches (StatsBomb PL 2015/16), open-play passes into a wide zone: permille to the FAR wing (n)")
print("   origin \\ end " + " ".join(f"{NAMES[d // 2]:>12s}" for d in range(1, 10, 2)))
for o in range(10):
    print(f"   {NAMES[o // 2]:5s} {'centre' if o % 2 == 0 else 'wide':6s} " + " ".join(
        f"{1000 * far[(o, d)] / n[(o, d)]:5.0f} ({n[(o, d)]:5d})" if n[(o, d)] else f"{'-':>12s}" for d in range(1, 10, 2)))
print("   C table: {" + ", ".join("{" + ", ".join(str(round(1000 * far[(o, d)] / n[(o, d)])) if n[(o, d)] >= 30 else "-1" for d in range(1, 10, 2)) + "}" for o in range(10)) + "}")

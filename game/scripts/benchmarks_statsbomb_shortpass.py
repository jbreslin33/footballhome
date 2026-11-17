#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_shortpass.py — the short pass, 2015/16 Premier League (G5.145,
game/DESIGN.md §8.249): open-play passes under 20 m a team-match by the passer's metres off THEIR line
(0-18 / 18-35 / 35-52 / 52-70 / 70+) x direction (forward within 45 deg of straight at their goal line,
back within 45 deg of straight at ours, else lateral), and completed %. Keepers left out. fh-game-match
prints the same as SHORT PASSES.

    benchmarks_statsbomb_shortpass.py <events dir>

Open play = every pass but corners, free kicks, goal kicks, kick-offs and throw-ins (as
benchmarks_statsbomb_concepts.py). Pitch: StatsBomb 120 x 80 scaled to 105 x 68. Data: StatsBomb Open
Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys

SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
SX, SY = 105 / 120, 68 / 80
files = [f for f in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))) if os.path.basename(f)[0].isdigit()]
n = collections.Counter(); ok = collections.Counter()
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Pass" or e.get("position", {}).get("name") == "Goalkeeper":
            continue
        p = e["pass"]
        if p.get("type", {}).get("name") in SET:
            continue
        (x0, y0), (x1, y1) = e["location"], p["end_location"]
        dx, dy = (x1 - x0) * SX, (y1 - y0) * SY
        if math.hypot(dx, dy) >= 20:
            continue
        d = (120 - x0) * SX
        b = sum(d >= t for t in (18, 35, 52, 70))
        a = math.degrees(math.atan2(abs(dy), dx))
        k = 0 if a <= 45 else 2 if a >= 135 else 1
        n[(b, k)] += 1
        if "outcome" not in p:
            ok[(b, k)] += 1
tm = 2 * len(files)
print(f"{len(files)} matches; SHORT PASSES (<20 m, open play, no keepers) a team-match, forward / lateral / back (completed %):")
for b, nm in enumerate(("0-18", "18-35", "35-52", "52-70", "70+")):
    print(f"   {nm:6s}" + "".join(f"  {n[(b, k)] / tm:5.1f} ({100 * ok[(b, k)] / max(1, n[(b, k)]):4.1f})" for k in range(3)))
print("   C init:", "{" + ", ".join("{" + ", ".join(f"{n[(b, k)] / tm:.1f}" for k in range(3)) + "}" for b in range(5)) + "}",
      "{" + ", ".join("{" + ", ".join(f"{100 * ok[(b, k)] / max(1, n[(b, k)]):.1f}" for k in range(3)) + "}" for b in range(5)) + "}")

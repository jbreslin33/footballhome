#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_passes.py — where real passes go, 2015/16 Premier League
(G5.25, game/DESIGN.md §8.123): the pass POLICY the game's on-ball state plays.

    benchmarks_statsbomb_passes.py <events dir>

Open-play passes (set pieces out), attempted (complete or not — the policy is the choice). The pitch
in 10 zones by the ball's distance from THEIR goal line (0-18, 18-35, 35-52, 52-70, 70+ m) × width
(central |y| < 20.16 m — the box's width — or wide). For each origin zone: passes a team-match from
it, and the share ending in each zone; the share lofted (StatsBomb height High) and crossed (the
cross flag). Plus a team-match's passes, completion, and the balls played into the box.

Pitch: StatsBomb 120 x 80 scaled to 105 x 68, attacking toward x = 120. Data: StatsBomb Open Data,
free with attribution to StatsBomb (github.com/statsbomb/open-data).
"""
import collections, glob, json, os, sys

SX, SY = 105 / 120, 68 / 80
DEPTH = (18, 35, 52, 70)          # metres from their line; 5 bands
NAMES = ("0-18", "18-35", "35-52", "52-70", "70+")


def zone(x, y):
    d = (120 - x) * SX
    b = sum(d >= t for t in DEPTH)
    w = 0 if abs((y - 40) * SY) < 20.16 else 1
    return b * 2 + w


def zname(z):
    return f"{NAMES[z // 2]} {'centre' if z % 2 == 0 else 'wide'}"


files = sorted(glob.glob(os.path.join(sys.argv[1], "*.json")))
n = collections.Counter()
to = collections.Counter()
loft = collections.Counter()
cross = collections.Counter()
total = complete = into_box = 0
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Pass":
            continue
        p = e["pass"]
        if p.get("type") is not None:      # corners, free kicks, throws, goal kicks, kick-offs
            continue
        o = zone(*e["location"])
        d = zone(*p["end_location"])
        n[o] += 1
        to[(o, d)] += 1
        if p.get("height", {}).get("name") == "High Pass":
            loft[o] += 1
        if p.get("cross"):
            cross[o] += 1
        total += 1
        if "outcome" not in p:
            complete += 1
        ex, ey = p["end_location"]
        if (120 - ex) * SX < 16.5 and abs((ey - 40) * SY) < 20.16 and not ((120 - e["location"][0]) * SX < 16.5 and abs((e["location"][1] - 40) * SY) < 20.16):
            into_box += 1
tm = 2 * len(files)
print(f"{len(files)} matches (StatsBomb PL 2015/16), open-play passes attempted")
print(f"PASSES a team-match {total / tm:.1f}, completed {100 * complete / total:.1f}%, into the box (from outside it) {into_box / tm:.2f}")
print("PASS POLICY (origin zone: passes a team-match | lofted | crossed | share to each end zone, m from their line):")
print("   end zones: " + " ".join(f"[{z}] {zname(z)}" for z in range(10)))
for o in range(10):
    if not n[o]:
        continue
    print(f"   {zname(o):12s} {n[o] / tm:6.1f} | loft {100 * loft[o] / n[o]:4.1f}% | cross {100 * cross[o] / n[o]:4.1f}% | "
          + " ".join(f"{100 * to[(o, d)] / n[o]:4.1f}" for d in range(10)))

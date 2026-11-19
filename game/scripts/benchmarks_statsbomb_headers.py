#!/usr/bin/env python3
"""benchmarks_statsbomb_headers.py — every header by spot: a clearance, a headed pass, or a shot (G5.181, game/DESIGN.md §8.287).

    python3 -I game/scripts/benchmarks_statsbomb_headers.py <PL 15/16 events dir>

StatsBomb PL 2015/16 (open data, attribution StatsBomb). A header = a Clearance with body part Head, a Pass with body
part Head (restarts excluded), or a headed Shot. Spot = m off the heading side's own goal line 0-6 / 6-18 / 18-35 /
35-52.5 / 52.5+ × |y| inside the box's width (20.16 m) or wide. Per spot: headers a team-match, the clearance share, the
headed passes' completion (no outcome = completed), median length and the share played forward (end x past start x).

§8.286: our headers within 35 m of our own goal are all clearances (World::headIt, physics.aerial.own_range_m 35);
ours from 18-35 m 12.7 headed clearances a team-match v StatsBomb's 3.3.
"""
import collections, glob, json, os, statistics, sys

SX, SY = 105 / 120, 68 / 80
BANDS = (6, 18, 35, 52.5)
DN = ("0-6", "6-18", "18-35", "35-52", "52+")


def band(x, y):
    d = x * SX
    a = next((i for i, b in enumerate(BANDS) if d < b), len(BANDS))
    return a, 0 if abs((y - 40) * SY) < 20.16 else 1


files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[:-5].isdigit())
n = collections.Counter(); kind = collections.Counter(); comp = collections.Counter(); fwd = collections.Counter()
plen = collections.defaultdict(list)
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        t = e["type"]["name"]
        if t == "Clearance" and e.get("clearance", {}).get("body_part", {}).get("name") == "Head":
            k = "clear"
        elif t == "Pass" and e["pass"].get("body_part", {}).get("name") == "Head" and e["pass"].get("type", {}).get("name") not in ("Throw-in", "Corner", "Free Kick", "Goal Kick", "Kick Off"):
            k = "pass"
        elif t == "Shot" and e["shot"].get("body_part", {}).get("name") == "Head":
            k = "shot"
        else:
            continue
        b = band(*e["location"]); n[b] += 1; kind[(b, k)] += 1
        if k == "pass":
            p = e["pass"]
            comp[b] += "outcome" not in p
            fwd[b] += p["end_location"][0] > e["location"][0]
            plen[b].append(p["length"] * SX)
tm = 2 * len(files)
print(f"{len(files)} matches: headers {sum(n.values()) / tm:.2f} a team-match (clear {sum(v for (b, k), v in kind.items() if k == 'clear') / tm:.2f}, "
      f"pass {sum(v for (b, k), v in kind.items() if k == 'pass') / tm:.2f}, shot {sum(v for (b, k), v in kind.items() if k == 'shot') / tm:.2f})")
print("  spot          headers a tm | clear % | headed passes a tm, completed %, median m, forward %")
for b in sorted(n):
    np_ = kind[(b, "pass")]
    print(f"  {DN[b[0]]:5s} {'wide' if b[1] else 'inside':6s} {n[b] / tm:6.2f} | {100 * kind[(b, 'clear')] / n[b]:5.1f} | "
          f"{np_ / tm:5.2f}, {100 * comp[b] / max(1, np_):4.1f}, {statistics.median(plen[b]) if plen[b] else 0:4.1f}, {100 * fwd[b] / max(1, np_):4.1f}")

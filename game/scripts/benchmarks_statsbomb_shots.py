#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_shots.py — real shots, 2015/16 Premier League (G5.23,
game/DESIGN.md §8.121): the same cuts as fh-game-match's SHOTS line.

    benchmarks_statsbomb_shots.py <events dir>

Per team-match: shots (penalties out — the game has none) and goals from them; the share by
distance to the goal centre (<12 / 12-18 / 18-25 / 25+ m) and the goals per shot in each; how each
shot ended (goal; saved by the keeper; blocked; off target = off target, wayward, post); StatsBomb
xG per shot by band. The decision behind it: of the times a player in that distance band let the
ball go (pass, shot, clearance — open play), the share that were shots.

Pitch: StatsBomb 120 x 80 scaled to 105 x 68, the goal at x = 120 (the attacking end). Data:
StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data).
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
BANDS = ("<12 m", "12-18", "18-25", "25+")
OUT = ("goal", "keeper", "blocked", "off target")


def band(x, y):
    d = math.hypot((120 - x) * SX, (40 - y) * SY)
    return 0 if d < 12 else 1 if d < 18 else 2 if d < 25 else 3


def outcome(name):
    if name == "Goal":
        return 0
    if name in ("Saved", "Saved to Post", "Saved Off Target"):
        return 1
    if name == "Blocked":
        return 2
    return 3


files = sorted(glob.glob(os.path.join(sys.argv[1], "*.json")))
shots = goals = 0
by_band = [0] * 4
goal_band = [0] * 4
xg_band = [0.0] * 4
out = [0] * 4
rel = [0] * 5        # balls let go: <12, 12-18, 18-25, 25-35, 35+
rel_shot = [0] * 5


def rband(x, y):
    d = math.hypot((120 - x) * SX, (40 - y) * SY)
    return 0 if d < 12 else 1 if d < 18 else 2 if d < 25 else 3 if d < 35 else 4
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        t = e["type"]["name"]
        loc = e.get("location")
        if not loc:
            continue
        if t == "Shot":
            s = e["shot"]
            if s.get("type", {}).get("name") == "Penalty":
                continue
            b = band(*loc)
            shots += 1
            by_band[b] += 1
            xg_band[b] += s.get("statsbomb_xg", 0.0)
            o = outcome(s["outcome"]["name"])
            out[o] += 1
            if o == 0:
                goals += 1
                goal_band[b] += 1
            if s.get("type", {}).get("name") == "Open Play":
                rel[rband(*loc)] += 1
                rel_shot[rband(*loc)] += 1
        elif t in ("Pass", "Clearance") and e.get("play_pattern", {}).get("name") != "From Corner":
            if t == "Pass" and e["pass"].get("type") is not None:   # set pieces out
                continue
            rel[rband(*loc)] += 1
tm = 2 * len(files)
print(f"{len(files)} matches (StatsBomb PL 2015/16), penalties out")
print(f"SHOTS a team-match {shots / tm:.1f}, goals {goals / tm:.2f}, {100 * goals / shots:.1f}% scored; by distance: "
      + " ".join(f"{BANDS[i]} {100 * by_band[i] / shots:.0f}% (scored {100 * goal_band[i] / max(1, by_band[i]):.1f}%, xG {xg_band[i] / max(1, by_band[i]):.3f});" for i in range(4)))
print("   how they ended: " + " ".join(f"{OUT[i]} {100 * out[i] / shots:.1f}%;" for i in range(4)))
print("   of the balls let go in open play (pass, shot, clearance), the share that were shots: "
      + " ".join(f"{b} {100 * rel_shot[i] / max(1, rel[i]):.1f}% (of {rel[i] / tm:.1f} a team-match);" for i, b in enumerate(("<12 m", "12-18", "18-25", "25-35", "35+"))))

# The shot POLICY (G5.23): of the balls let go in open play at a spot, the share that were
# shots — by distance (<12, 12-18, 18-25, 25-35 m) × the goal mouth's angle from there
# (<0.25, 0.25-0.5, 0.5+ rad; Law 1 goal 7.32 m). The game reads this table (physics.shot.*).
def angle(x, y):
    gx, gy = 105.0, 34.0
    px, py = x * SX, y * SY
    a1 = math.atan2(gy - 3.66 - py, gx - px)
    a2 = math.atan2(gy + 3.66 - py, gx - px)
    return abs(a2 - a1)


pol = collections.Counter()
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        t = e["type"]["name"]
        loc = e.get("location")
        if not loc:
            continue
        shot = t == "Shot" and e["shot"].get("type", {}).get("name") == "Open Play"
        if not shot:
            if t not in ("Pass", "Clearance") or e.get("play_pattern", {}).get("name") == "From Corner":
                continue
            if t == "Pass" and e["pass"].get("type") is not None:
                continue
        r = rband(*loc)
        if r > 3:
            continue
        a = angle(*loc)
        ab = 0 if a < 0.25 else 1 if a < 0.5 else 2
        pol[(r, ab)] += 1
        if shot:
            pol[("s", r, ab)] += 1
print("   SHOT POLICY: share of open-play releases that are shots, distance × goal angle (n):")
for r, b in enumerate(("<12 m", "12-18", "18-25", "25-35")):
    print(f"     {b:6s} " + "  ".join(f"angle {lab}: {100 * pol[('s', r, ab)] / max(1, pol[(r, ab)]):5.1f}% ({pol[(r, ab)]})"
                                    for ab, lab in enumerate(("<0.25", "0.25-0.5", "0.5+"))))

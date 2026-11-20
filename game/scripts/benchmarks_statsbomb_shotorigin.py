#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_shotorigin.py — where real shots come from, by distance band (G5.185,
game/DESIGN.md §8.291): the same cuts as fh-game-match's SHOT ORIGIN line.

    python3 -I benchmarks_statsbomb_shotorigin.py <events dir>

Every shot (penalties out), by distance to the goal centre (<12 / 12-18 / 18-25 / 25+ m) and by origin:
  direct fk — the free kick itself shot (StatsBomb shot type Free Kick)
  corner / free kick / throw-in — an open-play shot in a possession that began at that restart
                (StatsBomb play_pattern From Corner / From Free Kick / From Throw In; a possession runs until the
                other side has the ball, not on a deflection)
  other     — the rest (Regular Play, From Counter, From Goal Kick, From Keeper, From Kick Off, Other)
Per cell: shots a team-match, goals per shot; and per origin the median seconds from the possession's first event
to the shot (how long after the restart). Ours keys a possession the same way: it ends when the other side has a
man on the ball.

Pitch: StatsBomb 120 x 80 scaled to 105 x 68, the goal at x = 120. Data: StatsBomb Open Data, free with attribution
to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import glob, json, math, os, statistics, sys

SX, SY = 105 / 120, 68 / 80
BANDS = ("<12", "12-18", "18-25", "25+")
ORIG = ("direct fk", "corner", "free kick", "throw-in", "other")
PAT = {"From Corner": 1, "From Free Kick": 2, "From Throw In": 3}


def band(x, y):
    d = math.hypot((120 - x) * SX, (40 - y) * SY)
    return 0 if d < 12 else 1 if d < 18 else 2 if d < 25 else 3


def secs(e):
    h, m, s = e["timestamp"].split(":")
    return int(h) * 3600 + int(m) * 60 + float(s)


n = [[0] * 4 for _ in ORIG]
g = [[0] * 4 for _ in ORIG]
dt = [[] for _ in ORIG]
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())   # match event files only
for f in files:
    ev = json.load(open(f))
    first = {}
    for e in ev:
        if "possession" in e and "timestamp" in e:
            first.setdefault((e["period"], e["possession"]), secs(e))
    for e in ev:
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] == "Penalty":
            continue
        st = e["shot"]["type"]["name"]
        o = 0 if st == "Free Kick" else PAT.get(e["play_pattern"]["name"], 4)
        b = band(*e["location"][:2])
        n[o][b] += 1
        g[o][b] += e["shot"]["outcome"]["name"] == "Goal"
        dt[o].append(secs(e) - first[(e["period"], e["possession"])])

tm = 2 * len(files)
print(f"SHOT ORIGIN — StatsBomb PL 15/16, {len(files)} matches; shots a team-match [goals per shot %] by band")
print(f"{'origin':11s}" + "".join(f"{b:>18s}" for b in BANDS) + f"{'all':>18s}{'median s':>10s}")
for o, name in enumerate(ORIG):
    cells = [f"{n[o][b] / tm:7.2f} [{100 * g[o][b] / max(1, n[o][b]):5.1f}%]  " for b in range(4)]
    tot, tg = sum(n[o]), sum(g[o])
    print(f"{name:11s}" + "".join(f"{c:>18s}" for c in cells) + f"{tot / tm:7.2f} [{100 * tg / max(1, tot):5.1f}%]  "
          + f"{statistics.median(dt[o]) if dt[o] else 0:8.1f}")
for b in range(4):
    tb = sum(n[o][b] for o in range(5))
    print(f"  {BANDS[b]:6s} share of the band's shots: " + ", ".join(f"{ORIG[o]} {100 * n[o][b] / max(1, tb):.1f}%" for o in range(5))
          + f"; of its goals: " + ", ".join(f"{ORIG[o]} {100 * g[o][b] / max(1, sum(g[q][b] for q in range(5))):.1f}%" for o in range(5)))

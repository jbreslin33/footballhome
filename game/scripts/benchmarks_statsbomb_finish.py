#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_finish.py — how a real shot ends, by the defence it is struck
against (G5.122, game/DESIGN.md §8.223).

    python3 -I game/scripts/benchmarks_statsbomb_finish.py <events dir>

Open-play shots with a freeze frame, Premier League 2015/16 (StatsBomb Open Data, free with
attribution; github.com/statsbomb/open-data). Pitch 120 x 80 scaled to 105 x 68, goal centre
(105, 34). GOAL-SIDE as benchmarks_statsbomb_shotcontext.py (outfield opponents nearer the goal
centre than the shooter, 0 / 1 / 2 / 3 / 4+). For each count, and for each distance band
(<12 / 12-18 / 18-25 / 25+ m) x goal-side 0-1 / 2-3 / 4+: the shots' end — goal / saved /
blocked / off target (Off T, Wayward, Post) — and the keeper's save % of the on-target ones,
and the keeper's distance off his goal line (median). fh-game-match prints the same as FINISH.
FH original.
"""
import collections, glob, json, math, os, statistics, sys

SX, SY = 105 / 120, 68 / 80
GX, GY = 105.0, 34.0
KIND = {"Goal": 0, "Saved": 1, "Saved To Post": 1, "Saved Off Target": 1, "Blocked": 2}


def band(d):
    return 0 if d < 12 else 1 if d < 18 else 2 if d < 25 else 3


by_gs = collections.defaultdict(lambda: [0, 0, 0, 0])
by_bg = collections.defaultdict(lambda: [0, 0, 0, 0])
gk_off = collections.defaultdict(list)
files = [f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit()]
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] != "Open Play":
            continue
        ff = e["shot"].get("freeze_frame")
        if not ff:
            continue
        sx, sy = e["location"][0] * SX, e["location"][1] * SY
        ds = math.hypot(GX - sx, GY - sy)
        g = sum(1 for q in ff if not q["teammate"] and q["position"]["name"] != "Goalkeeper"
                and math.hypot(GX - q["location"][0] * SX, GY - q["location"][1] * SY) < ds)
        k = KIND.get(e["shot"]["outcome"]["name"], 3)
        gk, b = min(g, 4), band(ds)
        gg = 0 if g <= 1 else 1 if g <= 3 else 2
        by_gs[gk][k] += 1
        by_bg[(b, gg)][k] += 1
        for q in ff:
            if not q["teammate"] and q["position"]["name"] == "Goalkeeper":
                gk_off[(b, gg)].append(GX - q["location"][0] * SX)


def row(v):
    n = sum(v)
    sv = 100 * v[1] / max(1, v[0] + v[1])
    return f"n {n:5d} | {' / '.join(f'{100 * x / max(1, n):4.1f}' for x in v)} | saves {sv:4.1f}%"


print(f"{len(files)} matches (StatsBomb PL 2015/16) FINISH: goal / saved / blocked / off target %, keeper saves % of on target")
for k in range(5):
    print(f"  goal-side {k}{'+' if k == 4 else ' '}  {row(by_gs[k])}")
lab, gl = ("<12", "12-18", "18-25", "25+"), ("0-1", "2-3", "4+")
for b in range(4):
    for gg in range(3):
        v = by_bg[(b, gg)]
        o = gk_off[(b, gg)]
        print(f"  {lab[b]:>5} m, goal-side {gl[gg]:>3}  {row(v)} | keeper off his line median {statistics.median(o) if o else 0:.1f} m")

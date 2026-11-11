#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_shotcontext.py — the defence a real shot is struck against
(G5.85, game/DESIGN.md §8.186).

    python3 -I game/scripts/benchmarks_statsbomb_shotcontext.py <events dir>

Open-play shots with a freeze frame, Premier League 2015/16 (StatsBomb Open Data, free with
attribution; github.com/statsbomb/open-data). Pitch 120 x 80 scaled to 105 x 68, the goal centre
at (105, 34). For each shot: GOAL-SIDE = the outfield opponents nearer the goal centre than the
shooter; the count 0 / 1 / 2 / 3 / 4+ and the shots' goal % by it; the seconds since the shooting
side's possession began (StatsBomb `possession` — its first event) in 0-5 / 5-10 / 10-20 / 20+ s
bins and the goal-side median by bin. fh-game-match prints the same as SHOT CONTEXT. FH original.
"""
import collections, glob, json, math, os, statistics, sys

SX, SY = 105 / 120, 68 / 80
GX, GY = 105.0, 34.0
TB = (5, 10, 20)


def secs(ts):
    h, m, s = ts.split(":")
    return int(h) * 3600 + int(m) * 60 + float(s)


n = 0
gs = collections.Counter(); gs_goal = collections.Counter()
tb = collections.Counter(); tb_goal = collections.Counter(); tb_gs = collections.defaultdict(list)
bd_gs = collections.defaultdict(list)
files = [f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit()]
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    start = {}
    for e in ev:
        k = (e["period"], e["possession"])
        if k not in start:
            start[k] = secs(e["timestamp"])
    for e in ev:
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] != "Open Play":
            continue
        ff = e["shot"].get("freeze_frame")
        if not ff:
            continue
        sx, sy = e["location"][0] * SX, e["location"][1] * SY
        ds = math.hypot(GX - sx, GY - sy)
        g = sum(1 for q in ff if not q["teammate"] and q["position"]["name"] != "Goalkeeper"
                and math.hypot(GX - q["location"][0] * SX, GY - q["location"][1] * SY) < ds)
        goal = e["shot"]["outcome"]["name"] == "Goal"
        gk = min(g, 4)
        n += 1; gs[gk] += 1; gs_goal[gk] += goal
        t = secs(e["timestamp"]) - start[(e["period"], e["possession"])]
        b = sum(t >= x for x in TB)
        db = 0 if ds < 12 else 1 if ds < 18 else 2 if ds < 25 else 3
        bd_gs[db].append(g)
        tb[b] += 1; tb_goal[b] += goal; tb_gs[b].append(g)
tm = 2 * len(files)
print(f"{len(files)} matches (StatsBomb PL 2015/16): SHOT CONTEXT, {n} open-play shots ({n / tm:.1f} a team-match)")
print("  GOAL-SIDE outfield opponents (nearer the goal centre than the shooter) 0/1/2/3/4+: share % [goal %]: " +
      ", ".join(f"{k}{'+' if k == 4 else ''} {100 * gs[k] / n:.1f} [{100 * gs_goal[k] / max(1, gs[k]):.1f}]" for k in range(5)))
lab = ("0-5", "5-10", "10-20", "20+")
print("  SINCE THE POSSESSION BEGAN, s: share % [goal %] {goal-side median}: " +
      ", ".join(f"{lab[b]} {100 * tb[b] / n:.1f} [{100 * tb_goal[b] / max(1, tb[b]):.1f}] {{{statistics.median(tb_gs[b]) if tb_gs[b] else 0:.0f}}}" for b in range(4)))
bl = ("<12", "12-18", "18-25", "25+")
print("  GOAL-SIDE by the shot's distance: share of shots % / goal-side p25 / median / p75: " +
      ", ".join(f"{bl[b]} {100 * len(bd_gs[b]) / n:.0f} / {sorted(bd_gs[b])[len(bd_gs[b]) // 4]} / {statistics.median(bd_gs[b]):.0f} / {sorted(bd_gs[b])[3 * len(bd_gs[b]) // 4]}" for b in range(4)))

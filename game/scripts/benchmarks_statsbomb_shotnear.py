#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_shotnear.py — the nearest outfield defender to a real shooter at the strike: how
far, and whether he is goal-side (nearer his own goal line than the shooter), by the shot's distance (G5.264,
game/DESIGN.md §8.370).

    python3 -I game/scripts/benchmarks_statsbomb_shotnear.py <PL 15/16 events dir>

Open-play shots with a freeze frame, Premier League 2015/16 (StatsBomb Open Data, free with attribution to StatsBomb;
github.com/statsbomb/open-data). Pitch 120 x 80 scaled to 105 x 68. Bands <12 / 12-18 / 18-25 / 25+ m, then all.
fh-game-match prints ours on the "nearest outfield opponent to the SHOOTER" line. FH original.
"""
import collections, glob, json, math, os, sys
SX, SY = 105/120, 68/80
R = collections.defaultdict(list)
for f in glob.glob(os.path.join(sys.argv[1], "*.json")):
    if not os.path.basename(f)[0].isdigit(): continue
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] != "Open Play" or "freeze_frame" not in e["shot"]: continue
        x, y = e["location"]; d = math.hypot((120-x)*SX, (40-y)*SY)
        b = 0 if d < 12 else 1 if d < 18 else 2 if d < 25 else 3
        best = None
        for q in e["shot"]["freeze_frame"]:
            if q["teammate"] or q["position"]["name"] == "Goalkeeper": continue
            dd = math.hypot((q["location"][0]-x)*SX, (q["location"][1]-y)*SY)
            if best is None or dd < best[0]: best = (dd, q["location"][0] > x)
        if best: R[b].append(best); R[9].append(best)
print("band (0 <12, 1 12-18, 2 18-25, 3 25+, 9 all)  n  nearest p25/med/p75  goal-side  | within 3 m goal-side")
for b in (0,1,2,3,9):
    v = R[b]; ds = sorted(a for a,_ in v)
    near = [g for a,g in v if a < 3]
    print(b, len(v), "near p25/med/p75 %.2f/%.2f/%.2f" % (ds[len(ds)//4], ds[len(ds)//2], ds[3*len(ds)//4]), "goal-side %.1f%%" % (100*sum(g for _,g in v)/len(v)), "| within 3 m goal-side %.1f%% of %d" % (100*sum(near)/max(1,len(near)), len(near)))

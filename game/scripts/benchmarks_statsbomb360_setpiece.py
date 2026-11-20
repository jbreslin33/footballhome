#!/usr/bin/env python3
"""benchmarks_statsbomb360_setpiece.py — who is in the box when a corner or free kick is struck (G5.183, game/DESIGN.md §8.289).

    python3 -I game/scripts/benchmarks_statsbomb360_setpiece.py <open360 dir>

StatsBomb Open Data 360 (all men's sets under open360/<comp>_<season>/, attribution StatsBomb): at each Corner pass and each
Free Kick pass taken 18-52 m off their goal line, the freeze frame. Kept only when the visible area holds the whole penalty
box's core (penalty spot, the six-yard box's corners, the box's front edge middle and its two front corners pulled 6 m in) —
the full box is out of view at most corners. Counts in their penalty box (StatsBomb x >= 102, 18 <= y <= 62): the kicking
side's outfielders (taker out) and the defending side's outfielders (keeper out); and the defenders inside the six-yard box
(x >= 114, 30 <= y <= 50). Free kicks split by where the pass ends: into the box or not. A count is a floor where a player
stood out of view.

§8.288: our free kicks into the box are headed by a defender 11% (real 41%) — taken 1.3 s after the taker reaches it,
nobody holding a set-piece shape.
"""
import collections, glob, json, os, statistics, sys


def inside(poly, x, y):   # ray cast
    c = False
    for (x1, y1), (x2, y2) in zip(poly, poly[1:] + poly[:1]):
        if (y1 > y) != (y2 > y) and x < x1 + (y - y1) * (x2 - x1) / (y2 - y1):
            c = not c
    return c


CORE = [(108, 40), (114, 30), (114, 50), (119, 30), (119, 50), (103, 40), (103, 25), (103, 55)]
SX = 105 / 120
rows = collections.defaultdict(list)   # kind -> [(att, def, def6, att25, def25)]
skipped = collections.Counter()
for d in sorted(glob.glob(os.path.join(sys.argv[1], "*_*"))):
    for f in glob.glob(os.path.join(d, "events_*.json")):
        mid = os.path.basename(f)[7:-5]
        ff = os.path.join(d, f"360_{mid}.json")
        if not os.path.exists(ff):
            continue
        frames = {r["event_uuid"]: r for r in json.load(open(ff, encoding="utf8"))}
        for e in json.load(open(f, encoding="utf8")):
            if e["type"]["name"] != "Pass":
                continue
            pt = e["pass"].get("type", {}).get("name")
            if pt not in ("Corner", "Free Kick"):
                continue
            x0, _ = e["location"]; x1, y1 = e["pass"]["end_location"]
            if pt == "Corner":
                k = "corner"
            else:
                off = (120 - x0) * SX
                if not 18 <= off < 52.5:
                    continue
                into = x1 >= 102 and 18 <= y1 <= 62
                k = ("fk 18-35" if off < 35 else "fk 35-52") + (" into box" if into else " not")
            r = frames.get(e["id"])
            if not r:
                skipped["no frame"] += 1; continue
            poly = [tuple(r["visible_area"][i:i + 2]) for i in range(0, len(r["visible_area"]) - 1, 2)]
            if not all(inside(poly, bx, by) for bx, by in CORE):
                skipped["box not in view"] += 1; continue
            att = dfn = d6 = a25 = f25 = 0
            for p in r["freeze_frame"]:
                if p.get("actor") or p.get("keeper"):
                    continue
                px, py = p["location"]
                if (120 - px) * SX < 25 and 18 <= py <= 62:   # within 25 m of their line, the box's width
                    if p["teammate"]: a25 += 1
                    else: f25 += 1
                if px >= 102 and 18 <= py <= 62:
                    if p["teammate"]: att += 1
                    else:
                        dfn += 1; d6 += px >= 114 and 30 <= py <= 50
            rows[k].append((att, dfn, d6, a25, f25))
print("StatsBomb 360 set pieces with the whole box in view (skipped:", dict(skipped), ")")
print("  kind                 n     | in their box at the kick: attackers mean (p25-p75) | defenders mean (p25-p75) | defenders in the 6-yd box | within 25 m (box's width): attackers, defenders")
for k in sorted(rows):
    v = rows[k]
    q = lambda a: (statistics.mean(a), *statistics.quantiles(a, n=4)[::2]) if len(a) > 3 else (statistics.mean(a), 0, 0)
    a = q([t[0] for t in v]); b = q([t[1] for t in v]); c = statistics.mean(t[2] for t in v)
    print(f"  {k:20s} {len(v):5d} | {a[0]:4.1f} ({a[1]:.0f}-{a[2]:.0f}) | {b[0]:4.1f} ({b[1]:.0f}-{b[2]:.0f}) | {c:4.1f} | {statistics.mean(t[3] for t in v):4.1f}, {statistics.mean(t[4] for t in v):4.1f}")

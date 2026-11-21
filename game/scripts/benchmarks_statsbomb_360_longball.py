#!/usr/bin/env python3
"""benchmarks_statsbomb_360_longball.py — where the long high pass from the back lands, off the men standing there at
the kick (G5.211, game/DESIGN.md §8.317): the passes-only check on benchmarks_tracking_longball.py (DFL tracking can't
tell a pass from a clearance).

    python3 -I game/scripts/benchmarks_statsbomb_360_longball.py <open360 dir>

StatsBomb Open Data's men's competitions with 360 freeze frames (every visible player at the event). Open-play passes
(no set-piece pass.type), height High Pass, not headed, by an outfielder, from his own third (< 35 m off his line),
30 m+ from kick to end_location (where it was received, cut out or went out), the end inside the frame's visible
area. Against the freeze frame AT THE KICK: the passer's outfield mate nearest the end point (3 m+ off the passer) —
the end point's metres off him, on toward their goal (+) and across; and the nearest opponent outfielder to it. By
length 30-40 / 40-50 / 50+ m, with the completed share. Pitch 120 x 80 scaled to 105 x 68.
Data: StatsBomb Open Data, free with attribution to StatsBomb. FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")

def inside(poly, x, y):
    n = len(poly) // 2; c = False; j = n - 1
    for i in range(n):
        xi, yi, xj, yj = poly[2 * i], poly[2 * i + 1], poly[2 * j], poly[2 * j + 1]
        if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi: c = not c
        j = i
    return c

R = collections.defaultdict(list); seen = collections.Counter()
for d in sorted(glob.glob(os.path.join(sys.argv[1], "*_*"))):
    for f in glob.glob(os.path.join(d, "360_*.json")):
        mid = os.path.basename(f)[4:]
        ev = {e["id"]: e for e in json.load(open(os.path.join(d, "events_" + mid), encoding="utf8"))}
        for fr in json.load(open(f, encoding="utf8")):
            e = ev.get(fr["event_uuid"])
            if not e or e["type"]["name"] != "Pass": continue
            p = e["pass"]
            if p.get("type", {}).get("name") in SET or p.get("height", {}).get("name") != "High Pass" or p.get("body_part", {}).get("name") == "Head": continue
            if e.get("position", {}).get("name") == "Goalkeeper" or e["location"][0] * SX >= 35: continue
            x0, y0 = e["location"]; x1, y1 = p["end_location"][:2]
            L = math.hypot((x1 - x0) * SX, (y1 - y0) * SY)
            if L < 30: continue
            b = 0 if L < 40 else 1 if L < 50 else 2
            seen[(b, "n")] += 1
            if not inside(fr["visible_area"], x1, y1): continue
            seen[(b, "vis")] += 1
            mates = [q["location"] for q in fr["freeze_frame"] if q["teammate"] and not q.get("actor") and not q.get("keeper")
                     and math.hypot((q["location"][0] - x0) * SX, (q["location"][1] - y0) * SY) >= 3]
            opps = [math.hypot((q["location"][0] - x1) * SX, (q["location"][1] - y1) * SY) for q in fr["freeze_frame"] if not q["teammate"] and not q.get("keeper")]
            if not mates: continue
            m = min(mates, key=lambda q: math.hypot((q[0] - x1) * SX, (q[1] - y1) * SY))
            rec = (math.hypot((m[0] - x1) * SX, (m[1] - y1) * SY), (x1 - m[0]) * SX, abs(y1 - m[1]) * SY, min(opps) if opps else 99, "outcome" not in p)
            R[b].append(rec); R[3].append(rec)
q = lambda w, f: sorted(w)[int(f * len(w))] if w else -1
print("LONG HIGH PASS FROM THE BACK — StatsBomb 360 (open play, outfield, own third, 30 m+, end in view), at the kick:")
print("  length: n (of all such passes, end in view %) | completed % | the end off the passer's mate nearest it: m p25/med/p75 | on toward their goal med (p25, p75), 5 m+ beyond him %, 5 m+ short % | across med | nearest opponent to the end med")
for b, bn in enumerate(("30-40", "40-50", "50+", "all")):
    v = R[b]; n = max(1, len(v))
    tot = sum(seen[(i, "n")] for i in range(3)) if b == 3 else seen[(b, "n")]; vis = sum(seen[(i, "vis")] for i in range(3)) if b == 3 else seen[(b, "vis")]
    print(f"  {bn:6s} {len(v)} ({tot}, {100 * vis / max(1, tot):.0f}%) | {100 * sum(r[4] for r in v) / n:.0f} | {q([r[0] for r in v], .25):.1f}/{q([r[0] for r in v], .5):.1f}/{q([r[0] for r in v], .75):.1f} | "
          f"{q([r[1] for r in v], .5):+.1f} ({q([r[1] for r in v], .25):+.1f}, {q([r[1] for r in v], .75):+.1f}), {100 * sum(r[1] >= 5 for r in v) / n:.0f}%, {100 * sum(r[1] <= -5 for r in v) / n:.0f}% | {q([r[2] for r in v], .5):.1f} | {q([r[3] for r in v], .5):.1f}")

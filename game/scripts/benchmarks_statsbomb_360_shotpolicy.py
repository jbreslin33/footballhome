#!/usr/bin/env python3
"""benchmarks_statsbomb_360_shotpolicy.py — the shot policy by distance x goal angle x goal-side crowd (G5.198,
game/DESIGN.md §8.304).

    python3 -I game/scripts/benchmarks_statsbomb_360_shotpolicy.py <open360 dir>

Every open-play release in StatsBomb Open Data's men's 360 sets (a pass — no corner, free kick, goal kick, kick-off,
throw-in — or an open-play shot), by the ball's distance to the goal centre (<12 / 12-18 / 18-25 / 25-35 m), the goal
mouth's angle from the ball (<0.25 / 0.25-0.5 / 0.5+ rad, as Possession's shot_p) and GOAL-SIDE = visible opponent
outfielders nearer the goal centre than the ball (0-1 / 2-3 / 4-5 / 6+): releases and the share that were shots, as a
C++ table (permille) for physics.shot.crowd (Possession). Cells under 30 releases fall back to the (distance, angle)
share. Pitch 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data, free with attribution to StatsBomb. FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
GH = 7.32 / 2


def main():
    N = collections.Counter(); S = collections.Counter(); M = 0
    for d in sorted(glob.glob(os.path.join(sys.argv[1], "*_*"))):
        if not os.path.isdir(d): continue
        for f in glob.glob(os.path.join(d, "360_*.json")):
            mid = os.path.basename(f)[4:]
            ev = json.load(open(os.path.join(d, "events_" + mid), encoding="utf8")); by = {e["id"]: e for e in ev}; M += 1
            for fr in json.load(open(f, encoding="utf8")):
                e = by.get(fr["event_uuid"])
                if not e or "location" not in e: continue
                t = e["type"]["name"]
                if t == "Pass":
                    if e["pass"].get("type", {}).get("name") in SET: continue
                    sh = False
                elif t == "Shot":
                    if e["shot"]["type"]["name"] != "Open Play": continue
                    sh = True
                else: continue
                bx, by_ = (120 - e["location"][0]) * SX, (e["location"][1] - 40) * SY   # m off their line, across
                db = math.hypot(bx, by_)
                b = 0 if db < 12 else 1 if db < 18 else 2 if db < 25 else 3 if db < 35 else -1
                if b < 0: continue
                ang = abs(math.atan2(GH - by_, bx) - math.atan2(-GH - by_, bx))
                a = 0 if ang < 0.25 else 1 if ang < 0.5 else 2
                g = sum(1 for p in fr["freeze_frame"] if not p["teammate"] and not p.get("keeper")
                        and math.hypot((120 - p["location"][0]) * SX, (p["location"][1] - 40) * SY) < db)
                k = 0 if g <= 1 else 1 if g <= 3 else 2 if g <= 5 else 3
                for key in ((b, a, k), (b, a, -1)):
                    N[key] += 1; S[key] += sh
    print(f"// {M} matches; P(shot | release) permille [distance][angle][goal-side 0-1/2-3/4-5/6+]; n in comments")
    print("static const int kShotCrowd[4][3][4] = {")
    for b in range(4):
        rows = []
        for a in range(3):
            base = S[(b, a, -1)] / N[(b, a, -1)] if N[(b, a, -1)] else 0
            cells = [round(1000 * (S[(b, a, k)] / N[(b, a, k)] if N[(b, a, k)] >= 30 else base)) for k in range(4)]
            rows.append("{" + ", ".join(str(c) for c in cells) + "}")
            print(f"    // d{b} a{a}: n " + " / ".join(str(N[(b, a, k)]) for k in range(4)) + f"; all {1000 * base:.0f}")
        print("    {" + ", ".join(rows) + "},")
    print("};")


if __name__ == "__main__":
    main()

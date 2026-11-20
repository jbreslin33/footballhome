#!/usr/bin/env python3
"""benchmarks_statsbomb_360_shotchoice.py — does a pro shoot more with men in the way, or less? (G5.186,
game/DESIGN.md §8.292)

    python3 -I game/scripts/benchmarks_statsbomb_360_shotchoice.py <open360 dir>

Every open-play release in StatsBomb Open Data's men's 360 sets: a pass (no corner, free kick, goal kick, kick-off,
throw-in) or an open-play shot. From its freeze frame, GOAL-SIDE = the visible opponent outfielders nearer their goal
centre than the ball (as fh-game-match's SHOT CONTEXT and benchmarks_statsbomb_shotcontext.py). By the ball's distance
to the goal centre (<12 / 12-18 / 18-25 / 25-35 m) × goal-side (0-1 / 2-3 / 4-5 / 6+): releases, and the share that
were shots. Then each cell's share over its band's share — the multiplier on the band's shot policy for that crowd.
Broadcast frames can hide a man off camera; near goal the box is nearly always in view. Pitch 120 x 80 scaled to
105 x 68. Data: StatsBomb Open Data, free with attribution to StatsBomb. FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
BANDS = ("<12", "12-18", "18-25", "25-35")
GS = ("0-1", "2-3", "4-5", "6+")


def band(d):
    return 0 if d < 12 else 1 if d < 18 else 2 if d < 25 else 3 if d < 35 else -1


def gsb(g):
    return 0 if g <= 1 else 1 if g <= 3 else 2 if g <= 5 else 3


def main():
    N = collections.Counter(); S = collections.Counter(); matches = 0
    for d in sorted(glob.glob(os.path.join(sys.argv[1], "*_*"))):
        if not os.path.isdir(d): continue
        for f in glob.glob(os.path.join(d, "360_*.json")):
            mid = os.path.basename(f)[4:]
            ev = json.load(open(os.path.join(d, "events_" + mid), encoding="utf8"))
            byid = {e["id"]: e for e in ev}
            matches += 1
            for fr in json.load(open(f, encoding="utf8")):
                e = byid.get(fr["event_uuid"])
                if not e or "location" not in e: continue
                t = e["type"]["name"]
                if t == "Pass":
                    if e["pass"].get("type", {}).get("name") in SET: continue
                    shot = False
                elif t == "Shot":
                    if e["shot"]["type"]["name"] != "Open Play": continue
                    shot = True
                else:
                    continue
                bx, by = e["location"][:2]
                db = math.hypot((120 - bx) * SX, (40 - by) * SY)
                b = band(db)
                if b < 0: continue
                g = sum(1 for p in fr["freeze_frame"] if not p["teammate"] and not p.get("keeper")
                        and math.hypot((120 - p["location"][0]) * SX, (40 - p["location"][1]) * SY) < db)
                k = gsb(g)
                N[(b, k)] += 1; S[(b, k)] += shot; N[(b, -1)] += 1; S[(b, -1)] += shot
    print(f"SHOT CHOICE BY GOAL-SIDE — StatsBomb 360, {matches} matches; open-play releases (passes + shots): n | shot % | x the band's")
    for b in range(4):
        base = S[(b, -1)] / max(1, N[(b, -1)])
        cells = []
        for k in range(4):
            n = N[(b, k)]; s = S[(b, k)] / max(1, n)
            cells.append(f"{GS[k]} {n:6d} {100 * s:5.1f}% x{s / base if base else 0:4.2f}")
        print(f"  {BANDS[b]:5s} all {N[(b, -1)]:6d} {100 * base:5.1f}% | " + " | ".join(cells))


if __name__ == "__main__":
    main()

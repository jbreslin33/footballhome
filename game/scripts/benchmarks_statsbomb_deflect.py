#!/usr/bin/env python3
"""benchmarks_statsbomb_deflect.py — where a blocked ball goes (G5.163, game/DESIGN.md §8.269).

    python3 -I game/scripts/benchmarks_statsbomb_deflect.py <PL 15/16 events dir>

StatsBomb Open Data, Premier League 2015/16, every match. A blocked SHOT (Shot outcome Blocked, open play, its Block
event linked) and a blocked PASS (a Block event whose related event is a Pass): the ball's line in (striker → the
blocker) and out (the blocker → the next located event (within 90 s: a restart comes ~30 s after the ball goes out) that is not the Block itself, a Ball Receipt or a
Pressure — the next touch, or the restart's spot when it went out). The turn = the angle between in and out, 0° =
carried straight on, 180° = straight back; by 0-45 / 45-90 / 90-135 / 135-180 (pooled over sides). How far it went
(m to that next spot, median; its time). And how it ended: behind for a corner (the next event a Corner of the
attacking side) / out for a throw-in / the attackers' / the defenders'. fh-game-match's body block draws its turn
from these bins. Pitch 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data, free with attribution. FH original.
"""
import collections, glob, json, math, os, statistics, sys

SX, SY = 105 / 120, 68 / 80
SKIP = ("Block", "Ball Receipt*", "Pressure", "Duel", "Foul Committed", "Foul Won")


def secs(e):
    h, m, s = e["timestamp"].split(":")
    return e["period"] * 10000 + int(h) * 3600 + int(m) * 60 + float(s)


def main():
    R = {k: {"turn": collections.Counter(), "dist": [], "end": collections.Counter(), "n": 0} for k in ("shot", "pass")}
    for f in glob.glob(os.path.join(sys.argv[1], "*.json")):
        if not os.path.basename(f)[0].isdigit(): continue
        ev = json.load(open(f, encoding="utf8"))
        byid = {e["id"]: e for e in ev}
        for i, e in enumerate(ev):
            if e["type"]["name"] != "Block" or "location" not in e: continue
            rel = [byid[r] for r in e.get("related_events", []) if r in byid]
            src = next((r for r in rel if r["type"]["name"] in ("Shot", "Pass") and "location" in r), None)
            if src is None: continue
            kind = "shot" if src["type"]["name"] == "Shot" else "pass"
            if kind == "shot" and (src["shot"]["outcome"]["name"] != "Blocked" or src["shot"].get("type", {}).get("name") != "Open Play"): continue
            if kind == "pass" and src["pass"].get("type", {}).get("name") in ("Corner", "Free Kick", "Throw-in", "Goal Kick", "Kick Off"): continue
            # the blocker's spot in the attacker's frame: StatsBomb locations are each team's own frame (attacking +x)
            bx, by = 120 - e["location"][0], 80 - e["location"][1]
            sx, sy = src["location"]
            t0 = secs(e)
            nxt = None
            for g in ev[i + 1:i + 25]:
                if secs(g) - t0 > 90: break
                if g["type"]["name"] in SKIP or "location" not in g: continue
                if src["id"] in g.get("related_events", []) and g["type"]["name"] == "Goal Keeper": continue   # "shot faced": no touch
                nxt = g; break   # the next touch — or, after the ball went out (a restart ~30 s on), the restart
            if nxt is None: continue
            gx, gy = nxt["location"]
            if nxt["team"]["id"] != src["team"]["id"]: gx, gy = 120 - gx, 80 - gy
            vin = ((bx - sx) * SX, (by - sy) * SY); vout = ((gx - bx) * SX, (gy - by) * SY)
            li, lo = math.hypot(*vin), math.hypot(*vout)
            if li < 0.5 or lo < 0.5: continue
            c = max(-1, min(1, (vin[0] * vout[0] + vin[1] * vout[1]) / (li * lo)))
            ang = math.degrees(math.acos(c))
            r = R[kind]; r["n"] += 1; r["turn"][min(3, int(ang // 45))] += 1; r["dist"].append(lo)
            pt = nxt.get("pass", {}).get("type", {}).get("name") if nxt["type"]["name"] == "Pass" else None
            end = ("corner" if pt == "Corner" and nxt["team"]["id"] == src["team"]["id"] else
                   "throw-in" if pt == "Throw-in" else
                   "goal kick" if pt == "Goal Kick" else
                   "attackers" if nxt["team"]["id"] == src["team"]["id"] else "defenders")
            r["end"][end] += 1
    print("StatsBomb PL 2015/16: BLOCKED BALLS — the turn off the body (0 = straight on, 180 = straight back), how far, how it ended")
    for k in ("shot", "pass"):
        r = R[k]; n = max(1, r["n"])
        print(f"  {k:4s} {r['n']:5d}: turn 0-45 / 45-90 / 90-135 / 135-180 " + " / ".join(f"{100 * r['turn'][b] / n:.1f}" for b in range(4))
              + f"% | to the next touch med {statistics.median(r['dist']):.1f} m | ended: "
              + ", ".join(f"{e} {100 * r['end'][e] / n:.1f}%" for e in ("corner", "throw-in", "goal kick", "attackers", "defenders")))


if __name__ == "__main__":
    main()

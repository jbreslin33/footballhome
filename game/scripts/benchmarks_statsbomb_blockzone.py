#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_blockzone.py — open-play passes an opponent got a body to (an opponent's Block
among the pass's related events), 2015/16 Premier League, by where the pass was struck: within 14 m of a touchline
(wide) or not, and metres off the line attacked 0-18 / 18-35 / 35-52 / 52-70 / 70+ — a team-match, and of them the
share after which play restarts with a throw-in or a corner (the next event of another possession is one), and whose.
(G5.243, game/DESIGN.md §8.349.) fh-game-match prints the same as BLOCKED BY WHERE.
G5.244 (§8.350) BLOCKED BY THE TOUCHLINE — passes struck within 5 m / 5-14 m of a touchline: all of them and the
blocked ones by the pass's direction (down the line = within 30° of straight at the line attacked | forward inside |
square inside 60-120° | back | toward the touchline), the blocked share, the share of blocks then out; and the
blocker's spot off the passer: m, and ahead of him down the line (within 30°) / inside / behind.
WHICH WAY OFF THE BLOCK — from the block's spot to the next located event that is not the Block, a Ball Receipt, a
Pressure, a Duel or a foul (the next touch, or the restart's spot when it went out; within 60 s): the share that
went TOWARD the nearer touchline (its y nearer that line than the block's by 1 m+) / along (within 1 m) / away, by the
block's m off that touchline 0-5 / 5-10 / 10-20 / 20+; and the same for the nearer goal line by m off it.

    benchmarks_statsbomb_blockzone.py <events dir>

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
files = [f for f in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))) if os.path.basename(f)[0].isdigit()]
C = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8")); byid = {e["id"]: e for e in ev}
    for i, e in enumerate(ev):
        if e["type"]["name"] != "Pass" or e["pass"].get("type", {}).get("name") in SET: continue
        x, y = e["location"][0] * SX, e["location"][1] * SY
        tl = 105 - x; z = 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4; w = int(abs(y - 34) >= 20)
        C[("n", w, z)] += 1; C[("nx", w, z)] += bool(e["pass"].get("cross"))
        tch = 34 - abs(y - 34); tb = 0 if tch < 5 else 1 if tch < 14 else 2
        ex, ey = e["pass"]["end_location"][0] * SX, e["pass"]["end_location"][1] * SY
        sd = 1 if y > 34 else -1   # +1: his touchline is at y = 68
        def dirof(dx, dy):   # dx toward the line attacked, dy toward his touchline
            a = math.degrees(math.atan2(dy, dx))
            return 4 if 30 < a < 150 else 0 if abs(a) <= 30 else 1 if -60 <= a < -30 else 2 if -120 <= a < -60 else 3
        d = dirof(ex - x, (ey - y) * sd); hi = e["pass"].get("height", {}).get("name") == "High Pass"
        if tb < 2: C[("tn", tb, d)] += 1; C[("tnh", tb, d)] += hi
        if not any(r in byid and byid[r]["type"]["name"] == "Block" and byid[r]["team"]["id"] != e["team"]["id"] for r in e.get("related_events", [])): continue
        C[("b", w, z)] += 1; C[("bx", w, z)] += bool(e["pass"].get("cross"))
        blk = next(byid[r] for r in e.get("related_events", []) if r in byid and byid[r]["type"]["name"] == "Block" and byid[r]["team"]["id"] != e["team"]["id"])
        if tb < 2:
            C[("tb", tb, d)] += 1
            if "location" in blk:   # the blocker's location is in HIS side's frame: flip it
                bx, by = (120 - blk["location"][0]) * SX, (80 - blk["location"][1]) * SY
                dd = math.hypot(bx - x, by - y); C[("tbd", tb, 0 if dd < 2 else 1 if dd < 4 else 2)] += 1
                C[("tbs", tb, dirof(bx - x, (by - y) * sd))] += 1; C[("tbn", tb)] += 1
        if "location" in blk:
            bx, by = (120 - blk["location"][0]) * SX, (80 - blk["location"][1]) * SY
            j = ev.index(blk) if blk in ev[i:i + 6] else i
            nx = next((n for n in ev[i + 1:i + 14] if n is not blk and "location" in n and n["type"]["name"] not in ("Block", "Ball Receipt*", "Pressure", "Duel", "Foul Committed", "Foul Won") and n["period"] == e["period"]), None)
            if nx is not None:
                qx, qy = nx["location"][0] * SX, nx["location"][1] * SY
                if nx["team"]["id"] != e["team"]["id"]: qx, qy = 105 - qx, 68 - qy
                tt = 34 - abs(by - 34); tb4 = 0 if tt < 5 else 1 if tt < 10 else 2 if tt < 20 else 3
                dy = (qy - by) * (1 if by > 34 else -1); C[("wy", tb4, 0 if dy >= 1 else 2 if dy <= -1 else 1)] += 1
                gl = min(bx, 105 - bx); gb4 = 0 if gl < 5 else 1 if gl < 10 else 2 if gl < 20 else 3
                dx = (qx - bx) * (1 if bx > 52.5 else -1); C[("wx", gb4, 0 if dx >= 1 else 2 if dx <= -1 else 1)] += 1
        nxt = next((n for n in ev[i + 1:i + 12] if n["type"]["name"] == "Pass" and n["possession"] != e["possession"]), None)
        nx2 = next((n for n in ev[i + 1:i + 12] if n["possession"] != e["possession"]), None)
        kind = nxt["pass"].get("type", {}).get("name") if nxt is not None and nx2 is not None and nxt["possession"] == nx2["possession"] else None
        if kind in ("Throw-in", "Corner") and tb < 2: C[("to", tb, d)] += 1
        if kind in ("Throw-in", "Corner"): C[(kind, w, z)] += 1; C[(kind + (" ours" if nxt["team"]["id"] == e["team"]["id"] else " theirs"), w)] += 1
tm = 2 * len(files)
print(f"BLOCKED BY WHERE — StatsBomb PL 15/16, {len(files)} matches: open-play passes a team-match / with an opponent's Block / then a throw-in / then a corner, by m off the line attacked 0-18 / 18-35 / 35-52 / 52-70 / 70+")
for w, nm in ((1, "wide"), (0, "middle")):
    print(f"  {nm}: " + " | ".join(f"{C[('n', w, z)] / tm:.1f} / {C[('b', w, z)] / tm:.2f} / {C[('Throw-in', w, z)] / tm:.2f} / {C[('Corner', w, z)] / tm:.2f}" for z in range(5))
          + f" || all {sum(C[('b', w, z)] for z in range(5)) / tm:.2f} blocked, throw-in ours / theirs {C[('Throw-in ours', w)] / tm:.2f} / {C[('Throw-in theirs', w)] / tm:.2f}, corner {C[('Corner ours', w)] / tm:.2f}")
print("C++ row: {" + ", ".join(f"{C[(kk, w, z)] / tm:.2f}" for w in (1, 0) for z in range(5) for kk in ("b", "Throw-in", "Corner")) + "}")
dn = ["down the line", "forward inside", "square inside", "back", "toward the touchline"]
for tb, nm in ((0, "0-5 m off the touchline"), (1, "5-14 m")):
    print(f"BLOCKED BY THE TOUCHLINE, kick {nm}: passes a team-match (high %) / blocked (% of them) / of the blocked out % — " + " | ".join(
        f"{dn[d]} {C[('tn', tb, d)] / tm:.1f} ({100 * C[('tnh', tb, d)] / max(1, C[('tn', tb, d)]):.0f}) / {C[('tb', tb, d)] / tm:.2f} ({100 * C[('tb', tb, d)] / max(1, C[('tn', tb, d)]):.1f}) / {100 * C[('to', tb, d)] / max(1, C[('tb', tb, d)]):.0f}" for d in range(5)))
    n = max(1, C[("tbn", tb)])
    print(f"   the blocker off the passer: 0-2 / 2-4 / 4+ m {100 * C[('tbd', tb, 0)] / n:.0f} / {100 * C[('tbd', tb, 1)] / n:.0f} / {100 * C[('tbd', tb, 2)] / n:.0f}% | " + " ".join(f"{dn[d]} {100 * C[('tbs', tb, d)] / n:.0f}%" for d in range(5)))
for kk, nm in (("wy", "touchline"), ("wx", "goal line")):
    print(f"WHICH WAY OFF THE BLOCK, by the block's m off the nearer {nm} 0-5 / 5-10 / 10-20 / 20+: toward it / along / away % (n) — " + " | ".join(
        (lambda t: f"{100 * C[(kk, b4, 0)] / t:.0f} / {100 * C[(kk, b4, 1)] / t:.0f} / {100 * C[(kk, b4, 2)] / t:.0f} ({t})")(max(1, sum(C[(kk, b4, i)] for i in range(3)))) for b4 in range(4)))
print(f"CROSSES (StatsBomb's cross flag) from the wide last 18 m / 18-35 m: {C[('nx', 1, 0)] / tm:.2f} / {C[('nx', 1, 1)] / tm:.2f} a team-match, blocked {C[('bx', 1, 0)] / tm:.2f} / {C[('bx', 1, 1)] / tm:.2f}")

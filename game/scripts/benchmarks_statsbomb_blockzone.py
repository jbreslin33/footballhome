#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_blockzone.py — open-play passes an opponent got a body to (an opponent's Block
among the pass's related events), 2015/16 Premier League, by where the pass was struck: within 14 m of a touchline
(wide) or not, and metres off the line attacked 0-18 / 18-35 / 35-52 / 52-70 / 70+ — a team-match, and of them the
share after which play restarts with a throw-in or a corner (the next event of another possession is one), and whose.
(G5.243, game/DESIGN.md §8.349.) fh-game-match prints the same as BLOCKED BY WHERE.

    benchmarks_statsbomb_blockzone.py <events dir>

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, os, sys

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
        C[("n", w, z)] += 1
        if not any(r in byid and byid[r]["type"]["name"] == "Block" and byid[r]["team"]["id"] != e["team"]["id"] for r in e.get("related_events", [])): continue
        C[("b", w, z)] += 1
        nxt = next((n for n in ev[i + 1:i + 12] if n["type"]["name"] == "Pass" and n["possession"] != e["possession"]), None)
        nx2 = next((n for n in ev[i + 1:i + 12] if n["possession"] != e["possession"]), None)
        kind = nxt["pass"].get("type", {}).get("name") if nxt is not None and nx2 is not None and nxt["possession"] == nx2["possession"] else None
        if kind in ("Throw-in", "Corner"): C[(kind, w, z)] += 1; C[(kind + (" ours" if nxt["team"]["id"] == e["team"]["id"] else " theirs"), w)] += 1
tm = 2 * len(files)
print(f"BLOCKED BY WHERE — StatsBomb PL 15/16, {len(files)} matches: open-play passes a team-match / with an opponent's Block / then a throw-in / then a corner, by m off the line attacked 0-18 / 18-35 / 35-52 / 52-70 / 70+")
for w, nm in ((1, "wide"), (0, "middle")):
    print(f"  {nm}: " + " | ".join(f"{C[('n', w, z)] / tm:.1f} / {C[('b', w, z)] / tm:.2f} / {C[('Throw-in', w, z)] / tm:.2f} / {C[('Corner', w, z)] / tm:.2f}" for z in range(5))
          + f" || all {sum(C[('b', w, z)] for z in range(5)) / tm:.2f} blocked, throw-in ours / theirs {C[('Throw-in ours', w)] / tm:.2f} / {C[('Throw-in theirs', w)] / tm:.2f}, corner {C[('Corner ours', w)] / tm:.2f}")
print("C++ row: {" + ", ".join(f"{C[(kk, w, z)] / tm:.2f}" for w in (1, 0) for z in range(5) for kk in ("b", "Throw-in", "Corner")) + "}")

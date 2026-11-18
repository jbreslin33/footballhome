#!/usr/bin/env python3
"""benchmarks_statsbomb_shotpast.py — shots struck past the defence, and what set them up (G5.160, DESIGN §8.265).

    python3 -I game/scripts/benchmarks_statsbomb_shotpast.py <PL 15/16 events dir>

StatsBomb Open Data, Premier League 2015/16, every open-play shot (penalties and direct free kicks out) with its
freeze frame. Goal-side = outfield opponents nearer the goal centre than the shooter (as
benchmarks_statsbomb_shotcontext.py). By goal-side 0-1 / 2-3 / 4+: share of shots, goals per shot, and what set
the shot up — the key pass (shot.key_pass_id) by kind: through ball, cross, cut-back, other pass; or none (a
carry, a rebound, a loose ball). fh-game-match prints the same as SHOTS PAST THE DEFENCE. Data: StatsBomb Open
Data, free with attribution to StatsBomb. FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
KINDS = ("through ball", "cross", "cut-back", "other pass", "no pass")


def kind_of(p):
    if p is None: return 4
    q = p["pass"]
    if q.get("through_ball") or q.get("technique", {}).get("name") == "Through Ball": return 0
    if q.get("cut_back"): return 2
    if q.get("cross"): return 1
    return 3


if __name__ == "__main__":
    n = collections.Counter(); g = collections.Counter(); k = collections.Counter()
    for f in glob.glob(os.path.join(sys.argv[1], "*.json")):
        if not os.path.basename(f)[0].isdigit(): continue
        ev = json.load(open(f, encoding="utf8"))
        byid = {e["id"]: e for e in ev}
        for e in ev:
            if e["type"]["name"] != "Shot": continue
            s = e["shot"]
            if s.get("type", {}).get("name") != "Open Play" or "freeze_frame" not in s: continue
            x, y = e["location"]
            d0 = math.hypot((120 - x) * SX, (40 - y) * SY)
            gs = sum(1 for p in s["freeze_frame"] if not p["teammate"] and p.get("position", {}).get("name") != "Goalkeeper"
                     and math.hypot((120 - p["location"][0]) * SX, (40 - p["location"][1]) * SY) < d0)
            b = 0 if gs <= 1 else 1 if gs <= 3 else 2
            n[b] += 1; g[b] += s["outcome"]["name"] == "Goal"
            k[(b, kind_of(byid.get(s.get("key_pass_id"))))] += 1
    tot = sum(n.values())
    print(f"StatsBomb PL 2015/16: {tot} open-play shots with a freeze frame. SHOTS PAST THE DEFENCE, by goal-side outfielders:")
    for b, nm in enumerate(("0-1", "2-3", "4+")):
        print(f"  {nm:3s}: {100 * n[b] / tot:4.1f}% of shots, goal {100 * g[b] / max(1, n[b]):4.1f}% | set up by "
              + " / ".join(f"{KINDS[i]} {100 * k[(b, i)] / max(1, n[b]):.0f}%" for i in range(5)))

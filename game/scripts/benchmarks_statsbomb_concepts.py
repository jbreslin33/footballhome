#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_concepts.py — how often real 2015/16 Premier League sides
do the things a concept makes a player do, where StatsBomb tags the act itself (G5.17,
game/DESIGN.md §8.114). These are the rates the "Premier League 2015/16" model's concept
demands are set from: a demand is right when the game does the act as often as the league.

    benchmarks_statsbomb_concepts.py <events dir>

Per team-match (380 matches, both sides):
  * pressures, and the counter-press share (StatsBomb's own flag: pressure within 5 s of the
    team losing the ball) — counter-press (16), press-as-unit (68)
  * open-play passes; switches (StatsBomb: a pass travelling 50%+ of the pitch width) —
    switch-play (57); crosses — cross concepts; cut-backs (99); through balls — pass-ladder (29),
    over-top (6)
  * dribbles tried / completed — beat-man-1v1 (35)
  * return passes: A → B, then B's next pass (same possession, within 5 s, set pieces out) back
    to A — give-and-go (14), wall-pass (65)
  * carries that gain 10 m+ toward goal — drive-into-space (59)
Pitch: StatsBomb 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data, free with attribution
to StatsBomb (github.com/statsbomb/open-data).
"""
import collections, glob, json, os, sys

SX = 105 / 120
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")


def one(path):
    ev = json.load(open(path, encoding="utf8"))
    c = collections.Counter()
    teams = {e["team"]["name"] for e in ev if "team" in e}
    passes = []
    for e in ev:
        t = e["type"]["name"]
        if t == "Pressure":
            c["press"] += 1
            if e.get("counterpress"): c["cpress"] += 1
        elif t == "Pass":
            p = e["pass"]
            if p.get("type", {}).get("name") in SET: continue
            c["pass"] += 1
            if p.get("switch"): c["switch"] += 1
            if p.get("cross"): c["cross"] += 1
            if p.get("cut_back"): c["cutback"] += 1
            if p.get("through_ball") or p.get("technique", {}).get("name") == "Through Ball": c["through"] += 1
            passes.append(e)
        elif t == "Dribble":
            c["drib"] += 1
            if e["dribble"].get("outcome", {}).get("name") == "Complete": c["dribok"] += 1
        elif t == "Carry":
            a, b = e["location"], e["carry"]["end_location"]
            if (b[0] - a[0]) * SX >= 10: c["carry10"] += 1
    # return passes: B's next open-play pass after receiving from A goes back to A
    by_poss = collections.defaultdict(list)
    for e in passes: by_poss[e["possession"]].append(e)
    t = lambda e: e["minute"] * 60 + e["second"]
    for ps in by_poss.values():
        for i, a in enumerate(ps):
            r = a["pass"].get("recipient")
            if not r or "outcome" in a["pass"]: continue      # completed passes only
            nxt = next((b for b in ps[i + 1:] if b["player"]["id"] == r["id"]), None)
            if nxt is None or ps.index(nxt) != i + 1 or t(nxt) - t(a) > 5: continue
            c["recv_then_pass"] += 1
            if nxt["pass"].get("recipient", {}).get("id") == a["player"]["id"]: c["return"] += 1
    c["team_matches"] += len(teams)
    return c


files = sorted(glob.glob(os.path.join(sys.argv[1], "*.json")))
c = collections.Counter()
for f in files: c.update(one(f))
tm = c["team_matches"]
print(f"{len(files)} matches, {tm} team-matches (StatsBomb, Premier League 2015/16), per team-match:")
print(f"  pressures {c['press']/tm:.1f}, counter-press {c['cpress']/tm:.1f} ({100*c['cpress']/max(1,c['press']):.1f}% of pressures)")
print(f"  open-play passes {c['pass']/tm:.1f}: switches {c['switch']/tm:.2f}, crosses {c['cross']/tm:.2f}, cut-backs {c['cutback']/tm:.2f}, through balls {c['through']/tm:.2f}")
print(f"  dribbles {c['drib']/tm:.2f} tried, {c['dribok']/tm:.2f} completed ({100*c['dribok']/max(1,c['drib']):.0f}%)")
print(f"  return passes {c['return']/tm:.2f} ({100*c['return']/max(1,c['recv_then_pass']):.1f}% of passes made straight after a receipt within 5 s)")
print(f"  carries gaining 10 m+ {c['carry10']/tm:.2f}")

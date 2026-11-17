#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_turnover.py — how a side loses the ball in play, 2015/16 Premier League
(G5.148, game/DESIGN.md §8.252). StatsBomb's possession sequences: each change of possession team whose next
possession does not start with a set piece (corner, free kick, goal kick, kick-off, throw-in) is a turnover in
play. Its cause = the losing side's last on-ball event: a pass (incomplete), a shot (saved / blocked / off a
post), a clearance, a dribble (failed take-on), dispossessed / a lost duel (tackled), a miscontrol, or other
(ball receipt failed, error, keeper). A team-match each, and where (the loser's metres off THEIR line, 0-35 /
35-70 / 70+). fh-game-match prints the same as TURNOVERS.

    benchmarks_statsbomb_turnover.py <events dir>

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, os, sys

SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
ON = {"Pass", "Shot", "Clearance", "Dribble", "Dispossessed", "Miscontrol", "Carry", "Ball Receipt*", "Duel",
      "Error", "Goal Keeper", "Interception", "Ball Recovery", "Block", "50/50"}
files = [f for f in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))) if os.path.basename(f)[0].isdigit()]
C = collections.Counter(); Z = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    by = collections.defaultdict(list)
    for e in ev:
        by[e["possession"]].append(e)
    ps = sorted(by)
    for a, b in zip(ps, ps[1:]):
        A, B = by[a], by[b]
        if A[0]["possession_team"]["id"] == B[0]["possession_team"]["id"]:
            continue
        first = next((e for e in B if e["type"]["name"] == "Pass" or e["type"]["name"] == "Shot"), None)
        if first is not None and first["type"]["name"] == "Pass" and first["pass"].get("type", {}).get("name") in SET \
                and first is B[0] or (B[0]["type"]["name"] == "Pass" and B[0]["pass"].get("type", {}).get("name") in SET):
            continue
        if any(e["type"]["name"] in ("Half End", "Half Start") for e in A[-2:]):
            continue
        t = A[0]["possession_team"]["id"]
        last = None
        for e in reversed(A):
            if e.get("team", {}).get("id") == t and e["type"]["name"] in ON and "location" in e:
                last = e; break
        if last is None:
            continue
        n = last["type"]["name"]
        if n == "Pass": k = "pass" if "outcome" in last["pass"] else "pass (complete, then lost)"
        elif n == "Shot": k = "shot"
        elif n == "Clearance": k = "clearance"
        elif n == "Dribble": k = "dribble (failed take-on)"
        elif n in ("Dispossessed", "Duel"): k = "dispossessed / tackled"
        elif n == "Miscontrol": k = "miscontrol"
        elif n == "Carry": k = "carry (then lost)"
        elif n == "Ball Receipt*": k = "receipt failed"
        else: k = "other"
        C[k] += 1
        d = (120 - last["location"][0]) * 105 / 120
        Z[(k, 0 if d < 35 else 1 if d < 70 else 2)] += 1
tm = 2 * len(files)
print(f"{len(files)} matches; TURNOVERS IN PLAY a team-match {sum(C.values()) / tm:.1f}, by the loser's last on-ball event (0-35 / 35-70 / 70+ m off their line):")
for k, v in C.most_common():
    print(f"   {k:28s} {v / tm:5.1f}   {' / '.join(f'{Z[(k, z)] / tm:.1f}' for z in range(3))}")

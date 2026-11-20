#!/usr/bin/env python3
"""benchmarks_statsbomb_nopass.py — shots with no key pass, by how the shooter came to have the ball, 2015/16 Premier
League (G5.206, game/DESIGN.md §8.312).

    python3 -I game/scripts/benchmarks_statsbomb_nopass.py <PL 15/16 events dir>

Open-play shots with a freeze frame and no shot.key_pass_id, by goal-side outfield opponents 0-1 / 2+ (as
benchmarks_statsbomb_shotpast.py), in this order: a rebound (the shooter's side shot within 5 s); off their
clearance / block / keeper within 3 s; a regain (the possession began within 5 s); his own dribble within 5 s; other
(their last touch within 3 s named). A team-match each. fh-game-match prints the same as §8.312 NO-PASS shots.
Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys
SX, SY = 105 / 120, 68 / 80
def secs(e):
    h, m, s = e["timestamp"].split(":"); return int(h) * 3600 + int(m) * 60 + float(s)
SKIP = ("Ball Receipt*", "Pressure", "Carry", "Duel", "Foul Committed", "Foul Won", "Dribbled Past", "Substitution", "Tactical Shift", "Injury Stoppage", "Referee Ball-Drop", "Half Start", "Half End", "Starting XI", "Player Off", "Player On")
C = collections.Counter(); N = collections.Counter(); files = 0
for f in glob.glob(os.path.join(sys.argv[1], "*.json")):
    if not os.path.basename(f)[0].isdigit(): continue
    files += 1
    ev = json.load(open(f, encoding="utf8"))
    for i, e in enumerate(ev):
        if e["type"]["name"] != "Shot": continue
        s = e["shot"]
        if s.get("type", {}).get("name") != "Open Play" or "freeze_frame" not in s: continue
        x, y = e["location"]; d0 = math.hypot((120 - x) * SX, (40 - y) * SY)
        gs = sum(1 for p in s["freeze_frame"] if not p["teammate"] and p.get("position", {}).get("name") != "Goalkeeper" and math.hypot((120 - p["location"][0]) * SX, (40 - p["location"][1]) * SY) < d0)
        b = 0 if gs <= 1 else 1
        if s.get("key_pass_id"): continue
        t0 = secs(e); team = e["team"]["id"]
        prev = [q for q in ev[max(0, i - 25):i] if q["period"] == e["period"] and t0 - secs(q) <= 5 and q["type"]["name"] not in SKIP]
        kind = "other"
        if any(q["type"]["name"] == "Shot" and q["team"]["id"] == team for q in prev): kind = "rebound (our shot <5 s)"
        else:
            last_opp = next((q for q in reversed(prev) if q["team"]["id"] != team), None)
            pstart = next((q for q in ev if q.get("possession") == e["possession"] and q["period"] == e["period"]), None)
            age = t0 - secs(pstart) if pstart else 99
            if last_opp and last_opp["type"]["name"] in ("Clearance", "Block", "Goal Keeper") and t0 - secs(last_opp) <= 3: kind = "off their clearance/block/keeper <3 s"
            elif age <= 5: kind = "regain <5 s"
            elif any(q["type"]["name"] == "Dribble" and q["player"]["id"] == e["player"]["id"] for q in prev): kind = "his dribble"
            elif last_opp and t0 - secs(last_opp) <= 3: kind = "other loose (their touch <3 s): " + last_opp["type"]["name"]
        C[(b, kind)] += 1; N[b] += 1
tm = 2 * files
for b, nm in ((0, "0-1 goal-side"), (1, "2+")):
    print(f"NO-PASS shots, {nm}: {N[b] / tm:.2f} a team-match | " + "; ".join(f"{k} {v / tm:.3f}" for (bb, k), v in sorted(C.items(), key=lambda a: -a[1]) if bb == b))

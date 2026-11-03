#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_out.py — how the ball really leaves the pitch
and where clearances land (game/DESIGN.md §8.103).

    benchmarks_statsbomb_out.py <data dir> [out.json]

Premier League 2015/16, 380 matches, StatsBomb Open Data (free with attribution).
For each throw-in, corner and goal kick: the last on-ball event before it. For
each clearance: the next on-ball location (where it was next played), so a
landing spot, not a kick length; StatsBomb gives clearances no end point.
Pitch 120 x 80 scaled to 105 x 68. A team-match = matches x 2.
"""
import collections, json, os, sys
SKIP = {"Ball Receipt*", "Pressure", "Duel", "Foul Committed", "Foul Won", "Substitution", "Tactical Shift",
        "Injury Stoppage", "Player Off", "Player On", "Referee Ball-Drop", "Half Start", "Half End",
        "Starting XI", "Own Goal Against", "Own Goal For", "Bad Behaviour", "Offside", "Camera On", "Camera off", "Dribbled Past", "Shield", "Error"}
RESTART = {"Throw-in": "throw", "Corner": "corner", "Goal Kick": "goal_kick"}
d = sys.argv[1]
ms = json.load(open(os.path.join(d, "matches.json")))
team_matches = len(ms) * 2
by = collections.defaultdict(collections.Counter)
clr = collections.defaultdict(list)
clr_out = collections.Counter()
pass_h = collections.defaultdict(collections.Counter)
for m in ms:
    ev = json.load(open(os.path.join(d, "events", f"{m['match_id']}.json")))
    on = [e for e in ev if e["type"]["name"] not in SKIP and "location" in e]
    for i, e in enumerate(on):
        n = e["type"]["name"]
        if n == "Pass":
            t = e["pass"].get("type", {}).get("name")
            if t in ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in"):
                if t in RESTART and i:
                    p = on[i - 1]
                    k = p["type"]["name"]
                    if k == "Goal Keeper":
                        g = p["goalkeeper"]["type"]["name"]
                        # A keeper who only faced it touched nothing: the shot went out.
                        k = "Shot" if g in ("Shot Faced", "Goal Conceded", "Penalty Conceded") else "Keeper " + g
                    if k == "Pass":
                        h = p["pass"]["height"]["name"]
                        k = "Pass " + ("ground" if h == "Ground Pass" else "air")
                    by[RESTART[t]][k] += 1
                    by[RESTART[t]]["same_team" if p["team"]["id"] == e["team"]["id"] else "other_team"] += 1
            else:
                h = e["pass"]["height"]["name"]
                L = e["pass"]["length"] * 105 / 120
                b = "lt15" if L < 15 else "15_30" if L < 30 else "30_45" if L < 45 else "45_plus"
                c = pass_h[(h, b)]
                c["n"] += 1
                c["out"] += e["pass"].get("outcome", {}).get("name") == "Out"
                c["ok"] += "outcome" not in e["pass"]
        if n == "Clearance" and i + 1 < len(on):
            nx = on[i + 1]
            x0, y0 = e["location"][0] * 105 / 120, e["location"][1] * 68 / 80
            x1, y1 = nx["location"][0] * 105 / 120, nx["location"][1] * 68 / 80
            if nx["team"]["id"] != e["team"]["id"]:
                x1, y1 = 105 - x1, 68 - y1
            t = nx["type"]["name"]
            sp = t == "Pass" and nx["pass"].get("type", {}).get("name")
            kept = nx["team"]["id"] == e["team"]["id"]
            clr["fwd"].append(x1 - x0)
            clr["side"].append(abs(y1 - 34) - abs(y0 - 34))
            clr_out["n"] += 1
            clr_out["throw"] += sp == "Throw-in"
            clr_out["corner"] += sp == "Corner"
            clr_out["kept_next"] += kept
            clr_out["head"] += e.get("clearance", {}).get("head", False) or e.get("clearance", {}).get("body_part", {}).get("name") == "Head"
def med(v):
    v = sorted(v)
    return v[len(v) // 2]
out = {}
for k, c in by.items():
    n = sum(v for a, v in c.items() if a not in ("same_team", "other_team"))
    print(f"{k}: {n / team_matches:.1f} a team; before it, team that restarts played last {100 * c['same_team'] / n:.0f}%")
    out[k] = {"per_team_match": round(n / team_matches, 1)}
    for a, v in c.most_common():
        if a not in ("same_team", "other_team"):
            print(f"   {a:18s} {v / team_matches:5.2f} a team {100 * v / n:5.1f}%")
            out[k][a] = round(v / team_matches, 2)
n = clr_out["n"]
print(f"clearances {n / team_matches:.1f} a team; head {100 * clr_out['head'] / n:.0f}%; next ball forward median {med(clr['fwd']):.0f} m, side gain median {med(clr['side']):.0f} m")
print(f"   to a throw-in {100 * clr_out['throw'] / n:.1f}%  corner {100 * clr_out['corner'] / n:.1f}%  own team next {100 * clr_out['kept_next'] / n:.0f}%")
out["clearance"] = {"per_team_match": round(n / team_matches, 1), "fwd_median": med(clr["fwd"]), "throw_pct": round(100 * clr_out["throw"] / n, 1), "corner_pct": round(100 * clr_out["corner"] / n, 1), "own_next_pct": round(100 * clr_out["kept_next"] / n)}
print("open-play passes: height, length, a team, out%, complete%")
out["pass_out"] = []
for (h, b), c in sorted(pass_h.items()):
    r = dict(height=h, length=b, per_team_match=round(c["n"] / team_matches, 1), out_pct=round(100 * c["out"] / c["n"], 1), ok_pct=round(100 * c["ok"] / c["n"], 1))
    out["pass_out"].append(r)
    print(f"   {h:12s} {b:8s} {r['per_team_match']:6.1f} {r['out_pct']:5.1f} {r['ok_pct']:5.1f}")
if len(sys.argv) > 2:
    json.dump(out, open(sys.argv[2], "w"), indent=1)

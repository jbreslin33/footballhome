#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_decisions.py — what a real player does with
the ball, by where he is and whether he is pressed.

James 11/2: "lets re model based on the data". The Brain's hand rules gave 70
shots a team. This measures the choice itself from every on-ball release in
the 2015/16 Premier League (380 matches), so a decision can come from a table
of real rates, not a threshold. See game/DESIGN.md §8.102.

    benchmarks_statsbomb_decisions.py <data dir> [out.json]

A release = the action that ends a player's time on the ball in open play:
Shot, Pass, Clearance, Dispossessed or Miscontrol. Carries and dribbles are
not releases: they move him to the spot he releases from. Set pieces are out.
Distance = metres to the goal centre, with StatsBomb's 120 x 80 pitch scaled
to 105 x 68. Central = inside the width of the six-yard box plus 5 m a side.
Data: StatsBomb Open Data, free with attribution to StatsBomb.
"""
import collections, json, math, os, sys

DIST = [6, 11, 16, 22, 30, 45, 200]
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")


def cell(e):
    x, y = e["location"][:2]
    dx, dy = (120 - x) * 105 / 120, (y - 40) * 68 / 80
    d = math.hypot(dx, dy)
    band = next(i for i, top in enumerate(DIST) if d < top)
    return band, abs(dy) <= 14.16, bool(e.get("under_pressure"))


def main():
    data = sys.argv[1]
    ms = json.load(open(os.path.join(data, "matches.json")))
    t = collections.defaultdict(collections.Counter)
    team_shots = 0
    for m in ms:
        for e in json.load(open(os.path.join(data, "events", f"{m['match_id']}.json"))):
            if "location" not in e:
                continue
            n = e["type"]["name"]
            if n == "Pass":
                if e["pass"].get("type", {}).get("name") in SET:
                    continue
                k = "pass"
            elif n == "Shot":
                if e["shot"]["type"]["name"] != "Open Play":
                    continue
                k = "shot"
            elif n == "Clearance":
                k = "clear"
            elif n in ("Dispossessed", "Miscontrol"):
                k = "lost"
            else:
                continue
            c = t[cell(e)]
            c["n"] += 1
            c[k] += 1
            if k == "shot":
                team_shots += 1
                c["goal"] += e["shot"]["outcome"]["name"] == "Goal"
                c["xg"] += e["shot"]["statsbomb_xg"]
                c["head"] += e["shot"]["body_part"]["name"] == "Head"
    rows = []
    for (band, central, pressed), c in sorted(t.items()):
        rows.append({"to_m": DIST[band], "central": central, "pressed": pressed, "releases": c["n"],
                     "shot_pct": round(100 * c["shot"] / c["n"], 2), "pass_pct": round(100 * c["pass"] / c["n"], 1),
                     "clear_pct": round(100 * c["clear"] / c["n"], 1), "lost_pct": round(100 * c["lost"] / c["n"], 1),
                     "shots": c["shot"], "goal_pct": round(100 * c["goal"] / c["shot"], 1) if c["shot"] else 0,
                     "xg": round(c["xg"] / c["shot"], 3) if c["shot"] else 0,
                     "head_pct": round(100 * c["head"] / c["shot"]) if c["shot"] else 0})
    print(f"{len(ms)} matches, open-play shots a team a match {team_shots / len(ms) / 2:.1f}")
    print("  to m  where   pressed  releases  shot%   pass%  clear%  lost%   shots  goal%   xG   head%")
    for r in rows:
        print(f"{r['to_m']:6d}  {'central' if r['central'] else 'wide   '} {'yes' if r['pressed'] else 'no ':7s} {r['releases']:8d} {r['shot_pct']:6.1f} "
              f"{r['pass_pct']:7.1f} {r['clear_pct']:6.1f} {r['lost_pct']:6.1f} {r['shots']:7d} {r['goal_pct']:6.1f} {r['xg']:5.3f} {r['head_pct']:5d}")
    if len(sys.argv) > 2:
        json.dump(rows, open(sys.argv[2], "w"), indent=1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Rest defence in the pro game, from StatsBomb 360 freeze frames (G5.1).

Usage: benchmarks_statsbomb_rest.py <competition_id> <season_id> [cache_dir]
Euro 2020 = 55 43, World Cup 2022 = 43 106.

The question: with the ball in their half on an open-play pass, how many of
the passer's nine outfield mates are AHEAD of the ball, and how many of the
opponents' outfielders are behind it (left up).

Broadcast frames miss players, so the frame is kept only when its visible area
reaches the goal the team attacks, which keeps the men ahead of the ball in
shot. Mates ahead is the reliable count (it can only be under by a man out of
wide shot): "behind" is 9 minus it, a ceiling. Left up is a floor (the camera
looks away from those men), so it is printed but not a target.

Data: StatsBomb Open Data, free to use with attribution to StatsBomb.
FH original: the measure.
"""
import json
import os
import statistics
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from benchmarks_statsbomb import BASE, fetch   # noqa: E402

SET_PIECES = {"Corner", "Free Kick", "Throw-in", "Goal Kick", "Kick Off"}
ZONES = ((60, 80, "half to 40 yd out"), (80, 100, "40-20 yd out"), (100, 120, "last 20 yd"))


def zone(x):
    for i, (a, b, _) in enumerate(ZONES):
        if a <= x < b:
            return i
    return None


def measure(events, frames, ahead, up):
    ff = {f["event_uuid"]: f for f in frames}
    for e in events:
        if e["type"]["name"] != "Pass" or e.get("pass", {}).get("type", {}).get("name") in SET_PIECES:
            continue
        f = ff.get(e["id"])
        if not f or "location" not in e:
            continue
        x = e["location"][0]
        z = zone(x)
        if z is None or max(f["visible_area"][0::2]) < 115:
            continue
        a = u = 0
        for p in f["freeze_frame"]:
            if p.get("keeper") or p.get("actor"):
                continue
            if p["teammate"] and p["location"][0] > x:
                a += 1
            if not p["teammate"] and p["location"][0] < x:
                u += 1
        ahead[z].append(a)
        up[z].append(u)


def main():
    comp, season, cache = sys.argv[1], sys.argv[2], sys.argv[3]
    os.makedirs(cache, exist_ok=True)
    matches = fetch(f"{BASE}/matches/{comp}/{season}.json", os.path.join(cache, f"matches_{comp}_{season}.json"))
    ahead, up = [[] for _ in ZONES], [[] for _ in ZONES]
    for m in matches:
        i = m["match_id"]
        measure(fetch(f"{BASE}/events/{i}.json", os.path.join(cache, f"{i}.json")),
                fetch(f"{BASE}/three-sixty/{i}.json", os.path.join(cache, f"360_{i}.json")), ahead, up)
    print(matches[0]["competition"]["competition_name"], matches[0]["season"]["season_name"], len(matches), "matches")
    for z, (_, _, name) in enumerate(ZONES):
        if ahead[z]:
            print(f"  {name}: {len(ahead[z])} frames, mates ahead of the ball {statistics.mean(ahead[z]):.2f}"
                  f" (median {statistics.median(ahead[z])}), behind at most {9 - statistics.mean(ahead[z]):.2f};"
                  f" seen left up {statistics.mean(up[z]):.2f}")


if __name__ == "__main__":
    main()

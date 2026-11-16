#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_funnel.py — how far a real attack gets and where it stops (G5.127,
game/DESIGN.md §8.228).

    python3 -I game/scripts/benchmarks_statsbomb_funnel.py <events dir>

Premier League 2015/16, StatsBomb Open Data (free with attribution; github.com/statsbomb/open-data). Every
possession (StatsBomb's possession id) whose side has the ball in open play — its on-ball events (Pass, Carry
end, Ball Receipt* completed, Shot, Dribble, Dispossessed, Miscontrol) by the side in possession. Its deepest
band = the nearest any of those got to THEIR goal line (m: 52+ / 35-52 / 18-35 / 0-18). Reaching a band:
possessions a team-match. And from the band it reached last, how it ended: a shot; still in play to the other
side (lost) — by how (pass not completed, dispossessed / tackled / miscontrol, clearance or other); or dead
(out / foul / offside). FUNNEL line: of those reaching 35-52, the share going on to 18-35, of those 18-35 to
0-18, and shots from each deepest band. Pitch 120 x 80 scaled to 105 x 68, attacking toward x = 120. ENTRY line: the first time a possession gets into a deeper band, by a carry or a completed pass. FH original.
"""
import collections, glob, json, os, sys

SX = 105 / 120
BANDS = ("52+", "35-52", "18-35", "0-18")
OPEN = {"Regular Play", "From Counter", "From Keeper", "From Goal Kick", "From Throw In", "From Free Kick", "From Corner", "From Kick Off"}


def band(x):
    d = (120 - x) * SX
    return 3 if d < 18 else 2 if d < 35 else 1 if d < 52 else 0


def spots(e):
    n = e["type"]["name"]
    if n == "Ball Receipt*" and "ball_receipt" in e:
        return []
    out = [e["location"]] if "location" in e else []
    if n == "Carry":
        out.append(e["carry"]["end_location"])
    if n == "Pass" and "outcome" not in e.get("pass", {}):
        out.append(e["pass"]["end_location"])
    return out


ON = {"Pass", "Carry", "Ball Receipt*", "Shot", "Dribble", "Dispossessed", "Miscontrol", "Clearance", "Duel"}
entry = collections.defaultdict(collections.Counter)   # [band] how the possession first got there: carry / pass
reach = collections.Counter(); ends = collections.defaultdict(collections.Counter)
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    poss = collections.OrderedDict()
    for e in ev:
        poss.setdefault(e["possession"], []).append(e)
    keys = list(poss)
    for i, pk in enumerate(keys):
        es = poss[pk]
        team = es[0]["possession_team"]["id"]
        if es[0]["period"] > 4:
            continue
        mine = [e for e in es if e.get("team", {}).get("id") == team and e["type"]["name"] in ON]
        if not mine:
            continue
        # only the open-play part: drop a possession that is only a set piece taken and lost at once
        deep = -1
        for e in mine:
            if e["type"]["name"] == "Pass" and e["pass"].get("type", {}).get("name") in ("Corner", "Free Kick", "Penalty") :
                continue
            for s in spots(e):
                deep = max(deep, band(s[0]))
        if deep < 0:
            continue
        got = 0   # ENTRY: the first on-ball event taking the possession into each deeper band, by carry or completed pass
        for e in mine:
            n = e["type"]["name"]
            if n == "Pass" and e["pass"].get("type", {}).get("name") in ("Corner", "Free Kick", "Penalty", "Throw-in", "Goal Kick", "Kick Off"):
                continue
            if n == "Carry" or (n == "Pass" and "outcome" not in e["pass"]):
                b0 = band(e["location"][0]); b1 = band((e["carry"] if n == "Carry" else e["pass"])["end_location"][0])
                got = max(got, b0)
                for b in range(got + 1, b1 + 1):
                    entry[b]["carry" if n == "Carry" else "pass"] += 1
                got = max(got, b1)
        for b in range(deep + 1):
            reach[b] += 1
        shot = any(e["type"]["name"] == "Shot" and e.get("team", {}).get("id") == team for e in es)
        if shot:
            ends[deep]["shot"] += 1
            continue
        nxt = poss[keys[i + 1]] if i + 1 < len(keys) else None
        acts = [e for e in mine if e["type"]["name"] != "Ball Receipt*"]
        last = acts[-1] if acts else mine[-1]
        lost_in_play = nxt is not None and nxt[0]["play_pattern"]["name"] in ("Regular Play", "From Counter", "From Keeper") and nxt[0]["possession_team"]["id"] != team
        if not lost_in_play:
            ends[deep]["dead"] += 1
            continue
        n = last["type"]["name"]
        if n == "Pass" and "outcome" in last["pass"]:
            ends[deep]["lost pass"] += 1
        elif n in ("Dispossessed", "Miscontrol", "Duel", "Dribble") or (n == "Carry"):
            ends[deep]["lost on the ball"] += 1
        else:
            ends[deep]["lost other"] += 1
tm = 2 * len(files)
print(f"{len(files)} matches (StatsBomb PL 2015/16): FUNNEL — possessions by the deepest band reached (m off their line)")
print("  reaching: " + "; ".join(f"{BANDS[b]} {reach[b] / tm:.1f}" for b in range(4)) + " a team-match")
print("  on: 35-52 → 18-35 %.0f%%, 18-35 → 0-18 %.0f%%" % (100 * reach[2] / reach[1], 100 * reach[3] / reach[2]))
print("  ENTRY into a band (first time in the possession, from a shallower band): carried / passed a team-match: " +
      "; ".join(f"{BANDS[b]} {entry[b]['carry'] / tm:.1f} / {entry[b]['pass'] / tm:.1f}" for b in (1, 2, 3)))
for b in range(4):
    n = sum(ends[b].values())
    print(f"  deepest {BANDS[b]:5s} {n / tm:5.1f}: " + ", ".join(f"{k} {100 * v / n:.0f}%" for k, v in sorted(ends[b].items())))

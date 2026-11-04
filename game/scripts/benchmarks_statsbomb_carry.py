#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_carry.py — how real 2015/16 Premier League players carry the
ball (G5.18, game/DESIGN.md §8.115): every open-play Carry event (StatsBomb: the ball moved by a
player at his feet between two other events), by whether StatsBomb marks him under pressure and by
the third he's in. Length, forward gain toward goal, duration, speed (length / duration), and the
share that gain 10 m+.

    benchmarks_statsbomb_carry.py <events dir>

Pitch: StatsBomb 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data, free with attribution to
StatsBomb (github.com/statsbomb/open-data).
"""
import collections, glob, json, os, sys

SX, SY = 105 / 120, 68 / 80
c = collections.defaultdict(list)
tob = collections.defaultdict(list)
REL = ("Pass", "Shot", "Clearance", "Dispossessed", "Miscontrol")
ts = lambda e: e["minute"] * 60 + e["second"] + float("0." + e["timestamp"].split(".")[1]) if "." in e["timestamp"] else e["minute"] * 60 + e["second"]
files = sorted(glob.glob(os.path.join(sys.argv[1], "*.json")))
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    for i, e in enumerate(ev):
        if e["type"]["name"] == "Ball Receipt*" and "ball_receipt" not in e:
            pid = e["player"]["id"]
            for nx in ev[i + 1:i + 40]:
                if nx.get("player", {}).get("id") == pid and nx["type"]["name"] in REL:
                    if nx["period"] == e["period"] and nx.get("pass", {}).get("type") is None:   # set pieces out
                        tob["pressed" if e.get("under_pressure") else "free"].append(max(0.0, ts(nx) - ts(e)))
                    break
                if nx.get("possession") != e.get("possession"): break
    for e in ev:
        if e["type"]["name"] != "Carry" or e.get("play_pattern", {}).get("name") in ("From Kick Off",): continue
        a, b = e["location"], e["carry"]["end_location"]
        dx, dy = (b[0] - a[0]) * SX, (b[1] - a[1]) * SY
        ln = (dx * dx + dy * dy) ** 0.5; d = e.get("duration") or 0
        third = 0 if a[0] < 40 else 1 if a[0] < 80 else 2
        key = ("pressed" if e.get("under_pressure") else "free", third)
        c[key].append((ln, dx, d))
        c[("all", -1)].append((ln, dx, d))
tm = 2 * len(files)
print(f"{len(files)} matches; carries a team-match, mean length / forward gain / duration / speed (moving carries, 1 m+), share gaining 10 m+:")
for key in sorted(c, key=lambda k: (k[0] != "all", k[0], k[1])):
    v = c[key]; mv = [x for x in v if x[0] >= 1 and x[2] > 0]
    sp = sum(x[0] for x in mv) / max(1e-9, sum(x[2] for x in mv))
    lab = key[0] if key[1] < 0 else f"{key[0]:7s} {('own third', 'middle', 'final third')[key[1]]}"
    print(f"  {lab:24s} {len(v)/tm:6.1f}  {sum(x[0] for x in v)/len(v):5.1f} m / {sum(x[1] for x in v)/len(v):+5.1f} m / {sum(x[2] for x in v)/len(v):4.2f} s / {sp:4.2f} m/s   10 m+ {100*sum(1 for x in v if x[1] >= 10)/len(v):4.1f}% ({sum(1 for x in v if x[1] >= 10)/tm:.1f})")
    if key[0] == "all":
        for lo, hi in ((0, 1), (1, 3), (3, 6), (6, 10), (10, 20), (20, 99)):
            s = [x for x in v if lo <= x[0] < hi]
            if s: print(f"     length {lo:2d}-{hi:<2d} m {100*len(s)/len(v):5.1f}%  mean {sum(x[2] for x in s)/len(s):.2f} s, speed {sum(x[0] for x in s)/max(1e-9,sum(x[2] for x in s)):.2f} m/s")
print("TIME ON THE BALL (receipt to his next release), by pressure at the receipt:")
for k in ("free", "pressed"):
    v = tob[k]; n = len(v)
    print(f"  {k:7s} {n/tm:6.1f} a team-match  mean {sum(v)/n:.2f} s  inside 1 s {100*sum(1 for x in v if x < 1)/n:.1f}%  2 s {100*sum(1 for x in v if x < 2)/n:.1f}%  4 s {100*sum(1 for x in v if x < 4)/n:.1f}%  one-touch (<0.3 s) {100*sum(1 for x in v if x < 0.3)/n:.1f}%")

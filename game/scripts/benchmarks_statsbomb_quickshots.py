#!/usr/bin/env python3
"""benchmarks_statsbomb_quickshots.py — shots soon after the ball is won near their goal (G5.201, game/DESIGN.md §8.307).

    python3 -I game/scripts/benchmarks_statsbomb_quickshots.py <PL 15/16 events dir>

StatsBomb PL 2015/16, open play (penalties out; possessions From Corner / Free Kick / Throw In out — their shots are set
pieces). For every possession: its first event's spot (m off the goal it attacks) and kind; a shot by it within 5 s of that
first event. By where it began (0-18 / 18-35 / 35+ m off their line) and how (the first event: Interception, Ball Recovery,
Duel / tackle, Pass (a loose ball's first touch is often logged as the pass), other): possessions and quick shots a
team-match, and goals. fh-game-match's SHOT TRACE carries the same (won x / prev / t). FH original; data StatsBomb Open
Data, free with attribution.
"""
import collections, glob, json, os, sys

SX = 105 / 120


def secs(e):
    h, m, s = e["timestamp"].split(":")
    return int(h) * 3600 + int(m) * 60 + float(s)


files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
P = collections.Counter(); Q = collections.Counter(); G = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    first = {}
    for e in ev:
        if "possession" not in e or "location" not in e or e["type"]["name"] in ("Ball Receipt*", "Pressure", "Carry"): continue
        k = (e["period"], e["possession"])
        if k in first or e["possession_team"]["id"] != e["team"]["id"]: continue
        first[k] = e
    for k, e0 in first.items():
        if e0["play_pattern"]["name"] in ("From Corner", "From Free Kick", "From Throw In", "From Kick Off", "From Goal Kick"): continue
        x = (120 - e0["location"][0]) * SX
        z = 0 if x < 18 else 1 if x < 35 else 2
        t = e0["type"]["name"]
        how = t if t in ("Interception", "Ball Recovery", "Duel", "Pass", "Clearance", "Block") else "other"
        P[(z, how)] += 1
    for e in ev:
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] != "Open Play": continue
        e0 = first.get((e["period"], e["possession"]))
        if not e0 or e0["play_pattern"]["name"] in ("From Corner", "From Free Kick", "From Throw In", "From Kick Off", "From Goal Kick"): continue
        if secs(e) - secs(e0) > 5: continue
        x = (120 - e0["location"][0]) * SX
        z = 0 if x < 18 else 1 if x < 35 else 2
        t = e0["type"]["name"]
        how = t if t in ("Interception", "Ball Recovery", "Duel", "Pass", "Clearance", "Block") else "other"
        Q[(z, how)] += 1; G[(z, how)] += e["shot"]["outcome"]["name"] == "Goal"
tm = 2 * len(files)
print(f"QUICK SHOTS — StatsBomb PL 15/16, {len(files)} matches: open-play possessions (no restart start) by where / how they began: possessions | shots within 5 s | goals, a team-match")
for z, zn in enumerate(("0-18", "18-35", "35+")):
    tp = sum(P[(z, h)] for h in ("Interception", "Ball Recovery", "Duel", "Pass", "Clearance", "Block", "other"))
    tq = sum(Q[(z, h)] for h in ("Interception", "Ball Recovery", "Duel", "Pass", "Clearance", "Block", "other"))
    tg = sum(G[(z, h)] for h in ("Interception", "Ball Recovery", "Duel", "Pass", "Clearance", "Block", "other"))
    print(f"  {zn:5s} all {tp / tm:6.2f} | {tq / tm:5.2f} | {tg / tm:5.3f}   " + "; ".join(f"{h} {P[(z, h)] / tm:.2f}|{Q[(z, h)] / tm:.2f}|{G[(z, h)] / tm:.3f}" for h in ("Interception", "Ball Recovery", "Duel", "Pass", "other")))

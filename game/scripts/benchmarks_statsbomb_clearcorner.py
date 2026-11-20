#!/usr/bin/env python3
"""benchmarks_statsbomb_clearcorner.py — how often a clearance goes behind for a corner (G5.180, game/DESIGN.md §8.286).

    python3 -I game/scripts/benchmarks_statsbomb_clearcorner.py <PL 15/16 events dir>

StatsBomb PL 2015/16 (open data, attribution StatsBomb). Every Clearance (no end location in the data): its spot — m off
the clearing side's own goal line 0-6 / 6-18 / 18-35 / 35+ × |y| inside the box's width (20.16 m) or wide — and body part
(head / foot / other). Its result (G5.188 §8.294: by body part, corner and throw-in %): the next on-ball event (skipping receipts, pressures, duels … as benchmarks_statsbomb_out.py) is a corner,
a throw-in, a goal kick, or play on.

§8.285: our corners 1.9 a team-match (5.4); by what put it out, clearances 0.06 (StatsBomb 1.38) though our headed
clearances run 19.3 (15.8).
"""
import collections, glob, json, os, sys

SX, SY = 105 / 120, 68 / 80
SKIP = {"Ball Receipt*", "Pressure", "Duel", "Foul Committed", "Foul Won", "Substitution", "Tactical Shift",
        "Injury Stoppage", "Player Off", "Player On", "Referee Ball-Drop", "Half Start", "Half End",
        "Starting XI", "Own Goal Against", "Own Goal For", "Bad Behaviour", "Offside", "Camera On", "Camera off", "Dribbled Past", "Shield", "Error"}


def band(x, y):
    d = x * SX   # StatsBomb x for the clearing side: it attacks toward 120, so its own goal line is x = 0
    return (0 if d < 6 else 1 if d < 18 else 2 if d < 35 else 3, 0 if abs((y - 40) * SY) < 20.16 else 1)


files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[:-5].isdigit())
n = collections.Counter(); res = collections.Counter(); bp = collections.Counter(); bpc = collections.Counter(); bpt = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    on_ix = {}; on = []
    for i, e in enumerate(ev):   # the next on-ball event, as benchmarks_statsbomb_out.py
        if e["type"]["name"] not in SKIP and "location" in e: on_ix[i] = len(on); on.append(e)
    for i, e in enumerate(ev):
        if e["type"]["name"] != "Clearance":
            continue
        b = band(*e["location"]); body = e.get("clearance", {}).get("body_part", {}).get("name", "?")
        body = "head" if body == "Head" else "foot" if "Foot" in body else "other"
        team = e["team"]["id"]
        nx = on[on_ix[i] + 1] if on_ix.get(i) is not None and on_ix[i] + 1 < len(on) else None
        out = "play on"
        if nx is not None and nx["type"]["name"] == "Pass":
            pt = nx["pass"].get("type", {}).get("name")
            out = "corner" if pt == "Corner" else "throw-in" if pt == "Throw-in" else "goal kick" if pt == "Goal Kick" else out
        n[b] += 1; res[(b, out)] += 1; bp[(b, body)] += 1; bpc[(b, body)] += out == "corner"; bpt[(b, body)] += out == "throw-in"
tm = 2 * len(files)
tot = sum(n.values()); totc = sum(v for (b, o), v in res.items() if o == "corner")
print(f"{len(files)} matches: clearances {tot / tm:.2f} a team-match, -> their corner {totc / tm:.2f} a team-match ({100 * totc / tot:.1f}%)")
dn = ("0-6", "6-18", "18-35", "35+"); wn = ("inside", "wide")
for b in sorted(n):
    print(f"  {dn[b[0]]:5s} {wn[b[1]]:6s} {n[b] / tm:5.2f} a tm | corner {100 * res[(b, 'corner')] / n[b]:4.1f}% throw-in {100 * res[(b, 'throw-in')] / n[b]:4.1f}% goal kick {100 * res[(b, 'goal kick')] / n[b]:3.1f}%"
          + " | " + " ".join(f"{k} {bp[(b, k)] / tm:.2f} ({100 * bpc[(b, k)] / max(1, bp[(b, k)]):.0f}% corner, {100 * bpt[(b, k)] / max(1, bp[(b, k)]):.0f}% throw-in)" for k in ("head", "foot", "other")))

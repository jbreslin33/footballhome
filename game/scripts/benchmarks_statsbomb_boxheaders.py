#!/usr/bin/env python3
"""benchmarks_statsbomb_boxheaders.py — the balls a side heads in its own box, by what delivered them (G5.182, game/DESIGN.md §8.288).

    python3 -I game/scripts/benchmarks_statsbomb_boxheaders.py <PL 15/16 events dir>

StatsBomb PL 2015/16 (open data, attribution StatsBomb). A box header = a headed Clearance or headed Pass by a side inside
its own 18 m (x < 18 m off its goal line, |y| < 20.16 m). Its delivery = the last opponent Pass before it in the same
possession chain (StatsBomb 'possession' changes on the header, so the nearest earlier opponent pass within 10 s):
  corner / free kick / throw-in (pass type), cross (as the harness cut, G5.175: from within 30 m of their line, |y| 20.16+,
  ending in the box), long ball (any other pass 30 m+ ending in the box), other (anything else, or none found).
Also every delivery of each kind into the box a team-match, and the share a defender heads.

§8.287: ours head it in our 18 m 5.1 a team-match (real 9.7 inside the box's width).
"""
import collections, glob, json, os, sys

SX, SY = 105 / 120, 68 / 80


def secs(e):
    h, m, s = e["timestamp"].split(":")
    return e["period"] * 10000 + int(h) * 3600 + int(m) * 60 + float(s)


def in_box(x, y):   # x already in the defending side's frame: m off its goal line
    return x < 18 and abs((y - 40) * SY) < 20.16


def kind(p):
    t = p["pass"].get("type", {}).get("name")
    sx, sy = p["location"]; ex, ey = p["pass"]["end_location"]
    ed = (120 - ex) * SX   # the end, m off the defending goal line
    if not in_box(ed, ey):
        return None
    if t in ("Corner", "Free Kick", "Throw-in"):
        return {"Corner": "corner", "Free Kick": "free kick", "Throw-in": "throw-in"}[t]
    if (120 - sx) * SX < 30 and abs((sy - 40) * SY) >= 20.16:
        return "cross"
    if p["pass"]["length"] * SX >= 30:
        return "long ball"
    return "other"


files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[:-5].isdigit())
hd = collections.Counter(); dl = collections.Counter(); dl_air = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    last = {}   # team -> its last pass into the box (event)
    for e in ev:
        t = e["type"]["name"]
        if t == "Pass":
            k = kind(e)
            if k:
                dl[k] += 1; dl_air[k] += e["pass"].get("height", {}).get("name") == "High Pass"
                last[e["team"]["id"]] = (e, k)
        head = (t == "Clearance" and e.get("clearance", {}).get("body_part", {}).get("name") == "Head") or \
               (t == "Pass" and e["pass"].get("body_part", {}).get("name") == "Head" and e["pass"].get("type", {}).get("name") is None)
        if not head:
            continue
        x, y = e["location"]
        if not in_box(x * SX, y):
            continue
        opp = [v for tid, v in last.items() if tid != e["team"]["id"]]
        k = "other"
        if opp and 0 <= secs(e) - secs(opp[0][0]) <= 10:
            k = opp[0][1]
        hd[k] += 1
tm = 2 * len(files)
print(f"{len(files)} matches: box headers {sum(hd.values()) / tm:.2f} a team-match (defending side, inside its 18 m and the box's width)")
print("  delivery     box headers a tm | deliveries into the box a tm (high %) | headed by a defender in the box %")
for k in ("cross", "corner", "free kick", "long ball", "throw-in", "other"):
    print(f"  {k:10s}   {hd[k] / tm:5.2f}            | {dl[k] / tm:5.2f} ({100 * dl_air[k] / max(1, dl[k]):4.1f})               | {100 * hd[k] / max(1, dl[k]):4.1f}")

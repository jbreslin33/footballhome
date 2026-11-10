#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_highpass.py — real high passes: how many, how often they're won,
and how often an aerial duel follows (G5.73, game/DESIGN.md §8.174).

    python3 -I game/scripts/benchmarks_statsbomb_highpass.py <events dir> [--length]

Open-play passes (set pieces out, crosses out) of StatsBomb height "High Pass", by where they were
aimed (end_location), in metres off the passer's own goal 0-35 / 35-70 / 70+. Per zone: a
team-match, completed %, length median, and the share met by an aerial duel within 5 s and 6 m of
the end (a Duel "Aerial Lost", or any event flagged aerial_won, of either side). The duel share on
completed and on lost passes is split out: a lofted ball to a marked target man is contested
whatever comes of it. fh-game-match prints the same as HIGH PASSES.

--length: every open-play pass (crosses out) by the passer's metres off his own goal 0-35 / 35-70 /
70+ and its length 0-10 / 10-20 / 20-30 / 30-40 / 40-50 / 50+ m: a team-match, the share high, and
completed % high / not. The high share is Possession's physics.pass.high_* table (G5.73);
fh-game-match prints the same as HIGH BY LENGTH.

Pitch: StatsBomb 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data (PL 2015/16), free with
attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, statistics, sys

SX, SY = 105 / 120, 68 / 80


def t(e):
    h, m, s = e["timestamp"].split(":")
    return (e["period"], int(h) * 3600 + int(m) * 60 + float(s))


def aerial(e):
    if e["type"]["name"] == "Duel" and e.get("duel", {}).get("type", {}).get("name") == "Aerial Lost":
        return True
    return any(e.get(k, {}).get("aerial_won") for k in ("clearance", "pass", "shot", "miscontrol"))


files = sorted(glob.glob(os.path.join(sys.argv[1], "*.json")))
files = [f for f in files if os.path.basename(f)[0].isdigit()]
if "--length" in sys.argv[2:]:
    LB = (10, 20, 30, 40, 50)
    n = collections.Counter(); h = collections.Counter(); hc = collections.Counter(); gc = collections.Counter()
    for f in files:
        for e in json.load(open(f, encoding="utf8")):
            if e["type"]["name"] != "Pass":
                continue
            p = e["pass"]
            if p.get("type") is not None or p.get("cross"):
                continue
            x, y = e["location"]; ex, ey = p["end_location"]
            L = math.hypot((ex - x) * SX, (ey - y) * SY)
            o = x * SX
            k = (0 if o < 35 else 1 if o < 70 else 2, sum(L >= t for t in LB))
            n[k] += 1
            if p.get("height", {}).get("name") == "High Pass":
                h[k] += 1; hc[k] += "outcome" not in p
            else:
                gc[k] += "outcome" not in p
    tm = 2 * len(files)
    print(f"{len(files)} matches (StatsBomb PL 2015/16): open-play passes (crosses out)")
    print("origin m off own goal | by length 0-10/10-20/20-30/30-40/40-50/50+: [a team-match, high %, completed % high/not]")
    for oz, nm in enumerate(("0-35", "35-70", "70+")):
        print(f"   {nm:5s} " + " ".join(f"[{n[(oz, lb)] / tm:4.1f} {100 * h[(oz, lb)] / max(1, n[(oz, lb)]):4.1f}% "
                                      f"{100 * hc[(oz, lb)] / max(1, h[(oz, lb)]):3.0f}/{100 * gc[(oz, lb)] / max(1, n[(oz, lb)] - h[(oz, lb)]):3.0f}]"
                                      for lb in range(6)))
    sys.exit(0)
n = collections.Counter(); comp = collections.Counter(); duel = collections.Counter()
duel_c = collections.Counter(); duel_l = collections.Counter(); lens = collections.defaultdict(list)
for f in files:
    E = json.load(open(f, encoding="utf8"))
    for i, e in enumerate(E):
        if e["type"]["name"] != "Pass":
            continue
        p = e["pass"]
        if p.get("type") is not None or p.get("cross") or p.get("height", {}).get("name") != "High Pass":
            continue
        ex, ey = p["end_location"]
        own = ex * SX
        z = 0 if own < 35 else 1 if own < 70 else 2
        n[z] += 1
        ok = "outcome" not in p
        comp[z] += ok
        lens[z].append(p["length"] * SX)
        pt, ps = t(e)
        hit = False
        for f2 in E[i + 1:i + 25]:
            q, s2 = t(f2)
            if q != pt or s2 - ps > 5:
                break
            loc = f2.get("location")
            if not loc or not aerial(f2):
                continue
            # the location is in that event team's own frame
            lx, ly = (loc[0], loc[1]) if f2["team"]["id"] == e["team"]["id"] else (120 - loc[0], 80 - loc[1])
            if math.hypot((lx - ex) * SX, (ly - ey) * SY) <= 6:
                hit = True
                break
        duel[z] += hit
        (duel_c if ok else duel_l)[z] += hit
tm = 2 * len(files)
print(f"{len(files)} matches (StatsBomb PL 2015/16): open-play HIGH PASSES (crosses out), by the aim's m off the passer's own goal")
print("   zone  | a team-match | completed % | length med | aerial duel within 5 s, 6 m: all % / on completed % / on lost %")
for z, nm in enumerate(("0-35", "35-70", "70+")):
    if not n[z]:
        continue
    c, l = comp[z], n[z] - comp[z]
    print(f"   {nm:5s} | {n[z] / tm:5.1f} | {100 * c / n[z]:5.1f} | {statistics.median(lens[z]):5.1f} | "
          f"{100 * duel[z] / n[z]:5.1f} / {100 * duel_c[z] / max(c, 1):5.1f} / {100 * duel_l[z] / max(l, 1):5.1f}")

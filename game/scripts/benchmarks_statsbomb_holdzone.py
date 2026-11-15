#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_holdzone.py — a real man's time on the ball and how far he takes it, by where
he gets it (G5.126, game/DESIGN.md §8.227).

    python3 -I game/scripts/benchmarks_statsbomb_holdzone.py <events dir>

Premier League 2015/16, StatsBomb Open Data (free with attribution; github.com/statsbomb/open-data). Every
completed open-play receipt (Ball Receipt* without an outcome) to the same man's next release (Pass, Shot,
Clearance, Dispossessed, Miscontrol) within the period, the release not a set piece — as
benchmarks_statsbomb_carry.py. By the receipt's zone of the pass policy's grid (m off THEIR line 0-18 / 18-35 /
35-52 / 52-70 / 70+ x centre |y| < 20.16 or wide) and whether StatsBomb marks him under pressure at the receipt:
receipts a team-match; time on the ball p25 / median / p75 / p90 s and the one-touch share (under 0.3 s); the
spot he lets it go from, metres from the receipt — p50 / p75 / p90 — and the share 10 m+; and for wide receipts
the release's |y| change (in = toward the centre) and forward gain medians of those 5 m+.
Pitch 120 x 80 scaled to 105 x 68, attacking toward x = 120. FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
REL = ("Pass", "Shot", "Clearance", "Dispossessed", "Miscontrol")
DEPTH = (18, 35, 52, 70)
NAMES = ("0-18", "18-35", "35-52", "52-70", "70+")


def ts(e):
    m, s = e["minute"], e["second"]
    t = e["timestamp"]
    return m * 60 + s + (float("0." + t.split(".")[1]) if "." in t else 0.0)


def zone(x, y):
    d = (120 - x) * SX
    return sum(d >= t for t in DEPTH) * 2 + (0 if abs((y - 40) * SY) < 20.16 else 1)


T = collections.defaultdict(list); D = collections.defaultdict(list); IN = collections.defaultdict(list); FW = collections.defaultdict(list)
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    for i, e in enumerate(ev):
        if e["type"]["name"] != "Ball Receipt*" or "ball_receipt" in e or "location" not in e:
            continue
        pid = e["player"]["id"]
        for nx in ev[i + 1:i + 40]:
            if nx.get("player", {}).get("id") == pid and nx["type"]["name"] in REL:
                if nx["period"] == e["period"] and nx.get("pass", {}).get("type") is None and "location" in nx:
                    x0, y0 = e["location"]; x1, y1 = nx["location"]
                    k = (zone(x0, y0), bool(e.get("under_pressure")))
                    T[k].append(max(0.0, ts(nx) - ts(e)))
                    d = math.hypot((x1 - x0) * SX, (y1 - y0) * SY); D[k].append(d)
                    if d >= 5:
                        IN[k].append((abs(y0 - 40) - abs(y1 - 40)) * SY); FW[k].append((x1 - x0) * SX)
                break


def q(v, p):
    v = sorted(v); return v[min(len(v) - 1, int(p * len(v)))] if v else float("nan")


tm = 2 * len(files)
print(f"{len(files)} matches (StatsBomb PL 2015/16): HOLD BY ZONE — completed open-play receipts to his release")
print("  zone          pressed | receipts a team-match | on the ball s p25/med/p75/p90, one-touch % | let go m from the receipt p50/p75/p90, 10 m+ % | of 5 m+: in m med, forward m med")
for z in range(10):
    for pr in (False, True):
        k = (z, pr); t = T[k]
        if not t:
            continue
        print(f"  {NAMES[z // 2]:5s} {'wide  ' if z % 2 else 'centre'}  {'yes' if pr else 'no ':3s}   | {len(t) / tm:6.1f} | {q(t, .25):.1f} / {q(t, .5):.1f} / {q(t, .75):.1f} / {q(t, .9):.1f}, {100 * sum(x < 0.3 for x in t) / len(t):4.1f}% | "
              f"{q(D[k], .5):.1f} / {q(D[k], .75):.1f} / {q(D[k], .9):.1f}, {100 * sum(x >= 10 for x in D[k]) / len(D[k]):4.1f}% | {q(IN[k], .5):+.1f}, {q(FW[k], .5):+.1f}")

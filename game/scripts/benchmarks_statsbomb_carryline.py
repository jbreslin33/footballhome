#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_carryline.py — the line real 2015/16 Premier League carries take
(G5.128, game/DESIGN.md §8.229): every open-play Carry event 2 m+ long (StatsBomb: the ball moved by a
player at his feet between two other events), by the pass policy's zone at its start (m off their
line 0-18 / 18-35 / 35-52 / 52-70 / 70+ x centre |y| < 20.16 or wide) and whether StatsBomb marks him
under pressure. The line = the carry's angle off straight forward (toward their line), in 30 deg
sectors 0-30 / 30-60 / 60-90 / 90-120 / 120-150 / 150-180, split inward (toward the centre line) or
outward. Also: the share whose line points within 15 deg of the goal's centre ("at goal").

    benchmarks_statsbomb_carryline.py <events dir> [--table]

--table prints the permille rows (sectors in, then out) for game/src/ai/Possession.cpp.
Pitch: StatsBomb 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data, free with attribution to
StatsBomb (github.com/statsbomb/open-data).
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
h = collections.defaultdict(lambda: [0] * 12)
atg = collections.Counter(); n = collections.Counter(); ln_s = collections.Counter()
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Carry" or e.get("play_pattern", {}).get("name") == "From Kick Off": continue
        a, b = e["location"], e["carry"]["end_location"]
        x0, y0 = a[0] * SX, (a[1] - 40) * SY
        dx, dy = (b[0] - a[0]) * SX, (b[1] - a[1]) * SY
        L = math.hypot(dx, dy)
        if L < 2: continue
        d = 105 - x0
        zb = 0 if d < 18 else 1 if d < 35 else 2 if d < 52 else 3 if d < 70 else 4
        z = zb * 2 + (0 if abs(y0) < 20.16 else 1)
        pr = 1 if e.get("under_pressure") else 0
        ang = math.degrees(math.atan2(abs(dy), dx))               # 0 = straight forward
        inward = (dy * y0) < 0 or (y0 == 0)                       # toward the centre line
        s = min(5, int(ang // 30))
        h[(z, pr)][s + (0 if inward else 6)] += 1
        n[(z, pr)] += 1; ln_s[(z, pr)] += L
        g = math.degrees(math.atan2(-y0, d)); c = math.degrees(math.atan2(dy, dx))
        if abs(((c - g) + 180) % 360 - 180) < 15: atg[(z, pr)] += 1
tm = 2 * len(files)
ZN = ["0-18 c", "0-18 w", "18-35 c", "18-35 w", "35-52 c", "35-52 w", "52-70 c", "52-70 w", "70+ c", "70+ w"]
if "--table" in sys.argv:
    for pr in (0, 1):
        print(f"// {'pressed' if pr else 'free'}: zone rows, permille in 0-30..150-180 then out 0-30..150-180")
        for z in range(10):
            v = h[(z, pr)]; t = max(1, sum(v))
            r = [round(1000 * x / t) for x in v]; r[0] += 1000 - sum(r)
            print("    {" + ", ".join(f"{x:3d}" for x in r) + "},   // " + ZN[z] + f" ({t})")
    sys.exit()
print(f"{len(files)} matches; open-play carries 2 m+, a team-match | mean length | at goal (±15 deg) % | line off forward, % in 0-30/30-60/60-90/90-120/120-150/150-180 || out ...")
for pr in (0, 1):
    print("pressed" if pr else "free")
    for z in range(10):
        v = h[(z, pr)]; t = max(1, sum(v))
        print(f"  {ZN[z]:8s} {t/tm:5.1f} | {ln_s[(z,pr)]/t:4.1f} m | {100*atg[(z,pr)]/t:4.1f} | in " + " ".join(f"{100*x/t:4.1f}" for x in v[:6]) + " || out " + " ".join(f"{100*x/t:4.1f}" for x in v[6:]))

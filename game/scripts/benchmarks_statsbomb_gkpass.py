#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_gkpass.py — real passes to the passer's own keeper (G5.76,
game/DESIGN.md §8.177).

    python3 -I game/scripts/benchmarks_statsbomb_gkpass.py <events dir>

Open-play passes (set pieces out, crosses out) by the passer's metres off his own goal in 10 m
bins: all passes a team-match, the ones whose recipient is his own keeper (a player who carries
position "Goalkeeper" in that match), their share, length median, high % and completed %. The share
is Possession's physics.pass.gk_<bin> table (permille, to 0.1); fh-game-match prints the same as
TO OUR KEEPER. Passes by the keeper himself are left out (he never passes to himself).

Pitch: StatsBomb 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data (PL 2015/16), free with
attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, statistics, sys

SX, SY = 105 / 120, 68 / 80

files = [f for f in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))) if os.path.basename(f)[0].isdigit()]
n = collections.Counter(); k = collections.Counter(); hi = collections.Counter(); ok = collections.Counter()
lens = collections.defaultdict(list)
for f in files:
    E = json.load(open(f, encoding="utf8"))
    gk = {e["player"]["id"] for e in E if e.get("position", {}).get("name") == "Goalkeeper" and "player" in e}
    for e in E:
        if e["type"]["name"] != "Pass" or e["player"]["id"] in gk:
            continue
        p = e["pass"]
        if p.get("type") is not None or p.get("cross"):
            continue
        b = min(9, int(e["location"][0] * SX // 10))
        n[b] += 1
        if p.get("recipient", {}).get("id") in gk:
            k[b] += 1
            hi[b] += p.get("height", {}).get("name") == "High Pass"
            ok[b] += "outcome" not in p
            ex, ey = p["end_location"]; x, y = e["location"]
            lens[b].append(math.hypot((ex - x) * SX, (ey - y) * SY))
tm = 2 * len(files)
print(f"{len(files)} matches (StatsBomb PL 2015/16): open-play passes by outfielders (crosses out), to their own keeper")
print("   passer m off own goal | passes a team-match | to keeper a team-match | share permille | length med | high % | completed %")
for b in range(10):
    print(f"   {b * 10:2d}-{b * 10 + 10:<3d} | {n[b] / tm:5.1f} | {k[b] / tm:5.2f} | {1000 * k[b] / max(1, n[b]):6.1f} | "
          f"{statistics.median(lens[b]) if lens[b] else 0:4.1f} | {100 * hi[b] / max(1, k[b]):4.1f} | {100 * ok[b] / max(1, k[b]):5.1f}")
print(f"   all: {sum(k.values()) / tm:.2f} a team-match")
print("permille x1000 table: {" + ", ".join(str(round(1e6 * k[b] / max(1, n[b]) / 100) * 100) for b in range(10)) + "}")

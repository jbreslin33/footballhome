#!/usr/bin/env python3
"""benchmarks_statsbomb_longball_across.py — where across the pitch real long high passes from the back are aimed,
2015/16 Premier League (G5.213, game/DESIGN.md §8.319): the real line for the harness's LONG PASS ACROSS.

    python3 -I game/scripts/benchmarks_statsbomb_longball_across.py <events dir>

Open-play passes as benchmarks_statsbomb_ownthird_dir.py (set pieces out, not headed, outcomes none / Incomplete /
Out), by an outfielder from his own third (< 35 m off his goal line), High Pass, 30 m+ from kick to end. By the
kicker's spot across the pitch — centre (|y| < 10 m), half (10-20.16), wide (20.16+) — a team-match, and the share
that end in each lane, signed to his side of the pitch (his own touchline = +34): his wing (20.16+), his channel
(7-20.16), centre (-7..7), far channel, far wing; per lane the not completed % (Incomplete + Out). Per origin: the
end's |y| median, and metres on up the pitch (median). And the same by length 30-40 / 40-50 / 50+ m. Pitch: StatsBomb
120 x 80 scaled to 105 x 68. A centre kicker's "side" is the half of the pitch he stands in.

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Throw-in", "Goal Kick", "Kick Off")
ON = ("kicker centre", "kicker half", "kicker wide", "30-40 m", "40-50 m", "50+ m")
LN = ("his wing", "his channel", "centre", "far channel", "far wing")

files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
N = collections.Counter(); C = collections.Counter(); AY = collections.defaultdict(list); DX = collections.defaultdict(list)
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if e["type"]["name"] != "Pass" or "location" not in e: continue
        p = e["pass"]
        if p.get("type", {}).get("name") in SET or p.get("body_part", {}).get("name") == "Head": continue
        out = p.get("outcome", {}).get("name")
        if out not in (None, "Incomplete", "Out"): continue
        if e.get("position", {}).get("name") == "Goalkeeper" or p.get("height", {}).get("name") != "High Pass": continue
        x0, y0 = e["location"][0] * SX, (e["location"][1] - 40) * SY
        if x0 >= 35: continue
        x1, y1 = p["end_location"][0] * SX, (p["end_location"][1] - 40) * SY
        d = math.hypot(x1 - x0, y1 - y0)
        if d < 30: continue
        s = 1 if y0 >= 0 else -1; ye = y1 * s
        lane = 0 if ye >= 20.16 else 1 if ye >= 7 else 2 if ye > -7 else 3 if ye > -20.16 else 4
        for o in ((0 if abs(y0) < 10 else 1 if abs(y0) < 20.16 else 2), (3 if d < 40 else 4 if d < 50 else 5)):
            N[o] += 1; C[(o, lane, "n")] += 1; C[(o, lane, "bad")] += out is not None
            AY[o].append(abs(y1)); DX[o].append(x1 - x0)
tm = 2 * len(files)
md = lambda v: sorted(v)[len(v) // 2] if v else -1
print(f"LONG PASS ACROSS — StatsBomb PL 15/16, {len(files)} matches: open play, outfield, own third, High Pass, 30 m+")
for o, on in enumerate(ON):
    n = max(1, N[o])
    print(f"  {on:14s} {N[o] / tm:5.2f} a team-match | end |y| med {md(AY[o]):4.1f} | on up the pitch med {md(DX[o]):4.1f} | share % [not completed %]: " +
          "  ".join(f"{ln} {100 * C[(o, l, 'n')] / n:4.1f} [{100 * C[(o, l, 'bad')] / max(1, C[(o, l, 'n')]):3.0f}]" for l, ln in enumerate(LN)))
print("C++ rows {a team-match, end |y| med, on med, then share / bad x 5 lanes}:")
for o in range(6):
    n = max(1, N[o])
    print("  {" + ", ".join([f"{N[o] / tm:.2f}", f"{md(AY[o]):.1f}", f"{md(DX[o]):.1f}"] + [x for l in range(5) for x in (f"{100 * C[(o, l, 'n')] / n:.1f}", f"{100 * C[(o, l, 'bad')] / max(1, C[(o, l, 'n')]):.0f}")]) + "},")

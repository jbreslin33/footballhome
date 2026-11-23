#!/usr/bin/env python3
"""benchmarks_statsbomb_midloss.py — how real sides lose the ball in midfield, 2015/16 Premier League (G5.227,
game/DESIGN.md §8.333): the real line for the harness's MIDFIELD LOSSES.

    python3 -I game/scripts/benchmarks_statsbomb_midloss.py <events dir>

By the event's spot, m off the goal line its side attacks: 35-52 / 52-70 (and 18-35, 70+ beside them). A team-match:
  open-play passes by a foot (set pieces and headers out; outcomes none / Incomplete / Out) — tried, not completed,
  split ground (Ground + Low) / high and by length under 10 / 10-20 / 20-30 / 30+ m, and forward (within 45 deg of
  their goal) / square / back;
  Dispossessed, Miscontrol, and take-ons (Dribble) not completed.
Pitch: StatsBomb 120 x 80 scaled to 105 x 68.

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Throw-in", "Goal Kick", "Kick Off")
BN = ("18-35", "35-52", "52-70", "70+")
def band(x):   # x = StatsBomb location x (toward the goal attacked)
    tl = (120 - x) * SX
    return None if tl < 18 else 0 if tl < 35 else 1 if tl < 52 else 2 if tl < 70 else 3
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
C = collections.Counter()
for f in files:
    for e in json.load(open(f, encoding="utf8")):
        if "location" not in e: continue
        b = band(e["location"][0]); t = e["type"]["name"]
        if b is None: continue
        if t == "Pass":
            p = e["pass"]
            if p.get("type", {}).get("name") in SET or p.get("body_part", {}).get("name") == "Head": continue
            out = p.get("outcome", {}).get("name")
            if out not in (None, "Incomplete", "Out"): continue
            dx = (p["end_location"][0] - e["location"][0]) * SX; dy = (p["end_location"][1] - e["location"][1]) * SY
            d = math.hypot(dx, dy); bad = out is not None
            hi = "high" if p.get("height", {}).get("name") == "High Pass" else "ground"
            ln = "<10" if d < 10 else "10-20" if d < 20 else "20-30" if d < 30 else "30+"
            dr = "fwd" if dx >= abs(dy) else "back" if -dx >= abs(dy) else "square"
            for k in ("all", hi, ln, dr): C[(b, k, "n")] += 1; C[(b, k, "bad")] += bad
            if dr == "fwd": C[(b, "F", hi, ln, "n")] += 1; C[(b, "F", hi, ln, "bad")] += bad   # G5.229 (§8.336): the forward pass by height x length
        elif t in ("Dispossessed", "Miscontrol"): C[(b, t)] += 1
        elif t == "Dribble" and e["dribble"]["outcome"]["name"] == "Incomplete": C[(b, "takeon lost")] += 1
tm = 2 * len(files)
print(f"MIDFIELD LOSSES — StatsBomb PL 15/16, {len(files)} matches, a team-match, by the spot's m off the line attacked")
KS = ("all", "ground", "high", "<10", "10-20", "20-30", "30+", "fwd", "square", "back")
for b, bn in enumerate(BN):
    print(f"  {bn}: passes tried / not completed [%] — " + "; ".join(f"{k} {C[(b, k, 'n')] / tm:.1f} / {C[(b, k, 'bad')] / tm:.2f} [{100 * C[(b, k, 'bad')] / max(1, C[(b, k, 'n')]):.0f}]" for k in KS)
          + f" || dispossessed {C[(b, 'Dispossessed')] / tm:.2f}, miscontrol {C[(b, 'Miscontrol')] / tm:.2f}, take-on lost {C[(b, 'takeon lost')] / tm:.2f}")
print("FORWARD PASSES by height x length (G5.229): tried / not completed a team-match [%]")
LN = ("<10", "10-20", "20-30", "30+")
for b, bn in enumerate(BN):
    print(f"  {bn}: " + "; ".join(f"{h} {l} {C[(b, 'F', h, l, 'n')] / tm:.2f} / {C[(b, 'F', h, l, 'bad')] / tm:.2f} [{100 * C[(b, 'F', h, l, 'bad')] / max(1, C[(b, 'F', h, l, 'n')]):.0f}]" for h in ("ground", "high") for l in LN))
print("C++ forward rows {ground x 4 lengths (tried, bad), high x 4}:")
for b in range(4):
    print("  {" + ", ".join(f"{C[(b, 'F', h, l, 'n')] / tm:.2f}, {C[(b, 'F', h, l, 'bad')] / tm:.2f}" for h in ("ground", "high") for l in LN) + "},")
print("C++ rows {then tried, not completed x 10 kinds; dispossessed, miscontrol, take-on lost}:")
for b in range(4):
    print("  {" + ", ".join([f"{C[(b, k, 'n')] / tm:.1f}, {C[(b, k, 'bad')] / tm:.2f}" for k in KS] + [f"{C[(b, 'Dispossessed')] / tm:.2f}", f"{C[(b, 'Miscontrol')] / tm:.2f}", f"{C[(b, 'takeon lost')] / tm:.2f}"]) + "},")

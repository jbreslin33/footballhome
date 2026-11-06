#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_placement.py — where real shots go, and what
scores (game/DESIGN.md §8.135).

    python3 -I game/scripts/benchmarks_statsbomb_placement.py <data dir>

Open-play shots, Premier League 2015/16, 380 matches, StatsBomb Open Data (free
with attribution). The goal mouth is measured in its own units (yards → metres,
the 8 yd x 8 ft goal = 7.32 x 2.44 m), not the pitch's 120 x 80 scaling.

  ended          goal / saved / blocked / off target (wayward, post, saved off
                 target counted with off target) by distance band;
  on target      where it crossed the line: metres from the centre (0-1 / 1-2 /
                 2-3 / 3-3.66) x height (0-0.5 / 0.5-1.5 / 1.5-2.44); each cell's
                 share of on-target shots with a height, and its goal %;
  off target     how far outside the frame it went: metres wide of the post (or
                 over the bar), median and quartiles.
"""
import json, os, statistics as st, sys

YD = 0.9144
d = sys.argv[1]
ms = json.load(open(os.path.join(d, "matches.json")))
DB = [(0, 12), (12, 18), (18, 25), (25, 200)]
LAT = [0, 1, 2, 3, 3.66]
HT = [0, 0.5, 1.5, 2.44]
end = {b: {"Goal": 0, "Saved": 0, "Blocked": 0, "Off": 0} for b in DB}
cell = {}
wide, over = [], []
# G5.37: where unblocked shots crossed the goal line's plane, by distance band —
# the table the game draws a shot's crossing point from (a mouth-relative
# lateral bin x height bin, on and off target).
XL = [0, 1, 2, 3, 3.66, 5, 7, 10, 99]       # metres from the centre
XH = [0, 0.5, 1.5, 2.44, 4, 99]             # metres up
xing = {b: {} for b in DB}
# G5.37: the save curve — on-target shots with the keeper in the freeze frame:
# his gap to where it crossed (metres along the line from him, |dy|, and up),
# by distance band; save % per gap bin.
GAP = [0, 0.5, 1, 1.5, 2, 2.5, 3, 99]
sv = {}
for m in ms:
    for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
        if e["type"]["name"] != "Shot" or e["shot"]["type"]["name"] != "Open Play":
            continue
        sx, sy = (120 - e["location"][0]) * 105 / 120, (e["location"][1] - 40) * 68 / 80
        dist = (sx * sx + sy * sy) ** 0.5
        b = next(x for x in DB if x[0] <= dist < x[1])
        o = e["shot"]["outcome"]["name"]
        k = "Goal" if o == "Goal" else "Saved" if o in ("Saved", "Saved to Post") else "Blocked" if o == "Blocked" else "Off"
        end[b][k] += 1
        el = e["shot"].get("end_location") or []
        if len(el) < 2:
            continue
        lat = abs(el[1] - 40) * YD
        z = el[2] * YD if len(el) > 2 else None
        # A saved shot's end_location is where the keeper stopped it, not the
        # goal line: on target counts goals and saves wherever they ended (their
        # mouth position and height); off target only misses at the line.
        if z is not None and (k in ("Goal", "Saved") or (k == "Off" and el[0] >= 119)):
            on = k in ("Goal", "Saved")
            if on and (lat >= 3.66 or z >= 2.44):
                pass
            else:
                li = next(i for i in range(len(XL) - 1) if lat < XL[i + 1])
                hi = next(i for i in range(len(XH) - 1) if z < XH[i + 1])
                xing[b].setdefault("on" if on else "off", {})
                xing[b]["on" if on else "off"][(li, hi)] = xing[b]["on" if on else "off"].get((li, hi), 0) + 1
        if k in ("Goal", "Saved") and z is not None:
            gk = next((p for p in e["shot"].get("freeze_frame", []) if p["position"]["name"] == "Goalkeeper" and not p["teammate"]), None)
            if gk:
                gap = abs(el[1] - gk["location"][1]) * YD
                gi = next(i for i in range(len(GAP) - 1) if gap < GAP[i + 1])
                c2 = sv.setdefault((DB.index(b), gi), [0, 0]); c2[0] += 1; c2[1] += k == "Saved"
        if k in ("Goal", "Saved"):
            if z is None or lat > 3.66 or z > 2.44:
                continue
            li = next(i for i in range(4) if lat < LAT[i + 1] or i == 3)
            hi = next(i for i in range(3) if z < HT[i + 1] or i == 2)
            c = cell.setdefault((li, hi), [0, 0])
            c[0] += 1
            c[1] += k == "Goal"
        elif k == "Off" and el[0] >= 119:
            if lat > 3.66:
                wide.append(lat - 3.66)
            elif z is not None and z > 2.44:
                over.append(z - 2.44)

print("ENDED, open play, by distance (shots | goal / saved / blocked / off target %):")
tot = {"Goal": 0, "Saved": 0, "Blocked": 0, "Off": 0}
for b, v in end.items():
    n = sum(v.values())
    for k in tot:
        tot[k] += v[k]
    print(f"  {b[0]:2d}-{b[1] if b[1] < 200 else '':<3} {n:5d} | " + " / ".join(f"{100 * v[k] / n:4.1f}" for k in ("Goal", "Saved", "Blocked", "Off")))
n = sum(tot.values())
print(f"  all    {n:5d} | " + " / ".join(f"{100 * tot[k] / n:4.1f}" for k in ("Goal", "Saved", "Blocked", "Off")) +
      f"   (keeper saves {100 * tot['Saved'] / (tot['Saved'] + tot['Goal']):.1f}% of on target)")
cn = sum(c[0] for c in cell.values())
print(f"ON TARGET by where it crossed the line ({cn} with a height): share % / goal %")
print("  height \\ from centre     0-1 m        1-2 m        2-3 m      3-3.66 m")
for hi, lab in enumerate(("0-0.5 m", "0.5-1.5 m", "1.5-2.44 m")):
    row = []
    for li in range(4):
        c = cell.get((li, hi), [0, 0])
        row.append(f"{100 * c[0] / cn:5.1f} / {100 * c[1] / max(1, c[0]):4.1f}")
    print(f"  {lab:<10}          " + "   ".join(row))
for lab, v in (("wide of the post", wide), ("over the bar", over)):
    if len(v) > 4:
        q = st.quantiles(v, n=4)
        print(f"OFF TARGET {lab}: {len(v)} shots, median {st.median(v):.2f} m (p25 {q[0]:.2f}, p75 {q[2]:.2f})")

print("CROSSING TABLE (unblocked shots: P(on target) from the outcomes x the on-target spread from goals and saves,"
      " P(off) x the off-target spread from misses at the line), permille by band; lateral bins", XL[:-1], "height bins", XH[:-1])
for b in DB:
    v = end[b]; un = v["Goal"] + v["Saved"] + v["Off"]
    pon = (v["Goal"] + v["Saved"]) / un
    on, off = xing[b].get("on", {}), xing[b].get("off", {})
    non, noff = sum(on.values()), sum(off.values())
    cellp = lambda li, hi: pon * on.get((li, hi), 0) / non + (1 - pon) * off.get((li, hi), 0) / noff
    print(f"  // {b[0]}-{b[1] if b[1] < 200 else ''} m: on target {100 * pon:.1f}% of unblocked ({non} on, {noff} off with a height)")
    print("  {" + ", ".join("{" + ", ".join(f"{round(1000 * cellp(li, hi)):3d}" for hi in range(len(XH) - 1)) + "}" for li in range(len(XL) - 1)) + "},")

print("SAVE CURVE (on target, keeper in the freeze frame): save % by his gap along the line to where it crossed (m), n in brackets")
print("  band     " + "  ".join(f"{GAP[i]:.1f}-{GAP[i+1] if GAP[i+1] < 99 else '':<3}" for i in range(len(GAP) - 1)))
for bi, b in enumerate(DB):
    print(f"  {b[0]:2d}-{b[1] if b[1] < 200 else '':<3}  " + "  ".join(
        (f"{100 * sv[(bi, gi)][1] / sv[(bi, gi)][0]:4.0f}({sv[(bi, gi)][0]:3d})" if (bi, gi) in sv else "    -    ") for gi in range(len(GAP) - 1)))

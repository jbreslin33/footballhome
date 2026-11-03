#!/usr/bin/env python3
"""benchmarks_tracking_box.py — who is in the box when the ball is wide near goal
(game/DESIGN.md §8.107).

    python3 -I game/scripts/benchmarks_tracking_box.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177,
CC BY, data owner DFL (7 matches, TRACAB; loader from benchmarks_tracking.py).
5 Hz frames, ball in play, the ball 0-18 or 18-30 m off the attacked goal line
and 14 m+ off the middle: attackers in the box, in the 3-13 m central target
zone (|y| < 10), defenders in the box, and the two deepest defenders' distance
off their line. fh-game-match prints the same as BOX PRESENCE. FH original.
"""
import collections, glob, os, sys, multiprocessing
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt

class T(bt.ShapeTally):
    def __init__(self, length):
        super().__init__(length); self.c = collections.Counter()
    def period(self, frames):
        side = {}
        for t in (0, 1):
            ks = [p[0] for f in frames for p in f[4][t]] or [p[0] for f in frames for p in f[3][t]]
            side[t] = -1 if sum(ks) > 0 else 1
        for f in frames:
            a = f[2]; s = side[a]
            tl = self.half - s * f[0]; ay = abs(f[1])
            if ay < 14 or tl >= 30: continue
            k = "0-18" if tl < 18 else "18-30"
            box = tgt = dbox = 0
            for p in f[3][a]:
                ptl = self.half - s * p[0]
                if ptl < 16.5 and abs(p[1]) < 20.16: box += 1
                if 3 <= ptl <= 13 and abs(p[1]) < 10: tgt += 1
            for p in f[3][1 - a]:
                ptl = self.half - s * p[0]
                if ptl < 16.5 and abs(p[1]) < 20.16: dbox += 1
            ds = sorted(self.half - s * p[0] for p in f[3][1 - a])
            if len(ds) >= 2: self.c[k + "line1"] += ds[0]; self.c[k + "line2"] += ds[1]; self.c[k + "ln"] += 1
            c = self.c; c[k + "n"] += 1; c[k + "box"] += box; c[k + "tgt"] += tgt; c[k + "dbox"] += dbox; c[k + "tgt0"] += tgt == 0
    def result(self): return self.c

def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    bt.ShapeTally = T
    return bt.dfl_match(pos_path, info)[2]

files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(2) as pool:
    for r in pool.imap_unordered(one, files): c.update(r)
for k in ("0-18", "18-30"):
    n = c[k + "n"]
    print(f"ball {k} m off their line, |y| 14+ ({n} frames): attackers in the box {c[k+'box']/n:.2f}, in 3-13 m x |y|<10 {c[k+'tgt']/n:.2f} (none {100*c[k+'tgt0']/n:.0f}%), defenders in the box {c[k+'dbox']/n:.2f}; deepest defender {c[k+'line1']/max(1,c[k+'ln']):.1f} m, next {c[k+'line2']/max(1,c[k+'ln']):.1f} m off the line")

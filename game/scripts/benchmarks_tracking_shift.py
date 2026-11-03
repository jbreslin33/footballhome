#!/usr/bin/env python3
"""benchmarks_tracking_shift.py — how hard a real block follows the ball out of
possession (game/DESIGN.md §8.104).

    python3 -I game/scripts/benchmarks_tracking_shift.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177,
CC BY, data owner DFL (7 matches of 2022/23, TRACAB; see benchmarks_tracking.py,
whose loader this reuses). 5 Hz frames, ball in play, same team in possession
for the whole 1 s window, 9+ outfielders a side.

For the team WITHOUT the ball, over each 1 s window:
  middle      its outfielders' mean position: how far it moved (m/s), and the
              slope of that move on the ball's move (x on x, y on y; least
              squares through 0). 1.0 = the block moves metre for metre.
  back line   its deepest outfielder's height, the same slope on the ball's x.
  each man    the same slope for each outfielder on the ball (pooled).
The game's comparison is fh-game-match's HOLD SPOT SLIDES: the spot a man
holding shape is told to stand on, which the middle and the men follow.
"""
import collections, glob, math, multiprocessing, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt   # noqa: E402

BINS = (0.5, 1, 2, 4)


class ShiftTally(bt.ShapeTally):
    def __init__(self, length):
        super().__init__(length)
        self.c = collections.Counter()
        self.sp = collections.Counter()

    def period(self, frames):
        side = {}
        for t in (0, 1):
            ks = [p[0] for f in frames for p in f[4][t]] or [p[0] for f in frames for p in f[3][t]]
            side[t] = -1 if sum(ks) > 0 else 1
        # In-play speed of outfielders off the ball (both teams; the man of
        # the side in possession nearest the ball left out), 0.2 s steps:
        # fh-game-match's OFF THE BALL SPEED bins.
        for a, b in zip(frames, frames[1:]):
            for t in (0, 1):
                oa, ob = a[3][t], b[3][t]
                if len(oa) < 9 or len(oa) != len(ob):
                    continue
                skip = -1
                if t == a[2]:
                    skip = min(range(len(oa)), key=lambda j: (oa[j][0] - a[0]) ** 2 + (oa[j][1] - a[1]) ** 2)
                for j, (p, q) in enumerate(zip(oa, ob)):
                    if j == skip:
                        continue
                    v = math.hypot(q[0] - p[0], q[1] - p[1]) / bt.DT
                    if v > 12:
                        continue   # a swap in the list, not a man
                    self.c["s" + str(0 if v < 2 else 1 if v < 5 else 2)] += 1
                    self.c["sv"] += v; self.c["sn"] += 1
        # Where the block STANDS for each ball position (5 Hz frames, side
        # without the ball): ball by metres from that side's own goal line in
        # 15 m bins; its back line and middle, metres from the same line; its
        # middle's y on the ball's side by the ball's |y| in 10 m bins.
        for f in frames:
            d = 1 - f[2]
            of = f[3][d]
            if len(of) < 9 or len(f[3][f[2]]) < 9:
                continue
            s = side[d]
            bd = s * f[0] + self.half
            k = "L" + str(max(0, min(6, int(bd // 15))))
            self.c[k + "n"] += 1
            self.c[k + "line"] += min(s * p[0] for p in of) + self.half
            self.c[k + "mid"] += sum(s * p[0] for p in of) / len(of) + self.half
            self.c[k + "top"] += max(s * p[0] for p in of) + self.half
            ay = abs(f[1]); sy = 1 if f[1] >= 0 else -1
            ky = "Y" + str(min(3, int(ay // 10)))
            self.c[ky + "n"] += 1
            self.c[ky + "mid"] += sy * sum(p[1] for p in of) / len(of)
            self.c[ky + "ball"] += ay
            # Ball wide (|y| 24+): each defender's y toward the ball's side,
            # ranked from the far touchline (0) to the near (n-1), and the
            # far-most attacker's y: does the weak side come across?
            if ay >= 24 and len(of) == 10:
                ys = sorted(sy * p[1] for p in of)
                for r, y in enumerate(ys):
                    self.c[f"R{r}"] += y
                self.c["Rn"] += 1
                self.c["Rfar"] += min(sy * p[1] for p in f[3][f[2]])
                at = f[3][f[2]]
                if len(at) == 10:
                    for r, y in enumerate(sorted(sy * p[1] for p in at)):
                        self.c[f"A{r}"] += y
                    self.c["An"] += 1
        n = bt.SAMPLE_HZ
        for i in range(len(frames) - n):
            a, b = frames[i], frames[i + n]
            if any(frames[k][2] != a[2] for k in range(i, i + n + 1)):
                continue
            d = 1 - a[2]
            oa, ob = a[3][d], b[3][d]
            if len(oa) < 9 or len(ob) < 9 or len(a[3][a[2]]) < 9:
                continue
            bdx, bdy = b[0] - a[0], b[1] - a[1]
            cax = sum(p[0] for p in oa) / len(oa); cay = sum(p[1] for p in oa) / len(oa)
            cbx = sum(p[0] for p in ob) / len(ob); cby = sum(p[1] for p in ob) / len(ob)
            mx, my = cbx - cax, cby - cay
            v = math.hypot(mx, my)
            self.sp[bt.bucket(v, BINS)] += 1
            s = side[d]
            la = min(s * p[0] for p in oa); lb = min(s * p[0] for p in ob)
            c = self.c
            c["n"] += 1; c["v"] += v
            c["xx"] += bdx * bdx; c["yy"] += bdy * bdy
            c["mx"] += mx * bdx; c["my"] += my * bdy
            c["lx"] += (lb - la) * s * bdx
            if len(oa) == len(ob):   # same men, same order (sorted person ids)
                for p, q in zip(oa, ob):
                    c["px"] += (q[0] - p[0]) * bdx; c["py"] += (q[1] - p[1]) * bdy
                    c["pxx"] += bdx * bdx; c["pyy"] += bdy * bdy
                    c["pv"] += math.hypot(q[0] - p[0], q[1] - p[1]); c["pn"] += 1

    def result(self):
        return {"c": self.c, "sp": self.sp}


def one(pos_path):
    d = os.path.dirname(pos_path)
    mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    bt.ShapeTally = ShiftTally
    _, _, res = bt.dfl_match(pos_path, info)
    return res


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c, sp = collections.Counter(), collections.Counter()
    with multiprocessing.Pool(2) as pool:
        for r in pool.imap_unordered(one, files):
            c.update(r["c"]); sp.update(r["sp"])
    n = c["n"]
    print(f"{len(files)} matches, {n} one-second windows out of possession")
    print(f"  middle moves: mean {c['v'] / n:.2f} m/s; " + ", ".join(
        f"{lab} {100 * sp[k] / n:.0f}%" for k, lab in enumerate(("under 0.5", "0.5-1", "1-2", "2-4", "4+"))))
    print(f"  slope on the ball: middle x {c['mx'] / c['xx']:.2f}, y {c['my'] / c['yy']:.2f}; "
          f"back line x {c['lx'] / c['xx']:.2f}; each man x {c['px'] / c['pxx']:.2f}, y {c['py'] / c['pyy']:.2f}")
    print("  where it stands, ball m from its own goal: back line / middle / top man, m from the same line")
    for k in range(7):
        m = c[f"L{k}n"]
        if m:
            print(f"    ball {15 * k:3d}-{15 * k + 15:3d}: {c[f'L{k}line'] / m:5.1f} / {c[f'L{k}mid'] / m:5.1f} / "
                  f"{c[f'L{k}top'] / m:5.1f}  ({100 * m / sum(c[f'L{j}n'] for j in range(7)):.0f}%)")
    print("  middle's y toward the ball's side, by the ball's |y|")
    for k in range(4):
        m = c[f"Y{k}n"]
        if m:
            print(f"    |y| {10 * k:2d}-{10 * k + 10 if k < 3 else 34}: ball {c[f'Y{k}ball'] / m:4.1f}, middle {c[f'Y{k}mid'] / m:4.1f}")
    rn = c["Rn"]
    if rn:
        print("  ball |y| 24+, 10 defenders' y toward the ball, far to near: " +
              " ".join(f"{c[f'R{r}'] / rn:.1f}" for r in range(10)) + f"; far-most attacker {c['Rfar'] / rn:.1f}")
    an = c["An"]
    if an:
        print("  ball |y| 24+, 10 attackers' y toward the ball, far to near: " +
              " ".join(f"{c[f'A{r}'] / an:.1f}" for r in range(10)))
    print(f"  each man moves: mean {c['pv'] / c['pn']:.2f} m/s")
    sn = c["sn"]
    print(f"In play, outfielders off the ball (both sides), 0.2 s steps: under 2 {100 * c['s0'] / sn:.1f}%, "
          f"2-5 {100 * c['s1'] / sn:.1f}%, 5+ {100 * c['s2'] / sn:.1f}%; mean {c['sv'] / sn:.2f} m/s "
          f"= {c['sv'] / sn * 96 * 60 / 1000:.1f} km in 96 min")

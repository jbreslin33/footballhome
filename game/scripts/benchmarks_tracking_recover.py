#!/usr/bin/env python3
"""benchmarks_tracking_recover.py — how fast a real side gets back after it
loses the ball (game/DESIGN.md §8.128).

    python3 -I game/scripts/benchmarks_tracking_recover.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177,
CC BY, data owner DFL (7 matches of 2022/23, TRACAB; see benchmarks_tracking.py,
whose loader this reuses). 5 Hz frames, ball in play, 9+ outfielders a side.

For the side WITHOUT the ball, each outfielder over each 0.2 s step (the same
possession at both ends), by the seconds since his side lost it (the
possession flag last changed): his speed in bins (under 2 / 2-5 / 5+ m/s), the
share of steps at 5+ m/s running BACK (toward his own goal line, the back
component at least 0.7 of his speed), and the mean back component (m/s).
The same cut, off the ball both sides, as benchmarks_tracking_shift.py's
OFF THE BALL line, for the total. fh-game-match's RECOVERY line is this cut.
"""
import collections, glob, math, multiprocessing, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt   # noqa: E402

EDGES = (2, 4, 6, 10)   # seconds since the turnover: 0-2, 2-4, 4-6, 6-10, 10+
LABELS = ("0-2", "2-4", "4-6", "6-10", "10+")


class RecoverTally(bt.ShapeTally):
    def __init__(self, length):
        super().__init__(length)
        self.c = collections.Counter()

    def period(self, frames):
        side = {}
        for t in (0, 1):
            ks = [p[0] for f in frames for p in f[4][t]] or [p[0] for f in frames for p in f[3][t]]
            side[t] = -1 if sum(ks) > 0 else 1   # s * x + half = metres off t's own line
        since = 0
        for i, (a, b) in enumerate(zip(frames, frames[1:])):
            if i and a[2] != frames[i - 1][2]:
                since = 0
            else:
                since += 1
            if a[2] != b[2]:
                continue
            d = 1 - a[2]
            oa, ob = a[3][d], b[3][d]
            if len(oa) < 9 or len(oa) != len(ob) or len(a[3][a[2]]) < 9:
                continue
            k = bt.bucket(since * bt.DT, EDGES)
            s = side[d]
            z = "N" if s * a[0] + self.half < 40 else "F"   # the ball inside 40 m of their goal, or not
            near = math.hypot(s * a[0] + self.half, a[1]) < 20   # G5.85 (§8.186): ball within 20 m of their goal centre
            for p, q in zip(oa, ob):
                dx, dy = q[0] - p[0], q[1] - p[1]
                v = math.hypot(dx, dy) / bt.DT
                if v > 12:
                    continue   # a swap in the list, not a man
                back = -s * dx / bt.DT
                c = self.c
                c[f"{k}n"] += 1
                c[f"{k}s{0 if v < 2 else 1 if v < 5 else 2}"] += 1
                if v >= 5 and back >= 0.7 * v:
                    c[f"{k}fb"] += 1
                c[f"{k}back"] += back
                c[f"{k}v"] += v
                c[z + "n"] += 1
                c[f"{z}{k}n"] += 1
                if v >= 5 and back >= 0.7 * v:
                    c[f"{z}{k}fb"] += 1
                if v >= 5:
                    c[z + ("b" if back >= 0.7 * v else "u" if back <= -0.7 * v else "a")] += 1
                if near:   # G5.85: 5+ m/s by direction, and across (|dy| share) at 4+ / 5+ / 6+
                    c["Gn"] += 1
                    if v >= 5:
                        c["G" + ("b" if back >= 0.7 * v else "u" if back <= -0.7 * v else "a")] += 1
                    vy = abs(dy) / bt.DT
                    for cut in (4, 5, 6):
                        c[f"Gy{cut}"] += vy >= cut
                    c["Gvy"] += vy
            self.c["turn"] += 1 if since == 0 else 0

    def result(self):
        return {"c": self.c}


def one(pos_path):
    d = os.path.dirname(pos_path)
    mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    bt.ShapeTally = RecoverTally
    _, _, res = bt.dfl_match(pos_path, info)
    return res


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(2) as pool:
        for r in pool.imap_unordered(one, files):
            c.update(r["c"])
    tot = sum(c[f"{k}n"] for k in range(len(LABELS)))
    print(f"{len(files)} matches; the side without the ball, outfielders, 0.2 s steps, by seconds since it lost it")
    print("  since   share | under 2 / 2-5 / 5+ m/s | 5+ back | mean m/s, back m/s")
    for k, lab in enumerate(LABELS):
        n = c[f"{k}n"]
        if not n:
            continue
        print(f"  {lab:>5} {100 * n / tot:6.1f}% | {100 * c[f'{k}s0'] / n:5.1f} {100 * c[f'{k}s1'] / n:5.1f} "
              f"{100 * c[f'{k}s2'] / n:5.1f} | {100 * c[f'{k}fb'] / n:5.1f} | {c[f'{k}v'] / n:.2f}, {c[f'{k}back'] / n:+.2f}")
    n = tot
    print(f"  all     | {100 * sum(c[f'{k}s0'] for k in range(5)) / n:5.1f} {100 * sum(c[f'{k}s1'] for k in range(5)) / n:5.1f} "
          f"{100 * sum(c[f'{k}s2'] for k in range(5)) / n:5.1f} | {100 * sum(c[f'{k}fb'] for k in range(5)) / n:5.1f} | "
          f"{sum(c[f'{k}v'] for k in range(5)) / n:.2f}, {sum(c[f'{k}back'] for k in range(5)) / n:+.2f}")
    print("  5+ m/s by direction, % of the side's steps in the zone (back / up / across):")
    for z, lab in (("N", "ball inside 40 m of their goal"), ("F", "further out")):
        n = c[z + "n"]
        if n:
            print(f"    {lab}: {100 * n / tot:.1f}% of steps; {100 * c[z + 'b'] / n:.2f} / {100 * c[z + 'u'] / n:.2f} / {100 * c[z + 'a'] / n:.2f}")
    n = c["Gn"]
    if n:   # G5.85 (§8.186)
        print(f"    ball within 20 m of their goal centre: {100 * n / tot:.1f}% of steps; {100 * c['Gb'] / n:.2f} / {100 * c['Gu'] / n:.2f} / {100 * c['Ga'] / n:.2f}"
              f"; across component 4+ / 5+ / 6+ m/s {100 * c['Gy4'] / n:.2f} / {100 * c['Gy5'] / n:.2f} / {100 * c['Gy6'] / n:.2f}%, mean {c['Gvy'] / n:.2f} m/s")
    print("  5+ m/s back by seconds since it lost it, % of the zone's steps then (share of the zone's steps):")
    for z, lab in (("N", "inside 40 m"), ("F", "further out")):
        print(f"    {lab}: " + "; ".join(f"{LABELS[k]} {100 * c[f'{z}{k}fb'] / c[f'{z}{k}n']:.1f} ({100 * c[f'{z}{k}n'] / c[z + 'n']:.0f}%)"
                                         for k in range(len(LABELS)) if c[f"{z}{k}n"]))

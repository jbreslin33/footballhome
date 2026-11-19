#!/usr/bin/env python3
"""benchmarks_tracking_ballstate.py — what the ball is doing in play: on a man, contested, travelling, loose (G5.179,
game/DESIGN.md §8.285).

    python3 -I game/scripts/benchmarks_tracking_ballstate.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB 25 Hz, read at 5 Hz; loader as benchmarks_tracking_widepace.py). Every in-play frame (BallStatus 1):
- on the ball: a man within 2 m of it (2-D) and none of the other side within 2 m (the DFL cut of benchmarks_tracking_pressure.py);
- contested: men of both sides within 2 m;
- travelling: nobody within 2 m, the ball moving 4 m/s+ (0.2 s displacement);
- loose: nobody within 2 m, slower.
Seconds a team-match (half a match each), shares, and the runs (consecutive frames in one state): a match's count, median s.

§8.284: ours pass 9.70 times a minute in play (8.23), 6.2 s a pass cycle v 7.3 — less time between receptions.
"""
import collections, glob, math, multiprocessing, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt

ST = ("on the ball", "contested", "travelling", "loose")


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    team_of = {home: 0, guest: 1}
    ball = {}; pl = collections.defaultdict(dict); who = {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    sec = None; isb = False; skip = True; cur = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if n % 5: continue
            if isb:
                st = re.search(r'BallStatus="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7])) if st and st.group(1) == "1" else None
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    c = collections.Counter(); runs = collections.defaultdict(list)
    c["matches"] = 1
    prev = None; run = 0
    for key in sorted(ball):
        b = ball[key]; b0 = ball.get((key[0], key[1] - 5))
        fr = pl.get(key)
        if b is None or b0 is None or not fr:
            if prev is not None: runs[prev].append(run)
            prev = None; run = 0; continue
        near = [False, False]
        for pid, p in fr.items():
            if math.hypot(p[0] - b[0], p[1] - b[1]) < 2: near[who[pid]] = True
        v = math.hypot(b[0] - b0[0], b[1] - b0[1]) / 0.2
        sx = 1 if near[0] and near[1] else 0 if near[0] or near[1] else 2 if v >= 4 else 3
        c[sx] += 1
        if sx == prev: run += 1
        else:
            if prev is not None: runs[prev].append(run)
            prev = sx; run = 1
    if prev is not None: runs[prev].append(run)
    return c, dict(runs)


def q(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(p * len(xs)))] if xs else float("nan")


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    tot = collections.Counter(); R = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for c, r in pool.imap_unordered(one, files):
            tot.update(c)
            for k, v in r.items(): R[k].extend(v)
    m = tot["matches"]; n = sum(tot[i] for i in range(4))
    print(f"{m} DFL matches, {n / 5 / 60 / m:.1f} min in play a match (frames with the ball moving known)")
    for i in range(4):
        print(f"  {ST[i]:12s} {tot[i] / 5 / m:6.0f} s a match  {100 * tot[i] / n:5.1f}%  runs {len(R[i]) / m:6.0f} a match, med {q(R[i], .5) / 5:.1f} s, p75 {q(R[i], .75) / 5:.1f} s")

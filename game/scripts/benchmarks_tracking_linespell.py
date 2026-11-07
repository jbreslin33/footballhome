#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_linespell.py (G5.52, DESIGN §8.153) — usage: <DFL dir>
# Real: does the DEFENDING line's height go by the possession, as the attackers' depth does (§8.146)?
# Their offside line L (second-last of theirs, keeper in, or the ball), m off their goal, ball ours 18-52 m
# out, 5 Hz; L's offset from its median at the ball's 2 m band; over spells of 5 s+ (one possession):
# between-spell sd / within-spell sd and the spell offset's p10 … p90 (+ = higher, further from goal).
# DFL tracking (Bassek et al. 2025, CC BY); frames from benchmarks_tracking_gapspread.one.
import collections, glob, os, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking_gapspread as gs
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    fr = {}
    with multiprocessing.Pool(3) as pool:
        for rows in pool.imap_unordered(gs.one, files):
            for r in rows:
                sp = r[5][:r[5].index("DFL-OBJ")]
                fr[(sp, r[8])] = (r[2], r[7])   # (ball band, L) once a frame
    bb = collections.defaultdict(list)
    for band, L in fr.values(): bb[band].append(L)
    med = {k: sorted(v)[len(v) // 2] for k, v in bb.items()}
    sp = collections.defaultdict(list)
    for (s, t), (band, L) in fr.items(): sp[s].append((band, L - med[band]))
    for lo, hi, nm in ((9, 18, "ball 18-35"), (18, 26, "ball 35-52"), (9, 26, "ball 18-52")):
        ss = [[o for b, o in v if lo <= b < hi] for v in sp.values()]
        ss = [v for v in ss if len(v) >= 25]
        means = [sum(v) / len(v) for v in ss]
        mu = sum(means) / len(means)
        bsd = (sum((m - mu) ** 2 for m in means) / len(means)) ** .5
        wsd = (sum(sum((o - m) ** 2 for o in v) for v, m in zip(ss, means)) / sum(len(v) for v in ss)) ** .5
        q = sorted(means); qq = lambda f: q[min(len(q) - 1, int(f * len(q)))]
        print(f"{nm}: {len(ss)} spells of 5 s+; their line's spell offset between-sd {bsd:.1f} / within-sd {wsd:.1f} m; "
              f"p10 / p25 / p50 / p75 / p90 {qq(.1):.1f} / {qq(.25):.1f} / {qq(.5):.1f} / {qq(.75):.1f} / {qq(.9):.1f}")

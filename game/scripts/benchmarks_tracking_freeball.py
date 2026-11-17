#!/usr/bin/env python3
"""game/scripts/benchmarks_tracking_freeball.py — the ball between men (G5.150, game/DESIGN.md §8.254).

    python3 -I game/scripts/benchmarks_tracking_freeball.py <DFL dir>

At 5 Hz, in play (BallStatus 1): the ball is AT A MAN when its nearest player is within 2 m (the DFL cut of
benchmarks_tracking_pressure.py's spells), else FREE. A free run = consecutive free in-play frames. For each: how
long, how it started (the ball's speed over the 0.2 s into it: struck 8 m/s+ / a touch under 8), and how it
ended — the next man within 2 m is of the side last within 2 m before it (same) / the other side (other) / the
ball went dead first (dead). Per team-minute in play (each run counted for the side that had it last): runs,
their mean / median seconds, the share of in-play time free. fh-game-match prints the same as FREE BALL.

Data: DFL / Bundesliga tracking, Bassek et al. 2025 (idsse, CC BY 4.0). FH original.
"""
import collections, glob, math, os, re, statistics, sys, multiprocessing

SET = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = open(glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0], encoding="utf8").read()
    teams = set(re.findall(r'<Team [^>]*TeamId="([^"]+)"', info))
    ball = {}; pl = collections.defaultdict(dict); tm_of = {}
    sec = cur = None; isb = False; skip = True
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if n % 5: continue
            if isb:
                st = re.search(r'BallStatus="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7]), st is not None and st.group(1) == "1")
            else:
                pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = SET.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in teams
            if not skip and not isb: cur = pid; tm_of[pid] = tid
    runs = []; live = 0
    for sc in sorted({k[0] for k in ball}):
        ks = sorted(k for k in ball if k[0] == sc)
        last_side = None; start = None; v0 = 0.0; prev = None
        for k in ks:
            bx, by, ok = ball[k]
            if not ok:
                if start is not None and last_side is not None: runs.append(((k[1] - start) / 25, v0, "dead", last_side))
                start = None; last_side = None; prev = None; continue
            live += 1
            fr = pl.get(k, {})
            nd, nw = 99.0, None
            for pid, (x, y) in fr.items():
                e = math.hypot(x - bx, y - by)
                if e < nd: nd, nw = e, pid
            if nd <= 2.0:
                side = tm_of.get(nw)
                if start is not None and last_side is not None:
                    runs.append(((k[1] - start) / 25, v0, "same" if side == last_side else "other", last_side))
                start = None; last_side = side
            elif start is None and last_side is not None:
                start = k[1]
                v0 = math.hypot(bx - prev[0], by - prev[1]) * 5 if prev else 0.0
            prev = (bx, by)
    return runs, live / 5.0 / 60.0, sorted(teams)


def main():
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(2) as P:
        res = P.map(one, files)
    runs = [r for x in res for r in x[0]]; mins = sum(x[1] for x in res)   # in-play minutes over all matches
    tmin = 2 * mins   # team-minutes in play
    free = sum(r[0] for r in runs)
    print(f"{len(files)} DFL matches, {mins / len(files):.1f} min in play a match: FREE BALL (nobody within 2 m, in play) {100 * free / (mins * 60):.1f}% of in-play time")
    for name, sel in (("all", runs), ("struck 8+ m/s", [r for r in runs if r[1] >= 8]), ("a touch <8 m/s", [r for r in runs if r[1] < 8])):
        if not sel: continue
        ds = [r[0] for r in sel]
        ends = collections.Counter(r[2] for r in sel)
        print(f"   {name:15s} {len(sel) / tmin:5.2f} a team-minute | mean {statistics.mean(ds):.2f} s med {statistics.median(ds):.2f} | ends same / other / dead "
              + " / ".join(f"{100 * ends[e] / len(sel):.0f}" for e in ("same", "other", "dead")) + "%")


if __name__ == "__main__":
    main()

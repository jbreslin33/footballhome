#!/usr/bin/env python3
"""game/scripts/benchmarks_tracking_firsttouch.py — the first touch, elite (G5.80 receiving).

    python3 -I game/scripts/benchmarks_tracking_firsttouch.py <DFL dir>

A RECEPTION: a ball in play on the ground (Z < 0.5 m) that nobody has been within 1.5 m of for the last
0.4 s, moving 3 m/s+, reaches a player (within 1.0 m). At that frame (the touch): the incoming speed
(the ball over the 0.24 s before), the ball's speed off the touch (0.12-0.32 s after) as a share of the
incoming one, the ball's gap from him 0.5 s and 1.0 s later, the touch's direction against his own
travel (the ball's move over 0.12-0.32 s v his velocity: on / across / back), and whether he still has
it 1 s later (he is still the nearest man within 1.5 m) — by the incoming speed and by pressure (an
opponent within 3 m at the touch). What World's first touch draws.

Data: DFL / Bundesliga tracking, Bassek et al. 2025 (idsse, CC BY 4.0). FH original.
"""
import collections, glob, math, os, re, statistics, sys, multiprocessing

SP = [(3, 8), (8, 12), (12, 16), (16, 99)]


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = open(glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0], encoding="utf8").read()
    teams = set(re.findall(r'<Team [^>]*TeamId="([^"]+)"', info))
    halves = collections.defaultdict(lambda: {"ball": {}, "pl": {}})
    sec = cur = None; isb = False; skip = True
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip:
                continue
            a = s.split('"'); n = int(a[1]); H = halves[sec]
            if isb:
                z = re.search(r' Z="([-\d.]+)"', s)
                if 'BallStatus="1"' in s and z:
                    H["ball"][n] = (float(a[5]), float(a[7]), float(z.group(1)))
            else:
                H["pl"][cur][0][n] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in teams
            if not skip and not isb:
                cur = pid; halves[sec]["pl"][pid] = ({}, tid)
    out = collections.defaultdict(list)
    for H in halves.values():
        ball, pl = H["ball"], H["pl"]
        frames = sorted(ball)
        def near(n, r):
            bx, by, _ = ball[n]; best, bd = None, r
            for pid, (pos, tm) in pl.items():
                if n in pos:
                    dd = math.hypot(pos[n][0] - bx, pos[n][1] - by)
                    if dd < bd: best, bd = pid, dd
            return best, bd
        free_since = None; last_touch = -999; last_tm = None
        # which way each side attacks this half: the side whose men stand at lower x on average defends -x
        mx = collections.defaultdict(list)
        for pid, (pos, tm) in pl.items():
            xs = [v[0] for v in list(pos.values())[:500]]
            if xs: mx[tm].append(sum(xs) / len(xs))
        sgn = {}
        if len(mx) == 2:
            (ta, va), (tb, vb) = list(mx.items())
            a, b2 = sum(va) / len(va), sum(vb) / len(vb)
            sgn = {ta: 1 if a < b2 else -1, tb: 1 if b2 < a else -1}
        for n in frames:
            if ball[n][2] >= 0.5:
                free_since = None; continue
            who, dd = near(n, 1.5)
            if who is not None and free_since is None: last_tm = pl[who][1]
            if who is None:
                if free_since is None: free_since = n
                continue
            if free_since is not None and n - free_since >= 10 and n - last_touch > 25:
                # the touch: his closest frame over the next 0.32 s (a 10 m/s ball moves 0.4 m a frame)
                pos0 = pl[who][0]; m0, dm = n, dd
                for k in range(n, n + 9):
                    if k in ball and k in pos0:
                        e = math.hypot(ball[k][0] - pos0[k][0], ball[k][1] - pos0[k][1])
                        if e < dm: m0, dm = k, e
                if dm > 1.0:
                    free_since = None; continue
                n = m0; fs = free_since
                ok = all(k in ball for k in (n - 6, n - 1, n + 3, n + 8, n + 12, n + 25))
                pos = pl[who][0]
                if ok and all(k in pos for k in (n - 3, n + 3, n + 12, n + 25)):
                    vin = math.hypot(ball[n - 1][0] - ball[n - 6][0], ball[n - 1][1] - ball[n - 6][1]) * 25 / 5
                    if vin >= 3:
                        ox, oy = (ball[n + 8][0] - ball[n + 3][0]) * 5, (ball[n + 8][1] - ball[n + 3][1]) * 5
                        vout = math.hypot(ox, oy)
                        px, py = (pos[n + 3][0] - pos[n - 3][0]) * 25 / 6, (pos[n + 3][1] - pos[n - 3][1]) * 25 / 6
                        sp = math.hypot(px, py)
                        if vout > 0.5 and sp > 0.8:
                            c = (ox * px + oy * py) / (vout * sp)
                            dirn = "on" if c > 0.5 else "back" if c < -0.5 else "across"
                        else:
                            dirn = "still"
                        g5 = math.hypot(ball[n + 12][0] - pos[n + 12][0], ball[n + 12][1] - pos[n + 12][1])
                        g10 = math.hypot(ball[n + 25][0] - pos[n + 25][0], ball[n + 25][1] - pos[n + 25][1])
                        w25, _ = near(n + 25, 1.5)
                        tm = pl[who][1]; prs = 99; pq = None
                        for qid, (qpos, qtm) in pl.items():
                            if qtm != tm and n in qpos:
                                e = math.hypot(qpos[n][0] - pos[n][0], qpos[n][1] - pos[n][1])
                                if e < prs: prs, pq = e, qpos
                        # G5.81 (§8.182) PRESSED TOUCH: the touch's line v the line to the nearest opponent at
                        # the touch (toward < 60 deg, away > 120), and 0.5 s on whether the ball is nearer him
                        # than the receiver, and the opponent's gap to it.
                        rel = None
                        if pq is not None and prs < 3 and (n + 12) in pq:
                            qx, qy = pq[n][0] - pos[n][0], pq[n][1] - pos[n][1]
                            if vout > 0.5 and prs > 0.1:
                                cq = (ox * qx + oy * qy) / (vout * prs)
                                rel = "toward" if cq > 0.5 else "away" if cq < -0.5 else "across"
                            else:
                                rel = "still"
                            q5 = math.hypot(ball[n + 12][0] - pq[n + 12][0], ball[n + 12][1] - pq[n + 12][1])
                            rel = (rel, q5 < g5, q5, prs)
                        # G5.82 (§8.183) RECEIVER SPACE: his nearest opponent at the touch and at the release (the
                        # first frame nobody was within 1.5 m of the ball: ~0.1 s after the kick)
                        prs0 = 99
                        if fs in pos:
                            for qid, (qpos, qtm) in pl.items():
                                if qtm != tm and fs in qpos:
                                    prs0 = min(prs0, math.hypot(qpos[fs][0] - pos[fs][0], qpos[fs][1] - pos[fs][1]))
                        b = next(i for i, (lo, hi) in enumerate(SP) if lo <= vin < hi)
                        rx = 52.5 + sgn.get(tm, 1) * pos[n][0]
                        same0 = math.hypot(pq[fs][0] - pos[fs][0], pq[fs][1] - pos[fs][1]) if pq is not None and fs in pq and fs in pos else 99
                        rec = (vout / vin, vout, g5, g10, w25 == who, dirn, prs < 3, rel, (prs, prs0, (n - fs) / 25, last_tm == tm, rx, math.hypot(ball[n][0] - ball[fs][0], ball[n][1] - ball[fs][1]), same0, (math.hypot(pos[fs][0] - ball[fs][0], pos[fs][1] - ball[fs][1]) - math.hypot(pos[n][0] - ball[fs][0], pos[n][1] - ball[fs][1])) if fs in pos else None))
                        out[b].append(rec); out["P" if prs < 3 else "F"].append(rec); out["all"].append(rec)
                last_touch = n
            free_since = None
    return out


def summ(v, name):
    if not v:
        return
    q = lambda xs, p: sorted(xs)[min(len(xs) - 1, int(len(xs) * p))]
    keep = 100 * sum(1 for r in v if r[4]) / len(v)
    dirs = collections.Counter(r[5] for r in v)
    print(f"  {name:10s} n {len(v):5d} | off-touch speed / incoming p25 {q([r[0] for r in v], .25):.2f} med {q([r[0] for r in v], .5):.2f} p75 {q([r[0] for r in v], .75):.2f}"
          f" | off-touch m/s med {q([r[1] for r in v], .5):4.1f} | gap 0.5 s p25 {q([r[2] for r in v], .25):.2f} med {q([r[2] for r in v], .5):.2f} p75 {q([r[2] for r in v], .75):.2f} p90 {q([r[2] for r in v], .9):.2f}"
          f" | gap 1 s med {q([r[3] for r in v], .5):.2f} | kept 1 s {keep:.1f}% | touch on/across/back/still % "
          + " / ".join(f"{100 * dirs[k] / len(v):.0f}" for k in ("on", "across", "back", "still")))


def main():
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(2) as P:
        res = P.map(one, files)
    tot = collections.defaultdict(list)
    for r in res:
        for k, v in r.items():
            tot[k] += v
    print(f"{len(files)} DFL matches: receptions (a free ground ball 3 m/s+ reaching a man), {len(tot['all']) / (2 * len(files)):.1f} a team-match; controlled {sum(1 for r in tot['all'] if r[0] < 0.7) / (2 * len(files)):.1f}")
    for i, (lo, hi) in enumerate(SP):
        summ(tot[i], f"in {lo}-{hi if hi < 99 else '+'}")
    summ(tot["P"], "pressed"); summ(tot["F"], "free"); summ(tot["all"], "all")
    # CONTROLLED: the touch took pace off (off-touch under 70% of the incoming) — the first touches a
    # receiver keeps, not one-touch passes or balls running past a man.
    print("CONTROLLED first touches (off-touch < 0.7 x incoming):")
    for i, (lo, hi) in enumerate(SP):
        summ([r for r in tot[i] if r[0] < 0.7], f"in {lo}-{hi if hi < 99 else '+'}")
    summ([r for r in tot["P"] if r[0] < 0.7], "pressed"); summ([r for r in tot["F"] if r[0] < 0.7], "free"); summ([r for r in tot["all"] if r[0] < 0.7], "all")
    # G5.81 (§8.182) PRESSED TOUCH: controlled touches with an opponent inside 3 m, by his distance
    for lo, hi in ((0, 1.5), (1.5, 3), (0, 3)):
        v = [r[7] for r in tot["all"] if r[0] < 0.7 and r[7] is not None and lo <= r[7][3] < hi]
        if not v:
            continue
        c = collections.Counter(x[0] for x in v)
        q = lambda xs, p: sorted(xs)[min(len(xs) - 1, int(len(xs) * p))]
        print(f"PRESSED TOUCH opp {lo}-{hi} m: n {len(v)} ({len(v) / (2 * len(files)):.1f} a team-match) | touch toward / across / away / still % "
              + " / ".join(f"{100 * c[k] / len(v):.0f}" for k in ("toward", "across", "away", "still"))
              + f" | 0.5 s on: ball nearer him than the receiver {100 * sum(1 for x in v if x[1]) / len(v):.0f}% | his gap to it p25 {q([x[2] for x in v], .25):.2f} med {q([x[2] for x in v], .5):.2f}")

    # G5.82 (§8.183) RECEIVER SPACE: every reception (controlled or not) and the controlled ones — his nearest
    # opponent at the release and at the touch, binned; how much the gap closed over the ball's travel
    BN = [(0, 1.5), (1.5, 3), (3, 5), (5, 8), (8, 99)]
    for name, v in (("all", [r[8] for r in tot["all"]]), ("controlled", [r[8] for r in tot["all"] if r[0] < 0.7])):
        q = lambda xs, p: sorted(xs)[min(len(xs) - 1, int(len(xs) * p))]
        v0 = [x for x in v if x[1] < 99]
        fmt = lambda xs, i: " / ".join(f"{100 * sum(1 for x in xs if lo <= x[i] < hi) / len(xs):.0f}" for lo, hi in BN)
        print(f"RECEIVER SPACE {name}: n {len(v)} ({len(v) / (2 * len(files)):.1f} a team-match) | nearest opp at the touch % 0-1.5/1.5-3/3-5/5-8/8+ {fmt(v, 0)}"
              f" med {q([x[0] for x in v], .5):.2f} | at the release {fmt(v0, 1)} med {q([x[1] for x in v0], .5):.2f}"
              f" | closed med {q([x[1] - x[0] for x in v0], .5):.2f} m over med {q([x[2] for x in v0], .5):.2f} s"
              f" | of those inside 3 m at the touch, at the release 5 m+ {100 * sum(1 for x in v0 if x[0] < 3 and x[1] >= 5) / max(1, sum(1 for x in v0 if x[0] < 3)):.0f}%")
        pm = [x for x in v if x[3]]; ot = [x for x in v if not x[3]]
        i3 = lambda xs: 100 * sum(1 for x in xs if x[0] < 3) / max(1, len(xs))
        zs = [[x for x in v if lo <= x[4] < hi] for lo, hi in ((-99, 35), (35, 70), (70, 999))]
        print(f"   from a mate's pass {len(pm) / (2 * len(files)):.1f} a team-match, inside 3 m {i3(pm):.1f}% | other {len(ot) / (2 * len(files)):.1f}, inside 3 m {i3(ot):.1f}%"
              f" | by the receiver's m off own goal 0-35/35-70/70+: n " + " / ".join(f"{len(z) / (2 * len(files)):.1f}" for z in zs) + ", inside 3 m " + " / ".join(f"{i3(z):.0f}" for z in zs) + "%")
        RB = ((0, 5), (5, 10), (10, 15), (15, 99))
        sb = [[x for x in pm if lo <= x[6] < hi] for lo, hi in RB]
        print("   mate's pass, the man nearest at the touch by his m at the release 0-5/5-10/10-15/15+: share " + " / ".join(f"{100 * len(z) / max(1, len(pm)):.0f}" for z in sb)
              + "% | closed med " + " / ".join(f"{q([x[6] - x[0] for x in z], .5):.2f}" if z else "-" for z in sb) + " m | inside 3 m at the touch " + " / ".join(f"{i3(z):.0f}" for z in sb) + "%")
        LB = ((0, 10), (10, 20), (20, 30), (30, 999))
        r3 = lambda xs: 100 * sum(1 for x in xs if x[1] < 3) / max(1, len(xs))
        ls = [[x for x in pm if lo <= x[5] < hi] for lo, hi in LB]
        print("   mate's pass by the ball's travel release->touch 0-10/10-20/20-30/30+ m: n " + " / ".join(f"{len(z) / (2 * len(files)):.1f}" for z in ls)
              + " | inside 3 m at the touch " + " / ".join(f"{i3(z):.0f}" for z in ls) + "% | at the release " + " / ".join(f"{r3(z):.0f}" for z in ls) + "%")
        # G5.98 (§8.199) PASS PACE: the ball's travel time release->touch and its mean speed, by travel; to a mate / to an opponent
        lo_ = [[x for x in ot if lo <= x[5] < hi] for lo, hi in LB]
        tq = lambda z: f"{q([x[2] for x in z], .25):.2f}/{q([x[2] for x in z], .5):.2f}/{q([x[2] for x in z], .75):.2f}" if z else "-"
        cm = lambda z: f"{q([x[7] for x in z if x[7] is not None], .25):.2f}/{q([x[7] for x in z if x[7] is not None], .5):.2f}/{q([x[7] for x in z if x[7] is not None], .75):.2f}" if z else "-"
        print("   COMES TO IT (mate's pass: the receiver's metres nearer the release spot at the touch than at the release, p25/med/p75) by travel 0-10/10-20/20-30/30+: " + " | ".join(cm(z) for z in ls))
        print("   PASS PACE by travel 0-10/10-20/20-30/30+ m, s p25/med/p75: mate's pass " + " | ".join(tq(z) for z in ls)
              + " || to them " + " | ".join(tq(z) for z in lo_) + f" (n " + " / ".join(f"{len(z) / (2 * len(files)):.1f}" for z in lo_) + ")")


if __name__ == "__main__":
    main()

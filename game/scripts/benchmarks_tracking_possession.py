#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_possession.py (G5.14, DESIGN §8.111) — usage: <DFL dir>
# Real: the side IN possession (BallPossession, in play, 5 Hz) — where its outfielders stand by
# where the ball is. Ball in 10 m bands of metres from the goal it attacks (0 = their line); for
# each role the mean metres from that line, and the team's back man / middle / front man. Then a
# least-squares fit of the middle on the ball (both from OUR goal): middle = slope * ball + offset,
# and each role's mean gap from the middle over the bands 25-75 (what the game's possessionX
# depth_k stretches); by possession age (s since the spell began) the middle and its running; and
# which smoothing of the ball (EMA over T s) the middle follows best (fits ours_ball_tau_s).
# DFL tracking (Bassek et al. 2025, CC BY); loader as benchmarks_tracking_channel. All men off
# the ball and the carrier alike (one of ten).
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ROLE = {"IVL": "CB", "IVR": "CB", "IVZ": "CB", "LV": "FB", "RV": "FB", "DML": "DM/CM", "DMR": "DM/CM", "DMZ": "DM/CM",
        "DLM": "DM/CM", "DRM": "DM/CM", "ZO": "AM", "OLM": "WIDE", "ORM": "WIDE", "LM": "WIDE", "RM": "WIDE", "HL": "WIDE",
        "HR": "WIDE", "LA": "WIDE", "RA": "WIDE", "STL": "ST", "STR": "ST", "STZ": "ST"}
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
    half = length / 2; team_of = {home: 0, guest: 1}
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
                st = re.search(r'BallStatus="(\d)"', s); po = re.search(r'BallPossession="(\d)"', s)
                if st and st.group(1) == "1" and po and po.group(1) in "12": ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1)
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    own = {}
    for sc in {k[0] for k in ball}:
        xs = {0: [], 1: []}
        for (s2, n), ps in pl.items():
            if s2 != sc or n % 250: continue
            for pid, p in ps.items():
                if pid in keepers: xs[who[pid]].append(p[0])
        for tm in (0, 1): own[(sc, tm)] = -1 if (sum(xs[tm]) / max(1, len(xs[tm]))) < 0 else 1
    c = collections.Counter()
    # possession age: seconds since this side's spell (in play, unbroken at 5 Hz) began
    age = {}
    for (sc, n) in sorted(ball):
        att = ball[(sc, n)][2]; p = ball.get((sc, n - 5))
        age[(sc, n)] = age[(sc, n - 5)] + 0.2 if p and p[2] == att and (sc, n - 5) in age else 0.0
    # G5.14: which smoothing of the ball does the middle follow? EMA of the ball (pitch x, y) over
    # TAUS seconds, run through every in-play frame of a half; fit middle on it in possession frames.
    TAUS = (0, 1, 2, 3, 4, 6, 8)
    ema = {}
    for sc in {k[0] for k in ball}:
        e = {T: None for T in TAUS}; last = None
        for n in sorted(k[1] for k in ball if k[0] == sc):
            bx, by, att = ball[(sc, n)]
            if last is None or n - last > 25: e = {T: (bx, by) for T in TAUS}
            else:
                for T in TAUS:
                    al = 1.0 if T == 0 else min(1.0, 0.2 * (n - last) / 5 / T)
                    e[T] = (e[T][0] + al * (bx - e[T][0]), e[T][1] + al * (by - e[T][1]))
            last = n; ema[(sc, n)] = dict(e)
    for (sc, n), (bx, by, att) in ball.items():
        g0 = -own[(sc, att)]
        cur0 = [p for pid, p in pl.get((sc, n), {}).items() if pid not in keepers and who[pid] == att]
        dcur = [p for pid, p in pl.get((sc, n), {}).items() if pid not in keepers and who[pid] != att]
        if len(dcur) >= 9:   # G5.15 (§8.112): the side without it — its middle on the smoothed ball (attack-direction x)
            dmx = sum(p[0] for p in dcur) / len(dcur) * g0
            for T in TAUS:
                ex = ema[(sc, n)][T][0] * g0
                c[("dN", T)] += 1; c[("dX", T)] += ex; c[("dY", T)] += dmx; c[("dXX", T)] += ex * ex; c[("dXY", T)] += ex * dmx; c[("dYY", T)] += dmx * dmx
        if len(cur0) >= 9:
            mx = sum(p[0] for p in cur0) / len(cur0) * g0; my = sum(p[1] for p in cur0) / len(cur0)
            for T in TAUS:
                ex = ema[(sc, n)][T][0] * g0; ey = ema[(sc, n)][T][1]
                c[("eN", T)] += 1; c[("eX", T)] += ex; c[("eY", T)] += mx; c[("eXX", T)] += ex * ex; c[("eXY", T)] += ex * mx; c[("eYY", T)] += mx * mx
                c[("yN", T)] += 1; c[("yX", T)] += ey; c[("yY", T)] += my; c[("yXX", T)] += ey * ey; c[("yXY", T)] += ey * my; c[("yYY", T)] += my * my

        a = age[(sc, n)]; ab = min(6, int(a))
        cur = pl.get((sc, n), {}); nxt = pl.get((sc, n + 5), {})
        ms = []; spd = []; fr = []
        for pid, (x, y) in cur.items():
            if pid in keepers or who[pid] != att: continue
            ms.append(half - x * g0)
            if pid in nxt:
                vx = (nxt[pid][0] - x) / 0.2; vy = (nxt[pid][1] - y) / 0.2
                spd.append(((vx * vx + vy * vy) ** 0.5, vx * g0))
                if ROLE.get(pos_of.get(pid, ""), "?") in ("AM", "WIDE", "ST"): fr.append((half - x * g0, vx * g0, (vx * vx + vy * vy) ** 0.5))
        if len(ms) >= 9 and len(spd) >= 9 and fr:   # G5.15 (§8.112): the front men (AM/WIDE/ST) by age
            mid = sum(ms) / len(ms)
            for ftl, fv, fs in fr:
                c[("fn", ab)] += 1; c[("fa", ab)] += mid - ftl; c[("fv", ab)] += fv; c[("f5", ab)] += fs >= 5; c[("f5f", ab)] += fv >= 5
        if len(ms) >= 9 and len(spd) >= 9:
            c[("an", ab)] += 1; c[("am", ab)] += sum(ms) / len(ms)
            c[("av", ab)] += sum(s[1] for s in spd) / len(spd)
            c[("a5", ab)] += sum(1 for s in spd if s[0] >= 5) / len(spd)
            c[("a5f", ab)] += sum(1 for s in spd if s[1] >= 5) / len(spd)
            c[("abt", ab)] += 2 * half - (half - bx * g0)

        g = -own[(sc, att)]
        btl = half - bx * g
        k = min(9, int(btl // 10))
        tls = []
        for pid, (x, y) in pl.get((sc, n), {}).items():
            if pid in keepers or who[pid] != att: continue
            tl = half - x * g; tls.append(tl)
            r = ROLE.get(pos_of.get(pid, ""), "?")
            c[("n", k, r)] += 1; c[("s", k, r)] += tl
        dtl = []   # G5.15 (§8.112): the side WITHOUT it, same band, metres from its own line (the line the ball attacks)
        for pid, (x, y) in pl.get((sc, n), {}).items():
            if pid in keepers or who[pid] == att: continue
            tl = half - x * g; dtl.append(tl)
            r = ROLE.get(pos_of.get(pid, ""), "?")
            c[("dn", k, r)] += 1; c[("ds", k, r)] += tl
        if len(dtl) >= 9: c[("df", k)] += 1; c[("dmid", k)] += sum(dtl) / len(dtl)
        if len(dtl) >= 9 and 25 <= btl < 75:
            dm = sum(dtl) / len(dtl)
            for pid, (x, y) in pl.get((sc, n), {}).items():
                if pid in keepers or who[pid] == att: continue
                r = ROLE.get(pos_of.get(pid, ""), "?"); c[("dgn", r)] += 1; c[("dg", r)] += (half - x * g) - dm
        if len(tls) < 9: continue
        mid = sum(tls) / len(tls)
        c[("f", k)] += 1; c[("back", k)] += max(tls); c[("mid", k)] += mid; c[("front", k)] += min(tls)
        # fit from OUR goal: B = 2*half - btl, M = 2*half - mid
        B = 2 * half - btl; M = 2 * half - mid
        c["N"] += 1; c["B"] += B; c["M"] += M; c["BB"] += B * B; c["BM"] += B * M
        if 25 <= btl < 75:
            for pid, (x, y) in pl.get((sc, n), {}).items():
                if pid in keepers or who[pid] != att: continue
                r = ROLE.get(pos_of.get(pid, ""), "?"); c[("gn", r)] += 1; c[("g", r)] += mid - (half - x * g)
    return c
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files): c.update(r)
    roles = ("CB", "FB", "DM/CM", "AM", "WIDE", "ST")
    print(f"{len(files)} matches, {c['N']} frames in possession; metres from THEIR line (ball band = ball m from it)")
    print("  band    frames  back/middle/front   " + "  ".join(f"{r:>6}" for r in roles))
    for k in range(10):
        f = c[("f", k)]
        if not f: continue
        print(f"  {10*k:2d}-{10*k+10:<3d} {f:7d}  {c[('back',k)]/f:5.1f}/{c[('mid',k)]/f:5.1f}/{c[('front',k)]/f:5.1f}   " +
              "  ".join(f"{c[('s',k,r)]/c[('n',k,r)]:6.1f}" if c[("n", k, r)] else "     -" for r in roles))
    N = c["N"]; sl = (c["BM"] - c["B"] * c["M"] / N) / (c["BB"] - c["B"] ** 2 / N); off = c["M"] / N - sl * c["B"] / N
    print(f"  middle on the ball, from our goal: slope {sl:.2f}, offset {off:.1f} m (pitch-centred: middle_x = {sl:.2f} * ball_x + {off - (1 - sl) * 52.5:.1f})")
    print("  each role ahead of the middle, ball 25-75 m off their line: " + "; ".join(f"{r} {c[('g',r)]/c[('gn',r)]:+.1f}" for r in roles if c[("gn", r)]))
    print("  by possession age (s since the spell began): frames / ball m from OUR goal / middle m from THEIR line / middle's forward speed / men 5+ m/s / men 5+ m/s forward")
    for k in range(7):
        m = c[("an", k)]
        if m: print(f"    {k}{'+' if k == 6 else '-' + str(k + 1)} s {m:7d}  ball {c[('abt',k)]/m:5.1f}  middle {c[('am',k)]/m:5.1f}  fwd {c[('av',k)]/m:+.2f} m/s  5+ {100*c[('a5',k)]/m:4.1f}%  5+ fwd {100*c[('a5f',k)]/m:4.1f}%")
        f = c[("fn", k)]
        if f: print(f"           front men (AM/WIDE/ST): ahead of the middle {c[('fa',k)]/f:+5.1f} m  fwd {c[('fv',k)]/f:+.2f} m/s  5+ {100*c[('f5',k)]/f:4.1f}%  5+ fwd {100*c[('f5f',k)]/f:4.1f}%")
    print("  middle (attack-direction x / y) on an EMA of the ball over T s, possession frames: T: slope x, offset, R2 | slope y, R2")
    for T in (0, 1, 2, 3, 4, 6, 8):
        out = []
        for a in ("e", "y"):
            N = c[(a+"N",T)]; sx = c[(a+"X",T)]; sy = c[(a+"Y",T)]
            vx = c[(a+"XX",T)] - sx*sx/N; vy = c[(a+"YY",T)] - sy*sy/N; cxy = c[(a+"XY",T)] - sx*sy/N
            out.append((cxy/vx, sy/N - cxy/vx*sx/N, cxy*cxy/(vx*vy)))
        print(f"    T {T}: x {out[0][0]:.2f}, {out[0][1]:+.1f}, R2 {out[0][2]:.3f} | y {out[1][0]:.2f}, R2 {out[1][2]:.3f}")
    print("  DEFENDING SHAPE (the side without it; metres from its own line, ball band = ball m from that line):")
    print("  band    frames  middle   " + "  ".join(f"{r:>6}" for r in roles))
    for k in range(10):
        f = c[("df", k)]
        if not f: continue
        print(f"  {10*k:3d}-{10*k+10:<3d} {f:7d}  {c[('dmid',k)]/f:5.1f}    " + "  ".join(f"{c[('ds',k,r)]/max(1,c[('dn',k,r)]):6.1f}" for r in roles))
    print("  each role ahead of the middle (toward the ball's end), ball 25-75 m off the line: " + "; ".join(f"{r} {c[('dg',r)]/max(1,c[('dgn',r)]):+.1f}" for r in roles))
    print("  middle (attack-direction x, of the side WITHOUT it) on an EMA of the ball over T s: T: slope, offset, R2")
    for T in (0, 1, 2, 3, 4, 6, 8):
        N = c[("dN", T)]
        if not N: continue
        X, Y, XX, XY, YY = (c[(k, T)] for k in ("dX", "dY", "dXX", "dXY", "dYY"))
        sl = (N * XY - X * Y) / (N * XX - X * X); of = (Y - sl * X) / N
        r2 = (N * XY - X * Y) ** 2 / ((N * XX - X * X) * (N * YY - Y * Y))
        print(f"    T {T}: x {sl:.2f}, {of:+.1f}, R2 {r2:.3f}")

#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_lag.py (G5.42, DESIGN §8.142) — usage: <DFL dir>
# Real: does the block stand where the ball IS, or where it is going? The side WITHOUT the ball
# (the other side in BallPossession, in play, 5 Hz), SETTLED (6 s+ since it lost it, as
# benchmarks_tracking_possession.py), by the ball's 10 m band off the defenders' own line and the
# ball's speed toward that line over the last second (m/s, + = coming at them): each role's mean
# metres off its own line. If real men drop ahead of a ball coming at them, the "coming" rows stand
# deeper than the "still" rows at the same band; the settled table (§8.131) is the blend.
# Roles as benchmarks_tracking_possession. DFL tracking (Bassek et al. 2025, CC BY).
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ROLE = {"IVL": 0, "IVR": 0, "IVZ": 0, "LV": 1, "RV": 1, "DML": 2, "DMR": 2, "DMZ": 2, "DLM": 2, "DRM": 2, "ZO": 3,
        "OLM": 4, "ORM": 4, "LM": 4, "RM": 4, "HL": 4, "HR": 4, "LA": 4, "RA": 4, "STL": 5, "STR": 5, "STZ": 5}   # as benchmarks_tracking_possession
NAMES = ["CB", "FB", "DM/CM", "AM", "WIDE", "ST"]
VB = [(-99, -2, "away"), (-2, 2, "still"), (2, 5, "coming 2-5"), (5, 99, "coming 5+")]   # for the side in possession: back / still / forward 2-5 / forward 5+
def vbin(v):
    for i, (lo, hi, _) in enumerate(VB):
        if lo <= v < hi: return i
    return 1
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
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1 if (st and st.group(1) == "1" and po and po.group(1) in "12") else -1)
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
    last_lost = {}   # (sec, defending team) -> frame it last lost the ball
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        if att < 0: continue
        dfd = 1 - att
        prev = ball.get((sc, n - 5))
        if prev is None or prev[2] != att: last_lost[(sc, dfd)] = n
        then = ball.get((sc, n - 25))
        if then is None or then[2] < 0: continue
        g = own[(sc, dfd)]
        btl = half - bx * g; btl0 = half - then[0] * g
        v = btl0 - btl                                      # m/s toward their line over the last second
        b = min(9, max(0, int(btl // 10))); vb = vbin(v)
        fr = pl.get((sc, n), {})
        # The side IN possession (every in-play frame, as POSSESSION SHAPE §8.111): metres off THEIR line by role,
        # and its most advanced outfielder against the defenders' offside line (second-last, keeper in).
        if then[2] == att:
            c[("pn", b, vb)] += 1
            for pid, (x, y) in fr.items():
                if who.get(pid) != att or pid in keepers: continue
                r = ROLE.get(pos_of.get(pid))
                if r is None: continue
                c[("ps", b, vb, r)] += half - x * g; c[("pk", b, vb, r)] += 1
            dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == dfd)
            fa = [half - x * g for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers]
            if len(dl) >= 2 and fa:
                c[("fn", b, vb)] += 1; c[("fl", b, vb)] += dl[1]; c[("ff", b, vb)] += min(fa)
        if n - last_lost.get((sc, dfd), n) < 150: continue      # settled: 6 s at 25 Hz
        c[("n", b, vb)] += 1
        for pid, (x, y) in fr.items():
            if who.get(pid) != dfd or pid in keepers: continue
            r = ROLE.get(pos_of.get(pid))
            if r is None: continue
            c[("s", b, vb, r)] += half - x * g; c[("k", b, vb, r)] += 1
    return c
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files): c.update(r)
    print(f"{len(files)} DFL matches: the defending side SETTLED (6 s+), by the ball's band and its speed toward their line over 1 s")
    print("   band   ball        frames   " + "  ".join(f"{x:>6s}" for x in NAMES))
    for b in range(10):
        for vb, (_, _, lab) in enumerate(VB):
            n = c[("n", b, vb)]
            if n < 20: continue
            row = "  ".join(f"{c[('s',b,vb,r)]/c[('k',b,vb,r)]:6.1f}" if c[("k", b, vb, r)] else "     -" for r in range(6))
            print(f"   {b*10:2d}-{b*10+10:<3d} {lab:11s} {n:6d}   {row}")
    print(f"\nthe side IN possession (all in-play frames), by the ball's band off THEIR line and its speed toward it over 1 s (+ = going forward)")
    print("   band   ball        frames   " + "  ".join(f"{x:>6s}" for x in NAMES) + "   offside line / front man")
    for b in range(10):
        for vb, (_, _, lab) in enumerate(VB):
            n = c[("pn", b, vb)]
            if n < 20: continue
            row = "  ".join(f"{c[('ps',b,vb,r)]/c[('pk',b,vb,r)]:6.1f}" if c[("pk", b, vb, r)] else "     -" for r in range(6))
            fn = max(1, c[("fn", b, vb)])
            print(f"   {b*10:2d}-{b*10+10:<3d} {lab:11s} {n:6d}   {row}   {c[('fl',b,vb)]/fn:5.1f} / {c[('ff',b,vb)]/fn:5.1f}")

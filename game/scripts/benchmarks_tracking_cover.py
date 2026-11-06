#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_cover.py (G5.41, DESIGN §8.141) — usage: <DFL dir>
# Real: cover in the back pair. The side WITHOUT the ball (the other side in BallPossession, in play,
# 5 Hz) with exactly two centre-backs on: by the ball's 10 m band off the defenders' own line, the
# depth gap between the pair (higher − deeper, m), the share of frames where the deeper one is the
# one farther from the ball across (|y − ball y|), and the gap split that way (far − near, signed:
# + = the far man is deeper); the pair's mean against the band's settled CB spot is §8.131's table.
# DFL tracking (Bassek et al. 2025, CC BY); loader as benchmarks_tracking_box.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
CB = {"IVL", "IVR", "IVZ"}
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
    for (sc, n), (bx, by, att) in ball.items():
        dfd = 1 - att; g = own[(sc, dfd)]          # the defenders' own goal is at x = g·half
        btl = half - bx * g                          # ball metres off the defenders' own line
        b = min(9, max(0, int(btl // 10)))
        fr = pl.get((sc, n), {})
        cbs = [(half - x * g, abs(y - by)) for pid, (x, y) in fr.items() if who.get(pid) == dfd and pos_of.get(pid) in CB and pid not in keepers]
        if len(cbs) != 2: continue
        (d1, a1), (d2, a2) = cbs
        cbp = [(half - x * g, y) for pid, (x, y) in fr.items() if who.get(pid) == dfd and pos_of.get(pid) in CB and pid not in keepers]
        att_out = [(half - x * g, y) for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers]
        if att_out:   # their most advanced outfielder: is the deeper CB the one nearer him?
            lx, ly = min(att_out)
            n1 = (cbp[0][0] - lx) ** 2 + (cbp[0][1] - ly) ** 2; n2 = (cbp[1][0] - lx) ** 2 + (cbp[1][1] - ly) ** 2
            deep_near = (cbp[0][0] < cbp[1][0]) == (n1 < n2)
            c[("mk", b)] += 1; c[("dn", b)] += deep_near; c[("lx", b)] += lx - min(cbp[0][0], cbp[1][0])
        far, near = ((d1, d2) if a1 > a2 else (d2, d1))
        c[("n", b)] += 1; c[("gap", b)] += abs(d1 - d2); c[("fd", b)] += (far < near); c[("split", b)] += near - far
        c[("mean", b)] += (d1 + d2) / 2
    return c
files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files): c.update(r)
print(f"{len(files)} DFL matches: the defending back pair (two CBs on), by the ball's 10 m band off their own line")
for b in range(10):
    n = c[("n", b)]
    if not n: continue
    print(f"   {b*10:2d}-{b*10+10:<3d} frames {n:6d}: pair mean {c[('mean',b)]/n:5.1f} m, depth gap {c[('gap',b)]/n:4.1f} m; the far man deeper {100*c[('fd',b)]/n:3.0f}%, near − far {c[('split',b)]/n:+4.1f} m; the deeper is the nearer to their front man {100*c[('dn',b)]/max(1,c[('mk',b)]):3.0f}%, their front man {c[('lx',b)]/max(1,c[('mk',b)]):+4.1f} m above the deeper")

#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_gapspread.py (G5.46, DESIGN §8.146) — usage: <DFL dir>
# Real: what makes each role's gap to their offside line spread? The side in possession, ball ours and
# 18-52 m off their goal, 5 Hz. For each role, the variance of the gap and the share explained by
# (a) the ball's band (2 m), (b) + the ball's side v the man's (same / far / central, |y| 0-10-20-34),
# (c) the man (his match mean), (d) the spell (his mean over one possession), and the gap by side.
# DFL tracking (Bassek et al. 2025, CC BY), loader as benchmarks_tracking_runs.py.
import collections, glob, os, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking_linegap as lg
from benchmarks_tracking_runs import ROLE, NAMES
import benchmarks_tracking as bt, re
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
    rows = []; spell = 0; last = None
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        if att < 0: last = None; continue
        if last != (sc, att): spell += 1; last = (sc, att); s0 = n
        dfd = 1 - att; g = own[(sc, dfd)]
        btl = half - bx * g
        if btl < 18 or btl >= 52: continue
        fr = pl.get((sc, n), {})
        dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == dfd)
        if len(dl) < 2: continue
        L = min(dl[1], btl)
        byg = by * g   # ball y in the attackers' frame (sign only matters v the man's)
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers: continue
            r = ROLE.get(pos_of.get(pid), -1)
            if r < 0: continue
            gap = (half - x * g) - L
            if gap > 70: continue
            side = 2 if abs(by) < 10 else (0 if (by > 0) == (y > 0) else 1)   # 0 same side as the ball, 1 far, 2 ball central
            rows.append((r, gap, int(btl // 2), side, mid + pid, f"{mid}{spell}{pid}", min(2, int(abs(y) // 12)), L, (n - s0) / 25.0))
    return rows
def ve(rows, keyf):
    grp = collections.defaultdict(list)
    for rw in rows: grp[keyf(rw)].append(rw[1])
    mu = sum(rw[1] for rw in rows) / len(rows)
    tot = sum((rw[1] - mu) ** 2 for rw in rows)
    within = sum(sum((v - sum(vs) / len(vs)) ** 2 for v in vs) for vs in grp.values())
    return 1 - within / tot, (tot / len(rows)) ** .5
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    rows = []
    with multiprocessing.Pool(3) as pool:
        for rr in pool.imap_unordered(one, files): rows += rr
    print(f"{len(files)} DFL matches: WHAT SPREADS THE GAP (ball ours, 18-52 m off their goal, men 0-70 m short or past)")
    print("   role   sd m | share of variance explained by: ball band | + ball side v his | + his |y| | the man (match) | man + band | the spell (one possession)")
    for r in range(6):
        rr = [x for x in rows if x[0] == r]
        if len(rr) < 100: continue
        e1, sd = ve(rr, lambda w: w[2]); e2, _ = ve(rr, lambda w: (w[2], w[3])); e3, _ = ve(rr, lambda w: (w[2], w[3], w[6]))
        e4, _ = ve(rr, lambda w: w[4]); e5, _ = ve(rr, lambda w: (w[4], w[2])); e6, _ = ve(rr, lambda w: w[5])
        print(f"   {NAMES[r]:6s} {sd:4.1f} |   {100*e1:4.0f}%    |  {100*e2:4.0f}%    |  {100*e3:4.0f}%  |   {100*e4:4.0f}%   |  {100*e5:4.0f}%   |   {100*e6:4.0f}%")
    print("   gap median by the ball's side v his (same / far / ball central), ball 18-35 | 35-52:")
    for r in (1, 3, 4, 5):
        out = []
        for zlo, zhi in ((9, 17), (17, 26)):
            for sd in (0, 1, 2):
                v = sorted(x[1] for x in rows if x[0] == r and x[3] == sd and zlo <= x[2] < zhi)
                out.append(f"{v[len(v)//2]:4.1f}" if v else "   -")
        print(f"     {NAMES[r]:6s} " + " ".join(out[:3]) + "  |  " + " ".join(out[3:]))

    print("   SPELLS of 5 s+ in range (each man's frames in one possession): between-spell sd / within-spell sd / spell share;")
    print("   spell mean gap by THEIR LINE's height (spell mean L, m off their goal: <25 / 25-35 / 35-45 / 45+) and by s since we won it at the spell's first frame in range (<5 / 5-15 / 15+)")
    sp = collections.defaultdict(list)
    for x in rows: sp[x[5]].append(x)
    for r in range(6):
        ss = [v for v in sp.values() if v[0][0] == r and len(v) >= 25]
        if len(ss) < 30: continue
        means = [sum(w[1] for w in v) / len(v) for v in ss]
        mu = sum(means) / len(means)
        bsd = (sum((m - mu) ** 2 for m in means) / len(means)) ** .5
        wsd = (sum(sum((w[1] - m) ** 2 for w in v) for v, m in zip(ss, means)) / sum(len(v) for v in ss)) ** .5
        byL = collections.defaultdict(list); byT = collections.defaultdict(list)
        for v, m in zip(ss, means):
            Lm = sum(w[7] for w in v) / len(v); byL[0 if Lm < 25 else 1 if Lm < 35 else 2 if Lm < 45 else 3].append(m)
            t0 = v[0][8]; byT[0 if t0 < 5 else 1 if t0 < 15 else 2].append(m)
        md = lambda a: f"{sorted(a)[len(a)//2]:4.1f}({len(a):3d})" if a else "   -     "
        print(f"     {NAMES[r]:6s} {bsd:4.1f} / {wsd:4.1f} / {100*bsd**2/(bsd**2+wsd**2):3.0f}%  | L " + " ".join(md(byL[i]) for i in range(4)) + "  | t " + " ".join(md(byT[i]) for i in range(3)))
    print("   SPELL OFFSET (5 s+): his spell mean gap less his role's median gap at each frame's ball band, p10 / p25 / p50 / p75 / p90:")
    for r in range(6):
        rr = [x for x in rows if x[0] == r]
        bandmed = {}
        bb = collections.defaultdict(list)
        for x in rr: bb[x[2]].append(x[1])
        for k, v in bb.items(): v.sort(); bandmed[k] = v[len(v) // 2]
        offs = sorted(sum(w[1] - bandmed[w[2]] for w in v) / len(v) for v in sp.values() if v[0][0] == r and len(v) >= 25)
        if len(offs) < 30: continue
        q = lambda f: offs[min(len(offs) - 1, int(f * len(offs)))]
        print(f"     {NAMES[r]:6s} {q(.1):5.1f} / {q(.25):5.1f} / {q(.5):5.1f} / {q(.75):5.1f} / {q(.9):5.1f}   ({len(offs)} spells)")
    # team or man? each man's spell offset v the mean of his mates' offsets in the same possession (AM/WIDE/ST/FB/DM, 5 s+)
    spoff = {}
    for r in range(6):
        rr = [x for x in rows if x[0] == r]
        bb = collections.defaultdict(list)
        for x in rr: bb[x[2]].append(x[1])
        bm_ = {k: sorted(v)[len(v) // 2] for k, v in bb.items()}
        for key, v in sp.items():
            if v[0][0] == r and len(v) >= 25: spoff[key] = (r, sum(w[1] - bm_[w[2]] for w in v) / len(v))
    byp = collections.defaultdict(list)
    for key, (r, o) in spoff.items():
        if r >= 1: byp[key[:key.index("DFL-OBJ")]].append(o)
    xs = []; ys = []
    for k, os_ in byp.items():
        if len(os_) < 3: continue
        for i, o in enumerate(os_):
            xs.append(o); ys.append((sum(os_) - o) / (len(os_) - 1))
    mx = sum(xs) / len(xs); my = sum(ys) / len(ys)
    cov = sum((a - mx) * (b - my) for a, b in zip(xs, ys)); vx = sum((a - mx) ** 2 for a in xs); vy = sum((b - my) ** 2 for b in ys)
    print(f"   TEAM OR MAN: corr(his spell offset, his mates' mean in the same possession) = {cov/(vx*vy)**.5:.2f} over {len(xs)} man-spells")

#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_linegap.py (G5.46, DESIGN §8.146) — usage: <DFL dir>
# Real: when THEIR offside line moves, what do the side in possession's men near it do? Line L and a
# man A are metres off their goal line; gap = A - L (Law 11 line: second-last of theirs, keeper in, or
# the ball). Over the last 1 s: dL (line step: + = it stepped up, away from its goal; - = it dropped)
# and each man's dA. By dL band and role, for men 0-15 m short (or past) 1 s ago: mean dA, mean
# d(gap), the slope dA/dL (1 = he keeps his gap, 0 = he holds his ground), the gap now; the front
# man's gap by dL band; split by the ball going forward 2+ m/s or not (§8.145). DFL tracking (Bassek
# et al. 2025, CC BY), loader as benchmarks_tracking_runs.py.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES
DB = ["drop 2+", "drop .5-2", "still", "up .5-2", "up 2+"]
def db(dl): return 0 if dl < -2 else 1 if dl < -.5 else 2 if dl <= .5 else 3 if dl <= 2 else 4
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
    def line_at(sc, n, dfd, g):
        b = ball.get((sc, n)); fr = pl.get((sc, n))
        if b is None or not fr: return None
        dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == dfd)
        if len(dl) < 2: return None
        return min(dl[1], half - b[0] * g)
    c = collections.Counter(); G = collections.defaultdict(list); F = collections.defaultdict(list)
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        if att < 0: continue
        then = ball.get((sc, n - 25))
        if then is None or then[2] != att: continue        # ours for the whole second
        dfd = 1 - att; g = own[(sc, dfd)]
        L1 = line_at(sc, n, dfd, g); L0 = line_at(sc, n - 25, dfd, g)
        if L1 is None or L0 is None: continue
        btl = half - bx * g
        if btl < 18 or btl >= 52: continue                  # the ball 18-52 m off their goal: a line to play on
        bm = 1 if (half - then[0] * g) - btl >= 2 else 0
        dL = L1 - L0; k = db(dL)
        c[("n", bm, k)] += 1
        fr = pl[(sc, n)]; fp = pl.get((sc, n - 25), {})
        best = None
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers or pid not in fp: continue
            r = ROLE.get(pos_of.get(pid), -1)
            if r < 0: continue
            A1 = half - x * g; A0 = half - fp[pid][0] * g
            g0 = A0 - L0; g1 = A1 - L1
            if best is None or g1 < best: best = g1
            if g0 > 15: continue
            dA = A1 - A0
            for rr in (r, 9):
                c[("m", bm, k, rr)] += 1; c[("dA", bm, k, rr)] += dA; c[("dg", bm, k, rr)] += g1 - g0
                c[("xy", bm, rr)] += dA * dL; c[("xx", bm, rr)] += dL * dL; c[("sx", bm, rr)] += dL; c[("sy", bm, rr)] += dA; c[("s1", bm, rr)] += 1
                G[(bm, k, rr)].append(round(g1, 1))
        if best is not None: F[(bm, k)].append(round(best, 1))
    return c, G, F
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); G = collections.defaultdict(list); F = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, gg, ff in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in gg.items(): G[k2] += v
            for k2, v in ff.items(): F[k2] += v
    tm = 2 * len(files)
    def q(v):
        v = sorted(v); return f"{v[len(v)//4]:5.1f}/{v[len(v)//2]:5.1f}/{v[3*len(v)//4]:5.1f}" if v else "    -"
    print(f"{len(files)} DFL matches: THEIR LINE MOVES, OUR MEN NEAR IT (ball ours 1 s, 18-52 m off their goal, 5 Hz)")
    for bm in (0, 1):
        print(("ball NOT going forward" if bm == 0 else "ball going forward 2+ m/s") + ":")
        tot = sum(c[("n", bm, k)] for k in range(5))
        print("   line over 1 s     share   front man gap p25/med/p75 | men 0-15 m short 1 s ago: dA / d(gap) / gap now p25/med/p75")
        for k in range(5):
            m = max(1, c[("m", bm, k, 9)])
            print(f"   {DB[k]:10s}  {100*c[('n',bm,k)]/max(1,tot):5.1f}%   {q(F[(bm,k)])}    | {c[('dA',bm,k,9)]/m:5.2f} / {c[('dg',bm,k,9)]/m:5.2f} / {q(G[(bm,k,9)])}")
        print("   by role, dA / d(gap) per dL band (drop 2+ .. up 2+); slope dA/dL (1 = keeps his gap, 0 = holds his ground):")
        for r in range(6):
            n1 = c[("s1", bm, r)]
            if not n1: continue
            sl = (c[("xy", bm, r)] - c[("sx", bm, r)] * c[("sy", bm, r)] / n1) / max(1e-9, c[("xx", bm, r)] - c[("sx", bm, r)] ** 2 / n1)
            cells = "  ".join(f"{c[('dA',bm,k,r)]/max(1,c[('m',bm,k,r)]):5.2f}/{c[('dg',bm,k,r)]/max(1,c[('m',bm,k,r)]):5.2f}" for k in range(5))
            print(f"     {NAMES[r]:6s} {cells}   slope {sl:4.2f}   gap med by band " + " ".join(f"{sorted(G[(bm,k,r)])[len(G[(bm,k,r)])//2] if G[(bm,k,r)] else 0:4.1f}" for k in range(5)))

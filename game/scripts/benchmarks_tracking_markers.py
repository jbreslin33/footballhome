#!/usr/bin/env python3
"""benchmarks_tracking_markers.py — how tight the side without the ball stands to the men it is
defending, in every frame (G5.72, game/DESIGN.md §8.173).

    python3 -I game/scripts/benchmarks_tracking_markers.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB positions at 5 Hz). The side without the ball (BallPossession), in play,
keepers out. For each attacking outfielder, by his metres off the defenders' goal line (0-18 /
18-35 / 35-52 / 52+) and whether the ball is within 20 m of him: his nearest defending outfielder
p25 / median / p75, within 2 m %, and that man goal-side of him % (nearer the goal's centre). Then
the defenders' side: each CB / FB / DM's nearest attacker by the ball's band off his own line, and
the attacker's metres off that line. fh-game-match prints the same as MARKING, EVERY FRAME.
Spells 6 s+ old (settled) and all. FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES

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
    att = []; dfn = []; last = None; since = 0
    for (sc, n) in sorted(ball):
        bx, by, a_ = ball[(sc, n)]
        if a_ < 0: last = None; continue
        if last != (sc, a_): last = (sc, a_); since = n
        settled = (n - since) / 25 >= 6
        dt = 1 - a_; g = own[(sc, dt)]; gx = g * half   # the defenders' goal at (gx, 0)
        fr = pl.get((sc, n), {})
        A = [(pid, p) for pid, p in fr.items() if who.get(pid) == a_ and pid not in keepers]
        D = [(pid, p) for pid, p in fr.items() if who.get(pid) == dt and pid not in keepers]
        if len(A) < 8 or len(D) < 8: continue
        bown = half - bx * g
        for pid, p in A:
            dd, q = min((math.hypot(q[0] - p[0], q[1] - p[1]), q) for _, q in D)
            gs = math.hypot(q[0] - gx, q[1]) < math.hypot(p[0] - gx, p[1])
            o = half - p[0] * g
            att.append((0 if o < 18 else 1 if o < 35 else 2 if o < 52 else 3, math.hypot(bx - p[0], by - p[1]) < 20, dd, gs, settled))
        for pid, p in D:
            r = ROLE.get(pos_of.get(pid), -1)
            if r < 0 or r > 2: continue
            dd, q = min((math.hypot(q[0] - p[0], q[1] - p[1]), q) for _, q in A)
            dfn.append((r, max(0, min(4, int(bown // 18))), dd, half - q[0] * g, settled))
    return att, dfn

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    att = []; dfn = []
    with multiprocessing.Pool(3) as pool:
        for a, d in pool.imap_unordered(one, files): att += a; dfn += d
    def q(v):
        v = sorted(v); return f"{v[len(v)//4]:4.1f}/{v[len(v)//2]:4.1f}/{v[3*len(v)//4]:4.1f}" if v else "-"
    print(f"{len(files)} DFL matches: MARKING, EVERY FRAME (the side without it, in play, 5 Hz, keepers out)")
    for st, sn in ((None, "all"), (True, "settled 6 s+")):
        print(f"  {sn}: each attacker by his m off their goal, ball within 20 m of him / further: nearest defender p25/med/p75 | within 2 m % | goal-side %")
        for z, zn in enumerate(("0-18", "18-35", "35-52", "52+")):
            row = []
            for near in (True, False):
                v = [r for r in att if r[0] == z and r[1] == near and (st is None or r[4] == st)]
                if v: row.append(f"{q([r[2] for r in v])} | {100*sum(r[2] < 2 for r in v)/len(v):4.1f} | {100*sum(r[3] for r in v)/len(v):4.1f}")
            print(f"     {zn:6s} " + "  ||  ".join(row))
    print("  each CB / FB / DM by the ball's 18 m band off his own line: nearest attacker med | within 3 m % | that attacker's m off the line med")
    for r in range(3):
        row = []
        for b in range(5):
            v = [x for x in dfn if x[0] == r and x[1] == b]
            if v: row.append(f"{sorted(x[2] for x in v)[len(v)//2]:4.1f} {100*sum(x[2] < 3 for x in v)/len(v):4.1f}% {sorted(x[3] for x in v)[len(v)//2]:4.1f}")
        print(f"     {NAMES[r]:6s} " + " | ".join(row))

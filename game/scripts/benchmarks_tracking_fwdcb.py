#!/usr/bin/env python3
"""benchmarks_tracking_fwdcb.py — in their build-up, where our forwards stand against their centre-backs, by
who of theirs has the ball (G5.115, game/DESIGN.md §8.216).

    python3 -I game/scripts/benchmarks_tracking_fwdcb.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB positions at 5 Hz). The frames of benchmarks_tracking_pressshape.py: in play, the
BallPossession side has a carrier (its man nearest the ball within 2 m) and the ball is 52 m+ off the line it
attacks. Keepers out. By the carrier's role (CB / FB / DM-CM / AM / WIDE / ST): for each of the defending
side's ST / AM / WIDE, metres to the nearest of their CBs (not the carrier), to the ball, and off his own goal
line, medians; and their CBs' (bar the carrier) metres to the nearest defender, med, and within 3 m %.
fh-game-match prints the same as FORWARDS ON THEIR CBS. FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES

ON_M, LANE_M, T0, T1 = 3.0, 1.5, 0.15, 0.85

def lane_t(px, py, qx, qy, ox, oy):
    """(fraction along p→q of o's foot, o's distance to the line there)."""
    dx, dy = qx - px, qy - py; n = dx * dx + dy * dy
    if n == 0: return -1, 99
    t = ((ox - px) * dx + (oy - py) * dy) / n
    return t, math.hypot(ox - px - t * dx, oy - py - t * dy)

def classify(cx, cy, A, D):
    """A = [(role, (x, y))] their men bar the carrier, D = [(role, (x, y))] ours. Returns per attacker
    (role, state 0 ON / 1 SHADOW / 2 FREE, the coverer's role or -1, nearest m) and per defender
    (role, state 0 on a man / 1 shadow / 2 neither)."""
    out = []; dstate = [2] * len(D)
    for ra, (ax, ay) in A:
        dd, j = min((math.hypot(q[0] - ax, q[1] - ay), j) for j, (_, q) in enumerate(D))
        if dd < ON_M: out.append((ra, 0, D[j][0], dd)); dstate[j] = 0; continue
        best = None
        for jj, (_, (ox, oy)) in enumerate(D):
            t, g = lane_t(cx, cy, ax, ay, ox, oy)
            if T0 <= t <= T1 and g < LANE_M and (best is None or t < best[0]): best = (t, jj)
        if best: out.append((ra, 1, D[best[1]][0], dd)); dstate[best[1]] = min(dstate[best[1]], 1)
        else: out.append((ra, 2, -1, dd))
    for j, (_, (ox, oy)) in enumerate(D):   # on a man counts any attacker within 3 m, not only the one he is nearest
        if dstate[j] and any(math.hypot(ax - ox, ay - oy) < ON_M for _, (ax, ay) in A): dstate[j] = 0
    return out, [(D[j][0], dstate[j]) for j in range(len(D))]

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
    rows = []; cbs = []
    for (sc, n), (bx, by, a_) in ball.items():
        g_att = -own[(sc, a_)]
        if half - bx * g_att < 52: continue
        gd = own[(sc, 1 - a_)]
        fr = pl.get((sc, n), {})
        A = [(pid, p) for pid, p in fr.items() if who.get(pid) == a_ and pid not in keepers]
        D = [(pid, p) for pid, p in fr.items() if who.get(pid) == 1 - a_ and pid not in keepers]
        if len(A) < 8 or len(D) < 8: continue
        cd, ci = min((math.hypot(p[0] - bx, p[1] - by), i) for i, (_, p) in enumerate(A))
        if cd >= 2: continue
        cr = ROLE.get(pos_of.get(A[ci][0]), -1)
        CB = [p for i, (pid, p) in enumerate(A) if i != ci and ROLE.get(pos_of.get(pid), -1) == 0]
        if not CB: continue
        for pid, p in D:
            r = ROLE.get(pos_of.get(pid), -1)
            if r < 3: continue
            rows.append((cr, r, min(math.hypot(p[0] - q[0], p[1] - q[1]) for q in CB), math.hypot(p[0] - bx, p[1] - by), half - p[0] * gd, (half - p[0] * gd) - (half - bx * gd)))
        for q in CB:
            cbs.append((cr, min(math.hypot(p[0] - q[0], p[1] - q[1]) for _, p in D), half - bx * gd))
    return rows, cbs

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    rows = []; cbs = []
    with multiprocessing.Pool(3) as pool:
        for a, b in pool.imap_unordered(one, files): rows += a; cbs += b
    def md(v): v = sorted(v); return v[len(v) // 2] if v else float("nan")
    print(f"{len(files)} DFL matches: FORWARDS ON THEIR CBS (their carrier within 2 m, ball 52 m+ off the line they attack)")
    print("  by the carrier's role: ours ST / AM / WIDE m to their nearest CB | m to the ball | m off our line, med; their CBs: nearest of ours med, within 3 m % | the ball m off our line med")
    for cr in range(6):
        c = [x for x in cbs if x[0] == cr]
        if not c: continue
        line = f"     {NAMES[cr]:6s} {len(c):6d} |"
        for r in (5, 3, 4):
            v = [x for x in rows if x[0] == cr and x[1] == r]
            line += f" {NAMES[r]} {md([x[2] for x in v]):4.1f} {md([x[3] for x in v]):4.1f} {md([x[4] for x in v]):4.1f} |"
        for r in (5, 3):
            v = sorted(x[5] for x in rows if x[0] == cr and x[1] == r)
            line += f" {NAMES[r]}-ball p25/50/75 {v[len(v)//4]:+.1f}/{v[len(v)//2]:+.1f}/{v[3*len(v)//4]:+.1f} |"
        line += f" CB near {md([x[1] for x in c]):4.1f} {100*sum(x[1] < 3 for x in c)/len(c):4.1f}% | ball off our line {md([x[2] for x in c]):4.1f}"
        print(line)

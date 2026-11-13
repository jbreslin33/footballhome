#!/usr/bin/env python3
"""benchmarks_tracking_pressshape.py — the pressing structure in their half: who covers each of their
men, how, and with what (G5.102, game/DESIGN.md §8.204).

    python3 -I game/scripts/benchmarks_tracking_pressshape.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB positions at 5 Hz). In play, the BallPossession side has a carrier (its man
nearest the ball within 2 m) and the ball is 52 m+ off the line it attacks — its build-up, our press.
Keepers out. Each of its other outfielders is, at that frame:
  ON      — a defender within 3 m of him;
  SHADOW  — else a defender within 1.5 m of the carrier→him lane, between 15% and 85% along it
            (the cover shadow: the pass to him runs through that man);
  FREE    — neither.
By his role (DFL PlayingPosition → CB / FB / DM-CM / AM / WIDE / ST, as benchmarks_tracking_runs):
frames a team-match, the nearest defender med, ON / SHADOW / FREE %, and the role of the man doing it
(ON: the nearest; SHADOW: the shadower nearest the carrier). Then each defending role: metres to the
ball med, on a man (an attacker within 3 m) / shadowing a lane / neither %, and metres off his own goal
line med. fh-game-match prints the same as PRESS SHAPE. FH original.
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
    att = []; dfn = []; bl = []
    for (sc, n), (bx, by, a_) in ball.items():
        g_att = -own[(sc, a_)]                   # the line a_ attacks is at g_att * half
        if half - bx * g_att < 52: continue
        gd = own[(sc, 1 - a_)]                   # our own goal (the defenders') at gd * half
        fr = pl.get((sc, n), {})
        A = [(pid, p) for pid, p in fr.items() if who.get(pid) == a_ and pid not in keepers]
        D = [(pid, p) for pid, p in fr.items() if who.get(pid) == 1 - a_ and pid not in keepers]
        if len(A) < 8 or len(D) < 8: continue
        cd, ci = min((math.hypot(p[0] - bx, p[1] - by), i) for i, (_, p) in enumerate(A))
        if cd >= 2: continue
        cx, cy = A[ci][1]
        AA = [(ROLE.get(pos_of.get(pid), -1), p) for i, (pid, p) in enumerate(A) if i != ci]
        DD = [(ROLE.get(pos_of.get(pid), -1), p) for pid, p in D]
        o, ds = classify(cx, cy, AA, DD)
        o = [x + (math.hypot(p[0] - cx, p[1] - cy),) for x, (_, p) in zip(o, AA)]
        att += o; bl.append(half - bx * g_att)
        for (r, s_), (_, p) in zip(ds, DD):
            dfn.append((r, s_, math.hypot(p[0] - bx, p[1] - by), half - p[0] * gd))
    return att, dfn, bl

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    att = []; dfn = []; bl = []
    with multiprocessing.Pool(3) as pool:
        for a, d, b in pool.imap_unordered(one, files): att += a; dfn += d; bl += b
    tm = 2 * len(files)
    def md(v): v = sorted(v); return v[len(v) // 2] if v else float("nan")
    print(f"{len(files)} DFL matches: PRESS SHAPE (their carrier within 2 m, ball 52 m+ off the line they attack; keepers out)")
    print(f"  frames a team-match {len(bl)/tm:.0f}; the ball m off our line med {md(bl):.1f}, 52-70 m {100*sum(b < 70 for b in bl)/len(bl):.1f}%")
    print(f"  each of their other men by role: frames a team-match | nearest of ours med m | ON / SHADOW / FREE % | by whom (ON+SHADOW) CB/FB/DM/AM/WIDE/ST % | m from the carrier med")
    for r in range(6):
        v = [x for x in att if x[0] == r]
        if not v: continue
        cov = [x[2] for x in v if x[1] < 2]
        print(f"     {NAMES[r]:6s} {len(v)/tm:6.0f} | {md([x[3] for x in v]):4.1f} | " + " / ".join(f"{100*sum(x[1] == s for x in v)/len(v):4.1f}" for s in range(3))
              + " | " + "/".join(f"{100*sum(c == q for c in cov)/max(1, len(cov)):.0f}" for q in range(6)) + f" | {md([x[4] for x in v]):.1f}")
    v = att; print(f"     all    {len(v)/tm:6.0f} | {md([x[3] for x in v]):4.1f} | " + " / ".join(f"{100*sum(x[1] == s for x in v)/len(v):4.1f}" for s in range(3)))
    print(f"  each of ours by role: m to the ball med | on a man / shadowing / neither % | m off his own line med")
    for r in range(6):
        v = [x for x in dfn if x[0] == r]
        if not v: continue
        print(f"     {NAMES[r]:6s} {md([x[2] for x in v]):4.1f} | " + " / ".join(f"{100*sum(x[1] == s for x in v)/len(v):4.1f}" for s in range(3)) + f" | {md([x[3] for x in v]):4.1f}")

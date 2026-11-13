#!/usr/bin/env python3
"""benchmarks_tracking_flight.py — the pass in flight: the receiver's crude-race options from 0.8 s before he has
the ball to 0.8 s after, and how both sides move while it travels (G5.116, game/DESIGN.md §8.217).

    python3 -I game/scripts/benchmarks_tracking_flight.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL
(7 matches, TRACAB 5 Hz). Spells as benchmarks_tracking_shut.py (an outfielder nearest the ball within 1.5 m,
ball under 1.5 m, in play, 2+ frames). A RECEIPT: a spell whose previous spell (same half, ball live between)
was a different man of the same side, 0.4-3 s before. By the ball's band off the line the receiver attacks
(0-35 / 35-52 / 52+), at offsets −0.8 / −0.4 / 0 / +0.4 / +0.8 s from the receipt's first frame:
- the receiver's options (mates 5 m+, keepers out, the crude race of benchmarks_tracking_passrace.py run from
  where HE stands at that offset): mean, 3+ %;
- his mates' nearest opponent, med (m).
And over the flight (the passer's last frame → the receipt): the defending outfielders' speed med (m/s), their
closing on the receiver's mates (nearest-opponent distance at the kick − at the receipt, med m), and the
receiver's mates' own speed med. At the receipt: each mate 10-30 m's nearest opponent, metres toward the ball
and toward the goal the receiver attacks (ball-side / beyond shares, free % by side); the receiver's role and
metres off the centre line (by role); options by his width 0-10 / 10-20 / 20+ m; his mates and their men within
10 / 20 m; each mate role's metres from him and ahead of him. THE SLIDE: on every spell frame, each role of the
side on the ball, its metres toward the ball's side (mean), by the ball's metres off the centre line.
fh-game-match prints the same as THE PASS IN FLIGHT and THE SLIDE. FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_passrace import margin
from benchmarks_tracking_runs import ROLE, NAMES

ZG = ["0-35", "35-52", "52+"]
def zg(d): return 0 if d < 35 else 1 if d < 52 else 2
OFF = (-4, -2, 0, 2, 4)   # 5 Hz frames: −0.8 … +0.8 s

def opts(fr, who, keepers, pid, tm, gsx=0, side=None):
    """side: list to take (u, g, free) per mate — the nearest opponent's metres toward the ball (u) and toward
    the goal the receiver attacks (g, gsx = its sign on x), off the mate."""
    px, py = fr[pid]; opp = [p for q, p in fr.items() if who.get(q) == 1 - tm]
    n = 0; nds = []
    for q, (mx, my) in fr.items():
        if who.get(q) != tm or q == pid or q in keepers: continue
        L = math.hypot(mx - px, my - py)
        if L < 5: continue
        f = margin(px, py, mx, my, (mx, my), opp) <= 0; n += f
        ox, oy = min(opp, key=lambda o: math.hypot(o[0] - mx, o[1] - my))
        nds.append(math.hypot(ox - mx, oy - my))
        if side is not None: side.append((((ox - mx) * (px - mx) + (oy - my) * (py - my)) / L, (ox - mx) * gsx, f, L))
    return n, nds

def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    team_of = {home: 0, guest: 1}
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
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
                st = re.search(r'BallStatus="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7]), float(a[9]), bool(st and st.group(1) == "1"))
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    kx = collections.defaultdict(list)
    for k, fr in pl.items():
        if k[1] % 250: continue
        for pid, (x, y) in fr.items():
            if pid in keepers and pid in who: kx[(k[0], who[pid])].append(x)
    own = {k: (-1 if sum(v) / len(v) < 0 else 1) for k, v in kx.items()}
    keys = sorted(ball); seq = []   # (key, live, nearest pid or None)
    for k in keys:
        bx, by, bz, live = ball[k]; fr = pl.get(k)
        if not live or not fr: seq.append((k, False, None)); continue
        best = None; bd = 1.5
        if bz <= 1.5:
            for pid, (x, y) in fr.items():
                if pid not in who: continue
                dd = math.hypot(x - bx, y - by)
                if dd <= bd: bd = dd; best = pid
        seq.append((k, True, best))
    spells = []   # (i0, i1, pid)
    i = 0
    while i < len(seq):
        k, live, pid = seq[i]
        if pid is None: i += 1; continue
        j = i
        while j + 1 < len(seq) and seq[j + 1][2] == pid and seq[j + 1][0][0] == k[0] and seq[j + 1][0][1] == seq[j][0][1] + 5: j += 1
        if j > i: spells.append((i, j, pid))
        i = j + 1
    c = collections.Counter(); H = collections.defaultdict(list)
    for i0, i1, pid in spells:   # THE SLIDE: every spell frame, each mate role's metres toward the ball's side (pair mean), by |ball y|
        if pid in keepers: continue
        tm = who[pid]
        for t in range(i0, i1 + 1):
            k = seq[t][0]; fr = pl[k]; by = ball[k][1]; sg = 1 if by >= 0 else -1; yb = min(3, int(abs(by) // 8))
            for q, (x, y) in fr.items():
                if who.get(q) != tm or q in keepers: continue
                r = ROLE.get(pos_of.get(q), -1)
                if r >= 0: c[("sl", yb, r)] += 1; H[("sls", yb, r)].append(y * sg)
    def okrun(a, b):   # frames a..b consecutive, same half, all live
        if b >= len(seq) or a < 0: return False
        for t in range(a, b + 1):
            if not seq[t][1]: return False
            if t > a and (seq[t][0][0] != seq[t - 1][0][0] or seq[t][0][1] != seq[t - 1][0][1] + 5): return False
        return True
    for s_prev, s in zip(spells, spells[1:]):
        i0, i1, pid = s; p0, p1, ppid = s_prev
        if pid in keepers or ppid == pid or who.get(pid) != who.get(ppid): continue
        fl = i0 - p1
        if fl < 2 or fl > 15: continue
        if not okrun(min(p1, i0 + OFF[0]), i0 + OFF[-1]): continue
        k = seq[i0][0]; tm = who[pid]
        if (k[0], tm) not in own: continue
        z = zg(length / 2 + ball[k][0] * own[(k[0], tm)])
        c[("n", z)] += 1; H[("fl", z)].append(fl / 5)
        for oi, o in enumerate(OFF):
            fr = pl[seq[i0 + o][0]]
            if pid not in fr: continue
            sd = [] if o == 0 else None
            n, nds = opts(fr, who, keepers, pid, tm, own[(k[0], tm)] * -1, sd)
            for u, g, f, L in sd or []:
                if L < 10 or L >= 30: continue
                H[("u", z)].append(u); H[("g", z)].append(g); c[("sn", z)] += 1; c[("bs", z)] += u > 0; c[("gs", z)] += g > 0
                c[("bf", z, u > 0)] += f; c[("bn", z, u > 0)] += 1
            if o == 0: wy = min(2, int(abs(fr[pid][1]) // 10)); c[("wy", z, wy)] += 1; c[("wy3", z, wy)] += n >= 3; c[("wys", z, wy)] += n
            c[("o", z, oi)] += 1; c[("os", z, oi)] += n; c[("o3", z, oi)] += n >= 3; H[("nd", z, oi)] += nds
        fr0 = pl[seq[i0][0]]; rx, ry = fr0[pid]
        for q, (x, y) in fr0.items():   # local numbers round the receiver: his mates / their men (keepers in) within 10 and 20 m
            if q == pid or q not in who: continue
            dd = math.hypot(x - rx, y - ry)
            for ri, R in enumerate((10, 20)):
                if dd < R: c[("ln", z, who[q] == tm, ri)] += 1
        c[("rr", z, ROLE.get(pos_of.get(pid), -1))] += 1; H[("ry", z)].append(abs(ry)); H[("ryr", z, ROLE.get(pos_of.get(pid), -1))].append(abs(ry))
        for q, (x, y) in fr0.items():   # each mate's metres from the receiver, by role: across and along the pitch
            if who.get(q) != tm or q == pid or q in keepers: continue
            r = ROLE.get(pos_of.get(q), -1)
            if r < 0: continue
            H[("rd", z, r)].append(math.hypot(x - rx, y - ry)); H[("rl", z, r)].append((x - rx) * -own[(k[0], tm)])
        fa, fb = pl[seq[p1][0]], pl[seq[i0][0]]; T = fl / 5
        for q, (x, y) in fb.items():
            if q not in fa or q in keepers or q not in who: continue
            v = math.hypot(x - fa[q][0], y - fa[q][1]) / T
            H[("vd" if who[q] != tm else "va", z)].append(v)
        oppa = [p for q, p in fa.items() if who.get(q) == 1 - tm]; oppb = [p for q, p in fb.items() if who.get(q) == 1 - tm]
        for q, (x, y) in fb.items():
            if who.get(q) != tm or q == pid or q in keepers or q not in fa: continue
            na = min(math.hypot(ox - fa[q][0], oy - fa[q][1]) for ox, oy in oppa)
            nb = min(math.hypot(ox - x, oy - y) for ox, oy in oppb)
            H[("cl", z)].append(na - nb)
    return c, H

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); H = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, hh in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in hh.items(): H[k2] += v
    def md(v): v = sorted(v); return v[len(v) // 2] if v else float("nan")
    tm = 2 * len(files)
    print(f"{len(files)} DFL matches: THE PASS IN FLIGHT — receipts (a mate's spell 0.4-3 s before), the receiver's crude-race options from where he stands")
    print("  per band: receipts a team-match | flight s med | at −0.8/−0.4/0/+0.4/+0.8 s: options mean, 3+ %, mates' nearest opponent med m | over the flight: defenders' speed med, mates' speed med, defenders closing on mates med m")
    YB = ["0-8", "8-16", "16-24", "24+"]
    print("  THE SLIDE (spell frames, the side on the ball): each role's m toward the ball's side, mean, by the ball's m off the centre line")
    for yb in range(4):
        print(f"    ball {YB[yb]:5s} " + "  ".join(f"{NAMES[r]} {sum(H[('sls', yb, r)])/max(1, len(H[('sls', yb, r)])):+.1f}" for r in range(6)))
    for z in range(3):
        row = "  ".join(f"{c[('os', z, oi)]/max(1, c[('o', z, oi)]):.2f} {100*c[('o3', z, oi)]/max(1, c[('o', z, oi)]):.0f}% {md(H[('nd', z, oi)]):.1f}" for oi in range(5))
        print(f"  {ZG[z]:5s} mates 10-30 m at the receipt: their nearest opponent med {md(H[('u', z)]):+.1f} m toward the ball, {md(H[('g', z)]):+.1f} m toward the goal he attacks; ball-side {100*c[('bs', z)]/max(1, c[('sn', z)]):.0f}%, beyond him {100*c[('gs', z)]/max(1, c[('sn', z)]):.0f}%; free when he is ball-side {100*c[('bf', z, True)]/max(1, c[('bn', z, True)]):.0f}% / not {100*c[('bf', z, False)]/max(1, c[('bn', z, False)]):.0f}%")
        print(f"  {ZG[z]:5s} mates by role at the receipt, m from the receiver med / m ahead of him med: " + "  ".join(f"{NAMES[r]} {md(H[('rd', z, r)]):.1f} {md(H[('rl', z, r)]):+.1f}" for r in range(6)))
        print(f"  {ZG[z]:5s} the receiver's role %: " + "  ".join(f"{NAMES[r]} {100*c[('rr', z, r)]/max(1, c[('n', z)]):.0f}" for r in range(6)) + f"; his m off the centre line med {md(H[('ry', z)]):.1f}, by role " + " ".join(f"{NAMES[r]} {md(H[('ryr', z, r)]):.1f}" for r in range(6)))
        print(f"  {ZG[z]:5s} by the receiver's m off the centre line 0-10 / 10-20 / 20+: share % | options mean | 3+ %: " + "  ".join(f"{100*c[('wy', z, w)]/max(1, c[('n', z)]):.0f}% {c[('wys', z, w)]/max(1, c[('wy', z, w)]):.2f} {100*c[('wy3', z, w)]/max(1, c[('wy', z, w)]):.0f}%" for w in range(3)))
        print(f"  {ZG[z]:5s} round the receiver, mean: his mates within 10 / 20 m {c[('ln', z, True, 0)]/max(1, c[('n', z)]):.2f} / {c[('ln', z, True, 1)]/max(1, c[('n', z)]):.2f}, their men {c[('ln', z, False, 0)]/max(1, c[('n', z)]):.2f} / {c[('ln', z, False, 1)]/max(1, c[('n', z)]):.2f}")
        print(f"  {ZG[z]:5s} {c[('n', z)]/tm:.1f} {md(H[('fl', z)]):.1f}s | {row} | vd {md(H[('vd', z)]):.2f} va {md(H[('va', z)]):.2f} close {md(H[('cl', z)]):.2f}")

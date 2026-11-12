#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_shut.py (G5.100, DESIGN §8.202) — usage: <DFL dir>
# Real: a man on the ball with his lanes shut. A spell = the same man nearest the ball within 1.5 m (ball
# under 1.5 m, in play) on two 5 Hz frames running or more. At its first frame, his OPTIONS: mates 5 m+ away
# (keepers out) that benchmarks_tracking_passrace.py's crude race calls ours. By options 0 / 1 / 2 / 3+:
# the share of spells, time on the ball and carry (ball first → last frame) medians, how it ended — the
# next man on it a mate / theirs / dead ball first — and his options at its last frame.
# DFL tracking (Bassek et al. 2025, CC BY).
import collections, glob, math, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
from benchmarks_tracking_passrace import theirs_first
def opts(fr, who, keepers, pid, bx, by):
    tm = who[pid]; px, py = fr[pid]
    opp = [p for q, p in fr.items() if who.get(q) == 1 - tm]
    n = 0
    for q, (mx, my) in fr.items():
        if who.get(q) != tm or q == pid or q in keepers: continue
        if math.hypot(mx - px, my - py) < 5: continue
        n += not theirs_first(px, py, mx, my, (mx, my), opp)
    return n
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    team_of = {home: 0, guest: 1}
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
    keys = sorted(ball)
    kx = collections.defaultdict(list)
    for k, fr in pl.items():
        if k[1] % 250: continue
        for pid, (x, y) in fr.items():
            if pid in keepers and pid in who: kx[(k[0], who[pid])].append(x)
    own = {k: (-1 if sum(v) / len(v) < 0 else 1) for k, v in kx.items()}
    # per frame: the man on it (or None), None + dead marks
    seq = []   # (key, pid or None, live)
    for k in keys:
        bx, by, bz, live = ball[k]; fr = pl.get(k)
        if not live or not fr: seq.append((k, None, False)); continue
        best = None; bd = 1.5
        if bz <= 1.5:
            for pid, (x, y) in fr.items():
                if pid not in who: continue
                dd = math.hypot(x - bx, y - by)
                if dd <= bd: bd = dd; best = pid
        seq.append((k, best, True))
    spells = []   # (i0, i1, pid)
    i = 0
    while i < len(seq):
        k, pid, live = seq[i]
        if pid is None: i += 1; continue
        j = i
        while j + 1 < len(seq) and seq[j + 1][1] == pid and seq[j + 1][0][0] == k[0] and seq[j + 1][0][1] == seq[j][0][1] + 5: j += 1
        if j > i: spells.append((i, j, pid))
        i = j + 1
    c = collections.Counter(); H = collections.defaultdict(list)
    for si, (i0, i1, pid) in enumerate(spells):
        k0 = seq[i0][0]; k1 = seq[i1][0]; fr0 = pl[k0]; fr1 = pl[k1]
        if pid in keepers: continue
        o0 = opts(fr0, who, keepers, pid, *ball[k0][:2]); o1 = opts(fr1, who, keepers, pid, *ball[k1][:2])
        b = min(3, o0)
        # how it ended: the next spell's man, unless a dead frame comes first
        end = "dead"
        for jj in range(i1 + 1, min(len(seq), i1 + 75)):
            if not seq[jj][2]: break
            if seq[jj][1] is not None and seq[jj][1] != pid:
                # the next spell (2 frames) must start here
                if jj + 1 < len(seq) and seq[jj + 1][1] == seq[jj][1]:
                    end = "mate" if who[seq[jj][1]] == who[pid] else "theirs"; break
        dur = (k1[1] - k0[1]) / 25
        carry = math.hypot(ball[k1][0] - ball[k0][0], ball[k1][1] - ball[k0][1])
        g = own.get((k0[0], who[pid]))
        if g is not None:
            dz = length / 2 + ball[k0][0] * g; z = 0 if dz < 18 else 1 if dz < 35 else 2 if dz < 52 else 3 if dz < 70 else 4
            c[("z", z)] += 1; c[("zo", z, b)] += 1; c[("ze", z, end)] += 1
        c[("n", b)] += 1; c[("e", b, end)] += 1; H[("d", b)].append(dur); H[("c", b)].append(carry); H[("o1", b)].append(o1)
        c["n"] += 1
    return c, H
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); H = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, hh in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in hh.items(): H[k2] += v
    def q(v, p): v = sorted(v); return v[min(len(v) - 1, int(len(v) * p))] if v else float("nan")
    tm = 2 * len(files); N = max(1, c["n"])
    print(f"{len(files)} DFL matches: ON THE BALL (outfielder nearest within 1.5 m, 2+ frames at 5 Hz), {N/tm:.1f} spells a team-match; by his crude-race options at the start (mates 5 m+ the race calls ours)")
    print("  options | share % | on the ball s p25/med/p75 | carry m med | next on it: mate / theirs / dead % | options at the end med")
    print("  by the ball's m off the line he attacks: spells a team-match | options 0 / 1 / 2 / 3+ % | next on it mate / theirs / dead %")
    for z, nm in enumerate(["0-18", "18-35", "35-52", "52-70", "70+"]):
        n = max(1, c[("z", z)])
        print(f"   {nm:5s} {c[('z', z)]/tm:6.1f} | " + " / ".join(f"{100*c[('zo', z, b)]/n:4.1f}" for b in range(4)) + " | " + " / ".join(f"{100*c[('ze', z, e)]/n:4.1f}" for e in ("mate", "theirs", "dead")))
    for b in range(4):
        n = c[("n", b)]
        if not n: continue
        print(f"   {['0', '1', '2', '3+'][b]:3s} | {100*n/N:5.1f} | {q(H[('d', b)], .25):.1f}/{q(H[('d', b)], .5):.1f}/{q(H[('d', b)], .75):.1f} | {q(H[('c', b)], .5):4.1f} | "
              + " / ".join(f"{100*c[('e', b, e)]/n:4.1f}" for e in ("mate", "theirs", "dead")) + f" | {q(H[('o1', b)], .5):.0f}")

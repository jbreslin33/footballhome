#!/usr/bin/env python3
"""benchmarks_tracking_longball.py — who is under the long high ball from the back when it comes down (G5.211,
game/DESIGN.md §8.317).

    python3 -I game/scripts/benchmarks_tracking_longball.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB 25 Hz ball with height, players read at 5 Hz). As benchmarks_tracking_aerial.py (a high
ball = in play, rose past 4 m since it was last under 0.5 m; its first frame coming down through 2.4 m), cut to the
long ball from the back: launched (the last frame under 0.5 m) within 35 m of the kicker's own goal line, the ball in
play for 2 s+ before it (no goal kick or free kick), no keeper within 3 m of it at the launch, and 30 m+ from the
launch to the drop. The kicker's side = BallPossession at the drop. By carry 30-40 / 40-50 / 50+ m: a team-match; at
the drop the nearest outfielder of each side; the other side within 2 m, both, nobody within 3 m; the other side has
it within 3 s; where those two men stood at the launch, off the drop; outfielders of each side within 10 m of the drop
point at the launch and at the drop; the drop's metres off the kicker's own goal line. fh-game-match prints the same
as LONG BALL FROM THE BACK. FH original.
"""
import collections, glob, os, re, sys, math, multiprocessing
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info)
    half = length / 2; team_of = {home: 0, guest: 1}
    ball = {}; pl = collections.defaultdict(dict); who = {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    sec = None; isb = False; skip = True; cur = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if isb:
                st = re.search(r'BallStatus="(\d)"', s); po = re.search(r'BallPossession="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7]), float(a[9]), bool(st and st.group(1) == "1"), int(po.group(1)) - 1 if po and po.group(1) in "12" else -1)
            elif n % 5 == 0: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    out = []
    for sc in sorted({k[0] for k in ball}):
        ks = sorted(k[1] for k in ball if k[0] == sc)
        gx = {0: [], 1: []}
        for n in ks[::250]:
            for pid, p in pl.get((sc, n - n % 5), {}).items():
                if pid in keepers: gx[who[pid]].append(p[0])
        side = {t: (-1 if (sum(v) / len(v) if v else 0) < 0 else 1) for t, v in gx.items()}   # own goal at side*half
        rose = False; low = None; run = 0; lrun = 0
        for i in range(1, len(ks)):
            n = ks[i]; bx, by, bz, live, po = ball[(sc, n)]
            if not live or ks[i - 1] != n - 1: rose = False; low = None; run = 0; continue
            run += 1
            if bz < 0.5: rose = False; low = n; lrun = run
            if bz > 4.0: rose = True
            pz = ball[(sc, ks[i - 1])][2]
            if not (rose and pz > 2.4 >= bz and po >= 0): continue
            rose = False
            if low is None or lrun < 50: continue
            lx, ly = ball[(sc, low)][0], ball[(sc, low)][1]
            carry = math.hypot(bx - lx, by - ly)
            if carry < 30: continue
            if half - lx * side[po] >= 35: continue   # launched within 35 m of the kicker's own goal (at side*half)
            l0 = pl.get((sc, low - low % 5), {}); ps = pl.get((sc, n - n % 5), {})
            if any(pid in keepers and math.hypot(p[0] - lx, p[1] - ly) < 3 for pid, p in l0.items()): continue
            def nearp(team):
                ds = [(math.hypot(p[0] - bx, p[1] - by), pid) for pid, p in ps.items() if who[pid] == team and pid not in keepers]
                return min(ds) if ds else (99, None)
            (ba, pa), (bd, pd) = nearp(po), nearp(1 - po)
            cnt = lambda fr, team: sum(1 for pid, p in fr.items() if who[pid] == team and pid not in keepers and math.hypot(p[0] - bx, p[1] - by) < 10)
            la = math.hypot(l0[pa][0] - bx, l0[pa][1] - by) if pa in l0 else None
            ld = math.hypot(l0[pd][0] - bx, l0[pd][1] - by) if pd in l0 else None
            lost = any(ball.get((sc, m), (0, 0, 0, False, -1))[4] == 1 - po for m in range(n, n + 75))
            # the kicker's-side outfielder nearest the drop point AT THE LAUNCH (not the kicker: 3 m+ off the ball then): the drop off him —
            # metres on toward their goal (+) and across
            m0 = min(((math.hypot(p[0] - bx, p[1] - by), p) for pid, p in l0.items() if who[pid] == po and pid not in keepers and math.hypot(p[0] - lx, p[1] - ly) >= 3), default=None)
            off = (m0[0], (bx - m0[1][0]) * -side[po], abs(by - m0[1][1])) if m0 else None
            out.append((0 if carry < 40 else 1 if carry < 50 else 2, ba, bd, lost, la, ld, cnt(l0, po), cnt(l0, 1 - po), cnt(ps, po), cnt(ps, 1 - po), half - bx * side[po], (n - low) / 25, abs(by), off))
    return out
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    allr = []
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files): allr += r
    tm = 2 * len(files)
    md = lambda v: (sorted(v)[len(v) // 2] if v else -1)
    mean = lambda v: sum(v) / max(1, len(v))
    print(f"{len(files)} DFL matches: LONG BALL FROM THE BACK (high, launched within 35 m of the kicker's goal in open play, not by a keeper, 30 m+ to the drop): {len(allr)/tm:.2f} a team-match")
    print("  carry: a team-match | nearest of the kicker's side med | of the other side med | other side within 2 m % | both % | nobody within 3 m % | other side has it within 3 s % | at the launch, off the drop: his man med, their man med | within 10 m of the drop at the launch ours / theirs, at the drop ours / theirs | drop m off the kicker's goal med, |y| med | flight s med")
    for z, nm in list(enumerate(("30-40", "40-50", "50+"))) + [(None, "all")]:
        v = [r for r in allr if z is None or r[0] == z]
        if not v: continue
        k = len(v)
        print(f"     {nm:6s} {k/tm:5.2f} | {md([r[1] for r in v]):4.1f} | {md([r[2] for r in v]):4.1f} | {100*sum(r[2] < 2 for r in v)/k:4.1f} | {100*sum(r[1] < 2 and r[2] < 2 for r in v)/k:4.1f} | {100*sum(r[1] >= 3 and r[2] >= 3 for r in v)/k:4.1f} | {100*sum(r[3] for r in v)/k:4.1f} | "
              f"{md([r[4] for r in v if r[4] is not None]):4.1f}, {md([r[5] for r in v if r[5] is not None]):4.1f} | {mean([r[6] for r in v]):.2f} / {mean([r[7] for r in v]):.2f}, {mean([r[8] for r in v]):.2f} / {mean([r[9] for r in v]):.2f} | {md([r[10] for r in v]):4.1f}, {md([r[12] for r in v]):4.1f} | {md([r[11] for r in v]):.2f}")
        o = [r[13] for r in v if r[13]]; q = lambda w, f: sorted(w)[int(f * len(w))] if w else -1
        print(f"            the drop off the kicker's-side man nearest it at the launch: m p25/med/p75 {q([x[0] for x in o], .25):.1f}/{q([x[0] for x in o], .5):.1f}/{q([x[0] for x in o], .75):.1f} | on toward their goal med {q([x[1] for x in o], .5):+.1f} (p25 {q([x[1] for x in o], .25):+.1f}, p75 {q([x[1] for x in o], .75):+.1f}), 5 m+ beyond him {100 * sum(x[1] >= 5 for x in o) / max(1, len(o)):.0f}%, 5 m+ short {100 * sum(x[1] <= -5 for x in o) / max(1, len(o)):.0f}% | across med {q([x[2] for x in o], .5):.1f}")

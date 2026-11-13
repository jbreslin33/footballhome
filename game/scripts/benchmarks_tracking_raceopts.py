#!/usr/bin/env python3
"""benchmarks_tracking_raceopts.py — which mates the crude race calls free for the man on the ball, by the
mate's role and distance (G5.103, game/DESIGN.md §8.205).

    python3 -I game/scripts/benchmarks_tracking_raceopts.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL
(7 matches, TRACAB 5 Hz). Spells as benchmarks_tracking_shut.py (an outfielder nearest the ball within
1.5 m, ball under 1.5 m, in play, 2+ frames). At a spell's first frame, every mate 5 m+ away (keepers out)
is raced by benchmarks_tracking_passrace.py's crude race. By the ball's band off the line the carrier
attacks (0-35 / 35-52 / 52+): for each mate role and each distance band (5-10 / 10-20 / 20-30 / 30+ m),
mates a spell, free % (the race calls him ours), and for the not-free ones the winning margin med (s).
Plus the nearest opponent to each mate (m) med, free and not. fh-game-match prints the same as RACE
OPTIONS. FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_passrace import margin
from benchmarks_tracking_runs import ROLE, NAMES

ZG = ["0-35", "35-52", "52+"]
def zg(d): return 0 if d < 35 else 1 if d < 52 else 2
DB = ["5-10", "10-20", "20-30", "30+"]
def db(d): return 0 if d < 10 else 1 if d < 20 else 2 if d < 30 else 3

def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
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
    kx = collections.defaultdict(list)
    for k, fr in pl.items():
        if k[1] % 250: continue
        for pid, (x, y) in fr.items():
            if pid in keepers and pid in who: kx[(k[0], who[pid])].append(x)
    own = {k: (-1 if sum(v) / len(v) < 0 else 1) for k, v in kx.items()}
    keys = sorted(ball); seq = []
    for k in keys:
        bx, by, bz, live = ball[k]; fr = pl.get(k)
        if not live or not fr: seq.append((k, None)); continue
        best = None; bd = 1.5
        if bz <= 1.5:
            for pid, (x, y) in fr.items():
                if pid not in who: continue
                dd = math.hypot(x - bx, y - by)
                if dd <= bd: bd = dd; best = pid
        seq.append((k, best))
    c = collections.Counter(); H = collections.defaultdict(list)
    i = 0
    while i < len(seq):
        k, pid = seq[i]
        if pid is None: i += 1; continue
        j = i
        while j + 1 < len(seq) and seq[j + 1][1] == pid and seq[j + 1][0][0] == k[0] and seq[j + 1][0][1] == seq[j][0][1] + 5: j += 1
        if j > i and pid not in keepers and (k[0], who[pid]) in own:
            fr = pl[k]; tm = who[pid]; px, py = fr[pid]
            z = zg(length / 2 + ball[k][0] * own[(k[0], tm)])
            opp = [p for q, p in fr.items() if who.get(q) == 1 - tm]
            c[("sp", z)] += 1
            for q, (mx, my) in fr.items():
                if who.get(q) != tm or q == pid or q in keepers: continue
                L = math.hypot(mx - px, my - py)
                if L < 5: continue
                r = ROLE.get(pos_of.get(q), -1)
                if r < 0: continue
                m = margin(px, py, mx, my, (mx, my), opp); free = m <= 0
                nd = min(math.hypot(ox - mx, oy - my) for ox, oy in opp)
                b = db(L)
                for key in (("r", z, r), ("d", z, b)):
                    c[key + ("n",)] += 1; c[key + ("f",)] += free
                    if not free: H[key + ("m",)].append(m)
                H[("nd", z, free)].append(nd)
        i = j + 1
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
    print(f"{len(files)} DFL matches: RACE OPTIONS — the man on the ball's mates 5 m+ at a spell's start (keepers out), crude race")
    print("  by the ball's m off the line he attacks; per mate role / distance: mates a spell | free % | margin med s when theirs")
    for z in range(3):
        sp = max(1, c[("sp", z)])
        print(f"  {ZG[z]:5s} spells a team-match {c[('sp', z)]/tm:.1f}; nearest opponent to a mate med free {md(H[('nd', z, True)]):.1f} m / not {md(H[('nd', z, False)]):.1f} m")
        print("    role  " + "  ".join(f"{NAMES[r]}: {c[('r', z, r, 'n')]/sp:.2f} {100*c[('r', z, r, 'f')]/max(1, c[('r', z, r, 'n')]):.0f}% {md(H[('r', z, r, 'm')]):.2f}" for r in range(6)))
        print("    dist  " + "  ".join(f"{DB[b]}: {c[('d', z, b, 'n')]/sp:.2f} {100*c[('d', z, b, 'f')]/max(1, c[('d', z, b, 'n')]):.0f}% {md(H[('d', z, b, 'm')]):.2f}" for b in range(4)))

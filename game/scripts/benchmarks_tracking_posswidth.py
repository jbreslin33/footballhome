#!/usr/bin/env python3
"""benchmarks_tracking_posswidth.py — the side IN possession: how far apart each role's pair stands
across, by the ball's band (G5.102, game/DESIGN.md §8.204).

    python3 -I game/scripts/benchmarks_tracking_posswidth.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB positions at 5 Hz). In play, the BallPossession side; the ball in 10 m bands of
metres off the line that side attacks (0-10 … 90-100). For each role with exactly two men on
(CB / FB / DM-CM / WIDE, DFL PlayingPosition as benchmarks_tracking_runs), the pair's gap across (|dy|)
mean, and how deep apart (|dx|) mean. The defending side's settled table is DefendingBlock's
kRealWidthPm (benchmarks_tracking_possession / SETTLED WIDTH). fh-game-match prints the same as
POSSESSION WIDTH. FH original.
"""
import collections, glob, os, re, sys, multiprocessing
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
    gy = collections.defaultdict(list); gx = collections.defaultdict(list)
    for (sc, n), (bx, by, a_) in ball.items():
        g_att = -own[(sc, a_)]
        b = min(9, max(0, int((half - bx * g_att) // 10)))
        by_role = collections.defaultdict(list)
        for pid, p in pl.get((sc, n), {}).items():
            if who.get(pid) == a_ and pid not in keepers:
                r = ROLE.get(pos_of.get(pid), -1)
                if r >= 0: by_role[r].append(p)
        for r, ps in by_role.items():
            if len(ps) != 2: continue
            gy[(r, b)].append(abs(ps[0][1] - ps[1][1])); gx[(r, b)].append(abs(ps[0][0] - ps[1][0]))
    return gy, gx

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    gy = collections.defaultdict(list); gx = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for a, b in pool.imap_unordered(one, files):
            for k, v in a.items(): gy[k] += v
            for k, v in b.items(): gx[k] += v
    mean = lambda v: sum(v) / len(v) if v else float("nan")
    print(f"{len(files)} DFL matches: POSSESSION WIDTH (the side on the ball; ball m off the line it attacks, 10 m bands 0-10 … 90-100)")
    print("  the pair's gap ACROSS mean m (n frames) / how deep apart mean m:")
    for r in (0, 1, 2, 4):
        print(f"     {NAMES[r]:6s} " + " ".join(f"{mean(gy[(r, b)]):5.1f}" for b in range(10)) + f"   (n {sum(len(gy[(r, b)]) for b in range(10))})")
        print(f"     {'  deep':6s} " + " ".join(f"{mean(gx[(r, b)]):5.1f}" for b in range(10)))

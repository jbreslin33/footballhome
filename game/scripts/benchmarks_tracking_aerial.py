#!/usr/bin/env python3
"""benchmarks_tracking_aerial.py — who is under a high ball when it comes down, anywhere on the
pitch, open play (G5.71, game/DESIGN.md §8.172).

    python3 -I game/scripts/benchmarks_tracking_aerial.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB 25 Hz ball with height, players read at 5 Hz). A high ball = in play, it rose
past 4 m since it was last under 0.5 m; its first 25 Hz frame coming down through 2.4 m (head
height). There: the nearest outfielder of the side in possession (BallPossession, the kicker's
side) and of the other side to the ball (players at the 5 Hz frame at or before), and where they
stand off the drop point; by the ball's zone (metres off the kicker's own goal: 0-35 / 35-70 / 70+).
Then within 3 s whether the possession flag is the other side's. fh-game-match prints the same as
HIGH BALLS COMING DOWN. Extends benchmarks_tracking_drop.py (crosses in the box) to every high ball.
FH original.
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
        rose = False
        for i in range(1, len(ks)):
            n = ks[i]; bx, by, bz, live, po = ball[(sc, n)]
            if not live or ks[i - 1] != n - 1: rose = False; continue
            if bz < 0.5: rose = False
            if bz > 4.0: rose = True
            pz = ball[(sc, ks[i - 1])][2]
            if not (rose and pz > 2.4 >= bz and po >= 0): continue
            rose = False
            ps = pl.get((sc, n - n % 5), {})
            def near(team):
                ds = [(math.hypot(p[0] - bx, p[1] - by), pid) for pid, p in ps.items() if who[pid] == team and pid not in keepers]
                return min(ds)[0] if ds else 99
            ba = near(po); bd = near(1 - po)
            own = half - bx * side[po]   # m off the kicker's own goal (at side*half)
            z = 0 if own < 35 else 1 if own < 70 else 2
            lost = any(ball.get((sc, m), (0, 0, 0, False, -1))[4] == 1 - po for m in range(n, n + 75))
            out.append((z, ba, bd, lost))
    return out
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    allr = []
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files): allr += r
    tm = 2 * len(files)
    def q(v):
        v = sorted(v); return f"{v[len(v)//4]:4.1f}/{v[len(v)//2]:4.1f}/{v[3*len(v)//4]:4.1f}" if v else "-"
    print(f"{len(files)} DFL matches: HIGH BALLS COMING DOWN through 2.4 m in open play: {len(allr)/tm:.1f} a team-match")
    print("  by the ball's zone (m off the kicker's own goal): a team-match | nearest of the kicker's side p25/med/p75 | nearest of the other side | both within 2 m % | other side within 2 m % | nobody within 3 m % | the other side has it within 3 s %")
    for z, nm in enumerate(("0-35", "35-70", "70+")):
        v = [r for r in allr if r[0] == z]
        if not v: continue
        print(f"     {nm:6s} {len(v)/tm:5.1f} | {q([r[1] for r in v])} | {q([r[2] for r in v])} | {100*sum(r[1] < 2 and r[2] < 2 for r in v)/len(v):4.1f} | {100*sum(r[2] < 2 for r in v)/len(v):4.1f} | {100*sum(r[1] >= 3 and r[2] >= 3 for r in v)/len(v):4.1f} | {100*sum(r[3] for r in v)/len(v):4.1f}")

#!/usr/bin/env python3
"""benchmarks_tracking_goalside.py — how many defenders stay goal-side of the ball near their goal
(G5.85, game/DESIGN.md §8.186).

    python3 -I game/scripts/benchmarks_tracking_goalside.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB 25 Hz). 5 Hz, ball in play, the side with it by BallPossession, the ball
under 7 m/s (on a foot or dribbled, not passed). The defending side's goal = its keeper's half. GOAL-SIDE =
its outfielders nearer its goal centre than the ball. By the ball's distance to that goal centre
<12 / 12-18 / 18-25 / 25-30 m: frames, goal-side p25 / median / p75, and the share with 0 / 1-2 /
3-4 / 5+. Also the deepest outfielder's metres off the goal line minus the ball's (+ = ball deeper
than him). fh-game-match prints the same as GOAL-SIDE. FH original.
"""
import collections, glob, math, multiprocessing, os, re, statistics, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt

BANDS = (12, 18, 25, 30)


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info)
    half = length / 2
    team_of = {home: 1, guest: 2}
    ball = {}; men = collections.defaultdict(dict); who = {}
    sec = None; cur = None; kind = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if kind is None: continue
            a = s.split('"'); n = int(a[1])
            if kind == "ball":
                st = re.search(r'BallStatus="(\d)"', s); po = re.search(r'BallPossession="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7]), st and st.group(1) == "1", int(po.group(1)) if po else 0)
            elif n % 5 == 0:
                men[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            m = re.search(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"', s)
            sec, tid, pid = m.groups()
            if tid.upper() == "BALL": kind = "ball"
            elif tid in team_of: kind = "man"; cur = pid; who[pid] = team_of[tid]
            else: kind = None
    own = {}
    for sc in {k[0] for k in men}:
        for tm in (1, 2):
            xs = [p[0] for k, ps in men.items() if k[0] == sc for pid, p in ps.items() if pid in keepers and who[pid] == tm]
            own[(sc, tm)] = -1 if (sum(xs) / max(1, len(xs))) < 0 else 1
    out = []
    for (sc, n), ps in men.items():
        b = ball.get((sc, n)); b0 = ball.get((sc, n - 5))
        if not b or not b0 or not b[2] or b[3] not in (1, 2): continue
        if math.hypot(b[0] - b0[0], b[1] - b0[1]) / 0.2 > 7: continue
        dt = 3 - b[3]                                   # the defending side
        gx = own[(sc, dt)] * half
        db = math.hypot(gx - b[0], b[1])
        if db >= BANDS[-1]: continue
        outs = [p for pid, p in ps.items() if who.get(pid) == dt and pid not in keepers]
        g = sum(1 for p in outs if math.hypot(gx - p[0], p[1]) < db)
        deep = min(abs(gx - p[0]) for p in outs) if outs else 0
        out.append((sum(db >= x for x in BANDS[:-1]), g, abs(gx - b[0]) - deep))
    return out, 1


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(min(7, len(files))) as p:
        res = p.map(one, files)
    allr = [r for rs, _ in res for r in rs]
    lab = ("<12", "12-18", "18-25", "25-30")
    print(f"{len(files)} DFL matches: GOAL-SIDE (5 Hz, ball in play under 7 m/s, defenders' outfielders nearer their goal centre than the ball)")
    for b in range(4):
        v = sorted(r[1] for r in allr if r[0] == b); w = sorted(r[2] for r in allr if r[0] == b)
        if not v: continue
        k = len(v)
        print(f"   ball {lab[b]:5s} m from goal centre: {k / 5 / len(files) / 2:5.1f} s a team-match | goal-side p25/med/p75 {v[k // 4]} / {v[k // 2]} / {v[3 * k // 4]} | "
              f"0 {100 * sum(x == 0 for x in v) / k:4.1f}% 1-2 {100 * sum(1 <= x <= 2 for x in v) / k:4.1f}% 3-4 {100 * sum(3 <= x <= 4 for x in v) / k:4.1f}% 5+ {100 * sum(x >= 5 for x in v) / k:4.1f}% | "
              f"deepest man above the ball m p25/med/p75 {w[k // 4]:.1f} / {w[k // 2]:.1f} / {w[3 * k // 4]:.1f}")

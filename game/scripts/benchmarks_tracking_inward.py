#!/usr/bin/env python3
"""benchmarks_tracking_inward.py — how the attack's ball moves across the pitch near the goal it attacks
(G5.87, game/DESIGN.md §8.188).

    python3 -I game/scripts/benchmarks_tracking_inward.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB 25 Hz). 5 Hz, the ball in play both ends of each 0.2 s step, the same side
in BallPossession both ends. The attacked goal = the other side's keeper's half. Steps with the
ball within 35 m of that goal line (x), by the ball's |y| at the start (centre 0-9 / mid 9-20 /
wide 20+ m) and how it moved: CARRIED (under 7 m/s over the step) or PASSED (7+ m/s). For each:
seconds a team-match, and the ball's |y| change summed a team-match (− = toward the middle), and
the ball's metres toward the goal line summed; and ENTRIES — the steps that bring it inside 35 m, by
its |y| there, carried or passed. fh-game-match prints the same as INWARD. FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt

YB = (9, 20)
YL = ("centre 0-9", "mid 9-20", "wide 20+")


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info)
    half = length / 2
    team_of = {home: 1, guest: 2}
    ball = {}; kx = collections.defaultdict(list); who = {}
    sec = None; kind = None; cur = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if kind is None: continue
            a = s.split('"'); n = int(a[1])
            if n % 5: continue
            if kind == "ball":
                st = re.search(r'BallStatus="(\d)"', s); po = re.search(r'BallPossession="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7]), st and st.group(1) == "1", int(po.group(1)) if po else 0)
            elif kind == "keeper" and n % 250 == 0:
                kx[(sec, who[cur])].append(float(a[5]))
        elif s.startswith("<FrameSet "):
            m = re.search(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"', s)
            sec, tid, pid = m.groups()
            if tid.upper() == "BALL": kind = "ball"
            elif tid in team_of and pid in keepers: kind = "keeper"; cur = pid; who[pid] = team_of[tid]
            else: kind = None
    own = {k: (-1 if sum(v) / len(v) < 0 else 1) for k, v in kx.items()}   # sign of each side's own goal line
    c = collections.Counter()
    for (sc, n), b0 in ball.items():
        b1 = ball.get((sc, n + 5))
        if not b1 or not b0[2] or not b1[2] or b0[3] not in (1, 2) or b1[3] != b0[3]: continue
        dt = 3 - b0[3]
        if (sc, dt) not in own: continue
        gx = own[(sc, dt)] * half                       # the attacked goal line
        v = math.hypot(b1[0] - b0[0], b1[1] - b0[1]) / 0.2
        if v > 40: continue
        if abs(gx - b0[0]) >= 35:
            if abs(gx - b1[0]) < 35:   # ENTRY: the step that brings it inside 35 m, by its |y| there and how
                c[("E", "P" if v >= 7 else "C", sum(abs(b1[1]) >= y for y in YB))] += 1
            continue
        yb = sum(abs(b0[1]) >= y for y in YB)
        k = "P" if v >= 7 else "C"
        c[(k, yb, "n")] += 1
        c[(k, yb, "dy")] += abs(b1[1]) - abs(b0[1])
        c[(k, yb, "dx")] += abs(gx - b0[0]) - abs(gx - b1[0])
    return c


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(min(4, len(files))) as p:
        res = p.map(one, files)
    c = collections.Counter()
    for r in res: c.update(r)
    tm = 2 * len(files)
    print(f"{len(files)} DFL matches: INWARD (5 Hz, the attack's ball within 35 m of the goal line it attacks), a team-match:")
    for k, lab in (("C", "carried (under 7 m/s)"), ("P", "passed (7+ m/s)")):
        print(f"   {lab}:")
        for yb in range(3):
            n = c[(k, yb, "n")]
            print(f"      from {YL[yb]:10s}: {n * 0.2 / tm:6.1f} s | |y| change {c[(k, yb, 'dy')] / tm:+7.1f} m | toward the goal line {c[(k, yb, 'dx')] / tm:+7.1f} m")
    print("   ENTRIES into the last 35 m, a team-match, by |y| there " + " / ".join(YL) + ":")
    for k, lab in (("C", "carried"), ("P", "passed")):
        print(f"      {lab}: " + " / ".join(f"{c[('E', k, yb)] / tm:.1f}" for yb in range(3)))

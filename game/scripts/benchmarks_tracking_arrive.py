#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_arrive.py (G5.124, DESIGN §8.225) — usage: <DFL dir>
# Real: the defending side as the ball comes in. An ARRIVAL = the ball (in play, one side in BallPossession)
# inside 12 m of a goal centre at frame n, having been 16 m+ out within the 2 s before. For t = -1 / 0 /
# +0.5 / +1 / +2 s from it (5 Hz): the defenders' outfielders GOAL-SIDE of the ball then (nearer the goal
# centre), deeper than it (depth only), the deepest two's median metres off the line, the ball's distance;
# and their speed toward their own line (m/s, + = dropping). DFL tracking (Bassek et al. 2025, CC BY). FH original.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ROLE = {"IVL": 0, "IVR": 0, "IVZ": 0, "LV": 1, "RV": 1, "DML": 2, "DMR": 2, "DMZ": 2, "DLM": 2, "DRM": 2, "ZO": 3,
        "OLM": 4, "ORM": 4, "LM": 4, "RM": 4, "HL": 4, "HR": 4, "LA": 4, "RA": 4, "STL": 5, "STR": 5, "STZ": 5}   # as benchmarks_tracking_possession
NAMES = ["CB", "FB", "DM/CM", "AM", "WIDE", "ST"]
VB = [(-99, -2, "away"), (-2, 2, "still"), (2, 5, "coming 2-5"), (5, 99, "coming 5+")]   # for the side in possession: back / still / forward 2-5 / forward 5+
def vbin(v):
    for i, (lo, hi, _) in enumerate(VB):
        if lo <= v < hi: return i
    return 1
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
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1 if (st and st.group(1) == "1" and po and po.group(1) in "12") else -1)
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
    import math
    out = []
    last_far = {}
    keys = sorted(ball)
    for (sc, n) in keys:
        bx, by, att = ball[(sc, n)]
        if att < 0: continue
        dfd = 1 - att; g = own[(sc, dfd)]; gx = g * half
        db = math.hypot(gx - bx, by)
        if db >= 16: last_far[(sc, dfd)] = n; continue
        if db >= 12: continue
        lf = last_far.get((sc, dfd))
        if lf is None or n - lf > 50: continue
        last_far[(sc, dfd)] = -10 ** 9   # one arrival per entry
        row = []
        for dt in (-25, 0, 12, 25, 50):   # 25 Hz frames; 12 ~ 0.5 s at the 5 Hz grid
            m = n + dt - (n + dt) % 5
            b = ball.get((sc, m)); fr = pl.get((sc, m)); fr1 = pl.get((sc, m - 5))
            if not b or not fr: row.append(None); continue
            dbb = math.hypot(gx - b[0], b[1])
            outs = [(pid, p) for pid, p in fr.items() if who.get(pid) == dfd and pid not in keepers]
            gs = sum(1 for _, p in outs if math.hypot(gx - p[0], p[1]) < dbb)
            deeper = sum(1 for _, p in outs if abs(gx - p[0]) < abs(gx - b[0]))
            dep = sorted(abs(gx - p[0]) for _, p in outs)
            drop = [((abs(gx - fr1[pid][0]) - abs(gx - p[0])) / 0.2) for pid, p in outs if fr1 and pid in fr1]
            row.append((gs, deeper, (dep[0] + dep[1]) / 2 if len(dep) > 1 else 0, dbb, sorted(drop)[len(drop) // 2] if drop else 0,
                        sum(1 for x in drop if x > 4), abs(gx - b[0]), abs(b[1])))
        out.append(row)
    return out


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(min(7, len(files))) as p:
        res = p.map(one, files)
    rows = [r for rs in res for r in rs]
    med = lambda v: sorted(v)[len(v) // 2] if v else float("nan")
    print(f"{len(files)} DFL matches: ARRIVE, {len(rows)} arrivals inside 12 m ({len(rows) / len(files) / 2:.1f} a team-match) — median at t s from it:")
    for i, t in enumerate(("-1", "0", "+0.5", "+1", "+2")):
        v = [r[i] for r in rows if r[i]]
        print(f"  t {t:>4}: ball {med([x[3] for x in v]):4.1f} m | goal-side {med([x[0] for x in v])} (3+ {100 * sum(x[0] >= 3 for x in v) / len(v):4.1f}%) | deeper than it {med([x[1] for x in v])} | "
              f"deepest two {med([x[2] for x in v]):4.1f} m off | ball off the line {med([x[6] for x in v]):4.1f} |y| {med([x[7] for x in v]):4.1f}, wide (|y| 14+) {100 * sum(x[7] >= 14 for x in v) / len(v):3.0f}% | dropping med {med([x[4] for x in v]):+4.1f} m/s, men 4+ m/s back {sum(x[5] for x in v) / len(v):.2f}")

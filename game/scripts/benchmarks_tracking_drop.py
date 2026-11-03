#!/usr/bin/env python3
"""benchmarks_tracking_drop.py — who is near a high cross when it comes down
(game/DESIGN.md §8.108).

    python3 -I game/scripts/benchmarks_tracking_drop.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177,
CC BY, data owner DFL (7 matches, TRACAB 25 Hz ball with height; events for the
crosses). For each open-play high cross (DFL event Play FromOpenPlay="true"
Height="high" with a Cross child), the first 25 Hz frame within 4 s where the
ball comes down through 2.4 m inside a penalty area: the nearest outfield
defender and attacker to the ball (players at 5 Hz, the frame at or before),
and to where it next lands (z <= 0.3 m, or 1 s on). fh-game-match prints the
same as HIGH CROSS FIRST DROP THROUGH 2.4 M IN THE BOX. FH original.
"""
from datetime import datetime
import bisect, collections, glob, os, re, sys, math, multiprocessing
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info)
    half = length / 2
    team_of = {home: 0, guest: 1}
    ball = {}; pl = collections.defaultdict(dict); who = {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    sec = None; isb = False; skip = True; cur = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if isb:
                st = re.search(r'BallStatus="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7]), float(a[9]), datetime.fromisoformat(a[3]).timestamp(), st and st.group(1) == "1")
            elif n % 5 == 0: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    ev = open(glob.glob(os.path.join(d, f"DFL_03_02_events_raw_*_{mid}"))[0], encoding="utf8").read()
    ctimes = []
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<Play [^>]*FromOpenPlay="true"[^>]*Height="high"[^>]*>\s*<Cross', ev):
        ctimes.append(datetime.fromisoformat(m.group(1)).timestamp())
    out = []
    for sc in sorted({k[0] for k in ball}):
        ks = sorted(k[1] for k in ball if k[0] == sc)
        # which goal each team defends this half: its keeper's mean x
        gx = {0: [], 1: []}
        for n in ks[::250]:
            for pid, p in pl.get((sc, n - n % 5), {}).items():
                if pid in keepers: gx[who[pid]].append(p[0])
        side = {t: (-1 if (sum(v) / len(v) if v else 0) < 0 else 1) for t, v in gx.items()}  # goal at side*half
        tl = [ball[(sc, n)][3] for n in ks]
        starts = set()
        for ct in ctimes:
            j = bisect.bisect_left(tl, ct)
            if j < len(ks) and tl[j] - ct < 0.2:
                for jj in range(j + 1, min(j + 100, len(ks))):   # 4 s
                    if ball[(sc, ks[jj - 1])][2] > 2.4 >= ball[(sc, ks[jj])][2]: starts.add(jj); break
        prev = None
        for i, n in enumerate(ks):
            bx, by, bz = ball[(sc, n)][:3]
            if i in starts and abs(by) < 20.16 and abs(bx) > half - 16.5:
                g = 1 if bx > 0 else -1
                dteam = 0 if side[0] == g else 1
                ps = pl.get((sc, n - n % 5), {})
                land = None
                for m in ks[i:i + 26]:
                    if ball[(sc, m)][2] <= 0.3: land = ball[(sc, m)][:2]; break
                land = land or ball[(sc, ks[min(i + 25, len(ks) - 1)])][:2]
                def near(team, pt):
                    ds = [math.hypot(p[0] - pt[0], p[1] - pt[1]) for pid, p in ps.items() if who[pid] == team and pid not in keepers]
                    return min(ds) if ds else 99
                out.append((near(dteam, (bx, by)), near(1 - dteam, (bx, by)), near(dteam, land), near(1 - dteam, land)))
            prev = (n, bz)
    return out
files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
allr = []
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files): allr += r
def bins(xs): return " ".join(f"{lab} {100*sum(lo <= x < hi for x in xs)/len(xs):.0f}%" for lab, lo, hi in (("<1", 0, 1), ("1-2", 1, 2), ("2-4", 2, 4), ("4+", 4, 999)))
import statistics as st
print(f"{sum(1 for _ in allr)} open-play high crosses: first drop through 2.4 m inside the box, {len(allr)/len(files)/2:.1f} a team-match")
for j, lab in enumerate(["defender to ball", "attacker to ball", "defender to landing", "attacker to landing"]):
    xs = [r[j] for r in allr]; print(f"  {lab:22s} median {st.median(xs):.1f} m | {bins(xs)}")

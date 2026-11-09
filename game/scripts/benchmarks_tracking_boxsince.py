#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_boxsince.py (G5.61, DESIGN §8.162) — usage: <DFL dir>
# Real: men in the box by seconds since the ball was last dead (<3 / 3-6 / 6+), by the ball's zone.
# DFL tracking (Bassek et al. 2025, CC BY); loader as benchmarks_tracking_box.py.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
EDGES = (18, 35, 52, 70)
ROLE = {"IVL": "CB", "IVR": "CB", "IVZ": "CB", "LV": "FB", "RV": "FB", "DML": "DM/CM", "DMR": "DM/CM", "DMZ": "DM/CM",
        "DLM": "DM/CM", "DRM": "DM/CM", "ZO": "AM", "OLM": "WIDE", "ORM": "WIDE", "LM": "WIDE", "RM": "WIDE", "HL": "WIDE",
        "HR": "WIDE", "LA": "WIDE", "RA": "WIDE", "STL": "ST", "STR": "ST", "STZ": "ST"}
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
    c = collections.Counter()
    own = {}
    for sc in {k[0] for k in ball}:
        xs = {0: [], 1: []}
        for (s2, n), ps in pl.items():
            if s2 != sc or n % 250: continue
            for pid, p in ps.items():
                if pid in keepers: xs[who[pid]].append(p[0])
        for tm in (0, 1): own[(sc, tm)] = -1 if (sum(xs[tm]) / max(1, len(xs[tm]))) < 0 else 1
    live = set(ball.keys())
    for (sc, n), (bx, by, att) in ball.items():
        g = -own[(sc, att)]
        btl = half - bx * g
        if btl >= 52: continue
        bz = (0 if btl < 18 else 1 if btl < 35 else 2) * 2 + (0 if abs(by) < 20.16 else 1)
        m = n; 
        while (sc, m - 5) in live and n - m < 250: m -= 5
        since = (n - m) / 25.0; sb = 0 if since < 3 else 1 if since < 6 else 2
        fr = pl.get((sc, n), {})
        c[("f", bz, sb)] += 1
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers: continue
            if half - x * g < 18 and abs(y) < 20.16: c[("in", bz, sb)] += 1
    return c
files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files): c.update(r)
nm = ("0-18 c", "0-18 w", "18-35 c", "18-35 w", "35-52 c", "35-52 w")
for bz in range(6):
    t = sum(c[("f", bz, s)] for s in range(3))
    print(f"ball {nm[bz]}: " + " ".join(f"{lab} {100*c[('f',bz,s)]/t:.0f}% of frames, in box {c[('in',bz,s)]/max(1,c[('f',bz,s)]):.2f};" for s, lab in enumerate(("<3 s", "3-6 s", "6+ s"))))

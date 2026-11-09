#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_linegaps.py (G5.62, DESIGN §8.163) — usage: <DFL dir>
# Real: ball 18-35 m out, the side in possession's outfielders by metres short of their offside line
# (second-last, keeper in, or the ball), split by that line inside 16 m or not. DFL (Bassek et al. 2025, CC BY).
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
    for (sc, n), (bx, by, att) in ball.items():
        g = -own[(sc, att)]
        btl = half - bx * g
        if btl < 18 or btl >= 35: continue
        bz = 0 if abs(by) < 20.16 else 1
        fr = pl.get((sc, n), {})
        dtl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == 1 - att)
        if len(dtl) < 2: continue
        L = min(dtl[1], btl); dp = 1 if L < 16 else 0
        c[("f", bz, dp)] += 1
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers: continue
            gap = (half - x * g) - L
            b = 0 if gap < 0 else 1 if gap < 2 else 2 if gap < 5 else 3 if gap < 10 else 4
            c[("g", bz, dp, b)] += 1
    return c
files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files): c.update(r)
for bz, nm in enumerate(("18-35 centre", "18-35 wide")):
    for dp in (1, 0):
        f = max(1, c[("f", bz, dp)])
        print(f"ball {nm} line {'<16' if dp else '16+'}: men past / 0-2 / 2-5 / 5-10 / 10+ m short of their line: " + " / ".join(f"{c[('g',bz,dp,b)]/f:.2f}" for b in range(5)))

#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_boxprior.py (G5.61, DESIGN §8.162) — usage: <DFL dir>
# Real: of the side in possession's men in the box, in it 2 s before and how far they moved; the ball's zone 2 s before, by the ball's zone.
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
    for (sc, n), (bx, by, att) in ball.items():
        g = -own[(sc, att)]
        btl = half - bx * g
        if btl >= 52: continue
        bz = (0 if btl < 18 else 1 if btl < 35 else 2) * 2 + (0 if abs(by) < 20.16 else 1)
        fr = pl.get((sc, n), {}); fp = pl.get((sc, n - 50), {}); bp = ball.get((sc, n - 50))
        c[("f", bz)] += 1
        if bp is not None and bp[2] == att:
            pb = half - bp[0]*g; pz = (0 if pb < 18 else 1 if pb < 35 else 2 if pb < 52 else 3) * 2 + (0 if abs(bp[1]) < 20.16 else 1)
            c[("bz2", bz, pz)] += 1
        else: c[("bz2", bz, "notours")] += 1
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers: continue
            tl = half - x * g
            if tl >= 18 or abs(y) >= 20.16: continue
            c[("in", bz)] += 1
            if pid in fp:
                x0, y0 = fp[pid]; t0 = half - x0*g
                if t0 < 18 and abs(y0) < 20.16: c[("was_in", bz)] += 1
                c[("d2", bz)] += ((x-x0)**2+(y-y0)**2)**.5; c[("t0", bz)] += t0; c[("n2", bz)] += 1
    return c
files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files): c.update(r)
nm = ("0-18 c", "0-18 w", "18-35 c", "18-35 w", "35-52 c", "35-52 w", "52+ c", "52+ w")
for bz in range(6):
    f=c[("f",bz)]; i=c[("in",bz)]; n2=max(1,c[("n2",bz)])
    print(f"ball {nm[bz]}: in box {i/f:.2f}; of them in box 2 s before {100*c[('was_in',bz)]/max(1,i):.0f}%, moved {c[('d2',bz)]/n2:.1f} m, were {c[('t0',bz)]/n2:.1f} m off the line")
    tot=sum(v for k,v in c.items() if k[0]=="bz2" and k[1]==bz)
    print("   ball 2 s before: "+" ".join(f"{nm[k[2]] if k[2]!='notours' else 'not ours'} {100*v/tot:.0f}%" for k,v in sorted(c.items(), key=lambda kv:-kv[1]) if k[0]=="bz2" and k[1]==bz))

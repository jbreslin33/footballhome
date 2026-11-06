#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_press.py (G5.25, DESIGN §8.123) — usage: <DFL dir>
# Real: how close the nearest defender stands to the man on the ball, by where the ball is.
# Carrier = the attacker (BallPossession side, in play, 5 Hz) nearest the ball within 2 m. For
# each band of the ball's metres from THEIR line (0-18, 18-35, 35-52, 52-70, 70+): frames, the
# nearest defender's distance — 25th / 50th / 75th percentile — and the share inside 2 / 3 / 5 m.
# DFL tracking (Bassek et al. 2025, CC BY); loader as benchmarks_tracking_channel.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
EDGES = (18, 35, 52, 70)
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
    c = collections.defaultdict(list)
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
        fr = pl.get((sc, n), {})
        cd = None
        for pid, (x, y) in fr.items():
            if who.get(pid) != att:
                continue
            d = ((x - bx) ** 2 + (y - by) ** 2) ** 0.5
            if d < 2.0 and (cd is None or d < cd[0]):
                cd = (d, x, y)
        if cd is None:
            continue
        nb = min(((((x - cd[1]) ** 2 + (y - cd[2]) ** 2) ** 0.5, x) for pid, (x, y) in fr.items()
                  if who.get(pid) is not None and who[pid] != att and pid not in keepers), default=None)
        if nb is None:
            continue
        b = sum(btl >= t for t in EDGES)
        # G5.39 (§8.139): is he goal-side — nearer the defenders' goal line (x = g * half) than the carrier?
        c[b].append((nb[0], nb[1] * g > cd[1] * g))
    return dict(c)


files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
allc = collections.defaultdict(list)
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files):
        for k, v in r.items():
            allc[k].extend(v)
print(f"{len(files)} DFL matches: the nearest defender to the man on the ball, by the ball's metres from their line")
for b, name in enumerate(("0-18", "18-35", "35-52", "52-70", "70+")):
    raw = allc.get(b, [])
    if not raw:
        continue
    gs = 100 * sum(1 for x in raw if x[1]) / len(raw)
    v = sorted(x[0] for x in raw)
    q = lambda p: v[min(len(v) - 1, int(p * len(v)))]
    print(f"   {name:6s} frames {len(v):6d}  p25 {q(.25):4.1f}  median {q(.5):4.1f}  p75 {q(.75):4.1f} m;  inside 2 m {100*sum(x < 2 for x in v)/len(v):4.1f}%  3 m {100*sum(x < 3 for x in v)/len(v):4.1f}%  5 m {100*sum(x < 5 for x in v)/len(v):4.1f}%;  goal-side {gs:4.1f}%")

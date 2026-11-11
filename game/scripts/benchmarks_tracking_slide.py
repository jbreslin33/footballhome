#!/usr/bin/env python3
"""benchmarks_tracking_slide.py — how far each role slides across with the ball in possession
(G5.88, game/DESIGN.md §8.189).

    python3 -I game/scripts/benchmarks_tracking_slide.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB 25 Hz). 5 Hz, ball in play, the side in BallPossession, the ball 25-60 m off
the line it attacks, the man on the ball (nearest outfielder within 2 m) left out. For each man (a
player in a half): least-squares slope of his y on the ball's y (within that man, both demeaned) and
his mean y; pooled by role (DFL PlayingPosition, as benchmarks_tracking_zonemates). Also each role's
mean |y| with the ball wide on his side (|ball y| 14+, same sign) and on the far side. fh-game-match
prints the same as SLIDE BY ROLE. FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt

ROLE = {"IVL": "CB", "IVR": "CB", "IVZ": "CB", "LV": "FB", "RV": "FB", "DML": "DM/CM", "DMR": "DM/CM", "DMZ": "DM/CM",
        "DLM": "DM/CM", "DRM": "DM/CM", "ZO": "AM", "OLM": "WIDE", "ORM": "WIDE", "LM": "WIDE", "RM": "WIDE", "HL": "WIDE",
        "HR": "WIDE", "LA": "WIDE", "RA": "WIDE", "STL": "ST", "STR": "ST", "STZ": "ST"}
ROLES = ("CB", "FB", "DM/CM", "AM", "WIDE", "ST")


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
    S = collections.defaultdict(list)   # (sec, pid) -> [(by, y)]
    W = collections.defaultdict(list)   # (role, near/far) -> |y|
    for (sc, n), (bx, by, att) in ball.items():
        g = -own[(sc, att)]
        tl = half - bx * g
        if not 25 <= tl < 60: continue
        fr = pl.get((sc, n), {})
        mates = [(pid, x, y) for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers]
        if not mates: continue
        dd = min((math.hypot(x - bx, y - by), pid) for pid, x, y in mates)
        if dd[0] > 2: continue
        for pid, x, y in mates:
            if pid == dd[1]: continue
            r = ROLE.get(pos_of.get(pid, ""))
            if not r: continue
            S[(sc, pid, r)].append((by, y))
            if abs(by) >= 14:
                W[(r, "near" if (y > 0) == (by > 0) else "far")].append(abs(y))
    out = collections.defaultdict(lambda: [0.0, 0.0, 0])   # role -> sxy, sxx, n
    for (sc, pid, r), v in S.items():
        if len(v) < 50: continue
        mb = sum(p[0] for p in v) / len(v); my = sum(p[1] for p in v) / len(v)
        o = out[r]
        o[0] += sum((p[0] - mb) * (p[1] - my) for p in v); o[1] += sum((p[0] - mb) ** 2 for p in v); o[2] += len(v)
    return dict(out), {k: v for k, v in W.items()}


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(min(4, len(files))) as p:
        res = p.map(one, files)
    tot = collections.defaultdict(lambda: [0.0, 0.0, 0]); W = collections.defaultdict(list)
    for o, w in res:
        for r, v in o.items():
            for i in range(3): tot[r][i] += v[i]
        for k, v in w.items(): W[k] += v
    print(f"{len(files)} DFL matches: SLIDE BY ROLE (in possession, ball 25-60 m off their line, the man on the ball out)")
    for r in ROLES:
        sxy, sxx, n = tot[r]
        if not n: continue
        near = sorted(W[(r, "near")]); far = sorted(W[(r, "far")])
        med = lambda v: v[len(v) // 2] if v else float("nan")
        print(f"   {r:6s} slope of his y on the ball's y {sxy / sxx:.2f} (n {n}) | |y| med with the ball wide (|y| 14+) on his side {med(near):.1f} m, far side {med(far):.1f} m")

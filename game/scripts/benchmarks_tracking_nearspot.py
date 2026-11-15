#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_nearspot.py (G5.123, DESIGN §8.224) — usage: <DFL dir>
# Real: where the side without the ball stands near its own goal, by the ball's depth AND width.
# The other side in BallPossession, in play, 5 Hz, the ball under 7 m/s (on a foot), within 25 m of
# the defenders' own line: by the ball's metres off that line 0-6 / 6-12 / 12-18 / 18-25 x its |y|
# 0-8 / 8-16 / 16+: each role's median metres off its own line, the median of (his depth - the
# ball's), and the share of him nearer the goal centre than the ball (GOAL-SIDE). The settled spot
# table (§8.142) keys on depth only; a central ball 6 m out and a wide one by the byline share a row.
# Roles as benchmarks_tracking_possession. DFL tracking (Bassek et al. 2025, CC BY). FH original.
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
    out = collections.defaultdict(list)
    for (sc, n) in ball:
        bx, by, att = ball[(sc, n)]
        if att < 0: continue
        prev = ball.get((sc, n - 5))
        if prev is None or ((bx - prev[0]) ** 2 + (by - prev[1]) ** 2) ** 0.5 / 0.2 > 7: continue
        dfd = 1 - att; g = own[(sc, dfd)]
        gx = g * half
        btl = abs(gx - bx)
        if btl >= 25: continue
        db = (gx - bx) ** 2 + by ** 2
        bb = 0 if btl < 6 else 1 if btl < 12 else 2 if btl < 18 else 3
        yb = 0 if abs(by) < 8 else 1 if abs(by) < 16 else 2
        for pid, p in pl.get((sc, n), {}).items():
            if who.get(pid) != dfd or pid in keepers: continue
            r = ROLE.get(pos_of.get(pid, ""), -1)
            if r < 0: continue
            dm = abs(gx - p[0])
            out[(bb, yb, r)].append((dm, dm - btl, (gx - p[0]) ** 2 + p[1] ** 2 < db))
    return out


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(min(7, len(files))) as p:
        res = p.map(one, files)
    allr = collections.defaultdict(list)
    for r in res:
        for k, v in r.items(): allr[k] += v
    med = lambda v: sorted(v)[len(v) // 2] if v else float("nan")
    BL, YL = ("0-6", "6-12", "12-18", "18-25"), ("0-8", "8-16", "16+")
    print(f"{len(files)} DFL matches: NEAR SPOT (ball on a foot within 25 m of their line): per role median m off the line [his depth - ball's] goal-side %, n frames")
    for bb in range(4):
        for yb in range(3):
            cells = []
            for r in range(6):
                v = allr.get((bb, yb, r), [])
                cells.append(f"{NAMES[r]} {med([x[0] for x in v]):4.1f} [{med([x[1] for x in v]):+5.1f}] {100 * sum(x[2] for x in v) / max(1, len(v)):3.0f}%")
            n = len(allr.get((bb, yb, 0), []))
            print(f"  ball {BL[bb]:>5} m off, |y| {YL[yb]:>4}: " + " | ".join(cells) + f"  (CB n {n})")

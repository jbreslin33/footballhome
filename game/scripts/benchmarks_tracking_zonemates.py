#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_zonemates.py (G5.59, DESIGN §8.160) — usage: <DFL dir>
# Real: the side in possession's mates in each zone of the pass policy's grid (their line 0-18 /
# 18-35 / 35-52 / 52-70 / 70+ m × centre |y| < 20.16 or wide), by the ball's zone (in play, 5 Hz).
# The man on the ball (the nearest outfielder within 2 m) is not counted; with nobody within 2 m
# the frame is skipped. Wide zones on the ball's side and the far side are told apart. Per zone:
# the mean count and the share of frames with none; for the ball's own zone, by role and how far
# from the ball the nearest mate stands.
# DFL tracking (Bassek et al. 2025, CC BY); loader as benchmarks_tracking_box.
import collections, glob, os, re, sys, multiprocessing, math
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ROLE = {"IVL": "CB", "IVR": "CB", "IVZ": "CB", "LV": "FB", "RV": "FB", "DML": "DM/CM", "DMR": "DM/CM", "DMZ": "DM/CM",
        "DLM": "DM/CM", "DRM": "DM/CM", "ZO": "AM", "OLM": "WIDE", "ORM": "WIDE", "LM": "WIDE", "RM": "WIDE", "HL": "WIDE",
        "HR": "WIDE", "LA": "WIDE", "RA": "WIDE", "STL": "ST", "STR": "ST", "STZ": "ST"}   # as benchmarks_tracking_box
def zone(tl, y, by):
    b = 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4
    if abs(y) < 20.16: return b * 3
    return b * 3 + (1 if (y > 0) == (by > 0) else 2)   # 1 = wide on the ball's side, 2 = far side
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
    c = collections.Counter(); own = {}
    for sc in {k[0] for k in ball}:
        xs = {0: [], 1: []}
        for (s2, n), ps in pl.items():
            if s2 != sc or n % 250: continue
            for pid, p in ps.items():
                if pid in keepers: xs[who[pid]].append(p[0])
        for tm in (0, 1): own[(sc, tm)] = -1 if (sum(xs[tm]) / max(1, len(xs[tm]))) < 0 else 1
    for (sc, n), (bx, by, att) in ball.items():
        g = -own[(sc, att)]
        fr = pl.get((sc, n), {})
        mates = [(pid, x, y) for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers]
        if not mates: continue
        dd = sorted((math.hypot(x - bx, y - by), pid) for pid, x, y in mates)
        if dd[0][0] > 2: continue
        carrier = dd[0][1]
        bz = zone(half - bx * g, by, by)
        c[("f", bz)] += 1
        c[("carrier", bz, ROLE.get(pos_of.get(carrier, ""), "?"))] += 1   # G5.88: who has it
        cnt = collections.Counter(); near = 99.0
        for pid, x, y in mates:
            if pid == carrier: continue
            z = zone(half - x * g, y, by); cnt[z] += 1
            c[("zrole", bz, z, ROLE.get(pos_of.get(pid, ""), "?"))] += 1   # G5.88 (§8.189): every zone's mates by role
            if z == bz:
                c[("role", bz, ROLE.get(pos_of.get(pid, ""), "?"))] += 1
                near = min(near, math.hypot(x - bx, y - by))
        for z in range(15):
            c[("n", bz, z)] += cnt[z]
            if cnt[z] == 0: c[("zero", bz, z)] += 1
        if near < 99: c[("near", bz)] += near; c[("nearn", bz)] += 1
    return c


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files):
            c.update(r)
    bands = ("0-18", "18-35", "35-52", "52-70", "70+"); sides = ("centre", "wide", "far wide")
    nm = lambda z: f"{bands[z // 3]} {sides[z % 3]}"
    print(f"{len(files)} DFL matches: the side in possession's mates (not the man on the ball) by zone, by the ball's zone")
    for bz in (0, 1, 3, 4, 6, 7, 9, 10):
        f = c[("f", bz)]
        if not f: continue
        roles = sorted({k[2] for k in c if k[0] == "role" and k[1] == bz})
        print(f"   ball {nm(bz):14s} frames {f:6d}; own zone: {c[('n',bz,bz)]/f:.2f} mates, none {100*c[('zero',bz,bz)]/f:.0f}%, nearest {c[('near',bz)]/max(1,c[('nearn',bz)]):.1f} m; by role "
              + " ".join(f"{r} {c[('role',bz,r)]/f:.2f}" for r in roles))
        print("      on the ball: " + " ".join(f"{r} {100*c[('carrier',bz,r)]/f:.0f}%" for r in ("CB", "FB", "DM/CM", "AM", "WIDE", "ST")))
        for z in range(15):   # G5.88: who stands in each held zone
            if c[("n", bz, z)] / f >= 0.3:
                print(f"      in {nm(z):14s} by role: " + " ".join(f"{r} {c[('zrole',bz,z,r)]/f:.2f}" for r in ("CB", "FB", "DM/CM", "AM", "WIDE", "ST")))
        print("      mean (none %): " + "; ".join(f"{nm(z)} {c[('n',bz,z)]/f:.2f} ({100*c[('zero',bz,z)]/f:.0f}%)" for z in range(15) if c[("n", bz, z)]))

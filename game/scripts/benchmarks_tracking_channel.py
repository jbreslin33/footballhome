#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_channel.py (G5.13, DESIGN §8.110) — usage: <DFL dir>
# Real: with the ball wide 18-35 m off the line the side on it attacks (|y| 14+, in play, 5 Hz),
# who is ahead of it on its side: attackers / defenders in the channel (0-18 m off the line, |y| 14+,
# ball side), attackers ahead of the ball on its side (|y| 10+) and how many of them run at 4 m/s+
# toward the line, by role. DFL tracking (Bassek et al. 2025, CC BY).
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
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
        g = -own[(sc, att)]                      # the goal it attacks is at g*half
        btl = half - bx * g
        if not (18 <= btl < 35 and abs(by) >= 14): continue
        c["n"] += 1
        prev = pl.get((sc, n - 5), {})
        for pid, (x, y) in pl.get((sc, n), {}).items():
            if pid in keepers: continue
            r = ROLE.get(pos_of.get(pid, ""), "?")
            tl = half - x * g
            side = "att" if who[pid] == att else "def"
            same = (y > 0) == (by > 0)
            if tl < 18 and abs(y) >= 14 and same: c[(side, "chan")] += 1
            if tl < 16.5 and abs(y) < 20.16: c[(side, "box")] += 1
            if side == "att" and tl < btl and same and abs(y) >= 10:
                c[("ahead", r)] += 1
                if pid in prev:
                    vt = (x - prev[pid][0]) * g / 0.2   # toward the line it attacks
                    if vt >= 4: c[("run", r)] += 1
    return c
files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files): c.update(r)
n = c["n"]
print(f"{n} frames ({n/5/len(files)/2:.0f} s a team-match), ball wide 18-35 m off their line")
print(f"  in the channel (0-18, |y| 14+, ball side): attackers {c[('att','chan')]/n:.2f}, defenders {c[('def','chan')]/n:.2f}; in the box: attackers {c[('att','box')]/n:.2f}, defenders {c[('def','box')]/n:.2f}")
roles = sorted({k[1] for k in c if isinstance(k, tuple) and k[0] == "ahead"})
print("  attackers ahead of the ball on its side (|y| 10+), a frame / running 4 m/s+ at the line:", "; ".join(f"{r} {c[('ahead',r)]/n:.2f}/{c[('run',r)]/n:.2f}" for r in roles),
      f"; all {sum(c[('ahead',r)] for r in roles)/n:.2f}/{sum(c[('run',r)] for r in roles)/n:.2f}")

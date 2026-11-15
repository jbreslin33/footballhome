#!/usr/bin/env python3
"""game/scripts/benchmarks_tracking_wingmates.py — the man on the ball wide, and the mates in his zone with him
(G5.125, game/DESIGN.md §8.226).

    python3 -I game/scripts/benchmarks_tracking_wingmates.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches,
TRACAB 5 Hz). Frames in play with the side in possession (DFL's BallPossession) having a man within 2 m of the
ball, the ball WIDE (|y| 20.16 m+, the box's width) 0-18 / 18-35 / 35-52 m off the line that side attacks — the
pass policy's wide zones. For the ball's own zone, the side on it's other outfielders standing there (same depth
band, |y| 20.16+ on the ball's side): how many (0 / 1 / 2 / 3+ %), by role (mean a frame), and where each stands
from the ball — AHEAD (m toward their goal line; - = behind the ball) and IN (m toward the centre line; - =
nearer the touchline) and his DISTANCE from it, p25 / median / p75, all and by role. And the man on the ball's role.
fh-game-match prints the same as WING MATES.
FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_zonemates import ROLE

W = 20.16
BANDS = ("0-18", "18-35", "35-52")
RN = ("CB", "FB", "DM/CM", "AM", "WIDE", "ST")


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
    c = collections.Counter(); H = collections.defaultdict(list)
    for (sc, n), (bx, by, att) in ball.items():
        if abs(by) < W: continue
        g = -own[(sc, att)]                       # +1: they attack +x
        tl = half - bx * g
        if tl >= 52: continue
        b = 0 if tl < 18 else 1 if tl < 35 else 2
        mates = [(pid, x, y) for pid, (x, y) in pl.get((sc, n), {}).items() if who.get(pid) == att and pid not in keepers]
        if not mates: continue
        dd = sorted((math.hypot(x - bx, y - by), pid) for pid, x, y in mates)
        if dd[0][0] > 2: continue
        carrier = dd[0][1]; sg = 1 if by > 0 else -1
        c[("f", b)] += 1; c[("car", b, ROLE.get(pos_of.get(carrier, ""), "?"))] += 1
        k = 0
        for pid, x, y in mates:
            if pid == carrier or y * sg < W: continue
            t2 = half - x * g
            if (0 if t2 < 18 else 1 if t2 < 35 else 2 if t2 < 52 else 3) != b: continue
            k += 1; r = ROLE.get(pos_of.get(pid, ""), "?")
            c[("r", b, r)] += 1
            ah = (x - bx) * g; inn = (by - y) * sg
            H[("ah", b)].append(ah); H[("in", b)].append(inn); H[("ah", b, r)].append(ah); H[("in", b, r)].append(inn)
            H[("d", b)].append(math.hypot(ah, inn)); H[("d", b, r)].append(math.hypot(ah, inn))
        c[("k", b, min(k, 3))] += 1
    return c, H


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); H = collections.defaultdict(list)
    with multiprocessing.Pool(2) as pool:
        for cc, hh in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in hh.items(): H[k2] += v
    def q(v, p): v = sorted(v); return v[min(len(v) - 1, int(p * len(v)))] if v else float("nan")
    def t3(v): return f"{q(v, .25):+.1f} / {q(v, .5):+.1f} / {q(v, .75):+.1f}"
    print(f"{len(files)} DFL matches: WING MATES — the ball wide (|y| {W}+) with the side on it; its mates in the ball's own zone")
    for b in range(3):
        f = c[("f", b)]
        if not f: continue
        print(f"  ball {BANDS[b]:5s} wide  frames {f:6d} | mates there 0 / 1 / 2 / 3+ %: " + " / ".join(f"{100 * c[('k', b, k)] / f:.0f}" for k in range(4))
              + f" | mean {sum(c[('r', b, r)] for r in RN) / f:.2f}: " + " ".join(f"{r} {c[('r', b, r)] / f:.2f}" for r in RN))
        print(f"        on the ball: " + " ".join(f"{r} {100 * c[('car', b, r)] / f:.0f}%" for r in RN))
        print(f"        from the ball, AHEAD p25/med/p75 {t3(H[('ah', b)])} m, IN {t3(H[('in', b)])} m, DISTANCE {t3(H[('d', b)])} m")
        for r in RN:
            if len(H[("ah", b, r)]) >= 100:
                print(f"          {r:5s} n {len(H[('ah', b, r)]):5d}  AHEAD {t3(H[('ah', b, r)])}  IN {t3(H[('in', b, r)])}  DISTANCE {t3(H[('d', b, r)])}")

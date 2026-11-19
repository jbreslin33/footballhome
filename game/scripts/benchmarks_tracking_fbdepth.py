#!/usr/bin/env python3
"""benchmarks_tracking_fbdepth.py — where the full-backs stand in possession: m ahead of the ball and off the touchline,
by the ball's band and the spell's age (G5.174, game/DESIGN.md §8.280).

    python3 -I game/scripts/benchmarks_tracking_fbdepth.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB positions at 5 Hz; loader as benchmarks_tracking_spellpace.py). A spell = consecutive in-play frames with
one BallPossession side (a dead ball ends it); "won" = the frame before it was the other side's in play, else "restart".
For each FB / WIDE / DM-CM of the side on the ball (DFL PlayingPosition as benchmarks_tracking_runs): his m off the
touchline his side of the pitch at the spell's start (d0), at 1 / 2 / 3 / 5 / 8 s on, and his speed toward it (1 s
displacement). The men who start 10 m+ off and reach 5 m inside the spell: the time it took and the mean pace across.

Spells and roles as benchmarks_tracking_widepace.py (5 Hz, a spell = in-play frames with one BallPossession side). Every
frame of a spell: each FB of the side on the ball, near (the ball's side of the pitch) or far — his m ahead of the ball
toward the goal attacked, and m off his touchline; by the ball's m off the goal line attacked 0-35 / 35-70 / 70+ and the
spell's age 0-3 / 3-8 / 8+ s. For those within 5 m of the line, how far ahead of the ball they stand.

§8.279: our near FB with the ball 70 m+ out is on his line 15 / 30 / 52% by age (DFL 36 / 43 / 70), and a rolled FB trails
his target's depth (7.8 m), not its width.
"""
import collections, glob, math, multiprocessing, os, re, statistics, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES

TS = (1, 2, 3, 5, 8)


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    info = open(info_p, encoding="utf8").read()
    hy = float(re.search(r'PitchY="([\d.]+)"', info).group(1)) / 2
    half = length / 2; team_of = {home: 0, guest: 1}
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', info))
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
                live = st and st.group(1) == "1" and po and po.group(1) in "12"
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1) if live else None
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
    # spells
    spells = []; sp = None; prev = None
    for key in sorted(ball):
        b = ball[key]
        if b is None or sp is None or b[2] != sp["tm"] or key[0] != sp["sc"] or key[1] - sp["n1"] > 5:
            if sp: spells.append(sp)
            sp = None
            if b is not None:
                won = prev is not None and prev[0] == key[0] and key[1] - prev[1] <= 5 and ball[prev] is not None and ball[prev][2] != b[2]
                sp = {"tm": b[2], "sc": key[0], "n0": key[1], "n1": key[1], "won": won, "b0": b}
        else:
            sp["n1"] = key[1]
        prev = key
    if sp: spells.append(sp)
    c = collections.Counter(); L = collections.defaultdict(list)
    c["matches"] = 1
    for sp in spells:
        sc, tm, n0 = sp["sc"], sp["tm"], sp["n0"]
        gdir = -own[(sc, tm)]
        for n in range(n0, sp["n1"] + 1, 5):
            b = ball.get((sc, n)); fr = pl.get((sc, n))
            if not b or not fr:
                continue
            bx, by, _ = b
            z = 0 if half - bx * gdir < 35 else 1 if half - bx * gdir < 70 else 2
            age = (n - n0) / 25.0; ab = 0 if age < 3 else 1 if age < 8 else 2
            for pid, p in fr.items():
                if who.get(pid) != tm or pid in keepers or ROLE.get(pos_of.get(pid, ""), 6) != 1:
                    continue
                sd = 0 if (p[1] >= 0) == (by >= 0) else 1
                ahead = (p[0] - bx) * gdir; off = hy - abs(p[1])
                L[("a", sd, z, ab)].append(ahead); L[("o", sd, z, ab)].append(off)
                if off < 5:
                    L[("a5", sd, z, ab)].append(ahead)
                q0 = pl.get((sc, n - 5), {}).get(pid)
                if q0:   # his speed (0.2 s) and its upfield part
                    L[("v", sd, z, ab)].append(math.hypot(p[0] - q0[0], p[1] - q0[1]) / 0.2)
                    L[("vx", sd, z, ab)].append((p[0] - q0[0]) * gdir / 0.2)
    return c, dict(L)


def q(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(p * len(xs)))] if xs else float("nan")


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    tot = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pl_:
        for c, l in pl_.imap_unordered(one, files):
            tot.update(c)
            for k, v in l.items(): L[k].extend(v)
    zn = ("0-35", "35-70", "70+"); an = ("0-3", "3-8", "8+")
    print(f"{tot['matches']} DFL matches, every 5 Hz frame of a spell; the side on the ball's FBs")
    print("  side ball   age  | ahead of the ball m p25 / med / p75 | off his line m med, within 5 m % | those within 5 m: ahead med")
    for sd in (0, 1):
        for z in range(3):
            for ab in range(3):
                a = L.get(("a", sd, z, ab), []); o = L.get(("o", sd, z, ab), []); a5 = L.get(("a5", sd, z, ab), [])
                if len(a) < 50: continue
                print(f"  {'near' if sd == 0 else 'far ':4s} {zn[z]:5s} {an[ab]:3s} | {q(a, .25):6.1f} / {q(a, .5):6.1f} / {q(a, .75):6.1f} | {q(o, .5):5.1f}, {100 * sum(x < 5 for x in o) / len(o):3.0f}% | {q(a5, .5) if a5 else float('nan'):6.1f}")
    print("  SPEED: m/s % <1 / 1-2 / 2-4 / 4+ | upfield m/s med, p90")
    for sd in (0, 1):
        for z in range(3):
            for ab in range(3):
                v = L.get(("v", sd, z, ab), []); vx = L.get(("vx", sd, z, ab), [])
                if len(v) < 50: continue
                print(f"  {'near' if sd == 0 else 'far ':4s} {zn[z]:5s} {an[ab]:3s} | " + " / ".join(f"{100 * sum(lo <= x < hi for x in v) / len(v):2.0f}" for lo, hi in ((0, 1), (1, 2), (2, 4), (4, 99)))
                      + f" | {q(vx, .5):+.2f}, {q(vx, .9):+.2f}")
    print("  C table near/far x band x age: ahead med, off med, within 5 m %")
    for sd in (0, 1):
        print("   ", [[(round(q(L.get(('a', sd, z, ab), [0]), .5), 1), round(q(L.get(('o', sd, z, ab), [0]), .5), 1), round(100 * sum(x < 5 for x in L.get(('o', sd, z, ab), [])) / max(1, len(L.get(('o', sd, z, ab), []))))) for ab in range(3)] for z in range(3)])

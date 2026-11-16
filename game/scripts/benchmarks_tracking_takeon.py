#!/usr/bin/env python3
"""benchmarks_tracking_takeon.py — what happens when a defender stands square in front of the man on the
ball (G5.130, game/DESIGN.md §8.231), on real tracking, by the harness's own take-on cut.

    python3 -I game/scripts/benchmarks_tracking_takeon.py <dfl dir>

FACED: a defender goal-side within 1.5 m in the carrier's 45 deg cone (fh-game-match's take-on cut,
benchmarks_tracking_pressure.py). The man on the ball = the in-possession side's nearest outfielder to the
ball within 2 m, 5 Hz, ball in play (a gap of one frame allowed). From the first faced frame, the outcome:
PAST = while still the man on the ball he gets 1 m goal-ward of that defender; else at the spell's end
LOST = DFL's BallPossession is the other side's 1 s later; KEPT = his side still has it (a pass, or the
ball off him to a mate). Also: the zone (carrier's m off their line), seconds faced to the spell's end,
the carrier's speed and the defender's at the faced frame.

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches of 2022/23, TRACAB positions; loader as benchmarks_tracking_box.py).
"""
import collections, glob, math, multiprocessing, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
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
    c = collections.Counter()
    c["matches"] = 1
    keys = sorted(ball)
    # spell: carrier, last n, sc, faced-defender, faced zone, faced n, past?, start n
    sp = None
    def close(sp):
        if not sp or sp["d"] is None: return
        z = sp["z"]; c[("faced", z)] += 1
        dur = (sp["last"] - sp["fn"]) / 25.0; c[("dur", z)] += dur
        if sp["past"]: c[("past", z)] += 1; return
        later = ball.get((sp["sc"], sp["last"] + 25))
        if later is None:
            for dn in (20, 30, 15, 35, 10):
                later = ball.get((sp["sc"], sp["last"] + dn))
                if later: break
        if later is not None and later[2] != sp["att"]: c[("lost", z)] += 1
        else: c[("kept", z)] += 1
    prevpos = {}
    for key in keys:
        sc, n = key
        bx, by, att = ball[key]
        fr = pl.get(key, {})
        g = -own[(sc, att)]
        best = None
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers: continue
            dd = math.hypot(x - bx, y - by)
            if dd < 2 and (best is None or dd < best[0]): best = (dd, pid)
        if best is None:
            if sp and n - sp["last"] > 5: close(sp); sp = None
            continue
        car = best[1]
        if not sp or sp["car"] != car or n - sp["last"] > 10 or sc != sp["sc"]:
            close(sp)
            sp = {"car": car, "last": n, "sc": sc, "d": None, "past": False, "att": att}
        sp["last"] = n
        cx, cy = fr[car]
        tl = half - cx * g
        z = 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4
        if sp["d"] is None:
            for pid, (x, y) in fr.items():
                if who.get(pid) == att or pid in keepers: continue
                dd = math.hypot(x - cx, y - cy); ahead = (x - cx) * g
                if dd < 1.5 and ahead > 0 and abs(y - cy) <= ahead:
                    sp["d"] = pid; sp["z"] = z; sp["fn"] = n
                    pc = prevpos.get((sc, n - 5), {})
                    if car in pc: c[("cv", z)] += math.hypot(cx - pc[car][0], cy - pc[car][1]) / 0.2
                    if pid in pc: c[("dv", z)] += math.hypot(x - pc[pid][0], y - pc[pid][1]) / 0.2
                    break
        elif not sp["past"] and sp["d"] in fr and (cx - fr[sp["d"]][0]) * g >= 1:
            sp["past"] = True
        prevpos[key] = fr
        prevpos.pop((sc, n - 10), None)
    close(sp)
    return c


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files):
            c.update(r)
    tm = 2 * c["matches"]
    print(f"{c['matches']} DFL matches; FACED (a defender goal-side within 1.5 m in his 45 deg cone), a team-match | past % | lost % | kept % | s faced | carrier m/s | defender m/s")
    zn = ["0-18", "18-35", "35-52", "52-70", "70+"]
    for z in list(range(5)) + [None]:
        g = (lambda k: c[(k, z)]) if z is not None else (lambda k: sum(c[(k, q)] for q in range(5)))
        f = max(1, g("faced"))
        print(f"  {zn[z] if z is not None else 'all':6s} {g('faced')/tm:5.1f} | {100*g('past')/f:4.1f} | {100*g('lost')/f:4.1f} | {100*g('kept')/f:4.1f} | {g('dur')/f:4.2f} | {g('cv')/f:4.2f} | {g('dv')/f:4.2f}")

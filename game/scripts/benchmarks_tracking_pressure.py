#!/usr/bin/env python3
"""benchmarks_tracking_pressure.py — the harness's own pressure and take-on cuts, measured on real
tracking (G5.28, game/DESIGN.md §8.126).

    python3 -I game/scripts/benchmarks_tracking_pressure.py <dfl dir>

fh-game-match counts a PRESSURE when a defender comes within 4.5 m of the man on the ball closing
at 1 m/s+ (once per defender per spell), and a TAKE-ON when a defender stands goal-side within
1.5 m in his 45° cone. Its brackets were StatsBomb's hand-tagged pressures and dribbles — not the
same thing. Here the same cuts on DFL tracking, 5 Hz, ball in play: the man on the ball = the
in-possession side's nearest outfielder to the ball within 2 m (as the harness's carry); a spell =
the frames he stays it (a gap of one frame allowed). Closing speed = the drop in the defender's
distance to him over 0.2 s.

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
    spell = None          # (carrier, last n, {defenders pressed}, faced)
    prev = {}             # defender -> distance to the carrier last frame
    for key in sorted(ball):
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
            if spell and n - spell[1] > 5: spell = None
            continue
        car = best[1]
        if not spell or spell[0] != car or n - spell[1] > 10 or sc != spell[4]:
            if spell and spell[3]: c["takeon"] += 1
            spell = [car, n, set(), False, sc]; prev = {}
            c["spells"] += 1
            tl = half - fr[car][0] * g
            c[("spells_z", 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4)] += 1
        spell[1] = n
        cx, cy = fr[car]
        tl = half - cx * g
        z = 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4
        c["frames"] += 1
        for pid, (x, y) in fr.items():
            if who.get(pid) == att or pid in keepers: continue
            dd = math.hypot(x - cx, y - cy)
            if pid in prev and dd < 4.5 and (prev[pid] - dd) / 0.2 >= 1.0 and pid not in spell[2]:
                spell[2].add(pid); c["press"] += 1; c[("press_z", z)] += 1
            prev[pid] = dd
            ahead = (x - cx) * g
            if not spell[3] and dd < 1.5 and ahead > 0 and abs(y - cy) <= ahead:
                spell[3] = True
    if spell and spell[3]: c["takeon"] += 1
    return c


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files):
            c.update(r)
    tm = 2 * c["matches"]
    print(f"{c['matches']} DFL matches, the harness's cuts (a team-match): spells on the ball {c['spells'] / tm:.1f}, "
          f"{c['frames'] / max(1, c['spells']) * 0.2:.2f} s each")
    print(f"  PRESSURES (within 4.5 m, closing 1 m/s+, once per defender a spell) {c['press'] / tm:.1f} = "
          f"{c['press'] / max(1, c['spells']):.2f} a spell; by the carrier's metres off their line 0-18/18-35/35-52/52-70/70+: "
          + " ".join(f"{c[('press_z', z)] / tm:.1f}" for z in range(5)))
    print(f"  TAKE-ONS (a defender goal-side within 1.5 m in his 45° cone, once a spell) {c['takeon'] / tm:.1f}")

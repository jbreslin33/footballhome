#!/usr/bin/env python3
"""benchmarks_tracking_channel.py — who holds the wide channel ahead of the ball (G5.223, game/DESIGN.md §8.329).

    python3 -I game/scripts/benchmarks_tracking_channel.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB). Loader as benchmarks_tracking_deepwide.py. 5 Hz. A frame = in play, the side in possession has the
ball 35-52 m off the goal line it attacks. Across the pitch signed to the ball's side (its touchline = +34). The
CHANNEL = 18-35 m off that goal line, across 20.16+ (the ball-side wide zone ahead); its SPOT = 26.5 m off the line,
across +27. By the ball in the middle (|y| < 20.16) / wide:
  - s a team-match;
  - outfielders in the channel: ours mean, none %; theirs mean, none %;
  - the spot: our nearest outfielder med m, their nearest med m; ours nearer %, ours nearer by 3 m+ %, theirs nearer
    by 3 m+ %;
  - their nearest man to the spot by role (share %), and his m off his own goal line med.
fh-game-match prints the same as THE CHANNEL AHEAD. FH original.
"""
import collections, glob, math, multiprocessing, os, re, statistics, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt   # noqa: E402
from benchmarks_tracking_runs import ROLE   # noqa: E402

def lane(ye): return 0 if ye >= 20.16 else 1 if ye >= 7 else 2 if ye > -7 else 3 if ye > -20.16 else 4

def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    info = open(info_p, encoding="utf8").read()
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
    c = collections.Counter(); L = collections.defaultdict(list)
    for k, b in ball.items():
        if b is None: continue
        t = b[2]; sg = own[(k[0], t)]
        tl = half + sg * b[0]   # ball's m off the line it attacks (their goal at -sg*half)
        if tl < 35 or tl >= 52: continue
        w = 1 if abs(b[1]) >= 20.16 else 0; ys = 1 if b[1] >= 0 else -1
        c[f"n{w}"] += 1; cnt = [0, 0]; nd = [99.0, 99.0]; nr = None; nrm = 0.0
        for pid, p in pl[k].items():
            if pid in keepers or pid not in who: continue
            ptl = half + sg * p[0]; ye = p[1] * ys; us = who[pid] == t
            if 18 <= ptl < 35 and ye >= 20.16: cnt[0 if us else 1] += 1
            d = math.hypot(ptl - 26.5, ye - 27)
            if d < nd[0 if us else 1]:
                nd[0 if us else 1] = d
                if not us: nr = ROLE.get(pos_of.get(pid)); nrm = ptl
        c[f"a{w}"] += cnt[0]; c[f"d{w}"] += cnt[1]; c[f"a0{w}"] += cnt[0] == 0; c[f"d0{w}"] += cnt[1] == 0
        L[f"na{w}"].append(nd[0]); L[f"nd{w}"].append(nd[1])
        c[f"on{w}"] += nd[0] < nd[1]; c[f"o3{w}"] += nd[0] + 3 <= nd[1]; c[f"t3{w}"] += nd[1] + 3 <= nd[0]
        if nr is not None: c[f"r{w}_{nr}"] += 1; L[f"rm{w}_{nr}"].append(nrm)
    return c, L

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, LL in pool.imap_unordered(one, files):
            c.update(cc)
            for k, v in LL.items(): L[k].extend(v)
    md = lambda v: statistics.median(v) if v else float("nan")
    print(f"THE CHANNEL AHEAD — DFL, {len(files)} matches: in possession, the ball 35-52 m off the line attacked; the channel = 18-35 m off it, across 20.16+ on the ball's side; the spot = 26.5 m, +27")
    for w, nm in ((0, "ball in the middle"), (1, "ball wide")):
        n = max(1, c[f"n{w}"])
        print(f"  {nm}: {c[f'n{w}'] / 5 / (2 * len(files)):.1f} s a team-match | in the channel: ours {c[f'a{w}'] / n:.2f}, none {100 * c[f'a0{w}'] / n:.1f}% ; theirs {c[f'd{w}'] / n:.2f}, none {100 * c[f'd0{w}'] / n:.1f}% "
              f"| the spot: our nearest med {md(L[f'na{w}']):.1f} m, their nearest med {md(L[f'nd{w}']):.1f} m; ours nearer {100 * c[f'on{w}'] / n:.1f}%, ours by 3 m+ {100 * c[f'o3{w}'] / n:.1f}%, theirs by 3 m+ {100 * c[f't3{w}'] / n:.1f}%")
        print("     their nearest man to the spot, by role: share % [m off the line attacked med] — " + "; ".join(f"{rn} {100 * c[f'r{w}_{r}'] / n:.0f} [{md(L[f'rm{w}_{r}']):.1f}]" for r, rn in enumerate(("CB", "FB", "DM/CM", "AM", "WIDE", "ST"))))
    print("C++ rows {s, ours in, ours none, theirs in, theirs none, our nearest, their nearest, ours nearer, ours 3+, theirs 3+}:")
    for w in (0, 1):
        n = max(1, c[f"n{w}"])
        print("  {" + ", ".join(f"{x:.2f}" for x in (c[f'n{w}'] / 5 / (2 * len(files)), c[f'a{w}'] / n, 100 * c[f'a0{w}'] / n, c[f'd{w}'] / n, 100 * c[f'd0{w}'] / n, md(L[f'na{w}']), md(L[f'nd{w}']), 100 * c[f'on{w}'] / n, 100 * c[f'o3{w}'] / n, 100 * c[f't3{w}'] / n)) + "},")

#!/usr/bin/env python3
"""benchmarks_tracking_bandtime.py — what the ball's time in each band is spent on (G5.224, game/DESIGN.md §8.330).

    python3 -I game/scripts/benchmarks_tracking_bandtime.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB). Loader as benchmarks_tracking_deepwide.py. 5 Hz, in play. Band = the ball's m off the line the side
in possession attacks (0-18 / 18-35 / 35-52 / 52-70 / 70+), as benchmarks_tracking_balltime.py. Each frame is ON A
MAN (a man of the side in possession within 2 m of the ball — the DFL cut of benchmarks_tracking_pressure.py) or
TRAVELLING. Per band, a team-match: s on a man, s travelling; on-a-man stints (the same man, contiguous frames):
count, mean s, share of 3 s+ ; the ball's speed m/s med on a man / travelling; and the man's own speed med on it.
NEXT STINT (G5.226, §8.332): from a stint ending in a band, the next stint — the same side's by band (and whether
the ball rose past 2 m between), the other side's, or play stopped first; the ball's metres on toward their goal.
fh-game-match prints the same as BAND TIME / NEXT STINT. FH original.
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
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1, float(a[9])) if live else None
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
    prev = None; stint = None   # stint = (pid, band0, frames)
    # G5.226 (§8.332) NEXT STINT: last = the stint just closed (team, band, the ball's m off the line attacked at its end); zmax since
    last = None; zmax = 0.0; gapn = 0
    def close(st):
        if st: c[f"k{st[1]}"] += 1; c[f"ks{st[1]}"] += st[2]; c[f"k3{st[1]}"] += st[2] >= 15
    for k in sorted(ball):
        b = ball[k]
        cont = prev is not None and b is not None and prev[0][0] == k[0] and k[1] - prev[0][1] == 5
        if b is None or not cont:
            if last is not None: c[f"x{last[1]}_dead"] += 1; c[f"x{last[1]}"] += 1; last = None
        if b is None: close(stint); stint = None; prev = None; continue
        t = b[2]; sg = own[(k[0], t)]
        tl = half + sg * b[0]
        z = 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4
        man = None; md_ = 2.0
        for pid, p in pl[k].items():
            if who.get(pid) != t: continue
            d = math.hypot(p[0] - b[0], p[1] - b[1])
            if d < md_: md_ = d; man = pid
        bs = math.hypot(b[0] - prev[1][0], b[1] - prev[1][1]) * 5 if cont else None
        if man is not None:
            c[f"on{z}"] += 1
            if bs is not None: L[f"bo{z}"].append(bs)
            if cont and man in pl[prev[0]]: q = pl[prev[0]][man]; L[f"ms{z}"].append(math.hypot(pl[k][man][0] - q[0], pl[k][man][1] - q[1]) * 5)
            if stint and cont and stint[0] == man: stint = (man, stint[1], stint[2] + 1)
            else:
                close(stint); stint = (man, z, 1)
                if last is not None:
                    fz = last[1]; c[f"x{fz}"] += 1
                    if last[0] != t: c[f"x{fz}_lost"] += 1
                    else:
                        c[f"x{fz}_{z}"] += 1; air = zmax >= 2.0; c[f"xa{fz}_{z}"] += air
                        L[f"xg{fz}_{z}"].append(gapn / 5); L[f"xd{fz}"].append(last[2] - tl)
            last = (t, z, tl); zmax = 0.0; gapn = 0
        else:
            zmax = max(zmax, b[3]); gapn += 1
        if man is None:
            c[f"tr{z}"] += 1; close(stint); stint = None
            if bs is not None: L[f"bt{z}"].append(bs)
        prev = (k, b)
    close(stint)
    return c, L

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, LL in pool.imap_unordered(one, files):
            c.update(cc)
            for k, v in LL.items(): L[k].extend(v)
    md = lambda v: statistics.median(v) if v else float("nan")
    tm = 2 * len(files)
    print(f"BAND TIME — DFL, {len(files)} matches, 5 Hz in play; band = the ball's m off the line the side in possession attacks")
    print("  band: s on a man | s travelling | on a man % || stints a team-match | mean s | 3 s+ % || ball m/s med on a man / travelling | the man's own m/s med")
    rows = []
    for z, nm in enumerate(("0-18", "18-35", "35-52", "52-70", "70+")):
        on, tr, k = c[f"on{z}"] / 5 / tm, c[f"tr{z}"] / 5 / tm, max(1, c[f"k{z}"])
        r = (on, tr, 100 * on / max(1e-9, on + tr), c[f"k{z}"] / tm, c[f"ks{z}"] / 5 / k, 100 * c[f"k3{z}"] / k, md(L[f"bo{z}"]), md(L[f"bt{z}"]), md(L[f"ms{z}"]))
        rows.append(r)
        print(f"  {nm:6s} {r[0]:6.1f} | {r[1]:6.1f} | {r[2]:4.1f} || {r[3]:6.1f} | {r[4]:.2f} | {r[5]:4.1f} || {r[6]:.1f} / {r[7]:.1f} | {r[8]:.1f}")
    print("  NEXT STINT (G5.226) — from a stint ending in a band, the next stint: the same side's in 0-18 / 18-35 / 35-52 / 52-70 / 70+ % [in the air %] | the other side's % | play stopped % || stints a team-match | the ball's m on toward their goal, same side med")
    xrows = []
    for z, nm in enumerate(("0-18", "18-35", "35-52", "52-70", "70+")):
        n = max(1, c[f"x{z}"])
        r = [c[f"x{z}"] / tm] + [100 * c[f"x{z}_{q}"] / n for q in range(5)] + [100 * c[f"xa{z}_{q}"] / max(1, c[f"x{z}_{q}"]) for q in range(5)] + [100 * c[f"x{z}_lost"] / n, 100 * c[f"x{z}_dead"] / n, md(L[f"xd{z}"])]
        xrows.append(r)
        print(f"  {nm:6s} " + "  ".join(f"{r[1 + q]:4.1f} [{r[6 + q]:2.0f}]" for q in range(5)) + f" | {r[11]:4.1f} | {r[12]:4.1f} || {r[0]:6.1f} | {r[13]:+.1f}")
    print("C++ next-stint rows:")
    for r in xrows: print("  {" + ", ".join(f"{x:.1f}" for x in r) + "},")
    print("C++ rows:")
    for r in rows: print("  {" + ", ".join(f"{x:.2f}" for x in r) + "},")

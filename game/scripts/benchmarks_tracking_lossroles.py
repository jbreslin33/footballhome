#!/usr/bin/env python3
"""benchmarks_tracking_lossroles.py — where each role of a side stands when it loses the ball after a build-up near its
own goal (G5.209, game/DESIGN.md §8.315).

    python3 -I game/scripts/benchmarks_tracking_lossroles.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB). Loader and roles as benchmarks_tracking_widepace.py / benchmarks_tracking_runs.py (DFL
PlayingPosition → CB / FB / DM-CM / AM / WIDE / ST). 5 Hz; a spell = in-play frames with one BallPossession side. A
BUILD-UP LOSS = a spell of 3 s+ followed at once by the other side's, with the ball at the change within 35 m of the
loser's goal line. At the winner's first frame, each outfielder of the loser by role: goal-side % (nearer his goal
centre than the ball), m off his goal line med, m off the centre line (|y|) med, m behind the ball med (+ = nearer his
line). Also the ball's m off the line and |y| med. fh-game-match prints the same as LOSS ROLES. FH original.
"""
import collections, glob, math, multiprocessing, os, re, statistics, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt   # noqa: E402
from benchmarks_tracking_runs import ROLE, NAMES   # noqa: E402


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
    keys = sorted(ball); n0 = None
    for i in range(1, len(keys)):
        k, kp = keys[i], keys[i - 1]
        b, bp = ball[k], ball[kp]
        if b is None or bp is None or k[0] != kp[0] or k[1] - kp[1] > 5:
            n0 = k if b is not None else None
            continue
        if n0 is None: n0 = kp
        if b[2] == bp[2]: continue
        held = (kp[1] - n0[1]) / 25.0; n0 = k
        lo = bp[2]; sg = own[(k[0], lo)]   # his goal line at x = sg * half
        gx = sg * half
        m = half - sg * b[0]   # ball's m off the loser's line
        if m >= 35 or held < 3: continue
        db = math.hypot(b[0] - gx, b[1])
        c["n"] += 1; L["bm"].append(m); L["by"].append(abs(b[1]))
        for pid, p in pl[k].items():
            if who.get(pid) != lo or pid in keepers or pos_of.get(pid) not in ROLE: continue
            r = ROLE[pos_of[pid]]
            c[f"r{r}"] += 1; c[f"g{r}"] += math.hypot(p[0] - gx, p[1]) < db
            pm = half - sg * p[0]
            L[f"m{r}"].append(pm); L[f"y{r}"].append(abs(p[1])); L[f"b{r}"].append(m - pm)
    return c, L


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(2) as pool:
        for cc, LL in pool.imap_unordered(one, files):
            c.update(cc)
            for k, v in LL.items(): L[k].extend(v)
    md = lambda v: statistics.median(v) if v else float("nan")
    print(f"LOSS ROLES — DFL, {len(files)} matches: build-up losses (held 3 s+) within 35 m of the loser's line, "
          f"{c['n'] / (2 * len(files)):.2f} a team-match; ball m off the line med {md(L['bm']):.1f}, |y| med {md(L['by']):.1f}")
    print("  role: goal-side % | m off his line med | |y| med | m behind the ball med")
    for r, nm in enumerate(NAMES):
        if c[f"r{r}"]:
            print(f"  {nm:6s} {100 * c[f'g{r}'] / c[f'r{r}']:5.1f} | {md(L[f'm{r}']):5.1f} | {md(L[f'y{r}']):5.1f} | {md(L[f'b{r}']):+5.1f}  (n {c[f'r{r}']})")

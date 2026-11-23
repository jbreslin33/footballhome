#!/usr/bin/env python3
"""benchmarks_tracking_deepwide.py — who is up the line when a side has the ball deep and wide (G5.215,
game/DESIGN.md §8.321).

    python3 -I game/scripts/benchmarks_tracking_deepwide.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB). Loader and roles as benchmarks_tracking_lossroles.py (DFL PlayingPosition → CB / FB / DM-CM / AM /
WIDE / ST). 5 Hz. A DEEP WIDE frame = in play, the side in possession has the ball within 35 m of its own goal line
and 20.16 m+ off the centre line. Across the pitch every man is signed to the ball's side (the ball's touchline =
+34): lanes his wing (20.16+) / his channel (7-20.16) / centre (-7..7) / far channel / far wing. Per frame:
  - the side's striker nearest the ball's touchline, and its WIDE man nearest it: lane share %, across med, m off his
    own goal line med, m on from the ball med; and his spot when he is in the wing lane;
  - TARGETS UP THE LINE: the side's outfielders 25 m+ on from the ball on the ball's side (across 7+): mean, % of
    frames with none; and the same for the other side's outfielders there.
fh-game-match prints the same as DEEP WIDE BALL. FH original.
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
        bm = half - sg * b[0]
        if bm >= 35 or abs(b[1]) < 20.16: continue
        ys = 1 if b[1] >= 0 else -1
        c["n"] += 1; best = {}; tg = [0, 0]
        for pid, p in pl[k].items():
            if pid in keepers or pid not in who: continue
            ye = p[1] * ys; pm = half - sg * p[0]; on = pm - bm
            if on >= 25 and ye >= 7: tg[0 if who[pid] == t else 1] += 1
            if who[pid] != t: continue
            r = ROLE.get(pos_of.get(pid))
            if r in (4, 5) and (r not in best or ye > best[r][0]): best[r] = (ye, pm, on)
        c["t0"] += tg[0]; c["t1"] += tg[1]; c["none"] += tg[0] == 0
        for r, (ye, pm, on) in best.items():
            c[f"r{r}"] += 1; c[f"l{r}_{lane(ye)}"] += 1
            L[f"y{r}"].append(ye); L[f"m{r}"].append(pm); L[f"o{r}"].append(on)
            if lane(ye) == 0: L[f"wy{r}"].append(ye); L[f"wt{r}"].append(length - pm); L[f"wb{r}"].append(bm)
    return c, L

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, LL in pool.imap_unordered(one, files):
            c.update(cc)
            for k, v in LL.items(): L[k].extend(v)
    md = lambda v: statistics.median(v) if v else float("nan")
    n = max(1, c["n"])
    print(f"DEEP WIDE BALL — DFL, {len(files)} matches: in possession, ball within 35 m of our line and 20.16 m+ off the centre line: {c['n'] / 5 / (2 * len(files)):.1f} s a team-match")
    print(f"  TARGETS UP THE LINE (25 m+ on from the ball, on its side of the pitch, across 7+): ours mean {c['t0'] / n:.2f}, none {100 * c['none'] / n:.1f}% | theirs mean {c['t1'] / n:.2f}")
    for r, nm in ((5, "ST"), (4, "WIDE")):
        k = max(1, c[f"r{r}"])
        print(f"  the {nm} nearest the ball's touchline: his wing {100 * c[f'l{r}_0'] / k:.1f} | his channel {100 * c[f'l{r}_1'] / k:.1f} | centre {100 * c[f'l{r}_2'] / k:.1f} | far channel {100 * c[f'l{r}_3'] / k:.1f} | far wing {100 * c[f'l{r}_4'] / k:.1f} "
              f"| across med {md(L[f'y{r}']):+.1f} | m off his line med {md(L[f'm{r}']):.1f} | m on from the ball med {md(L[f'o{r}']):.1f}  (frames with one {100 * c[f'r{r}'] / n:.0f}%)")
        print(f"      … when in his wing: across med {md(L[f'wy{r}']):.1f}, m off THEIR line med {md(L[f'wt{r}']):.1f} (ball {md(L[f'wb{r}']):.1f} m off ours)")

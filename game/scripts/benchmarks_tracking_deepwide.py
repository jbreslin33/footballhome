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
  - THE OTHER SIDE'S BLOCK (G5.217, §8.323): its outfielders by metres on from the ball toward their own goal
    (under 10 / 10-25 / 25-40 / 40+), its nearest man to the ball, and its last outfielder (m off its own goal line,
    m on from the ball).
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
        if bm >= 35: continue
        if abs(b[1]) < 20.16:   # G5.218 (§8.324): the same deep ball in the middle — the other side's nearest man, last man, men round it
            c["cn"] += 1; near = 99.0; deep = 0.0
            for pid, p in pl[k].items():
                if pid in keepers or who.get(pid) != 1 - t: continue
                pm = half - sg * p[0]
                near = min(near, math.hypot(p[0] - b[0], p[1] - b[1])); deep = max(deep, pm); c["cdn0"] += pm - bm < 10
            L["cnear"].append(near); L["cdeep"].append(length - deep)
            continue
        ys = 1 if b[1] >= 0 else -1
        c["n"] += 1; best = {}; tg = [0, 0]
        dn = [0, 0, 0, 0]; near = 99.0; deep = 0.0   # the other side: within 10 / 10-25 / 25-40 / 40+ m on from the ball; nearest to it; its last man
        for pid, p in pl[k].items():
            if pid in keepers or pid not in who: continue
            ye = p[1] * ys; pm = half - sg * p[0]; on = pm - bm
            if on >= 25 and ye >= 7: tg[0 if who[pid] == t else 1] += 1
            if who[pid] != t:
                dn[0 if on < 10 else 1 if on < 25 else 2 if on < 40 else 3] += 1
                rr = ROLE.get(pos_of.get(pid))
                if rr is not None:
                    c[f"dr{rr}"] += 1; c[f"dr{rr}_n"] += on < 10; L[f"drd{rr}"].append(math.hypot(p[0] - b[0], p[1] - b[1])); L[f"dro{rr}"].append(on); L[f"dry{rr}"].append(ye)
                near = min(near, math.hypot(p[0] - b[0], p[1] - b[1])); deep = max(deep, pm)
                continue
            r = ROLE.get(pos_of.get(pid))
            if r in (4, 5) and (r not in best or ye > best[r][0]): best[r] = (ye, pm, on)
        c["t0"] += tg[0]; c["t1"] += tg[1]; c["none"] += tg[0] == 0
        for q in range(4): c[f"dn{q}"] += dn[q]
        L["near"].append(near); L["deep"].append(length - deep); L["gap"].append(deep - bm)
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
    print(f"  THE OTHER SIDE'S BLOCK: outfielders by m on from the ball (toward their own goal) <10 / 10-25 / 25-40 / 40+: {c['dn0'] / n:.2f} / {c['dn1'] / n:.2f} / {c['dn2'] / n:.2f} / {c['dn3'] / n:.2f} "
          f"| its nearest man to the ball med {md(L['near']):.1f} m | its last man: m off its own goal line med {md(L['deep']):.1f}, m on from the ball med {md(L['gap']):.1f}")
    print("  THE OTHER SIDE BY ROLE (deep wide ball): men a frame | of them under 10 m on from the ball % | m from the ball med | m on from the ball med | across (ball's side +) med")
    for r, nm in enumerate(("CB", "FB", "DM/CM", "AM", "WIDE", "ST")):
        k = max(1, c[f"dr{r}"])
        print(f"    {nm:6s} {c[f'dr{r}'] / n:.2f} | {100 * c[f'dr{r}_n'] / k:5.1f} | {md(L[f'drd{r}']):5.1f} | {md(L[f'dro{r}']):5.1f} | {md(L[f'dry{r}']):+5.1f}")
    q = lambda v, f: sorted(v)[int(f * len(v))] if v else float("nan")
    print(f"  DEEP BALL, CENTRE v WIDE — the other side's nearest man to the ball p25/med/p75: centre {q(L['cnear'], .25):.1f}/{q(L['cnear'], .5):.1f}/{q(L['cnear'], .75):.1f} | wide {q(L['near'], .25):.1f}/{q(L['near'], .5):.1f}/{q(L['near'], .75):.1f} "
          f"|| its men under 10 m on from the ball: centre {c['cdn0'] / max(1, c['cn']):.2f} | wide {c['dn0'] / n:.2f} || its last man m off its own line med: centre {md(L['cdeep']):.1f} | wide {md(L['deep']):.1f} || s a team-match centre {c['cn'] / 5 / (2 * len(files)):.1f}")
    for r, nm in ((5, "ST"), (4, "WIDE")):
        k = max(1, c[f"r{r}"])
        print(f"  the {nm} nearest the ball's touchline: his wing {100 * c[f'l{r}_0'] / k:.1f} | his channel {100 * c[f'l{r}_1'] / k:.1f} | centre {100 * c[f'l{r}_2'] / k:.1f} | far channel {100 * c[f'l{r}_3'] / k:.1f} | far wing {100 * c[f'l{r}_4'] / k:.1f} "
              f"| across med {md(L[f'y{r}']):+.1f} | m off his line med {md(L[f'm{r}']):.1f} | m on from the ball med {md(L[f'o{r}']):.1f}  (frames with one {100 * c[f'r{r}'] / n:.0f}%)")
        print(f"      … when in his wing: across med {md(L[f'wy{r}']):.1f}, m off THEIR line med {md(L[f'wt{r}']):.1f} (ball {md(L[f'wb{r}']):.1f} m off ours)")

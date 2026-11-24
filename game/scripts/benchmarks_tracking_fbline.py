#!/usr/bin/env python3
"""benchmarks_tracking_fbline.py — the full-back on the ball by his touchline in his own third: who is ahead of him
down the line (G5.238, game/DESIGN.md §8.344).

    python3 -I game/scripts/benchmarks_tracking_fbline.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB). Loader and roles as benchmarks_tracking_lossroles.py. 5 Hz, in play. A STINT = contiguous frames
with the same man of the side in possession nearest the ball and within 2 m of it (benchmarks_tracking_bandtime.py).
At the first frame of each stint of a FULL-BACK with the ball within 35 m of his own goal line and within 14 m of a
touchline (|y| >= 20):
  a team-match; his nearest opponent, m med;
  mates DOWN THE LINE — outfield, 3 m+ nearer the goal attacked than the ball, |y| >= 20 on the ball's side: none /
  one / two+ %; the nearest one: m ahead of the ball med [p25-p75], his role %, his nearest opponent m med, and the
  share with that opponent inside 3 m;
  mates AHEAD INSIDE — 3 m+ ahead, within 30 m of the ball, not down the line: mean count, the nearest m med.
fh-game-match prints the same as FB ON THE LINE. FH original.
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
    keys = sorted(ball); prev_man = None; prev_k = None
    for k in keys:
        b = ball[k]
        if b is None: prev_man = None; prev_k = None; continue
        cont = prev_k is not None and prev_k[0] == k[0] and k[1] - prev_k[1] == 5
        t = b[2]; ps = pl[k]
        man = None; md = 2.0
        for pid, p in ps.items():
            if who.get(pid) != t: continue
            dd = math.hypot(p[0] - b[0], p[1] - b[1])
            if dd < md: md = dd; man = pid
        new = man is not None and not (cont and prev_man == man)
        prev_man = man; prev_k = k
        if not new or man in keepers or pos_of.get(man) not in ROLE or ROLE[pos_of[man]] != 1: continue
        sg = own[(k[0], t)]   # his goal line at x = sg * half; he attacks -sg
        if half - sg * b[0] >= 35 or abs(b[1]) < 20: continue
        side = 1 if b[1] > 0 else -1
        c["n"] += 1
        L["opp"].append(min((math.hypot(p[0] - b[0], p[1] - b[1]) for pid, p in ps.items() if who.get(pid) == 1 - t and pid not in keepers), default=99))
        # G5.239 (§8.345) THE PRESS ON HIM: his nearest outfield opponent at the stint's first frame — who (role), how far;
        # 1 s on, if the full-back still has it (within 2 m of a live ball of his side): that opponent's m off him and the
        # m he closed; and the stint's length.
        od0, oid = min(((math.hypot(p[0] - b[0], p[1] - b[1]), pid) for pid, p in ps.items() if who.get(pid) == 1 - t and pid not in keepers), default=(99, None))
        if oid is not None:
            c[f"pr{ROLE.get(pos_of.get(oid), 2)}"] += 1; c["prn"] += 1
            c[f"pd{0 if od0 < 3 else 1 if od0 < 5 else 2 if od0 < 8 else 3 if od0 < 12 else 4}"] += 1
            k1 = (k[0], k[1] + 25); b1 = ball.get(k1); me1 = pl.get(k1, {}).get(man); o1 = pl.get(k1, {}).get(oid)
            c["at1"] += 1
            if b1 is not None and b1[2] == t and me1 and o1 and math.hypot(me1[0] - b1[0], me1[1] - b1[1]) <= 2:
                c["still1"] += 1; d1 = math.hypot(o1[0] - me1[0], o1[1] - me1[1]); me0 = ps[man]; d0m = math.hypot(ps[oid][0] - me0[0], ps[oid][1] - me0[1])
                L["d1"].append(d1); L["cl"].append(d0m - d1); c["in3_1"] += d1 < 3
        n_st = 1; kk = k
        while True:
            kk = (kk[0], kk[1] + 5); bb = ball.get(kk); mm = pl.get(kk, {}).get(man)
            if bb is None or bb[2] != t or not mm or math.hypot(mm[0] - bb[0], mm[1] - bb[1]) > 2: break
            n_st += 1
        L["len"].append(n_st / 5)
        line = []; inside = []
        for pid, p in ps.items():
            if who.get(pid) != t or pid == man or pid in keepers: continue
            ah = (b[0] - p[0]) * sg   # m nearer the goal attacked than the ball
            if ah < 3: continue
            if p[1] * side >= 20: line.append((ah, pid, p))
            elif math.hypot(p[0] - b[0], p[1] - b[1]) <= 30: inside.append(math.hypot(p[0] - b[0], p[1] - b[1]))
        c[f"line{min(2, len(line))}"] += 1
        c["inside"] += len(inside)
        if inside: L["ins"].append(min(inside))
        if line:
            ah, pid, p = min(line)
            L["ah"].append(ah); c[f"lr{ROLE.get(pos_of.get(pid), 2)}"] += 1
            od = min((math.hypot(q[0] - p[0], q[1] - p[1]) for qid, q in ps.items() if who.get(qid) == 1 - t and qid not in keepers), default=99)
            L["lo"].append(od); c["lo3"] += od < 3
    return c, L


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(2) as pool:
        for cc, LL in pool.imap_unordered(one, files):
            c.update(cc)
            for k, v in LL.items(): L[k].extend(v)
    md = lambda v: statistics.median(v) if v else float("nan")
    q = lambda v, f: sorted(v)[int(f * len(v))] if v else float("nan")
    n = max(1, c["n"]); nl = max(1, c["line1"] + c["line2"])
    print(f"FB ON THE LINE — DFL, {len(files)} matches: a full-back's stints begun within 35 m of his own line and 14 m of a touchline, {c['n'] / (2 * len(files)):.1f} a team-match; his nearest opponent med {md(L['opp']):.1f} m")
    print(f"  mates down the line none / one / two+: {100 * c['line0'] / n:.0f} / {100 * c['line1'] / n:.0f} / {100 * c['line2'] / n:.0f}% | the nearest: {md(L['ah']):.1f} m ahead [{q(L['ah'], .25):.1f}-{q(L['ah'], .75):.1f}], "
          + " ".join(f"{nm} {100 * c[f'lr{r}'] / nl:.0f}%" for r, nm in enumerate(NAMES)) + f" | his nearest opponent med {md(L['lo']):.1f} m, inside 3 m {100 * c['lo3'] / nl:.0f}%")
    print(f"  mates ahead inside (3 m+ ahead, within 30 m, not on the line): {c['inside'] / n:.2f} | the nearest {md(L['ins']):.1f} m")
    pn = max(1, c["prn"]); s1 = max(1, c["still1"])
    print(f"  THE PRESS ON HIM (G5.239): his nearest opponent at the first frame 0-3 / 3-5 / 5-8 / 8-12 / 12+ m: " + " / ".join(f"{100 * c[f'pd{i}'] / pn:.0f}" for i in range(5)) + "% | who: " + " ".join(f"{nm} {100 * c[f'pr{r}'] / pn:.0f}%" for r, nm in enumerate(NAMES))
          + f" | still his 1 s on {100 * c['still1'] / max(1, c['at1']):.0f}%: that man then {md(L['d1']):.1f} m off, closed {md(L['cl']):.1f} m [{q(L['cl'], .25):.1f}-{q(L['cl'], .75):.1f}], inside 3 m {100 * c['in3_1'] / s1:.0f}% | stint s med {md(L['len']):.1f}, p75 {q(L['len'], .75):.1f}")
    print("C++ press row: {" + ", ".join(f"{x:.1f}" for x in [100 * c[f'pd{i}'] / pn for i in range(5)] + [100 * c[f'pr{r}'] / pn for r in range(6)] + [100 * c['still1'] / max(1, c['at1']), md(L['d1']), md(L['cl']), q(L['cl'], .25), q(L['cl'], .75), 100 * c['in3_1'] / s1, md(L['len']), q(L['len'], .75)]) + "}")
    print("C++ row: {" + ", ".join(f"{x:.1f}" for x in [c['n'] / (2 * len(files)), md(L['opp']), 100 * c['line0'] / n, 100 * c['line1'] / n, 100 * c['line2'] / n, md(L['ah']), q(L['ah'], .25), q(L['ah'], .75)] + [100 * c[f'lr{r}'] / nl for r in range(6)] + [md(L['lo']), 100 * c['lo3'] / nl, c['inside'] / n, md(L['ins'])]) + "}")

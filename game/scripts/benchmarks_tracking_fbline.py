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
G5.240 (§8.346) THE PRESSER'S START — the stints above that a MATE'S PASS began (the frame before the ball left for him
was a different mate's, the ball travelling 1+ frames between, all in play): the pass's flight s and length m; the
PRESSER = his nearest outfield opponent at his first frame; at the kick (the passer's last frame): the presser's m off
the full-back, the share of pressers within 5 m of the passer, his speed (m/s over the next 0.2 s); in the flight: his
pace (path / flight), the m he closed on the full-back and that per second; his speed in the last 0.2 s before the touch;
how straight he ran (m closed / m run, runs of 1 m+); and the angle at the full-back between the presser and the
presser's own goal, at the kick and at the touch (0 = square on the full-back's line to that goal).
G5.241 (§8.347) STINTS ENDING IN THEIR WIDE LAST THIRD — every stint of an outfield man whose last frame has the ball
within 35 m of the line he attacks and 14 m of a touchline: a team-match, and what came next: a mate after the ball
travelled (a pass) | a mate straight off his feet | his own again | theirs straight off his feet (tackled; the winner's
role) | theirs within 1 s | theirs later | play stopped.
G5.242 (§8.348) THE ENGAGE CUE — every 5 Hz frame an outfield man is on the ball with the next frame in play: was the
ball on a man of the other side that next frame (taken off his feet)? As a rate per second on the ball, by his metres
to the nearest touchline (0-5 / 5-14 / 14+; pitch 68 m wide), his nearest outfield opponent's metres (0-1.5 / 1.5-3 /
3-5 / 5+) and whether a second opponent is within 5 m. [concept: engage-or-contain, game_concepts 157]
G5.243 (§8.349) OFF HIS FEET, 2 S ON — each such taking (wide = within 14 m of a touchline / middle): 2 s later the
ball is in play with the taker's side (kept) | with the side that had it (back) | play has stopped; and the taker's own
stint on it, s med.
G5.246 (§8.352) A MATE THERE — at the first frame of every stint of an outfield man, by the ball's band off the line
attacked (0-18 / 18-35 / 35-52 / 52-70 / 70+): the share with at least one outfield mate in each zone — the same
bands, centre / wide (|y| >= 20.16) — and the mean number of mates within 18 m and within 35 m of the line attacked.
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
    keys = sorted(ball); prev_man = None; prev_k = None; la = None; gap = 0; ecf = None   # ecf: the last frame's engage-cue cell, if a man was on it
    def wide3(l):   # the stint whose last frame is l = (k, man, t): the ball in that side's wide last third, an outfield man's
        bl = ball[l[0]]
        return l[1] not in keepers and half + own[(l[0][0], l[2])] * bl[0] < 35 and abs(bl[1]) >= 20
    def zone(l):   # the band (0 = within 18 m of the line attacked … 4 = 70 m+) and wide (|y| >= 20) of the stint's last frame, outfield
        bl = ball[l[0]]; tl = half + own[(l[0][0], l[2])] * bl[0]
        return None if l[1] in keepers else (0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4, int(abs(bl[1]) >= 20))
    for k in keys:
        b = ball[k]
        cont = b is not None and prev_k is not None and prev_k[0] == k[0] and k[1] - prev_k[1] == 5
        if not cont and la is not None and wide3(la): c["w3"] += 1; c["w3e6"] += 1   # play stopped
        if not cont and la is not None and zone(la): c[("zn",) + zone(la)] += 1
        if b is None: prev_man = None; prev_k = None; la = None; gap = 0; ecf = None; continue
        if not cont: la = None; gap = 0; ecf = None
        t = b[2]; ps = pl[k]
        man = None; md = 2.0
        for pid, p in ps.items():
            if who.get(pid) != t: continue
            dd = math.hypot(p[0] - b[0], p[1] - b[1])
            if dd < md: md = dd; man = pid
        new = man is not None and not (cont and prev_man == man)
        prev_man = man; prev_k = k
        la0, gap0 = la, gap
        if new and man not in keepers:   # G5.246 A MATE THERE
            sg2 = own[(k[0], t)]; tlb = half + sg2 * b[0]; bb5 = 0 if tlb < 18 else 1 if tlb < 35 else 2 if tlb < 52 else 3 if tlb < 70 else 4
            seen = set(); n18 = n35 = 0
            for pid, p in ps.items():
                if who.get(pid) != t or pid == man or pid in keepers: continue
                tl2 = half + sg2 * p[0]; n18 += tl2 < 18; n35 += tl2 < 35
                seen.add(((0 if tl2 < 18 else 1 if tl2 < 35 else 2 if tl2 < 52 else 3 if tl2 < 70 else 4), int(abs(p[1]) >= 20.16)))
            c[("mtn", bb5)] += 1; c[("mt18", bb5)] += n18; c[("mt35", bb5)] += n35
            for zz in seen: c[("mt", bb5) + zz] += 1
        if ecf is not None:
            c[("ec_n",) + ecf[1]] += 1; c[("ec_o",) + ecf[1]] += man is not None and t != ecf[0]
            if man is not None and t != ecf[0]:
                w2 = int(abs(b[1]) >= 20); b2 = ball.get((k[0], k[1] + 50))
                c[("of2", w2, 2 if b2 is None else 0 if b2[2] == t else 1)] += 1
                ns = 1; kk2 = k
                while True:
                    kk2 = (kk2[0], kk2[1] + 5); bb = ball.get(kk2); mm = pl.get(kk2, {}).get(man)
                    if bb is None or bb[2] != t or not mm or math.hypot(mm[0] - bb[0], mm[1] - bb[1]) > 2: break
                    ns += 1
                L[f"of2s{w2}"].append(ns / 5); c[("of2short", w2)] += ns <= 2
        ecf = None
        if man is not None and man not in keepers:
            ds = sorted(math.hypot(p[0] - b[0], p[1] - b[1]) for pid, p in ps.items() if who.get(pid) == 1 - t and pid not in keepers)
            if ds:
                tch = 34 - abs(b[1])
                ecf = (t, (0 if tch < 5 else 1 if tch < 14 else 2, 0 if ds[0] < 1.5 else 1 if ds[0] < 3 else 2 if ds[0] < 5 else 3, int(len(ds) > 1 and ds[1] < 5)))
        if new and la0 is not None and zone(la0):
            c[("zn",) + zone(la0)] += 1; c[("zo",) + zone(la0)] += la0[2] != t and gap0 == 0
        if new and la0 is not None and wide3(la0):
            e = (4 if gap0 == 0 else 5 if gap0 <= 5 else 3) if la0[2] != t else 2 if la0[1] == man else 0 if gap0 >= 1 else 1
            c["w3"] += 1; c[f"w3e{e}"] += 1
            if e == 4: c[f"w3r{ROLE.get(pos_of.get(man), 2) if man not in keepers else 6}"] += 1
        if man is not None: la = (k, man, t); gap = 0
        else: gap += 1
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
            # how the stint began: 0 a mate's pass (below) | 1 off a mate's feet (no travelling frame between) | 2 the ball was theirs
            # the frame before or last on a man of theirs | 3 play just (re)started or the ball came off nobody's
            hb = 3 if la0 is None else 2 if la0[2] != t else 0 if (la0[1] != man and gap0 >= 1) else 1 if la0[1] != man else 4   # 4 his own again after a touch away
            c[f"hb{hb}"] += 1; c[f"hb{hb}_3"] += od0 < 3; L[f"hb{hb}_d"].append(od0)
            if hb == 2:   # won from them: straight off their man's feet (no travelling frame) | within 1 s of their touch | later (their pass / long ball picked off)
                w = 0 if gap0 == 0 else 1 if gap0 <= 5 else 2
                c[f"wn{w}"] += 1; c[f"wn{w}_3"] += od0 < 3; c[f"wn{w}_same"] += oid == la0[1]
            if la0 is not None and la0[2] == t and la0[1] != man and gap0 >= 1:   # G5.240 (§8.346) THE PRESSER'S START
                kq = la0[0]; fr = [pl.get((k[0], n2), {}) for n2 in range(kq[1], k[1] + 1, 5)]; bq = ball.get(kq)
                if bq is not None and all(oid in f2 for f2 in fr) and man in fr[0] and la0[1] in fr[0]:
                    fl = (gap0 + 1) / 5; o = [f2[oid] for f2 in fr]; me0 = fr[0][man]; pa = fr[0][la0[1]]
                    dk = math.hypot(o[0][0] - me0[0], o[0][1] - me0[1]); d0 = math.hypot(o[-1][0] - ps[man][0], o[-1][1] - ps[man][1])
                    path = sum(math.hypot(o[i + 1][0] - o[i][0], o[i + 1][1] - o[i][1]) for i in range(len(o) - 1))
                    c["ps"] += 1; L["ps_fl"].append(fl); L["ps_len"].append(math.hypot(b[0] - bq[0], b[1] - bq[1]))
                    L["ps_dk"].append(dk); c[f"ps_b{0 if dk < 5 else 1 if dk < 10 else 2 if dk < 15 else 3}"] += 1
                    c["ps_onp"] += math.hypot(o[0][0] - pa[0], o[0][1] - pa[1]) < 5
                    L["ps_vk"].append(5 * math.hypot(o[1][0] - o[0][0], o[1][1] - o[0][1])); L["ps_vr"].append(5 * math.hypot(o[-1][0] - o[-2][0], o[-1][1] - o[-2][1]))
                    L["ps_pace"].append(path / fl); L["ps_cl"].append(dk - d0); L["ps_cls"].append((dk - d0) / fl); L["ps_d0"].append(d0)
                    if path >= 1: L["ps_str"].append((dk - d0) / path)
                    def offl(op, mp):   # degrees between the full-back -> presser and the full-back -> the presser's own goal (0 = square on his line to goal)
                        gx, gy = -sg * half - mp[0], -mp[1]; ox, oy = op[0] - mp[0], op[1] - mp[1]
                        return math.degrees(math.acos(max(-1, min(1, (gx * ox + gy * oy) / max(1e-9, math.hypot(gx, gy) * math.hypot(ox, oy))))))
                    L["ps_ak"].append(offl(o[0], me0)); L["ps_a0"].append(offl(o[-1], ps[man]))
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
    pm = max(1, c["ps"])
    print(f"  THE PRESSER'S START (G5.240): stints a mate's pass began {c['ps'] / (2 * len(files)):.1f} a team-match; the pass {md(L['ps_len']):.1f} m, {md(L['ps_fl']):.1f} s in flight | the presser at the kick: {md(L['ps_dk']):.1f} m off the full-back [{q(L['ps_dk'], .25):.1f}-{q(L['ps_dk'], .75):.1f}], 0-5 / 5-10 / 10-15 / 15+ m "
          + " / ".join(f"{100 * c[f'ps_b{i}'] / pm:.0f}" for i in range(4)) + f"%, within 5 m of the passer {100 * c['ps_onp'] / pm:.0f}%, moving {md(L['ps_vk']):.1f} m/s [{q(L['ps_vk'], .25):.1f}-{q(L['ps_vk'], .75):.1f}]"
          + f" | in the flight: pace {md(L['ps_pace']):.1f} m/s [{q(L['ps_pace'], .25):.1f}-{q(L['ps_pace'], .75):.1f}], closed {md(L['ps_cl']):.1f} m [{q(L['ps_cl'], .25):.1f}-{q(L['ps_cl'], .75):.1f}] = {md(L['ps_cls']):.1f} m/s | at the touch {md(L['ps_d0']):.1f} m off, moving {md(L['ps_vr']):.1f} m/s [{q(L['ps_vr'], .25):.1f}-{q(L['ps_vr'], .75):.1f}]"
          + f" | closed / run {md(L['ps_str']):.2f} [{q(L['ps_str'], .25):.2f}-{q(L['ps_str'], .75):.2f}] | off the full-back's line to the presser's goal, deg: at the kick {md(L['ps_ak']):.0f} [{q(L['ps_ak'], .25):.0f}-{q(L['ps_ak'], .75):.0f}], at the touch {md(L['ps_a0']):.0f} [{q(L['ps_a0'], .25):.0f}-{q(L['ps_a0'], .75):.0f}]")
    hn = ["a mate's pass", "off a mate's feet", "theirs before", "play restarted", "his own again"]
    print("  HOW HIS STINT BEGAN (a team-match, his nearest opponent inside 3 m %, med m): " + " | ".join(f"{hn[i]} {c[f'hb{i}'] / (2 * len(files)):.1f}, {100 * c[f'hb{i}_3'] / max(1, c[f'hb{i}']):.0f}%, {md(L[f'hb{i}_d']):.1f} m" for i in range(5)))
    wn = ["off their man's feet", "within 1 s of their touch", "later"]
    print("  WON FROM THEM (a team-match, nearest opponent inside 3 m %, that opponent the man who had it %): " + " | ".join(f"{wn[i]} {c[f'wn{i}'] / (2 * len(files)):.1f}, {100 * c[f'wn{i}_3'] / max(1, c[f'wn{i}']):.0f}%, {100 * c[f'wn{i}_same'] / max(1, c[f'wn{i}']):.0f}%" for i in range(3)))
    print("C++ won row: {" + ", ".join(f"{x:.1f}" for i in range(3) for x in (c[f'wn{i}'] / (2 * len(files)), 100 * c[f'wn{i}_3'] / max(1, c[f'wn{i}']), 100 * c[f'wn{i}_same'] / max(1, c[f'wn{i}']))) + "}")
    en = ["a pass to a mate", "a mate off his feet", "his own again", "theirs later", "theirs off his feet", "theirs within 1 s", "play stopped"]; tm2 = 2 * len(files)
    print(f"  STINTS ENDING IN THEIR WIDE LAST THIRD (G5.241): {c['w3'] / tm2:.1f} a team-match | next: " + " | ".join(f"{en[i]} {c[f'w3e{i}'] / tm2:.1f}" for i in range(7))
          + " | off his feet by: " + " ".join(f"{nm} {100 * c[f'w3r{r}'] / max(1, c['w3e4']):.0f}%" for r, nm in enumerate(NAMES)))
    print("  OFF HIS FEET BY WHERE (stints ending there a team-match, of them theirs straight off his feet) — m off the line attacked 0-18 / 18-35 / 35-52 / 52-70 / 70+: "
          + " | ".join(f"{nm} " + " / ".join(f"{c[('zn', z, w)] / tm2:.1f}, {c[('zo', z, w)] / tm2:.1f}" for z in range(5)) for w, nm in ((1, "wide"), (0, "middle"))))
    print("C++ zone row: {" + ", ".join(f"{c[(kk, z, w)] / tm2:.1f}" for w in (1, 0) for z in range(5) for kk in ("zn", "zo")) + "}")
    tn = ["0-5 m off the touchline", "5-14 m", "14 m+"]
    print("  THE ENGAGE CUE (G5.242): taken off his feet per second on the ball (s on it a team-match) — nearest opponent 0-1.5 / 1.5-3 / 3-5 / 5+ m; alone | a second within 5 m")
    for tb in range(3):
        print(f"    {tn[tb]}: " + " | ".join(" / ".join(f"{5 * c[('ec_o', tb, d, s2)] / max(1, c[('ec_n', tb, d, s2)]):.2f} ({c[('ec_n', tb, d, s2)] / 5 / tm2:.0f})" for d in range(4)) for s2 in (0, 1)))
    print("C++ cue row: {" + ", ".join(f"{5 * c[('ec_o', tb, d, s2)] / max(1, c[('ec_n', tb, d, s2)]):.3f}, {c[('ec_n', tb, d, s2)] / 5 / tm2:.1f}" for tb in range(3) for s2 in (0, 1) for d in range(4)) + "}")
    print("  OFF HIS FEET, 2 S ON (G5.243) a team-match — kept / back with the side that had it / play stopped; the taker's stint s med, 0.4 s or less %: "
          + " | ".join(f"{nm} " + " / ".join(f"{c[('of2', w, i)] / tm2:.1f}" for i in range(3)) + f"; {md(L[f'of2s{w}']):.1f} s, {100 * c[('of2short', w)] / max(1, len(L[f'of2s{w}'])):.0f}%" for w, nm in ((1, "wide"), (0, "middle"))))
    print("C++ of2 row: {" + ", ".join(f"{x:.1f}" for w in (1, 0) for x in [c[('of2', w, i)] / tm2 for i in range(3)] + [md(L[f'of2s{w}']), 100 * c[('of2short', w)] / max(1, len(L[f'of2s{w}']))]) + "}")
    print("  A MATE THERE (G5.246) — by the ball's band, % of stints' first frames with a mate in 0-18 c / 0-18 w / 18-35 c / 18-35 w / 35-52 c / 35-52 w | mates within 18 m, within 35 m of the line attacked (mean):")
    bn5 = ["0-18", "18-35", "35-52", "52-70", "70+"]
    for bb5 in range(5):
        nn = max(1, c[("mtn", bb5)])
        print(f"    ball {bn5[bb5]}: " + " / ".join(f"{100 * c[('mt', bb5, z, w)] / nn:.0f}" for z in range(3) for w in (0, 1)) + f" | {c[('mt18', bb5)] / nn:.2f}, {c[('mt35', bb5)] / nn:.2f}")
    print("C++ mate row: {" + ", ".join(", ".join(f"{100 * c[('mt', bb5, z, w)] / max(1, c[('mtn', bb5)]):.1f}" for z in range(3) for w in (0, 1)) + f", {c[('mt18', bb5)] / max(1, c[('mtn', bb5)]):.2f}, {c[('mt35', bb5)] / max(1, c[('mtn', bb5)]):.2f}" for bb5 in range(5)) + "}")
    print("C++ wide3 row: {" + ", ".join(f"{x:.1f}" for x in [c['w3'] / tm2] + [c[f'w3e{i}'] / tm2 for i in range(7)] + [100 * c[f'w3r{r}'] / max(1, c['w3e4']) for r in range(6)]) + "}")
    print("C++ began row: {" + ", ".join(f"{x:.1f}" for i in range(5) for x in (c[f'hb{i}'] / (2 * len(files)), 100 * c[f'hb{i}_3'] / max(1, c[f'hb{i}']), md(L[f'hb{i}_d']))) + "}")
    print("C++ start row: {" + ", ".join(f"{x:.1f}" for x in [c['ps'] / (2 * len(files)), md(L['ps_len']), md(L['ps_fl']), md(L['ps_dk']), q(L['ps_dk'], .25), q(L['ps_dk'], .75)] + [100 * c[f'ps_b{i}'] / pm for i in range(4)]
          + [100 * c['ps_onp'] / pm, md(L['ps_vk']), q(L['ps_vk'], .25), q(L['ps_vk'], .75), md(L['ps_pace']), q(L['ps_pace'], .25), q(L['ps_pace'], .75), md(L['ps_cl']), q(L['ps_cl'], .25), q(L['ps_cl'], .75), md(L['ps_cls']), md(L['ps_d0']), md(L['ps_vr']), q(L['ps_vr'], .25), q(L['ps_vr'], .75)]) + ", " + ", ".join(f"{x:.2f}" for x in [md(L['ps_str']), q(L['ps_str'], .25), q(L['ps_str'], .75)]) + ", " + ", ".join(f"{x:.0f}" for x in [md(L['ps_ak']), q(L['ps_ak'], .25), q(L['ps_ak'], .75), md(L['ps_a0']), q(L['ps_a0'], .25), q(L['ps_a0'], .75)]) + "}")
    print("C++ press row: {" + ", ".join(f"{x:.1f}" for x in [100 * c[f'pd{i}'] / pn for i in range(5)] + [100 * c[f'pr{r}'] / pn for r in range(6)] + [100 * c['still1'] / max(1, c['at1']), md(L['d1']), md(L['cl']), q(L['cl'], .25), q(L['cl'], .75), 100 * c['in3_1'] / s1, md(L['len']), q(L['len'], .75)]) + "}")
    print("C++ row: {" + ", ".join(f"{x:.1f}" for x in [c['n'] / (2 * len(files)), md(L['opp']), 100 * c['line0'] / n, 100 * c['line1'] / n, 100 * c['line2'] / n, md(L['ah']), q(L['ah'], .25), q(L['ah'], .75)] + [100 * c[f'lr{r}'] / nl for r in range(6)] + [md(L['lo']), 100 * c['lo3'] / nl, c['inside'] / n, md(L['ins'])]) + "}")

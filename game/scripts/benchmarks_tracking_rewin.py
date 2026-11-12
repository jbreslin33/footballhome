#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_rewin.py (G5.97, DESIGN §8.198) — usage: <DFL dir>
# Real: the moment a ball changes side in play (BallPossession flips, unbroken at 5 Hz) and what the
# next 3 s do with it. At the first frame of the winner's spell: the loser's nearest outfielder to the
# ball and the winner's (m), the ball's speed (m/s over the last 0.2 s) and height. Then whether the
# winner gives it straight back (the other side on it again inside 3 s, in play), whether it goes dead,
# or he keeps it 3 s+. Cut by the loser's nearest at the win, and by the loser's nearest 1 s later (does
# the counter-press close). Losers' spells that lasted under 1 s are flicker and not counted as wins.
# DFL tracking (Bassek et al. 2025, CC BY), loader as benchmarks_tracking_turnline.py.
import collections, glob, os, re, sys, multiprocessing, datetime
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
DB = (2, 4, 7, 12)   # the loser's nearest outfielder to the ball, m
def db(d): return 0 if d < DB[0] else 1 if d < DB[1] else 2 if d < DB[2] else 3 if d < DB[3] else 4
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    half = length / 2; team_of = {home: 0, guest: 1}
    ball = {}; tsec = {}; pl = collections.defaultdict(dict); who = {}
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
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1 if (st and st.group(1) == "1" and po and po.group(1) in "12") else -1, float(a[9]))
                tsec[(sec, n)] = datetime.datetime.fromisoformat(a[3]).timestamp()
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    keys = sorted(ball)
    # DFL events: (epoch s, team side, kind) — kind = pass_ok / pass_fail / cross_* / shot / tackle_won (for WinnerTeam) / tackle_lost / other (OtherBallAction) / claim
    ev_p = glob.glob(os.path.join(d, f"DFL_03_02_events_raw_*_{mid}"))[0]
    evs = []; cur_t = None
    for line in open(ev_p, encoding="utf8"):
        s = line.strip()
        if s.startswith("<Event "):
            m = re.search(r'EventTime="([^"]+)"', s); cur_t = datetime.datetime.fromisoformat(m.group(1)).timestamp() if m else None
        elif cur_t is None: continue
        elif s.startswith("<Play "):
            tm = team_of.get(re.search(r'Team="([^"]+)"', s).group(1)); ev = re.search(r'Evaluation="([^"]+)"', s)
            if tm is not None: evs.append((cur_t, tm, "pass_ok" if ev and ev.group(1) == "successfullyCompleted" else "pass_fail"))
        elif s.startswith("<TacklingGame "):
            w = team_of.get(re.search(r'WinnerTeam="([^"]+)"', s).group(1)); ty = re.search(r' Type="([^"]+)"', s)
            if w is not None: evs.append((cur_t, w, "duel_" + (ty.group(1) if ty else "?")))
        elif s.startswith("<OtherBallAction "):
            tm = team_of.get(re.search(r'Team="([^"]+)"', s).group(1))
            if tm is not None: evs.append((cur_t, tm, "touch"))
        elif s.startswith("<BallClaiming "):
            m2 = re.search(r'Team="([^"]+)"', s); tm = team_of.get(m2.group(1)) if m2 else None
            if tm is not None: evs.append((cur_t, tm, "claim"))
        elif s.startswith("<ShotAtGoal "):
            m2 = re.search(r'Team="([^"]+)"', s); tm = team_of.get(m2.group(1)) if m2 else None
            if tm is not None: evs.append((cur_t, tm, "shot"))
    evs.sort()
    import bisect
    evt = [e[0] for e in evs]
    def near(fr, bx, by, tm):
        return min((((x - bx) ** 2 + (y - by) ** 2) ** 0.5 for pid, (x, y) in fr.items() if who.get(pid) == tm and pid not in keepers), default=99.0)
    c = collections.Counter(); H = collections.defaultdict(list)
    # spells: runs of the same side on the ball, consecutive in play
    runs = []   # (sec, start index, end index, side)
    i = 0
    while i < len(keys):
        sc, n = keys[i]; att = ball[keys[i]][2]
        if att < 0: i += 1; continue
        j = i
        while j + 1 < len(keys) and keys[j + 1][0] == sc and keys[j + 1][1] == keys[j][1] + 5 and ball[keys[j + 1]][2] == att: j += 1
        runs.append((sc, i, j, att)); i = j + 1
    for r in range(1, len(runs)):
        sc, i0, i1, att = runs[r]; ps, p0, p1, patt = runs[r - 1]
        if ps != sc or patt == att or keys[i0][1] != keys[p1][1] + 5: continue   # not a change in play
        if (keys[p1][1] - keys[p0][1]) / 25 < 1: continue                          # the loser's spell was flicker
        n = keys[i0][1]; fr = pl.get((sc, n)); fr1 = pl.get((sc, n + 25))
        if not fr: continue
        bx, by, _, bz = ball[keys[i0]]; q = ball.get((sc, n - 5))
        spd = 5 * ((bx - q[0]) ** 2 + (by - q[1]) ** 2) ** 0.5 if q else 0.0
        dL = near(fr, bx, by, 1 - att); dW = near(fr, bx, by, att)
        dur = (keys[i1][1] - n) / 25
        nxt = runs[r + 1] if r + 1 < len(runs) else None
        back = nxt is not None and nxt[0] == sc and nxt[3] != att and keys[nxt[1]][1] == keys[i1][1] + 5
        out = "back" if (dur < 3 and back) else "dead" if dur < 3 else "kept"
        # events in the winner's spell (win −0.4 s … its end +0.4 s): the winner's first, and for a giveback the act that takes it back
        t0 = tsec[keys[i0]] - 0.4; t1 = tsec[keys[i1]] + 0.4
        sp = evs[bisect.bisect_left(evt, t0):bisect.bisect_right(evt, t1)]
        mine = [e for e in sp if e[1] == att]
        first = mine[0][2] if mine else "none"
        c[("first", out, first)] += 1
        if out == "back":
            tb = tsec[keys[i1]]; near_ev = [e for e in sp if abs(e[0] - tb) <= 0.8]
            took = "duel won by loser" if any(e[1] != att and e[2].startswith("duel") for e in near_ev) else \
                   "winner's pass failed" if any(e[1] == att and e[2] == "pass_fail" for e in near_ev) else \
                   "winner touch" if any(e[1] == att and e[2] == "touch" for e in near_ev) else \
                   "loser's act" if any(e[1] != att for e in near_ev) else "no event"
            c[("took", took)] += 1
            c[("nmine", min(3, len(mine)))] += 1
        kind = "air" if (spd >= 8 and bz >= 1.5) else "kicked" if spd >= 8 else "feet"
        b = db(dL)
        c[("n", b)] += 1; c[("o", b, out)] += 1; c["n"] += 1; c[("o", out)] += 1
        c[("k", kind)] += 1; c[("ko", kind, out)] += 1
        H[("dL", kind)].append(dL); H[("dW", kind)].append(dW); H["dL"].append(dL); H["dW"].append(dW)
        if fr1 and (sc, n + 25) in ball:
            b1x, b1y = ball[(sc, n + 25)][0], ball[(sc, n + 25)][1]
            d1 = near(fr1, b1x, b1y, 1 - att)
            if dur >= 1:
                c[("n1", db(d1))] += 1
                if out == "back": c[("b1", db(d1))] += 1
                H[("d1", b)].append(d1)
    # CONTROL SPELLS (tracking only, so ours and real cut alike): a man is on the ball when he is the nearest
    # to it within 1.5 m (ball under 1.5 m high) on two 5 Hz frames running; the side's spell runs from its first
    # such frame to the other side's; a dead ball (or a gap) ends the chain without a change.
    side = -1; since = None; cand = None; won = None   # won: (frame of the win, loser's spell s) for the open spell
    prev = None
    for key in keys:
        sc, n = key; bx, by, att, bz = ball[key]; fr = pl.get(key)
        cont = prev is not None and prev[0] == sc and prev[1] == n - 5 and att >= 0
        prev = key if att >= 0 else None
        if not cont or not fr:
            if won is not None: c["c_dead"] += 1 if (n - won[0]) / 25 < 3 else 0
            side = -1; since = None; cand = None; won = None
            if att < 0: continue
        best = None; bd = 1.5
        if bz <= 1.5 and fr:
            for pid, (x, y) in fr.items():
                if pid not in who: continue
                dd = ((x - bx) ** 2 + (y - by) ** 2) ** 0.5
                if dd <= bd: bd = dd; best = pid
        if best is not None and cand is not None and best == cand[0]:
            tm = who[best]; t0 = cand[1]
            if side < 0: side = tm; since = t0
            elif tm != side:
                age = (t0 - since) / 25
                c[("c_loss", 0 if age < 3 else 1 if age < 6 else 2)] += 1
                if won is not None and (t0 - won[0]) / 25 < 3: c["c_back"] += 1
                won = (t0, age) if age >= 1 else None
                if age >= 1: c["c_win"] += 1
                side = tm; since = t0
        cand = (best, n) if best is not None and (cand is None or cand[0] != best) else cand if best is not None else None
    return c, H
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); H = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, hh in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in hh.items(): H[k2] += v
    def med(v): v = sorted(v); return v[len(v) // 2] if v else float("nan")
    tm = 2 * len(files); N = max(1, c["n"])
    print(f"{len(files)} DFL matches: THE WIN (ball changes side in play, the loser had it 1 s+): {N/tm:.1f} a team-match; "
          f"given straight back (other side on it inside 3 s) {100*c[('o','back')]/N:.1f}%, dead inside 3 s {100*c[('o','dead')]/N:.1f}%, kept 3 s+ {100*c[('o','kept')]/N:.1f}%")
    print(f"  at the win, nearest outfielder to the ball med: loser {med(H['dL']):.1f} m, winner {med(H['dW']):.1f} m")
    BN = ["0-2", "2-4", "4-7", "7-12", "12+"]
    print("  by the loser's nearest at the win: share % | given back by 3 s % | the loser's nearest 1 s later med")
    for b in range(5):
        n = c[("n", b)]
        if n: print(f"     {BN[b]:5s} {100*n/N:5.1f} | {100*c[('o', b, 'back')]/n:5.1f} | {med(H[('d1', b)]):5.1f}")
    print("  by the ball at the win (kicked on the ground 8+ m/s / in the air 1.5 m+ / at feet): share % | given back % | loser's nearest med | winner's nearest med")
    for kd in ("kicked", "air", "feet"):
        n = c[("k", kd)]
        if n: print(f"     {kd:6s} {100*n/N:5.1f} | {100*c[('ko', kd, 'back')]/n:5.1f} | {med(H[('dL', kd)]):5.1f} | {med(H[('dW', kd)]):5.1f}")
    nl = sum(c[("c_loss", i)] for i in range(3)); nw = max(1, c["c_win"])
    print(f"  CONTROL SPELLS (a man nearest the ball within 1.5 m, ball under 1.5 m, two 5 Hz frames running): changes {nl/tm:.1f} a team-match, by the losing spell's age <3 / 3-6 / 6+ s: " + " / ".join(f"{c[('c_loss', i)]/tm:.1f}" for i in range(3)) + f"; wins (loser on it 1 s+) {nw/tm:.1f}, given back by 3 s {100*c['c_back']/nw:.1f}%")
    for out in ("back", "dead", "kept"):
        tot = sum(v for k, v in c.items() if isinstance(k, tuple) and k[0] == "first" and k[1] == out)
        row = sorted(((v, k[2]) for k, v in c.items() if isinstance(k, tuple) and k[0] == "first" and k[1] == out), reverse=True)
        print(f"  the winner's first event, spells {out}: " + ", ".join(f"{nm} {100*v/tot:.1f}%" for v, nm in row))
    tb = sum(v for k, v in c.items() if isinstance(k, tuple) and k[0] == "took")
    print("  how a giveback happens (events within 0.8 s of the change back): " + ", ".join(f"{k[1]} {100*v/tb:.1f}%" for k, v in sorted(c.items(), key=lambda kv: -kv[1]) if isinstance(k, tuple) and k[0] == "took"))
    print("  givebacks by the winner's events in the spell 0/1/2/3+: " + " / ".join(f"{100*c[('nmine', i)]/tb:.1f}" for i in range(4)))
    print("  spells 1 s+ old, by the loser's nearest 1 s after the win: share % | given back by 3 s %")
    n1 = max(1, sum(c[("n1", b)] for b in range(5)))
    for b in range(5):
        n = c[("n1", b)]
        if n: print(f"     {BN[b]:5s} {100*n/n1:5.1f} | {100*c[('b1', b)]/n:5.1f}")

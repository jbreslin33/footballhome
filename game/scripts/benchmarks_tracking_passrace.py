#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_passrace.py (G5.99, DESIGN §8.200) — usage: <DFL dir>
# Real: every open-play flat pass naming its Recipient (DFL events), scored by one CRUDE RACE that the
# harness runs identically on ours: the ball goes straight from the passer's spot to where the receiver
# stood at the kick at 11 m/s; every man reaches a point at 0.3 s + distance / 7 m/s, with 0.5 m of reach.
# "Theirs first" = an opponent reaches some point of the line (every 0.5 m, from 2 m out) before the ball
# and before the receiver. By the pass's length: the share of passes theirs first, and the completion of
# those and of the rest. Plus the passer's options at the kick: mates 5 m+ away, and how many of those
# the crude race calls ours.
# DFL tracking + events (Bassek et al. 2025, CC BY).
import bisect, collections, datetime, glob, math, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
VB, VP, RT, REACH = 11.0, 7.0, 0.3, 0.5
LB = (10, 20, 30)
def lb(d): return 0 if d < LB[0] else 1 if d < LB[1] else 2 if d < LB[2] else 3
MB = (0.2, 0.4, 0.7)
def mb(m): return 0 if m < MB[0] else 1 if m < MB[1] else 2 if m < MB[2] else 3
def margin(px, py, tx, ty, recv, opps):
    """How much their best man wins the race by (s): max over line points of min(ball, receiver) − his time; ≤ 0 = ours."""
    L = math.hypot(tx - px, ty - py); best = -9.0
    if L < 2: return best
    ux, uy = (tx - px) / L, (ty - py) / L
    s = 2.0
    while s <= L + 1e-9:
        qx, qy = px + ux * s, py + uy * s; tb = s / VB
        tr = RT + max(0.0, math.hypot(recv[0] - qx, recv[1] - qy) - REACH) / VP
        for ox, oy in opps:
            to = RT + max(0.0, math.hypot(ox - qx, oy - qy) - REACH) / VP
            best = max(best, min(tb, tr) - to)
        s += 0.5
    return best
def theirs_first(px, py, tx, ty, recv, opps):
    L = math.hypot(tx - px, ty - py)
    if L < 2: return False
    ux, uy = (tx - px) / L, (ty - py) / L
    s = 2.0
    while s <= L + 1e-9:
        qx, qy = px + ux * s, py + uy * s; tb = s / VB
        tr = RT + max(0.0, math.hypot(recv[0] - qx, recv[1] - qy) - REACH) / VP
        for ox, oy in opps:
            to = RT + max(0.0, math.hypot(ox - qx, oy - qy) - REACH) / VP
            if to < tb and to < tr: return True
        s += 0.5
    return False
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    team_of = {home: 0, guest: 1}
    ball = {}; pl = collections.defaultdict(dict); who = {}; ts = []
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    sec = None; isb = False; skip = True; cur = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if n % 5: continue
            if isb:
                ball[(sec, n)] = (float(a[5]), float(a[7]))
                ts.append((datetime.datetime.fromisoformat(a[3]).timestamp(), sec, n))
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    ts.sort(); tk = [t[0] for t in ts]
    ev_p = glob.glob(os.path.join(d, f"DFL_03_02_events_raw_*_{mid}"))[0]
    c = collections.Counter(); cur_t = None; lines = open(ev_p, encoding="utf8").read().splitlines()
    for i, line in enumerate(lines):
        s = line.strip()
        if s.startswith("<Event "):
            m = re.search(r'EventTime="([^"]+)"', s); cur_t = datetime.datetime.fromisoformat(m.group(1)).timestamp() if m else None
            continue
        if not s.startswith("<Play ") or cur_t is None: continue
        if 'Height="flat"' not in s or 'FromOpenPlay="true"' not in s or "Recipient=" not in s: continue
        if i + 1 >= len(lines) or not lines[i + 1].strip().startswith("<Pass"): continue
        ev = re.search(r'Evaluation="([^"]+)"', s); ok = ev and ev.group(1) == "successfullyCompleted"
        if not ev or ev.group(1) not in ("successfullyCompleted", "unsuccessful"): continue
        passer = re.search(r' Player="([^"]+)"', s).group(1); rcv = re.search(r'Recipient="([^"]+)"', s).group(1)
        j = bisect.bisect_left(tk, cur_t)
        best = min((k for k in (j - 1, j) if 0 <= k < len(ts)), key=lambda k: abs(tk[k] - cur_t), default=None)
        if best is None or abs(tk[best] - cur_t) > 0.3: continue
        _, sc, n = ts[best]; fr = pl.get((sc, n))
        if not fr or passer not in fr or rcv not in fr or passer not in who: continue
        tm = who[passer]; px, py = fr[passer]; tx, ty = fr[rcv]
        L = math.hypot(tx - px, ty - py)
        if L < 5: continue
        opps = [p for pid, p in fr.items() if who.get(pid) == 1 - tm]
        tf = theirs_first(px, py, tx, ty, (tx, ty), opps)
        mg = margin(px, py, tx, ty, (tx, ty), opps)
        if mg > 0: c[("mn", mb(mg))] += 1; c[("mok", mb(mg))] += ok
        b = lb(L); c[("n", b)] += 1; c[("tf", b)] += tf; c[("ok", b, tf)] += ok; c[("nn", b, tf)] += 1
        nm = ns = 0
        for pid, (mx, my) in fr.items():
            if who.get(pid) != tm or pid == passer or pid in keepers: continue
            if math.hypot(mx - px, my - py) < 5: continue
            nm += 1; ns += not theirs_first(px, py, mx, my, (mx, my), opps)
        c[("opt", tf, min(ns, 4))] += 1; c[("optn", tf)] += 1
    return c
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for cc in pool.imap_unordered(one, files): c.update(cc)
    tm = 2 * len(files); BN = ["5-10", "10-20", "20-30", "30+"]
    print(f"{len(files)} DFL matches: CRUDE RACE (ball {VB} m/s straight to where the receiver stood, men {VP} m/s after {RT} s, reach {REACH} m), open-play flat passes naming a recipient, 5 m+")
    print("  by length: passes a team-match | theirs first % | completed: theirs first / the rest %")
    for b in range(4):
        n = c[("n", b)]
        if n: print(f"     {BN[b]:5s} {n/tm:6.1f} | {100*c[('tf', b)]/n:5.1f} | {100*c[('ok', b, True)]/max(1, c[('nn', b, True)]):5.1f} / {100*c[('ok', b, False)]/max(1, c[('nn', b, False)]):5.1f}")
    print("  theirs first, by how much their man wins the race 0-0.2 / 0.2-0.4 / 0.4-0.7 / 0.7+ s: passes a team-match | completed %: " + " ; ".join(f"{c[('mn', i)]/tm:.1f} | {100*c[('mok', i)]/max(1, c[('mn', i)]):.1f}" for i in range(4)))
    for tf in (True, False):
        n = max(1, c[("optn", tf)])
        print(f"  passes {'theirs first' if tf else 'ours first  '}: the passer's other mates 5 m+ the race calls ours 0/1/2/3/4+ %: " + " / ".join(f"{100*c[('opt', tf, k)]/n:.0f}" for k in range(5)))

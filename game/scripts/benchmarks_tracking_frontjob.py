#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_frontjob.py (G5.63, DESIGN §8.164) — usage: <DFL dir>
# Real: who is the side in possession's front man, and for how long? Front man = the outfielder of
# the side on the ball nearest their goal line, not the man on the ball (nearest it within 2 m).
# Kept with a hysteresis h (the holder keeps it until a mate is h m further on; h = 0 raw, 1, 3).
# Tenure = seconds in the job, ended by a handover (spells ended by the ball changing side or going
# dead are counted apart). At a handover: the new man's gap to their offside line, the old man's, and
# where the new man was 2 s before; and why: the old man went on the ball, dropped (moved back 1+ m
# over the last 1 s) or was overtaken (new man moved on 1+ m). DFL tracking (Bassek et al. 2025,
# CC BY), loader as benchmarks_tracking_linegap.py. 5 Hz.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
HS = (0.0, 1.0, 3.0)
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
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1 if (st and st.group(1) == "1" and po and po.group(1) in "12") else -1)
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
    c = collections.Counter(); T = collections.defaultdict(list); H = collections.defaultdict(list)
    # §8.171: the front two's gap to their line by seconds since the spell began (5 Hz, in play)
    spell0 = None; prevk = None
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]; fr = pl.get((sc, n))
        if att < 0 or not fr: prevk = None; continue
        if prevk is None or prevk[0] != sc or prevk[1] != n - 5 or prevk[2] != att: spell0 = n
        prevk = (sc, n, att)
        dfd = 1 - att; g = own[(sc, dfd)]
        dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == dfd)
        if len(dl) < 2: continue
        L = min(dl[1], half - bx * g)
        onb = None; bd = 4.0
        for pid, (x, y) in fr.items():
            if who.get(pid) != att: continue
            dd = (x - bx) ** 2 + (y - by) ** 2
            if dd < bd: bd = dd; onb = pid
        A = sorted(half - x * g - L for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers and pid != onb)
        if len(A) < 2: continue
        since = (n - spell0) / 25; b = 0 if since < 3 else 1 if since < 6 else 2 if since < 10 else 3 if since < 20 else 4
        if since < 1:   # at the turnover: their line and our front man, metres off their goal, by the ball's
            btl = half - bx * g; zb = 0 if btl < 35 else 1 if btl < 52 else 2 if btl < 70 else 3
            H[("tL", zb)].append(L); H[("tA", zb)].append(L + A[0])
        H[("s1", b)].append(A[0]); H[("s2", b)].append(A[1] - A[0])
    for h in HS:
        hold = None; since = None; prev = None; hist = {}
        for (sc, n) in sorted(ball):
            bx, by, att = ball[(sc, n)]; fr = pl.get((sc, n))
            if att < 0 or not fr or prev is None or prev[0] != sc or prev[1] != n - 5 or prev[2] != att:
                if hold is not None and since is not None: T[(h, "end")].append((prev[1] - since) / 25)
                hold = None; since = None; prev = (sc, n, att) if att >= 0 else None; hist = {}
                if att < 0 or not fr: continue
            prev = (sc, n, att)
            dfd = 1 - att; g = own[(sc, dfd)]
            dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == dfd)
            if len(dl) < 2: continue
            L = min(dl[1], half - bx * g)
            onb = None; bd = 4.0
            for pid, (x, y) in fr.items():
                if who.get(pid) != att: continue
                dd = (x - bx) ** 2 + (y - by) ** 2
                if dd < bd: bd = dd; onb = pid
            A = {pid: half - x * g for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers}
            hist[n] = A
            cand = {p: a for p, a in A.items() if p != onb}
            if not cand: continue
            best = min(cand, key=cand.get)
            c[(h, "t")] += 1
            if hold is None or hold not in cand:
                why = "first" if hold is None else ("on ball" if hold == onb else "gone")
                if hold is not None:
                    T[(h, "hand")].append((n - since) / 25); c[(h, why)] += 1
                    then = hist.get(n - 50, {})
                    H[(h, "new")].append(cand[best] - L); H[(h, "new2")].append(then.get(best, cand[best]) - (cand[best]))
                hold = best; since = n; continue
            if cand[best] + h < cand[hold] and best != hold:
                old = hist.get(n - 25, {})
                dold = cand[hold] - old.get(hold, cand[hold]); dnew = old.get(best, cand[best]) - cand[best]
                why = "old dropped" if dold >= 1 else "new on" if dnew >= 1 else "drift"
                c[(h, why)] += 1
                T[(h, "hand")].append((n - since) / 25)
                then = hist.get(n - 50, {})
                H[(h, "new")].append(cand[best] - L); H[(h, "old")].append(cand[hold] - L)
                H[(h, "new2")].append(then.get(best, cand[best]) - cand[best])
                hold = best; since = n
            for k in list(hist):
                if k < n - 60: del hist[k]
    return c, T, H
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); T = collections.defaultdict(list); H = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, tt, hh in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in tt.items(): T[k2] += v
            for k2, v in hh.items(): H[k2] += v
    def q(v):
        v = sorted(v); return f"{v[len(v)//4]:5.1f}/{v[len(v)//2]:5.1f}/{v[3*len(v)//4]:5.1f}" if v else "    -"
    tm = 2 * len(files)
    print(f"{len(files)} DFL matches: THE FRONT MAN (ours on the ball in play; nearest their goal, not on the ball; 5 Hz)")
    for h in HS:
        n = len(T[(h, "hand")]); secs = c[(h, "t")] / 5
        print(f"  hysteresis {h:.0f} m: handovers {n/tm:6.1f} a team-match, one per {secs/max(1,n):5.1f} s in possession; "
              f"tenure to a handover p25/med/p75 {q(T[(h,'hand')])} s, to the spell's end {q(T[(h,'end')])} s")
        why = ["on ball", "gone", "old dropped", "new on", "drift"]
        print("     why: " + "  ".join(f"{w} {100*c[(h,w)]/max(1,n):4.1f}%" for w in why))
        pass
        print(f"     at the handover gap to their line p25/med/p75: new man {q(H[(h,'new')])}  old man {q(H[(h,'old')])};"
              f" the new man moved on over the last 2 s {q(H[(h,'new2')])} m")
    SB = ["<3 s", "3-6", "6-10", "10-20", "20+"]
    print("  §8.171 by seconds since the spell began: front man m short of their line p25/med/p75 | 4+ m short % | the second man behind him p25/med/p75")
    for b in range(5):
        v = H[("s1", b)]
        if v: print(f"     {SB[b]:6s} {q(v)}  {100*sum(x >= 4 for x in v)/len(v):5.1f}%   | {q(H[('s2', b)])}   ({len(v)} frames)")
    ZB = ["ball 0-35", "35-52", "52-70", "70+"]
    print("  §8.171 in the first second of the spell, m off their goal p25/med/p75: their line | our front man (not on the ball)")
    for z in range(4):
        if H[("tL", z)]: print(f"     {ZB[z]:9s} {q(H[('tL', z)])} | {q(H[('tA', z)])}   ({len(H[('tL', z)])})")

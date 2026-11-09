#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_turnline.py (G5.71, DESIGN §8.172) — usage: <DFL dir>
# Real: the side in possession's own offside line (its second-last man, keeper in) — metres off ITS
# goal — by the ball's band (ball m off that goal): in every possession frame, and in the last
# second before it loses the ball (the next side on it is the other, unbroken in play at 5 Hz). Then
# what the losing moments are: how far the ball came forward over the 3 s before (m toward their
# goal), the line's gap to its usual height for that band (the line's mean in all frames, 5 m bins),
# and how long the spell had run. Spells end by the ball changing side; dead balls are not losses.
# DFL tracking (Bassek et al. 2025, CC BY), loader as benchmarks_tracking_frontjob.py.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ZB = (35, 52, 70)   # bands of the ball m off the losing side's goal, as frontjob's turnover cut
def zb(b): return 0 if b < ZB[0] else 1 if b < ZB[1] else 2 if b < ZB[2] else 3
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
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1 if (st and st.group(1) == "1" and po and po.group(1) in "12") else -1, float(a[9]))
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
    # per in-play possession frame: (sec, n, att, ball m off att's goal, att's line m off its goal)
    rows = []
    for (sc, n) in sorted(ball):
        bx, by, att, bz = ball[(sc, n)]; fr = pl.get((sc, n))
        if att < 0 or not fr: rows.append(None); continue
        g = own[(sc, att)]
        dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == att)   # m off att's own goal
        if len(dl) < 2: rows.append(None); continue
        rows.append((sc, n, att, half - bx * g, dl[1]))
    H = collections.defaultdict(list); c = collections.Counter()
    for r in rows:
        if r: H[("all", int(r[3] // 5))].append(r[4]); c[("allz", zb(r[3]))] += 1
    lose = []   # index of the last frame of a spell that the other side then has, unbroken
    for i in range(1, len(rows)):
        a, b = rows[i - 1], rows[i]
        if a and b and a[0] == b[0] and b[1] == a[1] + 5 and b[2] != a[2]: lose.append(i - 1)
    for i in lose:
        sc, n, att, bb, L = rows[i]
        j = i;
        while j > 0 and rows[j - 1] and rows[j - 1][0] == sc and rows[j - 1][1] == rows[j][1] - 5 and rows[j - 1][2] == att: j -= 1
        dur = (n - rows[j][1]) / 25
        k = i - 15   # 3 s before (5 Hz)
        fwd = bb - rows[k][3] if k >= 0 and rows[k] and rows[k][0] == sc and rows[k][1] == n - 75 and rows[k][2] == att else None
        e = i + 1
        while e + 1 < len(rows) and rows[e + 1] and rows[e + 1][0] == sc and rows[e + 1][1] == rows[e][1] + 5 and rows[e + 1][2] == rows[i + 1][2]: e += 1
        kept = (rows[e][1] - rows[i + 1][1]) / 25 >= 2   # the winner keeps it 2 s+ (or it goes dead after 2 s+)
        # §8.172: was the ball kicked (moving 8+ m/s over the last 0.2 s) or at a man's feet, by the spell's age
        p0 = ball.get((sc, n - 5)); p1 = ball[(sc, n)]
        spd = 5 * ((p1[0] - p0[0]) ** 2 + (p1[1] - p0[1]) ** 2) ** 0.5 if p0 else 0.0
        kind = "air" if (spd >= 8 and max(p1[3], ball.get((sc, n + 5), p1)[3]) >= 1.5) else "kicked" if spd >= 8 else "feet"
        ab = 0 if dur < 3 else 1 if dur < 6 else 2
        c[("k", ab, kind)] += 1; c[("k", ab)] += 1
        if kept: c[("kk", ab, kind)] += 1; c[("kk", ab)] += 1
        z = zb(bb); c[("n", z)] += 1
        if kept:
            c[("nk", z)] += 1; H[("lastk", z)].append(L); H[("durk", z)].append(dur); H[("gapkk", z)].append((int(bb // 5), L))
        H[("last", z)].append(L); H[("lastb", z)].append(bb); H[("dur", z)].append(dur)
        if fwd is not None: H[("fwd", z)].append(fwd)
        H[("gapk", z)].append((int(bb // 5), L))   # gap to the usual line, resolved in main
    # spells won in play (the ball came from the other side, unbroken) and kept 2 s+: forward at +3/+6 s, lost by 3/6/10 s
    for i in lose:
        st = i + 1; sc, n0, att, b0, _ = rows[st]
        e = st
        while e + 1 < len(rows) and rows[e + 1] and rows[e + 1][0] == sc and rows[e + 1][1] == rows[e][1] + 5 and rows[e + 1][2] == att: e += 1
        dur = (rows[e][1] - n0) / 25
        if dur < 2: continue
        lost = e + 1 < len(rows) and rows[e + 1] and rows[e + 1][0] == sc and rows[e + 1][1] == rows[e][1] + 5   # ended by the other side on it
        z = zb(b0); c[("w", z)] += 1
        for T in (3, 6, 10):
            if lost and dur < T: c[("wl", z, T)] += 1
        for T in (3, 6):
            if st + 5 * T <= e: H[("wf", z, T)].append(rows[st + 5 * T][3] - b0)
    return c, H, len(lose)
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); H = collections.defaultdict(list); nl = 0
    with multiprocessing.Pool(3) as pool:
        for cc, hh, n in pool.imap_unordered(one, files):
            c.update(cc); nl += n
            for k2, v in hh.items(): H[k2] += v
    def q(v):
        v = sorted(v); return f"{v[len(v)//4]:5.1f}/{v[len(v)//2]:5.1f}/{v[3*len(v)//4]:5.1f}" if v else "    -"
    def med(v): v = sorted(v); return v[len(v) // 2] if v else float("nan")
    tm = 2 * len(files)
    usual = {b: sum(H[("all", b)]) / len(H[("all", b)]) for b in range(30) if H[("all", b)]}
    print(f"{len(files)} DFL matches: THE SIDE IN POSSESSION'S OWN LINE (second-last, keeper in), m off ITS goal; {nl/tm:.1f} losses a team-match (ball to the other side in play)")
    print("  all possession frames, ball 5 m bins off its own goal: " + "  ".join(f"{5*b}-{5*b+5} {usual[b]:.1f}" for b in sorted(usual)))
    ZN = ["ball 0-35", "35-52", "52-70", "70+"]
    print("  in the last frame before the loss, by the ball's band: losses a team-match / share of possession frames there | line p25/med/p75 | ball med | line minus usual med | ball forward over 3 s p25/med/p75 | spell s med")
    for z in range(4):
        if not H[("last", z)]: continue
        gap = [L - usual.get(b, L) for b, L in H[("gapk", z)]]
        gk = [L - usual.get(b, L) for b, L in H[("gapkk", z)]]
        print(f"     {ZN[z]:9s} kept 2 s+ by the winner: {c[('nk', z)]/tm:5.1f} a team-match | line med {med(H[('lastk', z)]):5.1f} | minus usual {med(gk):+5.1f} | spell s med {med(H[('durk', z)]):4.1f}")
        print(f"     {ZN[z]:9s} {c[('n', z)]/tm:5.1f} / {100*c[('n', z)]/max(1, c[('allz', z)]):.2f}% | {q(H[('last', z)])} | {med(H[('lastb', z)]):5.1f} | {med(gap):+5.1f} | {q(H[('fwd', z)])} | {med(H[('dur', z)]):4.1f}")
    print("  spells won in play and kept 2 s+, by the ball's band at the win: a team-match | lost again by 3 / 6 / 10 s % | ball forward at +3 s p25/med/p75 | at +6 s")
    for z in range(4):
        n = c[("w", z)]
        if n: print(f"     {ZN[z]:9s} {n/tm:5.1f} | {100*c[('w', z, 3)]/n if False else 100*c[('wl', z, 3)]/n:4.1f} / {100*c[('wl', z, 6)]/n:4.1f} / {100*c[('wl', z, 10)]/n:4.1f} | {q(H[('wf', z, 3)])} | {q(H[('wf', z, 6)])}")
    print("  losses by the spell's age: a team-match | the ball at the change: kicked on the ground / kicked in the air (1.5 m+) / at feet %  || kept 2 s+ by the winner: a team-match | ground / air / feet %")
    for ab, nm in enumerate(("<3 s", "3-6", "6+")):
        n = c[("k", ab)]; nk = c[("kk", ab)]
        if n: print(f"     {nm:5s} {n/tm:5.1f} | " + " / ".join(f"{100*c[('k', ab, kd)]/n:4.1f}" for kd in ("kicked", "air", "feet")) + f"  || {nk/tm:5.1f} | " + " / ".join(f"{100*c[('kk', ab, kd)]/max(1,nk):4.1f}" for kd in ("kicked", "air", "feet")))

#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_shoulder.py (G5.44, DESIGN §8.144) — usage: <DFL dir>
# Real: does the block stand where the ball IS, or where it is going? The side WITHOUT the ball
# (the other side in BallPossession, in play, 5 Hz), SETTLED (6 s+ since it lost it, as
# benchmarks_tracking_possession.py), by the ball's 10 m band off the defenders' own line and the
# ball's speed toward that line over the last second (m/s, + = coming at them): each role's mean
# metres off its own line. If real men drop ahead of a ball coming at them, the "coming" rows stand
# deeper than the "still" rows at the same band; the settled table (§8.131) is the blend.
# Roles as benchmarks_tracking_possession. DFL tracking (Bassek et al. 2025, CC BY).
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ROLE = {"IVL": 0, "IVR": 0, "IVZ": 0, "LV": 1, "RV": 1, "DML": 2, "DMR": 2, "DMZ": 2, "DLM": 2, "DRM": 2, "ZO": 3,
        "OLM": 4, "ORM": 4, "LM": 4, "RM": 4, "HL": 4, "HR": 4, "LA": 4, "RA": 4, "STL": 5, "STR": 5, "STZ": 5}   # as benchmarks_tracking_possession
NAMES = ["CB", "FB", "DM/CM", "AM", "WIDE", "ST"]
VB = [(-99, -2, "away"), (-2, 2, "still"), (2, 5, "coming 2-5"), (5, 99, "coming 5+")]   # for the side in possession: back / still / forward 2-5 / forward 5+
def vbin(v):
    for i, (lo, hi, _) in enumerate(VB):
        if lo <= v < hi: return i
    return 1
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
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
    c = collections.Counter(); spells = []; sd = collections.defaultdict(list); sd2 = collections.defaultdict(list); sd2b = collections.defaultdict(list)
    cur = None   # (sec, team, pid, start frame, last frame)
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        if att < 0: cur = None; continue
        dfd = 1 - att; g = own[(sc, dfd)]
        btl = half - bx * g; b = min(9, max(0, int(btl // 10)))
        fr = pl.get((sc, n), {})
        dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == dfd)
        fa = sorted((half - x * g, pid, y) for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers)
        if len(dl) < 2 or len(fa) < 2: cur = None; continue
        line = min(dl[1], btl)
        (f1, p1, y1), (f2, p2, y2) = fa[0], fa[1]
        r = ROLE.get(pos_of.get(p1), -1)
        c[("n", b)] += 1; c[("gap", b)] += f1 - line; c[("gap2", b)] += f2 - f1
        c[("r", b, r)] += 1; c[("dy", b)] += abs(y1 - by)
        c[("off", b)] += f1 < line                    # past the line (offside position if the ball came)
        c[("w1", b)] += 0 <= f1 - line < 1.0; c[("w2", b)] += 0 <= f1 - line < 2.0; c[("w4", b)] += f1 - line >= 4.0
        if r >= 0:
            c[("rn", b, r)] += 1; c[("rs", b, r)] += f1
        # Every striker (ST) of theirs on: his metres short of the line (− = past it), by band; and the nearer
        # of a pair (two-ST sides) — what a striker's job is measured on.
        sts = sorted(f for f, pid, y in fa if ROLE.get(pos_of.get(pid)) == 5)
        if sts:
            for f in sts: sd[b].append(round(f - line, 1))
            if len(sts) >= 2: sd2[b].append(round(sts[0] - line, 1)); sd2b[b].append(round(sts[1] - line, 1))
        if cur and cur[0] == sc and cur[1] == att and cur[2] == p1 and n - cur[4] == 5: cur = (sc, att, p1, cur[3], n)
        else:
            if cur and btl < 52: spells.append((cur[4] - cur[3] + 5) / 25)
            cur = (sc, att, p1, n, n)
    return c, spells, (sd, sd2, sd2b)
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); sp = []
    with multiprocessing.Pool(3) as pool:
        SD = [collections.defaultdict(list) for _ in range(3)]
        for r, s2, d3 in pool.imap_unordered(one, files):
            c.update(r); sp += s2
            for i in range(3):
                for k, v in d3[i].items(): SD[i][k] += v
    sp.sort()
    print(f"{len(files)} DFL matches: the side IN possession's most advanced outfielder v their offside line (second-last, keeper in, or the ball)")
    print("   band   frames  short of line  0-1 / 0-2 m / 4+ short  past it   2nd man behind   |dy| to ball   front man by role CB FB DM AM WIDE ST %   front man's mean m off their line by role")
    for b in range(10):
        n = c[("n", b)]
        if n < 20: continue
        roles = " ".join(f"{100*c[('r',b,r)]/n:3.0f}" for r in range(6))
        mean = " ".join(f"{c[('rs',b,r)]/c[('rn',b,r)]:5.1f}" if c[("rn", b, r)] > 30 else "    -" for r in range(6))
        print(f"   {b*10:2d}-{b*10+10:<3d} {n:6d}  {c[('gap',b)]/n:5.1f} m      {100*c[('w1',b)]/n:3.0f}% / {100*c[('w2',b)]/n:3.0f}% / {100*c[('w4',b)]/n:3.0f}%   {100*c[('off',b)]/n:4.1f}%   {c[('gap2',b)]/n:5.1f} m          {c[('dy',b)]/n:5.1f} m       {roles}      {mean}")
    if sp:
        q = lambda f: sp[min(len(sp) - 1, int(f * len(sp)))]
        print(f"   spells as the front man (ball inside 52 m of their line): n {len(sp)}, p25 / median / p75 / p90 {q(.25):.1f} / {q(.5):.1f} / {q(.75):.1f} / {q(.9):.1f} s")
    def qs(v):
        v = sorted(v); return " / ".join(f"{v[min(len(v)-1, int(f*len(v)))]:5.1f}" for f in (.1, .25, .5, .75, .9))
    print("   the striker (ST) v the line, m short (− = past it): band | every ST n, mean, p10/p25/p50/p75/p90 | two-ST sides: the nearer p10..p90 | the other p10..p90")
    for b in range(10):
        v = SD[0][b]
        if len(v) < 50: continue
        two = f"{qs(SD[1][b])} | {qs(SD[2][b])}" if len(SD[1][b]) >= 50 else "-"
        print(f"   {b*10:2d}-{b*10+10:<3d} | {len(v):6d} {sum(v)/len(v):5.1f}  {qs(v)} | {two}")

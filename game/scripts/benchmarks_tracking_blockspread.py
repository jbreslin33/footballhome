#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_blockspread.py (G5.70, DESIGN §8.171) — usage: <DFL dir>
# Real: how far each DEFENDING man stands off his role's mean spot, held over the opponents' spell.
# The side without the ball, in play, 5 Hz; depth = metres off his own goal line; the role's mean by
# the ball's 10 m band (off that same line) from all frames. A man's offset = depth - role/band mean
# - the block's own offset that frame (the mean over its outfielders: the team depth roll, G5.52, is
# apart). Per (spell, man) the mean offset → by role p10/p25/p50/p75/p90. Also the most advanced
# defending outfielder's depth by band (the man a turnover finds furthest up). DFL tracking (Bassek
# et al. 2025, CC BY), loader as benchmarks_tracking_gapspread.py.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES
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
    rows = []; spell = 0; last = None; lost_at = {}
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        if att < 0: last = None; continue
        if last != (sc, att): spell += 1; last = (sc, att); lost_at[spell] = n
        dfd = 1 - att; g = own[(sc, dfd)]
        bown = half - bx * g   # ball metres off the defenders' own line (g = their own end's sign)
        band = max(0, min(9, int(bown // 10)))
        fr = pl.get((sc, n), {})
        men = []
        for pid, (x, y) in fr.items():
            if who.get(pid) != dfd or pid in keepers: continue
            r = ROLE.get(pos_of.get(pid), -1)
            if r < 0: continue
            men.append((pid, r, half - x * g))
        if len(men) >= 8: rows.append((f"{mid}:{spell}", band, men, (n - lost_at[spell]) / 25 >= 6))
    return rows
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    rows = []
    with multiprocessing.Pool(3) as pool:
        for rr in pool.imap_unordered(one, files): rows += rr
    s = collections.defaultdict(float); c = collections.Counter()
    for sp, b, men, settled in rows:
        for pid, r, dep in men: s[(r, b)] += dep; c[(r, b)] += 1
    mean = {k: s[k] / c[k] for k in c}
    offz = collections.defaultdict(list)
    off = collections.defaultdict(list); top = collections.defaultdict(list); topst = collections.defaultdict(list); toprole = collections.Counter()
    for sp, b, men, settled in rows:
        o = [(pid, r, dep - mean[(r, b)]) for pid, r, dep in men]
        team = sum(x for _, _, x in o) / len(o)
        for pid, r, x in o: off[(sp, pid, r)].append(x - team); offz[(sp, pid, r, b < 2)].append(x - team)
        top[b].append(max(dep for _, _, dep in men))
        topst[(b, settled)].append(max(dep for _, _, dep in men))
        if settled: tm = max(men, key=lambda m: m[2]); toprole[tm[1]] += 1
    per = collections.defaultdict(list)
    for (sp, pid, r), v in off.items():
        if len(v) >= 10: per[r].append(sum(v) / len(v))   # 2 s+ of the spell
    def qs(v, ps=(.1, .25, .5, .75, .9)):
        v = sorted(v); return [v[min(len(v) - 1, int(len(v) * p))] for p in ps]
    print(f"{len(files)} DFL matches: THE BLOCK'S SPREAD (the side without it, in play, 5 Hz; spells 2 s+)")
    print("   role   a man's spell offset off his role/band mean, net of the block's, p10/p25/p50/p75/p90 m (n)")
    for r in range(6):
        if per[r]: print(f"   {NAMES[r]:6s} " + " ".join(f"{x:6.1f}" for x in qs(per[r])) + f"   ({len(per[r])})")
    print("   the most advanced defending outfielder, m off his own line, by the ball's band: median")
    print("   " + " ".join(f"{b*10}-{b*10+10}: {qs(top[b], (.5,))[0]:.1f}" for b in range(10) if top[b]))
    print("   ... settled (6 s+ since they lost it) / transition (0-6 s): median")
    print("   " + " ".join(f"{b*10}-{b*10+10}: {qs(topst[(b, True)], (.5,))[0]:.1f}/{qs(topst[(b, False)], (.5,))[0]:.1f}" for b in range(10) if topst[(b, True)] and topst[(b, False)]))
    tot = sum(toprole.values())
    print("   settled, who is the most advanced: " + " ".join(f"{NAMES[r]} {100*toprole[r]/tot:.0f}%" for r in range(6)))
    print("   the role means by band (settled + transition), m off own line: " + " | ".join(NAMES[r] + " " + " ".join(f"{mean.get((r, b), 0):.0f}" for b in range(10)) for r in (4, 5)))
    perz = collections.defaultdict(list)
    for (sp, pid, r, deep), v in offz.items():
        if len(v) >= 10: perz[(r, deep)].append(sum(v) / len(v))
    print("   the same with the ball inside 20 m of their goal / further out:")
    for r in range(6):
        if perz[(r, True)] and perz[(r, False)]:
            print(f"   {NAMES[r]:6s} " + " ".join(f"{x:5.1f}" for x in qs(perz[(r, True)])) + "  |  " + " ".join(f"{x:5.1f}" for x in qs(perz[(r, False)])))

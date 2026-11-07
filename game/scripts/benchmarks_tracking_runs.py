#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_runs.py (G5.45, DESIGN §8.145) — usage: <DFL dir>
# Real: the side IN possession's men against the defenders' offside line (Law 11: second-last of
# theirs, keeper in, or the ball), in play, 5 Hz. (1) How many of ours stand in each 2 m bin of gap
# short of the line (− = past it) a frame, and their mean speed toward goal there, by the ball's zone;
# (2) RUNS: a man of ours (outfield) 0-12 m short of the line or past it who moves at their goal at
# 4+ m/s for 0.6 s+ (a run, not a drift): how many a team-match, by role, where it starts (gap), how
# far past the line it gets, how long, the ball's zone at its start, and how many end with a ball
# played to him. DFL tracking (Bassek et al. 2025, CC BY), loader as benchmarks_tracking_shoulder.py.
import collections, glob, os, re, sys, multiprocessing, statistics
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ROLE = {"IVL": 0, "IVR": 0, "IVZ": 0, "LV": 1, "RV": 1, "DML": 2, "DMR": 2, "DMZ": 2, "DLM": 2, "DRM": 2, "ZO": 3,
        "OLM": 4, "ORM": 4, "LM": 4, "RM": 4, "HL": 4, "HR": 4, "LA": 4, "RA": 4, "STL": 5, "STR": 5, "STZ": 5}
NAMES = ["CB", "FB", "DM/CM", "AM", "WIDE", "ST"]
ZN = ["0-18", "18-35", "35-52", "52+"]
def zb(btl): return 0 if btl < 18 else 1 if btl < 35 else 2 if btl < 52 else 3
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
    c = collections.Counter(); runs = []; GL = collections.defaultdict(list)
    open_run = {}   # pid -> dict
    def close(pid):
        r = open_run.pop(pid)
        if r["k"] >= 3: runs.append(r)
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        if att < 0:
            for pid in list(open_run): close(pid)
            continue
        dfd = 1 - att; g = own[(sc, dfd)]
        btl = half - bx * g; z = zb(btl)
        fr = pl.get((sc, n), {}); fp = pl.get((sc, n - 5), {})
        dl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == dfd)
        if len(dl) < 2: continue
        line = min(dl[1], btl)
        c[("n", z)] += 1
        then = ball.get((sc, n - 25))
        bm = 1 if (then is not None and (half - then[0] * g) - btl >= 2) else 0   # the ball going forward 2+ m/s over 1 s
        seen = set()
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers or pid not in fp: continue
            r = ROLE.get(pos_of.get(pid), -1)
            gap = (half - x * g) - line
            vx = ((half - fp[pid][0] * g) - (half - x * g)) / 0.2   # m/s toward their line (metres-off-line falling)
            gb = int((gap + 4) // 2)
            if r >= 0: GL[(z, r)].append(round(gap, 1))
            if 0 <= gb < 11:
                c[("k", z, gb)] += 1; c[("v", z, gb)] += vx
                if r >= 0: c[("kr", z, gb, r)] += 1
            # a run: 0-12 m short or past it, 4+ m/s at goal
            if gap < 12 and pid not in open_run and r >= 0:
                c[("el", r, bm)] += 1                      # eligible man-frames: 0-12 m short or past, not running
            if gap < 12 and vx >= 4:
                seen.add(pid)
                if pid in open_run:
                    o = open_run[pid]; o["k"] += 1; o["min_gap"] = min(o["min_gap"], gap); o["last"] = n
                else:
                    open_run[pid] = {"pid": pid, "r": r, "k": 1, "g0": gap, "min_gap": gap, "z": z, "start": n, "last": n, "sec": sc, "att": att,
                                     "bm": bm, "x0": half - fp[pid][0] * g, "y0": fp[pid][1], "x1": half - x * g, "y1": y}
                if pid in open_run: open_run[pid]["x1"] = half - x * g; open_run[pid]["y1"] = y
        for pid in list(open_run):
            if pid not in seen: close(pid)
    for pid in list(open_run): close(pid)
    return c, runs, GL
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); runs = []; GL = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, rr, gl in pool.imap_unordered(one, files):
            c.update(cc); runs += rr
            for k, v in gl.items(): GL[k] += v
    tm = 2 * len(files)
    print(f"{len(files)} DFL matches: the side IN possession against their offside line (in play, 5 Hz)")
    print("MEN BY GAP short of the line a frame (2 m bins, - = past it), count / mean speed at their goal m/s, by the ball's zone off their line")
    print("   zone    " + "  ".join(f"{-4+2*b:>3d}..{-2+2*b:<3d}" for b in range(11)))
    for z in range(4):
        n = max(1, c[("n", z)])
        print(f"   {ZN[z]:6s}  " + "  ".join(f"{c[('k',z,b)]/n:4.2f}/{c[('v',z,b)]/max(1,c[('k',z,b)]):4.1f}" for b in range(11)))
    print("   share by role in each bin (CB FB DM AM WIDE ST %), all zones:")
    for b in range(11):
        k = sum(c[("kr", z, b, r)] for z in range(4) for r in range(6))
        print(f"     {-4+2*b:>3d}..{-2+2*b:<3d} " + " ".join(f"{100*sum(c[('kr',z,b,r)] for z in range(4))/max(1,k):4.0f}" for r in range(6)))
    print("EACH ROLE's gap short of the line (- = past), p10 / p25 / median / p75 / p90, by the ball's zone:")
    for z in range(4):
        row = []
        for r in range(6):
            v = sorted(GL[(z, r)])
            if not v: continue
            qq = lambda f: v[min(len(v) - 1, int(f * len(v)))]
            row.append(f"{NAMES[r]} {qq(.1):.1f}/{qq(.25):.1f}/{qq(.5):.1f}/{qq(.75):.1f}/{qq(.9):.1f}")
        print(f"   {ZN[z]:6s} " + "  ".join(row))
    print(f"RUNS (0-12 m short or past, 4+ m/s at their goal for 0.6 s+): {len(runs)/tm:.1f} a team-match")
    for z in range(4):
        rz = [r for r in runs if r["z"] == z]
        print(f"   ball {ZN[z]:6s}: {len(rz)/tm:5.1f} a team-match")
    print("   by role a team-match: " + "  ".join(f"{NAMES[r]} {sum(1 for x in runs if x['r']==r)/tm:.1f}" for r in range(6)))
    def q(v):
        v = sorted(v); return f"median {v[len(v)//2]:5.1f}  p25 {v[len(v)//4]:5.1f}  p75 {v[3*len(v)//4]:5.1f}" if v else "-"
    print(f"   starts, m short of the line   {q([r['g0'] for r in runs])}")
    print(f"   gets to (min gap, - = past)   {q([r['min_gap'] for r in runs])}")
    print(f"   lasts, s                      {q([r['k']*0.2 for r in runs])}")
    print(f"   forward, m                    {q([r['x0']-r['x1'] for r in runs])}")
    print(f"   across |dy|, m                {q([abs(r['y1']-r['y0']) for r in runs])}")
    print(f"   inward (toward y=0), m        {q([abs(r['y0'])-abs(r['y1']) for r in runs])}")
    for bm in (0, 1):
        lab = "ball NOT going forward" if bm == 0 else "ball going forward 2+"
        print(f"   {lab}: {sum(1 for r in runs if r['bm']==bm)/tm:.1f} a team-match; starts per eligible man-second by role: " +
              "  ".join(f"{NAMES[r]} {5*sum(1 for x in runs if x['r']==r and x['bm']==bm)/max(1,c[('el',r,bm)]):.3f}" for r in range(6)))
        print(f"      eligible man-seconds a team-match: " + "  ".join(f"{NAMES[r]} {c[('el',r,bm)]/5/tm:.0f}" for r in range(6)))
        rb = [r for r in runs if r["bm"] == bm]
        print(f"      starts {q([r['g0'] for r in rb])};  gets to {q([r['min_gap'] for r in rb])}")
        print(f"      lasts {q([r['k']*0.2 for r in rb])};  forward {q([r['x0']-r['x1'] for r in rb])};  past the line {100*sum(1 for r in rb if r['min_gap']<0)/max(1,len(rb)):.0f}%")
        for r in (3, 4, 5):
            rr = [x for x in rb if x["r"] == r]
            print(f"      {NAMES[r]}: starts {q([x['g0'] for x in rr])};  gets to {q([x['min_gap'] for x in rr])}")
    print(f"   past the line at some point   {100*sum(1 for r in runs if r['min_gap']<0)/max(1,len(runs)):.0f}%")

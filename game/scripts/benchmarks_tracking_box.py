#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_box.py (G5.26, DESIGN §8.124) — usage: <DFL dir>
# Real: who is in the box. The side in possession (BallPossession, in play, 5 Hz), by the ball's
# zone (the pass policy's grid; §8.141 adds their offside line and our most advanced man: their line 0-18 / 18-35 / 35-52 m × centre |y| < 20.16 or wide):
# its outfielders in the zone 0-18 m centre (the box's width) — mean count, the share of frames
# with 0 / 1 / 2 / 3+, the mean count by role, and where they stand (mean metres off the line,
# mean |y|, mean y toward the ball's side); the same for the 0-18 wide channels.
# DFL tracking (Bassek et al. 2025, CC BY); loader as benchmarks_tracking_channel.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
EDGES = (18, 35, 52, 70)
ROLE = {"IVL": "CB", "IVR": "CB", "IVZ": "CB", "LV": "FB", "RV": "FB", "DML": "DM/CM", "DMR": "DM/CM", "DMZ": "DM/CM",
        "DLM": "DM/CM", "DRM": "DM/CM", "ZO": "AM", "OLM": "WIDE", "ORM": "WIDE", "LM": "WIDE", "RM": "WIDE", "HL": "WIDE",
        "HR": "WIDE", "LA": "WIDE", "RA": "WIDE", "STL": "ST", "STR": "ST", "STZ": "ST"}
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
                if st and st.group(1) == "1" and po and po.group(1) in "12": ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1)
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    c = collections.Counter()
    own = {}
    for sc in {k[0] for k in ball}:
        xs = {0: [], 1: []}
        for (s2, n), ps in pl.items():
            if s2 != sc or n % 250: continue
            for pid, p in ps.items():
                if pid in keepers: xs[who[pid]].append(p[0])
        for tm in (0, 1): own[(sc, tm)] = -1 if (sum(xs[tm]) / max(1, len(xs[tm]))) < 0 else 1
    for (sc, n), (bx, by, att) in ball.items():
        g = -own[(sc, att)]
        btl = half - bx * g
        if btl >= 52:
            continue
        bz = (0 if btl < 18 else 1 if btl < 35 else 2) * 2 + (0 if abs(by) < 20.16 else 1)
        fr = pl.get((sc, n), {})
        c[("f", bz)] += 1
        inbox = 0
        dtl = sorted(half - x * g for pid, (x, y) in fr.items() if who.get(pid) == 1 - att)   # the defenders off their own line (keeper in)
        atl = [half - x * g for pid, (x, y) in fr.items() if who.get(pid) == att and pid not in keepers]
        if len(dtl) >= 2 and atl:   # §8.141: their offside line and our most advanced man
            c[("ln", bz)] += dtl[1]; c[("Lq", bz, min(60, int(min(dtl[1], btl))))] += 1   # G5.52: the line's spread c[("lead", bz)] += min(atl); c[("lnn", bz)] += 1
            dout = sorted((half - x * g, pid) for pid, (x, y) in fr.items() if who.get(pid) == 1 - att and pid not in keepers)
            cbs = [d for d, pid in dout if ROLE.get(pos_of.get(pid, "")) == "CB"]
            if dout and cbs:   # cover: the deepest outfielder against his CBs' mean, and who he is
                c[("deep", bz)] += dout[0][0]; c[("cbm", bz)] += sum(cbs) / len(cbs); c[("dn", bz)] += 1
                c[("drole", bz, ROLE.get(pos_of.get(dout[0][1], ""), "?"))] += 1
                c[("gap2", bz)] += dout[1][0] - dout[0][0]
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers:
                continue
            tl = half - x * g
            if tl >= 18:
                continue
            if abs(y) < 20.16:
                inbox += 1
                if len(dtl) >= 2:   # G5.52: in the box and past their offside line (an offside position) — and by how far
                    L = min(dtl[1], btl)
                    if tl < L: c[("past", bz)] += 1; c[("pastm", bz)] += L - tl
                    c[("Lin", bz)] += L
                c[("role", bz, ROLE.get(pos_of.get(pid, ""), "?"))] += 1
                c[("d", bz)] += tl; c[("ay", bz)] += abs(y); c[("ys", bz)] += y * (1 if by >= 0 else -1); c[("np", bz)] += 1
            else:
                c[("wide", bz)] += 1
                c[("chrole", bz, ROLE.get(pos_of.get(pid, ""), "?"))] += 1   # G5.56: who stands in their wide channels
                c[("chys", bz)] += 1 if (y > 0) == (by > 0) else 0           # on the ball's side
                c[("chd", bz)] += tl; c[("chay", bz)] += abs(y)
                if len(dtl) >= 2: c[("chL", bz, 1 if min(dtl[1], btl) < 16 else 0)] += 1
        c[("k", bz, min(inbox, 3))] += 1
        if len(dtl) >= 2:   # G5.53: the same shares split by their line inside 16 m or not
            dp = 1 if min(dtl[1], btl) < 16 else 0
            c[("kL", bz, dp, min(inbox, 3))] += 1; c[("fL", bz, dp)] += 1; c[("nL", bz, dp)] += inbox
    return c


files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files):
        c.update(r)
names = ("0-18 centre", "0-18 wide", "18-35 centre", "18-35 wide", "35-52 centre", "35-52 wide")
print(f"{len(files)} DFL matches: the side in possession's outfielders in the box zone (0-18 m, |y| < 20.16), by the ball's zone")
for bz, nm in enumerate(names):
    f = c[("f", bz)]
    if not f:
        continue
    np_ = c[("np", bz)]
    roles = sorted({k[2] for k in c if isinstance(k, tuple) and k[0] == "role" and k[1] == bz})
    print(f"   ball {nm:12s} frames {f:6d}: in the box {np_ / f:.2f} (0 {100*c[('k',bz,0)]/f:.0f}% 1 {100*c[('k',bz,1)]/f:.0f}% 2 {100*c[('k',bz,2)]/f:.0f}% 3+ {100*c[('k',bz,3)]/f:.0f}%), in the wide channels {c[('wide',bz)]/f:.2f}; "
          f"stand {c[('d',bz)]/max(1,np_):.1f} m off the line, |y| {c[('ay',bz)]/max(1,np_):.1f}, ball side {c[('ys',bz)]/max(1,np_):+.1f}; by role: "
          + " ".join(f"{r} {c[('role',bz,r)]/f:.2f}" for r in roles))
    ln = max(1, c[("lnn", bz)])
    if np_: print(f"      in the box: past their offside line {100*c[('past',bz)]/np_:.0f}% of them (by {c[('pastm',bz)]/max(1,c[('past',bz)]):.1f} m); their line {c[('Lin',bz)]/np_:.1f} m off their goal on those frames (G5.52)")
    wn = c[("wide", bz)]
    if wn:
        rr = sorted({k[2] for k in c if k[0] == "chrole" and k[1] == bz})
        print(f"      wide channels (G5.56): {wn/f:.2f} a frame, ball's side {100*c[('chys',bz)]/wn:.0f}%, by role " + " ".join(f"{r} {c[('chrole',bz,r)]/f:.3f}" for r in rr) +
              f"; stand {c[('chd',bz)]/wn:.1f} m off the line, |y| {c[('chay',bz)]/wn:.1f}; with the line inside 16 m {c[('chL',bz,1)]/max(1,c[('fL',bz,1)]):.2f} a frame, 16+ {c[('chL',bz,0)]/max(1,c[('fL',bz,0)]):.2f}")
    for dp, lab in ((1, "line inside 16 m"), (0, "line 16+ m")):
        fl = c[("fL", bz, dp)]
        if fl: print(f"      {lab}: {100*fl/max(1,f):.0f}% of frames, in the box {c[('nL',bz,dp)]/fl:.2f}, 0 / 1 / 2 / 3+ " + " / ".join(f"{1000*c[('kL',bz,dp,k)]/fl:.0f}" for k in range(4)) + " permille (G5.53)")
    lq = [(m, c[("Lq", bz, m)]) for m in range(61)]; tot = sum(k for _, k in lq)
    def lqq(f):
        acc = 0
        for m, k in lq:
            acc += k
            if acc >= f * tot: return m
        return 60
    if tot: print(f"      their line (min with the ball) p10 / p25 / p50 / p75 / p90: {lqq(.1)} / {lqq(.25)} / {lqq(.5)} / {lqq(.75)} / {lqq(.9)} m; inside 16 m {100*sum(k for m, k in lq if m < 16)/tot:.0f}% (G5.52)")
    print(f"      their offside line (second-last, keeper in) {c[('ln',bz)]/ln:.1f} m off their line; our most advanced outfielder {c[('lead',bz)]/ln:.1f} m")
    dn = max(1, c[("dn", bz)]); dr = sorted({k[2] for k in c if isinstance(k, tuple) and k[0] == "drole" and k[1] == bz})
    print(f"      their deepest outfielder {c[('deep',bz)]/dn:.1f} m, their CBs' mean {c[('cbm',bz)]/dn:.1f} m, next man {c[('gap2',bz)]/dn:.1f} m higher; deepest by role: "
          + " ".join(f"{r} {100*c[('drole',bz,r)]/dn:.0f}%" for r in dr))

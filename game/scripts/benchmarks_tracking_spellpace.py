#!/usr/bin/env python3
"""benchmarks_tracking_spellpace.py — how fast the man on the ball moves through his spell (G5.131,
game/DESIGN.md §8.232), on real tracking.

    python3 -I game/scripts/benchmarks_tracking_spellpace.py <dfl dir>

The man on the ball = the in-possession side's nearest outfielder to the ball within 2 m, 5 Hz, ball in
play (a gap of one frame allowed; benchmarks_tracking_pressure.py's cut). Spells 0.6 s+. His speed (0.2 s
displacement) by time since the spell began (0, 0.2 .. 2.0 s) and by time before it ended (-0.2 .. -1.0 s),
and by the spell's length band (0.6-1.2 / 1.2-2 / 2-3 / 3-5 s): net metres start to end, mean speed.

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches of 2022/23, TRACAB positions; loader as benchmarks_tracking_box.py).
"""
import collections, glob, math, multiprocessing, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt


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
                if st and st.group(1) == "1" and po and po.group(1) in "12": ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1)
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
    c = collections.Counter()
    c["matches"] = 1
    spells = []; cur = None
    for key in sorted(ball):
        sc, n = key
        bx, by, att = ball[key]
        fr = pl.get(key, {})
        best = None
        for pid, (x, y) in fr.items():
            if who.get(pid) != att or pid in keepers: continue
            dd = math.hypot(x - bx, y - by)
            if dd < 2 and (best is None or dd < best[0]): best = (dd, pid)
        if best is None:
            if cur and n - cur["last"] > 5: spells.append(cur); cur = None
            continue
        car = best[1]
        fb = pl.get((sc, n - 5), {})
        for pid, (x, y) in fr.items():   # §8.237 OFF THE BALL: the side on the ball's other outfielders, 0.2 s speed
            if who.get(pid) != att or pid in keepers or pid == car or pid not in fb: continue
            v = math.hypot(x - fb[pid][0], y - fb[pid][1]) / 0.2
            c[("ob", 0 if v < 1 else 1 if v < 2 else 2 if v < 4 else 3)] += 1
        if not cur or cur["car"] != car or n - cur["last"] > 10 or sc != cur["sc"]:
            if cur: spells.append(cur)
            cur = {"car": car, "sc": sc, "last": n, "pos": []}
        cur["last"] = n; cur["pos"].append((n, fr[car]))
    if cur: spells.append(cur)
    prev = None
    for sp in spells:
        p = sp["pos"]
        # G5.133 (§8.234): how it came to him — a mate's spell ended within 3 s before (a pass received)
        # or not (won / loose) — and his speed over the second before (0.2 s steps, -1.0 .. 0 s).
        got = 1 if prev and prev["sc"] == sp["sc"] and who.get(prev["car"]) == who.get(sp["car"]) and prev["car"] != sp["car"] and 0 < p[0][0] - prev["last"] <= 75 else 0
        if got: plen = math.hypot(prev["pos"][-1][1][0] - p[0][1][0], prev["pos"][-1][1][1] - p[0][1][1]); ft = (p[0][0] - prev["last"]) / 25.0
        rel_v = None
        if got:   # §8.237: the receiver at the release — his 0.2 s speed and the part of it away from the passer
            r = prev["last"]; q1 = pl.get((sp["sc"], r), {}).get(sp["car"]); q0 = pl.get((sp["sc"], r - 5), {}).get(sp["car"]); pp = prev["pos"][-1][1]
            if q1 and q0:
                dx, dy = q1[0] - pp[0], q1[1] - pp[1]; dl = math.hypot(dx, dy) or 1.0
                rel_v = (math.hypot(q1[0] - q0[0], q1[1] - q0[1]) / 0.2, ((q1[0] - q0[0]) * dx + (q1[1] - q0[1]) * dy) / dl / 0.2)
            fa = pl.get((sp["sc"], r), {}); fz = pl.get((sp["sc"], r - 5), {})   # §8.237 PICK BY PACE: every mate of the passer at the release, by his 0.2 s speed
            if q1 and q0:
                bnd = lambda v: 0 if v < 1 else 1 if v < 2 else 2 if v < 4 else 3
                for pid, xy in fa.items():
                    if who.get(pid) != who.get(sp["car"]) or pid in keepers or pid == prev["car"] or pid not in fz: continue
                    c[("pa", bnd(math.hypot(xy[0] - fz[pid][0], xy[1] - fz[pid][1]) / 0.2))] += 1
                c[("pp", bnd(math.hypot(q1[0] - q0[0], q1[1] - q0[1]) / 0.2))] += 1
            fl = []   # §8.237 THROUGH THE FLIGHT: his 0.2 s speed at 0 / 25 / 50 / 75 / 100% of it (5 Hz frames)
            for f in (0, 0.25, 0.5, 0.75, 1.0):
                m = r + int(round(f * (p[0][0] - r) / 5)) * 5; a1 = pl.get((sp["sc"], m), {}).get(sp["car"]); a0 = pl.get((sp["sc"], m - 5), {}).get(sp["car"])
                fl.append(math.hypot(a1[0] - a0[0], a1[1] - a0[1]) / 0.2 if a1 and a0 else None)
            if all(v is not None for v in fl): rel_v = (rel_v or (0, 0)) + tuple(fl) if rel_v else None
        prev = sp
        if len(p) < 4: continue
        n0 = p[0][0]; ap = [pl.get((sp["sc"], n0 - 5 * k), {}).get(sp["car"]) for k in range(6)]
        if all(ap):
            for k in range(5): c[("pre", got, k)] += math.hypot(ap[k][0] - ap[k + 1][0], ap[k][1] - ap[k + 1][1]) / 0.2; c[("pre_n", got, k)] += 1
            e = math.hypot(p[1][1][0] - p[0][1][0], p[1][1][1] - p[0][1][1]) / ((p[1][0] - p[0][0]) / 25.0)
            c[("got", got)] += 1; c[("got_v", got)] += e; c[("got_slow", got)] += e < 2
            vin = math.hypot(ap[0][0] - ap[1][0], ap[0][1] - ap[1][1]) / 0.2; ib = 0 if vin < 1 else 1 if vin < 4 else 2
            c[("ib", got, ib)] += 1
            if got: c[("iblen", ib)] += plen; c[("ibft", ib)] += ft; c[("lh", ib, min(7, int(plen / 5)))] += 1   # §8.236 received pass length, 5 m bands
            if got and rel_v and len(rel_v) == 7:
                for q in range(5): c[("fl", ib, q)] += rel_v[2 + q]; c[("fl_s", ib, q)] += rel_v[2 + q] < 1
                c[("fl_n", ib)] += 1
            if got and rel_v: c[("rv_n", ib)] += 1; c[("rv", ib)] += rel_v[0]; c[("rv_away", ib)] += rel_v[1]; c[("rv_still", ib)] += rel_v[0] < 1; c[("rv_n", 3)] += 1; c[("rv", 3)] += rel_v[0]; c[("rv_away", 3)] += rel_v[1]; c[("rv_still", 3)] += rel_v[0] < 1
            c[("hin", got, min(6, int(math.hypot(ap[0][0] - ap[1][0], ap[0][1] - ap[1][1]) / 0.2)))] += 1; c[("hf0", got, min(6, int(e)))] += 1
        dur = (p[-1][0] - p[0][0]) / 25.0
        sv = [math.hypot(p[i][1][0] - p[i - 1][1][0], p[i][1][1] - p[i - 1][1][1]) / ((p[i][0] - p[i - 1][0]) / 25.0) for i in range(1, len(p))]
        for i, v in enumerate(sv[:10]): c[("since", i)] += v; c[("since_n", i)] += 1
        for v in sv[5:]: c[("vb", min(7, int(v)))] += 1   # settled pace: 1.0 s+ into the spell, 1 m/s bands
        if len(sv) >= 8:   # per spell (1.6 s+): his settled pace (mean 1.0 s+ in) by the pace he got it at (first 0.4 s)
            sp_v = sum(sv[5:]) / len(sv[5:]); e = (sv[0] + sv[1]) / 2; eb = 0 if e < 2 else 1 if e < 4 else 2
            c[("pse", eb, min(14, int(sp_v * 2)))] += 1;
            c[("ps", min(14, int(sp_v * 2)))] += 1; c[("pe_n", eb)] += 1; c[("pe_v", eb)] += sp_v
        for i, v in enumerate(reversed(sv[-5:])): c[("before", i)] += v; c[("before_n", i)] += 1
        b = 0 if dur < 1.2 else 1 if dur < 2 else 2 if dur < 3 else 3 if dur < 5 else -1
        if b < 0: continue
        c[("n", b)] += 1; c[("net", b)] += math.hypot(p[-1][1][0] - p[0][1][0], p[-1][1][1] - p[0][1][1]); c[("dur", b)] += dur
        c[("path", b)] += sum(math.hypot(p[i][1][0] - p[i - 1][1][0], p[i][1][1] - p[i - 1][1][1]) for i in range(1, len(p)))
    return c


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files):
            c.update(r)
    tm = 2 * c["matches"]
    print(f"{c['matches']} DFL matches; spells 0.6 s+ of the man on the ball")
    print("  speed m/s by s since the spell began: " + " ".join(f"{0.2*(i+1):.1f} {c[('since', i)]/max(1,c[('since_n', i)]):.2f}" for i in range(10)))
    print("  speed m/s by s before it ended:       " + " ".join(f"-{0.2*i:.1f} {c[('before', i)]/max(1,c[('before_n', i)]):.2f}" for i in range(5)))
    vt = max(1, sum(c[("vb", q)] for q in range(8)))
    print("  settled pace (1 s+ into the spell), % of 5 Hz frames by m/s 0-1..7+: " + " ".join(f"{q} {100*c[('vb', q)]/vt:.1f}" for q in range(8)))
    pt = max(1, sum(c[("ps", q)] for q in range(15)))
    print("  per spell 1.6 s+ (%d): settled pace %% by 0.5 m/s band 0..7+: " % pt + " ".join(f"{q/2:.1f} {100*c[('ps', q)]/pt:.1f}" for q in range(15)))
    for b, lab in enumerate(["0-2", "2-4", "4+"]):
        n = max(1, c[("pe_n", b)])
        print(f"  per spell, got it at {lab} m/s, settled pace permille by 0.5 m/s band 0..7+: " + ", ".join(f"{round(1000*c[('pse', b, q)]/n)}" for q in range(15)))
    print("  per spell: settled pace by pace got it at 0-2 / 2-4 / 4+ m/s: " + " / ".join(f"{c[('pe_v', b)]/max(1,c[('pe_n', b)]):.2f} ({100*c[('pe_n', b)]/pt:.0f}%)" for b in range(3)))
    for g, lab in enumerate(["won / loose", "pass received"]):
        n = max(1, c[("got", g)])
        print(f"  how it came, {lab}: {c[('got', g)]/tm:.1f} a team-match; his speed before (s -1.0 .. -0.2 .. 0): " + " ".join(f"{-0.2*k:.1f} {c[('pre', g, k)]/max(1,c[('pre_n', g, k)]):.2f}" for k in reversed(range(5))) + f" | first 0.2 s {c[('got_v', g)]/n:.2f}, under 2 m/s {100*c[('got_slow', g)]/n:.0f}%")
        print("    " + " ".join(f"in {lab2} {100*c[('ib', g, ib)]/n:.0f}%" + (f" pass {c[('iblen', ib)]/max(1,c[('ib', g, ib)]):.1f} m flight {c[('ibft', ib)]/max(1,c[('ib', g, ib)]):.2f} s;" if g else ";") for ib, lab2 in enumerate(["<1", "1-4", "4+"])))
        if g:
            for ib, lab2 in enumerate(["<1", "1-4", "4+"]):
                nb = max(1, c[("ib", g, ib)])
                print(f"    in {lab2}: pass length % by 5 m band 0-5..35+: " + " ".join(f"{100*c[('lh', ib, q)]/nb:.1f}" for q in range(8)))
        print(f"    % by m/s 0-1..6+, into it (window ending 0): " + " ".join(f"{100*c[('hin', g, q)]/n:.1f}" for q in range(7)) + " | first 0.2 s: " + " ".join(f"{100*c[('hf0', g, q)]/n:.1f}" for q in range(7)))
    obt = max(1, sum(c[("ob", q)] for q in range(4)))
    print("  OFF THE BALL (§8.237; the side on the ball's other outfielders, 5 Hz frames): % by m/s <1 / 1-2 / 2-4 / 4+: " + " / ".join(f"{100*c[('ob', q)]/obt:.1f}" for q in range(4)))
    pat = max(1, sum(c[("pa", q)] for q in range(4))); ppt = max(1, sum(c[("pp", q)] for q in range(4)))
    print("  PICK BY PACE (§8.237): mates at the release <1 / 1-2 / 2-4 / 4+ m/s %: " + " / ".join(f"{100*c[('pa', q)]/pat:.1f}" for q in range(4)) + " | the receiver %: " + " / ".join(f"{100*c[('pp', q)]/ppt:.1f}" for q in range(4)) + " | lift: " + " / ".join(f"{(c[('pp', q)]/ppt)/max(1e-9, c[('pa', q)]/pat):.2f}" for q in range(4)))
    print("  THROUGH THE FLIGHT (§8.237): his m/s (under 1 %) at 0 / 25 / 50 / 75 / 100% of it — " + "; ".join(f"{lab2} " + " ".join(f"{c[('fl', ib, q)]/max(1,c[('fl_n', ib)]):.2f} ({100*c[('fl_s', ib, q)]/max(1,c[('fl_n', ib)]):.0f})" for q in range(5)) for ib, lab2 in enumerate(["in <1", "in 1-4", "in 4+"])))
    print("  THE RECEIVER AT THE RELEASE (§8.237): mean m/s, under 1 m/s %, away from the passer m/s — " + "; ".join(f"{lab2} {c[('rv', ib)]/max(1,c[('rv_n', ib)]):.2f}, {100*c[('rv_still', ib)]/max(1,c[('rv_n', ib)]):.0f}%, {c[('rv_away', ib)]/max(1,c[('rv_n', ib)]):+.2f}" for ib, lab2 in enumerate(["in <1", "in 1-4", "in 4+", "all"])))
    for b, lab in enumerate(["0.6-1.2", "1.2-2", "2-3", "3-5"]):
        n = max(1, c[("n", b)])
        print(f"  {lab:7s} s: {c[('n', b)]/tm:5.1f} a team-match | net {c[('net', b)]/n:4.1f} m | path {c[('path', b)]/n:4.1f} m | mean speed {c[('path', b)]/max(1e-9, c[('dur', b)]):.2f} m/s")

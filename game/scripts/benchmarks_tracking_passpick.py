#!/usr/bin/env python3
"""benchmarks_tracking_passpick.py (G5.74, DESIGN §8.175) — which man in a zone a pass is for.

    python3 -I game/scripts/benchmarks_tracking_passpick.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data
owner DFL (7 matches of 2022/23, TRACAB positions + official events). Open-play passes that
name a Recipient. At the kick (event time, the 25 Hz frame), on the pass policy's grid (their
line 0-18 / 18-35 / 35-52 / 52-70 / 70+ m x centre |y| < 20.16 or wide, wide = both flanks),
the Recipient's zone and every mate of the passer's standing in it.

The chooser (Possession, G5.17+) gives a zone its real share and splits it evenly among the mates
standing there. This asks whether the split is even:
  - with k >= 2 mates in the Recipient's zone, how often he is the nearest of them (even: 1/k);
  - a wide passer's pass into a wide zone with a mate on each flank: his own flank or the far one;
  - the split ~ exp(-d / lambda), d = passer to man: lambda by maximum likelihood over the zones
    with 2+ mates, by the passer's metres off his own goal 0-35 / 35-70 / 70+ (inf = even).
FH original.
"""
import collections, datetime, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt

LAMS = (4, 6, 8, 10, 12, 15, 18, 22, 27, 33, 40, 50, 65, 80, 100, 1e9)


def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)


def one(ev_path):
    d = os.path.dirname(ev_path); mid = ev_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    pos_path = ev_path.replace("03_02_events_raw", "04_03_positions_raw_observed")
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    half = length / 2
    passes = []
    txt = open(ev_path, encoding="utf8").read()
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<Play ([^>]*)>\s*<Pass', txt):
        a = dict(re.findall(r'(\w[\w-]*)="([^"]*)"', m.group(2)))
        if a.get("Recipient") and a.get("FromOpenPlay") == "true":
            passes.append((ms(m.group(1)) // 40, a["Player"], a["Recipient"], a["Team"]))
    want = {t for t, *_ in passes}
    fr = collections.defaultdict(dict); team = {}
    cur = None
    with open(pos_path, encoding="utf8", buffering=1 << 22) as f:
        for line in f:
            s = line.lstrip()
            if s.startswith("<Frame "):
                if cur is None: continue
                a = s.split('"'); g = ms(a[3]) // 40
                if g in want: fr[g][cur] = (float(a[5]), float(a[7]))
            elif s.startswith("<FrameSet"):
                m = re.search(r'TeamId="([^"]+)".*PersonId="([^"]+)"', s)
                if m and m.group(1).upper() != "BALL": cur = m.group(2); team[cur] = m.group(1)
                else: cur = None
    c = collections.Counter(); ll = collections.Counter()
    mk = []   # G5.83 (§8.184): per pass with 2+ mates in his zone: (receiver band, [(d, marker m, is him)])
    for t, pa, rc, tm in passes:
        F = fr.get(t, {})
        if pa not in F or rc not in F or team.get(rc) != tm: continue
        kx = [F[p][0] for p in F if p in keepers and team.get(p) == tm]
        if not kx: continue
        g = 1 if kx[0] < 0 else -1            # attacking toward +g
        def zone(x, y):
            tl = half - x * g
            b = 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4
            return b * 2 + (0 if abs(y) < 20.16 else 1)
        px, py = F[pa]
        own = half + px * g
        ob = 0 if own < 35 else 1 if own < 70 else 2
        oz = zone(px, py); ez = zone(*F[rc])
        inz = [p for p in F if team.get(p) == tm and p != pa and zone(*F[p]) == ez]
        k = len(inz)
        c[(ob, "n")] += 1
        if k < 2: continue
        dist = {p: math.hypot(F[p][0] - px, F[p][1] - py) for p in inz}
        opp = [F[q] for q in F if team.get(q) != tm and team.get(q) is not None]
        own_r = half + F[rc][0] * g
        rb = 0 if own_r < 35 else 1 if own_r < 70 else 2
        crowd = lambda p: sum(1 for q in F if team.get(q) == tm and q not in (p, pa) and q not in keepers and math.hypot(F[q][0] - F[p][0], F[q][1] - F[p][1]) < 10)
        mk.append((ob, rb, [(dist[p], min((math.hypot(F[p][0] - o[0], F[p][1] - o[1]) for o in opp), default=99), p == rc, crowd(p)) for p in inz]))
        c[(ob, "k")] += 1; c[(ob, "even")] += 1.0 / k
        if min(inz, key=lambda p: dist[p]) == rc: c[(ob, "nearest")] += 1
        c[(ob, "drc")] += dist[rc]; c[(ob, "dmean")] += sum(dist.values()) / k
        for lam in LAMS:
            den = sum(math.exp(-dist[p] / lam) for p in inz)
            ll[(ob, lam)] += -dist[rc] / lam - math.log(den)
        if oz % 2 == 1 and ez % 2 == 1:      # wide to wide: own flank or the far one
            sides = {1 if F[p][1] * py > 0 else 0 for p in inz}
            if sides == {0, 1}:
                c[(ob, "w2")] += 1
                if F[rc][1] * py > 0: c[(ob, "same")] += 1
    for k_, v in ll.items(): c[("ll",) + k_] = v
    return c, mk


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    tot = collections.Counter(); MK = []
    with multiprocessing.Pool(3) as pool:
        for c, mk in pool.imap_unordered(one, files):
            tot.update(c); MK += mk
    print(f"{len(files)} DFL matches: open-play passes naming a Recipient; his zone at the kick holding 2+ mates")
    for ob, nm in enumerate(("0-35", "35-70", "70+")):
        k = tot[(ob, "k")]
        if not k: continue
        best = max(LAMS, key=lambda l: tot[("ll", ob, l)])
        print(f"   passer {nm:5s} m off own goal: passes {tot[(ob, 'n')]:5d}, 2+ in his zone {k:5d} ({100 * k / tot[(ob, 'n')]:.0f}%): "
              f"he is the nearest {100 * tot[(ob, 'nearest')] / k:.1f}% (even {100 * tot[(ob, 'even')] / k:.1f}%), "
              f"his distance {tot[(ob, 'drc')] / k:.1f} m v the zone's mean {tot[(ob, 'dmean')] / k:.1f}; "
              f"wide to wide, both flanks held {tot[(ob, 'w2')]:.0f}: own flank {100 * tot[(ob, 'same')] / max(1, tot[(ob, 'w2')]):.1f}%; "
              f"lambda {best if best < 1e8 else 'inf'} m")
        print("      log-lik by lambda: " + " ".join(f"{l if l < 1e8 else 'inf'}:{tot[('ll', ob, l)] - tot[('ll', ob, 1e9)]:+.0f}" for l in LAMS))

    # G5.83 (§8.184) MARKED PICK: within his zone (2+ mates), the split ~ exp(-d / lambda) x lift(his nearest
    # opponent's metres, binned) — lift fitted by iterative scaling with lambda held at the passer band's best;
    # lift 1 everywhere = the distance split alone. Raw: share of receivers v share of the mates there, per bin.
    MB = (0, 2, 3.5, 5, 8, 99)
    mb = lambda x: next(i for i in range(5) if MB[i] <= x < MB[i + 1])
    best_l = {ob: max(LAMS, key=lambda l: tot[("ll", ob, l)]) for ob in range(3)}
    print("MARKED PICK (his zone holding 2+ mates; nearest opponent 0-2 / 2-3.5 / 3.5-5 / 5-8 / 8+ m), by the receiver's m off his own goal:")
    for rb, nm in enumerate(("0-35", "35-70", "70+")):
        rows = [(best_l[ob], ms_) for ob, r, ms_ in MK if r == rb]
        if not rows: continue
        av = [0] * 5; pk = [0] * 5
        for _, ms_ in rows:
            for d, m, isr, _cr in ms_:
                av[mb(m)] += 1; pk[mb(m)] += isr
        lift = [1.0] * 5
        for _ in range(50):
            exp_ = [0.0] * 5
            for lam, ms_ in rows:
                w = [math.exp(-d / lam if lam < 1e8 else 0) * lift[mb(m)] for d, m, _, _cr in ms_]
                sw = sum(w)
                for (d, m, _, _cr), wi in zip(ms_, w): exp_[mb(m)] += wi / sw
            lift = [lift[i] * pk[i] / exp_[i] if exp_[i] > 0 and pk[i] > 0 else lift[i] for i in range(5)]
            ref = lift[4]; lift = [x / ref for x in lift]
        ll0 = ll1 = 0.0
        for lam, ms_ in rows:
            w0 = [math.exp(-d / lam if lam < 1e8 else 0) for d, m, _, _cr in ms_]
            w1 = [w0[i] * lift[mb(ms_[i][1])] for i in range(len(ms_))]
            i = next(i for i, x in enumerate(ms_) if x[2])
            ll0 += math.log(w0[i] / sum(w0)); ll1 += math.log(w1[i] / sum(w1))
        n = len(rows)
        print(f"   receiver {nm:5s}: passes {n:5d} | mates per bin % " + " / ".join(f"{100 * a / sum(av):.0f}" for a in av)
              + " | receivers % " + " / ".join(f"{100 * x / n:.0f}" for x in pk)
              + " | lift (8+ = 1) " + " / ".join(f"{x:.2f}" for x in lift) + f" | log-lik gain {ll1 - ll0:+.0f}")

    # G5.117 (§8.218) CROWD PICK: the same split x lift(his own mates within 10 m, passer and keepers out: 0 / 1 / 2+),
    # both lifts fitted together by iterative scaling (crowd 0 = 1, marker 8+ = 1). Real passers pick the
    # loneliest free option 72-89% (benchmarks_tracking_flight.py THE PICK).
    print("CROWD PICK (his zone holding 2+ mates; his own mates within 10 m 0 / 1 / 2+, with the marker lift refitted alongside), by the receiver's m off his own goal:")
    cb = lambda k: min(2, k)
    for rb, nm in enumerate(("0-35", "35-70", "70+")):
        rows = [(best_l[ob], ms_) for ob, r, ms_ in MK if r == rb]
        if not rows: continue
        av = [0] * 3; pk = [0] * 3; avm = [0] * 5; pkm = [0] * 5
        for _, ms_ in rows:
            for d, m, isr, cr in ms_:
                av[cb(cr)] += 1; pk[cb(cr)] += isr; pkm[mb(m)] += isr
        lm = [1.0] * 5; lc = [1.0] * 3
        def wts(lam, ms_): return [math.exp(-d / lam if lam < 1e8 else 0) * lm[mb(m)] * lc[cb(cr)] for d, m, _, cr in ms_]
        for _ in range(80):
            for which in (0, 1):
                em = [0.0] * 5; ec = [0.0] * 3
                for lam, ms_ in rows:
                    w = wts(lam, ms_); sw = sum(w)
                    for (d, m, _, cr), wi in zip(ms_, w): em[mb(m)] += wi / sw; ec[cb(cr)] += wi / sw
                if which == 0:
                    lm = [lm[i] * pkm[i] / em[i] if em[i] > 0 and pkm[i] > 0 else lm[i] for i in range(5)]; r0 = lm[4]; lm = [x / r0 for x in lm]
                else:
                    lc = [lc[i] * pk[i] / ec[i] if ec[i] > 0 and pk[i] > 0 else lc[i] for i in range(3)]; r0 = lc[0]; lc = [x / r0 for x in lc]
        llc = 0.0
        for lam, ms_ in rows:
            w1 = wts(lam, ms_); i = next(i for i, x in enumerate(ms_) if x[2]); llc += math.log(w1[i] / sum(w1))
        n = len(rows)
        print(f"   receiver {nm:5s}: passes {n:5d} | mates per bin % " + " / ".join(f"{100 * a / sum(av):.0f}" for a in av)
              + " | receivers % " + " / ".join(f"{100 * x / n:.0f}" for x in pk)
              + " | crowd lift (0 = 1) " + " / ".join(f"{x:.2f}" for x in lc) + " | marker lift (8+ = 1) " + " / ".join(f"{x:.2f}" for x in lm) + f" | log-lik {llc:.0f}")


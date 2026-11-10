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
    return c


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    tot = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for c in pool.imap_unordered(one, files):
            tot.update(c)
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

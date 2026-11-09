#!/usr/bin/env python3
"""benchmarks_tracking_passzone.py (G5.59, DESIGN §8.160) — where a pass from a zone goes,
by which zones hold a mate at the kick.

    python3 -I game/scripts/benchmarks_tracking_passzone.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data
owner DFL (7 matches of 2022/23, TRACAB positions + official events). Open-play passes that
name a Recipient (completed ones, and those unsuccessful ones the operator names a man for).
At the kick (event time, the 25 Hz frame) the passer's zone, the Recipient's zone and every
mate's zone on the pass policy's grid (their line 0-18 / 18-35 / 35-52 / 52-70 / 70+ m ×
centre |y| < 20.16 or wide). This is fh-game-match's chooser read: a pass is for a man, and
his zone is where he stands as it is played. Per origin zone: the share to forward / level /
back bands (level split into the passer's own zone and the other), split by whether the
passer's own zone holds another mate.
"""
import collections, datetime, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt

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
            passes.append((ms(m.group(1)) // 40, a["Player"], a["Recipient"], a["Team"], a.get("Evaluation", "")))
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
    c = collections.Counter()
    for t, pa, rc, tm, ev in passes:
        F = fr.get(t, {})
        if pa not in F or rc not in F: continue
        kx = [F[p][0] for p in F if p in keepers and team.get(p) == tm]
        if not kx: continue
        g = -1 if kx[0] < 0 else 1            # attacking toward -sign(own keeper's x)
        g = -g
        def zone(x, y):
            tl = half - x * g
            b = 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4
            return b * 2 + (0 if abs(y) < 20.16 else 1)
        oz = zone(*F[pa]); ez = zone(*F[rc])
        mates = [zone(*F[p]) for p in F if team.get(p) == tm and p != pa and p not in keepers]
        own = 1 if oz in mates else 0
        occ = tuple(1 if z in mates or (z == ez) else 0 for z in range(10))   # the chooser's in_zone (the Recipient always counts)
        c[("occ", oz, ez, occ)] += 1
        cat = "fwd" if ez // 2 < oz // 2 else "back" if ez // 2 > oz // 2 else ("own" if ez == oz else "lvl")
        for k in ("all", own):
            c[(oz, k, cat)] += 1; c[(oz, k, "n")] += 1
            c[(oz, k, "ez", ez)] += 1
            if ev == "successfullyCompleted": c[(oz, k, "ok")] += 1
    return c

def fit(tot, oz, iters=200):
    """The chooser's weights for origin zone oz: pi[ez] such that picking an occupied zone with
    probability pi[ez] / sum(pi over occupied zones), over the real frames, gives the real
    Recipient zones (iterative proportional fit). Returns pi normalised to sum 1, and n."""
    rows = [(k[2], k[3], v) for k, v in tot.items() if isinstance(k, tuple) and k[0] == "occ" and k[1] == oz]
    n = sum(v for _, _, v in rows)
    obs = [sum(v for ez, _, v in rows if ez == z) / max(1, n) for z in range(10)]
    pi = [max(o, 1e-4) for o in obs]
    for _ in range(iters):
        pred = [0.0] * 10
        for ez, occ, v in rows:
            den = sum(pi[z] for z in range(10) if occ[z])
            for z in range(10):
                if occ[z]: pred[z] += v * pi[z] / den
        pi = [pi[z] * (obs[z] / (pred[z] / n)) if pred[z] > 0 and obs[z] > 0 else pi[z] for z in range(10)]
        sm = sum(pi); pi = [x / sm for x in pi]
    return pi, obs, n

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    tot = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for c in pool.imap_unordered(one, files):
            tot.update(c)
    names = [f"{b} {w}" for b in ("0-18", "18-35", "35-52", "52-70", "70+") for w in ("centre", "wide")]
    print(f"{len(files)} DFL matches: open-play passes naming a Recipient, by the passer's zone; the Recipient's zone at the kick")
    for oz in range(10):
        for k, lab in (("all", "all"), (1, "own zone held"), (0, "own zone empty")):
            n = tot[(oz, k, "n")]
            if n < 20: continue
            print(f"   from {names[oz]:12s} {lab:15s} n {n:5d} ({100*n/max(1,tot[(oz,'all','n')]):3.0f}%): fwd {100*tot[(oz,k,'fwd')]/n:4.1f}  own {100*tot[(oz,k,'own')]/n:4.1f}  "
                  f"level other {100*tot[(oz,k,'lvl')]/n:4.1f}  back {100*tot[(oz,k,'back')]/n:4.1f}  completed {100*tot[(oz,k,'ok')]/n:4.1f}%  | "
                  + " ".join(f"{names[ez]} {100*tot[(oz,k,'ez',ez)]/n:.1f}" for ez in range(10) if tot[(oz, k, "ez", ez)]))
    print("\n   THE CHOOSER'S WEIGHTS WHEN OCCUPIED (fit) v the share of passes, per mille; kappa = fit / share, scaled so the cells with 10+ passes pool to 1000 (the rest 1000)")
    kap = []
    for oz in range(10):
        pi, obs, n = fit(tot, oz)
        rel = [ez for ez in range(10) if obs[ez] * n >= 10]
        scale = sum(obs[z] for z in rel) / max(1e-9, sum(pi[z] for z in rel))   # kappa 1 = the reliable cells' pooled ratio
        row = []
        for ez in range(10):
            k = pi[ez] / obs[ez] * scale if ez in rel else 1.0
            row.append(int(round(1000 * min(4.0, max(0.25, k)))))
        kap.append(row)
        print(f"   from {names[oz]:12s} n {n:5d}: " + " ".join(f"{names[ez]} {1000*pi[ez]:.0f}/{1000*obs[ez]:.0f} k{row[ez]}" for ez in range(10) if obs[ez] > 0))
    print("   kKappa = {" + ", ".join("{" + ", ".join(str(v) for v in r) + "}" for r in kap) + "}")

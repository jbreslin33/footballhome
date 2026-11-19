#!/usr/bin/env python3
"""benchmarks_tracking_widepace.py — "make the pitch big": how fast the wide men go to their touchline when their side
gets the ball (G5.169, game/DESIGN.md §8.275).

    python3 -I game/scripts/benchmarks_tracking_widepace.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB positions at 5 Hz; loader as benchmarks_tracking_spellpace.py). A spell = consecutive in-play frames with
one BallPossession side (a dead ball ends it); "won" = the frame before it was the other side's in play, else "restart".
For each FB / WIDE / DM-CM of the side on the ball (DFL PlayingPosition as benchmarks_tracking_runs): his m off the
touchline his side of the pitch at the spell's start (d0), at 1 / 2 / 3 / 5 / 8 s on, and his speed toward it (1 s
displacement). The men who start 10 m+ off and reach 5 m inside the spell: the time it took and the mean pace across.

§8.274 put one man a spell on the line at the real share, but ours walk there (G5.137 hold_walk) and the spell ends
first. This is the real pace before any change.
"""
import collections, glob, math, multiprocessing, os, re, statistics, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES

TS = (1, 2, 3, 5, 8)


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    info = open(info_p, encoding="utf8").read()
    hy = float(re.search(r'PitchY="([\d.]+)"', info).group(1)) / 2
    half = length / 2; team_of = {home: 0, guest: 1}
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', info))
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
                live = st and st.group(1) == "1" and po and po.group(1) in "12"
                ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1) if live else None
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
    # spells
    spells = []; sp = None; prev = None
    for key in sorted(ball):
        b = ball[key]
        if b is None or sp is None or b[2] != sp["tm"] or key[0] != sp["sc"] or key[1] - sp["n1"] > 5:
            if sp: spells.append(sp)
            sp = None
            if b is not None:
                won = prev is not None and prev[0] == key[0] and key[1] - prev[1] <= 5 and ball[prev] is not None and ball[prev][2] != b[2]
                sp = {"tm": b[2], "sc": key[0], "n0": key[1], "n1": key[1], "won": won, "b0": b}
        else:
            sp["n1"] = key[1]
        prev = key
    if sp: spells.append(sp)
    c = collections.Counter(); L = collections.defaultdict(list)
    c["matches"] = 1
    for sp in spells:
        dur = (sp["n1"] - sp["n0"]) / 25.0
        L[("dur", sp["won"])].append(dur)
        if dur < 1: continue
        sc, tm, n0 = sp["sc"], sp["tm"], sp["n0"]
        gdir = -own[(sc, tm)]
        bx, by, _ = sp["b0"]
        z = 0 if half - bx * gdir < 35 else 1 if half - bx * gdir < 70 else 2
        f0 = pl.get((sc, n0), {})
        c[("sp", sp["won"], z)] += 1
        for pid, p in f0.items():
            r = ROLE.get(pos_of.get(pid, ""), 6)
            if who.get(pid) != tm or pid in keepers or r not in (1, 2, 4): continue
            side = 1 if p[1] >= 0 else -1
            sd = "near" if (p[1] >= 0) == (by >= 0) else "far"
            d0 = hy - p[1] * side
            key = (r, sp["won"], z, sd)
            L[("d0",) + key].append(d0)
            c[("men",) + key] += 1
            for t in TS:   # at t s on, if the spell lasts: his m off the line, his 1 s speed toward it
                n = n0 + 25 * t
                if n > sp["n1"]: break
                q1 = pl.get((sc, n), {}).get(pid); q0 = pl.get((sc, n - 25), {}).get(pid)
                if not q1 or not q0: break
                L[("dt", t) + key].append(hy - q1[1] * side)
                L[("vt", t) + key].append((q1[1] - q0[1]) * side)
            if d0 >= 10:   # started infield: does he reach 5 m inside the spell, how long, what pace
                c[("far0",) + key] += 1
                for n in range(n0 + 5, sp["n1"] + 1, 5):
                    q = pl.get((sc, n), {}).get(pid)
                    if q and hy - q[1] * side < 5:
                        tt = (n - n0) / 25.0
                        c[("reach",) + key] += 1
                        L[("tt",) + key].append(tt)
                        L[("pace",) + key].append((d0 - (hy - q[1] * side)) / tt)
                        pk = 0.0
                        for m in range(n0 + 5, n + 1, 5):
                            a1 = pl.get((sc, m), {}).get(pid); a0 = pl.get((sc, m - 5), {}).get(pid)
                            if a1 and a0: pk = max(pk, (a1[1] - a0[1]) * side / 0.2)
                        L[("peak",) + key].append(pk)
                        break
    return c, dict(L)


def q(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(p * len(xs)))] if xs else float("nan")


def pool(L, k0, *keys):
    out = []
    for k in keys: out.extend(L.get(k0 + k, []))
    return out


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    tot = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pl_:
        for c, l in pl_.imap_unordered(one, files):
            tot.update(c)
            for k, v in l.items(): L[k].extend(v)
    tm = 2 * tot["matches"]
    zn = ("0-35", "35-70", "70+"); wn = ("restart", "won")
    print(f"{tot['matches']} DFL matches")
    for w in (1, 0):
        xs = L[("dur", w)]
        print(f"SPELLS {wn[w]}: {len(xs) / tm:.1f} a team-match; length s p25 / med / p75 / p90 {q(xs, .25):.1f} / {q(xs, .5):.1f} / {q(xs, .75):.1f} / {q(xs, .9):.1f};"
              f" 1 s+ {100 * sum(x >= 1 for x in xs) / max(1, len(xs)):.0f}%, 5 s+ {100 * sum(x >= 5 for x in xs) / max(1, len(xs)):.0f}%, 10 s+ {100 * sum(x >= 10 for x in xs) / max(1, len(xs)):.0f}%")
    for w in (1, 0):
        print(f"FROM A {wn[w].upper()} (spells 1 s+), by the ball's m off the goal line attacked at the start; his side the ball's (near) / far:")
        for r in (1, 4, 2):
            for sd in ("near", "far"):
                for z in range(3):
                    key = (r, w, z, sd); d0 = L.get(("d0",) + key, [])
                    if len(d0) < 20: continue
                    f0 = tot[("far0",) + key]; rc = tot[("reach",) + key]
                    line = (f"  {NAMES[r]:5s} {sd:4s} {zn[z]:5s} n {len(d0):4d}  d0 med {q(d0, .5):4.1f} (within 5 m {100 * sum(x < 5 for x in d0) / len(d0):2.0f}%)  "
                            "d med @1/2/3/5/8 s " + " / ".join(f"{q(L.get(('dt', t) + key, []), .5):4.1f}" for t in TS)
                            + "  v out m/s @1/2/3/5/8 " + " / ".join(f"{statistics.mean(L[('vt', t) + key]) if L.get(('vt', t) + key) else float('nan'):+.2f}" for t in TS))
                    if f0:
                        tt = L.get(("tt",) + key, []); pc = L.get(("pace",) + key, []); pk = L.get(("peak",) + key, [])
                        line += f"  | from 10 m+: reach 5 m {100 * rc / f0:2.0f}%"
                        if tt: line += f", in s p25/med/p75 {q(tt, .25):.1f}/{q(tt, .5):.1f}/{q(tt, .75):.1f}, pace med {q(pc, .5):.1f}, peak med {q(pk, .5):.1f}"
                    print(line)
    print("POOLED (won + restart, all zones): from 10 m+ off, reached 5 m inside the spell — time s p25/med/p75, mean pace across m/s p25/med/p75, peak 0.2 s m/s med")
    for r in (1, 4, 2):
        for sd in ("near", "far"):
            ks = [(r, w, z, sd) for w in (0, 1) for z in range(3)]
            tt = pool(L, ("tt",), *ks); pc = pool(L, ("pace",), *ks); pk = pool(L, ("peak",), *ks)
            f0 = sum(tot[("far0",) + k] for k in ks); rc = sum(tot[("reach",) + k] for k in ks)
            v = {t: pool(L, ("vt", t), *ks) for t in TS}
            print(f"  {NAMES[r]:5s} {sd:4s} reach {100 * rc / max(1, f0):2.0f}% of {f0}; t {q(tt, .25):.1f}/{q(tt, .5):.1f}/{q(tt, .75):.1f}; pace {q(pc, .25):.1f}/{q(pc, .5):.1f}/{q(pc, .75):.1f}; peak {q(pk, .5):.1f}"
                  "  | all men, v out m/s @1/2/3/5/8 " + " / ".join(f"{statistics.mean(v[t]) if v[t] else float('nan'):+.2f}" for t in TS))

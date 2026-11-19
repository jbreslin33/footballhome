#!/usr/bin/env python3
"""benchmarks_tracking_widesince.py — real width at a kick by the time since the spell began (G5.170, game/DESIGN.md §8.276).

    python3 -I game/scripts/benchmarks_tracking_widesince.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB 25 Hz; loaders as benchmarks_tracking_widerecv.py and benchmarks_tracking_widepace.py). Every completed
open-play pass that names a Recipient (the kicks of §8.273). Its spell: back from the kick through in-play frames with the
kicker's side's BallPossession flag (a dead ball ends it; *won* = the frame before was the other side's in play). Two
cuts: raw (any flip starts a new spell) and *settled* (the other side's runs under 1 s — a contested touch, a ricochet —
don't end it). At the kick, the passer's side's widest outfielder each side, m off that touchline (as widerecv), by the
spell's age 0-3 / 3-8 / 8+ s.

§8.275 found ours win the ball half as often as real sides and keep it three times as long; real width at a kick is
counted over many short spells. This asks whether the real width at a kick depends on how old the spell is.
"""
import collections, datetime, glob, multiprocessing, os, re, statistics, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES

AGES = (3, 8)


def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)


def age_band(a):
    return sum(a >= e for e in AGES)


def one(ev_path):
    d = os.path.dirname(ev_path)
    mid = ev_path.rsplit("_", 1)[1]
    pos_path = os.path.join(d, f"DFL_04_03_positions_raw_observed_{ev_path.split('events_raw_')[1]}")
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    hy = float(re.search(r'PitchY="([\d.]+)"', open(info_p, encoding="utf8").read()).group(1)) / 2
    half = length / 2
    team_of = {home: 0, guest: 1}
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
    txt = open(ev_path, encoding="utf8").read()
    passes = []
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<Play ([^>]*)>\s*<Pass', txt):
        a = dict(re.findall(r'(\w[\w-]*)="([^"]*)"', m.group(2)))
        if (a.get("Recipient") and a.get("FromOpenPlay") == "true" and a.get("Team") in team_of
                and a.get("Evaluation") == "successfullyCompleted"):
            passes.append((ms(m.group(1)) // 40, a["Player"], team_of[a["Team"]]))
    kicks = {p[0] for p in passes}
    frames = collections.defaultdict(dict)
    ball = {}; poss = {}
    who, sec_of = {}, {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    st_re = re.compile(r'BallStatus="(\d)"'); po_re = re.compile(r'BallPossession="(\d)"')
    cur = None; isb = False; skip = True; sec = None
    with open(pos_path, encoding="utf8", buffering=1 << 22) as f:
        for line in f:
            s = line.lstrip()
            if s.startswith("<Frame "):
                if skip:
                    continue
                a = s.split('"')
                g = ms(a[3]) // 40
                if isb:
                    ball[g] = (float(a[5]), float(a[7]))
                    sec_of[g] = sec
                    st = st_re.search(s); po = po_re.search(s)
                    poss[g] = int(po.group(1)) - 1 if st and st.group(1) == "1" and po and po.group(1) in "12" else -1
                elif g in kicks:
                    frames[g][cur] = (float(a[5]), float(a[7]))
            elif s.startswith("<FrameSet "):
                sec, tid, pid = set_re.search(s).groups()
                isb = tid.upper() == "BALL"
                skip = not isb and tid not in team_of
                if not skip and not isb:
                    cur = pid; who[pid] = team_of[tid]
    own = {}
    for sc in set(sec_of.values()):
        xs = {0: [], 1: []}
        for g, ps in frames.items():
            if sec_of.get(g) != sc:
                continue
            for pid, p in ps.items():
                if pid in keepers:
                    xs[who[pid]].append(p[0])
        for tm in (0, 1):
            own[(sc, tm)] = -1 if (sum(xs[tm]) / max(1, len(xs[tm]))) < 0 else 1

    def spell(t, tm, settled):
        """Back from frame t: the spell's first frame and whether it was won."""
        g = t; other = 0
        while True:
            p = poss.get(g - 1, None)
            if p is None or p < 0:                  # dead ball / gap: a restart spell
                return g, False
            if p == tm:
                g -= 1; other = 0; continue
            if settled:                             # the other side's flag: under 1 s and ours again before it, keep going
                k = g - 1; n = 0
                while poss.get(k, -1) == 1 - tm and n < 25:
                    k -= 1; n += 1
                if n < 25 and poss.get(k, -1) == tm:
                    g = k; continue
            return g, True

    c = collections.Counter(); L = collections.defaultdict(list)
    c["matches"] = 1
    for t, pa, tm in passes:
        fr = frames.get(t); sc = sec_of.get(t)
        if not fr or sc is None or t not in ball or (sc, tm) not in own or poss.get(t, -1) != tm:
            if fr and t in ball:
                c["flag_off"] += 1
            continue
        gdir = -own[(sc, tm)]
        bx, by = ball[t]
        bs = 1 if by >= 0 else -1
        kz = 0 if half - bx * gdir < 35 else 1 if half - bx * gdir < 70 else 2
        wm = {}
        for k_, sd in (("near", bs), ("far", -bs)):
            wm[k_] = min((hy - p[1] * sd) for pid, p in fr.items() if who.get(pid) == tm and pid not in keepers)
        for cut in ("raw", "settled"):
            g0, won = spell(t, tm, cut == "settled")
            age = (t - g0) * 0.04
            ab = age_band(age)
            c[(cut, "k", ab)] += 1; c[(cut, "kw", ab, won)] += 1
            c[(cut, "kz", kz, ab)] += 1
            L[(cut, "age")].append(age)
            for k_ in ("near", "far"):
                L[(cut, k_, ab)].append(wm[k_])
                L[(cut, k_, ab, kz)].append(wm[k_])
                L[(cut, k_, ab, "won" if won else "restart")].append(wm[k_])
            for pid, p in fr.items():   # each FB / DM-CM / WIDE of his side (not the kicker): m off the touchline his side of the pitch
                r = ROLE.get(pos_of.get(pid, ""), 6)
                if who.get(pid) != tm or pid in keepers or pid == pa or r not in (1, 2, 4):
                    continue
                L[(cut, "rw", r, "near" if (p[1] >= 0) == (by >= 0) else "far", kz, ab)].append(hy - abs(p[1]))
        c["kicks"] += 1
    return c, dict(L)


def q(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(p * len(xs)))] if xs else float("nan")


def w5(xs):
    return 100 * sum(x < 5 for x in xs) / max(1, len(xs))


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    tot = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for c, l in pool.imap_unordered(one, files):
            tot.update(c)
            for k, v in l.items():
                L[k].extend(v)
    nk = max(1, tot["kicks"])
    an = ("0-3", "3-8", "8+"); zn = ("0-35", "35-70", "70+")
    print(f"{tot['matches']} DFL matches, {tot['kicks']} completed open-play passes with the kicker's side's flag "
          f"({tot['flag_off']} dropped: flag not his side at the kick)")
    for cut in ("raw", "settled"):
        ag = L[(cut, "age")]
        print(f"{cut.upper()} spells: the kick's spell age s p25 / med / p75 {q(ag, .25):.1f} / {q(ag, .5):.1f} / {q(ag, .75):.1f}")
        for ab in range(3):
            n = max(1, tot[(cut, "k", ab)])
            nr = L[(cut, "near", ab)]; nf = L[(cut, "far", ab)]
            print(f"  age {an[ab]:4s} s: {100 * tot[(cut, 'k', ab)] / nk:4.1f}% of kicks (won {100 * tot[(cut, 'kw', ab, True)] / n:.0f}%)"
                  f" | widest within 5 m ball's side {w5(nr):4.1f}% (med {q(nr, .5):4.1f} m), far {w5(nf):4.1f}% (med {q(nf, .5):4.1f} m)"
                  f" | by ball m off the goal line attacked, ball's side " + " / ".join(
                      f"{zn[z]} {w5(L.get((cut, 'near', ab, z), [])):.0f}" for z in range(3))
                  + " far " + " / ".join(f"{w5(L.get((cut, 'far', ab, z), [])):.0f}" for z in range(3))
                  + " | won / restart ball's side " + " / ".join(f"{w5(L.get((cut, 'near', ab, w), [])):.0f}" for w in ("won", "restart")))
        print(f"  BY ROLE: within 5 m of his own touchline %, by ball band 0-35 / 35-70 / 70+, each at age 0-3 / 3-8 / 8+ s (n)")
        for r in (1, 2, 4):
            for sd in ("near", "far"):
                print(f"    {NAMES[r]:6s} {sd:4s} " + " | ".join(zn[z] + " " + " / ".join(
                    f"{w5(L.get((cut, 'rw', r, sd, z, ab), [])):.0f}" for ab in range(3)) + " (" + "/".join(
                    str(len(L.get((cut, 'rw', r, sd, z, ab), []))) for ab in range(3)) + ")" for z in range(3)))
        alln = [x for ab in range(3) for x in L[(cut, "near", ab)]]; allf = [x for ab in range(3) for x in L[(cut, "far", ab)]]
        print(f"  all: widest within 5 m ball's side {w5(alln):.1f}%, far {w5(allf):.1f}%")

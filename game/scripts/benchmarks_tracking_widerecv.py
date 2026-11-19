#!/usr/bin/env python3
"""benchmarks_tracking_widerecv.py — the wide reception: where the man stood at the kick (G5.167, game/DESIGN.md §8.273).

    python3 -I game/scripts/benchmarks_tracking_widerecv.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB 25 Hz; loader as benchmarks_tracking_behind.py). Every open-play pass that names a Recipient and is
completed. The reception: the frame in the next 4 s when the ball is nearest him (stop at the first under 1.5 m).

§8.272 found ours receive a third of the real share of passes within 5 m of the touchline (StatsBomb PL 15/16 15.7%,
ours 4.5-4.8%) while our men stand about right per role. This asks the tracking: of the passes met within 5 m of the
touchline, where was the receiver at the kick (already wide, or ran there), how far did he run toward the line, and
where was the ball kicked from (down the line, or out to the wing from infield).
"""
import collections, datetime, glob, math, multiprocessing, os, re, statistics, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES

BANDS = (5, 10, 20)


def band(t):
    return sum(t >= e for e in BANDS)


def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)


def one(ev_path):
    d = os.path.dirname(ev_path)
    mid = ev_path.rsplit("_", 1)[1]
    pos_path = os.path.join(d, f"DFL_04_03_positions_raw_observed_{ev_path.split('events_raw_')[1]}")
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    hy = float(re.search(r'PitchY="([\d.]+)"', open(info_p, encoding="utf8").read()).group(1)) / 2
    half = length / 2
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
    team_of = {home: 0, guest: 1}
    txt = open(ev_path, encoding="utf8").read()
    passes = []
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<Play ([^>]*)>\s*<Pass', txt):
        a = dict(re.findall(r'(\w[\w-]*)="([^"]*)"', m.group(2)))
        if (a.get("Recipient") and a.get("FromOpenPlay") == "true" and a.get("Team") in team_of
                and a.get("Evaluation") == "successfullyCompleted"):
            passes.append((ms(m.group(1)) // 40, a["Player"], a["Recipient"], team_of[a["Team"]], a.get("Height", "")))
    kicks = {p[0] for p in passes} | {p[0] - 5 for p in passes}
    window = collections.defaultdict(set)
    for t, pa, re_, tm, h in passes:
        window[re_].update(range(t, t + 101))
    frames = collections.defaultdict(dict)
    ball = {}
    who, sec_of = {}, {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
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
                elif g in kicks or g in window.get(cur, ()):
                    frames[g][cur] = (float(a[5]), float(a[7]), float(a[11]) / 3.6)
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
    c = collections.Counter(); L = collections.defaultdict(list)
    c["matches"] = 1
    for t, pa, re_, tm, h in passes:
        fr = frames.get(t); sc = sec_of.get(t)
        if not fr or sc is None or re_ not in fr or t not in ball or (sc, tm) not in own or re_ in keepers:
            continue
        gdir = -own[(sc, tm)]
        bx, by = ball[t]
        rx, ry, rs = fr[re_]
        # at every kick: his side's widest outfielder on the ball's side and on the far side, m off that touchline
        bs = 1 if by >= 0 else -1
        kz = 0 if half - bx * gdir < 35 else 1 if half - bx * gdir < 70 else 2   # G5.168: the ball off the goal line attacked
        c[("kz", kz)] += 1
        for k_, sd in (("near", bs), ("far", -bs)):
            wm, wp = min(((hy - p[1] * sd), pid) for pid, p in fr.items() if who.get(pid) == tm and pid not in keepers)
            c[("widest", k_, band(max(0.0, wm)))] += 1
            L[("widest", k_)].append(wm)
            c[("wz", k_, kz, band(max(0.0, wm)))] += 1
            if wm < 5:   # G5.168: who he is
                c[("wrole", k_, kz, ROLE.get(pos_of.get(wp, ""), 6) if wp != pa else 7)] += 1
        c["kicks"] += 1
        for pid, p in fr.items():   # G5.168: each FB / WIDE / DM-CM of his side (not the kicker), m off the touchline he stands nearer
            r = ROLE.get(pos_of.get(pid, ""), 6)
            if who.get(pid) != tm or pid in keepers or pid == pa or r not in (1, 2, 4):
                continue
            L[("rw", r, kz, "near" if (p[1] >= 0) == (by >= 0) else "far")].append(hy - abs(p[1]))
        best = None
        for k in range(t + 2, t + 101):
            b = ball.get(k); r = frames.get(k, {}).get(re_)
            if not b or not r:
                continue
            dd = math.hypot(b[0] - r[0], b[1] - r[1])
            if best is None or dd < best[0]:
                best = (dd, k, r, b)
            if dd < 1.5:
                break
        if best is None or best[0] > 3:
            continue
        _, ka, ra, ba = best
        w1 = hy - abs(ba[1])                    # met: the ball's m off the touchline
        w0 = hy - abs(ry)                       # he stood at the kick
        wb = hy - abs(by)                       # the ball at the kick
        b1 = band(w1)
        c["n"] += 1; c[("recv", b1)] += 1
        same_side = (ry >= 0) == (ba[1] >= 0)
        r0 = frames.get(t - 5, {}).get(re_)
        if r0:   # his speed toward his nearest touchline at the kick
            side = 1 if ry >= 0 else -1
            L[("vw", b1)].append((ry - r0[1]) * side / 0.2)
        L[("out", b1)].append(w0 - w1)          # metres he went toward the line kick -> reception
        L[("air", b1)].append((ka - t) * 0.04)
        L[("len", b1)].append(math.hypot(ba[0] - bx, ba[1] - by))
        L[("fwd", b1)].append((ba[0] - bx) * gdir)
        c[("w0", b1, band(w0))] += 1
        c[("wb", b1, band(wb) if (by >= 0) == (ba[1] >= 0) else 4)] += 1   # 4 = from the far half
        c[("tl", b1, sum(half - ba[0] * gdir >= e for e in (18, 35, 70)))] += 1
        if b1 == 0:
            c[("role_wide", h)] += 1
            # was he the man nearest that touchline of his side at the kick (the wide man)?
            side = 1 if ba[1] >= 0 else -1
            mates = sorted(((hy - p[1] * side), pid) for pid, p in fr.items() if who.get(pid) == tm and pid not in keepers)
            rank = next((i for i, (_, pid) in enumerate(mates) if pid == re_), 9)
            c[("rank", min(rank, 3))] += 1
            if not same_side:
                c["crossfield"] += 1
    return c, dict(L)


def q(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(p * len(xs)))]


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    tot = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for c, l in pool.imap_unordered(one, files):
            tot.update(c)
            for k, v in l.items():
                L[k].extend(v)
    tm = 2 * tot["matches"]; n = max(1, tot["n"])
    lab = ("0-5", "5-10", "10-20", "20+")
    print(f"{tot['matches']} DFL matches, {tot['n']} completed open-play passes met by a named outfielder ({tot['n'] / tm:.1f} a team-match)")
    print("  met by m off the touchline 0-5 / 5-10 / 10-20 / 20+: " + " / ".join(f"{100 * tot[('recv', b)] / n:.1f}" for b in range(4)) + "%")
    for b1 in range(4):
        nb = max(1, tot[("recv", b1)])
        print(f"MET {lab[b1]} m off the touchline ({tot[('recv', b1)] / tm:.1f} a team-match):")
        print("  he stood at the kick, m off the touchline 0-5 / 5-10 / 10-20 / 20+: " + " / ".join(f"{100 * tot[('w0', b1, b)] / nb:.1f}" for b in range(4)) + "%")
        print("  the ball at the kick (same half) 0-5 / 5-10 / 10-20 / 20+ / from the far half: " + " / ".join(f"{100 * tot[('wb', b1, b)] / nb:.1f}" for b in range(5)) + "%")
        print("  met m off the goal line attacked 0-18 / 18-35 / 35-70 / 70+: " + " / ".join(f"{100 * tot[('tl', b1, b)] / nb:.1f}" for b in range(4)) + "%")
        for k, s in (("out", "went toward the line kick->met, m"), ("vw", "his speed toward his touchline at the kick, m/s"),
                     ("air", "ball's time to him, s"), ("len", "pass length, m"), ("fwd", "pass forward, m")):
            xs = L.get((k, b1))
            if xs:
                print(f"  {s:48s} median {statistics.median(xs):6.2f}  p25 {q(xs, .25):6.2f}  p75 {q(xs, .75):6.2f}")
    nk = max(1, tot["kicks"])
    for k_ in ("near", "far"):
        print(f"AT THE KICK, the passer's side's widest outfielder on the {k_} side, m off that touchline 0-5 / 5-10 / 10-20 / 20+: "
              + " / ".join(f"{100 * tot[('widest', k_, b)] / nk:.1f}" for b in range(4)) + f"%  median {statistics.median(L[('widest', k_)]):.2f}")
    zn = ("0-35", "35-70", "70+")
    rn = NAMES + ["?", "the kicker"]
    for k_ in ("near", "far"):
        print(f"WIDEST ON THE {k_.upper()} SIDE by the ball's m off the goal line attacked (G5.168): within 5 m % | of those, who (role %)")
        for z in range(3):
            nz = max(1, tot[("kz", z)]); n5 = max(1, tot[("wz", k_, z, 0)])
            print(f"  {zn[z]:6s} {100 * tot[('wz', k_, z, 0)] / nz:5.1f}% (5-10 {100 * tot[('wz', k_, z, 1)] / nz:.1f}) | "
                  + " ".join(f"{rn[r]} {100 * tot[('wrole', k_, z, r)] / n5:.0f}" for r in range(8) if tot[("wrole", k_, z, r)]))
    print("BY ROLE AT THE KICK (G5.168): each FB / DM-CM / WIDE of the kicker's side, m off the touchline his side of the pitch: p10 / p25 / med / p75, within 5 m %")
    for r in (1, 2, 4):
        for sd in ("near", "far"):
            print(f"  {NAMES[r]:6s} {sd:4s} " + " | ".join(
                f"{zn[z]} {q(L[('rw', r, z, sd)], .1):.1f} / {q(L[('rw', r, z, sd)], .25):.1f} / {q(L[('rw', r, z, sd)], .5):.1f} / {q(L[('rw', r, z, sd)], .75):.1f}, "
                f"{100 * sum(x < 5 for x in L[('rw', r, z, sd)]) / max(1, len(L[('rw', r, z, sd)])):.0f}%" for z in range(3) if L.get(('rw', r, z, sd))))
    n0 = max(1, tot[("recv", 0)])
    print("MET 0-5: the receiver's rank among his side's outfielders nearest that touchline at the kick 1st / 2nd / 3rd / 4th+: "
          + " / ".join(f"{100 * tot[('rank', r)] / n0:.1f}" for r in range(4)) + "%")

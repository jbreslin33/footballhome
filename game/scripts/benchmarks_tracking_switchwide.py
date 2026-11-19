#!/usr/bin/env python3
"""benchmarks_tracking_switchwide.py — the switch by where the far side's widest man stood at the kick (G5.172, game/DESIGN.md §8.278).

    python3 -I game/scripts/benchmarks_tracking_switchwide.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB 25 Hz; loader as benchmarks_tracking_behind.py). Every open-play pass that names a Recipient and is
completed. The reception: the frame in the next 4 s when the ball is nearest him (stop at the first under 1.5 m).

Loader and pass set as benchmarks_tracking_widerecv.py (completed open-play passes naming a Recipient; met = the frame the
ball is nearest him). A switch = the ball 34 m+ across, kick to met (the harness's cut of StatsBomb's switch flag). By
the passer's side's widest outfielder on the far side at the kick (m off that touchline 0-5 / 5-10 / 10-20 / 20+): the
share of passes that switch, who met it (that widest man or another), and the ball's m off the goal line attacked.

§8.277 put ours on the far touchline nearer the real share and our switches went 11.8 → 13.2 a team-match (PL 10.7).
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
        bs = 1 if by >= 0 else -1
        kz = 0 if half - bx * gdir < 35 else 1 if half - bx * gdir < 70 else 2
        wm, wp = min(((hy - p[1] * -bs), pid) for pid, p in fr.items() if who.get(pid) == tm and pid not in keepers)
        fb = band(max(0.0, wm))
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
        ba = best[3]
        # G5.172 wing lift: the pass policy's zones (benchmarks_statsbomb_wing.py); into a wide zone, far wing or near, and
        # whether the far wing of that end zone held a mate at the kick
        def zone(x, y):
            dd = half - x * gdir
            return sum(dd >= e for e in (18, 35, 52, 70)) * 2 + (0 if abs(y) < 20.16 else 1)
        oz = zone(bx, by); ez = zone(ba[0], ba[1])
        if ez % 2 == 1 and by != 0:
            far = (ba[1] >= 0) != (by >= 0)
            occ = any(zone(p[0], p[1]) == ez and (p[1] >= 0) != (by >= 0) for pid, p in fr.items() if who.get(pid) == tm and pid not in keepers and pid != pa)
            oc = oz % 2
            c[("w", oc, "n")] += 1; c[("w", oc, "far")] += far
            c[("w", oc, "occ")] += occ; c[("w", oc, "far_occ")] += far and occ
        sw = abs(ba[1] - by) >= 34
        c[("n", fb)] += 1; c[("nz", kz, fb)] += 1
        if sw:
            c[("sw", fb)] += 1; c[("swz", kz, fb)] += 1
            c[("to", fb, "widest" if re_ == wp else "other")] += 1
            c[("h", fb, h)] += 1
            L[("swrw", fb)].append(hy - abs(fr[re_][1]))
            L[("swlen",)].append(math.hypot(ba[0] - bx, ba[1] - by))
    return c, dict(L)


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    tot = collections.Counter(); L = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for c, l in pool.imap_unordered(one, files):
            tot.update(c)
            for k, v in l.items():
                L[k].extend(v)
    tm = 2 * tot["matches"]
    n = sum(tot[("n", b)] for b in range(4)); sw = sum(tot[("sw", b)] for b in range(4))
    lab = ("0-5", "5-10", "10-20", "20+"); zn = ("0-35", "35-70", "70+")
    print(f"{tot['matches']} DFL matches, {n} completed open-play passes met ({n / tm:.1f} a team-match); switches 34 m+ across {sw / tm:.2f} a team-match = {100 * sw / max(1, n):.2f}%")
    print("BY THE FAR SIDE'S WIDEST MATE AT THE KICK (m off that touchline): share of passes | switch % of them | switches a team-match | met by that widest man % | by ball m off the goal line attacked 0-35 / 35-70 / 70+ switch %")
    for b in range(4):
        nb = max(1, tot[("n", b)]); sb = tot[("sw", b)]
        print(f"  {lab[b]:5s} {100 * tot[('n', b)] / max(1, n):4.1f}% | {100 * sb / nb:4.2f}% | {sb / tm:4.2f} | {100 * tot[('to', b, 'widest')] / max(1, sb):3.0f}% | "
              + " / ".join(f"{100 * tot[('swz', z, b)] / max(1, tot[('nz', z, b)]):.2f}" for z in range(3)))
    for oc in (0, 1):
        n_ = max(1, tot[("w", oc, "n")]); o_ = max(1, tot[("w", oc, "occ")])
        f = tot[("w", oc, "far")] / n_; fc = tot[("w", oc, "far_occ")] / o_
        print(f"WING ({'centre' if oc == 0 else 'wide'} origin, completed passes into a wide zone, n {n_}): far {1000 * f:.0f} permille; the far wing of that end zone held a mate at the kick {100 * o_ / n_:.0f}%;"
              f" far given a mate there {1000 * fc:.0f} permille -> lift {fc / max(1e-9, f):.2f}")
    print(f"  switch length median {statistics.median(L[('swlen',)]):.1f} m")

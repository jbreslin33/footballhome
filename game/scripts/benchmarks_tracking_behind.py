#!/usr/bin/env python3
"""benchmarks_tracking_behind.py — balls played in behind, and the run that meets them
(G5.27, game/DESIGN.md §8.125).

    python3 -I game/scripts/benchmarks_tracking_behind.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data
owner DFL (7 matches of 2022/23, TRACAB 25 Hz positions + official events; loader as
benchmarks_tracking_receiver.py). Every open-play pass that names a Recipient (the event names
the man it was FOR, completed or not — 5,903 of 6,062 plays).

At the kick: their offside line (Law 11: the second-last of the defending side, keeper in, or
halfway) and where the man it is for stands against it (metres short of it, + = onside), his speed
and his speed toward their goal. The ball's arrival: the frame in the next 4 s when it is nearest
him. IN BEHIND = he meets it past the line as it stood at the kick. For those: how far he ran to it
(the lead), the ball's time in the air, the pass length, from where (the pass policy's zones), how
many a team-match, completed; and every forward pass's runners: men of the passer's side within 3 m
of the line at the kick running at their goal at 4+ m/s.
"""
import bisect, collections, datetime, glob, math, multiprocessing, os, re, statistics, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt

EDGES = (18, 35, 52, 70)


def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)


def zone(tl, y):
    return sum(tl >= e for e in EDGES) * 2 + (0 if abs(y) < 20.16 else 1)


def one(ev_path):
    d = os.path.dirname(ev_path)
    mid = ev_path.rsplit("_", 1)[1]
    pos_path = os.path.join(d, f"DFL_04_03_positions_raw_observed_{ev_path.split('events_raw_')[1]}")
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    half = length / 2
    team_of = {home: 0, guest: 1}
    txt = open(ev_path, encoding="utf8").read()
    passes = []
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<Play ([^>]*)>\s*<Pass', txt):
        a = dict(re.findall(r'(\w[\w-]*)="([^"]*)"', m.group(2)))
        if a.get("Recipient") and a.get("FromOpenPlay") == "true" and a.get("Team") in team_of:
            passes.append((ms(m.group(1)) // 40, a["Player"], a["Recipient"], team_of[a["Team"]],
                           a.get("Evaluation") == "successfullyCompleted", a.get("Height", "")))
    shots = []                              # (grid, team, goal) — G5.85 IN BEHIND THEN
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<ShotAtGoal ([^>]*)>(.*?)</ShotAtGoal>', txt, re.S):
        a = dict(re.findall(r'(\w[\w-]*)="([^"]*)"', m.group(2)))
        if a.get("Team") in team_of:
            shots.append((ms(m.group(1)) // 40, team_of[a["Team"]], "<SuccessfulShot" in m.group(3)))
    kicks = {p[0] for p in passes} | {p[0] - 5 for p in passes}
    window = collections.defaultdict(set)   # person -> grid times wanted (beyond the kicks)
    for t, pa, re_, tm, ok, h in passes:
        window[re_].update(range(t, t + 101))
    frames = collections.defaultdict(dict)  # grid -> person -> (x, y, s)
    ball = {}                               # grid -> (x, y)
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
    # Which way each team attacks, by section: its keeper's side.
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
    c = collections.Counter()
    lists = collections.defaultdict(list)
    c["matches"] = 1
    c["shots"] = len(shots); c["goals"] = sum(x[2] for x in shots)
    for t, pa, re_, tm, ok, h in passes:
        fr = frames.get(t)
        sc = sec_of.get(t)
        if not fr or sc is None or re_ not in fr or t not in ball or (sc, tm) not in own:
            continue
        gdir = -own[(sc, tm)]                   # +1: they attack +x
        bx, by = ball[t]
        rx, ry, rs = fr[re_]
        # their offside line: the second-last defender (keeper in), or halfway, or the ball
        dx = sorted((p[0] * gdir for pid, p in fr.items() if who.get(pid) == 1 - tm), reverse=True)
        if len(dx) < 2:
            continue
        line = max(dx[1], 0.0, bx * gdir)
        gap = line - rx * gdir                  # + = short of it (onside)
        # his speed toward their goal over the last 0.2 s
        r0 = frames.get(t - 5, {}).get(re_)
        vx = ((rx - r0[0]) * gdir / 0.2) if r0 else None
        # the ball's arrival: nearest him in the next 4 s (stop at the first close pass under 1.5 m)
        best = None
        for k in range(t + 2, t + 101):
            b = ball.get(k); r = frames.get(k, {}).get(re_)
            if not b or not r:
                continue
            dd = math.hypot(b[0] - r[0], b[1] - r[1])
            if best is None or dd < best[0]:
                best = (dd, k, r)
            if dd < 1.5:
                break
        if best is None:
            continue
        _, ka, ra = best
        fwd = (ra[0] - bx) * gdir               # metres the pass goes forward (kick → his reception)
        c["passes"] += 1
        tl = half - bx * gdir
        oz = zone(tl, by)
        c[("pass_z", oz)] += 1
        c[("gap_hist", max(-2, min(9, int(math.floor(gap / 2)))))] += 1
        if gap >= 0:
            c[("gap_ok_z", oz)] += 1
        # runners at a forward pass
        if fwd > 5:
            c["fwd"] += 1
            runners = 0
            for pid, p in fr.items():
                if who.get(pid) != tm or pid == pa or pid in keepers:
                    continue
                q = frames.get(t - 5, {}).get(pid)
                if q is None:
                    continue
                v = (p[0] - q[0]) * gdir / 0.2
                if abs(line - p[0] * gdir) < 3 and v > 4:
                    runners += 1
            c["fwd_runners"] += runners
            c[("fwd_runners_k", min(runners, 2))] += 1
        behind = ra[0] * gdir > line + 0.5 and fwd > 0
        if not behind:
            continue
        c["behind"] += 1
        c[("behind_gap_hist", max(-2, min(9, int(math.floor(gap / 2)))))] += 1
        c[("behind_z", oz)] += 1
        c["behind_ok"] += ok
        # G5.85 IN BEHIND THEN: a shot / goal by the passer's side within 10 s, by height
        hk = "high" if h == "high" else "low"
        sh = [x for x in shots if x[1] == tm and t < x[0] <= t + 250]
        c[("then_n", hk)] += 1
        c[("then_shot", hk)] += bool(sh)
        c[("then_goal", hk)] += any(x[2] for x in sh)
        c[("then_n_ok", ok)] += 1
        c[("then_shot_ok", ok)] += bool(sh)
        c[("then_goal_ok", ok)] += any(x[2] for x in sh)
        c[("behind_h", h)] += 1
        lists["gap"].append(gap)
        lists["speed"].append(rs)
        if vx is not None:
            lists["vx"].append(vx)
        lists["lead"].append(math.hypot(ra[0] - rx, ra[1] - ry))
        lists["lead_fwd"].append((ra[0] - rx) * gdir)
        lists["air"].append((ka - t) * 0.04)
        lists["len"].append(math.hypot(ra[0] - bx, ra[1] - by))
        lists["recv_tl"].append(half - ra[0] * gdir)
        lists["recv_past"].append(ra[0] * gdir - line)
        lists["kick_tl"].append(tl)
    return c, dict(lists)


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
    tm = 2 * tot["matches"]
    nb = tot["behind"]
    print(f"{tot['matches']} DFL matches, {tot['passes']} open-play passes with a named man ({tot['passes'] / tm:.1f} a team-match)")
    print(f"IN BEHIND (met past their line as it stood at the kick): {nb} = {nb / tm:.1f} a team-match, "
          f"{100 * nb / max(1, tot['passes']):.1f}% of passes, completed {100 * tot['behind_ok'] / max(1, nb):.1f}%")
    print("  height: " + ", ".join(f"{h} {100 * tot[('behind_h', h)] / nb:.0f}%" for h in ("flat", "high", "medium", "")))
    names = ("0-18 c", "0-18 w", "18-35 c", "18-35 w", "35-52 c", "35-52 w", "52-70 c", "52-70 w", "70+ c", "70+ w")
    print("  from (a team-match): " + ", ".join(f"{names[z]} {tot[('behind_z', z)] / tm:.2f}" for z in range(10)))
    print("  SHARE of the zone's named passes that go in behind: " + ", ".join(
        f"{names[z]} {100 * tot[('behind_z', z)] / max(1, tot[('pass_z', z)]):.1f}%" for z in range(10)))
    print("  P(in behind | his gap at the kick, 2 m bins from -4): " + ", ".join(
        f"{2 * g}..{2 * g + 2} {100 * tot[('behind_gap_hist', g)] / max(1, tot[('gap_hist', g)]):.0f}% (of {tot[('gap_hist', g)]})" for g in range(-2, 10)))
    for k, lab in (("gap", "his gap short of the line at the kick, m"), ("speed", "his speed at the kick, m/s"),
                   ("vx", "his speed toward goal at the kick, m/s"), ("lead", "how far he runs to it, m"),
                   ("lead_fwd", "  of it forward, m"), ("air", "ball's time to him, s"), ("len", "pass length, m"),
                   ("recv_past", "met past the line, m"), ("recv_tl", "met, metres off their line"),
                   ("kick_tl", "kicked from, metres off their line")):
        xs = L[k]
        if xs:
            print(f"  {lab:42s} median {statistics.median(xs):6.2f}  p25 {q(xs, .25):6.2f}  p75 {q(xs, .75):6.2f}  mean {statistics.mean(xs):6.2f}")
    print(f"IN BEHIND THEN (a shot / goal by the passer's side within 10 s; all shots {tot['shots'] / tm:.1f}, goals {tot['goals'] / tm:.2f} a team-match):")
    for k, lab in (("high", "high"), ("low", "flat/medium")):
        n = max(1, tot[("then_n", k)])
        print(f"  {lab:12s} {tot[('then_n', k)] / tm:5.1f} a team-match: shot {100 * tot[('then_shot', k)] / n:4.1f}%  goal {100 * tot[('then_goal', k)] / n:4.1f}%  ({tot[('then_goal', k)]} goals)")
    for k, lab in ((True, "completed"), (False, "not completed")):
        n = max(1, tot[("then_n_ok", k)])
        print(f"  {lab:12s} {tot[('then_n_ok', k)] / tm:5.1f} a team-match: shot {100 * tot[('then_shot_ok', k)] / n:4.1f}%  goal {100 * tot[('then_goal_ok', k)] / n:4.1f}%")
    nf = max(1, tot["fwd"])
    print(f"FORWARD PASSES (5+ m on): {tot['fwd']} ({tot['fwd'] / tm:.1f} a team-match); runners at the line (within 3 m, 4+ m/s at goal) "
          f"mean {tot['fwd_runners'] / nf:.2f}; 0 / 1 / 2+ {100 * tot[('fwd_runners_k', 0)] / nf:.0f} / "
          f"{100 * tot[('fwd_runners_k', 1)] / nf:.0f} / {100 * tot[('fwd_runners_k', 2)] / nf:.0f}%")

#!/usr/bin/env python3
"""benchmarks_tracking_deadmove.py — how much the players move while the ball is dead, by the restart that ends it
(G5.263, game/DESIGN.md §8.369; owner 11/25 "one player dwelling on ball and everyone just watching").

    python3 -I game/scripts/benchmarks_tracking_deadmove.py <dfl dir>

Dead spells as benchmarks_tracking_dead.py (BallStatus 0, named by the official restart event within 3 s before to
2 s after play resumes). In the last 5 s before the restart — the taker has the ball — every second, each tracked
player's speed over the second before (metres moved / 1 s, from X/Y, so DFL's S units do not matter): the mean, and
the share moving 1 m/s or more. Referees out; keepers in (ours counts the 21 men off the ball).

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23). FH original.
"""
import bisect, collections, datetime, glob, math, os, re, sys

KINDS = ("ThrowIn", "GoalKick", "CornerKick", "FreeKick", "KickOff", "Penalty")


def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)


def frames(pos_path):
    """yield (team, person, section, N, t ms, x, y, ballstatus)"""
    team = person = sec = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<FrameSet "):
            team = re.search(r'TeamId="([^"]+)"', s).group(1); person = re.search(r'PersonId="([^"]+)"', s).group(1)
            sec = re.search(r'GameSection="([^"]+)"', s).group(1)
            continue
        if not s.startswith("<Frame "):
            continue
        a = s.split('"')
        yield team, person, sec, int(a[1]), a[3], float(a[5]), float(a[7]), 'BallStatus="1"' in s


def one(ev_path):
    pos_path = ev_path.replace("03_02_events_raw", "04_03_positions_raw_observed")
    txt = open(ev_path, encoding="utf8").read()
    ev = sorted((ms(m.group(1)), m.group(2)) for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<(\w+)', txt)
                if m.group(2) in KINDS)
    times = [e[0] for e in ev]
    # pass 1: the ball — dead spells as (section, N0, N1, t1 ms)
    spells = []; last = None; n0 = None
    for team, person, sec, n, t, x, y, st in frames(pos_path):
        if team.upper() != "BALL":
            continue
        if not st and last is not False:
            n0 = (sec, n)
        if st and last is False and n0 is not None and n0[0] == sec:
            spells.append((sec, n0[1], n, ms(t)))
        last = st
    # sample frames: each second of the last 5 s before the restart (N1-125 .. N1-25), and the frame 1 s before each
    want = {}   # (sec, N) -> (spell index, role 0 = sample / 1 = a second before)
    kinds = []
    for i, (sec, a, b, t1) in enumerate(spells):
        j = bisect.bisect_left(times, t1 - 3000); kind = "other"
        while j < len(times) and times[j] <= t1 + 2000:
            kind = ev[j][1]; break
        kinds.append(kind)
        for k in range(1, 6):
            n = b - 25 * k
            if n - 25 >= a:
                want[(sec, n)] = i; want[(sec, n - 25)] = i
        for k in range(1, 31):   # and every second from the ball going dead (the profile)
            n = a + 25 * k
            if n < b:
                want[(sec, n)] = i; want[(sec, n - 25)] = i
    # pass 2: the players
    at = {}   # (person, sec, N) -> (x, y)
    for team, person, sec, n, t, x, y, st in frames(pos_path):
        if team.upper() == "BALL" or team.lower() == "referee":
            continue
        if (sec, n) in want:
            at[(person, sec, n)] = (x, y)
    S = collections.defaultdict(lambda: [0, 0.0, 0, 0])   # kind -> [player samples, speed sum, moving 1 m/s+, spells]
    people = {p for (p, s, n) in at}
    for i, (sec, a, b, t1) in enumerate(spells):
        got = False
        for k in range(1, 6):
            n = b - 25 * k
            if n - 25 < a:
                continue
            for p in people:
                q, r = at.get((p, sec, n)), at.get((p, sec, n - 25))
                if q is None or r is None:
                    continue
                v = math.hypot(q[0] - r[0], q[1] - r[1])
                row = S[kinds[i]]; row[0] += 1; row[1] += v; row[2] += v >= 1.0; got = True
        if got:
            S[kinds[i]][3] += 1
        for k in range(1, 31):
            n = a + 25 * k
            if n >= b:
                break
            bk = 0 if k <= 3 else 1 if k <= 6 else 2 if k <= 10 else 3 if k <= 20 else 4
            for p in people:
                q, r = at.get((p, sec, n)), at.get((p, sec, n - 25))
                if q is None or r is None:
                    continue
                v = math.hypot(q[0] - r[0], q[1] - r[1])
                row = S[("prof", kinds[i], bk)]; row[0] += 1; row[1] += v; row[2] += v >= 1.0
    return dict(S)


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    import multiprocessing
    T = collections.defaultdict(lambda: [0, 0.0, 0, 0])
    with multiprocessing.Pool(3) as pool:
        for d in pool.imap_unordered(one, files):
            for k, v in d.items():
                for z in range(4):
                    T[k][z] += v[z]
    print(f"{len(files)} DFL matches: the last 5 s before each restart, every second — players' speed over the second before")
    for k in KINDS + ("other",):
        n, sv, mv, sp = T.get(k, [0, 0, 0, 0])
        if n:
            print(f"  {k:10s} spells {sp:4d}: mean speed {sv / n:.2f} m/s, moving 1 m/s+ {100 * mv / n:.1f}% of the players")
    print("FROM THE BALL GOING DEAD (s 1-3 / 4-6 / 7-10 / 11-20 / 21-30): mean speed m/s, moving 1 m/s+ %")
    for k in KINDS + ("other",):
        cells = [T.get(("prof", k, bk)) for bk in range(5)]
        if any(cells):
            print(f"  {k:10s} " + " | ".join(f"{c[1] / c[0]:.2f} {100 * c[2] / c[0]:4.1f}%" if c and c[0] else "  -  " for c in cells))

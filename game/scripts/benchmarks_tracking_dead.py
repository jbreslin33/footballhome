#!/usr/bin/env python3
"""benchmarks_tracking_dead.py — how much of a match the ball is in play, and how long it is dead
before each kind of restart (G5.28, game/DESIGN.md §8.126).

    python3 -I game/scripts/benchmarks_tracking_dead.py <dfl dir>

The ball's BallStatus (TRACAB, 25 Hz): the share of each half in play; each dead spell (a run of
BallStatus 0) named by the restart event that ends it (ThrowIn, GoalKick, CornerKick, FreeKick,
KickOff, Penalty — the official event within 3 s before to 2 s after play resumes; else
"other": drop balls, VAR, injuries without a named restart). Per kind: how many a team-match and the
median / p25 / p75 seconds dead.

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches of 2022/23).
"""
import bisect, collections, datetime, glob, os, re, statistics, sys

KINDS = ("ThrowIn", "GoalKick", "CornerKick", "FreeKick", "KickOff", "Penalty")


def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)


def one(ev_path):
    pos_path = ev_path.replace("03_02_events_raw", "04_03_positions_raw_observed")
    txt = open(ev_path, encoding="utf8").read()
    ev = sorted((ms(m.group(1)), m.group(2)) for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<(\w+)', txt)
                if m.group(2) in KINDS)
    times = [e[0] for e in ev]
    spells = []   # (start ms, end ms)
    total = inplay = 0
    isb = False; last = None; dead_from = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<FrameSet "):
            isb = 'TeamId="BALL"' in s or 'TeamId="Ball"' in s
            if isb:
                last = None; dead_from = None
            continue
        if not isb or not s.startswith("<Frame "):
            continue
        a = s.split('"')
        t = ms(a[3])
        st = 'BallStatus="1"' in s
        total += 1; inplay += st
        if not st and last is not False:
            dead_from = t
        if st and last is False and dead_from is not None:
            spells.append((dead_from, t))
        last = st
    c = collections.Counter(); d = collections.defaultdict(list)
    c["total"] = total; c["inplay"] = inplay; c["matches"] = 1
    for t0, t1 in spells:
        i = bisect.bisect_left(times, t1 - 3000)
        kind = "other"
        while i < len(times) and times[i] <= t1 + 2000:
            kind = ev[i][1]; break
        d[kind].append((t1 - t0) / 1000)
    return c, d


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    import multiprocessing
    c = collections.Counter(); D = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, dd in pool.imap_unordered(one, files):
            c.update(cc)
            for k, v in dd.items():
                D[k].extend(v)
    tm = 2 * c["matches"]
    print(f"{c['matches']} DFL matches: ball in play {100 * c['inplay'] / c['total']:.1f}% of the match "
          f"({c['inplay'] / 25 / 60 / c['matches']:.1f} of {c['total'] / 25 / 60 / c['matches']:.1f} min)")
    print("DEAD BEFORE EACH RESTART (a team-match; seconds median p25 p75; share of all dead time):")
    alltime = sum(sum(v) for v in D.values())
    for k in KINDS + ("other",):
        v = sorted(D.get(k, []))
        if not v:
            continue
        print(f"  {k:10s} {len(v) / tm:5.1f}  {statistics.median(v):5.1f} {v[len(v) // 4]:5.1f} {v[3 * len(v) // 4]:5.1f}  {100 * sum(v) / alltime:4.1f}%")

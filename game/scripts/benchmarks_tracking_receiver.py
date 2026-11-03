#!/usr/bin/env python3
"""benchmarks_tracking_receiver.py — how fast the man a pass is for is moving at
the kick (game/DESIGN.md §8.103).

    python3 -I game/scripts/benchmarks_tracking_receiver.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177,
CC BY, data owner DFL (7 matches of 2022/23, TRACAB positions + official events;
see benchmarks_tracking.py). Completed flat open-play passes only: the event
names a Recipient only when one took it, so this is the receiver of passes that
arrived, not of every pass played. Event times are operator clocks, good to a
few tenths of a second. Direction is his 0.2 s displacement against passer→him.
Bins match fh-game-match's RECEIVER AT THE KICK.
"""
import collections, datetime, glob, math, multiprocessing, os, re, sys

def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)

def one(ev_path):
    pos_path = ev_path.replace("03_02_events_raw", "04_03_positions_raw_observed")
    want = {}          # person -> {grid: pass index}
    passes = []
    txt = open(ev_path, encoding="utf8").read()
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<Play ([^>]*)>\s*<Pass', txt):
        a = dict(re.findall(r'(\w[\w-]*)="([^"]*)"', m.group(2)))
        if a.get("Recipient") and a.get("Height") == "flat" and a.get("FromOpenPlay") == "true":
            t = ms(m.group(1)) // 40
            passes.append((t, a["Player"], a["Recipient"]))
            for p in (a["Player"], a["Recipient"]):
                want.setdefault(p, set()).update((t, t - 5))
    seen = {}
    cur = None
    with open(pos_path, encoding="utf8", buffering=1 << 22) as f:
        for line in f:
            s = line.lstrip()
            if s.startswith("<Frame "):
                if cur is None:
                    continue
                a = s.split('"')
                g = ms(a[3]) // 40
                if g in cur[1]:
                    seen[(cur[0], g)] = (float(a[5]), float(a[7]), float(a[11]) / 3.6)
            elif s.startswith("<FrameSet"):
                m = re.search(r'PersonId="([^"]+)"', s)
                p = m.group(1) if m else None
                cur = (p, want[p]) if p in want else None
    c = collections.Counter()
    for t, pa, re_ in passes:
        r1, r0, q = seen.get((re_, t)), seen.get((re_, t - 5)), seen.get((pa, t))
        if not (r1 and r0 and q):
            continue
        v = r1[2]
        dx, dy = r1[0] - q[0], r1[1] - q[1]        # passer to him
        mx, my = r1[0] - r0[0], r1[1] - r0[1]      # his last 0.2 s
        ml, dl = math.hypot(mx, my), max(0.1, math.hypot(dx, dy))
        along = (mx * dx + my * dy) / (ml * dl) if ml > 1e-6 else 0
        c[0 if v < 2 else 1 if v < 5 else 2 if along < -0.5 else 4 if along > 0.5 else 3] += 1
        c["n"] += 1
        c["v"] += v
    return c

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    tot = collections.Counter()
    with multiprocessing.Pool(3) as pool:
        for c in pool.imap_unordered(one, files):
            tot.update(c)
    n = tot["n"]
    print(f"{len(files)} matches, {n} completed flat open-play passes, mean receiver speed {tot['v'] / n:.2f} m/s")
    for i, name in enumerate(("under 2 m/s", "2-5 m/s", "5+ toward the passer", "5+ across", "5+ away")):
        print(f"  {name:22s} {100 * tot[i] / n:5.1f}%")

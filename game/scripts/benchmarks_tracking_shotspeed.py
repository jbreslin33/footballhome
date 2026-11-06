#!/usr/bin/env python3
"""game/scripts/benchmarks_tracking_shotspeed.py — how fast real shots travel
(game/DESIGN.md §8.135).

    python3 -I game/scripts/benchmarks_tracking_shotspeed.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177,
CC BY, data owner DFL (7 matches of 2022/23): the event files' ShotAtGoal (time,
distance, outcome) and the 25 Hz ball positions. For each shot, the ball's peak
speed over the 0.6 s after the event time (from its own positions, 0.12 s
steps), and the mean speed over its first 11 m of travel. By distance band and
outcome.
"""
import bisect, datetime as dt, glob, math, os, re, statistics as st, sys

d = sys.argv[1]


def ts(s):
    return dt.datetime.fromisoformat(s).timestamp()


rows = []
for ev in sorted(glob.glob(os.path.join(d, "DFL_03_02_events_raw_*"))):
    mid = ev.rsplit("_", 1)[1]
    pos = glob.glob(os.path.join(d, f"DFL_04_03_positions_raw_observed_*_{mid}"))[0]
    shots = []
    text = open(ev, encoding="utf8").read()
    for m in re.finditer(r'<Event ([^>]*)>\s*<ShotAtGoal ([^>]*)>\s*<(\w+)', text):
        a = m.group(1)
        t = re.search(r'EventTime="([^"]+)"', a).group(1)
        ex = float(re.search(r' X-Position="([-\d.]+)"', a).group(1)) - 52.5
        ey = float(re.search(r' Y-Position="([-\d.]+)"', a).group(1)) - 34
        dist = re.search(r'DistanceToGoal="([\d.]+)"', m.group(2))
        shots.append((ts(t), ex, ey, float(dist.group(1)) if dist else None, m.group(3)))
    ball = []
    inball = False
    for line in open(pos, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<FrameSet "):
            inball = 'TeamId="BALL"' in s
        elif inball and s.startswith("<Frame "):
            t = re.search(r'T="([^"]+)"', s).group(1)
            x = float(re.search(r' X="([-\d.]+)"', s).group(1))
            y = float(re.search(r' Y="([-\d.]+)"', s).group(1))
            ball.append((ts(t), x, y))
    ball.sort()
    times = [b[0] for b in ball]
    for t0, ex, ey, dist, out in shots:
        # The event clock is not the tracking clock: anchor on the frame within
        # 3 s where the ball is nearest the shot's spot (either end's mirror).
        i0 = bisect.bisect_left(times, t0 - 3)
        win = ball[i0:i0 + 151]
        if not win:
            continue
        k = min(range(len(win)), key=lambda j: min(math.hypot(win[j][1] - ex, win[j][2] - ey), math.hypot(win[j][1] + ex, win[j][2] + ey)))
        if min(math.hypot(win[k][1] - ex, win[k][2] - ey), math.hypot(win[k][1] + ex, win[k][2] + ey)) > 2.5:
            continue
        ta = win[k][0]
        seg = [b for b in ball[i0 + k:i0 + k + 20] if b[0] <= ta + 0.6]
        if len(seg) < 10:
            continue
        peak = 0.0
        for a, b in zip(seg, seg[3:]):
            dtt = b[0] - a[0]
            if 0 < dtt < 0.3:
                peak = max(peak, math.hypot(b[1] - a[1], b[2] - a[2]) / dtt)
        if peak > 45:
            continue   # a tracking jump, not a ball
        rows.append((dist, out, peak))

B = [(0, 12), (12, 18), (18, 25), (25, 99)]
print(f"{len(rows)} shots; peak ball speed (m/s) in the 0.6 s after the shot: median (p25-p75)")
for lo, hi in B:
    v = [r[2] for r in rows if r[0] is not None and lo <= r[0] < hi]
    if len(v) >= 4:
        q = st.quantiles(v, n=4)
        print(f"  {lo:2d}-{hi if hi < 99 else '':<3} m  n {len(v):3d}  {st.median(v):5.1f} ({q[0]:.1f}-{q[2]:.1f})")
for out in sorted({r[1] for r in rows}):
    v = [r[2] for r in rows if r[1] == out]
    if len(v) >= 4:
        print(f"  {out:<15} n {len(v):3d}  {st.median(v):5.1f}")
v = [r[2] for r in rows]
q = st.quantiles(v, n=4)
print(f"  all            n {len(v):3d}  {st.median(v):5.1f} ({q[0]:.1f}-{q[2]:.1f})")

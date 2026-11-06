#!/usr/bin/env python3
"""benchmarks_tracking_goalkick.py — where a real side stands for its own goal kick
(game/DESIGN.md §8.136; the club's tactic_buildout_shapes).

    python3 -I game/scripts/benchmarks_tracking_goalkick.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177,
CC BY, data owner DFL (7 matches of 2022/23, TRACAB 25 Hz). Each GoalKick event
is anchored on the tracking frame where the ball goes back into play (BallStatus
0 → 1) from inside the kicking side's goal area — the event clock is not the
tracking clock — within 40 s of the event. At that frame, every man of the
kicking side by his PlayingPosition (match information): metres off his own goal
line, and metres toward his own LEFT from the goal's centre line. Means and the
count, then the club plan's coordinates (0-100, OUR view as we attack their
goal: x left → right, their goal at y 100) with James's numbers (TW 1, IVL 5,
IVR 4, IVZ 6, LV 3, RV 2, DM* 6, left/right central midfield 10 / 8, OLM/LA 11,
ORM/RA 7, ST* 9 — a pro side's labels; each match's formation decides which
appear).
"""
import collections, datetime as dt, glob, os, re, statistics as st, sys

d = sys.argv[1]
set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
fr_re = re.compile(r'<Frame N="(\d+)" T="([^"]+)" X="([-\d.]+)" Y="([-\d.]+)"')
pos_stat = re.compile(r'BallStatus="(\d)"')


def ts(s):
    return dt.datetime.fromisoformat(s).timestamp()


acc = collections.defaultdict(list)   # position label -> [(depth, left)]
kicks = found = 0
for ev in sorted(glob.glob(os.path.join(d, "DFL_03_02_events_raw_*"))):
    mid = ev.rsplit("_", 1)[1]
    pos_path = glob.glob(os.path.join(d, f"DFL_04_03_positions_raw_observed_*_{mid}"))[0]
    info = open(glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0], encoding="utf8").read()
    role = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', info))
    gks = [(ts(m.group(2)), m.group(1)) for m in
           re.finditer(r'<GoalKick Team="([^"]+)" DecisionTimestamp="([^"]+)"', open(ev, encoding="utf8").read())]
    kicks += len(gks)
    # Pass 1: the ball — transitions 0 → 1 with the ball in a goal area.
    ball, cur, sec_ball = [], None, None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            cur = "BALL" if tid.upper() == "BALL" else None
            sec_ball = sec
        elif cur and s.startswith("<Frame "):
            m = fr_re.search(s)
            st_ = pos_stat.search(s)
            ball.append((sec_ball, int(m.group(1)), ts(m.group(2)), float(m.group(3)), float(m.group(4)), st_.group(1) if st_ else "1"))
    starts = []
    for a, b in zip(ball, ball[1:]):
        if a[0] == b[0] and a[5] == "0" and b[5] == "1" and abs(b[3]) > 46 and abs(b[4]) < 10:
            starts.append((b[0], b[1], b[2], b[3]))
    want = {}
    for t0, team in gks:
        best = min(starts, key=lambda x: abs(x[2] - t0), default=None)
        if best and abs(best[2] - t0) < 40:
            want[(best[0], best[1])] = (team, best[3])
    # Pass 2: every man at those frames.
    at = collections.defaultdict(dict)
    cur, sec, tid = None, None, None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<FrameSet "):
            sec, tid, cur = set_re.search(s).groups()
            if tid.upper() == "BALL":
                cur = None
        elif cur and s.startswith("<Frame "):
            m = fr_re.search(s)
            k = (sec, int(m.group(1)))
            if k in want:
                at[k][cur] = (tid, float(m.group(3)), float(m.group(4)))
    for k, (team, bx) in want.items():
        men = at.get(k, {})
        mine = {p: (x, y) for p, (t, x, y) in men.items() if t == team}
        if len(mine) < 10:
            continue
        found += 1
        own = 1 if bx > 0 else -1          # their goal is at x = own * 52.5
        for p, (x, y) in mine.items():
            depth = 52.5 - own * x          # metres off their own goal line
            left = -own * y                 # facing out of their goal (−own x), his left is −own y
            acc[role.get(p, "?")].append((depth, left))

NUM = {"TW": 1, "IVL": 5, "IVR": 4, "IVZ": 6, "LV": 3, "RV": 2, "DMZ": 6, "DML": 10, "DMR": 8, "DLM": 10,
       "DRM": 8, "ZO": 10, "OLM": 11, "LA": 11, "HL": 11, "ORM": 7, "RA": 7, "HR": 7, "STZ": 9, "STL": 9, "STR": 9}
print(f"{found} of {kicks} goal kicks anchored; the kicking side by position: metres off its own line, metres to its own left")
print("  pos   n   depth  left    | plan x,y (our view, their goal y 100)  James #")
for r in sorted(acc, key=lambda r: st.mean(a[0] for a in acc[r])):
    v = acc[r]
    dep, lf = st.mean(a[0] for a in v), st.mean(a[1] for a in v)
    # Our view: their left is our right (x up); their goal at y = 100.
    px, py = 50 + lf / 68 * 100, 100 - dep / 105 * 100
    print(f"  {r:<4} {len(v):3d}  {dep:5.1f}  {lf:+5.1f}    | {px:5.1f}, {py:5.1f}                         {NUM.get(r, '-')}")

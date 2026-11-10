#!/usr/bin/env python3
"""game/scripts/benchmarks_tracking_carry.py — the carried ball, from elite tracking (viewer gait, 11/10).

    python3 -I game/scripts/benchmarks_tracking_carry.py <DFL dir>

A CARRY: ball in play and on the ground (Z < 0.5 m), the possessing side's nearest player within
1.5 m of it, the same man for 1 s or more, moving 1 m/s or more. For every 25 Hz frame of a carry,
by the carrier's speed: the ball's offset from him along his direction of travel (ahead) and across
it (side). TOUCHES: the ball's speed along his line, relative to his, jumps by 1.2 m/s+ within 0.12 s
while he is within 1.0 m of it (0.25 s apart at least): touches a second, the interval between them,
and the farthest the ball runs ahead between two touches. What players.js's dribble draws.

Data: DFL / Bundesliga tracking, Bassek et al. 2025 (idsse, CC BY 4.0). FH original.
"""
import array, collections, glob, math, os, re, statistics, sys, multiprocessing

BANDS = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 99)]


def band(s):
    for i, (a, b) in enumerate(BANDS):
        if a <= s < b:
            return i
    return -1


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = open(glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0], encoding="utf8").read()
    teams = re.findall(r'<Team [^>]*TeamId="([^"]+)"', info)
    home = re.search(r'HomeTeamId="([^"]+)"', info).group(1)
    team_no = {t: (1 if t == home else 2) for t in teams}   # BallPossession 1 = home, 2 = guest
    halves = collections.defaultdict(lambda: {"ball": {}, "pl": {}})
    sec = cur = None; isb = False; skip = True
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip:
                continue
            a = s.split('"'); n = int(a[1])
            H = halves[sec]
            if isb:
                st = re.search(r'BallStatus="(\d)"', s); po = re.search(r'BallPossession="(\d)"', s)
                z = re.search(r' Z="([-\d.]+)"', s)
                if st and st.group(1) == "1" and po and po.group(1) in "12" and z:
                    H["ball"][n] = (float(a[5]), float(a[7]), float(z.group(1)), int(po.group(1)))
            else:
                H["pl"][cur][0][n] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"
            skip = not isb and tid not in team_no
            if not skip and not isb:
                cur = pid; halves[sec]["pl"][pid] = ({}, team_no[tid])
    out = {"ahead": collections.defaultdict(list), "side": collections.defaultdict(list), "frames": collections.Counter(),
           "touch": collections.Counter(), "secs": collections.Counter(), "intv": collections.defaultdict(list),
           "peak": collections.defaultdict(list)}
    for H in halves.values():
        ball, pl = H["ball"], H["pl"]
        if not ball:
            continue
        frames = sorted(ball)
        # carrier per frame: possessing side's nearest within 1.5 m, ball on the ground
        car = {}
        for n in frames:
            bx, by, bz, po = ball[n]
            if bz >= 0.5:
                continue
            best, bd = None, 1.5
            for pid, (pos, tm) in pl.items():
                if tm != po or n not in pos:
                    continue
                px, py = pos[n]; dd = math.hypot(bx - px, by - py)
                if dd < bd:
                    best, bd = pid, dd
            if best:
                car[n] = best
        # spells
        spells = []; start = prev = None; who = None
        for n in frames:
            c = car.get(n)
            if c and c == who and prev == n - 1:
                prev = n; continue
            if who and prev - start >= 25:
                spells.append((who, start, prev))
            who, start, prev = (c, n, n) if c else (None, None, None)
        if who and prev - start >= 25:
            spells.append((who, start, prev))
        for pid, a0, a1 in spells:
            pos = pl[pid][0]
            def vel(n, k=3):
                if n - k in pos and n + k in pos:
                    return ((pos[n + k][0] - pos[n - k][0]) * 25 / (2 * k), (pos[n + k][1] - pos[n - k][1]) * 25 / (2 * k))
                return None
            def bvel(n, k=2):
                if n - k in ball and n + k in ball:
                    return ((ball[n + k][0] - ball[n - k][0]) * 25 / (2 * k), (ball[n + k][1] - ball[n - k][1]) * 25 / (2 * k))
                return None
            last_t = None; peak = 0.0; rels = {}
            for n in range(a0, a1 + 1):
                v = vel(n); bv = bvel(n)
                if not v or not bv:
                    continue
                sp = math.hypot(*v)
                if sp < 1.0:
                    last_t = None
                    continue
                ux, uy = v[0] / sp, v[1] / sp
                bx, by = ball[n][0] - pos[n][0], ball[n][1] - pos[n][1]
                ah = bx * ux + by * uy; sd = abs(-bx * uy + by * ux)
                bi = band(sp)
                out["ahead"][bi].append(ah); out["side"][bi].append(sd); out["frames"][bi] += 1
                rel = (bv[0] - v[0]) * ux + (bv[1] - v[1]) * uy
                rels[n] = rel
                peak = max(peak, ah)
                if n - 3 in rels and rel - rels[n - 3] > 1.2 and math.hypot(bx, by) < 1.0 and (last_t is None or n - last_t >= 6):
                    out["touch"][bi] += 1
                    if last_t is not None:
                        out["intv"][bi].append((n - last_t) / 25); out["peak"][bi].append(peak)
                    last_t = n; peak = ah
            for n in range(a0, a1 + 1):
                v = vel(n)
                if v and math.hypot(*v) >= 1.0:
                    out["secs"][band(math.hypot(*v))] += 1 / 25
    return out


def q(v, p):
    v = sorted(v)
    return v[min(len(v) - 1, int(len(v) * p))] if v else float("nan")


def main():
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(2) as P:
        res = P.map(one, files)
    tot = {k: (collections.defaultdict(list) if isinstance(v, collections.defaultdict) else collections.Counter()) for k, v in res[0].items()}
    for r in res:
        for k, v in r.items():
            for b, x in v.items():
                if isinstance(x, list):
                    tot[k][b].extend(x)
                else:
                    tot[k][b] += x
    print(f"{len(files)} DFL matches: carries (possessing side's nearest within 1.5 m, ball on the ground, 1 s+), by the carrier's speed")
    print("  m/s   | carry s | ball ahead m: p25 / med / p75 / p90 | side m med | touches/s | touch interval s med | farthest ahead between touches m med / p75")
    for i, (a, b) in enumerate(BANDS):
        A = tot["ahead"][i]
        if not A:
            continue
        secs = tot["secs"][i]
        print(f"  {a}-{b if b < 99 else '+':<3} | {secs:7.0f} | {q(A, .25):5.2f} / {q(A, .5):5.2f} / {q(A, .75):5.2f} / {q(A, .9):5.2f} | "
              f"{q(tot['side'][i], .5):4.2f} | {tot['touch'][i] / max(secs, 1e-9):4.2f} | {q(tot['intv'][i], .5):4.2f} | "
              f"{q(tot['peak'][i], .5):4.2f} / {q(tot['peak'][i], .75):4.2f}")


if __name__ == "__main__":
    main()

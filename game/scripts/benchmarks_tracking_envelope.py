#!/usr/bin/env python3
"""game/scripts/benchmarks_tracking_envelope.py — what an elite body can do, by speed (G5.77 footsteps).

    python3 -I game/scripts/benchmarks_tracking_envelope.py <DFL dir>

Every outfielder (keepers out), ball in play, 25 Hz positions. Velocity = central difference over
+-3 frames (0.24 s), acceleration = the same of the velocity; every 2nd frame sampled. By the speed
band: the acceleration ALONG his line (speeding up p95 / p99, braking p95 / p99) and ACROSS it
(lateral = turning, p95 / p99), and the tightest turn radius actually run (v^2 / lateral, p1 / p5).
These bound the footstep body: what a planted foot can do at that speed. fh-game-match prints the
same as BODY ENVELOPE.

Data: DFL / Bundesliga tracking, Bassek et al. 2025 (idsse, CC BY 4.0). FH original.
"""
import collections, glob, math, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt

EDGES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 99]


def bnd(s):
    for i in range(len(EDGES) - 1):
        if EDGES[i] <= s < EDGES[i + 1]:
            return i
    return len(EDGES) - 2


def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    teams = {home, guest}
    inplay = set(); tracks = collections.defaultdict(dict)
    sec = cur = None; isb = False; skip = True
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip:
                continue
            a = s.split('"'); n = int(a[1])
            if isb:
                if 'BallStatus="1"' in s:
                    inplay.add((sec, n))
            else:
                tracks[(sec, cur)][n] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"
            skip = not isb and (tid not in teams or pid in keepers)
            if not skip and not isb:
                cur = pid
    acc = collections.defaultdict(list); brk = collections.defaultdict(list); lat = collections.defaultdict(list)
    rad = collections.defaultdict(list); cnt = collections.Counter()
    K = 3
    for (sc, pid), P in tracks.items():
        def vel(n):
            if n - K in P and n + K in P:
                return ((P[n + K][0] - P[n - K][0]) * 25 / (2 * K), (P[n + K][1] - P[n - K][1]) * 25 / (2 * K))
            return None
        for n in P:
            if n % 2 or (sc, n) not in inplay:
                continue
            v = vel(n); v0 = vel(n - K); v1 = vel(n + K)
            if not v or not v0 or not v1:
                continue
            sp = math.hypot(*v)
            ax = (v1[0] - v0[0]) * 25 / (2 * K); ay = (v1[1] - v0[1]) * 25 / (2 * K)
            b = bnd(sp); cnt[b] += 1
            if sp < 0.5:
                continue
            ux, uy = v[0] / sp, v[1] / sp
            al = ax * ux + ay * uy; la = abs(-ax * uy + ay * ux)
            (acc if al > 0 else brk)[b].append(abs(al)); lat[b].append(la)
            if la > 0.3:
                rad[b].append(sp * sp / la)
    return acc, brk, lat, rad, cnt


def q(v, p):
    v = sorted(v)
    return v[min(len(v) - 1, int(len(v) * p))] if v else float("nan")


def main():
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(2) as P:
        res = P.map(one, files)
    A = collections.defaultdict(list); B = collections.defaultdict(list); L = collections.defaultdict(list)
    R = collections.defaultdict(list); C = collections.Counter()
    for a, b, l, r, c in res:
        for k in a: A[k] += a[k]
        for k in b: B[k] += b[k]
        for k in l: L[k] += l[k]
        for k in r: R[k] += r[k]
        C.update(c)
    tot = sum(C.values())
    print(f"{len(files)} DFL matches, outfielders, ball in play (12.5 Hz samples): the body envelope by speed (m/s, m/s^2, m)")
    print("  speed | share of time | speeding up p95 / p99 | braking p95 / p99 | lateral p95 / p99 | tightest turn radius p1 / p5")
    for i in range(len(EDGES) - 1):
        hi = EDGES[i + 1] if EDGES[i + 1] < 99 else "+"
        print(f"  {EDGES[i]}-{hi:<2} | {100 * C[i] / max(1, tot):5.1f}% | {q(A[i], .95):4.1f} / {q(A[i], .99):4.1f} | "
              f"{q(B[i], .95):4.1f} / {q(B[i], .99):4.1f} | {q(L[i], .95):4.1f} / {q(L[i], .99):4.1f} | {q(R[i], .01):5.2f} / {q(R[i], .05):5.2f}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""benchmarks_tracking_chip.py — every real ball in the air by carry: how high it goes (G5.154,
game/DESIGN.md §8.259).

    python3 -I game/scripts/benchmarks_tracking_chip.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB 25 Hz ball with height). The cut is benchmarks_tracking_loft.py's (in play,
launch = last frame under 0.5 m, landing = next under 0.5 m, cut at a touch) but every flight that
peaks past 1.8 m (shoulder height, StatsBomb's "high"), not only past 4 m. By carry: flights a
team-match and the share peaking 1.8-2.5 / 2.5-4 / 4-6 / 6+ m, peak med, launch speed med.
fh-game-match prints the same as CHIP HEIGHT. FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
G = 9.81
BINS = ((10, 20), (20, 30), (30, 40), (40, 50), (50, 70))
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    bt.dfl_info(info)
    ball = {}
    sec = None; isb = False
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if not isb: continue
            a = s.split('"'); n = int(a[1])
            st = re.search(r'BallStatus="(\d)"', s)
            ball[(sec, n)] = (float(a[5]), float(a[7]), float(a[9]), bool(st and st.group(1) == "1"))
        elif s.startswith("<FrameSet "):
            m = re.search(r'GameSection="([^"]+)".*TeamId="([^"]+)"', s)
            sec = m.group(1); isb = m.group(2).upper() == "BALL"
    out = []
    for sc in sorted({k[0] for k in ball}):
        ks = sorted(k[1] for k in ball if k[0] == sc)
        i = 0
        while i < len(ks) - 4:
            n = ks[i]; bx, by, bz, live = ball[(sc, n)]
            nx = ball.get((sc, n + 1))
            if not (live and bz < 0.5 and nx and nx[3] and nx[2] >= 0.5):
                i += 1; continue
            # the launch: frame n. Follow while in play and consecutive.
            fr = [ball[(sc, n)]]; m = n + 1
            while (sc, m) in ball and ball[(sc, m)][3] and m - n < 250:
                fr.append(ball[(sc, m)])
                if ball[(sc, m)][2] < 0.5: break
                m += 1
            i += max(1, len(fr) - 1)
            if len(fr) < 6 or fr[-1][2] >= 0.5 and not ((sc, m) in ball and ball[(sc, m)][3]): continue
            zs = [f[2] for f in fr]
            pk = max(zs)
            if pk < 1.8: continue
            ip = zs.index(pk)
            # a touch: after the peak it stops falling (rises 0.15 m+ over 2 frames) before landing
            end = len(fr) - 1; touched = fr[-1][2] >= 0.5
            for j in range(ip + 2, len(fr)):
                if zs[j] > zs[j - 2] + 0.15: end = j - 2; touched = True; break
            carry = math.hypot(fr[end][0] - bx, fr[end][1] - by)
            t3 = 3 / 25
            vh = math.hypot(fr[3][0] - fr[0][0], fr[3][1] - fr[0][1]) / t3
            vz = (fr[3][2] - fr[0][2]) / t3 + G * t3 / 2
            ang = math.degrees(math.atan2(vz, max(0.1, vh)))
            down = next(((j / 25) for j in range(ip, end + 1) if zs[j] <= 2.4), None)
            land = None if touched else end / 25
            out.append((carry, ang, pk, down, land, math.hypot(vh, vz)))
    return out
def q(v):
    v = sorted(v)
    return f"{v[len(v) // 4]:5.1f} /{v[len(v) // 2]:5.1f} /{v[3 * len(v) // 4]:5.1f}" if v else "   -"
def med(v):
    v = sorted(x for x in v if x is not None)
    return f"{v[len(v) // 2]:4.2f}" if v else "  - "
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    with multiprocessing.Pool(min(8, len(files))) as p:
        allr = [r for rs in p.map(one, files) for r in rs]
    tm = 2 * len(files)
    cuts = (1.8, 2.5, 4.0, 6.0, 99)
    print(f"{len(files)} DFL matches: CHIP HEIGHT (in play, peaked past 1.8 m), by carry m: a team-match | peak 1.8-2.5 / 2.5-4 / 4-6 / 6+ m % | past 4 m a team-match | peak med | launch speed m/s med | landing s p10..p90 (untouched flights)")
    for lo, hi in ((5, 10),) + BINS:
        v = [r for r in allr if lo <= r[0] < hi]
        if not v: continue
        sh = [100 * sum(1 for r in v if cuts[k] <= r[2] < cuts[k + 1]) / len(v) for k in range(4)]
        ld = sorted(r[4] for r in v if r[4] is not None)
        lq = " ".join(f"{ld[int(k * (len(ld) - 1) / 10)]:4.2f}" for k in range(1, 10)) if ld else "-"
        print(f"   {lo:2d}-{hi:2d} {len(v) / tm:5.1f} | " + " / ".join(f"{x:4.1f}" for x in sh) + f" | {sum(1 for r in v if r[2] >= 4) / tm:4.1f} | {med([r[2] for r in v])} | {med([r[5] for r in v])} | landing s p10..p90 {lq} (of {len(ld)})")

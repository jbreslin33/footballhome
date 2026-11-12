#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_balltime.py (G5.101, DESIGN §8.203) — usage: <DFL dir>
# Real: where the ball lives. In-play 5 Hz frames with a side in possession (DFL's flag), the ball's metres
# off the line that side attacks, in bands 0-18 / 18-35 / 35-52 / 52-70 / 70+. Per band: seconds a
# team-match, share of possession time; VISITS (consecutive frames, same side, same band): a team-match,
# median length, and how each ends — forward (a nearer band), back, lost (the other side on it), dead.
# DFL tracking (Bassek et al. 2025, CC BY), loader as benchmarks_tracking_turnline.py.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ZB = (18, 35, 52, 70)
def zb(d): return 0 if d < ZB[0] else 1 if d < ZB[1] else 2 if d < ZB[2] else 3 if d < ZB[3] else 4
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    half = length / 2; team_of = {home: 0, guest: 1}
    ball = {}; kx = collections.defaultdict(list)
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    sec = None; isb = False; skip = True; cur = None; curt = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if n % 5: continue
            if isb:
                st = re.search(r'BallStatus="(\d)"', s); po = re.search(r'BallPossession="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), int(po.group(1)) - 1 if (st and st.group(1) == "1" and po and po.group(1) in "12") else -1)
            elif cur in keepers and n % 250 == 0: kx[(sec, curt)].append(float(a[5]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; curt = team_of[tid]
    own = {k: (-1 if sum(v) / len(v) < 0 else 1) for k, v in kx.items()}   # the side of the pitch each team defends, by half
    c = collections.Counter(); H = collections.defaultdict(list)
    prev = None; vis = None   # vis = [side, band, frames]
    for (sc, n) in sorted(ball):
        bx, att = ball[(sc, n)]
        cont = prev is not None and prev[0] == sc and prev[1] == n - 5
        if att < 0 or (sc, att) not in own:
            if vis: c[("end", vis[1], "dead")] += 1; H[("len", vis[1])].append(vis[2] / 5); vis = None
            prev = None; continue
        g = own[(sc, att)]                 # att defends the goal at x = g * half; it attacks x = -g * half
        band = zb(half + bx * g)           # metres off the line it attacks
        c[("t", band)] += 1; c["t"] += 1
        if vis and cont and vis[0] == att and vis[1] == band: vis[2] += 1
        else:
            if vis:
                e = "dead" if not cont else "lost" if vis[0] != att else "forward" if band < vis[1] else "back"
                c[("end", vis[1], e)] += 1; H[("len", vis[1])].append(vis[2] / 5)
            vis = [att, band, 1]
        prev = (sc, n)
    return c, H
if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); H = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, hh in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in hh.items(): H[k2] += v
    def med(v): v = sorted(v); return v[len(v) // 2] if v else float("nan")
    tm = 2 * len(files); BN = ["0-18", "18-35", "35-52", "52-70", "70+"]
    print(f"{len(files)} DFL matches: WHERE THE BALL LIVES (in play, DFL's possession flag; m off the line the side on it attacks): {c['t']/5/tm:.0f} s a team-match on it")
    print("  band | s a team-match | share % | visits a team-match | visit s med | ends forward / back / lost / dead %")
    for b in range(5):
        nv = sum(c[("end", b, e)] for e in ("forward", "back", "lost", "dead"))
        print(f"   {BN[b]:5s} | {c[('t', b)]/5/tm:6.1f} | {100*c[('t', b)]/max(1, c['t']):5.1f} | {nv/tm:6.1f} | {med(H[('len', b)]):4.1f} | "
              + " / ".join(f"{100*c[('end', b, e)]/max(1, nv):4.1f}" for e in ("forward", "back", "lost", "dead")))

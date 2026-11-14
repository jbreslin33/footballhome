#!/usr/bin/env python3
"""benchmarks_tracking_rolewidth.py — the side on the ball, each role's width by the ball's width (G5.120,
game/DESIGN.md §8.221): the target for the in-possession slide by role.

    python3 -I game/scripts/benchmarks_tracking_rolewidth.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL
(7 matches, TRACAB 5 Hz). Spells as benchmarks_tracking_flight.py (an outfielder nearest the ball within 1.5 m,
ball under 1.5 m, in play, 2+ frames). On every spell frame, the side on the ball's outfielders, the carrier
out; s = a man's metres toward the ball's side (y × the sign of the ball's y). By the ball's metres off the
centre line in 4 m bins (0-4 … 24-28, 28+), each role (benchmarks_tracking_runs.ROLE):
- PAIR (exactly two of that role on the pitch, neither the carrier): the pair's centre s (mean), the near man's s
  and the far man's s (med), their gap (med);
- LONE (exactly one, not the carrier): his s (mean) and |y| (med), his s med on the ball's side and on the far
  side, and the share of frames he stands on the ball's side.
And the same lone man's side per spell: with the ball within 8 m of the centre, the share of spells he keeps one
side throughout, and his |y| med on those frames.
fh-game-match prints the same as ROLE WIDTH.
FH original.
"""
import collections, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt
from benchmarks_tracking_runs import ROLE, NAMES

NB = 8
def yb(by): return min(NB - 1, int(abs(by) // 4))

def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    team_of = {home: 0, guest: 1}
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
    ball = {}; pl = collections.defaultdict(dict); who = {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    sec = None; isb = False; skip = True; cur = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if n % 5: continue
            if isb:
                st = re.search(r'BallStatus="(\d)"', s)
                ball[(sec, n)] = (float(a[5]), float(a[7]), float(a[9]), bool(st and st.group(1) == "1"))
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    seq = []
    for k in sorted(ball):
        bx, by, bz, live = ball[k]; fr = pl.get(k)
        if not live or not fr: seq.append((k, None)); continue
        best = None; bd = 1.5
        if bz <= 1.5:
            for pid, (x, y) in fr.items():
                if pid not in who: continue
                dd = math.hypot(x - bx, y - by)
                if dd <= bd: bd = dd; best = pid
        seq.append((k, best))
    spells = []; i = 0
    while i < len(seq):
        k, pid = seq[i]
        if pid is None: i += 1; continue
        j = i
        while j + 1 < len(seq) and seq[j + 1][1] == pid and seq[j + 1][0][0] == k[0] and seq[j + 1][0][1] == seq[j][0][1] + 5: j += 1
        if j > i: spells.append((i, j, pid))
        i = j + 1
    H = collections.defaultdict(list); c = collections.Counter()
    for i0, i1, pid in spells:
        if pid in keepers: continue
        tm = who[pid]; lone_sides = collections.defaultdict(set)
        for t in range(i0, i1 + 1):
            k = seq[t][0]; fr = pl[k]; by = ball[k][1]; sg = 1 if by >= 0 else -1; b = yb(by)
            byr = collections.defaultdict(list)
            for q, (x, y) in fr.items():
                if who.get(q) != tm or q in keepers: continue
                r = ROLE.get(pos_of.get(q), -1)
                if r >= 0: byr[r].append((q, y))
            for r, men in byr.items():
                if any(q == pid for q, _ in men): continue
                if len(men) == 2:
                    s = sorted(y * sg for _, y in men)
                    H[("pc", b, r)].append((s[0] + s[1]) / 2); H[("pn", b, r)].append(s[1]); H[("pf", b, r)].append(s[0])
                    H[("pg", b, r)].append(s[1] - s[0])
                elif len(men) == 1:
                    q, y = men[0]
                    H[("ls", b, r)].append(y * sg); H[("ly", b, r)].append(abs(y)); c[("ln", b, r)] += 1; c[("lb", b, r)] += y * sg > 0
                    H[("lnr" if y * sg > 0 else "lfr", b, r)].append(y * sg)
                    if abs(by) < 8:
                        lone_sides[(q, r)].add(y >= 0); H[("lcy", r)].append(abs(y))
        for (q, r), sides in lone_sides.items():
            c[("lsp", r)] += 1; c[("lsk", r)] += len(sides) == 1
    return c, H

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter(); H = collections.defaultdict(list)
    with multiprocessing.Pool(3) as pool:
        for cc, hh in pool.imap_unordered(one, files):
            c.update(cc)
            for k2, v in hh.items(): H[k2] += v
    def md(v): v = sorted(v); return v[len(v) // 2] if v else float("nan")
    def mn(v): return sum(v) / len(v) if v else float("nan")
    BN = [f"{4*b}-{4*b+4}" if b < NB - 1 else f"{4*b}+" for b in range(NB)]
    print(f"{len(files)} DFL matches: ROLE WIDTH — the side on the ball, carrier out, s = m toward the ball's side; by the ball's m off the centre line " + " / ".join(BN))
    for r in range(6):
        if sum(len(H[("pc", b, r)]) for b in range(NB)) > 500:
            print(f"  {NAMES[r]:5s} PAIR centre s mean: " + " / ".join(f"{mn(H[('pc', b, r)]):+.1f}" for b in range(NB)))
            print(f"        near s med:      " + " / ".join(f"{md(H[('pn', b, r)]):+.1f}" for b in range(NB)))
            print(f"        far s med:       " + " / ".join(f"{md(H[('pf', b, r)]):+.1f}" for b in range(NB)))
            print(f"        gap med:         " + " / ".join(f"{md(H[('pg', b, r)]):.1f}" for b in range(NB)) + f"  (n {sum(len(H[('pc', b, r)]) for b in range(NB))})")
        if sum(len(H[("ls", b, r)]) for b in range(NB)) > 500:
            print(f"  {NAMES[r]:5s} LONE s mean:   " + " / ".join(f"{mn(H[('ls', b, r)]):+.1f}" for b in range(NB)))
            print(f"        |y| med:         " + " / ".join(f"{md(H[('ly', b, r)]):.1f}" for b in range(NB)))
            print(f"        ball side s med: " + " / ".join(f"{md(H[('lnr', b, r)]):+.1f}" for b in range(NB)))
            print(f"        far side s med:  " + " / ".join(f"{md(H[('lfr', b, r)]):+.1f}" for b in range(NB)))
            print(f"        ball side %:     " + " / ".join(f"{100*c[('lb', b, r)]/max(1, c[('ln', b, r)]):.0f}" for b in range(NB))
                  + f"  (n {sum(c[('ln', b, r)] for b in range(NB))}); ball within 8 m: one side the whole spell {100*c[('lsk', r)]/max(1, c[('lsp', r)]):.0f}% of {c[('lsp', r)]}, |y| med {md(H[('lcy', r)]):.1f}")

#!/usr/bin/env python3
"""benchmarks_tracking_marking.py — is the man a pass is for marked when it is played? (G5.72,
game/DESIGN.md §8.173)

    python3 -I game/scripts/benchmarks_tracking_marking.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner
DFL (7 matches, TRACAB positions read at 5 Hz + official events). Every open-play pass that names a
Recipient of the passer's own side: completed passes only (on a lost pass the tag is the opponent
who took it; those are dropped). At the pass's EventTime (operator clock, good to a few tenths): the
recipient's nearest outfielder of the other side, and the passer's. By Height (flat / high) and by the recipient's zone
(metres off the passer's own goal 0-35 / 35-70 / 70+). Beside it, every other outfielder of the
passer's side in that zone at the same kick: the men he could have picked, so the gap between the
two is the passer's choice and the second alone is the defence's marking. fh-game-match
prints the same as RECEIVER'S MARKER AT THE KICK (completed passes, positions at the release).
FH original.
"""
import collections, datetime, glob, math, multiprocessing, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt

def ms(t):
    return int(datetime.datetime.fromisoformat(t).timestamp() * 1000)

def one(ev_path):
    pos_path = ev_path.replace("03_02_events_raw", "04_03_positions_raw_observed")
    mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(os.path.dirname(pos_path), f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info)
    half = length / 2; team_of = {home: 0, guest: 1}
    passes = []
    txt = open(ev_path, encoding="utf8").read()
    for m in re.finditer(r'<Event [^>]*EventTime="([^"]+)"[^>]*>\s*<Play ([^>]*)>\s*<Pass', txt):
        a = dict(re.findall(r'(\w[\w-]*)="([^"]*)"', m.group(2)))
        if a.get("FromOpenPlay") == "true" and a.get("Recipient") and a.get("Team") in team_of:
            passes.append((ms(m.group(1)) // 40, a["Player"], a["Recipient"], a.get("Height"), a.get("Evaluation") == "successfullyCompleted", team_of[a["Team"]]))
    want = set()
    for t, *_ in passes: want.update(range(t - 4, t + 1))
    fr = collections.defaultdict(dict); who = {}; sec_of = {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    cur = None; sec = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if cur is None: continue
            a = s.split('"')
            if int(a[1]) % 5: continue
            g = ms(a[3]) // 40
            if g in want: fr[g][cur] = (float(a[5]), float(a[7])); sec_of[g] = sec
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            cur = pid if tid in team_of else None
            if cur: who[pid] = team_of[tid]
    # own goal side per team per section, from its keeper's mean x
    gx = collections.defaultdict(list)
    for g, ps in fr.items():
        for pid, p in ps.items():
            if pid in keepers: gx[(sec_of[g], who[pid])].append(p[0])
    side = {k: (-1 if sum(v) / len(v) < 0 else 1) for k, v in gx.items()}
    out = []
    for t, pa, rc, h, ok, tp in passes:
        g = next((u for u in range(t, t - 5, -1) if u in fr and rc in fr[u] and pa in fr[u]), None)
        if g is None or who.get(rc) != tp or who.get(pa) != tp: continue   # Recipient on a lost pass can be the opponent who took it
        ps = fr[g]; team = who[rc]
        if (sec_of[g], team) not in side: continue
        def nearest(p):
            return min((math.hypot(q[0] - p[0], q[1] - p[1]) for pid, q in ps.items() if who[pid] != team and pid not in keepers), default=99)
        r = ps[rc]; own = half - r[0] * side[(sec_of[g], team)]
        z = 0 if own < 35 else 1 if own < 70 else 2
        alt = []   # every other outfielder of his side then: (zone, nearest opponent)
        for pid, q in ps.items():
            if who[pid] == team and pid not in keepers and pid != pa:
                o = half - q[0] * side[(sec_of[g], team)]; alt.append((0 if o < 35 else 1 if o < 70 else 2, nearest(q)))
        out.append((h == "high", z, nearest(r), nearest(ps[pa]), ok, math.hypot(r[0] - ps[pa][0], r[1] - ps[pa][1]), alt))
    return out

if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_03_02_events_raw_*.xml")))
    allr = []
    with multiprocessing.Pool(3) as pool:
        for r in pool.imap_unordered(one, files): allr += r
    tm = 2 * len(files)
    def q(v):
        v = sorted(v); return f"{v[len(v)//4]:4.1f}/{v[len(v)//2]:4.1f}/{v[3*len(v)//4]:4.1f}" if v else "-"
    print(f"{len(files)} DFL matches: RECEIVER'S MARKER AT THE KICK, open-play passes naming a recipient: {len(allr)/tm:.1f} a team-match")
    print("  height, recipient's zone (m off the passer's own goal): a team-match | recipient's nearest opponent p25/med/p75 | within 2 m % | within 3.5 m % | 5 m+ free % | passer's nearest opponent med | pass length med || every other outfielder of the passer's side in the same zone at that kick (the men he could have picked)")
    for hi, hn in ((False, "flat"), (True, "high")):
        for z, nm in enumerate(("0-35", "35-70", "70+")):
            v = [r for r in allr if r[0] == hi and r[1] == z]
            if not v: continue
            n = len(v); al = [d for r in v for zz, d in r[6] if zz == z]
            print(f"   {hn:4s} {nm:6s} {n/tm:5.1f} | {q([r[2] for r in v])} | {100*sum(r[2] < 2 for r in v)/n:4.1f} | {100*sum(r[2] < 3.5 for r in v)/n:4.1f} | {100*sum(r[2] >= 5 for r in v)/n:4.1f} | {sorted(r[3] for r in v)[n//2]:4.1f} | {sorted(r[5] for r in v)[n//2]:4.1f} || every mate in that zone then: med {sorted(al)[len(al)//2]:4.1f}, within 2 m {100*sum(d < 2 for d in al)/len(al):4.1f}%, 5 m+ {100*sum(d >= 5 for d in al)/len(al):4.1f}%")

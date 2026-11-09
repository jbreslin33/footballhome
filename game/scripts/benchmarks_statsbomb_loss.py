#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_loss.py — how real 2015/16 Premier League sides lose the ball in
open play, by how long they had had it (G5.71, game/DESIGN.md §8.172). A possession is lost in open
play when the next possession is the other side's and starts in play (play pattern Regular Play,
From Counter or From Keeper). Its age = seconds from its first event to the next possession's first.
How it ended = the losing side's last on-ball event: pass (long = 30 m+, high = StatsBomb High Pass),
clearance, shot, duel / dispossessed, miscontrol, other; and how it began (won in open play or a
restart).

    benchmarks_statsbomb_loss.py <events dir>

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data).
"""
import collections, glob, json, os, sys

SX, SY = 105 / 120, 68 / 80
OPEN = {"Regular Play", "From Counter", "From Keeper"}
ON = {"Pass", "Carry", "Shot", "Clearance", "Dispossessed", "Miscontrol", "Duel", "Dribble", "Ball Receipt*"}
AGES = (3, 6, 10, 20)
def ts(e):
    h, m, s = e["timestamp"].split(":"); return int(h) * 3600 + int(m) * 60 + float(s)
def age_b(a): return next((i for i, x in enumerate(AGES) if a < x), len(AGES))
def how(evs, team):
    last = None
    for e in evs:
        if e.get("team", {}).get("id") != team or e["type"]["name"] not in ON or e["type"]["name"] == "Ball Receipt*": continue
        last = e
    if last is None: return "other"
    n = last["type"]["name"]
    if n == "Pass":
        p = last["pass"]; a, b = last["location"], p["end_location"]
        ln = (((b[0] - a[0]) * SX) ** 2 + ((b[1] - a[1]) * SY) ** 2) ** 0.5
        return "pass long" if ln >= 30 else "pass high" if p.get("height", {}).get("name") == "High Pass" else "pass short"
    if n == "Carry": return "carry"
    if n == "Shot": return "shot"
    if n == "Clearance": return "clearance"
    if n == "Miscontrol": return "miscontrol"
    return "duel"
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
C = collections.Counter(); W = collections.Counter(); N = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    poss = collections.OrderedDict()
    for e in ev:
        if e["period"] > 4: continue
        poss.setdefault((e["period"], e["possession"]), []).append(e)
    keys = list(poss)
    for i in range(len(keys) - 1):
        k, k2 = keys[i], keys[i + 1]
        if k[0] != k2[0]: continue
        P, Q = poss[k], poss[k2]
        t, t2 = P[0]["possession_team"]["id"], Q[0]["possession_team"]["id"]
        won = P[0]["play_pattern"]["name"] in OPEN
        N["won" if won else "restart"] += 1
        if t == t2 or Q[0]["play_pattern"]["name"] not in OPEN: continue
        a = ts(Q[0]) - ts(P[0]); b = age_b(a); h = how(P, t)
        C[(b, h)] += 1; C[(b, "n")] += 1; C["n"] += 1; C[("won", b)] += won
        W[(b, Q[0]["type"]["name"])] += 1
tm = 2 * len(files)
names = ["<3 s", "3-6", "6-10", "10-20", "20+"]
hows = ["pass short", "pass high", "pass long", "clearance", "duel", "miscontrol", "carry", "shot", "other"]
print(f"{len(files)} StatsBomb PL 15/16 matches: OPEN-PLAY LOSSES {C['n']/tm:.1f} a team-match (possessions begun in open play {N['won']/tm:.1f}, from a restart {N['restart']/tm:.1f})")
print("  by the lost possession's age: a team-match (share) | it began in open play % | how it ended, % of the band: " + " / ".join(hows))
for b in range(len(names)):
    n = C[(b, "n")]
    if not n: continue
    print(f"     {names[b]:6s} {n/tm:5.1f} ({100*n/C['n']:4.1f}%) | {100*C[('won', b)]/n:4.1f}% | " + " / ".join(f"{100*C[(b, h)]/n:4.1f}" for h in hows))
print("  the next possession's first event, % of the band: " + ", ".join(f"{names[b]}: " + " ".join(f"{t} {100*c/C[(b,'n')]:.0f}" for (bb, t), c in W.most_common() if bb == b and 100 * c / C[(b, 'n')] >= 3) for b in range(len(names))))

# The passes after a win (§8.172): the side's open-play passes by seconds since its possession began,
# for possessions begun in open play v from a restart — forward metres (toward their goal) p25/med/p75,
# share 10 m+ forward, share back (any metres), completed %; and by the ball's band at the pass.
def zb5(x): d = (120 - x) * SX; return 0 if d < 35 else 1 if d < 52 else 2 if d < 70 else 3
PA = collections.defaultdict(list)
for f in files:
    ev = json.load(open(f, encoding="utf8"))
    t0 = {}
    for e in ev:
        if e["period"] > 4: continue
        k = (e["period"], e["possession"])
        if k not in t0: t0[k] = (ts(e), e["play_pattern"]["name"] in OPEN)
        if e["type"]["name"] != "Pass" or e["pass"].get("type") is not None: continue
        if e.get("team", {}).get("id") != e["possession_team"]["id"]: continue
        st, won = t0[k]; a = ts(e) - st
        ab = 0 if a < 3 else 1 if a < 6 else 2 if a < 10 else 3
        fwd = (e["pass"]["end_location"][0] - e["location"][0]) * SX
        PA[(won, ab, zb5(e["location"][0]))].append((fwd, "outcome" not in e["pass"]))
        PA[(won, ab, -1)].append((fwd, "outcome" not in e["pass"]))
print("  OPEN-PLAY PASSES by seconds since the possession began: passes a team-match | forward m p25/med/p75 | 10 m+ forward % | back % | completed %")
ZN5 = ["ball 70+ off own goal", "52-70", "35-52", "0-35"]
for won in (True, False):
    for zz in (-1, 3, 2, 1, 0):
        for ab, nm in enumerate(("<3 s", "3-6", "6-10", "10+")):
            v = PA[(won, ab, zz)]
            if not v: continue
            fw = sorted(x for x, _ in v)
            print(f"     {'won in play' if won else 'restart':11s} {('all' if zz < 0 else ZN5[zz]):24s} {nm:5s} {len(v)/tm:5.1f} | {fw[len(fw)//4]:5.1f}/{fw[len(fw)//2]:5.1f}/{fw[3*len(fw)//4]:5.1f} | {100*sum(x >= 10 for x in fw)/len(fw):4.1f} | {100*sum(x < 0 for x in fw)/len(fw):4.1f} | {100*sum(c for _, c in v)/len(v):4.1f}")

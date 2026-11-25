#!/usr/bin/env python3
"""benchmarks_statsbomb_takeon_fail.py — how a real take-on ends, 2015/16 Premier League (G5.260, game/DESIGN.md §8.366).

    python3 -I game/scripts/benchmarks_statsbomb_takeon_fail.py <events dir>

Every Dribble (StatsBomb's take-on: an attempt to beat a man), by the carrier's m off the line he attacks: tried /
completed a team-match; the failed ones by the related opponent event — a Tackle duel won (Won / Success In Play /
Success Out: the tackler's side has it), a Tackle duel lost (Lost In Play / Lost Out: knocked away, nobody's or out),
or Dribbled Past but Incomplete (he beat him and lost it after); then who has the ball next (the first event of
either side that is not a Pressure / Duel / Dribbled Past / receipt), and for a completed one whether his side shoots
within 10 s. Beside them, Dispossessed (taken off him with no take-on tried) and Miscontrol, by the same bands.
Pitch: StatsBomb 120 x 80 scaled to 105 x 68.

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, os, sys
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
tm = 2 * len(files)
SX = 105 / 120
BN = ("0-18", "18-35", "35-52", "52-70", "70+")
def band(x):
    tl = (120 - x) * SX
    return 0 if tl < 18 else 1 if tl < 35 else 2 if tl < 52 else 3 if tl < 70 else 4
def secs(e): return e["minute"] * 60 + e["second"]
SKIP = ("Pressure", "Duel", "Dribbled Past", "Ball Receipt*", "Carry", "Dribble")
C = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8")); byid = {e["id"]: e for e in ev}
    for i, e in enumerate(ev):
        tn = e["type"]["name"]
        if "location" not in e: continue
        b = band(e["location"][0]); me = e["team"]["id"]
        if tn in ("Dispossessed", "Miscontrol"): C[(b, tn)] += 1; continue
        if tn != "Dribble": continue
        ok = e["dribble"].get("outcome", {}).get("name") == "Complete"
        C[(b, "tried")] += 1; C[(b, "ok")] += ok
        if ok:
            t0 = secs(e)
            for n in ev[i + 1:i + 60]:
                if secs(n) - t0 > 10 or n["period"] != e["period"]: break
                if n["type"]["name"] == "Shot" and n["team"]["id"] == me: C[(b, "ok_shot10")] += 1; break
            continue
        rel = [byid[r] for r in e.get("related_events", []) if r in byid]
        tk = [r for r in rel if r["type"]["name"] == "Duel" and r.get("duel", {}).get("type", {}).get("name") == "Tackle"]
        if tk:
            o = tk[0]["duel"].get("outcome", {}).get("name", "")
            how = "tackled: theirs" if o in ("Won", "Success In Play", "Success Out") else "tackled: knocked loose" + (" out" if "Out" in o else " in play")
        elif any(r["type"]["name"] == "Dribbled Past" for r in rel): how = "past him, then lost it"
        else: how = "other"
        C[(b, "fail", how)] += 1
        for n in ev[i + 1:i + 30]:
            if n["type"]["name"] in SKIP: continue
            C[(b, "fail_next", how, "own" if n["team"]["id"] == me else "opp")] += 1; break
for b in range(5):
    n = C[(b, "tried")]
    if not n: continue
    print(f"{BN[b]}: take-ons {n/tm:.2f} tried / {C[(b,'ok')]/tm:.2f} completed [{100*C[(b,'ok')]/n:.1f}%]; completed -> his side shoots within 10 s {100*C[(b,'ok_shot10')]/max(1,C[(b,'ok')]):.1f}%")
    fails = n - C[(b, "ok")]
    for how in ("tackled: theirs", "tackled: knocked loose in play", "tackled: knocked loose out", "past him, then lost it", "other"):
        k = C[(b, "fail", how)]
        if not k: continue
        own = C[(b, "fail_next", how, "own")]; opp = C[(b, "fail_next", how, "opp")]
        print(f"   {how:32s} {k/tm:5.2f} ({100*k/fails:4.1f}% of failed)  next ball own/opp {100*own/max(1,own+opp):.0f}/{100*opp/max(1,own+opp):.0f}%")
    print(f"   beside it: Dispossessed {C[(b,'Dispossessed')]/tm:.2f}, Miscontrol {C[(b,'Miscontrol')]/tm:.2f}")
T = lambda k: sum(v for kk, v in C.items() if kk[1:] == k)
print(f"ALL: take-ons {T(('tried',))/tm:.2f} / {T(('ok',))/tm:.2f} [{100*T(('ok',))/T(('tried',)):.1f}%]; Dispossessed {T(('Dispossessed',))/tm:.2f}; Miscontrol {T(('Miscontrol',))/tm:.2f}")
fl = T(('tried',)) - T(('ok',))
for how in ("tackled: theirs", "tackled: knocked loose in play", "tackled: knocked loose out", "past him, then lost it", "other"):
    print(f"   {how:32s} {T(('fail',how))/tm:5.2f} ({100*T(('fail',how))/fl:.1f}%)")

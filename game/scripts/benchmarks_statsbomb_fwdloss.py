#!/usr/bin/env python3
"""benchmarks_statsbomb_fwdloss.py — the forward ground pass a real side loses, and how a blocked pass is booked,
2015/16 Premier League (G5.233, game/DESIGN.md §8.339).

    python3 -I game/scripts/benchmarks_statsbomb_fwdloss.py <events dir>

Part 1: open-play forward passes by a foot, Ground + Low (within 45 deg of their goal; set pieces, headers and High
out), by the kick's m off the line attacked (70+ = own third): tried / not completed a team-match, split by the
passer's under_pressure flag, his position, Ground v Low, wide (20 m+ off the middle) v central; the lost ones by
outcome, whether a recipient is named, m to where they ended, and the next event.
Part 2: every open-play pass with an opponent's Block among its related events, by outcome — StatsBomb books a
blocked pass Incomplete whoever has the ball next; the `deflected` flag marks the few that still arrive.
Pitch: StatsBomb 120 x 80 scaled to 105 x 68.

Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, sys
SET = ("Corner", "Free Kick", "Throw-in", "Goal Kick", "Kick Off")
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
tm = 2 * len(files)
SX, SY = 105/120, 68/80
BN=("18-35","35-52","52-70","70+")
def band(x):
    tl=(120-x)*SX
    return None if tl<18 else 0 if tl<35 else 1 if tl<52 else 2 if tl<70 else 3
C=collections.Counter(); L=collections.defaultdict(list)
for f in files:
    ev=json.load(open(f,encoding="utf8"))
    for i,e in enumerate(ev):
        if e["type"]["name"]!="Pass" or "location" not in e: continue
        b=band(e["location"][0]); p=e["pass"]
        if b is None: continue
        if p.get("type",{}).get("name") in SET or p.get("body_part",{}).get("name")=="Head": continue
        out=p.get("outcome",{}).get("name")
        if out not in (None,"Incomplete","Out"): continue
        if p.get("height",{}).get("name")=="High Pass": continue
        dx=(p["end_location"][0]-e["location"][0])*SX; dy=(p["end_location"][1]-e["location"][1])*SY
        if dx<abs(dy): continue
        d=math.hypot(dx,dy); bad=out is not None
        up=bool(e.get("under_pressure")); gk=e["position"]["name"]=="Goalkeeper"
        pos=e["position"]["name"]
        role="GK" if gk else "CB" if "Center Back" in pos else "FB" if ("Back" in pos) else "DM/CM" if ("Midfield" in pos and ("Center" in pos or "Defensive" in pos)) else "other"
        C[(b,"n")]+=1; C[(b,"bad")]+=bad; C[(b,"up",up,"n")]+=1; C[(b,"up",up,"bad")]+=bad
        C[(b,"role",role,"n")]+=1; C[(b,"role",role,"bad")]+=bad
        C[(b,"low",p.get("height",{}).get("name"),"n")]+=1; C[(b,"low",p.get("height",{}).get("name"),"bad")]+=bad
        wide = abs(e["location"][1]-40)*SY>=20
        C[(b,"wide",wide,"n")]+=1; C[(b,"wide",wide,"bad")]+=bad
        if bad:
            C[(b,"out",out)]+=1; L[(b,"len")].append(d)
            C[(b,"hasrec",bool(p.get("recipient")))]+=1
            # next event by anyone not same pass
            for j in range(i+1,min(i+8,len(ev))):
                n=ev[j]; tn=n["type"]["name"]
                if tn in ("Ball Receipt*","Pressure") : continue
                C[(b,"next",("opp " if n["team"]["id"]!=e["team"]["id"] else "own ")+tn)]+=1; break
for b in (3,2,1):
    n=C[(b,"n")]
    print(f"{BN[b]}: forward ground(+low) passes {n/tm:.2f} / lost {C[(b,'bad')]/tm:.2f} [{100*C[(b,'bad')]/n:.0f}%]")
    for up in (False,True): print(f"   pressed={up}: {C[(b,'up',up,'n')]/tm:.2f} / {C[(b,'up',up,'bad')]/tm:.2f} [{100*C[(b,'up',up,'bad')]/max(1,C[(b,'up',up,'n')]):.0f}%]")
    for r in ("GK","CB","FB","DM/CM","other"): print(f"   {r}: {C[(b,'role',r,'n')]/tm:.2f} / {C[(b,'role',r,'bad')]/tm:.2f} [{100*C[(b,'role',r,'bad')]/max(1,C[(b,'role',r,'n')]):.0f}%]")
    for r in ("Ground Pass","Low Pass"): print(f"   {r}: {C[(b,'low',r,'n')]/tm:.2f} / {C[(b,'low',r,'bad')]/tm:.2f} [{100*C[(b,'low',r,'bad')]/max(1,C[(b,'low',r,'n')]):.0f}%]")
    for r in (False,True): print(f"   wide={r}: {C[(b,'wide',r,'n')]/tm:.2f} / {C[(b,'wide',r,'bad')]/tm:.2f} [{100*C[(b,'wide',r,'bad')]/max(1,C[(b,'wide',r,'n')]):.0f}%]")
    print("   outcome:", {k[2]:round(v/tm,2) for k,v in C.items() if k[0]==b and k[1]=="out"}, "recipient named:", {k[2]:round(v/tm,2) for k,v in C.items() if k[0]==b and k[1]=="hasrec"})
    v=sorted(L[(b,"len")]); print("   lost: m to where it ended p25/med/p75", [round(v[int(q*len(v))],1) for q in (.25,.5,.75)])
    print("   next:", sorted(((round(v/tm,2),k[2]) for k,v in C.items() if k[0]==b and k[1]=="next"),reverse=True)[:8])

C = collections.Counter()   # part 2
for f in files:
    ev=json.load(open(f,encoding="utf8")); byid={e["id"]:e for e in ev}
    for e in ev:
        if e["type"]["name"]!="Pass": continue
        p=e["pass"]
        if p.get("type",{}).get("name") in SET: continue
        out=p.get("outcome",{}).get("name") or "Complete"
        C[("all",out)]+=1
        if p.get("deflected"): C[("deflected flag",out)]+=1
        blk=[byid[r] for r in e.get("related_events",[]) if r in byid and byid[r]["type"]["name"]=="Block" and byid[r]["team"]["id"]!=e["team"]["id"]]
        if blk:
            C[("opp block related",out)]+=1
            b=blk[0].get("block",{})
            C[("block kind", "deflection" if b.get("deflection") else "plain", out)]+=1
for k,v in sorted(C.items(), key=lambda kv:(str(kv[0][0]),-kv[1])): print(k, round(v/tm,2))

# part 3 (G5.234, §8.340): midfield (kick 35-70 m off the line attacked) open-play passes by a foot not completed, by
# direction (45 deg cones, to where the ball ended) and how: Ground + Low — an opponent's Block among the related
# events and ended within 8 m | Block / Interception / their Duel, Clearance or keeper beyond 8 m ("their touch") |
# their Ball Recovery or pass next ("theirs clean" — nobody got to it in flight) | Out | other; High apart.
C = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8")); byid = {e["id"]: e for e in ev}
    for i, e in enumerate(ev):
        if e["type"]["name"] != "Pass" or "location" not in e: continue
        b = band(e["location"][0]); p = e["pass"]
        if b not in (1, 2) or p.get("type", {}).get("name") in SET or p.get("body_part", {}).get("name") == "Head": continue
        out = p.get("outcome", {}).get("name")
        if out not in (None, "Incomplete", "Out"): continue
        dx = (p["end_location"][0] - e["location"][0]) * SX; dy = (p["end_location"][1] - e["location"][1]) * SY
        d = math.hypot(dx, dy); dr = 0 if dx >= abs(dy) else 2 if -dx >= abs(dy) else 1
        C[(dr, "tried", p.get("height", {}).get("name") == "High Pass")] += 1
        if out is None: continue
        if p.get("height", {}).get("name") == "High Pass": C[(dr, 5)] += 1; continue
        if out == "Out": C[(dr, 3)] += 1; continue
        rel = [byid[r] for r in e.get("related_events", []) if r in byid and byid[r]["team"]["id"] != e["team"]["id"]]
        blk = any(r["type"]["name"] == "Block" for r in rel)
        nxt = next((n for n in ev[i + 1:i + 8] if n["type"]["name"] not in ("Ball Receipt*", "Pressure")), None)
        nt = nxt["type"]["name"] if nxt is not None and nxt["team"]["id"] != e["team"]["id"] else ""
        if blk and d < 8: C[(dr, 0)] += 1
        elif blk or nt in ("Interception", "Duel", "Clearance", "Goal Keeper", "Block"): C[(dr, 1)] += 1
        elif nt in ("Ball Recovery", "Pass", "Carry", "Dribble", "Shot", "Miscontrol", "Foul Committed"): C[(dr, 2)] += 1
        else: C[(dr, 4)] += 1
print("MIDFIELD PASSES NOT COMPLETED, HOW (35-70 m), a team-match: ground blocked <8 m | their touch beyond | theirs clean | out | other | high")
for dr, dn in enumerate(("forward", "square", "back")):
    print(f"  {dn}: " + " | ".join(f"{C[(dr, k)] / tm:.2f}" for k in range(6)))
print("C++ rows: " + ", ".join("{" + ", ".join(f"{C[(dr, k)] / tm:.2f}" for k in range(6)) + "}" for dr in range(3)))
print("  tried, ground / high: " + "; ".join(f"{dn} {C[(dr, 'tried', False)] / tm:.1f} / {C[(dr, 'tried', True)] / tm:.1f}" for dr, dn in enumerate(("forward", "square", "back"))))

# part 4 (G5.234, §8.340): midfield origin (35-70 m off the passer's own goal), open-play foot passes of 5 m+ by the angle
# off straight-at-their-goal x length: a team-match, the High share, and the share of the high ones not completed.
C=collections.Counter()
for f in files:
    for e in json.load(open(f,encoding="utf8")):
        if e["type"]["name"]!="Pass" or "location" not in e: continue
        p=e["pass"]
        if p.get("type",{}).get("name") in SET or p.get("body_part",{}).get("name")=="Head": continue
        out=p.get("outcome",{}).get("name")
        if out not in (None,"Incomplete","Out"): continue
        own=e["location"][0]*SX
        if not (35<=own<70): continue
        dx=(p["end_location"][0]-e["location"][0])*SX; dy=(p["end_location"][1]-e["location"][1])*SY
        d=math.hypot(dx,dy)
        if d<5: continue
        a=math.degrees(math.atan2(abs(dy),dx)); ab=0 if a<30 else 1 if a<45 else 2 if a<60 else 3 if a<90 else 4 if a<120 else 5
        lb=0 if d<10 else 1 if d<20 else 2 if d<30 else 3 if d<40 else 4
        hi=p.get("height",{}).get("name")=="High Pass"
        C[(ab,lb,"n")]+=1; C[(ab,lb,"hi")]+=hi; C[(ab,lb,"hibad")]+= hi and out is not None
print("midfield origin (35-70 m off own goal), open-play foot passes 5 m+: by angle off straight-at-goal x length: n a team-match, high %, [high lost %]")
for ab,an in enumerate(("0-30","30-45","45-60","60-90","90-120","120+")):
    print(f"  {an:7s} "+" | ".join(f"{C[(ab,lb,'n')]/tm:5.1f} {100*C[(ab,lb,'hi')]/max(1,C[(ab,lb,'n')]):3.0f}% [{100*C[(ab,lb,'hibad')]/max(1,C[(ab,lb,'hi')]):2.0f}]" for lb in range(5)), f"|| high a team-match {sum(C[(ab,lb,'hi')] for lb in range(5))/tm:.1f}")

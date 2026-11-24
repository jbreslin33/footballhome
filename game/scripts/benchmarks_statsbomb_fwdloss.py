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

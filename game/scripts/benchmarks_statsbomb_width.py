#!/usr/bin/env python3
"""benchmarks_statsbomb_width.py — where the ball is played and where passes are blocked, by the lines (G5.166, game/DESIGN.md §8.272).

    python3 -I game/scripts/benchmarks_statsbomb_width.py <PL 15/16 events dir>

StatsBomb Open Data, Premier League 2015/16, every match. (1) Blocked open-play passes (a Block linked to the pass)
by the block's metres off the nearer touchline (0-5 / 5-10 / 10-20 / 20+) and off the goal line the blockers defend
(0-18 / 18-35 / 35-70 / 70+): the share, and how many went out next for a corner / throw-in / goal kick (the next
located event that is not the Block, a Ball Receipt, Pressure, Duel or foul, within 90 s). (2) Open-play passes by
where they were struck, the same bands; completed ones by where they ended (the receiver). fh-game-match's PASSES
CHARGED DOWN block prints ours on the same bands. Pitch 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data, free
with attribution to StatsBomb. FH original.
"""
import collections, glob, json, math, os, statistics, sys

SX, SY = 105/120, 68/80
SET=("Corner","Free Kick","Throw-in","Goal Kick","Kick Off")
def secs(e):
    h,m,s=e["timestamp"].split(":"); return e["period"]*10000+int(h)*3600+int(m)*60+float(s)
SKIP=("Block","Ball Receipt*","Pressure","Duel","Foul Committed","Foul Won")
side=collections.Counter(); sideout=collections.Counter(); depth=collections.Counter(); depthc=collections.Counter(); n=0
tl=[]; gl=[]; outs=collections.Counter()
for f in glob.glob(os.path.join(sys.argv[1],"*.json")):
    if not os.path.basename(f)[0].isdigit(): continue
    ev=json.load(open(f)); byid={e["id"]:e for e in ev}
    for i,e in enumerate(ev):
        if e["type"]["name"]!="Block" or "location" not in e: continue
        src=next((byid[r] for r in e.get("related_events",[]) if r in byid and byid[r]["type"]["name"]=="Pass" and "location" in byid[r]),None)
        if src is None or src["pass"].get("type",{}).get("name") in SET: continue
        # in the passer's frame (attacking +x)
        bx,by=120-e["location"][0],80-e["location"][1]
        dtouch=min(by,80-by)*SY; dgoal=(120-bx)*SX
        t0=secs(e); nxt=None
        for g in ev[i+1:i+25]:
            if secs(g)-t0>90: break
            if g["type"]["name"] in SKIP or "location" not in g: continue
            nxt=g; break
        if nxt is None: continue
        pt=nxt.get("pass",{}).get("type",{}).get("name") if nxt["type"]["name"]=="Pass" else None
        end="corner" if pt=="Corner" else "throw" if pt=="Throw-in" else "gk" if pt=="Goal Kick" else "play"
        n+=1
        b="0-5" if dtouch<5 else "5-10" if dtouch<10 else "10-20" if dtouch<20 else "20+"
        side[b]+=1; sideout[(b,end)]+=1
        d="their 0-18" if dgoal<18 else "18-35" if dgoal<35 else "35-70" if dgoal<70 else "own 35"
        depth[d]+=1; depthc[(d,end)]+=1
        tl.append(dtouch); gl.append(dgoal)
print("blocked open-play passes",n)
print("by metres off the touchline: share | corner / throw-in / goal kick %")
for b in ("0-5","5-10","10-20","20+"):
    k=side[b]; print(f"  {b:6s} {100*k/n:5.1f}% | "+" / ".join(f"{100*sideout[(b,e)]/k:.1f}" for e in ("corner","throw","gk")))
print("by metres off their goal line:")
for d in ("their 0-18","18-35","35-70","own 35"):
    k=depth[d]; print(f"  {d:10s} {100*k/n:5.1f}% | "+" / ".join(f"{100*depthc[(d,e)]/k:.1f}" for e in ("corner","throw","gk")))
q=lambda a:" / ".join(f"{x:.1f}" for x in statistics.quantiles(a,n=4))
print("touchline m",q(tl),"| their goal line m",q(gl))

print("--- passes ---")
SY=68/80; SET=("Corner","Free Kick","Throw-in","Goal Kick","Kick Off")
c=collections.Counter(); g=collections.Counter(); n=0
for f in glob.glob(os.path.join(sys.argv[1],"*.json")):
    if not os.path.basename(f)[0].isdigit(): continue
    for e in json.load(open(f)):
        if e["type"]["name"]!="Pass" or e["pass"].get("type",{}).get("name") in SET: continue
        x,y=e["location"]; tl=min(y,80-y)*SY; n+=1
        c["0-5" if tl<5 else "5-10" if tl<10 else "10-20" if tl<20 else "20+"]+=1
        gl=(120-x)*105/120; g["0-18" if gl<18 else "18-35" if gl<35 else "35-70" if gl<70 else "70+"]+=1
print("open-play passes by m off the touchline:"," ".join(f"{b} {100*c[b]/n:.1f}" for b in ("0-5","5-10","10-20","20+")))
print("by m off their goal line:"," ".join(f"{b} {100*g[b]/n:.1f}" for b in ("0-18","18-35","35-70","70+")))
c=collections.Counter(); n=0
for f in glob.glob(os.path.join(sys.argv[1],"*.json")):
    if not os.path.basename(f)[0].isdigit(): continue
    for e in json.load(open(f)):
        if e["type"]["name"]!="Pass" or e["pass"].get("type",{}).get("name") in SET or "outcome" in e["pass"]: continue
        x,y=e["pass"]["end_location"]; tl=min(y,80-y)*SY; n+=1
        c["0-5" if tl<5 else "5-10" if tl<10 else "10-20" if tl<20 else "20+"]+=1
print("completed passes' end by m off the touchline:"," ".join(f"{b} {100*c[b]/n:.1f}" for b in ("0-5","5-10","10-20","20+")))

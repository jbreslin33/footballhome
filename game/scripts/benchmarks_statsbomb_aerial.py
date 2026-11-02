#!/usr/bin/env python3
"""benchmarks_statsbomb_aerial.py - pro headers and aerial duels (G5.3,
game/DESIGN.md section 8.101), from StatsBomb Open Data.

    python3 -I game/scripts/benchmarks_statsbomb_aerial.py <cache_dir> <matches>

Premier League 2015/16 (competition 2, season 27), the same seeded sample as
benchmarks_statsbomb_restarts.py. An aerial duel = one Duel event of type
"Aerial Lost" (StatsBomb records the loser), or a Clearance / Pass / Shot /
Miscontrol flagged aerial_won. Goals after a corner = play pattern "From Corner".
Data: StatsBomb Open Data, free to use with attribution to StatsBomb.
"""
import json,os,sys,urllib.request,random
from concurrent.futures import ThreadPoolExecutor
BASE="https://raw.githubusercontent.com/statsbomb/open-data/master/data"
D=sys.argv[1]; N=int(sys.argv[2])
def get(u,p):
    if not os.path.exists(p):
        for k in range(5):
            try:
                d=urllib.request.urlopen(u,timeout=30).read(); open(p,'wb').write(d); break
            except OSError: pass
    return json.load(open(p))
ms=get(f"{BASE}/matches/2/27.json",f"{D}/m.json"); random.seed(7); random.shuffle(ms); ms=ms[:N]
with ThreadPoolExecutor(8) as ex:
    evs=list(ex.map(lambda m:get(f"{BASE}/events/{m['match_id']}.json",f"{D}/{m['match_id']}.json"),ms))
c=dict(shots=0,goals=0,hs=0,hg=0,hot=0,lost=0,won=0,cg=0,cs=0,chs=0,chg=0,corners=0,box=0,bh=0,dclear=0)
for E in evs:
    for e in E:
        n=e['type']['name']
        if n=='Duel' and e['duel']['type']['name']=='Aerial Lost': c['lost']+=1
        for k in('clearance','pass','shot','miscontrol'):
            if e.get(k,{}).get('aerial_won'): c['won']+=1
        if n=='Clearance' and e.get('clearance',{}).get('body_part',{}).get('name')=='Head': c['dclear']+=1
        if n=='Pass' and e['pass'].get('type',{}).get('name')=='Corner': c['corners']+=1
        if n!='Shot' or e['shot']['type']['name']=='Penalty': continue
        h=e['shot']['body_part']['name']=='Head'; o=e['shot']['outcome']['name']
        g=o=='Goal'; ot=o in('Goal','Saved','Saved To Post')
        cn=e['play_pattern']['name']=='From Corner'
        c['shots']+=1; c['goals']+=g; c['hs']+=h; c['hg']+=h and g; c['hot']+=h and ot
        c['cs']+=cn; c['cg']+=cn and g; c['chs']+=cn and h; c['chg']+=cn and h and g
tm=len(evs)*2; m=len(evs)
print('matches',m)
print('headed shots a team %.2f (%.1f%% of shots), headed goals a match %.2f, conversion %.1f%%, on target %.1f%%'%(c['hs']/tm,100*c['hs']/c['shots'],c['hg']/m,100*c['hg']/max(c['hs'],1),100*c['hot']/max(c['hs'],1)))
print('aerial duels lost %.1f, won flagged %.1f a match; headed clearances a team %.1f'%(c['lost']/m,c['won']/m,c['dclear']/tm))
print('corners a match %.1f; from-corner shots %.1f a match, goals %.2f; per corner: shot %.1f%%, goal %.1f%%; headed from corner %.1f shots, %.2f goals a match'%(c['corners']/m,c['cs']/m,c['cg']/m,100*c['cs']/c['corners'],100*c['cg']/c['corners'],c['chs']/m,c['chg']/m))

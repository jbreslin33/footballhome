#!/usr/bin/env python3
"""benchmarks_statsbomb_restarts.py - pro throw-ins, goal kicks and corners
(G5.2, game/DESIGN.md section 8.100), from StatsBomb Open Data.

    python3 -I game/scripts/benchmarks_statsbomb_restarts.py <cache_dir> <matches>

Premier League 2015/16 (competition 2, season 27), a seeded random sample; the
numbers in mig 922 are the 60-match run. Dead time = end of the event before the
restart to the restart. Goal kicks predate the 2019 law.
Data: StatsBomb Open Data, free to use with attribution to StatsBomb.
"""
import json,os,sys,urllib.request,statistics as st,random
from concurrent.futures import ThreadPoolExecutor
BASE="https://raw.githubusercontent.com/statsbomb/open-data/master/data"; YD=.9144
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
def t(e): 
    h,m,s=e['timestamp'].split(':'); return int(h)*3600+int(m)*60+float(s)
R={k:{'n':0,'dead':[],'len':[],'ok':0,'h':{},'shot10':0} for k in('Throw-in','Goal Kick','Corner')}
inplay=[]
for E in evs:
    E=[e for e in E if e['type']['name'] not in('Starting XI','Half Start','Half End','Tactics','Substitution','Player On','Player Off')]
    for i,e in enumerate(E):
        if e['type']['name']!='Pass': continue
        k=e['pass'].get('type',{}).get('name')
        if k not in R: continue
        r=R[k]; r['n']+=1
        # dead time: end of the last event before it in the same period
        j=i-1
        while j>=0 and E[j]['type']['name'] in('Ball Receipt*',): j-=1
        if j>=0 and E[j]['period']==e['period']:
            p=E[j]; d=t(e)-(t(p)+p.get('duration',0) or 0)
            if 0<=d<120: r['dead'].append(d)
        r['len'].append(e['pass']['length']*YD)
        r['ok']+= 'outcome' not in e['pass']
        h=e['pass']['height']['name']; r['h'][h]=r['h'].get(h,0)+1
        for q in E[i+1:i+40]:
            if q['period']!=e['period'] or t(q)-t(e)>10: break
            if q['type']['name']=='Shot' and q['team']['id']==e['team']['id']: r['shot10']+=1; break
tm=len(evs)*2
for k,r in R.items():
    d=sorted(r['dead']); l=sorted(r['len'])
    q=lambda a,p:a[int(len(a)*p)]
    print(k,'per team-match %.1f'%(r['n']/tm),'dead median %.1f p25 %.1f p75 %.1f mean %.1f'%(st.median(d),q(d,.25),q(d,.75),st.mean(d)),
      'len median %.1f p25 %.1f p75 %.1f p90 %.1f'%(st.median(l),q(l,.25),q(l,.75),q(l,.9)),'complete %.0f%%'%(100*r['ok']/r['n']),'height',r['h'],'shot<=10s %.1f%%'%(100*r['shot10']/r['n']),
      '<=15m %.0f%%'%(100*sum(x<=15 for x in l)/len(l)),'<=35m %.0f%%'%(100*sum(x<=35 for x in l)/len(l)))
print('matches',len(evs))

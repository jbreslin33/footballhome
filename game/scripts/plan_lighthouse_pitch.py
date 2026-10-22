#!/usr/bin/env python3
"""Plan the Lighthouse Field soccer pitch — constrained placement search.

James (2026-10-22): 115 x 74 yd; touchlines EXACTLY 10 ft (no closer)
from the metal foul-ball fence and the softball 3rd-base fence; >= 15 yd
from the main diamond's infield dirt (that strip floods); off all infield
dirt; clear of trees and the rodeo fence; as far toward the rodeo (east)
and the barn (south) as allowed — the cemetery-end goalmouth is worn to
dirt by car traffic.

Obstacles are site metres (x east, z south; origin = LIGHTHOUSE_SITE),
measured on Google's current satellite imagery (0.07-0.14 m/px; each
screenshot calibrated from its URL centre + altitude: 0.001311 m/px per
metre of altitude). The softball 3rd-base fence is the clearly visible
1st-base fence mirrored about home->2nd (the backstop corners are exactly
symmetric). METAL is a PLACEHOLDER until laser-measured on site — update
it and re-run; the result goes into frontend/js/game/lighthouse-layout.js
(gamePitch / realPitch).

Search: 2° x 2 m coarse sweep, then 0.25° x 0.25 m refine (~5 min).
"""
YD=0.9144; L,W=115*YD,74*YD
FT10=10*0.3048; YD15=15*YD
# Google-frame obstacles (site metres, x east, z south)
MAIN_DIRT=[(-68.3,-11.6),(-42.2,-11.6),(-33.6,-8.2),(-29.0,-0.5),(-27.2,10.6),(-27.2,29.0),(-28.3,30.1),(-69,30.1)]
SKIN=[(65.5,-2.4),(69.3,-10.8),(76.3,-14.2),(86.7,-14.6),(93.3,-9.7),(95.4,-5.6),(93.3,0.7),(90.2,6.3),(86.7,17.4),(80.4,12.5),(70.7,5.6),(65.8,2.1)]
FENCE_1B=[(91.55,18.77),(97.46,8.34),(103.02,-1.95)]
FENCE_3B=[(82.86,21.54),(61.51,11.29)]
RODEO=[(93.3,-87.5),(137.1,-20.1)]
METAL=[(-35,33),(45,33)]   # PLACEHOLDER — to be laser-measured
trees=json.loads(open('frontend/js/game/lighthouse-trees.js').read().split('=',1)[1].rstrip().rstrip(';'))
trees=[t for t in trees if -110<t[0]<170 and -150<t[1]<70]
def seg_d(p,a,b):
    dx,dz=b[0]-a[0],b[1]-a[1]; L2=dx*dx+dz*dz
    t=0 if L2==0 else max(0,min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dz)/L2))
    return math.hypot(p[0]-a[0]-t*dx,p[1]-a[1]-t*dz)
def cross(a,b,c,d):
    o=lambda p,q,r:(q[0]-p[0])*(r[1]-p[1])-(q[1]-p[1])*(r[0]-p[0])
    return o(a,b,c)*o(a,b,d)<0 and o(c,d,a)*o(c,d,b)<0
def rect(cx,cz,th):
    c,s=math.cos(th),math.sin(th)
    return [(cx+u*c-v*s,cz+u*s+v*c) for u,v in [(-L/2,-W/2),(L/2,-W/2),(L/2,W/2),(-L/2,W/2)]]
def inside(p,R):
    sg=None
    for i in range(4):
        a,b=R[i],R[(i+1)%4]; cr=(b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0])
        if sg is None: sg=cr>0
        elif (cr>0)!=sg: return False
    return True
def dpoly(R,P,closed):
    pts=P+([P[0]] if closed else [])
    d=1e9
    for i in range(4):
        a,b=R[i],R[(i+1)%4]
        for j in range(len(pts)-1):
            c,e=pts[j],pts[j+1]
            if cross(a,b,c,e): return 0.0
            d=min(d,seg_d(c,a,b),seg_d(e,a,b),seg_d(a,c,e),seg_d(b,c,e))
    if any(inside(p,R) for p in P): return 0.0
    if closed and any(inside(q,P+[]) for q in []): pass
    return d
def side(p,a,b): return (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0])
def metrics(cx,cz,th):
    R=rect(cx,cz,th)
    m=dict(main_infield=dpoly(R,MAIN_DIRT,True), softball_skin=dpoly(R,SKIN,True),
           fence_1B=dpoly(R,FENCE_1B,False), fence_3B=dpoly(R,FENCE_3B,False),
           metal=dpoly(R,METAL,False))
    m['north_of_metal']=all(p[1]<33 for p in R)
    m['west_of_rodeo']=all(side(p,RODEO[0],RODEO[1])>0 for p in R) if side((0,0),RODEO[0],RODEO[1])>0 else all(side(p,RODEO[0],RODEO[1])<0 for p in R)
    m['rodeo']=dpoly(R,RODEO,False)
    m['trees']=min((0 if inside(t,R) else min(seg_d(t,R[i],R[(i+1)%4]) for i in range(4))) for t in trees)
    return m,R
def ok(cx,cz,th):
    m,_=metrics(cx,cz,th)
    return (m['main_infield']>=YD15 and m['softball_skin']>=0.3 and m['fence_1B']>=FT10 and m['fence_3B']>=FT10
            and m['metal']>=FT10 and m['north_of_metal'] and m['west_of_rodeo'] and m['rodeo']>=FT10 and m['trees']>=2.0)
def search(ths,czs,cxs,best=None):
    for thd in ths:
        th=math.radians(thd)
        for cz in czs:
            for cx in cxs:
                sc=cz+0.35*cx
                if best and sc<=best[0]: continue
                if ok(cx,cz,th): best=(sc,cx,cz,thd)
    return best
fr=lambda a,b,st:[a+i*st for i in range(int(round((b-a)/st))+1)]
b=search(fr(0,178,2),fr(-90,10,2),fr(-30,80,2)); print('coarse',b,flush=True)
b=search(fr(b[3]-2,b[3]+2,0.25),fr(b[2]-2.5,b[2]+2.5,0.25),fr(b[1]-2.5,b[1]+2.5,0.25)); print('best',b)
m,R=metrics(b[1],b[2],math.radians(b[3]))
print({k:(round(v,2) if isinstance(v,float) else v) for k,v in m.items()})
print('corners',[(round(x,2),round(z,2)) for x,z in R])
json.dump({'x':b[1],'z':b[2],'rotDeg':b[3],'corners':R,'metrics':m},open('/dev/stdout','w'))

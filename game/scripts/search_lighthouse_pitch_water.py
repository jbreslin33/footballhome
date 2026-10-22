#!/usr/bin/env python3
"""Search every legal 115x74 yd pitch placement at Lighthouse Field and score
its water on USGS 3DEP lidar: 3 x pond m² + 1.5 x runoff-crossing m² + 0.5 x
too-flat m² (< 0.5 %). Legal = plan_lighthouse_pitch.py's rules. Caches the
lidar grids in the scratch dir D; results -> D/water_res.json. Fed the
candidates in lighthouse-layout.js (10/22).
"""
import sys,math,json,heapq,io,urllib.request,urllib.parse,pickle,os
sys.path.insert(0,'game/scripts')
import plan_lighthouse_pitch as P
from PIL import Image
D=os.environ.get('LH_SCRATCH', '/tmp/lighthouse-water/')
os.makedirs(D, exist_ok=True)
LAT0,LON0=40.008229,-75.124772;KX=111320*math.cos(math.radians(LAT0));KZ=110540;R=6378137.0
X0,X1,Z0,Z1=-140,180,-160,110
pk=D+'grids.pkl'
if os.path.exists(pk):
    g,filled,acc=pickle.load(open(pk,'rb'))
else:
    loc2ll=lambda x,z:(LAT0-z/KZ,LON0+x/KX)
    ll2m=lambda la,lo:(math.radians(lo)*R,math.log(math.tan(math.pi/4+math.radians(la)/2))*R)
    la1,lo0=loc2ll(X0-5,Z0-5);la0,lo1=loc2ll(X1+5,Z1+5)
    mx0,my0=ll2m(la0,lo0);mx1,my1=ll2m(la1,lo1);res=0.5/math.cos(math.radians(LAT0))
    W,H=int((mx1-mx0)/res),int((my1-my0)/res)
    q=urllib.parse.urlencode({'bbox':f'{mx0},{my0},{mx1},{my1}','bboxSR':3857,'imageSR':3857,'size':f'{W},{H}','format':'tiff','pixelType':'F32','interpolation':'RSP_BilinearInterpolation','f':'json'})
    UA={'User-Agent':'FootballHome-game/1.0'}
    meta=json.load(urllib.request.urlopen(urllib.request.Request('https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer/exportImage?'+q,headers=UA),timeout=120))
    dv=Image.open(io.BytesIO(urllib.request.urlopen(urllib.request.Request(meta['href'],headers=UA),timeout=120).read())).load()
    e=meta['extent'];w,h=meta['width'],meta['height']
    def elev(x,z):
        la,lo=loc2ll(x,z);mx,my=ll2m(la,lo)
        X=(mx-e['xmin'])/(e['xmax']-e['xmin'])*w-0.5;Y=(e['ymax']-my)/(e['ymax']-e['ymin'])*h-0.5
        i,j=int(X),int(Y);fx,fy=X-i,Y-j
        return dv[i,j]*(1-fx)*(1-fy)+dv[i+1,j]*fx*(1-fy)+dv[i,j+1]*(1-fx)*fy+dv[i+1,j+1]*fx*fy
    xs=range(X0,X1+1);zs=range(Z0,Z1+1);nx,nz=len(xs),len(zs)
    g=[[elev(x,z) for x in xs] for z in zs]
    filled=[[0.0]*nx for _ in range(nz)];seen=[[False]*nx for _ in range(nz)];pq=[];order=[];n=0
    for j in range(nz):
        for i in range(nx):
            if i in(0,nx-1) or j in(0,nz-1): heapq.heappush(pq,(g[j][i],n,i,j));n+=1;seen[j][i]=True
    while pq:
        hh,_,i,j=heapq.heappop(pq);filled[j][i]=hh;order.append((i,j))
        for dj in(-1,0,1):
            for di in(-1,0,1):
                a,b=i+di,j+dj
                if 0<=a<nx and 0<=b<nz and not seen[b][a]: seen[b][a]=True;n+=1;heapq.heappush(pq,(max(g[b][a],hh+1e-5),n,a,b))
    rcv={}
    for j in range(1,nz-1):
        for i in range(1,nx-1):
            best=None;bd=0
            for dj in(-1,0,1):
                for di in(-1,0,1):
                    if di or dj:
                        d=(filled[j][i]-filled[j+dj][i+di])/math.hypot(di,dj)
                        if d>bd: bd=d;best=(i+di,j+dj)
            if best: rcv[i,j]=best
    acc={}
    for c in reversed(order):
        acc[c]=acc.get(c,0)+1;r=rcv.get(c)
        if r: acc[r]=acc.get(r,0)+acc[c]
    acc=[[acc.get((i,j),0) for i in range(nx)] for j in range(nz)]
    pickle.dump((g,filled,acc),open(pk,'wb'))
def water(cx,cz,thd,step=2.0):
    th=math.radians(thd);ca,sa=math.cos(th),math.sin(th);n=pond=flow=flat=0;flowA=0
    u=-P.L/2+step/2
    while u<P.L/2:
        v=-P.W/2+step/2
        while v<P.W/2:
            x,z=cx+u*ca-v*sa,cz+u*sa+v*ca;i,j=int(round(x-X0)),int(round(z-Z0))
            gx=(g[j][i+3]-g[j][i-3])/6;gz=(g[j+3][i]-g[j-3][i])/6;sl=math.hypot(gx,gz)*100
            pd=filled[j][i]-g[j][i];a=acc[j][i];n+=1
            if pd>0.01: pond+=1
            elif a>=150: flow+=1;flowA=max(flowA,a)
            elif sl<0.5: flat+=1
            v+=step
        u+=step
    k=step*step
    return dict(pond=pond*k,flow=flow*k,flat=flat*k,maxflow=flowA,score=3*pond*k+1.5*flow*k+0.5*flat*k)
if __name__=='__main__':
    def ok(cx,cz,thd):
        m,_=P.metrics(cx,cz,math.radians(thd))
        return (m['main_infield']>=P.YD15 and m['softball_skin']>=0.3 and m['fence_3B']>=P.FT10 and m['backstop_1B']>=P.FT10 and m['vendor']>=P.FT10 and m['north_of_vendor'] and m['west_of_rodeo'] and m['rodeo']>=P.FT10 and m['trees']>=2.0),m
    res=[]
    for thd in range(0,180,5):
        for cz in range(-90,12,3):
            for cx in range(-30,82,3):
                o,m=ok(cx,cz,thd)
                if o:
                    w=water(cx,cz,thd,3.0); res.append((w['score'],cx,cz,thd,w,m['cemetery']))
        print(thd,len(res),flush=True)
    res.sort()
    json.dump([(s,cx,cz,t,w,c) for s,cx,cz,t,w,c in res],open(D+'water_res.json','w'))
    print('feasible',len(res))
    for r in res[:10]: print(r)
    print('planA',water(25.15,-19.65,94.0,3.0))

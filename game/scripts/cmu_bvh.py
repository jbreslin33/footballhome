#!/usr/bin/env python3
"""cmu_bvh.py — read a CMU motion-capture BVH (Bruce Hahne's conversion, frame 0 a T-pose) and do forward
kinematics in plain Python (G5.106). Quaternions are (w, x, y, z). Used by retarget_cmu.py.

Source data: CMU Graphics Lab Motion Capture Database — "The data used in this project was obtained from
mocap.cs.cmu.edu. The database was created with funding from NSF EIA-0196217." Free for all uses; may be
included in products, not resold directly (mocap.cs.cmu.edu, read 2026-11-13). FH original code."""
import math

def qmul(a, b):
    aw, ax, ay, az = a; bw, bx, by, bz = b
    return (aw*bw - ax*bx - ay*by - az*bz, aw*bx + ax*bw + ay*bz - az*by,
            aw*by - ax*bz + ay*bw + az*bx, aw*bz + ax*by - ay*bx + az*bw)
def qinv(q): return (q[0], -q[1], -q[2], -q[3])
def qaxis(ax, ang):
    s = math.sin(ang / 2); return (math.cos(ang / 2), ax[0]*s, ax[1]*s, ax[2]*s)
def qrot(q, v):
    p = qmul(qmul(q, (0.0, v[0], v[1], v[2])), qinv(q)); return (p[1], p[2], p[3])
def qnorm(q):
    n = math.sqrt(sum(c*c for c in q)) or 1.0; return tuple(c / n for c in q)
AX = {'X': (1, 0, 0), 'Y': (0, 1, 0), 'Z': (0, 0, 1)}

class Bvh:
    def __init__(self, path):
        toks = open(path).read().split()
        self.names, self.parent, self.offset, self.chans = [], [], [], []
        i = 0; stack = []; cur = -1
        while toks[i] != 'MOTION':
            t = toks[i]
            if t in ('ROOT', 'JOINT'):
                self.names.append(toks[i + 1]); self.parent.append(cur); self.offset.append((0, 0, 0)); self.chans.append([])
                cur = len(self.names) - 1; i += 2
            elif t == 'End':
                self.names.append(None); self.parent.append(cur); self.offset.append((0, 0, 0)); self.chans.append([])
                cur = len(self.names) - 1; i += 2
            elif t == '{': stack.append(cur); i += 1
            elif t == '}':
                stack.pop(); cur = self.parent[cur] if cur >= 0 else -1; i += 1
            elif t == 'OFFSET': self.offset[cur] = tuple(float(x) for x in toks[i + 1:i + 4]); i += 4
            elif t == 'CHANNELS':
                n = int(toks[i + 1]); self.chans[cur] = toks[i + 2:i + 2 + n]; i += 2 + n
            else: i += 1
        nf = int(toks[i + 2]); self.dt = float(toks[i + 5]); vals = toks[i + 6:]
        per = sum(len(c) for c in self.chans)
        self.frames = [[float(x) for x in vals[f * per:(f + 1) * per]] for f in range(nf)]
        self.index = {n: k for k, n in enumerate(self.names) if n}
    def fk(self, f):
        """world rotation and position of every joint at frame f (BVH units, Y up)."""
        row = self.frames[f]; k = 0; W = []; P = []
        for j in range(len(self.names)):
            pos = list(self.offset[j]); q = (1.0, 0.0, 0.0, 0.0)
            for c in self.chans[j]:
                v = row[k]; k += 1
                if c.endswith('position'): pos['XYZ'.index(c[0])] += v if self.parent[j] >= 0 else 0; pos['XYZ'.index(c[0])] = v if self.parent[j] < 0 else pos['XYZ'.index(c[0])]
                else: q = qmul(q, qaxis(AX[c[0]], math.radians(v)))
            p = self.parent[j]
            if p < 0: W.append(qnorm(q)); P.append(tuple(pos))
            else:
                W.append(qnorm(qmul(W[p], q))); o = qrot(W[p], pos); P.append((P[p][0] + o[0], P[p][1] + o[1], P[p][2] + o[2]))
        return W, P

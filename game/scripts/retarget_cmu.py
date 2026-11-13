#!/usr/bin/env python3
"""retarget_cmu.py — CMU motion capture (BVH, frame 0 a T-pose) → looping clips on our player body's
skeleton (frontend/game-assets/ubc/body_male.gltf, bound in a T-pose), written as a glTF binary of
animations only (G5.106, DESIGN §8.207).

    python3 -I game/scripts/retarget_cmu.py <out.glb> <bvh dir> name:file:t0:t1[:tmin:tmax[:mirror]] ...

tmin < 0: a one-shot clip — the window t0-t1 as it is (a kick), not a loop; it does not close on frame 0.

For each clip: the window t0-t1 s of the file; inside it, the loop is the pair of frames 0.25-1.6 s apart
whose poses differ least (joint rotations, plus the hips' velocity). Each mapped joint's world rotation
from the CMU T-pose is carried onto our bone's bind rotation (W = G·Wc(t)·Wc(0)⁻¹·G0⁻¹·B), so the two
skeletons' different bone axes never matter; G turns the window's mean heading to face our forward. The
pelvis keeps its height (scaled to our leg) and its sway about the straight line through the loop's ends;
its travel is printed (m/s forward / left) for the viewer to match speeds. Downsampled to 30 fps.

Data: CMU Graphics Lab Motion Capture Database — "The data used in this project was obtained from
mocap.cs.cmu.edu. The database was created with funding from NSF EIA-0196217." FH original code."""
import json, math, os, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cmu_bvh import Bvh, qmul, qinv, qrot, qnorm, qaxis

MAP = {'pelvis': 'Hips', 'spine_01': 'LowerBack', 'spine_02': 'Spine', 'spine_03': 'Spine1', 'neck_01': 'Neck1',
       'Head': 'Head', 'clavicle_l': 'LeftShoulder', 'upperarm_l': 'LeftArm', 'lowerarm_l': 'LeftForeArm',
       'hand_l': 'LeftHand', 'clavicle_r': 'RightShoulder', 'upperarm_r': 'RightArm', 'lowerarm_r': 'RightForeArm',
       'hand_r': 'RightHand', 'thigh_l': 'LeftUpLeg', 'calf_l': 'LeftLeg', 'foot_l': 'LeftFoot', 'ball_l': 'LeftToeBase',
       'thigh_r': 'RightUpLeg', 'calf_r': 'RightLeg', 'foot_r': 'RightFoot', 'ball_r': 'RightToeBase'}
BODY = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../frontend/game-assets/ubc/body_male.gltf')
FPS = 30

def yaw_between(a, b):
    """rotation about +Y taking horizontal direction a onto b."""
    return qaxis((0, 1, 0), math.atan2(a[2], a[0]) - math.atan2(b[2], b[0]))

class Ours:
    def __init__(self):
        j = json.load(open(BODY)); self.nodes = j['nodes']
        self.names = [n.get('name') for n in self.nodes]
        self.parent = {c: i for i, n in enumerate(self.nodes) for c in n.get('children', [])}
        roots = j['scenes'][j.get('scene', 0)]['nodes']
        self.Lq = [tuple(n.get('rotation', [0, 0, 0, 1])[k] for k in (3, 0, 1, 2)) for n in self.nodes]
        self.Lt = [tuple(n.get('translation', [0, 0, 0])) for n in self.nodes]
        self.order = []
        def walk(i):
            self.order.append(i)
            for c in self.nodes[i].get('children', []): walk(c)
        for r in roots: walk(r)
        self.Bq, self.Bp = self.fk(self.Lq, self.Lt)
        self.idx = {n: i for i, n in enumerate(self.names) if n}
    def fk(self, Lq, Lt):
        W = [None] * len(self.nodes); P = [None] * len(self.nodes)
        for i in self.order:
            p = self.parent.get(i)
            if p is None: W[i] = Lq[i]; P[i] = Lt[i]
            else:
                W[i] = qnorm(qmul(W[p], Lq[i])); o = qrot(W[p], Lt[i]); P[i] = (P[p][0] + o[0], P[p][1] + o[1], P[p][2] + o[2])
        return W, P

def ang(q):  # rotation angle of a unit quaternion
    return 2 * math.acos(min(1.0, abs(q[0])))

def retarget(ours, b, t0, t1, tmin=0.25, tmax=1.6, mirror=0):
    n0 = max(1, int(t0 / b.dt)); n1 = min(len(b.frames) - 1, int(t1 / b.dt))
    step = max(1, int(round(1 / (FPS * b.dt))))
    frames = list(range(n0, n1 + 1, step))
    FK = {f: b.fk(f) for f in frames}
    Wc0, Pc0 = b.fk(0)
    L, R, H = b.index['LeftUpLeg'], b.index['RightUpLeg'], b.index['Hips']
    left = lambda P: (P[L][0] - P[R][0], 0.0, P[L][2] - P[R][2])
    ol = (ours.Bp[ours.idx['thigh_l']][0] - ours.Bp[ours.idx['thigh_r']][0], 0.0,
          ours.Bp[ours.idx['thigh_l']][2] - ours.Bp[ours.idx['thigh_r']][2])
    G0 = yaw_between(left(Pc0), ol)
    # the loop: least pose difference 0.25-1.6 s apart
    J = [b.index[c] for c in MAP.values() if c in b.index]
    def diff(fa, fb):
        Wa, Pa = FK[fa]; Wb, Pb = FK[fb]
        d = sum(ang(qmul(qmul(qinv(Wa[H]), Wa[j]), qinv(qmul(qinv(Wb[H]), Wb[j])))) for j in J)
        return d
    best = None
    if tmin < 0: best = (0.0, 0, len(frames) - 1)     # one shot (a kick): the window as it is, no loop
    for ia, fa in (enumerate(frames) if tmin >= 0 else []):
        for ib in range(ia + 1, len(frames)):
            T = (frames[ib] - fa) * b.dt
            if T < tmin: continue
            if T > tmax: break
            d = diff(fa, frames[ib])
            if best is None or d < best[0]: best = (d, ia, ib)
    d, ia, ib = best
    loop = frames[ia:ib + 1]
    # heading: the loop's mean left vector → ours
    ml = [0.0, 0.0, 0.0]
    for f in loop:
        lv = left(FK[f][1]); n = math.hypot(lv[0], lv[2]) or 1
        ml[0] += lv[0] / n; ml[2] += lv[2] / n
    G = yaw_between(tuple(ml), ol)
    s = (ours.Bp[ours.idx['thigh_l']][1] - ours.Bp[ours.idx['foot_l']][1]) / (Pc0[L][1] - Pc0[b.index['LeftFoot']][1])
    pa, pb = FK[loop[0]][1][H], FK[loop[-1]][1][H]
    T = (loop[-1] - loop[0]) * b.dt
    vel = qrot(G, ((pb[0] - pa[0]) / T * s, 0, (pb[2] - pa[2]) / T * s))
    ofwd = qrot(qaxis((0, 1, 0), -math.pi / 2), (ol[0], 0, ol[2]))   # forward = left turned −90° about up
    on = math.hypot(ol[0], ol[2]); fn = math.hypot(ofwd[0], ofwd[2])
    v_fwd = (vel[0] * ofwd[0] + vel[2] * ofwd[2]) / fn; v_left = (vel[0] * ol[0] + vel[2] * ol[2]) / on
    pel = ours.idx['pelvis']; root = ours.parent[pel]
    hip_h0 = Pc0[H][1]
    out_q = {nm: [] for nm in MAP}; out_p = []; lows = []
    nl = math.hypot(ol[0], ol[2]); N = (ol[0] / nl, 0.0, ol[2] / nl)   # our left: the mirror plane's normal
    def mir_q(q):   # a rotation seen in the mirror: the axis is a pseudovector, so v → −(v − 2(v·N)N)
        w, x, y, z = q; dv = x * N[0] + y * N[1] + z * N[2]
        return (w, -(x - 2 * dv * N[0]), -(y - 2 * dv * N[1]), -(z - 2 * dv * N[2]))
    def mir_p(v):
        dv = v[0] * N[0] + v[1] * N[1] + v[2] * N[2]; return (v[0] - 2 * dv * N[0], v[1] - 2 * dv * N[1], v[2] - 2 * dv * N[2])
    swap = lambda nm: nm[:-2] + ('_r' if nm.endswith('_l') else '_l') if nm[-2:] in ('_l', '_r') else nm
    if mirror: v_left = -v_left
    for k, f in enumerate(loop[:-1]):
        Wc, Pc = FK[f]
        Lq = list(ours.Lq)
        Wn = [None] * len(ours.nodes)
        for i in ours.order:
            p = ours.parent.get(i); nm = ours.names[i]
            src = swap(nm) if (mirror and nm) else nm
            if nm in MAP and MAP[src] in b.index:
                c = b.index[MAP[src]]
                D = qnorm(qmul(qmul(qmul(G, Wc[c]), qinv(Wc0[c])), qinv(G0)))   # the joint's turn from the T-pose, our frame
                if mirror: D = mir_q(D)
                Wn[i] = qnorm(qmul(D, ours.Bq[i]))
                Lq[i] = qnorm(qmul(qinv(Wn[p]), Wn[i])) if p is not None else Wn[i]
            else:
                Wn[i] = qnorm(qmul(Wn[p], Lq[i])) if p is not None else Lq[i]
        for nm in MAP:
            if nm in ours.idx: out_q[nm].append(Lq[ours.idx[nm]])
        # pelvis: sway about the straight line, height scaled
        u = (f - loop[0]) / (loop[-1] - loop[0])
        hx = Pc[H][0] - (pa[0] + (pb[0] - pa[0]) * u); hz = Pc[H][2] - (pa[2] + (pb[2] - pa[2]) * u)
        sw = qrot(G, (hx * s, 0, hz * s))
        if mirror: sw = mir_p(sw)
        wpos = (sw[0], ours.Bp[pel][1] + (Pc[H][1] - hip_h0) * s, sw[2])
        rp = ours.Bp[root]; lp = qrot(qinv(ours.Bq[root]), (wpos[0] - rp[0], wpos[1] - rp[1], wpos[2] - rp[2]))
        out_p.append(lp)
        Lt = list(ours.Lt); Lt[pel] = lp
        _, Pn = ours.fk(Lq, Lt)
        lows.append(min(Pn[ours.idx['ball_l']][1], Pn[ours.idx['ball_r']][1]))
    # grounded: the loop's lowest toe on the grass at the bind pose's toe height (the CMU T-pose frame was
    # added after capture; its hip height is not the standing one — feet floated 10-16 cm)
    off = ours.Bp[ours.idx['ball_l']][1] - min(lows)
    dl = qrot(qinv(ours.Bq[root]), (0.0, off, 0.0))
    out_p = [(p[0] + dl[0], p[1] + dl[1], p[2] + dl[2]) for p in out_p]
    return {'q': out_q, 'p': out_p, 'dur': T, 'n': len(loop) - 1, 'fwd': v_fwd, 'left': v_left, 'diff': d,
            'span': ((loop[0]) * b.dt, loop[-1] * b.dt), 'ground': off, 'loop': tmin >= 0}

def write(path, ours, clips):
    buf = bytearray(); views = []; accs = []
    def add(vals, typ):
        while len(buf) % 4: buf.append(0)
        off = len(buf); flat = [c for v in vals for c in (v if isinstance(v, (tuple, list)) else (v,))]
        buf.extend(struct.pack('<%df' % len(flat), *flat))
        views.append({'buffer': 0, 'byteOffset': off, 'byteLength': 4 * len(flat)})
        a = {'bufferView': len(views) - 1, 'componentType': 5126, 'count': len(vals), 'type': typ}
        if typ == 'SCALAR': a['min'] = [min(vals)]; a['max'] = [max(vals)]
        accs.append(a); return len(accs) - 1
    anims = []
    for name, c in clips:
        n = c['n']; times = [k * c['dur'] / n for k in range(n + 1)]
        ti = add(times, 'SCALAR'); ch = []; sm = []
        for nm, qs in c['q'].items():
            qs = qs + [qs[0] if c.get('loop', True) else qs[-1]]   # a loop closes on its first frame
            for k in range(1, len(qs)):                          # keep the hemisphere continuous
                if sum(a * b for a, b in zip(qs[k], qs[k - 1])) < 0: qs[k] = tuple(-x for x in qs[k])
            sm.append({'input': ti, 'output': add([(q[1], q[2], q[3], q[0]) for q in qs], 'VEC4'), 'interpolation': 'LINEAR'})
            ch.append({'sampler': len(sm) - 1, 'target': {'node': ours.idx[nm], 'path': 'rotation'}})
        ps = c['p'] + [c['p'][0] if c.get('loop', True) else c['p'][-1]]
        sm.append({'input': ti, 'output': add(ps, 'VEC3'), 'interpolation': 'LINEAR'})
        ch.append({'sampler': len(sm) - 1, 'target': {'node': ours.idx['pelvis'], 'path': 'translation'}})
        anims.append({'name': name, 'channels': ch, 'samplers': sm,
                      'extras': {'fwd_mps': round(c['fwd'], 3), 'left_mps': round(c['left'], 3), 'source_span_s': [round(x, 2) for x in c['span']]}})
    nodes = [{k: v for k, v in nd.items() if k in ('name', 'children', 'translation', 'rotation', 'scale')} for nd in ours.nodes]
    g = {'asset': {'version': '2.0', 'generator': 'FH retarget_cmu.py (CMU mocap, mocap.cs.cmu.edu)'},
         'scene': 0, 'scenes': [{'nodes': [i for i in range(len(nodes)) if i not in ours.parent]}], 'nodes': nodes,
         'animations': anims, 'accessors': accs, 'bufferViews': views, 'buffers': [{'byteLength': len(buf)}]}
    js = json.dumps(g, separators=(',', ':')).encode()
    while len(js) % 4: js += b' '
    while len(buf) % 4: buf.append(0)
    with open(path, 'wb') as f:
        f.write(struct.pack('<III', 0x46546C67, 2, 28 + len(js) + len(buf)))
        f.write(struct.pack('<II', len(js), 0x4E4F534A)); f.write(js)
        f.write(struct.pack('<II', len(buf), 0x004E4942)); f.write(buf)

if __name__ == '__main__':
    out, d = sys.argv[1], sys.argv[2]
    ours = Ours(); clips = []
    for spec in sys.argv[3:]:
        name, fn, *nums = spec.split(':')
        c = retarget(ours, Bvh(os.path.join(d, fn)), *[float(x) for x in nums])
        print(f"{name:14s} {fn:12s} loop {c['span'][0]:.2f}-{c['span'][1]:.2f}s ({c['dur']:.2f}s, pose diff {c['diff']:.2f} rad) travel fwd {c['fwd']:+.2f} left {c['left']:+.2f} m/s, grounded {c['ground']:+.3f} m")
        clips.append((name, c))
    write(out, ours, clips)
    print(out, os.path.getsize(out), 'bytes')

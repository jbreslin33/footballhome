"""Pitch calibration for a fixed-position pan/tilt/zoom camera.

World: metres, origin = centre spot, x along the length, y across, z up.
Pitch 100.58 x 67.67 (Lighthouse yellow pitch).  Near touchline y = -W/2
(camera side), halfway line x = 0.

Per frame: detect the halfway line + near touchline (white paint, Hough),
then fit ONE camera position (shared by all frames) + per-frame pan, tilt,
focal length so the projected world lines land on the detected paint.
Output: calib.json  {camera:[x,y,z], frames:{frame:{pan,tilt,f,res_px}}}
        overlay/*.jpg — the whole pitch template drawn back over the frames."""
import json, sys, os, math
import cv2, numpy as np
from scipy.optimize import least_squares

L, W = 100.58, 67.67
src, outdir = sys.argv[1], sys.argv[2]
os.makedirs(outdir + "/overlay", exist_ok=True)

from ultralytics import YOLO
import torch
torch.set_num_threads(1)
PEOPLE = YOLO("yolo11s.pt")
def people_boxes(f):
    r = PEOPLE(f, classes=[0], imgsz=1280, conf=0.15, verbose=False)[0]
    return r.boxes.xyxy.tolist()

def paint_mask(f, people=()):
    H = f.shape[0]
    hsv = cv2.cvtColor(f, cv2.COLOR_BGR2HSV)
    grass = cv2.inRange(hsv, (20, 25, 40), (95, 255, 220))
    grass = cv2.morphologyEx(grass, cv2.MORPH_CLOSE, np.ones((25, 25), np.uint8))
    g = cv2.cvtColor(f, cv2.COLOR_BGR2GRAY)
    th = cv2.morphologyEx(g, cv2.MORPH_TOPHAT, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15)))
    m = ((th > 28) & (grass > 0) & (hsv[..., 1] < 80)).astype(np.uint8) * 255
    m[:int(H * 0.42)] = 0          # far side / goals / trees: not used for the two main lines
    for x1, y1, x2, y2 in people:  # a spectator's arm or a sock is not paint
        pad = 6
        m[max(0, int(y1) - pad):int(y2) + pad, max(0, int(x1) - pad):int(x2) + pad] = 0
    return m

def ransac_line(pts, iters=300, tol=4.0):
    if len(pts) < 20: return None
    best = None; rng = np.random.default_rng(0)
    for _ in range(iters):
        a, b = pts[rng.choice(len(pts), 2, replace=False)]
        d = b - a; n = np.linalg.norm(d)
        if n < 30: continue
        nrm = np.array([-d[1], d[0]]) / n
        dist = np.abs((pts - a) @ nrm)
        inl = dist < tol
        if best is None or inl.sum() > best.sum(): best = inl
    if best is None or best.sum() < 40: return None
    return pts[best]

def detect(f, people=()):
    H, Wd = f.shape[:2]
    m = paint_mask(f, people)
    segs = cv2.HoughLinesP(m, 1, np.pi / 360, 50, minLineLength=60, maxLineGap=15)
    steep, shallow = [], []
    if segs is None: return None, None
    for x1, y1, x2, y2 in segs.reshape(-1, 4):
        ang = abs(math.degrees(math.atan2(y2 - y1, x2 - x1)))
        ang = min(ang, 180 - ang)
        n = max(2, int(math.hypot(x2 - x1, y2 - y1) / 8))
        pts = np.stack([np.linspace(x1, x2, n), np.linspace(y1, y2, n)], 1)
        (steep if ang > 55 else shallow if 8 < ang < 50 else []).extend(pts)
    half = ransac_line(np.array(steep)) if steep else None
    touch = ransac_line(np.array(shallow)) if shallow else None
    return half, touch

def detect_goal(f):
    H, Wd = f.shape[:2]; y0, y1 = int(H * 0.30), int(H * 0.62)
    band = f[y0:y1]
    hsv = cv2.cvtColor(band, cv2.COLOR_BGR2HSV)
    white = cv2.inRange(hsv, (0, 0, 150), (180, 60, 255))
    g = cv2.cvtColor(band, cv2.COLOR_BGR2GRAY)
    th = cv2.morphologyEx(g, cv2.MORPH_TOPHAT, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9)))
    m = ((th > 15) & (white > 0)).astype(np.uint8) * 255
    m = cv2.dilate(m, np.ones((3, 3), np.uint8))
    n, lab, st, _ = cv2.connectedComponentsWithStats(m, 8)
    best = None
    for i in range(1, n):
        x, y, w, h, a = st[i]
        if not (25 <= w <= 450 and 15 <= h <= 160 and 1.3 <= w / h <= 6): continue
        rawfill = (white[y:y + h, x:x + w] > 0).mean()
        if rawfill > 0.45: continue                       # tents / walls are solid white
        lcol = (m[y:y + h, x:x + max(3, w // 12)] > 0).any(1).mean()
        rcol = (m[y:y + h, x + w - max(3, w // 12):x + w] > 0).any(1).mean()
        if lcol < 0.5 or rcol < 0.5: continue             # both posts present
        if best is None or a > best[4]: best = (x, y + y0, w, h, a)
    return None if best is None else np.array(best[:4], float)

def basis(pan, tilt):
    fwd = np.array([math.sin(pan) * math.cos(tilt), math.cos(pan) * math.cos(tilt), -math.sin(tilt)])
    right = np.array([math.cos(pan), -math.sin(pan), 0.0])
    down = np.cross(fwd, right)
    return fwd, right, down

K1 = 0.0
def project(P, C, pan, tilt, f, cx, cy, k1=None):
    k1 = K1 if k1 is None else k1
    fwd, right, down = basis(pan, tilt)
    d = P - C
    z = d @ fwd
    u = f * (d @ right) / z; v = f * (d @ down) / z
    r2 = (u * u + v * v) / (cx * cx)
    sc = 1 + k1 * r2
    return np.stack([cx + u * sc, cy + v * sc], -1), z

def line_resid(pts, A, B, C, pan, tilt, f, cx, cy, k1=None):
    P = np.linspace(A, B, 41)
    uv, z = project(P, C, pan, tilt, f, cx, cy, k1)
    uv = uv[z > 1]
    if len(uv) < 2: return np.full(len(pts), 100.0)
    a = uv[:-1]; b = uv[1:]; ab = b - a
    t = np.clip(((pts[:, None, :] - a[None]) * ab[None]).sum(-1) / ((ab * ab).sum(-1)[None] + 1e-9), 0, 1)
    proj = a[None] + t[..., None] * ab[None]
    return np.sqrt(((pts[:, None, :] - proj) ** 2).sum(-1)).min(1)

HALF = (np.array([0, -W / 2, 0.]), np.array([0, W / 2, 0.]))
GOAL = np.array([[L / 2, -3.66, 0], [L / 2, -3.66, 2.44], [L / 2, 3.66, 2.44], [L / 2, 3.66, 0]], float)
def goal_resid(gb, C, pan, tilt, f, cx, cy, wgt=1.5, k1=None, half_len=None):
    if gb is None: return np.zeros(0)
    G = GOAL.copy()
    if half_len is not None: G[:, 0] = half_len
    uv, z = project(G, C, pan, tilt, f, cx, cy, k1)
    if (z <= 1).any(): return np.full(4, 200.0)
    x, y, w, h = gb
    return wgt * np.array([uv[:, 0].min() - x, uv[:, 0].max() - (x + w), uv[:, 1].min() - y, uv[:, 1].max() - (y + h)])
TOUCH = (np.array([-L / 2, -W / 2, 0.]), np.array([L / 2, -W / 2, 0.]))

# ── collect detections at 2 fps
cap = cv2.VideoCapture(src); fps = cap.get(cv2.CAP_PROP_FPS) or 30
frames, imgs, fi = [], {}, 0
while True:
    ok, f = cap.read()
    if not ok: break
    if fi % round(fps / 2) == 0:
        h, t = detect(f, people_boxes(f))
        if h is not None and t is not None:
            frames.append((fi, h[::3], t[::3], detect_goal(f))); imgs[fi] = f
    fi += 1
Hh, Ww = next(iter(imgs.values())).shape[:2]
cx, cy = Ww / 2, Hh / 2
print("frames with both lines:", len(frames), "of", fi // round(fps / 2) + 1)

# ── joint fit: camera (3) + per frame (pan, tilt, log f)
def unpack(p):
    C = p[:3]; per = p[5:].reshape(-1, 3)
    return C, per
def resid(p):
    C, per = unpack(p); k1 = p[3]; hl = p[4]
    r = []
    for (fi, h, t, gb), (pan, tilt, lf) in zip(frames, per):
        f = math.exp(lf)
        r.append(line_resid(h, *HALF, C, pan, tilt, f, cx, cy, k1))
        r.append(line_resid(t, *TOUCH, C, pan, tilt, f, cx, cy, k1))
        r.append(goal_resid(gb, C, pan, tilt, f, cx, cy, k1=k1, half_len=hl))
    r.append(np.array([0.0 * C[0]]))
    return np.concatenate(r)

# stage 1: camera position from a dozen spread-out frames
all_frames = frames
withg = [fr for fr in frames if fr[3] is not None]
print("frames with goal:", len(withg), flush=True)
sub = withg[::max(1, len(withg) // 12)][:12]
frames = [(fi, h[::2], t[::2], gb) for fi, h, t, gb in sub]
best = None
for cam0 in ([0, -45, 4], [0, -38, 6], [3, -42, 3]):
    p0 = np.concatenate([cam0, [0.0, L / 2], np.tile([0.7, 0.08, math.log(1100)], len(frames))])
    lo = np.concatenate([[-30, -90, 0.5, -0.5, 40], np.tile([-1.5, -0.2, math.log(300)], len(frames))])
    hi = np.concatenate([[30, -W / 2 - 0.5, 25, 0.5, 60], np.tile([1.5, 1.2, math.log(8000)], len(frames))])
    sol = least_squares(resid, p0, bounds=(lo, hi), loss="soft_l1", f_scale=3.0, max_nfev=200, x_scale="jac")
    Cc, _ = unpack(sol.x)
    print("start", cam0, "->", np.round(Cc, 2), "cost", round(sol.cost, 1), flush=True)
    if Cc[1] > -W / 2 or Cc[2] < 0.5: continue
    if best is None or sol.cost < best.cost: best = sol
C, _ = unpack(best.x); K1 = float(best.x[3]); L = 2 * float(best.x[4])
GOAL[:, 0] = L / 2; TOUCH = (np.array([-L / 2, -W / 2, 0.]), np.array([L / 2, -W / 2, 0.]))
print("camera (m):", np.round(C, 2), "lens k1:", round(K1, 4), "fitted pitch length:", round(L, 2), flush=True)

# stage 2: every frame on its own, camera fixed
frames = all_frames
per = []
prev = np.array([0.7, 0.08, math.log(1100)])
for fi, h, t, gb in frames:
    def r1(q):
        f = math.exp(q[2])
        return np.concatenate([line_resid(h, *HALF, C, q[0], q[1], f, cx, cy),
                               line_resid(t, *TOUCH, C, q[0], q[1], f, cx, cy),
                               goal_resid(gb, C, q[0], q[1], f, cx, cy)])
    s1 = None
    starts = [prev] + [np.array([pn, tl, math.log(fl)]) for pn in (-0.6, -0.2, 0.2, 0.6, 1.0)
                       for tl in (0.08, 0.15) for fl in (900, 1300)]
    for q0 in starts:
        q0 = np.clip(q0, [-1.49, -0.19, math.log(301)], [1.49, 1.19, math.log(7999)])
        sol1 = least_squares(r1, q0, bounds=([-1.5, -0.2, math.log(300)], [1.5, 1.2, math.log(8000)]),
                             loss="soft_l1", f_scale=3.0, max_nfev=200)
        if s1 is None or sol1.cost < s1.cost: s1 = sol1
        if s1.cost < 5 * len(h): break                   # good enough — keep the warm start
    per.append(s1.x); prev = s1.x
per = np.array(per)

# ── template for overlay
def template():
    segs = []
    def rect(x0, y0, x1, y1): segs.extend([((x0, y0), (x1, y0)), ((x1, y0), (x1, y1)), ((x1, y1), (x0, y1)), ((x0, y1), (x0, y0))])
    rect(-L / 2, -W / 2, L / 2, W / 2)
    segs.append(((0, -W / 2), (0, W / 2)))
    for s in (-1, 1):
        gx = s * L / 2
        rect(gx, -20.16, gx - s * 16.5, 20.16)          # penalty area
        rect(gx, -9.16, gx - s * 5.5, 9.16)             # goal area
    circ = [(9.15 * math.cos(a), 9.15 * math.sin(a)) for a in np.linspace(0, 2 * math.pi, 49)]
    segs.extend(zip(circ[:-1], circ[1:]))
    return segs
TPL = template()

out = {"camera": [round(v, 3) for v in C], "k1": round(K1, 5), "pitch": [L, W], "frames": {}}
for (fi, h, t, gb), (pan, tilt, lf) in zip(frames, per):
    f = math.exp(lf)
    rh = line_resid(h, *HALF, C, pan, tilt, f, cx, cy); rt = line_resid(t, *TOUCH, C, pan, tilt, f, cx, cy)
    res = float(np.median(np.abs(np.concatenate([rh, rt]))))
    out["frames"][int(fi)] = {"pan_deg": round(math.degrees(pan), 2), "tilt_deg": round(math.degrees(tilt), 2),
                              "f_px": round(f, 1), "median_res_px": round(res, 2), "goal": gb is not None}
    vis = imgs[fi].copy()
    for (a, b) in TPL:
        A = np.array([a[0], a[1], 0.]); B = np.array([b[0], b[1], 0.])
        P = np.linspace(A, B, 20)
        uv, z = project(P, C, pan, tilt, f, cx, cy)
        for i in range(len(P) - 1):
            r2a = ((uv[i] - [cx, cy]) ** 2).sum() / cx ** 2; r2b = ((uv[i + 1] - [cx, cy]) ** 2).sum() / cx ** 2
            if z[i] > 1 and z[i + 1] > 1 and r2a < 1.4 and r2b < 1.4:
                cv2.line(vis, tuple(map(int, uv[i])), tuple(map(int, uv[i + 1])), (0, 255, 255), 2)
    for (gx) in (-L / 2, L / 2):                          # goal posts + crossbar, 7.32 x 2.44
        G = np.array([[gx, -3.66, 0], [gx, -3.66, 2.44], [gx, 3.66, 2.44], [gx, 3.66, 0]], float)
        uv, z = project(G, C, pan, tilt, f, cx, cy)
        if (z > 1).all(): cv2.polylines(vis, [uv.astype(int)], False, (0, 0, 255), 3)
    if gb is not None:
        x, y, w, hh = map(int, gb); cv2.rectangle(vis, (x, y), (x + w, y + hh), (255, 0, 255), 2)
    for p in h: cv2.circle(vis, tuple(map(int, p)), 2, (255, 0, 255), -1)
    for p in t: cv2.circle(vis, tuple(map(int, p)), 2, (255, 0, 255), -1)
    cv2.putText(vis, f"frame {fi} pan {math.degrees(pan):.1f} tilt {math.degrees(tilt):.1f} f {f:.0f} res {res:.1f}px",
                (30, Hh - 30), 0, 1.0, (0, 255, 255), 2)
    cv2.imwrite(f"{outdir}/overlay/{fi:05d}.jpg", vis)
json.dump(out, open(outdir + "/calib.json", "w"), indent=1)
print("median residual px over frames:", round(float(np.median([v["median_res_px"] for v in out["frames"].values()])), 2))

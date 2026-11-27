"""Film analysis — the per-frame pass that turns a clip into rows for the DB.

Inputs (all produced by the earlier steps in scripts/film/):
  clip.mp4            the clip (any length), 1080p
  calib.json          calibrate_camera.py: camera position, lens k1, pitch
                      size, pan/tilt/focal at the frames it could solve
  ball_path.csv       ball_path.py: the ball's pixel spot per frame
Outputs (in outdir):
  detections.csv      frame, t, kind (player|goalkeeper|referee|ball), team
                      (kit colour: white|dark|NULL), track_id, img_x, img_y,
                      pitch_x, pitch_y (metres, centre spot origin), conf
  camera.csv          frame, t, pan_deg, tilt_deg, f_px, solved (bool)
  replay.mp4          the clip with boxes, ball ring and pitch lines drawn,
                      960x540 H.264 at the analysis frame rate

Players/keepers/referees come from Roboflow's football-player model (MIT,
github.com/roboflow/sports); team = median torso colour.  Pitch positions
come from the fitted pan/tilt/zoom camera (feet / ball on the ground plane).
Run: nice -n 19 python analyze_clip.py clip.mp4 calib.json ball_path.csv outdir
       --fps 10 --models <dir with football-player.pt> --ffmpeg <ffmpeg>
"""
import argparse, csv, json, math, os, subprocess
import cv2, numpy as np, torch
from ultralytics import YOLO

ap = argparse.ArgumentParser()
ap.add_argument("clip"); ap.add_argument("calib"); ap.add_argument("ball"); ap.add_argument("outdir")
ap.add_argument("--fps", type=float, default=10); ap.add_argument("--seconds", type=float, default=0)
ap.add_argument("--models", default="."); ap.add_argument("--ffmpeg", default="ffmpeg")
ap.add_argument("--threads", type=int, default=1); ap.add_argument("--tracker", default="bytetrack.yaml")
a = ap.parse_args()
torch.set_num_threads(a.threads)
os.makedirs(a.outdir + "/frames", exist_ok=True)

cal = json.load(open(a.calib))
C = np.array(cal["camera"], float); K1 = float(cal.get("k1", 0)); L, W = cal["pitch"]
solved = {int(k): v for k, v in cal["frames"].items()}
skeys = sorted(solved)

def cam_at(fr):
    """pan, tilt (rad), f — linear between solved frames, held at the ends."""
    if not skeys: return None
    if fr <= skeys[0]: v = solved[skeys[0]]; return math.radians(v["pan_deg"]), math.radians(v["tilt_deg"]), v["f_px"], fr == skeys[0]
    if fr >= skeys[-1]: v = solved[skeys[-1]]; return math.radians(v["pan_deg"]), math.radians(v["tilt_deg"]), v["f_px"], fr == skeys[-1]
    i = np.searchsorted(skeys, fr)
    f0, f1 = skeys[i - 1], skeys[i]
    if f1 == fr: v = solved[fr]; return math.radians(v["pan_deg"]), math.radians(v["tilt_deg"]), v["f_px"], True
    w = (fr - f0) / (f1 - f0); v0, v1 = solved[f0], solved[f1]
    lerp = lambda k: v0[k] * (1 - w) + v1[k] * w
    return math.radians(lerp("pan_deg")), math.radians(lerp("tilt_deg")), math.exp(math.log(v0["f_px"]) * (1 - w) + math.log(v1["f_px"]) * w), False

def basis(pan, tilt):
    fwd = np.array([math.sin(pan) * math.cos(tilt), math.cos(pan) * math.cos(tilt), -math.sin(tilt)])
    right = np.array([math.cos(pan), -math.sin(pan), 0.0])
    return fwd, right, np.cross(fwd, right)

def project(P, pan, tilt, f, cx, cy):
    fwd, right, down = basis(pan, tilt)
    d = P - C; z = d @ fwd
    u = f * (d @ right) / z; v = f * (d @ down) / z
    sc = 1 + K1 * (u * u + v * v) / (cx * cx)
    return np.stack([cx + u * sc, cy + v * sc], -1), z

def to_pitch(px, py, pan, tilt, f, cx, cy):
    """pixel → ground point (x, y) in metres; None when the ray misses the ground."""
    du, dv = px - cx, py - cy
    u, v = du, dv
    for _ in range(8):                                  # undo the lens bend
        sc = 1 + K1 * (u * u + v * v) / (cx * cx); u, v = du / sc, dv / sc
    fwd, right, down = basis(pan, tilt)
    ray = fwd + (u / f) * right + (v / f) * down
    if ray[2] >= -1e-6: return None
    s = -C[2] / ray[2]; g = C + s * ray
    if abs(g[0]) > L / 2 + 15 or abs(g[1]) > W / 2 + 15: return None   # far off the pitch = bad ray
    return float(g[0]), float(g[1])

def kit(img, box):
    x1, y1, x2, y2 = map(int, box); h = y2 - y1
    crop = img[y1 + int(h * 0.15): y1 + int(h * 0.5), x1 + int((x2 - x1) * 0.2): max(x1 + int((x2 - x1) * 0.2) + 1, x2 - int((x2 - x1) * 0.2))]
    if crop.size == 0: return None
    hsv = cv2.cvtColor(crop, cv2.COLOR_BGR2HSV).reshape(-1, 3)
    g = (hsv[:, 0] > 30) & (hsv[:, 0] < 90) & (hsv[:, 1] > 50)
    hsv = hsv[~g] if (~g).sum() > 10 else hsv
    hh, s, v = np.median(hsv, axis=0)
    if v > 150 and s < 60: return "white"
    if v < 125: return "dark"
    return None

ball = {int(r["frame"]): (float(r["x"]), float(r["y"])) for r in csv.DictReader(open(a.ball))}
model = YOLO(os.path.join(a.models, "football-player.pt"))
ROLE = {1: "goalkeeper", 2: "player", 3: "referee"}
COL = {"white": (255, 255, 255), "dark": (140, 60, 20), "referee": (0, 0, 255), "goalkeeper": (0, 165, 255)}

cap = cv2.VideoCapture(a.clip); vfps = cap.get(cv2.CAP_PROP_FPS) or 30
step = max(1, round(vfps / a.fps)); limit = a.seconds * vfps if a.seconds else 1e12
det_rows, cam_rows, n, fi = [], [], 0, 0
while fi < limit:
    ok, frame = cap.read()
    if not ok: break
    if fi % step:
        fi += 1; continue
    H, Wd = frame.shape[:2]; cx, cy = Wd / 2, H / 2
    t = round(fi / vfps, 3)
    cam = cam_at(fi)
    if cam: cam_rows.append([fi, t, round(math.degrees(cam[0]), 3), round(math.degrees(cam[1]), 3), round(cam[2], 1), cam[3]])
    vis = frame.copy()
    if cam:                                              # pitch lines from the fitted camera
        pan, tilt, f, _ = cam
        segs = [((-L / 2, -W / 2), (L / 2, -W / 2)), ((L / 2, -W / 2), (L / 2, W / 2)), ((L / 2, W / 2), (-L / 2, W / 2)),
                ((-L / 2, W / 2), (-L / 2, -W / 2)), ((0, -W / 2), (0, W / 2))]
        for s_ in (-1, 1):
            gx = s_ * L / 2
            segs += [((gx, -20.16), (gx - s_ * 16.5, -20.16)), ((gx - s_ * 16.5, -20.16), (gx - s_ * 16.5, 20.16)), ((gx - s_ * 16.5, 20.16), (gx, 20.16))]
        circ = [(9.15 * math.cos(q), 9.15 * math.sin(q)) for q in np.linspace(0, 2 * math.pi, 41)]
        segs += list(zip(circ[:-1], circ[1:]))
        for p0, p1 in segs:
            P = np.linspace([p0[0], p0[1], 0], [p1[0], p1[1], 0], 16)
            uv, z = project(P, pan, tilt, f, cx, cy)
            for i in range(len(P) - 1):
                r2 = max(((uv[i] - [cx, cy]) ** 2).sum(), ((uv[i + 1] - [cx, cy]) ** 2).sum()) / cx ** 2
                if z[i] > 1 and z[i + 1] > 1 and r2 < 1.4:
                    cv2.line(vis, tuple(map(int, uv[i])), tuple(map(int, uv[i + 1])), (0, 220, 255), 2)
    r = model.track(frame, persist=True, imgsz=1280, conf=0.2, tracker=a.tracker, verbose=False)[0]
    if r.boxes is not None and len(r.boxes):
        ids = r.boxes.id.int().tolist() if r.boxes.id is not None else [None] * len(r.boxes)
        for box, cls, conf, tid in zip(r.boxes.xyxy.tolist(), r.boxes.cls.int().tolist(), r.boxes.conf.tolist(), ids):
            if cls not in ROLE: continue
            role = ROLE[cls]; team = kit(frame, box) if role == "player" else None
            fx, fy = (box[0] + box[2]) / 2, box[3]
            pp = to_pitch(fx, fy, *cam[:3], cx, cy) if cam else None
            det_rows.append([fi, t, role, team or "", tid if tid is not None else "", round(fx, 1), round(fy, 1),
                             round(pp[0], 2) if pp else "", round(pp[1], 2) if pp else "", round(conf, 3)])
            col = COL.get(team if role == "player" else role, (160, 160, 160))
            cv2.rectangle(vis, (int(box[0]), int(box[1])), (int(box[2]), int(box[3])), col, 3)
    if fi in ball:
        bx, by = ball[fi]
        pp = to_pitch(bx, by, *cam[:3], cx, cy) if cam else None
        det_rows.append([fi, t, "ball", "", "", round(bx, 1), round(by, 1),
                         round(pp[0], 2) if pp else "", round(pp[1], 2) if pp else "", ""])
        cv2.circle(vis, (int(bx), int(by)), 22, (0, 255, 255), 4)
    cv2.imwrite(f"{a.outdir}/frames/{n:05d}.jpg", cv2.resize(vis, (960, 540)), [cv2.IMWRITE_JPEG_QUALITY, 88])
    n += 1; fi += 1
    print(f"frame {fi} ({n})", flush=True)

with open(a.outdir + "/detections.csv", "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["frame", "t", "kind", "team", "track_id", "img_x", "img_y", "pitch_x", "pitch_y", "conf"]); w.writerows(det_rows)
with open(a.outdir + "/camera.csv", "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["frame", "t", "pan_deg", "tilt_deg", "f_px", "solved"]); w.writerows(cam_rows)
subprocess.run([a.ffmpeg, "-loglevel", "error", "-y", "-framerate", str(a.fps), "-i", a.outdir + "/frames/%05d.jpg",
                "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "23", "-movflags", "+faststart", a.outdir + "/replay.mp4"], check=True)
print("done", n, "frames", len(det_rows), "detections")

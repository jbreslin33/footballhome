"""Ball candidate pass: every frame (at 10 fps) gets ALL plausible ball spots —
YOLO11x sports-ball hits on overlapping tiles (low conf) + small white round blobs
on grass that are not inside a player box.  A later linker picks the path that
moves like a ball.  Output: ball_cands.csv (frame, t, src, x, y, w, h, score)."""
import csv, sys, cv2, numpy as np, torch
from ultralytics import YOLO

torch.set_num_threads(2)
src, out, secs = sys.argv[1], sys.argv[2], float(sys.argv[3])
cap = cv2.VideoCapture(src); fps = cap.get(cv2.CAP_PROP_FPS) or 30
step = round(fps / 10)
ball_m, ppl_m = YOLO("yolo11x.pt"), YOLO("yolo11s.pt")

def tiles(f, size=640, ov=160):
    H, W = f.shape[:2]; y0 = int(H * 0.30)
    for y in range(y0, H - ov, size - ov):
        for x in range(0, W - ov, size - ov):
            yield x, y, f[y:min(y + size, H), x:min(x + size, W)]

def blobs(f, people):
    H, W = f.shape[:2]; y0 = int(H * 0.30)
    hsv = cv2.cvtColor(f, cv2.COLOR_BGR2HSV)
    white = cv2.inRange(hsv, (0, 0, 165), (180, 70, 255))
    white[:y0] = 0
    for (x1, y1, x2, y2) in people:          # players' kits/socks aren't the ball
        white[int(y1):int(y2), int(x1):int(x2)] = 0
    n, lab, st, cen = cv2.connectedComponentsWithStats(white, 8)
    res = []
    for i in range(1, n):
        x, y, w, h, a = st[i]
        if not (3 <= w <= 24 and 3 <= h <= 24 and a >= 8): continue
        ar = w / h; fill = a / (w * h)
        if 0.6 <= ar <= 1.6 and fill >= 0.45:     # roundish, solid — not a pitch line
            res.append((x + w / 2, y + h / 2, w, h, round(fill * min(ar, 1 / ar), 2)))
    return res

rows, fi = [], 0
while fi < secs * fps:
    ok, f = cap.read()
    if not ok: break
    if fi % step == 0:
        t = round(fi / fps, 2)
        p = ppl_m(f, classes=[0], imgsz=1280, conf=0.15, verbose=False)[0]
        people = p.boxes.xyxy.tolist()
        for x, y, tl in tiles(f):
            r = ball_m(tl, classes=[32], imgsz=960, conf=0.03, verbose=False)[0]
            for b, c in zip(r.boxes.xyxy.tolist(), r.boxes.conf.tolist()):
                rows.append([fi, t, "yolo", round((b[0] + b[2]) / 2 + x, 1), round((b[1] + b[3]) / 2 + y, 1),
                             round(b[2] - b[0], 1), round(b[3] - b[1], 1), round(c, 3)])
        for (cx, cy, w, h, s) in blobs(f, people):
            rows.append([fi, t, "blob", round(cx, 1), round(cy, 1), w, h, s])
        for b in people:
            rows.append([fi, t, "person", round((b[0] + b[2]) / 2, 1), round(b[3], 1), round(b[2] - b[0], 1), round(b[3] - b[1], 1), 0])
        print(fi, flush=True)
    fi += 1
with open(out, "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["frame", "t", "src", "x", "y", "w", "h", "score"]); w.writerows(rows)
print("done", len(rows))

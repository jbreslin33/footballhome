"""Pick the ball's path out of per-frame candidates (ball_cands.csv).

Viterbi over frames (10 fps): each frame's states = its yolo + blob candidates
+ one 'not visible' state.  Emission: yolo conf strongly, blob roundness weakly,
bonus when the spot is at a player's feet (that's where the ball usually is).
Transition: a ball moves < ~MAXJ px per 0.1 s (camera pans too); smooth paths win;
'not visible' costs a little per frame so short gaps are bridged, long ones aren't.
Output: ball_path.csv (frame, t, x, y, src, score) — only frames where a spot was chosen."""
import csv, sys, math, collections

cands = collections.defaultdict(list); people = collections.defaultdict(list); tmap = {}
for r in csv.DictReader(open(sys.argv[1])):
    fr = int(r["frame"]); tmap[fr] = float(r["t"])
    x, y, w, h, sc = float(r["x"]), float(r["y"]), float(r["w"]), float(r["h"]), float(r["score"])
    if r["src"] == "person": people[fr].append((x, y, w, h))
    else: cands[fr].append((x, y, r["src"], sc, w, h))
frames = sorted(tmap)

# A spot that stays put (±5 px) for 2 s+ is a grass clump / line mark, not the ball.
# (Camera held still 0:18–0:30 in the Heritage test: the clump at 1175,835 owned the path.)
import cv2
cap = cv2.VideoCapture(sys.argv[3]) if len(sys.argv) > 3 else None
def on_grass(fr_img, x, y):
    if fr_img is None: return True
    H, W = fr_img.shape[:2]
    ring = fr_img[max(0, int(y) - 22):int(y) + 22, max(0, int(x) - 22):int(x) + 22]
    hsv = cv2.cvtColor(ring, cv2.COLOR_BGR2HSV).reshape(-1, 3)
    green = ((hsv[:, 0] > 20) & (hsv[:, 0] < 95) & (hsv[:, 1] > 25)).mean()
    return green > 0.45
imgs = {}
if cap is not None:
    fi = 0; want = set(frames)
    while fi <= frames[-1]:
        ok, im = cap.read()
        if not ok: break
        if fi in want: imgs[fi] = im
        fi += 1
STILL_FRAMES = 20          # 2 s at 10 fps
orig = {fr: list(cands[fr]) for fr in frames}     # count against the unfiltered lists
for fr in frames:
    keep = []
    for c in orig[fr]:
        if c[2] == "blob" and not on_grass(imgs.get(fr), c[0], c[1]): continue
        still = 0
        for fr2 in frames:
            if abs(fr2 - fr) > 90: continue          # ±3 s window
            if any(abs(c[0] - d[0]) < 5 and abs(c[1] - d[1]) < 5 for d in orig[fr2]): still += 1
        if still >= STILL_FRAMES: continue
        keep.append(c)
    cands[fr] = keep
MAXJ, MISS = 140.0, 2.2

def emit(fr, c):
    x, y, src, sc, w, h = c
    e = 4.0 + 12 * sc if src == "yolo" else 0.8 + 1.5 * sc
    for (px, py, pw, ph) in people[fr]:                # near a player's feet
        if abs(x - px) < pw * 1.2 and -ph * 0.35 < y - py < ph * 0.25:
            e += 1.0; break
    if w > 28 or h > 28: e -= 3
    return e

# Viterbi (maximise score)
prev = [(0.0, None, None)]          # (score, state, backptr) ; state None = missing
hist = []
for fr in frames:
    states = [None] + cands[fr]
    cur = []
    for s in states:
        best = (-1e9, None)
        for i, (ps, pst, _) in enumerate(prev):
            if s is None:
                v = ps - MISS
            elif pst is None:
                v = ps + emit(fr, s) - 1.5
            else:
                d = math.hypot(s[0] - pst[0], s[1] - pst[1])
                if d > MAXJ: continue
                v = ps + emit(fr, s) - (d / MAXJ) ** 2 * 2
            if v > best[0]: best = (v, i)
        cur.append((best[0], s, best[1]))
    hist.append(cur); prev = cur
# backtrack
i = max(range(len(prev)), key=lambda k: prev[k][0])
path = []
for fr, cur in zip(reversed(frames), reversed(hist)):
    sc, s, bp = cur[i]
    path.append((fr, s)); i = bp if bp is not None else 0
path.reverse()
with open(sys.argv[2], "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["frame", "t", "x", "y", "src", "score"])
    for fr, s in path:
        if s is not None: w.writerow([fr, tmap[fr], s[0], s[1], s[2], s[3]])
seen = sum(1 for _, s in path if s is not None)
print(f"ball placed in {seen} of {len(path)} frames; yolo {sum(1 for _, s in path if s and s[2]=='yolo')}, blob {sum(1 for _, s in path if s and s[2]=='blob')}")

#!/usr/bin/env python3
"""benchmarks_tracking_lossgoalside.py — after a side loses the ball near its own goal, how many of it are goal-side
of the ball, second by second (G5.208, game/DESIGN.md §8.314).

    python3 -I game/scripts/benchmarks_tracking_lossgoalside.py <dfl dir>

Source: Bassek, Rein, Weber & Memmert (2025), doi 10.6084/m9.figshare.28196177, CC BY, data owner DFL (7 matches of
2022/23, TRACAB; loader benchmarks_tracking.py). 5 Hz, ball in play, 9+ outfielders a side. A LOSS = the possession
flag changes side with the ball within 35 m of the losing side's goal line (0-18 / 18-35 m). For the side that lost
it, GOAL-SIDE = its outfielders nearer its goal centre than the ball; counted at 0 / 1 / 2 / 3 / 5 s after the loss
while the other side still has it (the losses still live at that second in brackets). fh-game-match prints the same as
LOSS THEN GOAL-SIDE. FH original.
"""
import collections, glob, math, multiprocessing, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import benchmarks_tracking as bt   # noqa: E402

AT = (0, 5, 10, 15, 25)   # frames: 0 / 1 / 2 / 3 / 5 s


class LossTally(bt.ShapeTally):
    def __init__(self, length):
        super().__init__(length)
        self.c = collections.Counter()

    def period(self, frames):
        side = {}
        for t in (0, 1):
            ks = [p[0] for f in frames for p in f[4][t]] or [p[0] for f in frames for p in f[3][t]]
            side[t] = -1 if sum(ks) > 0 else 1   # s * x + half = metres off t's own line
        held = 0
        for i in range(1, len(frames)):
            a, prev = frames[i], frames[i - 1]
            if a[2] == prev[2]:
                held += 1
                continue
            age, held = held, 0   # frames the loser had had it
            lo = 1 - a[2]
            s = side[lo]
            m = s * a[0] + self.half
            if m >= 35 or len(a[3][lo]) < 9:
                continue
            z = (0 if m < 18 else 1) + (2 if age * bt.DT >= 3 else 0)   # +2: held 3 s+ (build-up), else a scramble
            self.c[f"n{z}"] += 1
            for j, off in enumerate(AT):
                if i + off >= len(frames):
                    break
                f = frames[i + off]
                if any(frames[i + q][2] != a[2] for q in range(off + 1)):
                    break   # lost it back (or out) before this second
                gx = -s * self.half   # the loser's goal centre x
                db = math.hypot(f[0] - gx, f[1])
                gs = sum(1 for p in f[3][lo] if math.hypot(p[0] - gx, p[1]) < db)
                self.c[f"k{z}{j}"] += 1
                self.c[f"g{z}{j}"] += gs
                self.c[f"le1{z}{j}"] += gs <= 1

    def result(self):
        return {"c": self.c}


def one(pos_path):
    d = os.path.dirname(pos_path)
    mid = pos_path.rsplit("_", 1)[1]
    info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    bt.ShapeTally = LossTally
    _, _, res = bt.dfl_match(pos_path, info)
    return res


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
    c = collections.Counter()
    with multiprocessing.Pool(2) as pool:
        for r in pool.imap_unordered(one, files):
            c.update(r["c"])
    tm = 2 * len(files)
    print(f"LOSS THEN GOAL-SIDE — DFL, {len(files)} matches: losses within 35 m of the loser's goal line; its outfielders "
          "goal-side of the ball at 0 / 1 / 2 / 3 / 5 s (mean, share with 0-1, losses still theirs)")
    for z, zn in ((0, "0-18 held <3 s"), (2, "0-18 held 3 s+"), (1, "18-35 held <3 s"), (3, "18-35 held 3 s+")):
        print(f"  {zn:15s} {c[f'n{z}'] / tm:5.2f} a team-match: " + "; ".join(
            f"{('0', '1', '2', '3', '5')[j]} s {c[f'g{z}{j}'] / max(1, c[f'k{z}{j}']):.2f} ({100 * c[f'le1{z}{j}'] / max(1, c[f'k{z}{j}']):.0f}% 0-1, n {c[f'k{z}{j}']})"
            for j in range(len(AT))))

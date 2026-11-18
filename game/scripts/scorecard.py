#!/usr/bin/env python3
"""scorecard.py — the realism scorecard (G5.158, game/DESIGN.md §8.263): every headline number of the game
against the real one, biggest miss first.

    python3 -I game/scripts/scorecard.py <real_scorecard.json> <ours_seed1.json> [<ours_seed2.json> ...]

real: benchmarks_statsbomb_scorecard.py (StatsBomb PL 2015/16, all 380 matches, 95% bootstrap interval).
ours: fh-game-match runs with GAME_SCORECARD=<file> (one file a seed; 8+ matches each).
Per stat: real [95% interval] | ours mean over the runs (min-max) | ours / real | z = (ours − real) /
sqrt(se_real² + se_ours²), se_real from the interval, se_ours the runs' sd / √runs | verdict:
  ok   — |z| < 2 (inside the noise of both)
  off  — |z| ≥ 2 and ours within ±15% of real
  OFF  — |z| ≥ 2 and more than 15% away
Sorted by |log(ours / real)|. Tracking-only numbers (no PL measure) are listed apart, each with its source.
FH original.
"""
import json, math, sys

# Numbers only tracking measures — no PL 15/16 source; provisional until the pooled tracking benchmarks
# (DESIGN §8.263) replace them: (value, source).
TRACKING = {"ball_in_play_pct": (55.2, "DFL Bundesliga 22/23, 7 matches")}


def main():
    real = json.load(open(sys.argv[1]))
    runs = [json.load(open(p)) for p in sys.argv[2:]]
    keys = list(runs[0]["stats"])
    rows, side = [], []
    for k in keys:
        xs = [r["stats"][k] for r in runs if k in r["stats"]]
        m = sum(xs) / len(xs)
        sd = math.sqrt(sum((x - m) ** 2 for x in xs) / (len(xs) - 1)) if len(xs) > 1 else 0.0
        if k in real["stats"]:
            rv = real["stats"][k]
            v, lo, hi = rv["value"], rv["lo"], rv["hi"]
            se = math.sqrt(((hi - lo) / 3.92) ** 2 + (sd / math.sqrt(len(xs))) ** 2) or 1e-9
            z = (m - v) / se
            ratio = m / v if v else float("inf")
            far = abs(ratio - 1) > 0.15
            verdict = "ok" if abs(z) < 2 else ("OFF" if far else "off")
            rows.append((abs(math.log(ratio)) if v and m > 0 else 9.0, k, v, lo, hi, m, min(xs), max(xs), ratio, z, verdict))
        elif k in TRACKING:
            side.append((k, TRACKING[k], m, min(xs), max(xs)))
    rows.sort(key=lambda r: -r[0])
    seeds = ", ".join(str(r.get("seed", "?")) for r in runs)
    print(f"REALISM SCORECARD — ours: {len(runs)} runs x {runs[0].get('matches')} matches (seeds {seeds}); "
          f"real: {real['source']}, {real['matches']} matches")
    print(f"{'':4s}{'stat':24s}{'real':>9s} {'95%':>17s} {'ours':>9s} {'min-max':>17s} {'x real':>7s} {'z':>6s}")
    for _, k, v, lo, hi, m, a, b, ratio, z, verdict in rows:
        print(f"{verdict:4s}{k:24s}{v:9.2f} [{lo:7.2f},{hi:7.2f}] {m:9.2f} [{a:7.2f},{b:7.2f}] {ratio:7.2f} {z:6.1f}")
    n_ok = sum(r[-1] == "ok" for r in rows); n_off = sum(r[-1] == "off" for r in rows); n_OFF = sum(r[-1] == "OFF" for r in rows)
    print(f"    {n_ok} ok, {n_off} off (within 15%), {n_OFF} OFF of {len(rows)}")
    if side:
        print("TRACKING-ONLY (provisional; one source until the pooled tracking benchmarks land):")
        for k, (v, src), m, a, b in side:
            print(f"    {k:24s}{v:9.2f} ({src}) ours {m:.2f} [{a:.2f}, {b:.2f}]")


if __name__ == "__main__":
    main()

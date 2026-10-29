#!/usr/bin/env python3
"""benchmarks_statsbomb_360.py — the pro's balls in behind the line (G4.98,
game/DESIGN.md §8.96), from StatsBomb Open Data's 360 freeze frames.

    python3 -I game/scripts/benchmarks_statsbomb_360.py <competition_id> <season_id> [cache_dir] > out.json

The event tag (Pass technique Through Ball, benchmarks_statsbomb.py) is a
narrow one — a ball split between defenders for a runner. The harness asks a
plainer question: a pass aimed past their last outfield man at the kick.
The 360 freeze frame on each pass says where everyone in the camera's view
stood when it was struck, so the same question can be put to the pro:

  back line         the deepest outfield opponent's distance off his own goal
                    line in each such frame (percentiles, by the passer's
                    half) — where a pro line sits, for what counts as high.
  ball in behind    an open-play pass (no corner, free kick, throw-in, goal
                    kick or kick-off), 3 m+ forward, whose end location lies
                    beyond the deepest OUTFIELD opponent in its freeze frame,
                    with at least 4 outfield opponents in view (a back line
                    off camera would make a deep ball look like one) and its
                    end inside the camera's visible area.

Broadcast frames can miss an off-camera defender deeper still, so the count
is a ceiling, not exact. Also: completed, lofted (High Pass), from the
passer's own half, under pressure (StatsBomb's under_pressure), and how far
past the last man it ended.

Data: StatsBomb Open Data — free to use with attribution to StatsBomb.
FH original: the measure; StatsBomb: the events and freeze frames.
"""
import json
import os
import shutil
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from benchmarks_statsbomb import BASE, YD, fetch, bucket, Tally   # noqa: E402

LINE = []   # (their back line's distance from their goal, m; passer in his own half)
SET_PIECES = {"Corner", "Free Kick", "Throw-in", "Goal Kick", "Kick Off"}


def inside(pt, poly):
    """Point in polygon (ray casting); poly is a flat [x0, y0, x1, y1, ...]."""
    x, y = pt
    xs, ys = poly[0::2], poly[1::2]
    n, c = len(xs), False
    j = n - 1
    for i in range(n):
        if (ys[i] > y) != (ys[j] > y) and x < (xs[j] - xs[i]) * (y - ys[i]) / (ys[j] - ys[i]) + xs[i]:
            c = not c
        j = i
    return c


def measure(events, frames, T):
    T.add("matches")
    ff = {f["event_uuid"]: f for f in frames}
    for e in events:
        if e["period"] > 4 or e["type"]["name"] != "Pass":
            continue
        p = e["pass"]
        if p.get("type", {}).get("name") in SET_PIECES:
            continue
        T.add("passes")
        sx, ex = e["location"][0], p["end_location"][0]
        if (ex - sx) * YD < 3:
            continue
        f = ff.get(e["id"])
        if not f:
            continue
        T.add("fwd_framed")
        opp = [q["location"][0] for q in f["freeze_frame"] if not q["teammate"] and not q["keeper"]]
        if len(opp) < 4 or not inside(p["end_location"], f.get("visible_area", [])):
            continue
        T.add("fwd_seen")
        back = max(opp)
        LINE.append(((120 - back) * YD, sx < 60))   # their last outfielder off his goal line
        if ex <= back:
            continue
        T.add("behind")
        if "outcome" not in p:
            T.add("behind_complete")
        if p.get("height", {}).get("name") == "High Pass":
            T.add("behind_lofted")
        if sx < 60:
            T.add("behind_own_half")
        if e.get("under_pressure"):
            T.add("behind_pressed")
        T.add(f"behind_depth_{bucket((ex - back) * YD, (2, 5, 10))}")


def main():
    comp, season = sys.argv[1], sys.argv[2]
    cache = sys.argv[3] if len(sys.argv) > 3 else None
    tmp = None
    if not cache:
        tmp = cache = tempfile.mkdtemp(prefix="sb360-")
    os.makedirs(cache, exist_ok=True)
    try:
        matches = fetch(f"{BASE}/matches/{comp}/{season}.json", os.path.join(cache, f"matches_{comp}_{season}.json"))
        ids = [m["match_id"] for m in matches]
        with ThreadPoolExecutor(8) as ex:
            evs = list(ex.map(lambda i: fetch(f"{BASE}/events/{i}.json", os.path.join(cache, f"{i}.json")), ids))
            fr = list(ex.map(lambda i: fetch(f"{BASE}/three-sixty/{i}.json", os.path.join(cache, f"360_{i}.json")), ids))
        T = Tally()
        for e, f in zip(evs, fr):
            measure(e, f, T)
    finally:
        if tmp:
            shutil.rmtree(tmp, ignore_errors=True)
    tm = 2 * T.get("matches")
    bh = max(1, T.get("behind"))
    c0 = matches[0]
    out = {
        "competition": c0["competition"]["competition_name"],
        "season": c0["season"]["season_name"],
        "matches": T.get("matches"),
        "forward_passes_framed_seen_pct": round(100.0 * T.get("fwd_seen") / max(1, T.get("fwd_framed")), 1),
        "metrics": {
            "behind_line_passes_per_team_match": round(T.get("behind") / tm, 2),
            "behind_line_completion_pct": round(100.0 * T.get("behind_complete") / bh, 1),
            "behind_line_lofted_pct": round(100.0 * T.get("behind_lofted") / bh, 1),
            "behind_line_own_half_pct": round(100.0 * T.get("behind_own_half") / bh, 1),
            "behind_line_pressed_pct": round(100.0 * T.get("behind_pressed") / bh, 1),
        },
    }
    for half, name in ((True, "own_half"), (False, "their_half")):
        xs = sorted(d for d, h in LINE if h == half)
        if xs:
            for q in (25, 50, 75, 90):
                out["metrics"][f"back_line_m_p{q}_passer_{name}"] = round(xs[min(len(xs) - 1, len(xs) * q // 100)], 1)
    for i, n in enumerate(("lt2m", "2_5m", "5_10m", "10m_plus")):
        out["metrics"][f"behind_line_depth_{n}_pct"] = round(100.0 * T.get(f"behind_depth_{i}") / bh, 1)
    json.dump(out, sys.stdout, indent=1)
    print()


if __name__ == "__main__":
    main()

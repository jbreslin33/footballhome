#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_foot.py — strong foot and weak foot, elite (G5.79 kicks off a plant foot).

    python3 -I game/scripts/benchmarks_statsbomb_foot.py <events dir>

Every outfielder's open-play passes and shots by body part (StatsBomb: Right Foot / Left Foot / Head /
Other). His STRONG foot = the foot of most of his footed passes (players with 100+ footed passes). Then:
the share of players who are left-footed; how often each plays the weak foot (passes, shots: median and
quartiles over players); pass completion and length, strong v weak; shots on target and goals per shot,
strong v weak; and the weak-foot share by where the ball is across his body — not in the data, so by the
pass's direction relative to his strong side (a right-footer's passes to his left v right).

Data: StatsBomb Open Data (PL 2015/16), free with attribution to StatsBomb (github.com/statsbomb/open-data).
FH original.
"""
import collections, glob, json, math, os, statistics, sys

files = [f for f in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))) if os.path.basename(f)[0].isdigit()]
pas = collections.defaultdict(lambda: collections.Counter())   # player -> foot -> passes
rec = []   # (player, foot, completed, length, dy_signed_by_attack)
shots = []  # (player, foot, on_target, goal, xg)
for f in files:
    E = json.load(open(f, encoding="utf8"))
    gk = {e["player"]["id"] for e in E if e.get("position", {}).get("name") == "Goalkeeper" and "player" in e}
    for e in E:
        t = e["type"]["name"]
        if "player" not in e or e["player"]["id"] in gk:
            continue
        if e.get("play_pattern", {}).get("name") not in ("Regular Play", "From Counter", "From Keeper"):
            continue
        if t == "Pass":
            p = e["pass"]
            if p.get("type") is not None:
                continue
            bp = p.get("body_part", {}).get("name")
            if bp not in ("Right Foot", "Left Foot"):
                continue
            pid = e["player"]["id"]
            pas[pid][bp] += 1
            (x, y), (ex, ey) = e["location"], p["end_location"]
            rec.append((pid, bp, "outcome" not in p, math.hypot(ex - x, ey - y) * 105 / 120, (ey - y)))
        elif t == "Shot":
            s = e["shot"]
            bp = s.get("body_part", {}).get("name")
            if bp not in ("Right Foot", "Left Foot") or s.get("type", {}).get("name") != "Open Play":
                continue
            o = s.get("outcome", {}).get("name")
            shots.append((e["player"]["id"], bp, o in ("Goal", "Saved", "Saved To Post"), o == "Goal", s.get("statsbomb_xg", 0)))
strong = {}
for pid, c in pas.items():
    n = c["Right Foot"] + c["Left Foot"]
    if n >= 100:
        strong[pid] = "Right Foot" if c["Right Foot"] >= c["Left Foot"] else "Left Foot"
weak_share = sorted(min(c["Right Foot"], c["Left Foot"]) / (c["Right Foot"] + c["Left Foot"]) for pid, c in pas.items() if pid in strong)
left = sum(1 for v in strong.values() if v == "Left Foot")
print(f"{len(files)} StatsBomb PL 15/16 matches; {len(strong)} outfielders with 100+ footed open-play passes")
print(f"  left-footed {100 * left / len(strong):.1f}%  |  weak-foot share of a player's passes: p10 {weak_share[len(weak_share) // 10]:.3f}  p25 {weak_share[len(weak_share) // 4]:.3f}  "
      f"med {statistics.median(weak_share):.3f}  p75 {weak_share[3 * len(weak_share) // 4]:.3f}  p90 {weak_share[9 * len(weak_share) // 10]:.3f}")
S = collections.defaultdict(list)
for pid, bp, ok, L, dy in rec:
    if pid not in strong:
        continue
    k = "strong" if bp == strong[pid] else "weak"
    S[k].append((ok, L))
for k in ("strong", "weak"):
    v = S[k]
    print(f"  passes {k:6s}: {len(v):7d} ({100 * len(v) / (len(S['strong']) + len(S['weak'])):.1f}%) completed {100 * sum(o for o, _ in v) / len(v):.1f}%  length med {statistics.median(L for _, L in v):.1f} m"
          f"  | 30 m+: share {100 * sum(1 for _, L in v if L >= 30) / len(v):.1f}%, completed {100 * sum(o for o, L in v if L >= 30) / max(1, sum(1 for _, L in v if L >= 30)):.1f}%")
for lo, hi in ((0, 15), (15, 30), (30, 99)):
    st = [o for o, L in S["strong"] if lo <= L < hi]; wk = [o for o, L in S["weak"] if lo <= L < hi]
    print(f"    {lo}-{hi if hi < 99 else '+'} m: completed strong {100 * sum(st) / max(1, len(st)):.1f}% weak {100 * sum(wk) / max(1, len(wk)):.1f}%  weak share {100 * len(wk) / max(1, len(st) + len(wk)):.1f}%")
# direction across his strong side: StatsBomb y grows to the attacking side's right? use sign relative to strong foot
side = collections.Counter()
for pid, bp, ok, L, dy in rec:
    if pid not in strong or abs(dy) < 3:
        continue
    # StatsBomb pitch: x toward the opponent goal, y down = to the attacker's right
    to_strong_side = (dy > 0) == (strong[pid] == "Right Foot")
    side[(to_strong_side, bp == strong[pid])] += 1
for ts in (True, False):
    n = side[(ts, True)] + side[(ts, False)]
    print(f"  passes played toward his {'strong' if ts else 'weak'} side (3 m+ across): weak foot {100 * side[(ts, False)] / max(1, n):.1f}% of {n}")
SH = collections.defaultdict(list)
for pid, bp, on, g, xg in shots:
    if pid in strong:
        SH["strong" if bp == strong[pid] else "weak"].append((on, g, xg))
for k in ("strong", "weak"):
    v = SH[k]
    print(f"  open-play shots {k:6s}: {len(v):5d} ({100 * len(v) / (len(SH['strong']) + len(SH['weak'])):.1f}%) on target {100 * sum(a for a, _, _ in v) / len(v):.1f}%  goals/shot {100 * sum(b for _, b, _ in v) / len(v):.1f}%  xG/shot {sum(c for _, _, c in v) / len(v):.3f}")

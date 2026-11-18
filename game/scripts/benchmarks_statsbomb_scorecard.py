#!/usr/bin/env python3
"""benchmarks_statsbomb_scorecard.py — the realism scorecard's real side (G5.158, game/DESIGN.md §8.263).

    python3 -I game/scripts/benchmarks_statsbomb_scorecard.py <PL 15/16 events dir> > real_scorecard.json

Every match of StatsBomb Open Data's Premier League 2015/16 (competition 2, season 27; 380 matches, both
sides), the headline numbers fh-game-match writes with GAME_SCORECARD, each on the cut the harness line
of the same name uses (and the per-topic benchmarks_statsbomb_*.py it came from):
  goals (every goal, penalties and own goals in) | shots (penalties in; outcome goal / saved / blocked /
  off; distance to the goal centre <12 / 12-18 / 18-25 / 25+ m and the share scored in each, penalties
  out of the bands) | penalties | open-play passes (set pieces out) and completion; switches, crosses,
  cut-backs (StatsBomb's flags) | dribbles tried / completed | carries gaining 10 m+ | pressures and the
  counter-press share | tackle duels | fouls committed | aerial duels a match (one Aerial Lost a duel: StatsBomb logs the loser; the winner's act carries aerial_won)
  | headed clearances | throw-ins, goal kicks, corners, free kicks (passes and shots) | offsides.
Per stat: the value (team-match rate, or a pooled share) and a 95% interval from 2000 bootstrap
resamples of the 380 matches (seed 7) — the uncertainty of the real number itself.
Pitch: StatsBomb 120 x 80 scaled to 105 x 68. Data: StatsBomb Open Data, free with attribution to
StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, math, os, random, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
SAVED = ("Saved", "Saved to Post", "Saved Off Target")


def band(x, y):
    d = math.hypot((120 - x) * SX, (40 - y) * SY)
    return 0 if d < 12 else 1 if d < 18 else 2 if d < 25 else 3


def one(path):
    c = collections.Counter()
    for e in json.load(open(path, encoding="utf8")):
        t = e["type"]["name"]
        if t == "Shot":
            s = e["shot"]; o = s["outcome"]["name"]; pen = s.get("type", {}).get("name") == "Penalty"
            c["shots"] += 1
            c["goals"] += o == "Goal"; c["shot_goals"] += o == "Goal"
            c["on"] += o == "Goal" or o in SAVED; c["blocked"] += o == "Blocked"; c["fin"] += 1
            if pen: c["pens"] += 1
            else:
                b = band(*e["location"]); c[f"b{b}"] += 1; c[f"bg{b}"] += o == "Goal"; c["banded"] += 1
            if s.get("type", {}).get("name") == "Free Kick": c["fk"] += 1
        elif t == "Own Goal Against":
            c["goals"] += 1
        elif t == "Pass":
            p = e["pass"]; pt = p.get("type", {}).get("name")
            if pt == "Throw-in": c["throw"] += 1
            elif pt == "Goal Kick": c["gk"] += 1
            elif pt == "Corner": c["corner"] += 1
            elif pt == "Free Kick": c["fk"] += 1
            if p.get("outcome", {}).get("name") == "Pass Offside": c["offside"] += 1
            if pt in SET: continue
            c["pass"] += 1
            if "outcome" not in p: c["pass_ok"] += 1
            if e.get("under_pressure"): c["pass_up"] += 1
            if p.get("switch"): c["switch"] += 1
            if p.get("cross"): c["cross"] += 1
            if p.get("cut_back"): c["cutback"] += 1
        elif t == "Offside":
            c["offside"] += 1
        elif t == "Pressure":
            c["press"] += 1; c["cpress"] += bool(e.get("counterpress"))
        elif t == "Dribble":
            c["drib"] += 1; c["dribok"] += e["dribble"].get("outcome", {}).get("name") == "Complete"
        elif t == "Carry":
            a, b = e["location"], e["carry"]["end_location"]
            if (b[0] - a[0]) * SX >= 10: c["carry10"] += 1
        elif t == "Duel":
            dt = e["duel"]["type"]["name"]
            if dt == "Tackle": c["tackle"] += 1
            elif dt == "Aerial Lost": c["aerial"] += 1
        elif t == "Foul Committed":
            c["foul"] += 1
        elif t == "Clearance":
            if e["clearance"].get("body_part", {}).get("name") == "Head": c["hclear"] += 1
    return c


# stat -> (kind, numerator, denominator): "tm" = per team-match (2 a match), "m" = per match, "pct" = 100·num/den
STATS = {
    "goals_tm": ("tm", "goals"), "shots_tm": ("tm", "shots"), "conversion_pct": ("pct", "shot_goals", "shots"),
    "on_target_pct": ("pct", "on", "fin"), "blocked_pct": ("pct", "blocked", "fin"), "off_target_pct": ("off",),
    "shots_lt12_pct": ("pct", "b0", "banded"), "shots_12_18_pct": ("pct", "b1", "banded"),
    "shots_18_25_pct": ("pct", "b2", "banded"), "shots_25p_pct": ("pct", "b3", "banded"),
    "scored_lt12_pct": ("pct", "bg0", "b0"), "scored_12_18_pct": ("pct", "bg1", "b1"),
    "scored_18_25_pct": ("pct", "bg2", "b2"), "scored_25p_pct": ("pct", "bg3", "b3"),
    "penalties_tm": ("tm", "pens"), "passes_tm": ("tm", "pass"), "pass_completion_pct": ("pct", "pass_ok", "pass"),
    "passes_under_pressure_pct": ("pct", "pass_up", "pass"),
    "crosses_tm": ("tm", "cross"), "switches_tm": ("tm", "switch"), "cutbacks_tm": ("tm", "cutback"),
    "takeons_tm": ("tm", "drib"), "takeon_success_pct": ("pct", "dribok", "drib"), "carries10_tm": ("tm", "carry10"),
    "pressures_tm": ("tm", "press"), "counterpress_pct": ("pct", "cpress", "press"), "tackles_tm": ("tm", "tackle"),
    "fouls_tm": ("tm", "foul"), "aerial_duels_m": ("m", "aerial"), "headed_clearances_tm": ("tm", "hclear"),
    "throwins_tm": ("tm", "throw"), "goalkicks_tm": ("tm", "gk"), "corners_tm": ("tm", "corner"),
    "freekicks_tm": ("tm", "fk"), "offsides_tm": ("tm", "offside"),
}


def value(tot, n, spec):
    k = spec[0]
    if k == "tm": return tot[spec[1]] / (2 * n)
    if k == "m": return tot[spec[1]] / n
    if k == "off": return 100 * (tot["fin"] - tot["on"] - tot["blocked"]) / max(1, tot["fin"])
    return 100 * tot[spec[1]] / max(1, tot[spec[2]])


if __name__ == "__main__":
    files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
    per = [one(f) for f in files]
    n = len(per)
    tot = collections.Counter()
    for c in per: tot.update(c)
    rng = random.Random(7)
    boots = {k: [] for k in STATS}
    for _ in range(2000):
        b = collections.Counter()
        for _ in range(n): b.update(per[rng.randrange(n)])
        for k, spec in STATS.items(): boots[k].append(value(b, n, spec))
    out = {"source": "StatsBomb Open Data, Premier League 2015/16", "matches": n, "stats": {}}
    for k, spec in STATS.items():
        v = sorted(boots[k])
        out["stats"][k] = {"value": round(value(tot, n, spec), 4), "lo": round(v[int(0.025 * len(v))], 4), "hi": round(v[int(0.975 * len(v)) - 1], 4)}
    json.dump(out, sys.stdout, indent=1)
    print()

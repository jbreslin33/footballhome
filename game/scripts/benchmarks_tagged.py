#!/usr/bin/env python3
"""benchmarks_tagged.py — semi-pro reference numbers from film we tag ourselves.

    python3 -I game/scripts/benchmarks_tagged.py <competition> <season> sheet1.csv [sheet2.csv ...] > out.json

No public data covers our level, so the source is our own film (#film). One
sheet a game, one row a ball action, open play only, tagged by a person:

    half,clock,team,action,third
    1,12:04,lh,pass_ok,mid

  clock   mm:ss on the film clock (a half need not start at 0:00)
  team    any two short names, the same all game
  action  pass_ok   reached a mate
          pass_lost did not (picked off, or out of play)
          lost      lost it on the ball: tackled, bad touch
          clear     a clearance
          shot      a shot, not scored
          goal      a shot, scored
          restart   a set piece taken: holds the ball, counts as no pass
  third   where the action was, from THAT team's direction: own, mid, att

Tag a whole half if a whole game is too long: rates are scaled by the time
tagged (first action to last, each half). A change of the acting team is a new
spell, as in benchmarks_statsbomb.py, and a spell whose first action is in the
new team's attacking third is the other team's own-third loss. The codes are
the StatsBomb rows' codes, so a harness line, a pro line and a semi-pro line
ask the same question. One person's tagging: keep the same reader across games.

FH original: the tag sheet. Metric definitions: game_benchmark_metrics.
"""
import csv
import json
import statistics
import sys

ACTIONS = {"pass_ok", "pass_lost", "lost", "clear", "shot", "goal", "restart"}
THIRDS = {"own", "mid", "att"}


def read_sheet(path):
    rows = []
    with open(path, newline="", encoding="utf8") as f:
        for n, r in enumerate(csv.DictReader(f), 2):
            m, s = r["clock"].split(":")
            half, team, act, third = int(r["half"]), r["team"].strip(), r["action"].strip(), r["third"].strip()
            if act not in ACTIONS or third not in THIRDS:
                raise SystemExit(f"{path}:{n}: bad action or third: {act!r} {third!r}")
            rows.append((half, int(m) * 60 + int(s), team, act, third))
    teams = {r[2] for r in rows}
    if len(teams) != 2:
        raise SystemExit(f"{path}: expected two teams, found {sorted(teams)}")
    for a, b in zip(rows, rows[1:]):
        if a[0] == b[0] and b[1] < a[1]:
            raise SystemExit(f"{path}: clock runs backward at {b[1] // 60}:{b[1] % 60:02d}, half {b[0]}")
    return rows


def measure(rows):
    tagged = 0
    for h in {r[0] for r in rows}:
        ts = [r[1] for r in rows if r[0] == h]
        tagged += max(ts) - min(ts)
    if tagged <= 0:
        raise SystemExit("a sheet covers no time")
    per_match = 90 * 60.0 / tagged     # both teams together, scaled to 90
    per_team = per_match / 2
    spells = []
    for r in rows:
        if not spells or spells[-1][0] != r[2] or spells[-1][1] != r[0]:
            spells.append([r[2], r[0], []])
        spells[-1][2].append(r)
    changes = [s for a, s in zip(spells, spells[1:]) if a[1] == s[1]]
    # Time to the next spell's start, as the pro's spell clock runs.
    spans = [b[2][0][1] - a[2][0][1] for a, b in zip(spells, spells[1:]) if a[1] == b[1]]
    own3 = [s for s in changes if s[2][0][4] == "att"]
    quick = sum(any(r[3] in ("shot", "goal") and r[1] - s[2][0][1] <= 10 for r in s[2]) for s in own3)
    passes = sum(r[3] in ("pass_ok", "pass_lost") for r in rows)
    ok = sum(r[3] == "pass_ok" for r in rows)
    shots = sum(r[3] in ("shot", "goal") for r in rows)
    goals = sum(r[3] == "goal" for r in rows)
    out = {
        "open_play_passes_per_team_match": passes * per_team,
        "open_play_pass_completion_pct": 100.0 * ok / max(1, passes),
        "shots_open_play_per_team_match": shots * per_team,
        "goals_open_play_per_match": goals * per_match,
        "spells_per_match": len(changes) * per_match,
        "spell_length_s": statistics.mean(spans) if spans else None,
        "own_third_losses_per_team_match": len(own3) * per_team,
        "own_third_loss_shot_10s_pct": 100.0 * quick / len(own3) if own3 else None,
    }
    return out, tagged / 60.0


def main():
    if len(sys.argv) < 4:
        raise SystemExit(__doc__)
    comp, season, paths = sys.argv[1], sys.argv[2], sys.argv[3:]
    per = []
    minutes = 0.0
    for p in paths:
        m, t = measure(read_sheet(p))
        per.append(m)
        minutes += t
    metrics, spread = {}, {}
    for k in per[0]:
        xs = [m[k] for m in per if m[k] is not None]
        if xs:
            metrics[k] = round(statistics.mean(xs), 2)
            spread[k] = [round(min(xs), 2), round(max(xs), 2)]
    json.dump({"level": "semipro", "competition": comp, "season": season, "matches": len(per),
               "tagged_minutes": round(minutes, 1), "metrics": metrics, "range": spread}, sys.stdout, indent=1)
    print()


if __name__ == "__main__":
    main()

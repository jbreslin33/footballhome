#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_area_duels.py — the man on the ball in the
defenders' penalty area, and how often they challenge him (game/DESIGN.md §8.141).

    python3 -I game/scripts/benchmarks_statsbomb_area_duels.py <data dir>

Premier League 2015/16, 380 matches, StatsBomb Open Data (free with attribution).
Locations are the acting team's view (attacking toward x = 120); the attackers'
target area is x >= 102, 18 <= y <= 62 yards; the defenders' own area mirrored.

  exposure   a team-match, the attackers' receipts in the area, their carries
             in it (start in the area) and those carries' seconds;
  challenge  the defenders' tackle duels, fouls, and the attackers' take-ons
             (Dribble) in the area — per receipt and per carry-second.
"""
import json, os, sys

d = sys.argv[1]
ms = json.load(open(os.path.join(d, "matches.json")))
def att_area(l): return l is not None and l[0] >= 102 and 18 <= l[1] <= 62
def own_area(l): return l is not None and l[0] <= 18 and 18 <= l[1] <= 62
rec = car = 0; car_s = 0.0; duels = won = fouls = drib = drib_ok = 0; shots = 0
for m in ms:
    for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
        t = e["type"]["name"]; loc = e.get("location")
        if t == "Ball Receipt*" and att_area(loc) and "ball_receipt" not in e: rec += 1
        elif t == "Carry" and att_area(loc): car += 1; car_s += e.get("duration") or 0.0
        elif t == "Dribble" and att_area(loc):
            drib += 1; drib_ok += e["dribble"]["outcome"]["name"] == "Complete"
        elif t == "Shot" and att_area(loc) and e["shot"]["type"]["name"] == "Open Play": shots += 1
        elif t == "Duel" and e.get("duel", {}).get("type", {}).get("name") == "Tackle" and own_area(loc):
            duels += 1; won += e["duel"].get("outcome", {}).get("name") in ("Won", "Success", "Success In Play", "Success Out")
        elif t == "Foul Committed" and own_area(loc): fouls += 1
tm = 2 * len(ms)
print(f"EXPOSURE a team-match (attackers in the area): receipts {rec / tm:.2f}, carries {car / tm:.2f} lasting {car_s / tm:.1f} s "
      f"(median carry {car_s / max(1, car):.2f} s); open-play shots from it {shots / tm:.2f}")
print(f"CHALLENGES a team-match (defenders in their own area): tackle duels {duels / tm:.2f} (won {100 * won / max(1, duels):.0f}%), "
      f"fouls {fouls / tm:.2f}; attackers' take-ons {drib / tm:.2f} ({100 * drib_ok / max(1, drib):.0f}% complete)")
print(f"  per receipt: tackle duels {duels / max(1, rec):.3f}, take-ons {drib / max(1, rec):.3f}; "
      f"per carry-second: tackle duels {duels / max(1e-9, car_s):.3f}/s")

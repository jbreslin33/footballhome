#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_penalties.py — Law 14: fouls in a side's own
penalty area, penalties, and how they're taken (game/DESIGN.md §8.140).

    python3 -I game/scripts/benchmarks_statsbomb_penalties.py <data dir>

Premier League 2015/16, 380 matches, StatsBomb Open Data (free with attribution).
An event's location is from its own team's view (attacking toward x = 120), so a
defender's own penalty area is x <= 18, 18 <= y <= 62 (yards).

  in the area   tackle duels and fouls committed by a side in its own area: the
                share of its challenges there that are fouls, fouls ÷ (duels +
                fouls) — the same cut as §8.126's by third;
  penalties     awarded (penalty shots) a team-match; scored %; where they went
                (end_location across the mouth and height, on target).
"""
import json, os, sys

YD = 0.9144
d = sys.argv[1]
ms = json.load(open(os.path.join(d, "matches.json")))
duels = fouls = pens = goals = saved = off = 0
lat, ht = [], []
for m in ms:
    for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
        t = e["type"]["name"]
        loc = e.get("location")
        in_own_area = loc is not None and loc[0] <= 18 and 18 <= loc[1] <= 62
        if t == "Duel" and e.get("duel", {}).get("type", {}).get("name") == "Tackle" and in_own_area:
            duels += 1
        elif t == "Foul Committed" and in_own_area:
            fouls += 1
        elif t == "Shot" and e["shot"]["type"]["name"] == "Penalty":
            pens += 1
            o = e["shot"]["outcome"]["name"]
            goals += o == "Goal"
            saved += o in ("Saved", "Saved to Post")
            off += o not in ("Goal", "Saved", "Saved to Post")
            el = e["shot"].get("end_location") or []
            if o in ("Goal", "Saved", "Saved to Post") and len(el) >= 2:
                lat.append(abs(el[1] - 40) * YD)
                if len(el) > 2:
                    ht.append(el[2] * YD)
tm = 2 * len(ms)
print(f"OWN AREA: tackle duels {duels / tm:.2f} a team-match, fouls committed {fouls / tm:.2f}; "
      f"the share of challenges there that are fouls {100 * fouls / max(1, duels + fouls):.1f}%")
print(f"PENALTIES: {pens / tm:.3f} a team-match ({pens}); scored {100 * goals / pens:.1f}%, saved {100 * saved / pens:.1f}%, "
      f"missed {100 * off / pens:.1f}%")
if lat:
    lat.sort()
    print(f"  on target, metres from the centre: p25 {lat[len(lat) // 4]:.2f}, median {lat[len(lat) // 2]:.2f}, p75 {lat[3 * len(lat) // 4]:.2f}")
if ht:
    ht.sort()
    print(f"  on target, height m: p25 {ht[len(ht) // 4]:.2f}, median {ht[len(ht) // 2]:.2f}, p75 {ht[3 * len(ht) // 4]:.2f} ({len(ht)})")

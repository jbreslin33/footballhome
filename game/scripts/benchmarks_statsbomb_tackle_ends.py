#!/usr/bin/env python3
"""benchmarks_statsbomb_tackle_ends.py — where a real tackle sends the ball, 2015/16 Premier League (G5.261, game/DESIGN.md §8.367).
    python3 -I game/scripts/benchmarks_statsbomb_tackle_ends.py <events dir>
Every Tackle duel (StatsBomb: the tackler plays the ball off the carrier), by its outcome (Won / Success In Play /
Success Out: the tackler's side has it; Lost In Play / Lost Out: knocked away, the carrier's side has it), split by
whether the carrier was taking him on (a Dribble related to the duel) or not; then who has the ball next (the first
event that is not a Pressure / Duel / Dribbled Past / receipt / carry) and whether that is a restart (Throw-in, Goal
Kick, Corner, Free Kick) — a team-match. Last, every tackle by its m off the nearer touchline: how many, and the
share knocked out of play (Success Out / Lost Out). Ours: fh-game-match TACKLE ENDS.
Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data). FH original.
"""
import collections, glob, json, os, sys
files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[0].isdigit())
tm = 2 * len(files)
SKIP = ("Pressure", "Duel", "Dribbled Past", "Ball Receipt*", "Carry", "Dribble", "Foul Won")
RESTART = ("Throw-in", "Goal Kick", "Corner", "Free Kick", "Kick Off")
C = collections.Counter()
for f in files:
    ev = json.load(open(f, encoding="utf8")); byid = {e["id"]: e for e in ev}
    for i, e in enumerate(ev):
        if e["type"]["name"] != "Duel" or e.get("duel", {}).get("type", {}).get("name") != "Tackle": continue
        o = e["duel"].get("outcome", {}).get("name", "?")
        rel = [byid[r] for r in e.get("related_events", []) if r in byid]
        tko = "take-on" if any(r["type"]["name"] == "Dribble" for r in rel) else "no take-on"
        me = e["team"]["id"]
        C[(tko, o)] += 1
        if "location" in e:
            y = e["location"][1] * 68 / 80; d = min(y, 68 - y); b = 0 if d < 5 else 1 if d < 12 else 2 if d < 20 else 3
            C[("band", b)] += 1; C[("band_out", b)] += "Out" in o
        for n in ev[i + 1:i + 30]:
            tn = n["type"]["name"]
            if tn in SKIP: continue
            pt = n.get("pass", {}).get("type", {}).get("name", "")
            dead = pt in RESTART or n.get("play_pattern", {}).get("name") in ("From Throw In", "From Goal Kick", "From Corner", "From Free Kick") and n["possession"] != e["possession"]
            C[(tko, o, "tackler" if n["team"]["id"] == me else "carrier", "dead" if dead else "live")] += 1; break
for tko in ("take-on", "no take-on"):
    tot = sum(v for k, v in C.items() if len(k) == 2 and k[0] == tko)
    print(f"{tko}: tackles {tot/tm:.2f} a team-match")
    for o in ("Won", "Success In Play", "Success Out", "Lost In Play", "Lost Out"):
        k = C[(tko, o)]
        if not k: continue
        parts = " ".join(f"{s}/{d} {100*C[(tko,o,s,d)]/max(1,k):.0f}%" for s in ("tackler", "carrier") for d in ("live", "dead"))
        print(f"   {o:16s} {k/tm:5.2f} ({100*k/tot:4.1f}%)  next: {parts}")
    side = {s: sum(v for kk, v in C.items() if len(kk) == 4 and kk[0] == tko and kk[2] == s) for s in ("tackler", "carrier")}
    print(f"   next ball, all outcomes: tackler's side {100*side['tackler']/max(1,sum(side.values())):.1f}% / carrier's {100*side['carrier']/max(1,sum(side.values())):.1f}%")
for b, nm in enumerate(("<5 m", "5-12", "12-20", "20+")):
    print(f"m off the touchline {nm:6s} tackles {C[('band', b)]/tm:5.2f} a team-match, out of play {100*C[('band_out', b)]/max(1, C[('band', b)]):4.1f}%")

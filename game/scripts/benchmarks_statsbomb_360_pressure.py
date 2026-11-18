#!/usr/bin/env python3
"""benchmarks_statsbomb_360_pressure.py — what StatsBomb's "under pressure" means in metres (G5.159, DESIGN §8.264).

    python3 -I game/scripts/benchmarks_statsbomb_360_pressure.py <open360 dir> <PL 15/16 events dir>

StatsBomb's Pressure event is an analyst's tag (a man closing the one on the ball), not a distance rule, so a
count of our pressures on any distance rule is not StatsBomb's count (ours 385 a team-match on a 4.5 m closing rule,
StatsBomb 152; the same rule on DFL tracking 375 v 375). What can be carried across is the flag StatsBomb puts on
the act itself: under_pressure on an open-play pass. From the 360 freeze frames (every visible player at the
event, StatsBomb Open Data's men's competitions with 360: Bundesliga 23/24, World Cup 2022, La Liga 20/21, Ligue 1
21/22 + 22/23, MLS 2023, Euro 2020 + 2024, AFCON 2023): each open-play pass's passer (the actor) and his nearest
visible opponent outfielder, metres (120 x 80 scaled to 105 x 68); P(under_pressure | that distance) in 0.5 m bins
to 4 m, then 1 m to 8, then 8+, pooled and by competition. Then the real share of open-play passes under pressure
on StatsBomb PL 2015/16, all matches — the number fh-game-match's PASSES UNDER PRESSURE line reproduces by putting
each of our passes through the pooled curve. Data: StatsBomb Open Data, free with attribution to StatsBomb. FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
EDGES = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6, 7, 8, 1e9]


def bin_of(d):
    return next(i for i in range(len(EDGES) - 1) if EDGES[i] <= d < EDGES[i + 1])


def comp_counts(d):
    n = [0] * (len(EDGES) - 1); u = [0] * (len(EDGES) - 1); tot = flag = 0
    for f in glob.glob(os.path.join(d, "360_*.json")):
        mid = os.path.basename(f)[4:]
        ev = json.load(open(os.path.join(d, "events_" + mid), encoding="utf8"))
        byid = {e["id"]: e for e in ev}
        for fr in json.load(open(f, encoding="utf8")):
            e = byid.get(fr["event_uuid"])
            if not e or e["type"]["name"] != "Pass" or e["pass"].get("type", {}).get("name") in SET: continue
            act = [p for p in fr["freeze_frame"] if p.get("actor")]
            if not act: continue
            ax, ay = act[0]["location"]
            opp = [math.hypot((p["location"][0] - ax) * SX, (p["location"][1] - ay) * SY)
                   for p in fr["freeze_frame"] if not p["teammate"] and not p.get("keeper")]
            dmin = min(opp) if opp else 99.0
            b = bin_of(dmin); fl = bool(e.get("under_pressure"))
            n[b] += 1; u[b] += fl; tot += 1; flag += fl
    return n, u, tot, flag


if __name__ == "__main__":
    comps = json.load(open(os.path.join(sys.argv[1], "competitions.json")))
    names = {f"{c['competition_id']}_{c['season_id']}": f"{c['competition_name']} {c['season_name']}" for c in comps}
    N = [0] * (len(EDGES) - 1); U = [0] * (len(EDGES) - 1)
    print("StatsBomb 360: open-play passes, P(under_pressure | the passer's nearest visible opponent outfielder, m)")
    print("  bins: " + " ".join(f"{EDGES[i]:g}-{EDGES[i + 1]:g}" if EDGES[i + 1] < 1e8 else f"{EDGES[i]:g}+" for i in range(len(EDGES) - 1)))
    for d in sorted(glob.glob(os.path.join(sys.argv[1], "*_*"))):
        if not os.path.isdir(d): continue
        n, u, tot, flag = comp_counts(d)
        if tot < 500: continue
        for i in range(len(N)): N[i] += n[i]; U[i] += u[i]
        print(f"  {names.get(os.path.basename(d), d):30s} passes {tot:6d} under pressure {100 * flag / tot:4.1f}% | "
              + " ".join(f"{100 * u[i] / n[i]:3.0f}" if n[i] else "  -" for i in range(len(n))))
    print(f"  {'POOLED':30s} passes {sum(N):6d} under pressure {100 * sum(U) / sum(N):4.1f}% | "
          + " ".join(f"{100 * U[i] / N[i]:3.0f}" if N[i] else "  -" for i in range(len(N))))
    print("  pooled curve (permille, for fh-game-match): " + ", ".join(str(round(1000 * U[i] / N[i])) if N[i] else "0" for i in range(len(N))))
    print("  pooled passes per bin %: " + " ".join(f"{100 * N[i] / sum(N):.1f}" for i in range(len(N))))
    pt = pu = 0
    for f in glob.glob(os.path.join(sys.argv[2], "*.json")):
        if not os.path.basename(f)[0].isdigit(): continue
        for e in json.load(open(f, encoding="utf8")):
            if e["type"]["name"] != "Pass" or e["pass"].get("type", {}).get("name") in SET: continue
            pt += 1; pu += bool(e.get("under_pressure"))
    print(f"StatsBomb PL 2015/16: open-play passes {pt}, under pressure {100 * pu / pt:.2f}%")

#!/usr/bin/env python3
"""benchmarks_statsbomb_clear.py — when a pro clears, and where it goes
(game/DESIGN.md §8.106).

    python3 -I game/scripts/benchmarks_statsbomb_clear.py rates <360 cache dir>
    python3 -I game/scripts/benchmarks_statsbomb_clear.py outcomes <PL 2015/16 dir>

Data: StatsBomb Open Data, free to use with attribution to StatsBomb.

rates     foot clearances as a share of foot releases (open-play passes +
          clearances; no keepers, no headers), by zone (own box, rest of the
          own third to 35 m, midfield to 70 m, their third) and the nearest
          outfield opponent's distance in the 360 freeze frame (under 1.2 m,
          1.2-3, 3-6, 6+). Needs <id>.json events beside 360_<id>.json.
          StatsBomb flags every clearance under_pressure, so the event flag
          cannot split pressed from free; the frame can. The
          concept.clear-the-danger.rate_* rows (mig 989).
outcomes  each clearance's next on-ball event: a throw-in or corner (out), or
          who played it next, by zone, foot or head, and |y| (centre under 12 m,
          mid, wide 24+). fh-game-match prints the same as CLEARANCES BY ZONE.
FH original: the measures.
"""
import collections, glob, json, math, os, sys

SKIP = {"Ball Receipt*", "Pressure", "Duel", "Foul Committed", "Foul Won", "Substitution", "Tactical Shift",
        "Injury Stoppage", "Player Off", "Player On", "Referee Ball-Drop", "Half Start", "Half End",
        "Starting XI", "Own Goal Against", "Own Goal For", "Bad Behaviour", "Offside", "Camera On", "Camera off",
        "Dribbled Past", "Shield", "Error"}
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")


def rates(d):
    C = collections.defaultdict(collections.Counter); nmatch = 0
    for f in sorted(glob.glob(os.path.join(d, "360_*.json"))):
        evf = os.path.join(d, os.path.basename(f)[4:])
        if not os.path.exists(evf):
            continue
        nmatch += 1
        ff = {r["event_uuid"]: r["freeze_frame"] for r in json.load(open(f))}
        for e in json.load(open(evf)):
            n = e["type"]["name"]
            if n == "Pass":
                if e["pass"].get("type", {}).get("name") in SET:
                    continue
                if e["pass"].get("body_part", {}).get("name") in ("Head", "Keeper Arm", "Drop Kick", "Other"):
                    continue
                k = "pass"
            elif n == "Clearance":
                cl = e.get("clearance", {})
                if cl.get("head") or cl.get("body_part", {}).get("name") in ("Head", "Other"):
                    continue
                k = "clear"
            else:
                continue
            if e["position"]["name"] == "Goalkeeper":
                continue
            fr = ff.get(e["id"])
            if not fr:
                continue
            x, y = e["location"]
            ds = [math.hypot((p["location"][0] - x) * 105 / 120, (p["location"][1] - y) * 68 / 80)
                  for p in fr if not p["teammate"] and not p.get("keeper")]
            if not ds:
                continue
            dn = min(ds)
            b = "lt1.2" if dn < 1.2 else "1.2-3" if dn < 3 else "3-6" if dn < 6 else "6+"
            X = x * 105 / 120; Y = abs(y * 68 / 80 - 34)
            z = "box" if X < 16.5 and Y < 20.16 else "own3" if X < 35 else "mid" if X < 70 else "fin3"
            for key in ((z,), (z, b)):
                C[key]["n"] += 1; C[key][k] += 1
    nm = nmatch * 2
    print(nmatch, "matches")
    for key in sorted(C):
        c = C[key]
        print(f"{' '.join(key):12s} releases {c['n'] / nm:6.1f}/team  clear {c['clear'] / nm:4.1f} = {100 * c['clear'] / c['n']:5.1f}%")


def outcomes(d):
    ms = json.load(open(os.path.join(d, "matches.json")))
    C = collections.defaultdict(collections.Counter)
    for m in ms:
        ev = json.load(open(os.path.join(d, "events", f"{m['match_id']}.json")))
        on = [e for e in ev if e["type"]["name"] not in SKIP and "location" in e]
        for i, e in enumerate(on[:-1]):
            if e["type"]["name"] != "Clearance":
                continue
            x0 = e["location"][0] * 105 / 120; y0 = abs(e["location"][1] * 68 / 80 - 34)
            nx = on[i + 1]
            sp = nx["type"]["name"] == "Pass" and nx["pass"].get("type", {}).get("name")
            out = "throw" if sp == "Throw-in" else "corner" if sp == "Corner" else "in"
            cl = e.get("clearance", {})
            head = cl.get("head", False) or cl.get("body_part", {}).get("name") == "Head"
            zx = "box" if x0 < 16.5 and y0 < 20.16 else "own3" if x0 < 35 else "mid+"
            zy = "wide" if y0 >= 24 else "mid" if y0 >= 12 else "centre"
            kept = nx["team"]["id"] == e["team"]["id"]
            for k in (("all",), ("head" if head else "foot",), (zx,), (zy,), (zx, zy), ("head" if head else "foot", zy)):
                c = C[k]; c["n"] += 1; c[out] += 1; c["kept"] += kept
    nm = len(ms) * 2
    for k, c in sorted(C.items(), key=lambda kv: -kv[1]["n"]):
        print(f"{' '.join(k):18s} {c['n'] / nm:5.1f}/team  throw {100 * c['throw'] / c['n']:4.1f}%  "
              f"corner {100 * c['corner'] / c['n']:4.1f}%  next ours {100 * c['kept'] / c['n']:4.1f}%")


if __name__ == "__main__":
    {"rates": rates, "outcomes": outcomes}[sys.argv[1]](sys.argv[2])

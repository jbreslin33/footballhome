#!/usr/bin/env python3
"""benchmarks_statsbomb_cross.py — crosses, wide carries and blocks (game/DESIGN.md §8.107).

    python3 -I game/scripts/benchmarks_statsbomb_cross.py crosses|carries|blocks|arrive <PL 2015/16 dir>

Premier League 2015/16, 380 matches, StatsBomb Open Data (free with attribution
to StatsBomb). Pitch 120 x 80 scaled to 105 x 68; a team-match = matches x 2.

crosses  open-play passes tagged cross: a team, completion, height, the next
         on-ball event, end spot, and the cross share of passes by where struck
         (m off their goal line 0-6 / 6-18 / 18-30 / 30+ x wide 24+ / half-space
         14-24 / centre): the concept.cross.rate_* rows.
carries  carries 3 m+ from wide or the half-space within 55 m of their line:
         straight down the line (under 20 deg), out, in 20-50, in 50+, back —
         the concept.drive-the-line shares (back carries left out).
blocks   Block events (not offensive): what was blocked, the next on-ball
         event, and how far the ball turned off its line.
arrive   how the ball reaches the crossing zone (18 m off their line, |y| 14+):
         completed passes ending there, carries ending there.
FH original: the measures.
"""
import collections, json, math, os, sys


def crosses(d):
    SKIP = {"Ball Receipt*", "Pressure", "Duel", "Foul Committed", "Foul Won", "Substitution", "Tactical Shift",
            "Injury Stoppage", "Player Off", "Player On", "Referee Ball-Drop", "Half Start", "Half End",
            "Starting XI", "Own Goal Against", "Own Goal For", "Bad Behaviour", "Offside", "Camera On", "Camera off", "Dribbled Past", "Shield", "Error"}
    SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
    ms = json.load(open(os.path.join(d, "matches.json")))
    R = collections.defaultdict(collections.Counter)   # releases by origin zone
    O = collections.Counter(); H = collections.Counter(); E = collections.defaultdict(list)
    for m in ms:
        ev = json.load(open(os.path.join(d, "events", f"{m['match_id']}.json")))
        on = [e for e in ev if e["type"]["name"] not in SKIP and "location" in e]
        for i, e in enumerate(on):
            if e["type"]["name"] != "Pass" or e["pass"].get("type", {}).get("name") in SET: continue
            x = e["location"][0] * 105 / 120; y = abs(e["location"][1] * 68 / 80 - 34)
            to_line = 105 - x
            # origin zone: depth from their goal line, width from the middle
            zx = "0-6" if to_line < 6 else "6-18" if to_line < 18 else "18-30" if to_line < 30 else "30+"
            zy = "wide24+" if y >= 24 else "halfsp14-24" if y >= 14 else "centre"
            cross = bool(e["pass"].get("cross"))
            R[(zx, zy)]["n"] += 1; R[(zx, zy)]["cross"] += cross
            if not cross: continue
            O["n"] += 1
            O["ok"] += "outcome" not in e["pass"]
            H[e["pass"]["height"]["name"]] += 1
            ex = e["pass"]["end_location"][0] * 105 / 120; ey = e["pass"]["end_location"][1] * 68 / 80 - 34
            if e["location"][1] < 40: ey = -ey   # + = toward the far post (crosser on the -y side → far is +... normalise: near side negative)
            E["x"].append(105 - ex); E["y"].append(ey)
            if i + 1 < len(on):
                nx = on[i + 1]; sp = nx["type"]["name"] == "Pass" and nx["pass"].get("type", {}).get("name")
                O[{"Throw-in": "throw", "Corner": "corner", "Goal Kick": "goal_kick"}.get(sp, "in")] += 1
                if nx["type"]["name"] == "Shot" and nx["team"]["id"] == e["team"]["id"]: O["shot_next"] += 1
                if nx["type"]["name"] == "Clearance": O["clear_next"] += 1
    nm = len(ms) * 2
    print(f"crosses {O['n']/nm:.1f} a team, completed {100*O['ok']/O['n']:.0f}%; next: shot {100*O['shot_next']/O['n']:.1f}%, clearance {100*O['clear_next']/O['n']:.1f}%, corner {100*O['corner']/O['n']:.1f}%, throw {100*O['throw']/O['n']:.1f}%, goal kick {100*O['goal_kick']/O['n']:.1f}%")
    print("height:", {k: f"{100*v/O['n']:.0f}%" for k, v in H.items()})
    for zx in ("0-6", "6-18", "18-30", "30+"):
        print(f"  from {zx:5s} m off their line: " + ", ".join(f"{zy} {R[(zx,zy)]['n']/nm:.1f} rel, cross {100*R[(zx,zy)]['cross']/max(1,R[(zx,zy)]['n']):.0f}%" for zy in ("wide24+", "halfsp14-24", "centre")))
    xs = sorted(E["x"]); ys = sorted(E["y"])
    q = lambda v, f: v[int(f * len(v))]
    print(f"end: m off their line median {q(xs,.5):.1f} (q25 {q(xs,.25):.1f}, q75 {q(xs,.75):.1f}); y from centre, + = far side, median {q(ys,.5):.1f} (q25 {q(ys,.25):.1f}, q75 {q(ys,.75):.1f})")


def carries(d):
    ms = json.load(open(os.path.join(d, "matches.json")))
    C = collections.defaultdict(collections.Counter)
    for m in ms:
        for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
            if e["type"]["name"] != "Carry": continue
            x0 = e["location"][0] * 105 / 120; y0 = abs(e["location"][1] * 68 / 80 - 34)
            x1 = e["carry"]["end_location"][0] * 105 / 120; y1 = abs(e["carry"]["end_location"][1] * 68 / 80 - 34)
            L = math.hypot(x1 - x0, y1 - y0)
            if L < 3: continue
            tl = 105 - x0
            zx = "18-35" if 18 <= tl < 35 else "35-55" if 35 <= tl < 55 else None
            if tl < 18: zx = "0-18"
            if zx is None: continue
            zy = "wide24+" if y0 >= 24 else "half14-24" if y0 >= 14 else None
            if zy is None: continue
            fwd = x1 - x0; inward = y0 - y1
            ang = math.degrees(math.atan2(inward, fwd))   # 0 = straight down the line, + = inside
            b = "back" if fwd < 0 and abs(ang) > 90 else "line<20" if abs(ang) < 20 else "in20-50" if 20 <= ang < 50 else "in50+" if ang >= 50 else "out20+"
            c = C[(zx, zy)]; c["n"] += 1; c[b] += 1; c["len"] += L
    nm = len(ms) * 2
    for k in sorted(C):
        c = C[k]
        print(f"{k[0]:6s} {k[1]:10s} carries 3m+ {c['n']/nm:4.1f}/team, mean {c['len']/c['n']:.1f} m: " + ", ".join(f"{b} {100*c[b]/c['n']:.0f}%" for b in ("line<20", "out20+", "in20-50", "in50+", "back")))


def blocks(d):
    SKIP = {"Ball Receipt*", "Pressure", "Duel", "Foul Committed", "Foul Won", "Substitution", "Tactical Shift",
            "Injury Stoppage", "Player Off", "Player On", "Referee Ball-Drop", "Half Start", "Half End",
            "Starting XI", "Own Goal Against", "Own Goal For", "Bad Behaviour", "Offside", "Camera On", "Camera off", "Dribbled Past", "Shield", "Error"}
    ms = json.load(open(os.path.join(d, "matches.json")))
    C = collections.defaultdict(collections.Counter); ang = collections.defaultdict(collections.Counter)
    for m in ms:
        ev = json.load(open(os.path.join(d, "events", f"{m['match_id']}.json")))
        on = [e for e in ev if e["type"]["name"] not in SKIP and "location" in e]
        byid = {e["id"]: e for e in ev}
        for i, e in enumerate(on[:-1]):
            if e["type"]["name"] != "Block": continue
            # what was blocked: the related shot or pass
            kind = "other"; src = None
            for r in e.get("related_events", []):
                q = byid.get(r)
                if q and q["type"]["name"] in ("Shot", "Pass"): kind = q["type"]["name"].lower(); src = q
            if e.get("block", {}).get("offensive"): continue
            nx = on[i + 1]
            sp = nx["type"]["name"] == "Pass" and nx["pass"].get("type", {}).get("name")
            out = {"Throw-in": "throw", "Corner": "corner", "Goal Kick": "goal_kick"}.get(sp, "in")
            if out == "in": out = "blocker" if nx["team"]["id"] == e["team"]["id"] else "kicker"
            c = C[kind]; c["n"] += 1; c[out] += 1
            if src is not None:
                # ball direction before (src -> block) and after (block -> next), as an angle
                ax, ay = e["location"][0] - src["location"][0], e["location"][1] - src["location"][1]
                nx_loc = nx["location"]
                if nx["team"]["id"] != e["team"]["id"]: pass
                # StatsBomb flips coords to the acting team; Block is the defending team, src the attacker
                sx, sy = 120 - src["location"][0], 80 - src["location"][1]
                ax, ay = e["location"][0] - sx, e["location"][1] - sy
                ox, oy = (nx_loc[0], nx_loc[1]) if nx["team"]["id"] == e["team"]["id"] else (120 - nx_loc[0], 80 - nx_loc[1])
                bx, by = ox - e["location"][0], oy - e["location"][1]
                if math.hypot(ax, ay) > 1 and math.hypot(bx, by) > 1 and out in ("blocker", "kicker"):
                    a = math.degrees(math.acos(max(-1, min(1, (ax * bx + ay * by) / (math.hypot(ax, ay) * math.hypot(bx, by))))))
                    ang[kind]["lt45" if a < 45 else "45-90" if a < 90 else "90-135" if a < 135 else "135+"] += 1
    nm = len(ms) * 2
    for k, c in C.items():
        print(f"{k:6s} {c['n']/nm:4.1f}/team: " + ", ".join(f"{o} {100*c[o]/c['n']:.1f}%" for o in ("corner", "throw", "goal_kick", "blocker", "kicker")))
    for k, a in ang.items():
        t = sum(a.values()); print(f"{k:6s} turn from its line (in play): " + ", ".join(f"{b} {100*a[b]/t:.0f}%" for b in ("lt45", "45-90", "90-135", "135+")))


def arrive(d):
    ms = json.load(open(os.path.join(d, "matches.json")))
    C = collections.Counter(); L = collections.Counter()
    def zone(loc):
        x = loc[0] * 105 / 120; y = abs(loc[1] * 68 / 80 - 34)
        return 105 - x < 18 and y >= 14
    for m in ms:
        for e in json.load(open(os.path.join(d, "events", f"{m['match_id']}.json"))):
            n = e["type"]["name"]
            if n == "Carry":
                if zone(e["carry"]["end_location"]) and not zone(e["location"]):
                    C["carry_in"] += 1
                    L[round((e["carry"]["end_location"][0] - e["location"][0]) * 105 / 120 / 5) * 5] += 1
            elif n == "Pass" and "outcome" not in e["pass"] and e["pass"].get("type", {}).get("name") not in ("Corner", "Throw-in", "Free Kick", "Goal Kick", "Kick Off"):
                if zone(e["pass"]["end_location"]):
                    C["pass_in" if not zone(e["location"]) else "pass_within"] += 1
                    C["pass_in_from_wide" if not zone(e["location"]) and abs(e["location"][1] * 68 / 80 - 34) >= 14 else "x"] += 1
    nm = len(ms) * 2
    print({k: round(v / nm, 2) for k, v in C.items()})
    print("carry-in forward metres:", {k: round(v / nm, 2) for k, v in sorted(L.items())})


if __name__ == "__main__":
    {"crosses": crosses, "carries": carries, "blocks": blocks, "arrive": arrive}[sys.argv[1]](sys.argv[2])

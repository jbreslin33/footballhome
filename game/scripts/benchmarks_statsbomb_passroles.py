#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_passroles.py — who passes to whom, 2015/16 Premier League
(G5.139, game/DESIGN.md §8.243): open-play passes a team-match by the passer's role and the role of
the man it was for (StatsBomb `recipient`; none = no recipient, an incomplete ball to nobody), split
by where the passer stood — his own half (52.5 m+ off their line) or theirs. The harness's PASS ROLES
line is the same cut on the game's roles.

    benchmarks_statsbomb_passroles.py <events dir> [--inc]

--inc prints the table as the C initializer game/src/tools/passroles_real.inc holds.

Open play = every pass but corners, free kicks, goal kicks, kick-offs and throw-ins (as
benchmarks_statsbomb_concepts.py: Recovery / Interception passes kept). A man's role is his
StatsBomb position at his latest event (the Starting XI before his first), mapped to the game's six:
centre-backs CB; full / wing backs FB; defensive AND central midfielders DM (the game has no CM:
its 4-2-3-1 pair and 4-3-3 trio are DMs); attacking midfielders AM; wide midfielders and wingers
Wide; forwards ST. The CM fold is approximate. Pitch: StatsBomb 120 x 80, attacking toward x = 120.
Data: StatsBomb Open Data, free with attribution to StatsBomb (github.com/statsbomb/open-data).
"""
import collections, glob, json, os, sys

SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
ROLES = ("CB", "FB", "DM", "AM", "Wide", "ST", "GK")
POS = {
    "Goalkeeper": 6,
    "Right Center Back": 0, "Center Back": 0, "Left Center Back": 0,
    "Right Back": 1, "Left Back": 1, "Right Wing Back": 1, "Left Wing Back": 1,
    "Right Defensive Midfield": 2, "Center Defensive Midfield": 2, "Left Defensive Midfield": 2,
    "Right Center Midfield": 2, "Center Midfield": 2, "Left Center Midfield": 2,
    "Right Attacking Midfield": 3, "Center Attacking Midfield": 3, "Left Attacking Midfield": 3,
    "Right Midfield": 4, "Left Midfield": 4, "Right Wing": 4, "Left Wing": 4,
    "Right Center Forward": 5, "Center Forward": 5, "Left Center Forward": 5, "Secondary Striker": 5,
}

files = sorted(f for f in glob.glob(os.path.join(sys.argv[1], "*.json")) if os.path.basename(f)[:-5].isdigit())
n = collections.Counter()   # (own half, passer, receiver + 1)
unknown = 0
for f in files:
    pos = {}
    for e in json.load(open(f, encoding="utf8")):
        t = e["type"]["name"]
        if t == "Starting XI":
            for q in e["tactics"]["lineup"]:
                pos.setdefault(q["player"]["id"], q["position"]["name"])
            continue
        if "player" in e and "position" in e:
            pos[e["player"]["id"]] = e["position"]["name"]
        if t != "Pass":
            continue
        p = e["pass"]
        if p.get("type", {}).get("name") in SET:
            continue
        a = POS.get(e["position"]["name"])
        r = p.get("recipient")
        b = POS.get(pos.get(r["id"])) if r else -1
        if a is None or b is None:
            unknown += 1
            continue
        own = 1 if (120 - e["location"][0]) * 105 / 120 >= 52.5 else 0
        n[(own, a, b + 1)] += 1

tm = 2 * len(files)
if "--inc" in sys.argv:
    for h in (0, 1):
        print("    {")
        for a in range(7):
            print("        {" + ", ".join(f"{n[(h, a, b)] / tm:.2f}" for b in range(8)) + "},")
        print("    },")
    sys.exit()
print(f"{len(files)} matches (StatsBomb PL 2015/16), open-play passes; {unknown} with an unmapped position skipped")
for h in (1, 0):
    print(f"PASS ROLES, passer in {'his own' if h else 'their'} half (a team-match, passer -> receiver none/CB/FB/DM/AM/Wide/ST/GK):")
    for a in range(7):
        row = [n[(h, a, b)] / tm for b in range(8)]
        print(f"   {ROLES[a]:<4} {sum(row):5.1f} |" + "".join(f" {v:4.1f}" for v in row))

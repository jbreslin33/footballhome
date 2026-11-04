#!/usr/bin/env python3
"""game/scripts/benchmarks_statsbomb_wide.py — what a real player does when he
has the ball wide, 18-35 m off the line he attacks (G5.13, game/DESIGN.md §8.110).

§8.109: the game's ball spends 1.1 s per final-third entry in the last 18 m
(real 3.0) and gets into the crossing zone 3.5 times a team (real 21.7). This
measures the man on the ball one zone back — wide (|y| 14 m+), 18-35 m off
their line — from the 2015/16 Premier League (380 matches): where he lets it
go from (did he carry it on?), and what he lets it go as (pass to where,
cross, shot, lost).

    benchmarks_statsbomb_wide.py <events dir>

A spell = one player's consecutive events on the ball (receipt, carries,
dribbles, then the release), opponents' off-ball events (pressure, duels,
fouls) skipped. Spells that start in the zone in open play count. Zones:
StatsBomb's 120 x 80 scaled to 105 x 68; 0-18 / 18-35 / 35+ m off the line,
wide = |y| 14 m+, the same cut as match_main's POSSESSION BY ZONE.
Data: StatsBomb Open Data, free with attribution to StatsBomb.
"""
import collections, glob, json, os, sys

SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
ON_BALL = ("Ball Receipt*", "Ball Recovery", "Carry", "Dribble", "Pass", "Shot", "Dispossessed", "Miscontrol", "Clearance")
RELEASE = ("Pass", "Shot", "Dispossessed", "Miscontrol", "Clearance")
SKIP = ("Pressure", "Duel", "Foul Committed", "Dribbled Past", "Block", "Foul Won", "Shield")


def on_ball(e):
    """A failed receipt (the pass never reached him) or recovery is no spell."""
    t = e["type"]["name"]
    if t == "Ball Receipt*":
        return e.get("ball_receipt", {}).get("outcome", {}).get("name") != "Incomplete"
    if t == "Ball Recovery":
        return not e.get("ball_recovery", {}).get("recovery_failure")
    return True


def zone(loc):
    tl = (120 - loc[0]) * 105 / 120
    ay = abs(loc[1] - 40) * 68 / 80
    d = "0-18" if tl < 18 else "18-35" if tl < 35 else "35+"
    return d, "wide" if ay >= 14 else "centre"


def main():
    files = sorted(glob.glob(os.path.join(sys.argv[1], "[0-9]*.json")))
    spells = 0
    rel_from = collections.Counter()   # where he let it go from
    what = collections.Counter()       # what he let it go as
    pw = {False: collections.Counter(), True: collections.Counter()}   # by pressure on the release
    dur = 0.0
    carry_m = 0.0
    for f in files:
        ev = json.load(open(f))
        i = 0
        while i < len(ev):
            e = ev[i]
            if e["type"]["name"] not in ON_BALL or "location" not in e or "player" not in e or not on_ball(e):
                i += 1
                continue
            p, team = e["player"]["id"], e["team"]["id"]
            sp = [e]
            j = i + 1
            while j < len(ev) and sp[-1]["type"]["name"] not in RELEASE:
                x = ev[j]
                if x["type"]["name"] in SKIP and x["team"]["id"] != team:
                    j += 1
                    continue
                if x.get("player", {}).get("id") == p and x["type"]["name"] in ON_BALL and on_ball(x):
                    sp.append(x)
                    j += 1
                    if x["type"]["name"] == "Dribble" and x.get("dribble", {}).get("outcome", {}).get("name") == "Incomplete":
                        break
                    continue
                break
            i = j
            if zone(sp[0]["location"]) != ("18-35", "wide"):
                continue
            last = sp[-1]
            t = last["type"]["name"]
            if t == "Pass" and last["pass"].get("type", {}).get("name") in SET:
                continue
            if any(x["type"]["name"] == "Pass" and x["pass"].get("type", {}).get("name") in SET for x in sp):
                continue
            spells += 1
            for x in sp:
                if x["type"]["name"] == "Carry":
                    dur += x.get("duration", 0.0) or 0.0
                    a, b = x["location"], x["carry"]["end_location"]
                    carry_m += ((b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2) ** 0.5 * 105 / 120
            rel_loc = last["location"]
            if t in ("Ball Receipt*", "Ball Recovery"):
                # received and nothing after it by him: tackled before a carry
                # was logged, or a dummy — count as lost.
                what["lost"] += 1
                rel_from["%s %s" % zone(rel_loc)] += 1
                continue
            rel_from["%s %s" % zone(rel_loc)] += 1
            pr = bool(last.get("under_pressure"))
            pw[pr]["n"] += 1
            if t == "Pass" and not last["pass"].get("cross"):
                ez = zone(last["pass"]["end_location"])
                pw[pr]["back" if ez[0] == "35+" else "channel" if ez == ("0-18", "wide") else "along" if ez == ("18-35", "wide") else "inside"] += 1
            else:
                pw[pr]["cross" if t == "Pass" else "shot" if t == "Shot" else "lost" if t != "Clearance" else "clear"] += 1
            if t == "Shot":
                what["shot"] += 1
            elif t == "Pass":
                pz = last["pass"]
                if pz.get("cross"):
                    what["cross"] += 1
                else:
                    ez = zone(pz["end_location"])
                    key = "pass to %s %s" % ez
                    if ez[0] == "35+":
                        key = "pass to 35+"
                    what[key] += 1
                    if not pz.get("outcome"):
                        what["  (completed) " + key] += 1
            elif t in ("Dispossessed", "Miscontrol", "Dribble", "Carry"):
                what["lost"] += 1
            elif t == "Clearance":
                what["clearance"] += 1
    tm = 2 * len(files)
    print(f"{len(files)} matches; spells starting wide 18-35 in open play: {spells / tm:.1f} a team-match")
    print(f"  carrying: {dur / max(1, spells):.2f} s and {carry_m / max(1, spells):.1f} m a spell")
    print("  let go from:", "; ".join(f"{k} {100 * v / spells:.0f}%" for k, v in sorted(rel_from.items(), key=lambda kv: -kv[1])))
    for pr in (False, True):
        c = pw[pr]
        print(f"  {'pressed' if pr else 'not pressed'} ({100 * c['n'] / spells:.0f}% of spells):",
              "; ".join(f"{k} {100 * c[k] / c['n']:.0f}%" for k in ("channel", "along", "inside", "back", "cross", "shot", "lost")))
    print("  let go as:")
    for k, v in sorted(what.items(), key=lambda kv: (kv[0].startswith("  "), -kv[1])):
        print(f"    {k:34s} {100 * v / spells:5.1f}%  {v / tm:5.2f} a team-match")


if __name__ == "__main__":
    main()

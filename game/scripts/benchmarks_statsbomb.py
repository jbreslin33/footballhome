#!/usr/bin/env python3
"""benchmarks_statsbomb.py — pro reference numbers for the game's harness
(G4.81b, game/DESIGN.md §8.79), from StatsBomb Open Data.

    python3 -I game/scripts/benchmarks_statsbomb.py <competition_id> <season_id> [cache_dir] > out.json

Downloads the season's event files (github.com/statsbomb/open-data, ~3 MB a
match; cache_dir keeps them for a rerun, default: a temp dir, deleted), and
measures each benchmark the way fh-game-match measures the game, so a
harness line and its pro line are the same question:

  spell              a change of the team in possession (StatsBomb
                     possession ids, consecutive same-team ones merged)
  own-third loss     a spell that starts in the LOSING team's defensive
                     third (the new team's first located event at x >= 80
                     of 120 — the harness: ball < 35 m from the loser's goal)
  ... -> shot 10 s   the winners shoot within 10 s, inside that spell
  shot spell age     seconds from the spell's start to the shot
  goal-side          outfield opponents in the shot's freeze frame nearer
                     the goal line than the shooter (broadcast freeze
                     frames can miss an off-camera man: a floor, not exact)

Penalties and the shoot-out are left out; set pieces are counted, with
open-play figures alongside (the game has no set-piece shots yet).
Coordinates are StatsBomb's 120 x 80 yards, each event from its own team's
attacking direction; metres = yards x 0.9144.

Data: StatsBomb Open Data — free to use with attribution to StatsBomb
(see the repository's LICENSE / user agreement). FH original: the
measures; StatsBomb: the events.
"""
import json
import math
import os
import shutil
import sys
import tempfile
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE = "https://raw.githubusercontent.com/statsbomb/open-data/master/data"
YD = 0.9144
ON_BALL = {"Pass", "Carry", "Ball Receipt*", "Dribble", "Shot", "Miscontrol", "Dispossessed",
           "Clearance", "Ball Recovery", "Interception", "Goal Keeper", "Duel", "Shield", "Block",
           "Foul Won", "50/50"}


def fetch(url, path, tries=5):
    if not os.path.exists(path):
        for k in range(tries):   # raw.githubusercontent.com stalls now and then under load
            try:
                with urllib.request.urlopen(url, timeout=20) as r:
                    data = r.read()
                with open(path + ".part", "wb") as f:
                    f.write(data)
                os.replace(path + ".part", path)
                break
            except OSError:
                if k == tries - 1:
                    raise
    with open(path) as f:
        return json.load(f)


def t_of(e):
    h, m, s = e["timestamp"].split(":")
    return (e["period"] - 1) * 45 * 60 + int(h) * 3600 + int(m) * 60 + float(s)


def end_cause(e):
    """How a spell ended, from the losing side's last on-ball event: a pass
    that didn't reach a mate (picked off or out), a clearance, a shot, a bad
    touch, beaten on the ball (dispossessed / lost duel incl. aerial / failed
    dribble),
    or other (keeper, foul, ...)."""
    if e is None:
        return "other"
    n = e["type"]["name"]
    if n == "Pass":
        return "pass" if "outcome" in e["pass"] else "other"
    if n == "Ball Receipt*":   # the pass's failed receipt — still a lost pass
        return "pass" if "outcome" in e.get("ball_receipt", {}) else "other"
    if n == "Shot":
        return "shot"
    if n == "Clearance":
        return "clear"
    if n == "Miscontrol":
        return "bad_touch"
    if n in ("Dispossessed", "Duel", "Dribble"):
        return "on_ball"
    return "other"


def bucket(x, edges):
    for i, b in enumerate(edges):
        if x < b:
            return i
    return len(edges)


class Tally:
    def __init__(self):
        self.n = {}

    def add(self, k, v=1):
        self.n[k] = self.n.get(k, 0) + v

    def get(self, k):
        return self.n.get(k, 0)


def measure(events, T):
    ev = [e for e in events if e["period"] <= 4]
    ev.sort(key=lambda e: e["index"])
    T.add("matches")
    # spells
    spells = []   # [team, start_t, start_x(new team's own coords), end_t]
    cur = None
    for e in ev:
        pt = e["possession_team"]["id"]
        if cur is None or pt != cur[0]:
            if cur is not None:
                cur[3] = t_of(e)
            x = None
            cur = [pt, t_of(e), x, None]
            spells.append(cur)
        if cur[2] is None and e["team"]["id"] == pt and "location" in e and e["type"]["name"] in ON_BALL:
            cur[2] = e["location"][0]
    if spells and spells[-1][3] is None:
        spells[-1][3] = t_of(ev[-1])
    T.add("spells", max(0, len(spells) - 1))
    # How each spell ended (G4.82): the losing side's last on-ball event.
    last = {}
    for e in ev:
        if e["team"]["id"] == e["possession_team"]["id"] and e["type"]["name"] in ON_BALL:
            last[e["possession"]] = e
    poss_of = {}
    for e in ev:
        poss_of.setdefault(e["possession"], e["possession_team"]["id"])
    order = sorted(poss_of)
    for a, b in zip(order, order[1:]):
        if poss_of[a] == poss_of[b]:
            continue
        T.add("ends")
        T.add("end_" + end_cause(last.get(a)))
    for s in spells[1:]:
        T.add("spell_s", s[3] - s[1])
        T.add("spell_n")
    own3 = [s for s in spells[1:] if s[2] is not None and s[2] >= 80]
    T.add("own3_losses", len(own3))

    def spell_at(team, t):
        for s in spells:
            if s[0] == team and s[1] <= t <= s[3] + 1e-6:
                return s
        return None

    shots_by_spell = {}
    for e in ev:
        name = e["type"]["name"]
        team = e["team"]["id"]
        if name == "Pass":
            p = e["pass"]
            if p.get("type", {}).get("name") in (None,):   # open-play passes only
                T.add("passes")
                if "outcome" not in p:
                    T.add("passes_complete")
                    if e["location"][0] < 80 <= p["end_location"][0]:
                        T.add("final_third_entries")
                if p.get("technique", {}).get("name") == "Through Ball" or p.get("through_ball"):   # G4.96
                    T.add("through_balls")
                    if "outcome" not in p:
                        T.add("through_balls_complete")
                if p.get("height", {}).get("name") == "Ground Pass":
                    T.add("ground_passes")
                    if "outcome" not in p:
                        T.add("ground_passes_complete")
        elif name == "Carry":
            if e["location"][0] < 80 <= e["carry"]["end_location"][0]:
                T.add("final_third_entries")
        elif name == "Shot":
            sh = e["shot"]
            st = sh["type"]["name"]
            if st == "Penalty":
                continue
            T.add("shots")
            goal = sh["outcome"]["name"] == "Goal"
            if goal:
                T.add("goals")
            if st != "Open Play":
                continue
            T.add("shots_op")
            if goal:
                T.add("goals_op")
            x, y = e["location"]
            T.add("shot_dist_%d" % bucket(math.hypot(120 - x, 40 - y) * YD, (11, 18, 25)))
            ff = sh.get("freeze_frame", [])
            opp = [p for p in ff if not p["teammate"] and p.get("position", {}).get("name") != "Goalkeeper"]
            gs = sum(1 for p in opp if p["location"][0] > x)
            T.add("shot_goalside_%d" % bucket(gs, (3, 5, 7)))
            near = min((math.hypot(p["location"][0] - x, p["location"][1] - y) * YD for p in opp), default=99)
            T.add("shot_near_%d" % bucket(near, (1.5, 3, 6)))
            s = spell_at(team, t_of(e))
            if s is not None:
                T.add("shot_age_%d" % bucket(t_of(e) - s[1], (5, 10, 20)))
                if s[2] is not None:
                    T.add("shot_began_%d" % bucket((120 - s[2]) * YD, (35, 52.5, 70)))
                shots_by_spell.setdefault(id(s), []).append(t_of(e))
    for s in own3:
        ts = shots_by_spell.get(id(s), [])
        if any(t - s[1] <= 10 for t in ts):
            T.add("own3_shot10")
        if ts:
            T.add("own3_shot_spell")
    # G4.92: time on the ball — from a player's Ball Receipt to his next
    # open-play Pass in the same possession (carries in between count).
    got = {}
    for e in ev:
        n = e["type"]["name"]
        pl = e.get("player", {}).get("id")
        if pl is None:
            continue
        if n == "Ball Receipt*" and "ball_receipt" not in e:   # a clean receipt (no outcome = received)
            got[pl] = (t_of(e), e.get("possession"))
        elif n == "Pass" and e["pass"].get("type", {}).get("name") is None:
            r = got.pop(pl, None)
            if r is not None and r[1] == e.get("possession"):
                d = t_of(e) - r[0]
                if 0 <= d < 30:
                    T.add("tob_n")
                    T.add("tob_s", d)
                    T.add("tob_%d" % bucket(d, (1, 2, 4)))
        elif n not in ("Carry", "Pressure", "Duel", "Dribble", "Ball Receipt*"):
            got.pop(pl, None)
    for e in ev:
        n = e["type"]["name"]
        if n == "Own Goal Against":
            T.add("goals")
        elif n == "Interception":   # G4.82: kept = Won / Success In Play
            kept = e["interception"]["outcome"]["name"] in ("Won", "Success In Play")
            T.add("int_kept" if kept else "int_lost")
        elif n == "Miscontrol":
            T.add("miscontrol")
        elif n == "Offside":        # G4.88: an offside called off a non-pass touch
            T.add("offsides")
        elif n == "Pass" and e.get("pass", {}).get("outcome", {}).get("name") == "Pass Offside":
            T.add("offsides")       # ...and the usual one: the pass's outcome


def main():
    comp, season = sys.argv[1], sys.argv[2]
    cache = sys.argv[3] if len(sys.argv) > 3 else None
    tmp = None
    if not cache:
        tmp = cache = tempfile.mkdtemp(prefix="sb-")
    os.makedirs(cache, exist_ok=True)
    try:
        matches = fetch(f"{BASE}/matches/{comp}/{season}.json", os.path.join(cache, f"matches_{comp}_{season}.json"))
        ids = [m["match_id"] for m in matches]
        with ThreadPoolExecutor(8) as ex:
            evs = list(ex.map(lambda i: fetch(f"{BASE}/events/{i}.json", os.path.join(cache, f"{i}.json")), ids))
        T = Tally()
        for e in evs:
            measure(e, T)
    finally:
        if tmp:
            shutil.rmtree(tmp, ignore_errors=True)
    m = T.get("matches")
    tm = 2 * m
    so = max(1, T.get("shots_op"))

    def pct(k, d):
        return round(100.0 * T.get(k) / max(1, d), 1)

    c0 = matches[0]
    out = {
        "competition": c0["competition"]["competition_name"],
        "season": c0["season"]["season_name"],
        "matches": m,
        "metrics": {
            "shots_per_team_match": round(T.get("shots") / tm, 2),
            "shots_open_play_per_team_match": round(T.get("shots_op") / tm, 2),
            "goals_per_match": round(T.get("goals") / m, 2),
            "goals_open_play_per_match": round(T.get("goals_op") / m, 2),
            "open_play_passes_per_team_match": round(T.get("passes") / tm, 1),
            "open_play_pass_completion_pct": pct("passes_complete", T.get("passes")),
            "ground_pass_completion_pct": pct("ground_passes_complete", T.get("ground_passes")),
            "spells_per_match": round(T.get("spells") / m, 1),
            "spell_length_s": round(T.get("spell_s") / max(1, T.get("spell_n")), 1),
            "final_third_entries_per_team_match": round(T.get("final_third_entries") / tm, 1),
            "own_third_losses_per_team_match": round(T.get("own3_losses") / tm, 1),
            "own_third_loss_shot_10s_pct": pct("own3_shot10", T.get("own3_losses")),
            "own_third_loss_shot_spell_pct": pct("own3_shot_spell", T.get("own3_losses")),
        },
    }
    out["metrics"]["interceptions_kept_per_team_match"] = round(T.get("int_kept") / tm, 2)
    out["metrics"]["offsides_per_team_match"] = round(T.get("offsides") / tm, 2)   # G4.88
    out["metrics"]["through_balls_per_team_match"] = round(T.get("through_balls") / tm, 2)   # G4.96
    out["metrics"]["through_ball_completion_pct"] = pct("through_balls_complete", T.get("through_balls"))
    tn = max(1, T.get("tob_n"))   # G4.92: time on the ball before a pass
    out["metrics"]["time_on_ball_s"] = round(T.get("tob_s") / tn, 2)
    for i, n in enumerate(("lt1s", "1_2s", "2_4s", "4s_plus")):
        out["metrics"][f"time_on_ball_{n}_pct"] = round(100.0 * T.get(f"tob_{i}") / tn, 1)
    out["metrics"]["bad_touches_per_team_match"] = round((T.get("miscontrol") + T.get("int_lost")) / tm, 2)
    for c in ("pass", "clear", "shot", "bad_touch", "on_ball", "other"):
        out["metrics"][f"spell_end_{c}_pct"] = round(100.0 * T.get("end_" + c) / max(1, T.get("ends")), 1)
    for k, names in (("shot_age", ("lt5s", "5_10s", "10_20s", "20s_plus")),
                     ("shot_goalside", ("0_2", "3_4", "5_6", "7_plus")),
                     ("shot_dist", ("lt11m", "11_18m", "18_25m", "25m_plus")),
                     ("shot_near", ("lt1_5m", "1_5_3m", "3_6m", "6m_plus")),
                     ("shot_began", ("lt35m", "35_52m", "52_70m", "70m_plus"))):
        for i, n in enumerate(names):
            out["metrics"][f"op_{k}_{n}_pct"] = round(100.0 * T.get(f"{k}_{i}") / so, 1)
    json.dump(out, sys.stdout, indent=1)
    print()


if __name__ == "__main__":
    main()

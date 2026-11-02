#!/usr/bin/env python3
"""game/scripts/load_pl1516.py — the real 2015/16 Premier League as game teams.

James 11/2: "pro only with Actual pro teams and player abilities". Every team,
its usual shape and XI, and every ability that events can show, from the same
380 matches the pro benchmarks are measured on, so a gap between the game and
the benchmark points at the model. See game/DESIGN.md §8.102.

    load_pl1516.py <data dir> <out.sql> [--spread FILE] [--report FILE]

<data dir> holds matches.json, events/<id>.json and lineups/<id>.json from
StatsBomb Open Data (free with attribution to StatsBomb,
github.com/statsbomb/open-data). <out.sql> gets the team and player rows. It
holds player names, so it belongs in a scratch folder: names live in the DB,
never in git. Nothing here connects to a database; apply the SQL to the
scratch DB yourself. Stdin is read for the position profile only when --profile
is given (position_group<TAB>attribute<TAB>offset rows from
game_sheet_position_profile).

An ability is RANK + SPREAD:
  * rank: the player against his position group that season, from events.
    Rates are shrunk toward the group's mean, so 200 minutes can't top a list.
  * spread: where that rank lands on the 0-100 scale. CENTRE and SPREAD_SD
    below are [FH] placeholders until an FM export gives the true spread by
    position; --spread FILE overrides them (JSON {group: {attr: [pct, rating]
    pairs}}). 50 is the band exactly, so an average pro plays the pro band.

Passing is judged against the pass: a league rate by length, zone, height and
pressure, so a full-back's long diagonals aren't marked down against a holding
midfielder's five-yard balls. Attributes events can't show (pace, acceleration,
deceleration, agility, reaction, strength, communication, concentration) get
no row: unrated means the band exactly. FIFA 16 or FM fills those.
"""
import argparse, collections, json, os, statistics, sys

CENTRE = 50      # [FH] rating of the group's median player
SPREAD_SD = 12   # [FH] points per standard deviation, until an FM export
LO, HI = 20, 90
PRO_TOP_CMS = 920  # [FH] unrated pace: DESIGN §8 "pro ~9-9.5 m/s", until FIFA 16 or FM
SQUAD = 18       # 11 + 7 on the bench, by minutes
MIN_RANKED = 450 # minutes to be counted when the percentiles are built

GROUP = {
    "Goalkeeper": "GK", "Center Back": "CB", "Left Center Back": "CB", "Right Center Back": "CB",
    "Left Back": "FB", "Right Back": "FB", "Left Wing Back": "FB", "Right Wing Back": "FB",
    "Center Defensive Midfield": "DM", "Left Defensive Midfield": "DM", "Right Defensive Midfield": "DM",
    "Center Midfield": "CM", "Left Center Midfield": "CM", "Right Center Midfield": "CM",
    "Center Attacking Midfield": "AM", "Left Attacking Midfield": "AM", "Right Attacking Midfield": "AM",
    "Left Midfield": "W", "Right Midfield": "W", "Left Wing": "W", "Right Wing": "W",
    "Center Forward": "ST", "Left Center Forward": "ST", "Right Center Forward": "ST", "Secondary Striker": "ST",
}
# StatsBomb position → the FH slot labels it can fill, best first.
SLOT = {
    "Goalkeeper": ["GK"], "Center Back": ["CB"], "Left Center Back": ["CB"], "Right Center Back": ["CB"],
    "Left Back": ["LB", "LWB"], "Right Back": ["RB", "RWB"], "Left Wing Back": ["LWB", "LB"], "Right Wing Back": ["RWB", "RB"],
    "Center Defensive Midfield": ["CDM", "CM"], "Left Defensive Midfield": ["CDM", "CM"], "Right Defensive Midfield": ["CDM", "CM"],
    "Center Midfield": ["CM", "CDM", "CAM"], "Left Center Midfield": ["CM", "CDM"], "Right Center Midfield": ["CM", "CDM"],
    "Center Attacking Midfield": ["CAM", "CM", "ST"], "Left Attacking Midfield": ["CAM", "LW", "LM"], "Right Attacking Midfield": ["CAM", "RW", "RM"],
    "Left Midfield": ["LM", "LW"], "Right Midfield": ["RM", "RW"], "Left Wing": ["LW", "LM"], "Right Wing": ["RW", "RM"],
    "Center Forward": ["ST"], "Left Center Forward": ["ST"], "Right Center Forward": ["ST"], "Secondary Striker": ["ST", "CAM"],
}
# StatsBomb's shape → the nearest formation the game has.
SHAPE = {"433": "4-3-3", "4231": "4-2-3-1", "442": "4-4-2", "352": "3-5-2", "343": "3-4-3", "4141": "4-3-3",
         "451": "4-3-3", "41212": "4-4-2", "4411": "4-2-3-1", "4312": "4-4-2", "4132": "4-4-2", "3421": "3-4-3",
         "3412": "3-5-2", "3511": "3-5-2", "532": "3-5-2", "541": "3-4-3", "4222": "4-4-2", "424": "4-4-2"}
# Home kit: shirt, shorts, socks, trim (facts of the season, not from StatsBomb).
KIT = {
    "AFC Bournemouth": ("#b50e12", "#000000", "#000000", "#000000"), "Arsenal": ("#ef0107", "#ffffff", "#ffffff", "#ffffff"),
    "Aston Villa": ("#670e36", "#ffffff", "#95bfe5", "#95bfe5"), "Chelsea": ("#034694", "#034694", "#ffffff", "#ffffff"),
    "Crystal Palace": ("#1b458f", "#1b458f", "#1b458f", "#c4122e"), "Everton": ("#003399", "#ffffff", "#ffffff", "#ffffff"),
    "Leicester City": ("#003090", "#003090", "#003090", "#fdbe11"), "Liverpool": ("#c8102e", "#c8102e", "#c8102e", "#ffffff"),
    "Manchester City": ("#6cabdd", "#ffffff", "#6cabdd", "#ffffff"), "Manchester United": ("#da291c", "#ffffff", "#000000", "#000000"),
    "Newcastle United": ("#241f20", "#000000", "#000000", "#ffffff"), "Norwich City": ("#fff200", "#00a650", "#fff200", "#00a650"),
    "Southampton": ("#d71920", "#000000", "#000000", "#ffffff"), "Stoke City": ("#e03a3e", "#ffffff", "#ffffff", "#ffffff"),
    "Sunderland": ("#eb172b", "#000000", "#000000", "#ffffff"), "Swansea City": ("#ffffff", "#ffffff", "#ffffff", "#000000"),
    "Tottenham Hotspur": ("#ffffff", "#132257", "#ffffff", "#132257"), "Watford": ("#fbee23", "#000000", "#000000", "#ed2127"),
    "West Bromwich Albion": ("#122f67", "#ffffff", "#ffffff", "#ffffff"), "West Ham United": ("#7a263a", "#ffffff", "#ffffff", "#1bb1e7"),
}


def minute(e):
    return e["minute"] + e["second"] / 60


def appearances(events, lineups, match_end):
    """{player_id: {pos: minutes}} for one match, from the lineup's position spells."""
    out = {}
    for side in lineups:
        for p in side["lineup"]:
            spells = collections.Counter()
            for s in p.get("positions", []):
                a = clock(s.get("from"))
                b = clock(s.get("to")) if s.get("to") else match_end
                spells[s["position"]] += max(0, b - a)
            if spells:
                out[p["player_id"]] = (side["team_name"], spells, p)
    return out


def clock(t):
    if not t:
        return 0
    m, s = t.split(":")[:2]
    return int(m) + int(s) / 60


class Tally:
    """One player's raw counts for the season."""

    def __init__(self):
        self.c = collections.Counter()
        self.pos = collections.Counter()
        self.team_min = collections.Counter()
        self.name = ""
        self.shirts = collections.Counter()
        self.starts = collections.Counter()   # (team, position) → starts


def pass_bin(e):
    p = e["pass"]
    length = p.get("length", 0)
    lb = 0 if length < 10 else 1 if length < 20 else 2 if length < 35 else 3
    zone = int(min(e["location"][0], 119.9) // 40)
    h = p.get("height", {}).get("name", "Ground Pass")
    return lb, zone, h, bool(e.get("under_pressure"))


def open_play(e):
    return e["pass"].get("type", {}).get("name") not in ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")


def load(data):
    matches = json.load(open(os.path.join(data, "matches.json")))
    players = collections.defaultdict(Tally)
    shapes = collections.defaultdict(collections.Counter)
    table = collections.defaultdict(lambda: [0, 0, 0])     # team: points, gf, ga
    games = []
    for m in matches:
        i = m["match_id"]
        ev = json.load(open(os.path.join(data, "events", f"{i}.json")))
        ln = json.load(open(os.path.join(data, "lineups", f"{i}.json")))
        games.append(ev)
        h, a = m["home_team"]["home_team_name"], m["away_team"]["away_team_name"]
        hs, ss = m["home_score"], m["away_score"]
        table[h][0] += 3 if hs > ss else 1 if hs == ss else 0
        table[a][0] += 3 if ss > hs else 1 if hs == ss else 0
        table[h][1] += hs; table[h][2] += ss; table[a][1] += ss; table[a][2] += hs
        end = max(minute(e) for e in ev)
        for pid, (team, spells, p) in appearances(ev, ln, end).items():
            t = players[pid]
            t.name = p.get("player_nickname") or p["player_name"]
            t.shirts[(team, p.get("jersey_number"))] += 1
            for pos, mins in spells.items():
                t.pos[pos] += mins
                t.team_min[team] += mins
                t.c["minutes"] += mins
        for e in ev:
            if e["type"]["name"] == "Starting XI":
                team = e["team"]["name"]
                shapes[team][str(e["tactics"]["formation"])] += 1
                for x in e["tactics"]["lineup"]:
                    players[x["player"]["id"]].starts[(team, x["position"]["name"])] += 1
    # League pass rates by difficulty, then each passer against them.
    rate = collections.defaultdict(lambda: [0, 0])
    for ev in games:
        for e in ev:
            if e["type"]["name"] == "Pass" and open_play(e) and "location" in e:
                r = rate[pass_bin(e)]
                r[0] += 1
                r[1] += "outcome" not in e["pass"]
    for ev in games:
        by_id = {e["id"]: e for e in ev}
        for e in ev:
            n = e["type"]["name"]
            if "player" not in e:
                continue
            c = players[e["player"]["id"]].c
            if n == "Pass":
                if e["pass"].get("aerial_won"):
                    c["aerial_won"] += 1
                if open_play(e) and "location" in e:
                    b = pass_bin(e)
                    exp = rate[b][1] / rate[b][0]
                    ok = "outcome" not in e["pass"]
                    c["pass_n"] += 1
                    c["pass_over"] += ok - exp
                    if b[3]:
                        c["press_n"] += 1
                        c["press_over"] += ok - exp
            elif n == "Ball Receipt*":
                c["receipts"] += 1
                c["bad_touch"] += "ball_receipt" in e and e["ball_receipt"].get("outcome", {}).get("name") == "Incomplete"
            elif n in ("Miscontrol", "Dispossessed"):
                c["bad_touch"] += 1
                if n == "Miscontrol" and e.get("miscontrol", {}).get("aerial_won"):
                    c["aerial_won"] += 1
            elif n == "Duel":
                t = e["duel"]["type"]["name"]
                if t == "Aerial Lost":
                    c["aerial_lost"] += 1
                elif t == "Tackle":
                    c["tackle_n"] += 1
                    c["tackle_won"] += e["duel"].get("outcome", {}).get("name") in ("Won", "Success", "Success In Play", "Success Out")
            elif n == "Dribbled Past":
                c["tackle_n"] += 1
            elif n == "Dribble":
                c["drib_n"] += 1
                c["drib_ok"] += e["dribble"].get("outcome", {}).get("name") == "Complete"
            elif n in ("Interception", "Block"):
                c["reads"] += 1
            elif n == "Ball Recovery":
                c["reads"] += not e.get("ball_recovery", {}).get("recovery_failure")
            elif n == "Clearance":
                if e["clearance"].get("aerial_won"):
                    c["aerial_won"] += 1
            elif n == "Shot":
                s = e["shot"]
                if s.get("aerial_won"):
                    c["aerial_won"] += 1
                if s["type"]["name"] == "Penalty":
                    continue
                o = s["outcome"]["name"]
                if s["body_part"]["name"] != "Head":
                    c["shot_n"] += 1
                    c["shot_on"] += o in ("Goal", "Saved", "Saved To Post")
                    c["shot_over"] += (o == "Goal") - s["statsbomb_xg"]
                for rid in e.get("related_events", []):
                    g = by_id.get(rid)
                    if g and g["type"]["name"] == "Goal Keeper" and "player" in g and \
                       g["goalkeeper"]["type"]["name"] in ("Shot Saved", "Goal Conceded", "Penalty Saved", "Shot Faced"):
                        k = players[g["player"]["id"]].c
                        k["faced"] += 1
                        k["saved_over"] += s["statsbomb_xg"] - (o == "Goal")
                        break
    return players, shapes, table


def metrics(t):
    """attribute → (numerator, denominator, prior weight), bigger = better."""
    c, mins = t.c, t.c["minutes"]
    return {
        "passing": (c["pass_over"], c["pass_n"], 150),
        "decisions": (c["press_over"], c["press_n"], 60),
        "first_touch": (-c["bad_touch"], c["receipts"], 200),
        "tackling": (c["tackle_won"], c["tackle_n"], 30),
        "dribbling": (c["drib_ok"], c["drib_n"], 30),
        "anticipation": (c["reads"], mins / 90, 10),
        "shooting": (c["shot_over"] + 0.5 * c["shot_on"], c["shot_n"], 40),
        "goalkeeping": (c["saved_over"], c["faced"], 40),
        "jumping_reach": (c["aerial_won"], c["aerial_won"] + c["aerial_lost"], 30),
    }


def inv(pct):
    return statistics.NormalDist().inv_cdf(min(0.995, max(0.005, pct)))


def rate(players, profile, spread):
    """{pid: {attr: rating}} by rank inside each position group."""
    group = {pid: GROUP[t.pos.most_common(1)[0][0]] for pid, t in players.items() if t.pos}
    out = collections.defaultdict(dict)
    attrs = metrics(next(iter(players.values())))
    for g in sorted(set(group.values())):
        ids = [p for p in group if group[p] == g]
        for a in attrs:
            if (a == "goalkeeping") != (g == "GK"):
                continue
            if g == "GK" and a not in ("goalkeeping", "passing"):
                continue
            pool = [metrics(players[p])[a] for p in ids]
            n = sum(x[1] for x in pool)
            mean = sum(x[0] for x in pool) / n if n else 0
            val = {p: (x[0] + mean * x[2]) / (x[1] + x[2]) for p, x in zip(ids, pool)}
            ranked = sorted(val[p] for p in ids if players[p].c["minutes"] >= MIN_RANKED) or sorted(val.values())
            for p in ids:
                below = sum(v < val[p] for v in ranked) + 0.5 * sum(v == val[p] for v in ranked)
                pct = (below + 0.5) / (len(ranked) + 1)
                if spread and a in spread.get(g, {}):
                    r = interp(spread[g][a], pct)
                else:
                    r = CENTRE + profile.get((g, a), 0) + SPREAD_SD * inv(pct)
                out[p][a] = int(round(max(LO, min(HI, r))))
    return out, group


def interp(pairs, pct):
    pairs = sorted(pairs)
    for (a, ra), (b, rb) in zip(pairs, pairs[1:]):
        if a <= pct <= b:
            return ra + (rb - ra) * (pct - a) / (b - a) if b > a else ra
    return pairs[0][1] if pct < pairs[0][0] else pairs[-1][1]


def pick_xi(team, ids, players, labels):
    """Greedy fill of the formation's slots by season starts at that label."""
    score = {}
    for p in ids:
        for (tm, pos), n in players[p].starts.items():
            if tm != team:
                continue
            for rank, lab in enumerate(SLOT[pos]):
                score[(p, lab)] = score.get((p, lab), 0) + n * (1 if rank == 0 else 0.4)
    taken, xi = set(), {}
    while len(xi) < len(labels):
        best = None
        for slot, lab in labels.items():
            if slot in xi:
                continue
            for p in ids:
                if p in taken:
                    continue
                s = score.get((p, lab), 0) + players[p].team_min[team] * 1e-4
                if best is None or s > best[0]:
                    best = (s, slot, p)
        xi[best[1]] = best[2]
        taken.add(best[2])
    return xi


def q(v):
    return "NULL" if v is None else "'" + str(v).replace("'", "''") + "'"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("data")
    ap.add_argument("out")
    ap.add_argument("--profile", help="TSV position_group, attribute, offset")
    ap.add_argument("--formations", required=True, help="JSON {code: {slot: label}}")
    ap.add_argument("--spread")
    ap.add_argument("--game-model", default="Curriculum")
    ap.add_argument("--report")
    a = ap.parse_args()
    profile = {}
    if a.profile:
        for l in open(a.profile):
            g, at, off = l.rstrip("\n").split("\t")
            profile[(g, at)] = float(off)
    spread = json.load(open(a.spread)) if a.spread else None
    forms = {k: {int(s): v for s, v in f.items()} for k, f in json.load(open(a.formations)).items()}
    players, shapes, table = load(a.data)
    ratings, group = rate(players, profile, spread)
    squads = collections.defaultdict(list)
    for pid, t in players.items():
        if t.team_min:
            squads[t.team_min.most_common(1)[0][0]].append(pid)
    teams = sorted(table)
    sql = ["BEGIN;", "DELETE FROM game_demo_teams WHERE level_band = 'pro' AND name IN (" + ",".join(q(t) for t in teams) + ");"]
    report = {}
    for team in teams:
        shape = next(SHAPE[s] for s, _ in shapes[team].most_common() if SHAPE.get(s) in forms)
        labels = forms[shape]
        ids = sorted(squads[team], key=lambda p: -players[p].team_min[team])
        xi = pick_xi(team, ids, players, labels)
        bench = [p for p in ids if p not in xi.values()][: SQUAD - 11]
        kit = KIT[team]
        sql.append("INSERT INTO game_demo_teams (name, level_band, game_model, formation_code, kit_shirt, kit_shorts, kit_socks, kit_trim) "
                   f"VALUES ({q(team)}, 'pro', {q(a.game_model)}, {q(shape)}, {q(kit[0])}, {q(kit[1])}, {q(kit[2])}, {q(kit[3])});")
        tid = f"(SELECT id FROM game_demo_teams WHERE name = {q(team)})"
        used = set()
        rows = [(slot, xi[slot], labels[slot]) for slot in sorted(xi)] + [(None, p, "SUB") for p in bench]
        report[team] = {"shape": shape, "points": table[team][0], "xi": []}
        for slot, pid, label in rows:
            t = players[pid]
            shirt = next((n for (tm, n), _ in t.shirts.most_common() if tm == team and n not in used), None)
            if shirt is None:
                shirt = next(n for n in range(60, 99) if n not in used)
            used.add(shirt)
            tier = "starter" if slot else "bench"
            sql.append("INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, position, lineup_slot, lineup_tier) "
                       f"VALUES ({tid}, {shirt}, {q(t.name)}, {PRO_TOP_CMS}, {q(label)}, {'NULL' if slot is None else slot}, {q(tier)});")
            for at, r in ratings[pid].items():
                sql.append("INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating, source) "
                           f"VALUES ({tid}, {shirt}, {q(at)}, {r}, 'derived');")
            if slot:
                report[team]["xi"].append({"slot": slot, "label": label, "group": group.get(pid), "min": round(t.c["minutes"]),
                                           "name": t.name, "r": ratings[pid]})
    sql.append("COMMIT;")
    open(a.out, "w").write("\n".join(sql) + "\n")
    if a.report:
        json.dump(report, open(a.report, "w"), indent=1)
    print(f"{len(teams)} teams, {sum(len(x) for x in squads.values())} players seen, {len(sql)} statements", file=sys.stderr)


if __name__ == "__main__":
    main()

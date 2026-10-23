#!/usr/bin/env python3
"""game/scripts/load_squads.py — the game's two squads from this season's
record and the real rosters (G4.40, mig 656). Re-run any time; it rewrites
the records, both squads' qualities and attributes, and the Ukies' roster.

James: "use this years record and roster … its all on apsl website" /
"for lh anyone on a roster gets scores" / "for other teams need to be on
real roster" / "use previous and future lineups to gauge skill level at
certain things based on position … for lh as that is all we know … then i
and u can edit over time" / "physical tools like speed and size and height
etc are very sim for amateur semi and pro. its the skill level that differs
and tactical concept awareness and implementation".

Sources:
  * APSL: the TeamPass Jumbotron feed (league 3841, Delaware River = 817)
    and the Ukies' APSL team page (active roster, goals) — fetched through
    the club's scraper proxy (footballhome_scraper:3128) from the backend
    container, the same path LeagueFixtureSync uses.
  * CASA Liga 1: league_fixtures (source 1), already synced by the backend.
  * Lighthouse rosters + lineups: team_persons (teams 35 APSL, 938 APSL
    Reserves, 120 Liga 1) and match_lineups (past and planned matches).

Rules (edit here, re-run):
  * Team quality = its table position inside its division's span
    (game_division_quality / view game_team_strength).
  * Lighthouse player SKILL by lineup tier (James: "starting apsl lineup …
    higher abilities. then bench then liga 1 guys and bench liga 1"):
      APSL starter  = APSL quality + 4 x his start share   (60-64)
      APSL bench    = APSL quality                        (60)
      Liga 1 starter = Liga 1 quality + 4 x start share    (52-56)
      Liga 1 bench  = Liga 1 quality                      (52)
      no lineup yet = his roster tier's quality - 2
  * Age (James: "younger players are gonna be talented but dumb and will be
    more skilled later"): the MENTAL side — anticipation, decisions and
    concept awareness (game_demo_players.quality) — moves 0.8 a year from
    age 25 (capped +-5); pace drops 1.5 a year past 30; potential = room to
    grow: +2 a year under 24 (+4), +2 at 24-27.
  * Skills and mental attributes = quality + his position profile (weighted
    by where he has lined up). PHYSICAL (pace) does NOT follow quality —
    same baseline at every level, shaped only by position.
  * APSL goals add to shooting (+2 a goal, at most +6).
  * Hand edits win: an attribute marked source='edited' (the in-game editor,
    James, Claude — mig 657) is never overwritten. (The Ukies' squad is
    rebuilt from their APSL roster, so edit theirs after their lineups are
    known.)
Names go straight into the club DB, never into git.
"""
import json, re, html, subprocess, sys, collections

PSQL = ["sudo", "-n", "podman", "exec", "-i", "footballhome_db", "psql", "-v", "ON_ERROR_STOP=1",
        "-U", "footballhome_user", "-d", "footballhome"]
SEASON = "2026/27"
LH_APSL, LH_RESERVES, LH_LIGA1 = 35, 938, 120
UKIES_APSL_TEAM = 168338
APSL_LEAGUE, APSL_DIV = 3841, 817
PACE_BASE = 60            # physical baseline, the same at every level
GK_SKILL_NON_KEEPER = 25  # outfielders' goalkeeping

# Position profile: attribute offsets from quality (pace: from PACE_BASE).
PROFILE = {
    "GK":  {"goalkeeping": 10, "pace": -6, "shooting": -15, "tackling": -10, "first_touch": -4, "passing": -2},
    "CB":  {"tackling": 6, "anticipation": 4, "pace": -2, "shooting": -6, "first_touch": -2, "passing": -1},
    "FB":  {"pace": 5, "tackling": 2, "shooting": -4, "passing": 1},
    "DM":  {"passing": 4, "decisions": 4, "tackling": 3, "anticipation": 2, "shooting": -3},
    "CM":  {"passing": 3, "first_touch": 2, "decisions": 2},
    "AM":  {"first_touch": 4, "passing": 3, "decisions": 2, "shooting": 2, "tackling": -4},
    "W":   {"pace": 6, "first_touch": 3, "shooting": 1, "tackling": -4},
    "ST":  {"shooting": 6, "first_touch": 3, "pace": 3, "tackling": -6, "passing": -1},
}
ABBR_GROUP = {"GK": "GK", "CB": "CB", "SW": "CB", "RB": "FB", "LB": "FB", "WB": "FB", "LWB": "FB", "RWB": "FB",
              "CDM": "DM", "CM": "CM", "RM": "W", "LM": "W", "CAM": "AM", "RW": "W", "LW": "W", "ST": "ST", "FW": "ST"}
ATTRS = ["pace", "passing", "shooting", "first_touch", "tackling", "anticipation", "decisions", "goalkeeping"]


def sql(query):
    r = subprocess.run(PSQL + ["-tA", "-F", "\t", "-c", query], capture_output=True, text=True, check=True, stdin=subprocess.DEVNULL)
    return [l.split("\t") for l in r.stdout.splitlines() if l]


def run_sql(script):
    subprocess.run(PSQL + ["--single-transaction", "-q"], input=script, text=True, check=True)


def q(v):
    return "NULL" if v is None else "'" + str(v).replace("'", "''") + "'"


def fetch(url, accept="text/html"):
    cmd = ["sudo", "-n", "podman", "exec", "footballhome_backend", "curl", "-s", "-m", "60", "-L",
           "-x", "http://footballhome_scraper:3128", "-A", "Mozilla/5.0 (X11; Linux x86_64)", "-H", "Accept: " + accept, url]
    return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout


# ── records ─────────────────────────────────────────────────────────────
def apsl_records(feed):
    teams = feed["teams"]
    tab = collections.defaultdict(lambda: [0] * 6)
    for g in feed["games"]:
        if g.get("d") != APSL_DIV or g.get("st") != 1:
            continue
        for me, gf, ga in ((g["t1"], g["s1"], g["s2"]), (g["t2"], g["s2"], g["s1"])):
            r = tab[teams[str(me)]["name"]]
            r[0] += 1; r[1] += gf > ga; r[2] += gf == ga; r[3] += gf < ga; r[4] += gf; r[5] += ga
    return {k: v for k, v in tab.items()}


def liga1_records():
    rows = sql("""SELECT t, count(*), sum((gf>ga)::int), sum((gf=ga)::int), sum((gf<ga)::int), sum(gf), sum(ga) FROM (
        SELECT home_name t, home_score gf, away_score ga FROM league_fixtures WHERE source_id = 1 AND removed_at IS NULL AND home_score IS NOT NULL AND starts_at < now() AND division_label = 'Liga 1'
        UNION ALL SELECT away_name, away_score, home_score FROM league_fixtures WHERE source_id = 1 AND removed_at IS NULL AND home_score IS NOT NULL AND starts_at < now() AND division_label = 'Liga 1') g GROUP BY t""")
    return {r[0]: [int(x) for x in r[1:]] for r in rows}


def roster_from_page(page):
    m = re.search(r"Active\s+Roster\s*\((\d+)\s+Players\)\s*</h2>\s*(<table.*?</table>)", page, re.S)
    out = []
    for row in re.findall(r"<tr class=\"TableRow\d\">(.*?)</tr>", m.group(2), re.S):
        name = re.search(r'class="tp1205-fade">\s*(.*?)\s*</div>', row, re.S)
        tds = re.findall(r"<td[^>]*>(.*?)</td>", row, re.S)
        num = lambda s: int(s) if re.fullmatch(r"\s*\d+\s*", s) else 0
        out.append({"name": html.unescape(re.sub(r"\s+", " ", name.group(1))).strip(), "goals": num(tds[-2])})
    assert len(out) == int(m.group(1)), "roster count mismatch"
    return out


def age_mods(age):
    """(mental offset, pace offset, potential gain) for an age in years."""
    if age is None:
        return 0, 0, 0
    mental = max(-5, min(5, round(0.8 * (age - 25))))
    pace = -round(1.5 * (age - 30)) if age > 30 else 0
    grow = 4 + 2 * (24 - age) if age < 24 else (2 if age <= 27 else 0)
    return mental, pace, grow


def attributes(quality, groups, goals, mental=0, pace_age=0):
    """quality → the eight attributes, shaped by the position mix and age."""
    a = {k: quality for k in ATTRS}
    a["pace"] = PACE_BASE + pace_age
    a["anticipation"] += mental
    a["decisions"] += mental
    a["goalkeeping"] = GK_SKILL_NON_KEEPER
    total = sum(groups.values()) or 1
    for g, n in groups.items():
        for k, off in PROFILE[g].items():
            a[k] += off * n / total
    if groups.get("GK", 0) * 2 >= total:          # mostly a keeper
        a["goalkeeping"] = quality + PROFILE["GK"]["goalkeeping"]
    a["shooting"] += min(6, 2 * goals)
    return {k: max(0, min(100, round(v))) for k, v in a.items()}


def main():
    feed = json.loads(fetch(f"https://alta.teampass.com/App/Jumbotron/data/{APSL_LEAGUE}?format=2A", "application/json"))
    ukies_page = fetch(f"https://app.teampass.com/APSL/Team/{UKIES_APSL_TEAM}")
    lh_page = fetch("https://app.teampass.com/APSL/Team/165430")
    apsl, liga1 = apsl_records(feed), liga1_records()

    s = ["DELETE FROM game_team_records WHERE season = %s;" % q(SEASON)]
    for div, recs, src in (("APSL Delaware River", apsl, "TeamPass Jumbotron 3841/817"), ("CASA Liga 1", liga1, "league_fixtures source 1")):
        for team, r in recs.items():
            s.append("INSERT INTO game_team_records (team_label, division, season, played, wins, draws, losses, goals_for, goals_against, source) VALUES (%s, %s, %s, %d, %d, %d, %d, %d, %d, %s);"
                     % (q(team), q(div), q(SEASON), *r, q(src)))
    run_sql("\n".join(s))
    strength = {(r[0], r[1]): int(r[2]) for r in sql("SELECT team_label, division, quality FROM game_team_strength WHERE season = %s" % q(SEASON))}
    q_lh_apsl = strength[("Lighthouse 1893 SC", "APSL Delaware River")]
    q_lh_liga1 = strength[("Lighthouse Mens Club 1893", "CASA Liga 1")]
    q_ukies = strength[("Philadelphia Ukrainian Nationals", "APSL Delaware River")]

    # ── Lighthouse: everyone on a men's roster ──
    roster = sql(f"""SELECT tp.person_id, max(CASE WHEN tp.team_id IN ({LH_APSL}) THEN 2 ELSE 1 END),
                            min(p.first_name || ' ' || p.last_name),
                            COALESCE(min(extract(year FROM age(p.birth_date)))::text, '')
                       FROM team_persons tp JOIN persons p ON p.id = tp.person_id
                       LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
                      WHERE tp.team_id IN ({LH_APSL}, {LH_RESERVES}, {LH_LIGA1}) AND tp.removed_at IS NULL
                        AND (rs.counts_as_on_roster OR rs.code = 'needs_docs')
                      GROUP BY tp.person_id""")
    lineups = collections.defaultdict(lambda: {"groups": collections.Counter(), "apsl": [0, 0], "liga": [0, 0]})
    for pid, abbr, starter, team in sql(f"""SELECT pl.person_id, pos.abbreviation, l.is_starter, m.home_team_id FROM match_lineups l
                                        JOIN matches m ON m.id = l.match_id JOIN players pl ON pl.id = l.player_id
                                        LEFT JOIN positions pos ON pos.id = l.position_id
                                       WHERE m.home_team_id IN ({LH_APSL}, {LH_RESERVES}, {LH_LIGA1})"""):
        rec = lineups[pid]
        tier = rec["apsl"] if int(team) == LH_APSL else rec["liga"]   # [apps, starts]
        tier[0] += 1
        tier[1] += starter == "t"
        if abbr in ABBR_GROUP:
            rec["groups"][ABBR_GROUP[abbr]] += 1
    lh_goals = {x["name"].split()[-1].lower(): x["goals"] for x in roster_from_page(lh_page)}
    lh_team = sql("SELECT id FROM game_demo_teams WHERE name = 'Lighthouse APSL'")[0][0]
    have = {r[0]: (int(r[1]), r[2]) for r in sql(f"SELECT person_id, shirt, COALESCE(position, '') FROM game_demo_players WHERE team_id = {lh_team} AND person_id IS NOT NULL")}
    next_shirt = int(sql(f"SELECT COALESCE(max(shirt), 0) FROM game_demo_players WHERE team_id = {lh_team}")[0][0]) + 1
    s = [f"UPDATE game_demo_teams SET quality = {q_lh_apsl} WHERE id = {lh_team};"]
    in_squad = []
    for pid, tier, name, age in roster:
        rec = lineups.get(pid)
        if rec and rec["apsl"][0]:
            base = q_lh_apsl + round(4 * rec["apsl"][1] / rec["apsl"][0])
        elif rec and rec["liga"][0]:
            base = q_lh_liga1 + round(4 * rec["liga"][1] / rec["liga"][0])
        else:
            base = (q_lh_apsl if tier == "2" else q_lh_liga1) - 2
        mental, pace_age, grow = age_mods(int(age) if age else None)
        aware = base + mental                       # concept awareness
        potential = min(100, base + grow)
        groups = rec["groups"] if rec else collections.Counter()
        if pid in have and not groups and have[pid][1] in ABBR_GROUP:
            groups = collections.Counter({ABBR_GROUP[have[pid][1]]: 1})
        goals = lh_goals.get(name.split()[-1].lower(), 0)
        attrs = attributes(base, groups, goals, mental, pace_age)
        if pid in have:
            shirt = have[pid][0]
            s.append(f"UPDATE game_demo_players SET quality = {aware}, potential = {potential} WHERE team_id = {lh_team} AND shirt = {shirt};")
        else:
            shirt = next_shirt; next_shirt += 1
            pos = groups.most_common(1)[0][0] if groups else ""
            label = {"GK": "GK", "CB": "CB", "FB": "RB", "DM": "CDM", "CM": "CM", "AM": "CAM", "W": "RW", "ST": "ST"}.get(pos, "SUB")
            s.append(f"INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, person_id, position, quality, potential) VALUES ({lh_team}, {shirt}, {q(name)}, 640, {pid}, {q(label)}, {aware}, {potential});")
        in_squad.append(shirt)
        s.extend(f"INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating, source) VALUES ({lh_team}, {shirt}, {q(k)}, {v}, 'derived') "
                 f"ON CONFLICT (team_id, shirt, attribute) DO UPDATE SET rating = EXCLUDED.rating WHERE game_demo_player_attributes.source = 'derived';" for k, v in attrs.items())
    run_sql("\n".join(s))

    # ── Ukrainian Nationals: the real APSL roster only ──
    uk = roster_from_page(ukies_page)
    uk_team = sql("SELECT id FROM game_demo_teams WHERE name = 'Ukrainian Nationals'")[0][0]
    slots = [r[0] for r in sql("SELECT e->>'label' FROM formations f, jsonb_array_elements(f.positions_json) e WHERE f.code = '4-2-3-1' ORDER BY (e->>'slot')::int")]
    # No public lineups for them: scorers up front, the rest in roster order.
    order = sorted(range(len(uk)), key=lambda i: -uk[i]["goals"])
    attack = [i for i in order if uk[i]["goals"] > 0][:4]
    rest = [i for i in range(len(uk)) if i not in attack]
    lineup = {}
    for slot_idx, label in enumerate(slots, start=1):
        pool = attack if label in ("ST", "CAM", "RW", "LW") and attack else rest
        lineup[pool.pop(0)] = (slot_idx, label)
    s = [f"DELETE FROM game_demo_player_concepts WHERE team_id = {uk_team};",
         f"DELETE FROM game_demo_players WHERE team_id = {uk_team};",
         f"UPDATE game_demo_teams SET quality = {q_ukies} WHERE id = {uk_team};"]
    for i, p in enumerate(uk):
        slot, label = lineup.get(i, (None, "SUB"))
        groups = collections.Counter({ABBR_GROUP[label]: 1}) if label in ABBR_GROUP else collections.Counter()
        attrs = attributes(q_ukies, groups, p["goals"])
        shirt = i + 1
        s.append(f"INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, position, lineup_slot, quality, description) VALUES "
                 f"({uk_team}, {shirt}, {q(p['name'])}, 640, {q(label)}, {slot if slot else 'NULL'}, {q_ukies}, 'APSL roster; position a guess until their lineups are known');")
        s.extend(f"INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating, source) VALUES ({uk_team}, {shirt}, {q(k)}, {v}, 'derived');" for k, v in attrs.items())
    run_sql("\n".join(s))
    print(f"qualities: Lighthouse APSL {q_lh_apsl}, Lighthouse Liga 1 {q_lh_liga1}, Ukies {q_ukies}")
    print(f"Lighthouse squad {len(in_squad)} (rostered), Ukies squad {len(uk)} (APSL roster)")


if __name__ == "__main__":
    main()

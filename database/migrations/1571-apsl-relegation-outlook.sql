-- 1571 (2026-11-19) — 📉 #apsl Forecast: the relegation outlook, three
-- seasons, and the CASA feeder's strength.
--
-- Owner 2026-11-19: "for the apsl predictions page do a section on the
-- amount of teams getting relegated. 3.5 of 16 this year. and 3.5 of 14
-- next year. then year after back to "normal" apsl rules 1.5 of 12 for our
-- conference … show percentage of teams getting relegated each year. show
-- strength of teams from casa" + "or show chances of getting promoted from
-- feeders in delaware river conf" + "1.5 promotion spots each year" +
-- "we might get relegated then go to liga 1 during really hard year … so
-- hopefully we get promoted during that blood bath and come back up in
-- calmer waters with 1.5 of 12 relegations".
--
-- pyramid_relegation_outlook: per conference per season, how many teams and
-- how many go down / come up (the .5 = the group-playoff winner v the feeder
-- side: one of the two plays in the conference next year).
-- pyramid_feeder_sources: which stored league table feeds a conference
-- (league_fixtures: source + division), how many of its top places go up
-- outright and how many play the conference's survivor.  The model rates
-- those teams from their own games (1.00 = that league's average — no game
-- links the two leagues, so the scales are not comparable) and plays out the
-- rest of their listed games.
-- pyramid_forecast_policies.our_name_pattern: our side in that conference
-- and its feeder (the "our road" box).
BEGIN;

CREATE TABLE IF NOT EXISTS pyramid_relegation_outlook (
    id              serial PRIMARY KEY,
    competition_id  integer NOT NULL REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    season          text NOT NULL,
    sort_order      integer NOT NULL DEFAULT 0,
    teams           integer NOT NULL CHECK (teams > 0),
    relegated       numeric NOT NULL CHECK (relegated >= 0),
    promoted        numeric NOT NULL CHECK (promoted >= 0),
    rules_label     text,
    note            text,
    UNIQUE (competition_id, season)
);

CREATE TABLE IF NOT EXISTS pyramid_feeder_sources (
    id                 serial PRIMARY KEY,
    competition_id     integer NOT NULL REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    fixture_source_id  integer NOT NULL REFERENCES league_fixture_sources(id) ON DELETE CASCADE,
    division_label     text NOT NULL,
    label              text NOT NULL,
    auto_places        integer NOT NULL DEFAULT 1 CHECK (auto_places >= 0),
    playoff_places     integer NOT NULL DEFAULT 1 CHECK (playoff_places >= 0),
    sort_order         integer NOT NULL DEFAULT 0,
    note               text,
    UNIQUE (competition_id, fixture_source_id, division_label)
);

ALTER TABLE pyramid_forecast_policies ADD COLUMN IF NOT EXISTS our_name_pattern text;

INSERT INTO pyramid_relegation_outlook (competition_id, season, sort_order, teams, relegated, promoted, rules_label, note)
SELECT c.id, v.season, v.o, v.teams, v.down, v.up, v.rules, v.note
  FROM pyramid_competitions c
 CROSS JOIN (VALUES
    ('2026-27', 1, 16, 3.5, 1.5, 'Shrinking year 1', 'Owner 11/19: 3.5 of 16 — 8th A + 8th B down, 7th v 7th loser down, winner v a CASA side'),
    ('2027-28', 2, 14, 3.5, 1.5, 'Shrinking year 2', 'Owner 11/19: 3.5 of 14 next year'),
    ('2028-29', 3, 12, 1.5, 1.5, 'Normal APSL rules', 'Owner 11/19: back to normal APSL rules, 1.5 of 12')
 ) AS v(season, o, teams, down, up, rules, note)
 WHERE c.kind = 'conference' AND c.name = 'Delaware River Conference'
ON CONFLICT (competition_id, season) DO NOTHING;

-- CASA Select Philadelphia Liga 1 (league_fixtures source 1, SportsEngine).
INSERT INTO pyramid_feeder_sources (competition_id, fixture_source_id, division_label, label, auto_places, playoff_places, note)
SELECT c.id, s.id, 'Liga 1', 'CASA Philadelphia Liga 1', 1, 1,
       'Owner 11/19: 1.5 promotion spots a year. Counted as 1st up, 2nd plays the group-playoff winner (feeder_stay_up_pct) — until the owner says how the CASA leagues share them'
  FROM pyramid_competitions c, league_fixture_sources s
 WHERE c.kind = 'conference' AND c.name = 'Delaware River Conference'
   AND s.league_label = 'CASA' AND s.program_id = '69f8ec901f20d170d3795cec'
ON CONFLICT (competition_id, fixture_source_id, division_label) DO NOTHING;

UPDATE pyramid_forecast_policies p SET our_name_pattern = 'Lighthouse%'
  FROM pyramid_competitions c
 WHERE p.competition_id = c.id AND c.name = 'Delaware River Conference' AND p.our_name_pattern IS NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_ol_title',      'Forecast — outlook heading',                                         '📉 Up and down — three seasons', 387),
    ('fc_ol_note',       'Forecast — outlook note',                                            'The .5 = the group-playoff winner v the feeder side: one of the two plays here next year.', 388),
    ('fc_ol_season',     'Forecast — outlook column: season',                                  'Season', 389),
    ('fc_ol_teams',      'Forecast — outlook column: teams',                                   'Teams', 390),
    ('fc_ol_down',       'Forecast — outlook column: relegated',                               '⬇ Down', 391),
    ('fc_ol_down_pct',   'Forecast — outlook column: share relegated',                         '% down', 392),
    ('fc_ol_up',         'Forecast — outlook column: promoted in',                             '⬆ Up', 393),
    ('fc_ol_next',       'Forecast — outlook column: size next year',                          'Next year', 394),
    ('fc_ol_rules',      'Forecast — outlook column: rules',                                   'Rules', 395),
    ('fc_ol_road',       'Forecast — our road heading ({team})',                               '🛣 {team}''s road', 396),
    ('fc_ol_road_now',   'Forecast — our road: this season ({down} {season})',                 '{season}: {down} chance we go down (from the forecast above).', 397),
    ('fc_ol_stay',       'Forecast — our road: survive both hard years ({pct} {s1} {s2} {base})', 'Stay up through {s1} and {s2}: {pct} — this season''s forecast × the {base} an average side goes down next year.', 398),
    ('fc_ol_bounce',     'Forecast — our road: drop now, back next year ({s2} {s3} {feeder} {up} {others} {s3_down} {s3_teams})', 'Drop now: {s2} in {feeder} — {up} spots come up, and the {others} other sides relegated with us chase them too. Back up for {s3}: then only {s3_down} of {s3_teams} go down.', 399),
    ('fc_ol_feeder',     'Forecast — feeder table heading ({label})',                          '⬆ {label} — who comes up', 400),
    ('fc_ol_feeder_note','Forecast — feeder note ({auto} {playoff} {pct} {played} {left})',     'Strength from {played} games ({left} to go), 1.00 = this league''s average — no game links CASA and APSL, so the two scales can''t be compared. Promotion counted as: top {auto} up, the next {playoff} play our group-playoff winner ({pct} to come up).', 401),
    ('fc_ol_col_up',     'Forecast — feeder column: promoted %',                               '⬆ Up', 402),
    ('fc_ol_col_first',  'Forecast — feeder column: 1st %',                                    '1st', 403),
    ('fc_ol_col_po',     'Forecast — feeder column: plays the playoff %',                      '⚔️ Playoff', 404)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;

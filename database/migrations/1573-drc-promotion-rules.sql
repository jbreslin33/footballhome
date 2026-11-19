-- 1573 (2026-11-19) — 📉 #apsl Forecast: Delaware River promotion rules,
-- every feeder.
--
-- Owner 2026-11-19: "there are other feeder conferences going to drc. check
-- the pyramid. desert hawks would play the winners of the other confs for
-- auto promotion. loser of those would go into promotion playoffs with the
-- 2nd to 5th from each feeder. not counting reserve teams or teams that are
-- for metro" + "we skip them in playoffs etc and go to next team" + "you
-- should write this db as rules for drc pro/rels".
--
-- Feeders = the pyramid's own links into the conference (pyramid_links
-- upper_competition_id): CASA Select Philadelphia, Lancaster and Central
-- Jersey Liga 1.  Mig 1571's pyramid_feeder_sources (Philly only, read from
-- league_fixtures) goes; the feeders' games now come from the pyramid read
-- itself (PyramidSync's SportsEngine reader stores them in pyramid_games).
--
-- pyramid_promotion_rules, one row per conference:
--   champion_rank           the place that makes a feeder's champion (1)
--   champions_format        how the champions meet: 'knockout' (random draw,
--                           byes when not a power of two, neutral, a draw =
--                           50/50 on penalties); the winner goes up
--   playoff_from/to_rank    which further places enter the promotion playoff
--                           (2nd–5th), with the champions who lost
--   playoff_format          'knockout' as above
--   playoff_winner_meets_survivor  the playoff winner then plays the
--                           conference's group-playoff winner
--                           (pyramid_forecast_policies.feeder_stay_up_pct)
--   skip_reserves           a team whose club has a side in any APSL
--                           conference is skipped (the next team moves up)
--   skip_other_conference   a feeder team nearest another conference
--                           (pyramid_team_nearest_conference, the official
--                           drive-time model) is skipped
-- pyramid_promotion_exclusions: a club skipped by hand (with why) — for a
-- reserve side the pyramid can't link to its first team by club.
-- Strength: each feeder's teams rated from their own games, 1.00 = that
-- league's average; no game links the feeders, so their averages are taken
-- as equal when the champions and the playoff meet.
BEGIN;

DROP TABLE IF EXISTS pyramid_feeder_sources;

CREATE TABLE IF NOT EXISTS pyramid_promotion_rules (
    competition_id                 integer PRIMARY KEY REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    champion_rank                  integer NOT NULL DEFAULT 1 CHECK (champion_rank >= 1),
    champions_format               text NOT NULL DEFAULT 'knockout' CHECK (champions_format IN ('knockout')),
    playoff_from_rank              integer NOT NULL DEFAULT 2 CHECK (playoff_from_rank >= 1),
    playoff_to_rank                integer NOT NULL DEFAULT 5 CHECK (playoff_to_rank >= playoff_from_rank),
    champion_losers_to_playoff     boolean NOT NULL DEFAULT true,
    playoff_format                 text NOT NULL DEFAULT 'knockout' CHECK (playoff_format IN ('knockout')),
    playoff_winner_meets_survivor  boolean NOT NULL DEFAULT true,
    skip_reserves                  boolean NOT NULL DEFAULT true,
    skip_other_conference          boolean NOT NULL DEFAULT true,
    note                           text
);

CREATE TABLE IF NOT EXISTS pyramid_promotion_exclusions (
    id               serial PRIMARY KEY,
    competition_id   integer NOT NULL REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    pyramid_club_id  integer NOT NULL REFERENCES pyramid_clubs(id) ON DELETE CASCADE,
    reason           text NOT NULL,
    UNIQUE (competition_id, pyramid_club_id)
);

INSERT INTO pyramid_promotion_rules (competition_id, note)
SELECT c.id, 'Owner 11/19: feeder champions play off for the auto spot; the losers join 2nd–5th of each feeder in the promotion playoff; reserves and Metro-side teams skipped, the next team moves up'
  FROM pyramid_competitions c
 WHERE c.kind = 'conference' AND c.name = 'Delaware River Conference'
ON CONFLICT (competition_id) DO NOTHING;

-- Lighthouse Mens Club 1893 = Lighthouse 1893 SC's reserve side (the
-- pyramid keeps them as two clubs).
INSERT INTO pyramid_promotion_exclusions (competition_id, pyramid_club_id, reason)
SELECT c.id, pc.id, 'Reserve side of Lighthouse 1893 SC (APSL)'
  FROM pyramid_competitions c, pyramid_clubs pc
 WHERE c.kind = 'conference' AND c.name = 'Delaware River Conference' AND pc.name = 'Lighthouse Mens Club 1893'
ON CONFLICT (competition_id, pyramid_club_id) DO NOTHING;

-- Words: the feeder-note and promotion columns follow the rules now.
UPDATE message_templates SET body = 'Each side''s strength comes from its own games, 1.00 = its league''s average. No game links the feeders (or CASA and APSL), so the feeders'' averages are taken as equal when they meet.', label = 'Forecast — feeder note'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_feeder_note';
UPDATE message_templates SET body = '⬆ Who comes up — the feeders', label = 'Forecast — feeders heading'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_feeder';
UPDATE message_templates SET body = 'Drop now: {s2} in {feeder} — {up} spots come up across the feeders, and the {others} other sides relegated with us chase them too. Back up for {s3}: then only {s3_down} of {s3_teams} go down.'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_bounce';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_ol_rules_text', 'Forecast — promotion rules ({champ} {from} {to} {meet})',   'How they come up: each feeder''s {champ} (reserves and sides nearer another conference skipped — the next team moves up) meet in a knockout; the winner goes up. The champions who lose join {from}–{to} of each feeder in the promotion playoff (knockout, random draw).{meet}', 405),
    ('fc_ol_rules_meet', 'Forecast — promotion rules: playoff winner v survivor ({pct})', ' Its winner plays our group-playoff winner for the last spot ({pct} to come up).', 406),
    ('fc_ol_col_champ',  'Forecast — feeder column: champion %',                      '👑 Champion', 407),
    ('fc_ol_col_auto',   'Forecast — feeder column: wins the champions'' knockout %', '⬆ Auto', 408),
    ('fc_ol_col_poin',   'Forecast — feeder column: in the promotion playoff %',      '⚔️ In playoff', 409),
    ('fc_ol_col_powin',  'Forecast — feeder column: wins the promotion playoff %',    '🏆 Wins it', 410),
    ('fc_ol_col_rank',   'Forecast — feeder column: place among the eligible',        'Elig. #', 411),
    ('fc_ol_skip_reserve','Forecast — skipped: reserve side',                         'reserve — skipped', 412),
    ('fc_ol_skip_conf',  'Forecast — skipped: nearer another conference ({conf})',    'for {conf} — skipped', 413),
    ('fc_ol_skip_hand',  'Forecast — skipped by hand ({reason})',                     '{reason} — skipped', 414),
    ('fc_ol_summary',    'Forecast — feeders summary line ({auto} {po})',             'Most likely up: {auto} (auto) · playoff favourite: {po}', 415)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;

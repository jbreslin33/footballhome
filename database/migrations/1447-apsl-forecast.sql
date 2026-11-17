-- 1447 (2026-11-17) — 📈 #apsl Forecast: every conference's games stored,
-- a goals model, and the season played out 10,000 times.
--
-- Owner 2026-11-17: "anaylaze apsl standings. tell me chances of lightouse
-- getting relegated. 8th place in del river a and b get auto relegated. 7th
-- place in a and b play off and loser gets relegated. winner has to play a
-- casa team to stay up" + "top 2 spots in a and b go to playoffs. actually
-- make on apsl page an analysis for league and all teams so i can click on
-- any of them" + "make it be able to predict scores etc. like a betting app
-- lol. use analysis".
--
-- pyramid_games: the TeamPass feed's games (one row per feed game), written
-- by the same weekly read as the tables (PyramidSync → fh_pyramid_games_load).
-- pyramid_sources.tiebreak: the feed's own table order (sort_features
-- codenames, e.g. Points → H2H points → H2H goal diff → goal diff → goals).
-- pyramid_forecast_policies: per conference (NULL = every conference) the
-- simulation's settings.  The zones themselves stay pyramid_division_zones
-- (playoff 1–2, relegation playoff 7, relegation 8 for the Delaware River
-- groups — already the league's marks).
BEGIN;

CREATE TABLE IF NOT EXISTS pyramid_games (
    id            serial PRIMARY KEY,
    source_id     integer NOT NULL REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    external_id   text NOT NULL,
    division_ext  text NOT NULL,          -- the feed's division id (a conference's groups share it)
    home_ext      text NOT NULL,          -- pyramid_teams.external_id (t1 = home)
    away_ext      text NOT NULL,
    starts_local  timestamp,              -- the feed's local kick-off
    home_score    integer,
    away_score    integer,
    complete      boolean NOT NULL DEFAULT false,
    cancelled     boolean NOT NULL DEFAULT false,
    forfeit       boolean NOT NULL DEFAULT false,
    last_seen_at  timestamptz NOT NULL DEFAULT now(),
    removed_at    timestamptz,
    UNIQUE (source_id, external_id)
);
CREATE INDEX IF NOT EXISTS idx_pyramid_games_div ON pyramid_games (source_id, division_ext);

ALTER TABLE pyramid_sources ADD COLUMN IF NOT EXISTS tiebreak text[];

-- One writer for the games: upsert what the feed lists, mark the rest gone.
CREATE OR REPLACE FUNCTION fh_pyramid_games_load(p_source_id integer, p_games jsonb, p_tiebreak text[]) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE n integer;
BEGIN
  INSERT INTO pyramid_games (source_id, external_id, division_ext, home_ext, away_ext, starts_local,
                             home_score, away_score, complete, cancelled, forfeit, last_seen_at, removed_at)
  SELECT p_source_id, g->>'id', g->>'d', g->>'t1', g->>'t2', NULLIF(g->>'dt', '')::timestamp,
         NULLIF(g->>'s1', '')::int, NULLIF(g->>'s2', '')::int,
         COALESCE((g->>'c')::int, 0) = 1, COALESCE((g->>'x')::int, 0) = 1, COALESCE((g->>'ff')::int, 0) = 1, now(), NULL
    FROM jsonb_array_elements(p_games) g
   WHERE g ? 'id' AND g ? 't1' AND g ? 't2' AND g ? 'd'
  ON CONFLICT (source_id, external_id) DO UPDATE SET
         division_ext = EXCLUDED.division_ext, home_ext = EXCLUDED.home_ext, away_ext = EXCLUDED.away_ext,
         starts_local = EXCLUDED.starts_local, home_score = EXCLUDED.home_score, away_score = EXCLUDED.away_score,
         complete = EXCLUDED.complete, cancelled = EXCLUDED.cancelled, forfeit = EXCLUDED.forfeit,
         last_seen_at = now(), removed_at = NULL;
  GET DIAGNOSTICS n = ROW_COUNT;
  UPDATE pyramid_games SET removed_at = now()
   WHERE source_id = p_source_id AND removed_at IS NULL
     AND external_id NOT IN (SELECT g->>'id' FROM jsonb_array_elements(p_games) g WHERE g ? 'id');
  IF p_tiebreak IS NOT NULL AND array_length(p_tiebreak, 1) > 0 THEN
    UPDATE pyramid_sources SET tiebreak = p_tiebreak WHERE id = p_source_id;
  END IF;
  RETURN n;
END $$;

CREATE TABLE IF NOT EXISTS pyramid_forecast_policies (
    id                     serial PRIMARY KEY,
    competition_id         integer UNIQUE REFERENCES pyramid_competitions(id) ON DELETE CASCADE,   -- NULL = every conference
    sims                   integer NOT NULL DEFAULT 10000 CHECK (sims BETWEEN 500 and 100000),
    prior_games            numeric NOT NULL DEFAULT 3 CHECK (prior_games >= 0),   -- shrink each team toward average by this many average games
    pair_relegation_playoffs boolean NOT NULL DEFAULT true,   -- the relegation-playoff places of two groups meet; the loser goes down
    feeder_label           text,                              -- who the survivor then plays to stay up (NULL = nobody)
    feeder_stay_up_pct     numeric NOT NULL DEFAULT 50 CHECK (feeder_stay_up_pct BETWEEN 0 AND 100),
    note                   text
);
INSERT INTO pyramid_forecast_policies (competition_id, note)
SELECT NULL, 'Default for every conference'
 WHERE NOT EXISTS (SELECT 1 FROM pyramid_forecast_policies WHERE competition_id IS NULL);
-- Delaware River (owner 11/17): 7th A v 7th B, the loser goes down; the
-- winner plays a CASA team to stay up.  Nothing is known of that CASA side,
-- so it is a coin flip until the owner says otherwise.
INSERT INTO pyramid_forecast_policies (competition_id, feeder_label, feeder_stay_up_pct, note)
SELECT c.id, 'a CASA team', 50, 'Owner 11/17: 7th A v 7th B, loser relegated; winner plays a CASA team to stay up (50/50 — no CASA side known yet)'
  FROM pyramid_competitions c
 WHERE c.kind = 'conference' AND c.name = 'Delaware River Conference'
   AND NOT EXISTS (SELECT 1 FROM pyramid_forecast_policies p WHERE p.competition_id = c.id);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('view_forecast',      'APSL pyramid — view pill: forecast',                           '📈 Forecast', 330),
    ('fc_title',           'Forecast — title ({conf})',                                     '📈 {conf} — the season played out {sims} times', 331),
    ('fc_pick_conf',       'Forecast — pick a conference',                                  'Pick a conference', 332),
    ('fc_none',            'Forecast — no games stored for this conference',               'No schedule stored for this conference yet — it arrives with the weekly read.', 333),
    ('fc_how',             'Forecast — how it works ({games} {left} {avg} {home})',        'Built from {games} played games ({left} to go): each side''s goals for and against, adjusted for who they played, {avg} goals a side a game, home edge ×{home}. Each remaining game is drawn at random from those goal rates, the tables sorted by the league''s own tie-breaks, then the playoffs played. Percentages = share of the 10,000 seasons.', 334),
    ('fc_col_team',        'Forecast — column: team',                                       'Team', 335),
    ('fc_col_now',         'Forecast — column: today (pos / pts)',                          'Now', 336),
    ('fc_col_xpts',        'Forecast — column: expected points',                            'xPts', 337),
    ('fc_col_playoff',     'Forecast — column: playoff %',                                  '🏆 Playoff', 338),
    ('fc_col_first',       'Forecast — column: 1st %',                                      '1st', 339),
    ('fc_col_relplay',     'Forecast — column: relegation playoff %',                       '⚔️ Rel. playoff', 340),
    ('fc_col_auto',        'Forecast — column: auto relegation %',                          '⬇ Auto', 341),
    ('fc_col_down',        'Forecast — column: relegated in all %',                         '💀 Down', 342),
    ('fc_col_rating',      'Forecast — column: strength',                                    'Strength', 343),
    ('fc_tap_team',        'Forecast — tap a team hint',                                    'Tap a team for its odds, its games and every predicted score', 344),
    ('fc_upcoming',        'Forecast — heading: upcoming games',                            '🎯 Upcoming games — predicted', 345),
    ('fc_results',         'Forecast — heading: results',                                   '✅ Results', 346),
    ('fc_finish',          'Forecast — heading: finish position chances',                   'Where they finish', 347),
    ('fc_team_odds',       'Forecast — team summary ({playoff} {down} {xpts})',             '🏆 {playoff} playoff · 💀 {down} relegated · {xpts} expected points', 348),
    ('fc_strength',        'Forecast — strength line ({att} {def})',                        'Scores {att}× and concedes {def}× an average side (1.00 = average)', 349),
    ('fc_down_path',       'Forecast — how they go down ({auto} {playoff} {feeder})',       '⬇ {auto} finish bottom · ⚔️ {playoff} lose the group playoff · {feeder} lose to {feeder_label}', 350),
    ('fc_down_path_nofeed','Forecast — how they go down, no feeder game ({auto} {playoff})','⬇ {auto} finish bottom · ⚔️ {playoff} lose the group playoff', 351),
    ('fc_back',            'Forecast — back to the table',                                  '← All teams', 352),
    ('fc_odds',            'Forecast — odds line label',                                    'Odds', 353),
    ('fc_likely',          'Forecast — most likely score',                                  'Most likely', 354),
    ('fc_over',            'Forecast — over 2.5 goals',                                     'Over 2.5', 355),
    ('fc_btts',            'Forecast — both teams score',                                   'Both score', 356),
    ('fc_xg',              'Forecast — expected goals',                                     'xG', 357),
    ('fc_draw',            'Forecast — draw',                                               'Draw', 358),
    ('fc_scores',          'Forecast — top scores heading',                                 'Top scores', 359),
    ('fc_feeder_note',     'Forecast — feeder assumption ({feeder} {pct})',                 'The group-playoff winner then plays {feeder} to stay up — counted as {pct} to stay up (nothing known of that side).', 360),
    ('fc_fun',             'Forecast — disclaimer',                                         'For fun — a goals model, not a bookmaker. Odds are fair odds (no margin).', 361),
    ('fc_asof',            'Forecast — as of ({date})',                                     'Games as of {date}', 362),
    ('fc_all_games',       'Forecast — heading: every upcoming game in the conference',     '🎯 Every upcoming game', 363)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;

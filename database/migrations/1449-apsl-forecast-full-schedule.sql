-- 1449 (2026-11-17) — 📈 #apsl Forecast: the WHOLE season, not just the
-- games the feed lists.
--
-- Owner 2026-11-17: "wait do you know that its a 22 game schedule right? so
-- you play your division 2x and the other division 1x. recalc and show all
-- projections for every matchup for rest of year for all teams."
--
-- The TeamPass feed lists the fall half only (12 a team in the Delaware
-- River).  group_rounds / cross_group_rounds say how often each pair meets;
-- PyramidForecast adds the meetings the feed doesn't list yet as "to be
-- scheduled" games — a same-group return leg at the other side's ground, a
-- cross-group game at no known ground (no home edge).  NULL = only the
-- listed games (every other conference until its format is entered).
BEGIN;
ALTER TABLE pyramid_forecast_policies
    ADD COLUMN IF NOT EXISTS group_rounds integer CHECK (group_rounds BETWEEN 1 AND 4),
    ADD COLUMN IF NOT EXISTS cross_group_rounds integer CHECK (cross_group_rounds BETWEEN 0 AND 4);
UPDATE pyramid_forecast_policies p SET group_rounds = 2, cross_group_rounds = 1,
       note = COALESCE(note, '') || ' · 22 games: own group twice, the other group once (owner 11/17)'
  FROM pyramid_competitions c
 WHERE p.competition_id = c.id AND c.name = 'Delaware River Conference' AND p.group_rounds IS NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_tbs',          'Forecast — a game the league has not scheduled yet',              'Not scheduled yet', 364),
    ('fc_neutral',      'Forecast — venue not known (no home edge)',                       'venue TBD', 365),
    ('fc_format',       'Forecast — the season format ({n} {rounds} {cross} {listed} {added})', '{n}-game season: own group {rounds}×, the other group {cross}× — {listed} games listed by the league, {added} more still to be scheduled (included).', 366),
    ('fc_all_rows',     'Forecast — heading: every remaining matchup ({n})',               '🎯 Every remaining matchup · {n}', 367),
    ('fc_col_game',     'Forecast — column: game',                                         'Game', 368),
    ('fc_col_when',     'Forecast — column: when',                                         'When', 369),
    ('fc_filter_all',   'Forecast — matchup filter: all',                                  'All', 370),
    ('fc_filter_sched', 'Forecast — matchup filter: scheduled',                            'Scheduled', 371),
    ('fc_filter_tbs',   'Forecast — matchup filter: not scheduled yet',                    'Not scheduled yet', 372)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
COMMIT;

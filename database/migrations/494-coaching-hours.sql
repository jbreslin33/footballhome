-- 494 (2026-09-29) — Coaching on #finances.  Owner: "add in coach hours
-- right? their usual hours to expenses? list it as coaching. then for each
-- game assume a coach getting paid hours of for game of u8 1.5, u10 1.5,
-- u12 2, apsl 3, liga 1 2.45, women 2. so you should be able to estimate
-- games per month right?"
--
-- Two kinds of Coaching item, both under the invoice category 'labor':
--   Usual hours   each active issuer's default week (invoice_default_shifts)
--                 × their hourly_rate, projected day by day from today —
--                 computed in Expenses::projection(), nothing stored
--   Game hours    per game, every game (home and away): ref_fee_policies
--                 rows of kind 'coaching' with hours_per_game × rate_per_hour;
--                 games come from the same schedules as the referee fees,
--                 seasons say how many games each season should hold
ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS kind           TEXT NOT NULL DEFAULT 'referee' CHECK (kind IN ('referee', 'coaching'));
ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS hours_per_game NUMERIC(5,2);
ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS rate_per_hour  NUMERIC(8,2);
COMMENT ON TABLE ref_fee_policies IS 'Per-game costs (mig 490/494): kind referee = fee per home game; kind coaching = hours_per_game × rate_per_hour for every game. Games come from league_fixtures when the league has a feed, else from the calendar.';

CREATE OR REPLACE FUNCTION pg_temp.coach(p_label text, p_section int, p_league int, p_fixture text, p_labels text[], p_cat text, p_band text, p_hours numeric, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO ref_fee_policies (club_id, label, group_label, kind, club_section_id, league_id, fixture_league_label, event_league_labels, event_category, age_band,
                                hours_per_game, rate_per_hour, per_game_usd, home_only, sort_order, note)
  SELECT 134, p_label, 'Game hours', 'coaching', p_section, p_league, p_fixture, p_labels, p_cat, p_band,
         p_hours, 15.00, ROUND(p_hours * 15.00, 2), false, p_sort, 'Owner 2026-09-29: coach paid ' || p_hours || ' h per game at the $15 coaching rate, home and away'
   WHERE NOT EXISTS (SELECT 1 FROM ref_fee_policies WHERE club_id = 134 AND kind = 'coaching' AND label = p_label);
$$;
SELECT pg_temp.coach('APSL',            1, 1, 'APSL', '{APSL}',                       'mens',   NULL,  3.00, 11);
SELECT pg_temp.coach('Liga 1',          1, 2, 'CASA', '{CASA,"Liga 1","LIGA 1"}',     'mens',   NULL,  2.45, 12);
SELECT pg_temp.coach('Tri County',      2, 7, NULL,   '{"Tri County",TCWSL}',         'womens', NULL,  2.00, 13);
SELECT pg_temp.coach('Parks & Rec U8',  3, 8, NULL,   '{PPR}',                        'boys',   'U8',  1.50, 14);
SELECT pg_temp.coach('Parks & Rec U10', 3, 8, NULL,   '{PPR}',                        'boys',   'U10', 1.50, 15);
SELECT pg_temp.coach('Parks & Rec U12', 3, 8, NULL,   '{PPR}',                        'boys',   'U12', 2.00, 16);

-- Seasons for game hours: every game, home and away.  Fall = what the
-- schedules show today; the rest mirrors it (assumed).
CREATE OR REPLACE FUNCTION pg_temp.cseason(p_label text, p_season text, p_from date, p_to date, p_n int, p_assumed boolean)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO ref_fee_seasons (policy_id, label, starts_on, ends_on, home_games_expected, is_assumed)
  SELECT p.id, p_season, p_from, p_to, p_n, p_assumed FROM ref_fee_policies p
   WHERE p.club_id = 134 AND p.kind = 'coaching' AND p.label = p_label
     AND NOT EXISTS (SELECT 1 FROM ref_fee_seasons s WHERE s.policy_id = p.id AND s.label = p_season);
$$;
SELECT pg_temp.cseason('APSL',   'Fall 2026',   '2026-09-01', '2026-12-31', 12, false);
SELECT pg_temp.cseason('APSL',   'Spring 2027', '2027-03-01', '2027-06-30', 10, true);
SELECT pg_temp.cseason('Liga 1', 'Fall 2026',   '2026-09-01', '2026-12-31', 12, false);
SELECT pg_temp.cseason('Liga 1', 'Spring 2027', '2027-03-01', '2027-06-30', 12, true);
SELECT pg_temp.cseason('Tri County', 'Fall 2026',   '2026-09-01', '2026-11-30', 8, true);
SELECT pg_temp.cseason('Tri County', 'Spring 2027', '2027-03-01', '2027-06-15', 8, true);
SELECT pg_temp.cseason('Parks & Rec U8',  'Fall 2026',      '2026-09-01', '2026-11-30', 9, false);
SELECT pg_temp.cseason('Parks & Rec U8',  'Indoor 2026/27', '2026-12-01', '2027-02-28', 9, true);
SELECT pg_temp.cseason('Parks & Rec U8',  'Spring 2027',    '2027-03-01', '2027-06-15', 9, true);
SELECT pg_temp.cseason('Parks & Rec U10', 'Fall 2026',      '2026-09-01', '2026-11-30', 9, false);
SELECT pg_temp.cseason('Parks & Rec U10', 'Indoor 2026/27', '2026-12-01', '2027-02-28', 9, true);
SELECT pg_temp.cseason('Parks & Rec U10', 'Spring 2027',    '2027-03-01', '2027-06-15', 9, true);
SELECT pg_temp.cseason('Parks & Rec U12', 'Fall 2026',      '2026-09-01', '2026-11-30', 9, false);
SELECT pg_temp.cseason('Parks & Rec U12', 'Indoor 2026/27', '2026-12-01', '2027-02-28', 9, true);
SELECT pg_temp.cseason('Parks & Rec U12', 'Spring 2027',    '2027-03-01', '2027-06-15', 9, true);

-- Coaching leads the category order; the labor category prints as Coaching.
UPDATE message_templates SET body = 'labor|league_dues|registrations|referees|field_rentals|facilities|equipment|uniforms|other' WHERE kind = 'finances' AND tier = 'category_order';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', 'Finances — the labor category''s name', 'finances', 'coaching_label', NULL, 'Coaching', 22, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'coaching_label');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', 'Finances — usual hours item', 'finances', 'usual_hours', NULL, 'Usual hours — {name}', 23, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'usual_hours');

-- Game hours stay one line per league inside Coaching (no merge).
UPDATE ref_fee_policies SET group_label = NULL WHERE club_id = 134 AND kind = 'coaching';

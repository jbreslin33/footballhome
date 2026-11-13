-- 1332 (2026-11-13): James's men's coaching for the year, $20 an hour.
--
-- Owner: "for men i am the coach … factor the hours for coaching for year
-- august through july … $20 an hour … we never stop practicing … its always 5
-- days of practice. but sometimes we have holidays and cancel … do games
-- separate by looking at ref fees … double apsl home games."
--
--   games      per-game coaching policies (kind coaching, Men's pill):
--              APSL 22 (11 home on the refs line × 2) × 3 h, Liga 1 22 × 2.45 h
--              — already $60 / $49 a game = $20/h; rate_per_hour 15 → 20.
--              New: U23 6 × 2.45 h ($49), Cups 5 × 3 h ($60: Amateur 1,
--              state open cup 1, Grassroots 3).
--   practices  budget_lines "Coaching — practices": 5 practices a week, 8¼ h
--              (Mon/Wed/Fri 1¾, Tue/Thu 1½ — calendar lengths) × $20 = $165 a
--              week, all year, less 2 weeks of holidays/cancellations
--              (budget_lines.weeks_off) — assumed.  Its cash timing stays the
--              coach's usual week on the grid, so the Year plan alone reads it.

BEGIN;

UPDATE ref_fee_policies SET rate_per_hour = 20.00,
       note = 'Coach paid hours per game × $20 (owner 2026-11-13), home and away'
 WHERE id IN (7, 8) AND kind = 'coaching';

WITH p AS (
  INSERT INTO ref_fee_policies (club_id, label, club_section_id, event_league_labels, event_category, per_game_usd, home_only,
                                effective_from, is_active, sort_order, note, kind, hours_per_game, rate_per_hour, bill_home_only,
                                team_id, budget_scope)
  SELECT 134, v.label, 1, v.labels, 'mens', v.per_game, false, '2026-08-01', true, v.so,
         'Coach paid hours per game × $20 (owner 2026-11-13)', 'coaching', v.hours, 20.00, false, t.id, 'mens'
    FROM (VALUES ('U23',  ARRAY['U23'],       49.00, 2.45, 14, 'Lighthouse Mens Club U23'),
                 ('Cups', ARRAY['USASA Cup'], 60.00, 3.00, 15, 'USASA Cup')) AS v(label, labels, per_game, hours, so, team)
    JOIN teams t ON t.name = v.team
  RETURNING id, label
)
INSERT INTO ref_fee_seasons (policy_id, label, starts_on, ends_on, home_games_expected, is_assumed, note)
SELECT p.id, '2026/27', '2026-08-01', '2027-07-31', CASE p.label WHEN 'U23' THEN 6 ELSE 5 END, false,
       CASE p.label WHEN 'U23' THEN '6 games, no playoffs (owner 2026-11-13)'
                    ELSE 'Amateur Cup 1 (lost 10/18), state open cup 1, Grassroots 3 group games' END
  FROM p;

ALTER TABLE budget_lines ADD COLUMN IF NOT EXISTS weeks_off integer NOT NULL DEFAULT 0 CHECK (weeks_off >= 0);
COMMENT ON COLUMN budget_lines.weeks_off IS 'Weeks a per-week line skips in its period (holidays, cancellations) — mig 1332';

INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end,
                          spread, is_assumed, is_active, sort_order, note, budget_year_id, weeks_off)
VALUES (134, 1, 'labor', 'Coaching — practices', 165.00, 'week', '2026-08-01', '2027-07-31', 'even', true, true, 5,
        'James: 5 practices a week, 8¼ h (Mon/Wed/Fri 1¾, Tue/Thu 1½) × $20 — all year, 2 weeks off for holidays/cancellations (owner 2026-11-13)',
        1, 2);

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan game coaching row',  'finances', 'plan_game_coaching', 'Game coaching — {label}', true, 84, true, false),
  ('Finances', 'Finances — Year plan per game unit',      'finances', 'plan_unit_game',     'per game: {hours} h × {rate}/h', true, 85, true, false);

INSERT INTO schema_migrations (filename) VALUES ('1332-mens-coaching-year.sql') ON CONFLICT DO NOTHING;
COMMIT;

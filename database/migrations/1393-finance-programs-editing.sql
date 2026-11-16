-- 1393 (2026-11-16) — #finances 🧩 Programs, step 2: plan seasons edited on
-- the page (owner "continue" after step 1). Words only; the data is
-- program_season_plans / program_season_entries (mig 1390).
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — programs: saving', 'pg_saving', 'Saving…', 353),
    ('Finances — programs: all seasons placeholder', 'pg_all_seasons', 'all', 354),
    ('Finances — programs: row practice hours', 'pg_row_practice_h', 'Practice h/wk', 355),
    ('Finances — programs: row practice weeks', 'pg_row_practice_w', 'Practice weeks', 356),
    ('Finances — programs: row games', 'pg_row_games_n', 'Games per team', 357),
    ('Finances — programs: row game hours', 'pg_row_game_h', 'Hours a game', 358),
    ('Finances — programs: row coach rate', 'pg_row_rate', 'Coach $/h', 359),
    ('Finances — programs: paid', 'pg_paid', 'Paid', 360),
    ('Finances — programs: row leagues', 'pg_row_leagues', 'Leagues', 361),
    ('Finances — programs: remove', 'pg_remove', 'Remove', 362),
    ('Finances — programs: add league', 'pg_add_league', '＋ league', 363),
    ('Finances — programs: edit hint', 'pg_edit', 'Plan seasons: type a number to set it, clear it to go back to the default (grey). The Total column sets every plan season of the year at once.', 364)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

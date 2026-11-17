-- 1424 (2026-11-16): 💵 Men's money and every 🧩 program table read as a
-- running balance, with coaching on its own lines. Owner: "show all coaching
-- on separate lines and do pre coaching balance" + "pre grant total" + "pre
-- club wide total" + "do that for all, not just men".
--   money in → own costs → BALANCE BEFORE COACHING → coaching (practice,
--   each game-coaching line) → BALANCE BEFORE CLUB WIDE → club wide share →
--   BALANCE BEFORE GRANT → grant → BALANCE AFTER GRANT.
-- Plan seasons split the program's coaching into practice and game lines
-- (ProgramBudget.cpp). Words only here.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — men''s money: coaching band',            'pm_coaching',            'Coaching',                    417),
    ('Finances — men''s money: coaching heading',         'pm_out_coaching',        'MONEY OUT — COACHING',        418),
    ('Finances — men''s money: club wide heading',        'pm_out_club',            'MONEY OUT — CLUB WIDE',       419),
    ('Finances — money out before coaching (subtotal)',   'pm_out_pre_coach',       'Money out — before coaching', 420),
    ('Finances — balance before coaching',                'pm_pre_coach',           'BALANCE BEFORE COACHING',     421),
    ('Finances — balance before club wide',               'pm_pre_club',            'BALANCE BEFORE CLUB WIDE',    422),
    ('Finances — program line: practice coaching',        'pg_line_coach_practice', 'Practice coaching',           423),
    ('Finances — program line: game coaching',            'pg_line_coach_games',    'Game coaching',               424)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
UPDATE message_templates
   SET body = 'Where every dollar goes for a year of Men''s, and what comes in, as a running balance. Out = each league''s and cup''s fees × quantity from its fee plan, refs, physio; kits and LeagueApps fees; then coaching (practices and each competition''s games, every line on its own); then Men''s share of the club-wide costs. Per man / mo = the line ÷ 12 ÷ {n} paying men. Grant-proof = the balance before any grant is not negative.'
 WHERE kind = 'finances' AND tier = 'pm_note';
INSERT INTO schema_migrations (filename) VALUES ('1424-finance-running-balance-coaching-lines.sql') ON CONFLICT DO NOTHING;
COMMIT;

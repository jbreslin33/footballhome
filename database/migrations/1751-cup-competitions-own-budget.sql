-- 1751 (2026-11-23): each cup is its own competition in the budget.
--
-- Owner 2026-11-23: "lets break each to its core so open cup is not apsl its
-- open cup … it still needs separation but then u can roll them up as mens ref
-- fees league/tourny fees etc … call it a competition? the individual things
-- … just like u12 is diff from u12 travel?"
--
-- The cups were one budget scope ("Cups", team 939) with every cup inside it.
-- Now each competition the cup side enters has its own scope under Cups —
-- its own pill and its own block on #finances — and Cups / Men's still add
-- them up by kind of cost (referees, league dues, registrations …).
-- A competition scope has no team_id: money from a cup game on the calendar
-- (league "USASA Cup", team 939) cannot tell the cups apart and stays on Cups.

BEGIN;

INSERT INTO cash_flow_scopes (code, label, parent, sort_order) VALUES
    ('open_cup',       'Open Cup',       'cups', 131),
    ('amateur_cup',    'Amateur Cup',    'cups', 132),
    ('grassroots_cup', 'Grassroots Cup', 'cups', 133),
    ('us_open_cup',    'U.S. Open Cup',  'cups', 134)
ON CONFLICT (code) DO NOTHING;

UPDATE team_season_entries e SET budget_scope = m.scope
  FROM seasons s
  JOIN (VALUES (21, 'open_cup'), (22, 'amateur_cup'), (19, 'grassroots_cup'), (23, 'us_open_cup')) m(league_id, scope)
    ON m.league_id = s.league_id
 WHERE s.id = e.season_id AND e.team_id = 939;

INSERT INTO schema_migrations (filename) VALUES ('1751-cup-competitions-own-budget.sql') ON CONFLICT DO NOTHING;
COMMIT;

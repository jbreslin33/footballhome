-- 1442 (2026-11-17) — 🧩 Programs: one plan grid for every program and year
-- (owner "the now and future years should be consistent in format with
-- options … for diff amount of players and paid or volunteer coach" + "also
-- need hours for coach and it should show the schedule in there for that
-- team"). Men's table gets the same grid; Men's plan-season coaching follows
-- it (volunteer = none; practice from the grid; games when typed). Each
-- program shows its weekly practice slots from the calendar. Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — programs: schedule head ({weeks} {hours})', 'pg_schedule', 'Practice schedule — calendar, next {weeks} weeks · {hours} h/wk', 417),
    ('Finances — programs: slot on only some weeks ({n} {of})', 'pg_schedule_weeks', '{n} of {of} wks', 418),
    ('Finances — programs: no practices on the calendar', 'pg_schedule_none', 'No practices on the calendar', 419),
    ('Finances — programs: weekday names, Mon first, | between', 'pg_days', 'Mon|Tue|Wed|Thu|Fri|Sat|Sun', 420),
    ('Finances — men''s money: grid practice coaching line', 'pm_grid_practice', 'Practice coaching — plan seasons', 421),
    ('Finances — men''s money: grid game coaching line', 'pm_grid_games', 'Game coaching — plan seasons', 422),
    ('Finances — men''s money: note over the grid', 'pm_grid_note', 'Plan seasons: blank = the default (grey). Paying men add their dues; coaching follows the grid — volunteer = no coaching that season; blank games keep the per-game coaching.', 423)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
COMMIT;

-- 1397 (2026-11-16) — #finances step 3 (owner "yes"): 👥 Full capacity is the
-- program model in the "capacity" scenario (every program fields at least
-- one team per plan season, players = teams × capacity; coach, practice,
-- games and leagues shared with the plan), and the Operating Budget of a
-- later year adds up from the programs. mig 1387's own maths is gone
-- (CapacityPlan.cpp deleted): its teams / coaches tables go (no coach was
-- ever saved — 0 rows); capacity_plan_settings stays (ProgramBudget reads
-- the coach rate, weeks a year and calendar weeks from it).
DROP TABLE IF EXISTS capacity_plan_coaches;
DROP TABLE IF EXISTS capacity_plan_teams;

UPDATE message_templates SET is_active = false
 WHERE kind = 'finances' AND tier LIKE 'cap\_%' AND tier <> 'cap_title';

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — full capacity: note (programs)', 'pg_cap_note', 'Every program full: each plan season fields at least one team per program and every team at its roster capacity (players = teams × capacity; Women''s pay no dues). Coaches, practice, games and leagues are the plan''s — change them here or on 🧩 Programs, it is the same plan. A real season (this year''s fall) stays real. A what-if — the Operating Budget never reads it.', 365),
    ('Finances — budget: later year from programs', 'plan_from_programs', '{year} adds up from the programs (🧩 Programs, expected) — change it there.', 366),
    ('Finances — budget: program share of club-wide', 'plan_prog_shared', '{program} — share of club-wide costs', 367),
    ('Finances — budget: program dues unit', 'plan_prog_dues_unit', 'players averaged over the seasons, from the programs', 368)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

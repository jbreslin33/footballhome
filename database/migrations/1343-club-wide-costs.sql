-- 1343 (2026-11-13): club-wide yearly costs.
-- Owner: "veo sub is gone. we are using xbot with no sub. balls 2k projected
-- per year? cones 100, pinnies are part of uniform and included in the 35.
-- nets 100? top soil 1k. seed 3.5k. lights in future 0 right now. generator 0
-- right now. light stands 0 right now. but leave room for more."
--   per year, club-wide (no section): balls $2,000, cones $100, nets $100
--   (Equipment); top soil $1,000, seed $3,500 (Facilities); lights,
--   generator, light stands $0 — on the plan so they can be filled in later.
--   Paint ($100/wk in season) + generator gas ($30/wk) stay.
--   2026-27 and 2027-28 (paint + gas copied into 2027-28).
BEGIN;
INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end,
                          spread, is_assumed, is_active, sort_order, note, budget_year_id)
SELECT 134, NULL, v.cat, v.label, v.amt, 'fixed', y.starts_on, y.ends_on, 'even', y.label <> '2026-27', true, v.so, v.note, y.id
  FROM budget_years y
 CROSS JOIN (VALUES ('equipment',  'Balls',        2000.00, 20, '$2k a year (owner 2026-11-13)'),
                    ('equipment',  'Cones',         100.00, 21, '(owner 2026-11-13)'),
                    ('equipment',  'Nets',          100.00, 22, '(owner 2026-11-13)'),
                    ('facilities', 'Top soil',     1000.00, 23, '(owner 2026-11-13)'),
                    ('facilities', 'Grass seed',   3500.00, 24, '(owner 2026-11-13)'),
                    ('equipment',  'Lights',          0.00, 25, 'Future — $0 for now (owner 2026-11-13)'),
                    ('equipment',  'Generator',       0.00, 26, 'Future — $0 for now (owner 2026-11-13)'),
                    ('equipment',  'Light stands',    0.00, 27, 'Future — $0 for now (owner 2026-11-13)')) AS v(cat, label, amt, so, note)
 WHERE y.club_id = 134 AND y.label IN ('2026-27', '2027-28');
INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end,
                          spread, is_assumed, is_active, sort_order, note, group_label, budget_year_id, weeks_off)
SELECT club_id, club_section_id, category, label, amount_usd, amount_per, (period_start + interval '1 year')::date, (period_end + interval '1 year')::date,
       spread, true, true, sort_order, note, group_label, 2, weeks_off
  FROM budget_lines WHERE id IN (17, 18, 19, 20, 21);
INSERT INTO schema_migrations (filename) VALUES ('1343-club-wide-costs.sql') ON CONFLICT DO NOTHING;
COMMIT;

-- 547 (2026-10-07) — #my whose-schedule pills by person first (owner: "for
-- me with grace i can have a me pill and a grace pill? or a me coach
-- pill, me player pill … for parents with multiple kids each kid would
-- have a pill … the pill should show a symbol to show it's filled out or
-- needs attention").  The row is now people (Me · coach, Me · player, each
-- child) with the team / practice-group pills underneath the one picked;
-- the red count / green tick stays on every pill.  Adds the staff hat's
-- label and the sub-row's "All" (kind my_schedule).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'My page', v.l, 'my_schedule', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('who_staff',   'Whose schedule — my staff hat',            'Me · staff', 735),
    ('who_me',      'Whose schedule — me, one hat only',        'Me', 736),
    ('who_sub_all', 'Whose schedule — sub-row, every team',     'All', 737)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_schedule' AND m.tier = v.t);

-- #coach-schedule words (mig 955), read through MessageCopy, kind coach_schedule.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Coach Schedule', v.l, 'coach_schedule', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('tile_title',   'Tile title',            'Coach Schedule', 1),
    ('tile_sub',     'Tile line',             'Set each coach''s practice days — that is what they see and RSVP to', 2),
    ('title',        'Page title',            'Coach Schedule', 3),
    ('sub',          'Page line',             'Coaches see and RSVP only to the practices on their days. Games don''t change.', 4),
    ('every',        'Every day',             'Every practice', 5),
    ('call_in',      'No days',               'Call in if needed', 6),
    ('call_in_hint', 'How to call a coach in','To call a coach in, invite them on the practice in Event Center.', 7),
    ('day_1', 'Monday',    'Mon', 11), ('day_2', 'Tuesday',  'Tue', 12), ('day_3', 'Wednesday', 'Wed', 13),
    ('day_4', 'Thursday',  'Thu', 14), ('day_5', 'Friday',   'Fri', 15), ('day_6', 'Saturday',  'Sat', 16),
    ('day_7', 'Sunday',    'Sun', 17)
  ) AS v(t, l, b, o);

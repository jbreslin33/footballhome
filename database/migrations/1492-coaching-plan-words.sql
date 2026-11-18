-- 1492 (2026-11-18) — words for the 🧑‍🏫 Coaches table on #finances Programs
-- (components/coaching-plan.js, mig 1491).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Finances', l, 'finances', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('cp_title',    'Coaches table — title ({year})',  '🧑‍🏫 Coaches · {year}', 900),
    ('cp_note',     'Coaches table — how it''s worked out', 'Practice sessions × the coaches at them, early arrival before the first session of the day, and games — hover a season for the split.', 901),
    ('cp_coach',    'Coaches table — coach column',    'Coach', 902),
    ('cp_hours',    'Coaches table — hours column',    'Hours', 903),
    ('cp_amount',   'Coaches table — pay column',      'Pay', 904),
    ('cp_total',    'Coaches table — total row',       'All coaches', 905),
    ('cp_practice', 'Coaches table — practice',        'Practice', 906),
    ('cp_arrival',  'Coaches table — early arrival',   'Early arrival', 907),
    ('cp_game',     'Coaches table — games',           'Games', 908),
    ('cp_loading',  'Coaches table — loading',         'Loading coaches…', 909),
    ('cp_none',     'Coaches table — none',            'No paid coaching planned.', 910)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.t);
COMMIT;

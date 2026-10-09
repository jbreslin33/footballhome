-- 552 (2026-10-09) — #dashboard: the Home games cell.
-- Owner: "add in upcoming home games because i always need to be aware to
-- line fields and make sure i can be there".  GET /api/dashboard lists
-- every home game on the calendar in the next 28 days with the team's
-- format (teams.field_size — what to line); the words live here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dashboard', l, 'dashboard', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('home_title',      'Home games cell — title',                         '🏠 Home games', 848),
    ('home_sub',        'Home games cell — line under the title ({days} {facility})', 'Next {days} days at {facility} — line the field, be there', 849),
    ('home_count',      'Home games cell — under the big number ({days})', 'in {days} days', 850),
    ('home_games_word', 'Home games cell — "games" after a day''s count',   'games', 851),
    ('home_none',       'Home games cell — none coming ({days})',          'No home games in the next {days} days', 852)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'dashboard' AND m.tier = v.t);

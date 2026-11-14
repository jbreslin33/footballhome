-- 1366 (2026-11-14) — Event Center slice 3: Mine retires as a mounted page
-- (docs/event-center-design.md).  Owner: "do we need my section now? lets
-- think of proper build with oop concepts on front and back end".
--
-- Event Center is now three pieces for every tier: the notices strip
-- (GET /api/my/notices — C++ NoticeBoard: DuesNotice, VolunteerShiftNotice),
-- the week calendar, and 👤 Mine (page links, reminders toggle, SectionChat,
-- FinesPanel).  These are the page-link words that were hard-coded in #my's
-- header.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Mine link — team rules',  'link_team_rules', 'Team Rules', 1310),
    ('Mine link — rosters',     'link_rosters',    'Rosters',    1311),
    ('Mine link — players',     'link_players',    'Players',    1312),
    ('Mine link — schedules',   'link_schedules',  'Schedules',  1313)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

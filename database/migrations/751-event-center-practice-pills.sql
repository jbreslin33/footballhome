-- 751: a practice opens on Game Center's big pill row (lib/event-pills.js):
-- 👥 All Players (🎟 Invites inside) · 🎽 Groups (Teams on a pickup) ·
-- 📝 Practice Plan (🔶 Cones inside).  Owner 2026-10-27: "same behaviour
-- for practice and game except where we have to differ".
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('pill_players', 'Event pill — everyone on the event (RSVP, attendance, invites)', 'All Players', 1219),
    ('pill_groups',  'Event pill — practice groups by bib colour',                    'Groups', 1220),
    ('pill_teams',   'Event pill — pickup teams by bib colour',                       'Teams', 1221),
    ('pill_plan',    'Event pill — the practice plan (and cones)',                     'Practice Plan', 1222)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);

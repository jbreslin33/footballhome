-- 438 (2026-09-25) — owner: "people with dual roles, like Luke Breslin …
-- label his events as COACH or PLAYER. for Vazquez it should show COACH
-- for youth stuff and STAFF for mens and womens stuff … like a role label".
-- The role per event comes from the feed (my_role); the words are here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', l, 'my_role', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('coach',   'My page — role pill: coaches a team on this event',      'COACH',   730),
    ('player',  'My page — role pill: rostered player on this event',     'PLAYER',  731),
    ('staff',   'My page — role pill: club staff (mig 430), not coach/player', 'STAFF', 732),
    ('invited', 'My page — role pill: invited (call-up / play-down)',     'INVITED', 733)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_role' AND m.tier = v.t);

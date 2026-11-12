-- 1296 (2026-11-12): Event Center — staff see ONE of 👤 Mine / 📅 Club week at
-- a time.  Owner: "on event-center i am confused by what i see. it shows like
-- both views at same time lol player and admin/coach" → picked "two pills,
-- one at a time": Club week by default, last pick kept per device; an old
-- #my door (sign-in link, RSVP text) opens on Mine.  Players and parents have
-- no pills — Mine is their page.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.c, v.l, 'event_center', v.t, NULL, v.b, v.o, true, true, false
  FROM (SELECT (SELECT category FROM message_templates WHERE kind = 'event_center' LIMIT 1) AS c) cat,
       (VALUES
         ('Event Center — staff pill: your own week', 'view_mine', '👤 Mine',      900),
         ('Event Center — staff pill: club calendar', 'view_club', '📅 Club week', 901)
       ) AS v0(l, t, b, o)
       CROSS JOIN LATERAL (SELECT COALESCE(cat.c, 'Event Center') AS c, v0.l, v0.t, v0.b, v0.o) v
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
INSERT INTO schema_migrations (filename) VALUES ('1296-event-center-view-pills.sql') ON CONFLICT DO NOTHING;
COMMIT;

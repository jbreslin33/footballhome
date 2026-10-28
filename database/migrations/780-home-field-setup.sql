-- 780: HOME-7v7 / HOME-11v11 in place of the address when a game is on the
-- field we prep (owner 2026-10-28: "when a game is actually at Lighthouse.
-- not just 'home' … because we need to prep field"; "u8,u10 is 7v7
-- everything else is 11v11"; "you don't even need the address. this would
-- replace when its Lighthouse Sports complex").
--
-- facilities.field_prep  — a field we lay out for games (Sport Complex
--                          only; the Community Center is indoors).
-- field_formats.home_setup — what to lay out for that format: 7v7 → 7v7,
--                          9v9 and 11v11 → the full 11v11 field (9v9 is
--                          already the whole field there, field_share 1.00).
-- The calendar feed's home_setup = the biggest tagged team's setup.
ALTER TABLE facilities    ADD COLUMN IF NOT EXISTS field_prep boolean NOT NULL DEFAULT false;
ALTER TABLE field_formats ADD COLUMN IF NOT EXISTS home_setup text;

UPDATE facilities SET field_prep = true WHERE id = 1 AND NOT field_prep;   -- Lighthouse Sport Complex

UPDATE field_formats f SET home_setup = v.s
  FROM (VALUES (4, '11v11'), (7, '7v7'), (9, '11v11'), (11, '11v11')) AS v(p, s)
 WHERE f.players_per_side = v.p AND f.home_setup IS NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Game on our prepped field, in place of the address ({setup})', 'event_center', 'home_setup', NULL,
       'HOME-{setup}', 1225, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'home_setup');

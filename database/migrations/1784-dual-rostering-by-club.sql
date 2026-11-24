-- 1784 (2026-11-23): #dual-rostering — by club, most shared players first.
-- Owner: "allow to order by clubs with most guyus from other clubs lol".
-- A 👤 By player / 🏟 By club switch: By club folds the same cards under
-- each club, ordered by how many of its players are also on another club's
-- roster (within the league pills picked).  Page code only; these are its words.

BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dual rostering', l, 'roster_watch', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('by_player',  'Switch: one card per player',              '👤 By player', 70),
    ('by_club',    'Switch: clubs, most shared players first', '🏟 By club', 71),
    ('club_count', 'Club fold: its count ({n})',               '{n} also at another club', 72),
    ('club_count_all', 'Club fold: its count, any pill but Different clubs ({n})', '{n} on two or more teams', 73)
  ) v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_watch' AND m.tier = v.t);

INSERT INTO schema_migrations (filename) VALUES ('1784-dual-rostering-by-club.sql') ON CONFLICT DO NOTHING;

COMMIT;

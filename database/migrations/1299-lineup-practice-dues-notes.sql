-- 1299 (2026-11-12): Starters & Bench graphic — under each name, practices
-- made + projected / needed for everyone, and dues owed for club admins only.
-- Owner: "we need to show on players number of practices made and projected
-- to make sure everyone can see in lineup graphic (not for insta though)
-- also for me i need to know dues owed. dues:0, dues:52 etc" / "only admin
-- see dues" / shorthand "A:1,P:1 its inferred 2".  On-screen card only (GameCenterScreen._lineupNote, live
-- rosterData); the Instagram export never carries it.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT COALESCE((SELECT category FROM message_templates WHERE kind = 'eligibility' LIMIT 1), 'Eligibility'),
       v.l, 'eligibility', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Lineup graphic note — practices Attended + Projected', 'lineup_note_practice', 'A:{attended} P:{projected}', 900),
    ('Lineup graphic note — dues owed (admins only)',                 'lineup_note_dues',     'Dues:{amount}',                        901)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'eligibility' AND m.tier = v.t);
INSERT INTO schema_migrations (filename) VALUES ('1299-lineup-practice-dues-notes.sql') ON CONFLICT DO NOTHING;
COMMIT;

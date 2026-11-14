-- 1346 (2026-11-13) — 📇 Contact on the Game Center move sheet.
--
-- Owner 2026-11-13: "i need easy way to do this from the graphic right? like
-- i see a starter or bench guy with a certain p: and a: and then i can hit
-- contact from there right? along with switch pos?"  Tapping a man on the
-- live lineup graphic opens the move sheet (mig 454); its first row is now
-- 📇 Contact {player}, its note his practice-criteria row, and it opens his
-- contact popup — 🏃 Practice criteria preselected (mig 1342) when he is
-- short or only projected.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Game Center — move sheet: contact him ({player})', 'lineup_move', 'contact', NULL,
       '📇 Contact {player}', 60, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'lineup_move' AND t.tier = 'contact');

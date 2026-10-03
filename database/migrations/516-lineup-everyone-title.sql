-- 516 — Kids' games: the Starters & Bench pill, card and post read "Lineup".
--
-- Owner 2026-10-03: "hide those chips on kids games and call it lineup".
-- With everyone playing (mig 515) there are no starters and no bench to
-- name; the title is a 'lineup_everyone' copy row like the rest.

BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Game Center', 'Everyone plays — pill / card title', 'lineup_everyone', 'title', NULL, 'Lineup', 4, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_everyone' AND tier = 'title');

COMMIT;

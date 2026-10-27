-- 765 (2026-10-27) — Game Center: swap a 2nd/3rd with the starter from the graphic.
--
-- Owner: "need to be able to swap sub for starter in graphic".  Tapping a
-- sharer's name under a chip (or the starter's chip) offers the swap: the
-- sub takes the starting spot, the starter takes the sub's place in the
-- order (mig 763).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Move sheet — swap a sharer with the starter ({player} {other} {position} {nth})', 'lineup_move', 'share_swap', NULL,
       '⇄ {player} starts at {position} — {other} goes {nth}', 51, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_move' AND tier = 'share_swap');

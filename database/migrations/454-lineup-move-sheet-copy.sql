-- 454 — Game Center lineup: the move sheet's words.
--
-- Owner 2026-09-26: "if i click someone in lineup in graphic we should
-- have popup to move them. have pos grid show and bench and alt and
-- unassign button."
--
-- Tapping a player on the live Starters & Bench graphic used to unassign
-- them outright.  Now it opens the move sheet (game-center.js,
-- _openMoveSheet): the 1-N position grid, then Bench / Alternates /
-- Unassign.  A taken position hands off to the swap sheet (migration
-- 453), a full bench to its bench picker.  Rows here are kind =
-- 'lineup_move', client_side = true; {spot} reuses the lineup_swap
-- spot_* rows, Cancel reuses lineup_swap/cancel.
--
-- Tokens: {player}, {spot} (where they are now), {other} (who holds a
-- position).

CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text,
                                                  p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('lineup_move', 'title',    'Game Center — move sheet: title',            'Move {player}', 1);
SELECT pg_temp.add_client_tpl('lineup_move', 'sub',      'Game Center — move sheet: subtitle',         'Now: {spot}', 2);
SELECT pg_temp.add_client_tpl('lineup_move', 'grid',     'Game Center — move sheet: position grid label', 'Position', 3);
SELECT pg_temp.add_client_tpl('lineup_move', 'taken',    'Game Center — move sheet: taken pill tooltip', '{other} — tap to swap or move them', 4);
SELECT pg_temp.add_client_tpl('lineup_move', 'bench',    'Game Center — move sheet: Bench row',        'Bench', 5);
SELECT pg_temp.add_client_tpl('lineup_move', 'alt',      'Game Center — move sheet: Alternates row',   'Alternates', 6);
SELECT pg_temp.add_client_tpl('lineup_move', 'unassign', 'Game Center — move sheet: Unassign row',     'Unassign', 7);
SELECT pg_temp.add_client_tpl('lineup_move', 'current',  'Game Center — move sheet: note on the current row', 'current', 8);

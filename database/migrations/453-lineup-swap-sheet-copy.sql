-- 453 — Game Center lineup: the swap sheet's words.
--
-- Owner 2026-09-26: "when we click something that is filled … we would
-- have popup saying full and that we need to swap someone … if i click
-- the 6 position and it's not empty it would ask if i want to swap him
-- and caleb or put luke at 6 and caleb to bench or alt."
--
-- Before this, a taken position bumped its holder straight to unassigned
-- with no warning, and a full bench dropped the tap with a toast.  Now an
-- occupied target opens a bottom sheet on #game-center
-- (frontend/js/screens/game-center.js, _openSwapSheet); an empty target
-- is still one tap.  Every word on that sheet is a row here, kind =
-- 'lineup_swap', client_side = true (migration 367), rendered by
-- frontend/js/lib/message-copy.js.
--
-- Tokens: {player} the one being moved, {other} the one in the way,
-- {position} "Centre Midfield", {number} the pill number, {n} a bench
-- slot, {cap} the bench cap, {spot} one of the spot_* rows below.

CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text,
                                                  p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- Position taken (Luke → 6, Caleb there).
SELECT pg_temp.add_client_tpl('lineup_swap', 'position_title', 'Game Center — swap sheet: position taken (title)',
  '{number} · {position} is taken by {other}', 1);
SELECT pg_temp.add_client_tpl('lineup_swap', 'position_sub', 'Game Center — swap sheet: position taken (subtitle)',
  'Where should {other} go so {player} can take it?', 2);
SELECT pg_temp.add_client_tpl('lineup_swap', 'swap', 'Game Center — swap sheet: Swap button',
  'Swap — {other} takes {spot}', 3);
SELECT pg_temp.add_client_tpl('lineup_swap', 'swap_off', 'Game Center — swap sheet: Swap when {player} has no spot',
  '{other} comes off the lineup', 4);
SELECT pg_temp.add_client_tpl('lineup_swap', 'to_bench', 'Game Center — swap sheet: to Bench button',
  '{other} to Bench', 5);
SELECT pg_temp.add_client_tpl('lineup_swap', 'to_alt', 'Game Center — swap sheet: to Alternates button',
  '{other} to Alternates', 6);
SELECT pg_temp.add_client_tpl('lineup_swap', 'bench_full', 'Game Center — swap sheet: greyed to-Bench reason / bench toast',
  'Bench full ({cap} max)', 7);

-- Bench full (Luke → Bench, nine already there).
SELECT pg_temp.add_client_tpl('lineup_swap', 'bench_title', 'Game Center — swap sheet: bench full (title)',
  'Bench is full ({cap} max)', 8);
SELECT pg_temp.add_client_tpl('lineup_swap', 'bench_sub', 'Game Center — swap sheet: bench full (subtitle)',
  'Pick who {player} swaps with:', 9);
SELECT pg_temp.add_client_tpl('lineup_swap', 'bench_row', 'Game Center — swap sheet: bench row (under the name)',
  '#{n} · moves to {spot}', 10);

-- Where a player lands, for {spot}.
SELECT pg_temp.add_client_tpl('lineup_swap', 'spot_position', 'Game Center — swap sheet: {spot} = a position',
  '{number} · {position}', 11);
SELECT pg_temp.add_client_tpl('lineup_swap', 'spot_bench', 'Game Center — swap sheet: {spot} = a bench slot',
  'Bench #{n}', 12);
SELECT pg_temp.add_client_tpl('lineup_swap', 'spot_alt', 'Game Center — swap sheet: {spot} = Alternates',
  'Alternates', 13);
SELECT pg_temp.add_client_tpl('lineup_swap', 'spot_off', 'Game Center — swap sheet: {spot} = no spot',
  'off the lineup', 14);

SELECT pg_temp.add_client_tpl('lineup_swap', 'cancel', 'Game Center — swap sheet: Cancel row',
  'Cancel', 15);

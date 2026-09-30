-- 506 (2026-09-30) — Message everyone from a game, by RSVP.
-- Owner: "i need to be able to email in bulk everyone from a game. diff
-- buttons for those going, going and undecided, then an all button. for
-- every game women too. we can do text version too but that stinks lol on
-- my phone … example use case is game changed to diff day so i need to
-- email all parents of just u8".
--
-- GET /api/game-message/:matchId/recipients (GameMessageController) lists
-- everyone on the game's rosters with their answer and the contact a
-- message reaches them by (parents for youth); the ✉ / 💬 buttons on the
-- squad pills of #game-center hand the chosen group to the shared
-- composer (components/bulk-message-composer.js), which opens Gmail with
-- them in BCC.  These are the panel's words (client_side rows, read
-- through MessageCopy.block('game_message', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('game_message', 'title', 'Message the game — panel title',
  '✉️ Message everyone in this game', 1);
SELECT pg_temp.add_client_tpl('game_message', 'hint', 'Message the game — what the buttons do',
  'Everyone on this game''s rosters — parents for youth players. Pick who, write it once, and Gmail opens with them in BCC (💬 opens Messages instead). Nothing sends until you press Send there.', 2);
SELECT pg_temp.add_client_tpl('game_message', 'group_going', 'Message the game — group: going',
  'Going', 3);
SELECT pg_temp.add_client_tpl('game_message', 'group_going_undecided', 'Message the game — group: going + undecided',
  'Going + undecided', 4);
SELECT pg_temp.add_client_tpl('game_message', 'group_all', 'Message the game — group: everyone',
  'Everyone', 5);
SELECT pg_temp.add_client_tpl('game_message', 'scope', 'Message the game — composer heading',
  '{group} · {game}', 6);
SELECT pg_temp.add_client_tpl('game_message', 'subject', 'Message the game — email subject',
  'Lighthouse 1893 — {game}', 7);

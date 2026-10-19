-- 600 (2026-10-19) — Message the game: include call-ups and potential
-- call-ups.  Owner: "need ability to email or text all parents on the
-- actual u10 and u8 call ups. need to setup carpools and would like to
-- message all whether going or not but can't leave out potentional u8
-- call ups."
--
-- GET /api/game-message/:matchId/recipients now returns three kinds of
-- people (GameMessageController):
--   roster     — on a tagged team's roster (as before)
--   callup     — an open invite to this game (fh_event_invites, mig 355),
--                whatever they answered, or nothing yet
--   candidate  — COULD be invited (fh_event_invite_candidates, mig 355):
--                for a U10 game, every U8/U9 in the club not yet invited
--
-- The #game-center panel's Going / Going+undecided / Everyone groups now
-- cover roster + call-ups, and a fourth button adds the candidates.
-- These are that button's words and the refreshed hint (client_side rows,
-- MessageCopy.block('game_message', tier)).
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Message the game — group: everyone + potential call-ups',
       'game_message', 'group_with_candidates', NULL,
       'Everyone + potential call-ups', 8, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates
                    WHERE kind = 'game_message' AND tier = 'group_with_candidates');

UPDATE message_templates
   SET body = 'Everyone on this game''s rosters AND its call-ups — parents for youth players, whether they answered or not. The last button adds every player who could still be called up. Pick who, write it once, and Gmail opens with them in BCC (💬 opens Messages instead). Nothing sends until you press Send there.'
 WHERE kind = 'game_message' AND tier = 'hint';

UPDATE message_templates
   SET body = 'Everyone (incl. call-ups)'
 WHERE kind = 'game_message' AND tier = 'group_all';

COMMIT;

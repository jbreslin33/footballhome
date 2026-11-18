-- 1470 (2026-11-18) — a group message sent from an event opens naming THAT
-- event (owner: "message a group on an event should focus on that event lol.
-- it can't have custom url but should mention the event in particular").
-- The 📇 group buttons on an event (event-screen.js _onGroupMessage) and
-- Game Center's ✉️ Message everyone (game-center.js _messageGame) used to
-- open an empty box; on a text there is no subject, so nothing said which
-- event it was about.  Now the box starts with this line (editable), no link:
-- group texts can't carry a personal magic link.  {event} = the event as
-- players know it (EventLabels.title + when, never the raw gcal title),
-- {where} = venue / HOME-11v11; {game} = Game Center's "Home vs Away · when".
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT c, l, k, t, NULL, b, o, true, true, false
  FROM (VALUES
    ('Event Center', 'Group contact: message opens with ({event} {where})', 'event_center', 'group_body',
     E'{event}[[ @ {where}]]\n\n', 1201),
    ('System', 'Message everyone: message opens with ({game} {where})', 'game_message', 'body',
     E'{game}[[ @ {where}]]\n\n', 20)
  ) AS v(c, l, k, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
COMMIT;

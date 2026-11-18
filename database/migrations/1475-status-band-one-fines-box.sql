-- 1475 (2026-11-18) — 🚦 Status band: ONE fines box — owed so far + what's at
-- stake.  Owner 11/18: "total fines and chat i am not sure if they should be
-- in yellow?" → "there is nothing to act on current fines" → "i think we
-- should a box with fines. current and new potential".
--
--   ⚖️ Fines $4 so far · +$11 if RSVPs not set   [See ›]
-- Grey (info): answering is the action, and that's the red RSVP box, which
-- no longer carries the money.  The box shows when either number is > 0.
UPDATE message_templates SET body = '⚖️ Fines {amount} so far', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'seg_fines_owed';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Status band — fines box, with what unanswered events would add', 'event_center', 'seg_fines_owed_stake', NULL,
       '⚖️ Fines {amount} so far · +{stake} if RSVPs not set', 1403, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'seg_fines_owed_stake');

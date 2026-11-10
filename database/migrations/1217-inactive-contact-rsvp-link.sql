-- 1217: 💤 Inactive card's 📇 Contact carries his RSVP link (owner
-- 2026-11-10: "christopher moran … he is asking for link i assume to rsvp.
-- when i goto an event and to him and hit contact it should have that as
-- option just like active players … lets not leave stuff out on players"
-- → "on their contact").
--
-- An Inactive man owes no answer, so the 📣 RSVP reminder has nothing to
-- send him.  His way in is the 🎟 invite (fh_event_invites, mig 355): the
-- server writes it with his own sign-in link, and he can mark himself for
-- that event.  Event Center and Game Center now put it first, preselected,
-- in the Contact popup on every 💤 Inactive card — games AND practices
-- (the 🎟 CALL IN button stays for games).  Games keep msg_callup's words;
-- a practice gets its own label below.

BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Contact', 'Contact popup: invite an Inactive player to this practice (his RSVP link)', 'contact_popup', 'msg_callup_practice',
       NULL, '🎟 RSVP link — invite to this practice', 1349, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'contact_popup' AND tier = 'msg_callup_practice');

COMMIT;

-- 604 (2026-10-19) — Dashboard Game Center cell counts call-ups.
-- Owner: "sabres game tonight says 4 of 12 … because i assume call ups
-- its 6 going. this is scary to see 4 of 12. if we invited call ups lets
-- say 12 call ups invited then it should say 6 of 24 right? if we invted
-- 6 call ups then 6 of 18 right?"
--
-- Exactly that: the cell's "{n} going of {of}" now counts the game's OPEN
-- invites (fh_event_invites, mig 355) in both numbers — an invitee joins
-- the denominator the moment the invite is sent, and their Going counts
-- like anyone's.  Potential (uninvited) call-ups count nowhere.  This is
-- the extra line naming how many of the pool are call-ups.
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dashboard', 'Game Center cell — call-ups in the pool ({n})',
       'dashboard', 'gc_callups', NULL, 'incl. {n} call-ups', 865, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'dashboard' AND tier = 'gc_callups');

COMMIT;

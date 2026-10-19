-- 598 (2026-10-19) — Dylan Martinez: every text button goes to his own
-- number.  Owner: "need that number to be the one all his 'text' buttons
-- goto for reminders etc" (2155013619).
--
-- After the mig-597 merge his only phone row IS +12155013619, and the
-- reminder pickers (parent's contact first, then the player's own,
-- is_primary first) already resolve to it.  This pins it: the phone is
-- flagged primary, and a person_self_contacts row (mig 533) marks him
-- self-contacted — its trigger clears parent_person_id on insert and the
-- sync respects the row from then on, so a future LA re-key can't quietly
-- route his reminders to a "parent" again.

UPDATE person_phones
   SET is_primary = true
 WHERE person_id = 22311 AND phone_number = '+12155013619';

INSERT INTO person_self_contacts (person_id, note)
SELECT 22311,
       'mig 598 (owner 2026-10-19): Dylan is 18 and contacts himself at +12155013619 — all reminder/text buttons go to him, never a parent row'
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22311)
ON CONFLICT (person_id) DO NOTHING;

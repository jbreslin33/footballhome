-- 368 — Drop the "starting Aug 7 LeagueApps will auto-charge…" dues note.
--
-- Migration 367 carried it over from the hardcoded PAY copy as an inactive
-- dues_note row because the date had passed.  Owner 2026-09-17: "drop it."
-- Removes the row and the optional {note} slot from the dues templates.
DELETE FROM message_templates WHERE kind = 'dues_note';

UPDATE message_templates
   SET body = replace(replace(body, '[[ {note}]]', ''), E'[[{note}\n\n]]', ''),
       updated_at = now()
 WHERE kind IN ('dues_sms', 'dues_email') AND body LIKE '%{note}%';

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM message_templates WHERE body LIKE '%{note}%';
  IF n <> 0 THEN RAISE EXCEPTION 'migration 368: % template(s) still reference {note}', n; END IF;
END $$;

-- 1214: youth dues notices — why dues matter, not a release threat.
--
-- The release-policy notices (285-290, sent to youth since mig 1149/1152)
-- warned "Reaching {pause_amount} owed … could lead shortly to release from
-- the team roster" / "This could lead shortly to release from the team
-- roster." James: just let them know it's important to running the club.
-- Each tier now says what dues pay for instead; amount owed + pay link stay.

BEGIN;

UPDATE message_templates SET body = replace(body,
  'Reaching {pause_amount} owed[[ (for you that would be {pause_date})]] could lead shortly to release from the team roster.',
  'Dues are what keep the club running — fields, referees, league fees and coaches for every player.'),
  updated_at = now() WHERE id IN (285, 288);

UPDATE message_templates SET body = replace(body,
  'This could lead shortly to release from the team roster.',
  'Dues are what keep the club running — fields, referees, league fees and coaches for every player.'),
  updated_at = now() WHERE id IN (286, 287, 289, 290);

DO $$
DECLARE bad text;
BEGIN
  SELECT string_agg(id::text, ', ') INTO bad
    FROM message_templates
   WHERE id IN (285, 286, 287, 288, 289, 290)
     AND (body ~* '(release|pause_amount|pause_date)'
          OR body !~ 'Dues are what keep the club running');
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '1214: youth dues copy not rewritten for ids %', bad;
  END IF;
END $$;

COMMIT;

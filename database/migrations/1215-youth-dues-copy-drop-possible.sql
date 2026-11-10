-- 1215: youth dues notices — say that dropping from the program is possible.
--
-- After 1214's "Dues are what keep the club running …" line, every youth
-- (release-policy) notice, email + text, adds one soft sentence:
-- "If dues stay unpaid, a player can be dropped from the program."

BEGIN;

UPDATE message_templates SET body = replace(body,
  'Dues are what keep the club running — fields, referees, league fees and coaches for every player.',
  'Dues are what keep the club running — fields, referees, league fees and coaches for every player. If dues stay unpaid, a player can be dropped from the program.'),
  updated_at = now()
 WHERE id IN (285, 286, 287, 288, 289, 290)
   AND body !~ 'dropped from the program';

DO $$
DECLARE bad text;
BEGIN
  SELECT string_agg(id::text, ', ') INTO bad
    FROM message_templates
   WHERE id IN (285, 286, 287, 288, 289, 290)
     AND body !~ 'If dues stay unpaid, a player can be dropped from the program\.';
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION '1215: drop sentence missing for ids %', bad;
  END IF;
END $$;

COMMIT;

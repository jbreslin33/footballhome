-- 🏟 Turf proposals: a league COULD rent, not would (James 11/23 "couild
-- instead of would"). The four renter sentences only.
BEGIN;
UPDATE proposal_sections s SET body = replace(replace(replace(s.body,
  'sports league would rent', 'sports league could rent'),
  'A league would rent in fall', 'A league could rent in fall'),
  'sports league would pay', 'sports league could pay')
FROM proposals p WHERE p.id = s.proposal_id AND p.code IN ('turf-mini-pitch', 'field-turf-pitches');
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code IN ('turf-mini-pitch', 'field-turf-pitches') AND s.body ~ '(league|League) would (rent|pay)';
  IF n <> 0 THEN RAISE EXCEPTION '% sections still say a league would rent or pay', n; END IF;
END $$;
COMMIT;

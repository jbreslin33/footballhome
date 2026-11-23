-- 🏟 Turf proposals: the renter is CASA, Heyday or a similar sports league,
-- not CASA alone (James 11/23 "casa or hey dey or similiar sports league").
BEGIN;
UPDATE proposal_sections s SET body = replace(replace(s.body,
  'CASA would rent the mini pitch for league nights,', 'CASA, Heyday or a similar sports league would rent the mini pitch for league nights,'),
  'CASA would rent in fall, spring and summer, not in winter,', 'A league would rent in fall, spring and summer, not in winter,')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';
UPDATE proposal_sections s SET body = replace(s.body,
  '- **It can earn rent.** CASA would pay $100–$150 an hour', '- **It can earn rent.** CASA, Heyday or a similar sports league would pay $100–$150 an hour')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;
UPDATE proposal_sections s SET body = replace(s.body,
  'CASA would rent in fall, spring and summer, not in winter.', 'CASA, Heyday or a similar sports league would rent in fall, spring and summer, not in winter.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.heading = 'Rental potential';
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code IN ('turf-mini-pitch', 'field-turf-pitches') AND s.body LIKE '%CASA, Heyday or a similar sports league%';
  IF n <> 3 THEN RAISE EXCEPTION 'renter wording in % of 3 sections', n; END IF;
END $$;
COMMIT;

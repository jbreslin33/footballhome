-- 🏟 Turf proposals: a rental year is 21 nights, skipping winter (James 11/23
-- "year 21 days skipping winter for rentals"). Column heads and the
-- sentences say so; figures unchanged.
BEGIN;
UPDATE proposal_sections s SET body = replace(replace(s.body,
  '|League nights a week|One season (7 nights)|A year: fall, spring and summer',
  '|League nights a week|One season (7 nights)|A year (21 nights each, skipping winter)'),
  'One Monday league across fall, spring and summer is 21 three-hour rentals a year, 7 pm to 10 pm:',
  'One Monday league is 21 three-hour rentals a year, 7 pm to 10 pm, skipping winter:')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';
UPDATE proposal_sections s SET body = replace(s.body,
  'one league night across fall, spring and summer is 21 three-hour rentals a year, about $8,946',
  'one league night is 21 three-hour rentals a year, skipping winter, about $8,946')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;
UPDATE proposal_sections s SET body = replace(s.body,
  '|Pitch|Going rate an hour|A night (3 hours)|One season (7 nights)|Fall, spring and summer',
  '|Pitch|Going rate an hour|A night (3 hours)|One season (7 nights)|A year (21 nights, skipping winter)')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.heading = 'Rental potential';
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code IN ('turf-mini-pitch', 'field-turf-pitches') AND s.body LIKE '%skipping winter%';
  IF n <> 3 THEN RAISE EXCEPTION 'skipping winter in % of 3 sections', n; END IF;
END $$;
COMMIT;

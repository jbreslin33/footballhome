-- 🏟 Turf Mini Pitch: the rental sum spelled out (James 11/23 "so like 21 3
-- hour rentals per year. 7 to 10pm on mondays at variable rate you found").
-- 21 Monday nights × 3 hours = 63 hours: $6,300–$9,450 at CASA's $100–$150,
-- $8,946 at the $142 going rate found at Sofive.
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'One Monday league across fall, spring and summer brings in $6,300–$9,450 a year.',
  'One Monday league across fall, spring and summer is 21 three-hour rentals a year, 7 pm to 10 pm: $6,300–$9,450 at $100–$150 an hour, or **$8,946** at the $142 going rate.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';
UPDATE proposal_sections s SET body = replace(s.body,
  '$6,300–$9,450 a year for one league night across fall, spring and summer, and three times that for three nights.',
  'one league night across fall, spring and summer is 21 three-hour rentals a year, about $8,946 at the $142 going rate.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;
DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'turf-mini-pitch' AND s.body LIKE '%21 three-hour rentals a year%';
  IF n <> 2 THEN RAISE EXCEPTION 'mini pitch: 21 rentals line in % of 2 sections', n; END IF;
END $$;
COMMIT;

-- 🏟 Turf proposals: rental potential = Monday and Sunday nights, nothing
-- else (James 11/23 "do monday and sunday nights" + "leavbe out rest").
-- Two league nights, 7 nights a season each, skipping winter: 21 nights
-- each, 42 nights (126 hours) a year together. The 2/3/5-nights-a-week rows
-- are gone. Mini pitch: $12,600–$18,900 at $100–$150 an hour, $17,892 at the
-- $142 going rate. Field pitches: rate × 126 hours.

BEGIN;

UPDATE proposal_sections s SET body = $b$CASA, Heyday or a similar sports league could rent the mini pitch on Monday and Sunday nights, with games from 7 pm to 10 pm, at **$100–$150 an hour**. That is three hours, $300–$450, a night. The lights that are already there make those hours possible.
That is the going rate: Sofive in Elkins Park charges **$142 an hour** for an outdoor 5v5 turf field on a weekday evening (Monday 8 to 9 pm, fees included, [Sofive booking page](https://webapp.sofive.com/rent), read November 23, 2026).
A league could rent in fall, spring and summer, not in winter, with about 7 game nights a season: 21 nights a year for each league night.
|League night|One season (7 nights)|A year (21 nights, skipping winter)|A year at the $142 going rate
|Monday|$2,100–$3,150|$6,300–$9,450|$8,946
|Sunday|$2,100–$3,150|$6,300–$9,450|$8,946
|**Monday and Sunday**|**$4,200–$6,300**|**$12,600–$18,900**|**$17,892**
Monday and Sunday together are 42 three-hour rentals a year. At the going rate that is $17,892, more than low-end turf inside the poles costs when we lay it ourselves ($16,835).
If the pitch is rented, the turf stays down through fall, spring and summer, so basketball has to move to another spot.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';

UPDATE proposal_sections s SET body = replace(s.body,
  'could pay $100–$150 an hour for league nights, 7 pm to 10 pm: one league night is 21 three-hour rentals a year, skipping winter, about $8,946 at the $142 going rate.',
  'could pay $100–$150 an hour for Monday and Sunday league nights, 7 pm to 10 pm: 42 three-hour rentals a year, skipping winter, about $17,892 at the $142 going rate.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  $a$What each pitch could earn from one league night, at the going rate. A league night is one evening of the week, 7 pm to 10 pm, with about 7 game nights a season; CASA, Heyday or a similar sports league could rent in fall, spring and summer, not in winter. Evening rental needs the lights add-on.
|Pitch|Going rate an hour|A night (3 hours)|One season (7 nights)|A year (21 nights, skipping winter)
|5v5|$142|$426|$2,982|$8,946
|7v7|$157.50|$472.50|$3,307.50|$9,922.50
|9v9|$200|$600|$4,200|$12,600
|Full|$250|$750|$5,250|$15,750
Each extra league night in the week adds the same again.$a$,
  $b$What each pitch could earn from Monday and Sunday league nights, at the going rate. Games run 7 pm to 10 pm, with about 7 game nights a season for each night; CASA, Heyday or a similar sports league could rent in fall, spring and summer, not in winter. Evening rental needs the lights add-on.
|Pitch|Going rate an hour|A night (3 hours)|A year, Monday (21 nights)|A year, Monday and Sunday (42 nights)
|5v5|$142|$426|$8,946|$17,892
|7v7|$157.50|$472.50|$9,922.50|$19,845
|9v9|$200|$600|$12,600|$25,200
|Full|$250|$750|$15,750|$31,500$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.heading = 'Rental potential';

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE (p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential' AND s.body LIKE '%|**Monday and Sunday**|%')
      OR (p.code = 'turf-mini-pitch' AND s.sort_order = 1 AND s.body LIKE '%42 three-hour rentals a year%')
      OR (p.code = 'field-turf-pitches' AND s.heading = 'Rental potential' AND s.body LIKE '%|Full|$250|$750|$15,750|$31,500%');
  IF n <> 3 THEN RAISE EXCEPTION 'monday and sunday: % of 3 updated', n; END IF;
END $$;

COMMIT;

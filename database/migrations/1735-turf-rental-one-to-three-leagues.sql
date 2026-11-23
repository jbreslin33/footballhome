-- 🏟 Turf proposals: rental potential as 1 to 3 leagues (James 11/23 "so 1
-- to 3 'leaguess'"). A league takes one slot of the week (Monday night,
-- Saturday or Sunday): a three-hour block, 7 dates a season, 21 a year
-- skipping winter. Rows / columns are 1, 2 and 3 leagues; figures as mig 1734.

BEGIN;

UPDATE proposal_sections s SET body = $b$One to three leagues could rent the mini pitch: CASA, Heyday or a similar sports league, each taking one slot of the week. The slots are Monday night, 7 pm to 10 pm, Saturday and Sunday. The rate is **$100–$150 an hour**, so a three-hour block is $300–$450. The lights that are already there make the evening hours possible.
That is the going rate: Sofive in Elkins Park charges **$142 an hour** for an outdoor 5v5 turf field on a weekday evening (Monday 8 to 9 pm, fees included, [Sofive booking page](https://webapp.sofive.com/rent), read November 23, 2026).
A league could rent in fall, spring and summer, not in winter, with about 7 dates a season: 21 three-hour rentals a year.
|Leagues|Rentals a year|A year at $100–$150 an hour|A year at the $142 going rate
|1 league|21|$6,300–$9,450|$8,946
|2 leagues|42|$12,600–$18,900|$17,892
|3 leagues|63|$18,900–$28,350|$26,838
Two leagues at the going rate bring in more in a year than low-end turf inside the poles costs when we lay it ourselves ($16,835). Three leagues bring in close to the cost of mid-range turf ($28,490).
If the pitch is rented, the turf stays down through fall, spring and summer, so basketball has to move to another spot.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';

UPDATE proposal_sections s SET body = replace(s.body,
  'could pay $100–$150 an hour for Monday nights and Saturdays and Sundays: 63 three-hour rentals a year, skipping winter, about $26,838 at the $142 going rate.',
  'could pay $100–$150 an hour. One to three leagues, on Monday nights, Saturdays and Sundays, skipping winter: $8,946 to $26,838 a year at the $142 going rate.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  $a$What each pitch could earn from league play on Monday nights, 7 pm to 10 pm, and on Saturdays and Sundays, at the going rate: a three-hour block each, with about 7 dates a season for each day. CASA, Heyday or a similar sports league could rent in fall, spring and summer, not in winter. Monday night rental needs the lights add-on.
|Pitch|Going rate an hour|A three-hour block|A year, one day (21 dates)|A year, Monday, Saturday and Sunday (63 dates)
|5v5|$142|$426|$8,946|$26,838
|7v7|$157.50|$472.50|$9,922.50|$29,767.50
|9v9|$200|$600|$12,600|$37,800
|Full|$250|$750|$15,750|$47,250$a$,
  $b$What each pitch could earn from one to three leagues, at the going rate. Each league takes one slot of the week (Monday night, 7 pm to 10 pm, Saturday or Sunday): a three-hour block, about 7 dates a season, 21 rentals a year. CASA, Heyday or a similar sports league could rent in fall, spring and summer, not in winter. Monday night rental needs the lights add-on.
|Pitch|Going rate an hour|1 league, a year|2 leagues, a year|3 leagues, a year
|5v5|$142|$8,946|$17,892|$26,838
|7v7|$157.50|$9,922.50|$19,845|$29,767.50
|9v9|$200|$12,600|$25,200|$37,800
|Full|$250|$15,750|$31,500|$47,250$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.heading = 'Rental potential';

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE (p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential' AND s.body LIKE '%|3 leagues|63|$18,900–$28,350|$26,838%')
      OR (p.code = 'turf-mini-pitch' AND s.sort_order = 1 AND s.body LIKE '%One to three leagues, on Monday nights%')
      OR (p.code = 'field-turf-pitches' AND s.heading = 'Rental potential' AND s.body LIKE '%|Full|$250|$15,750|$31,500|$47,250%');
  IF n <> 3 THEN RAISE EXCEPTION 'one to three leagues: % of 3 updated', n; END IF;
END $$;

COMMIT;

-- 🏟 Turf proposals: rental potential = Monday nights plus Saturdays and
-- Sundays (James 11/23 "actually monday nights and saturday and sundays").
-- Three league slots, a three-hour block each, 7 a season, skipping winter:
-- 21 each, 63 rentals (189 hours) a year. Mini pitch: $18,900–$28,350 at
-- $100–$150 an hour, $26,838 at the $142 going rate. Field pitches: rate ×
-- 189 hours. The Saturday and Sunday blocks are assumed to be three hours,
-- like Monday night.

BEGIN;

UPDATE proposal_sections s SET body = $b$CASA, Heyday or a similar sports league could rent the mini pitch on Monday nights, 7 pm to 10 pm, and on Saturdays and Sundays, at **$100–$150 an hour**. A three-hour block is $300–$450. The lights that are already there make the evening hours possible.
That is the going rate: Sofive in Elkins Park charges **$142 an hour** for an outdoor 5v5 turf field on a weekday evening (Monday 8 to 9 pm, fees included, [Sofive booking page](https://webapp.sofive.com/rent), read November 23, 2026).
A league could rent in fall, spring and summer, not in winter, with about 7 dates a season: 21 a year for each day.
|League day|One season (7 dates)|A year (21 dates, skipping winter)|A year at the $142 going rate
|Monday night|$2,100–$3,150|$6,300–$9,450|$8,946
|Saturday|$2,100–$3,150|$6,300–$9,450|$8,946
|Sunday|$2,100–$3,150|$6,300–$9,450|$8,946
|**All three**|**$6,300–$9,450**|**$18,900–$28,350**|**$26,838**
All three together are 63 three-hour rentals a year. At the going rate that is $26,838, close to what mid-range turf inside the poles costs when we lay it ourselves ($28,490).
If the pitch is rented, the turf stays down through fall, spring and summer, so basketball has to move to another spot.$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';

UPDATE proposal_sections s SET body = replace(s.body,
  'could pay $100–$150 an hour for Monday and Sunday league nights, 7 pm to 10 pm: 42 three-hour rentals a year, skipping winter, about $17,892 at the $142 going rate.',
  'could pay $100–$150 an hour for Monday nights and Saturdays and Sundays: 63 three-hour rentals a year, skipping winter, about $26,838 at the $142 going rate.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  $a$What each pitch could earn from Monday and Sunday league nights, at the going rate. Games run 7 pm to 10 pm, with about 7 game nights a season for each night; CASA, Heyday or a similar sports league could rent in fall, spring and summer, not in winter. Evening rental needs the lights add-on.
|Pitch|Going rate an hour|A night (3 hours)|A year, Monday (21 nights)|A year, Monday and Sunday (42 nights)
|5v5|$142|$426|$8,946|$17,892
|7v7|$157.50|$472.50|$9,922.50|$19,845
|9v9|$200|$600|$12,600|$25,200
|Full|$250|$750|$15,750|$31,500$a$,
  $b$What each pitch could earn from league play on Monday nights, 7 pm to 10 pm, and on Saturdays and Sundays, at the going rate: a three-hour block each, with about 7 dates a season for each day. CASA, Heyday or a similar sports league could rent in fall, spring and summer, not in winter. Monday night rental needs the lights add-on.
|Pitch|Going rate an hour|A three-hour block|A year, one day (21 dates)|A year, Monday, Saturday and Sunday (63 dates)
|5v5|$142|$426|$8,946|$26,838
|7v7|$157.50|$472.50|$9,922.50|$29,767.50
|9v9|$200|$600|$12,600|$37,800
|Full|$250|$750|$15,750|$47,250$b$)
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.heading = 'Rental potential';

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE (p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential' AND s.body LIKE '%|**All three**|%')
      OR (p.code = 'turf-mini-pitch' AND s.sort_order = 1 AND s.body LIKE '%63 three-hour rentals a year%')
      OR (p.code = 'field-turf-pitches' AND s.heading = 'Rental potential' AND s.body LIKE '%|Full|$250|$750|$15,750|$47,250%');
  IF n <> 3 THEN RAISE EXCEPTION 'monday saturday sunday: % of 3 updated', n; END IF;
END $$;

COMMIT;

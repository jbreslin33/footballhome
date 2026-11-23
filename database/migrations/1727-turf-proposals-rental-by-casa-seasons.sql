-- 🏟 Turf proposals: rental potential on CASA's real pattern (James 11/23
-- "casa runs 4 seassons a year. assum like 7 rentals from each for each
-- 'day' of week. so league would be Monday night at LH. would run Fall,
-- Spring, summer"). A league night = one weekday evening, 7 pm to 10 pm
-- (3 hours), about 7 nights a season. Replaces the "nights a week × 20
-- weeks" tables of migs 1723 and 1726.
-- Mini pitch, $100–$150 an hour: one league night = $2,100–$3,150 a season,
-- $6,300–$9,450 over fall, spring and summer, $8,400–$12,600 over all four.
-- Field pitches, going rate × 21 hours a season, × 63 over three seasons.

BEGIN;

UPDATE proposal_sections s SET body = $b$CASA would rent the mini pitch for league nights, with games from 7 pm to 10 pm, at **$100–$150 an hour**. That is three hours, $300–$450, a night. The lights that are already there make those hours possible.
That is the going rate: Sofive in Elkins Park charges **$142 an hour** for an outdoor 5v5 turf field on a weekday evening (Monday 8 to 9 pm, fees included, [Sofive booking page](https://webapp.sofive.com/rent), read November 23, 2026).
CASA runs four seasons a year, with about 7 game nights a season for each league night. A league night is one evening of the week, for example Monday night at Lighthouse. The leagues here would run in fall, spring and summer.
|League nights a week|One season (7 nights)|Fall, spring and summer|All four seasons
|1 (Monday)|$2,100–$3,150|$6,300–$9,450|$8,400–$12,600
|2|$4,200–$6,300|$12,600–$18,900|$16,800–$25,200
|3|$6,300–$9,450|$18,900–$28,350|$25,200–$37,800
|5|$10,500–$15,750|$31,500–$47,250|$42,000–$63,000
One Monday league across fall, spring and summer brings in $6,300–$9,450 a year. Three league nights bring in $18,900–$28,350 a year, about what mid-range turf inside the poles costs when we lay it ourselves ($28,490).$b$
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';

UPDATE proposal_sections s SET body = replace(s.body,
  '- **It can earn rent.** CASA would pay $100–$150 an hour for league nights, 7 pm to 10 pm: $18,000–$27,000 over a November-to-March season at three nights a week.',
  '- **It can earn rent.** CASA would pay $100–$150 an hour for league nights, 7 pm to 10 pm: $6,300–$9,450 a year for one league night across fall, spring and summer, and three times that for three nights.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(replace(s.body,
  $a$What each pitch could earn in evening rentals, at the going rate, for a league playing 7 pm to 10 pm. Evening rental needs the lights add-on.
|Pitch|Going rate an hour|A night (3 hours)|3 nights a week for 20 weeks
|5v5|$142|$426|$25,560
|7v7|$157.50|$472.50|$28,350
|9v9|$200|$600|$36,000
|Full|$250|$750|$45,000$a$,
  $b$What each pitch could earn from one league night, at the going rate. A league night is one evening of the week, 7 pm to 10 pm, with about 7 game nights a season; CASA runs four seasons a year, and the leagues here would run in fall, spring and summer. Evening rental needs the lights add-on.
|Pitch|Going rate an hour|A night (3 hours)|One season (7 nights)|Fall, spring and summer
|5v5|$142|$426|$2,982|$8,946
|7v7|$157.50|$472.50|$3,307.50|$9,922.50
|9v9|$200|$600|$4,200|$12,600
|Full|$250|$750|$5,250|$15,750
Each extra league night in the week adds the same again.$b$),
  'Each pitch can also earn rent', 'Each pitch can also earn rent')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.heading = 'Rental potential';

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE (p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential' AND s.body LIKE '%|1 (Monday)|$2,100–$3,150|$6,300–$9,450|$8,400–$12,600%')
      OR (p.code = 'turf-mini-pitch' AND s.sort_order = 1 AND s.body LIKE '%$6,300–$9,450 a year for one league night%')
      OR (p.code = 'field-turf-pitches' AND s.heading = 'Rental potential' AND s.body LIKE '%|Full|$250|$750|$5,250|$15,750%');
  IF n <> 3 THEN RAISE EXCEPTION 'rental by season: % of 3 updated', n; END IF;
END $$;

COMMIT;

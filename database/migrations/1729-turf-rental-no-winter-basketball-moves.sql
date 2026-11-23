-- 🏟 Turf proposals: CASA would not rent in winter, and renting means
-- basketball moves (James 11/23 "they wouldn't do winter for casa.
-- basketball would have to move to another spot of we rent"). Mini pitch:
-- the "All four seasons" column goes; the section and the summary say that
-- with leagues in fall, spring and summer the turf stays down and basketball
-- moves to another spot. Field pitches: fall, spring and summer only.

BEGIN;

UPDATE proposal_sections s SET body = replace(replace(replace(replace(replace(replace(s.body,
  'CASA runs four seasons a year, with about 7 game nights a season for each league night. A league night is one evening of the week, for example Monday night at Lighthouse. The leagues here would run in fall, spring and summer.',
  'CASA would rent in fall, spring and summer, not in winter, with about 7 game nights a season for each league night. A league night is one evening of the week, for example Monday night at Lighthouse.'),
  '|League nights a week|One season (7 nights)|Fall, spring and summer|All four seasons', '|League nights a week|One season (7 nights)|A year: fall, spring and summer'),
  '|1 (Monday)|$2,100–$3,150|$6,300–$9,450|$8,400–$12,600', '|1 (Monday)|$2,100–$3,150|$6,300–$9,450'),
  '|2|$4,200–$6,300|$12,600–$18,900|$16,800–$25,200', '|2|$4,200–$6,300|$12,600–$18,900'),
  '|3|$6,300–$9,450|$18,900–$28,350|$25,200–$37,800', '|3|$6,300–$9,450|$18,900–$28,350'),
  '|5|$10,500–$15,750|$31,500–$47,250|$42,000–$63,000', '|5|$10,500–$15,750|$31,500–$47,250')
  || E'\nIf the pitch is rented, the turf stays down through fall, spring and summer, so basketball has to move to another spot.'
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential'
  AND s.body NOT LIKE '%basketball has to move to another spot%';

UPDATE proposal_sections s SET body = replace(s.body,
  'Or the turf stays down all year and the basketball court is moved somewhere else.',
  'Or the turf stays down all year and the basketball court is moved somewhere else; that is what renting the pitch for leagues in fall, spring and summer would need.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(s.body,
  'with about 7 game nights a season; CASA runs four seasons a year, and the leagues here would run in fall, spring and summer.',
  'with about 7 game nights a season; CASA would rent in fall, spring and summer, not in winter.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.heading = 'Rental potential';

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE (p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential' AND s.body NOT LIKE '%four seasons%'
            AND s.body LIKE '%basketball has to move to another spot.%' AND s.body LIKE '%|1 (Monday)|$2,100–$3,150|$6,300–$9,450' || E'\n' || '%')
      OR (p.code = 'turf-mini-pitch' AND s.sort_order = 1 AND s.body LIKE '%that is what renting the pitch for leagues%')
      OR (p.code = 'field-turf-pitches' AND s.heading = 'Rental potential' AND s.body LIKE '%not in winter.%');
  IF n <> 3 THEN RAISE EXCEPTION 'no winter: % of 3 updated', n; END IF;
END $$;

COMMIT;

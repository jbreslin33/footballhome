-- 🏟 Turf Field Pitches: the Full pitch's seating follows the U.S. Soccer Pro
-- League Standards (James 11/23 "div 3 seating at first with space to expand
-- to d1 us soccer pls standard"). Package 4 Stadium = Division III seating,
-- 1,000 seats (was 500), with room left around the pitch to grow to the
-- Division I minimum of 15,000. Bleachers 1,000 × $150 = $150,000 (was
-- $75,000): package 4 = $1,528,373 + $150,000 + $10,000 + $15,000 = $1,703,373.

BEGIN;

UPDATE proposals SET summary = replace(summary, '$1,628,373', '$1,703,373') WHERE code = 'field-turf-pitches';

UPDATE proposal_sections s SET body = replace(s.body,
  'up to **$1,628,373** (Full, fenced and lit, with seating).',
  'up to **$1,703,373** (Full, fenced and lit, with Division III seating for 1,000 and room to expand to Division I).')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 1;

UPDATE proposal_sections s SET body = replace(replace(replace(replace(s.body,
  '|$1,528,373|$1,628,373', '|$1,528,373|$1,703,373'),
  '**Package 4, Stadium (Full only):** package 3 plus bleachers for 500, two team shelters and a scoreboard.',
  '**Package 4, Stadium (Full only):** package 3 plus seating to the U.S. Soccer Pro League Standards for Division III, 1,000 seats, two team shelters and a scoreboard. The seating is laid out with room left around the pitch to expand to the Division I standard of 15,000 seats.'),
  '|Bleachers|500 seats × $150, estimate|$75,000', '|Bleachers, Division III standard|1,000 seats × $150, estimate|$150,000'),
  '|**Package 4 total: Stadium**||**$1,628,373**', '|**Package 4 total: Stadium**||**$1,703,373**')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 4;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'field-turf-pitches' AND (
        (s.sort_order = 1 AND s.body LIKE '%**$1,703,373**%')
     OR (s.sort_order = 4 AND s.body LIKE '%|$1,528,373|$1,703,373%' AND s.body LIKE '%Division I standard of 15,000 seats%'
         AND s.body LIKE '%1,000 seats × $150, estimate|$150,000%' AND s.body LIKE '%**Package 4 total: Stadium**||**$1,703,373**%'
         AND s.body NOT LIKE '%1,628,373%'));
  IF n <> 2 THEN RAISE EXCEPTION 'field pitches: % of 2 sections updated', n; END IF;
END $$;

COMMIT;

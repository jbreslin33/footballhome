-- 🏟 Turf Mini Pitch: rental potential (James 11/23 "we need to add in rental
-- potential too. going rate for mini turf rental. casa would pay $100-$150
-- an hour to rent for a league that has games starting at 7pm to 10 pm").
-- New section "Rental potential" after Costs: 3 hours a night at $100–$150 =
-- $300–$450 a night; by league nights a week, per week and over the 20 weeks
-- November to March. One bullet in the summary.

BEGIN;

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 6, 'Rental potential', $b$CASA would rent the mini pitch for a league with games from 7 pm to 10 pm, at **$100–$150 an hour**. That is three hours, $300–$450, a night. The lights that are already there make those hours possible.
|League nights a week|A week|November to March (20 weeks)
|1|$300–$450|$6,000–$9,000
|2|$600–$900|$12,000–$18,000
|3|$900–$1,350|$18,000–$27,000
|5|$1,500–$2,250|$30,000–$45,000
Three nights a week for one November-to-March season brings in $18,000–$27,000, about what mid-range turf inside the poles costs when we lay it ourselves ($28,490).$b$
FROM proposals p WHERE p.code = 'turf-mini-pitch'
  AND NOT EXISTS (SELECT 1 FROM proposal_sections s WHERE s.proposal_id = p.id AND s.heading = 'Rental potential');

UPDATE proposal_sections s SET body = replace(s.body,
  E'\n- **It rests the grass field and extends training** into late fall, winter and early spring.',
  E'\n- **It can earn rent.** CASA would pay $100–$150 an hour for league nights, 7 pm to 10 pm: $18,000–$27,000 over a November-to-March season at three nights a week.\n- **It rests the grass field and extends training** into late fall, winter and early spring.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'turf-mini-pitch' AND ((s.sort_order = 6 AND s.heading = 'Rental potential')
      OR (s.sort_order = 1 AND s.body LIKE '%**It can earn rent.**%'));
  IF n <> 2 THEN RAISE EXCEPTION 'mini pitch: rental potential in % of 2 places', n; END IF;
END $$;

COMMIT;

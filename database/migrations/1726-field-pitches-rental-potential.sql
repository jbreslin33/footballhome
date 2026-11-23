-- 🏟 Turf Field Pitches: rental potential (James 11/23 "add rental potential
-- to the field pitches proposal too"). New section after Costs; Upkeep and
-- Decisions move down (sort_order 5 → 7, 6 → 8).
-- Hourly rates: 5v5 $142 and 7v7 $157.50 are Sofive Elkins Park's outdoor
-- 5v5 and 6v6 prices, read on its booking page 11/23/2026 (Monday 8–9 pm,
-- fees included). Full $250 is a published outdoor turf field rate (The
-- Training Center PA); 9v9 $200 is an estimate between the two. For
-- comparison the City of Philadelphia rents its premium artificial turf
-- fields to adult groups at $350 for up to four hours (2024 fee schedule).
-- A night = 3 hours, as in the mini pitch proposal (7 to 10 pm).

BEGIN;

UPDATE proposal_sections s SET sort_order = 8 FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 6 AND s.heading = 'Decisions';
UPDATE proposal_sections s SET sort_order = 7 FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 5 AND s.heading = 'Upkeep';

INSERT INTO proposal_sections (proposal_id, sort_order, heading, body)
SELECT p.id, 5, 'Rental potential', $b$What each pitch could earn in evening rentals, at the going rate, for a league playing 7 pm to 10 pm. Evening rental needs the lights add-on.
|Pitch|Going rate an hour|A night (3 hours)|3 nights a week for 20 weeks
|5v5|$142|$426|$25,560
|7v7|$157.50|$472.50|$28,350
|9v9|$200|$600|$36,000
|Full|$250|$750|$45,000
**Where the rates come from.** 5v5 and 7v7: Sofive in Elkins Park charges $142 an hour for an outdoor 5v5 turf field and $157.50 for an outdoor 6v6, on a weekday evening, fees included ([Sofive booking page](https://webapp.sofive.com/rent), read November 23, 2026). Full: $250 an hour is a published rate for an outdoor turf field ([The Training Center PA](https://thetrainingcenterpa.com/fieldcourt-rentals/)). 9v9: an estimate between those. For comparison, the City of Philadelphia rents its premium artificial turf fields to adult groups at $350 for up to four hours ([2024 fee schedule](https://www.phila.gov/media/20240213112044/Athletic-Fee-Schedule-2024.pdf)).$b$
FROM proposals p WHERE p.code = 'field-turf-pitches'
  AND NOT EXISTS (SELECT 1 FROM proposal_sections s WHERE s.proposal_id = p.id AND s.heading = 'Rental potential');

UPDATE proposal_sections s SET body = replace(s.body,
  'Prices are estimates from published figures, not quotes.',
  'Prices are estimates from published figures, not quotes. Each pitch can also earn rent: $142 to $250 an hour at the going rate, depending on size.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'field-turf-pitches' AND s.sort_order = 1;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'field-turf-pitches' AND ((s.sort_order = 5 AND s.heading = 'Rental potential')
      OR (s.sort_order = 7 AND s.heading = 'Upkeep') OR (s.sort_order = 8 AND s.heading = 'Decisions')
      OR (s.sort_order = 1 AND s.body LIKE '%Each pitch can also earn rent%'));
  IF n <> 4 THEN RAISE EXCEPTION 'field pitches: rental potential, % of 4 checks', n; END IF;
END $$;

COMMIT;

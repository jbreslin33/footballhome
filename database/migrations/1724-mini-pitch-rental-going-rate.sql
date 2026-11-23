-- 🏟 Turf Mini Pitch: the going rate behind the rental figure (James 11/23
-- "check going rate for turf rental at sofive etc" + "granted ours is
-- outdoor"). Read on Sofive's booking page 11/23/2026: Sofive Elkins Park,
-- Adult Soccer, 5v5 Outdoor, Monday 8:00–9:00 PM, $142.00, fees included.
-- That sits inside CASA's $100–$150 an hour.
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'The lights that are already there make those hours possible.',
  E'The lights that are already there make those hours possible.\nThat is the going rate: Sofive in Elkins Park charges **$142 an hour** for an outdoor 5v5 turf field on a weekday evening (Monday 8 to 9 pm, fees included, [Sofive booking page](https://webapp.sofive.com/rent), read November 23, 2026).')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential';
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'turf-mini-pitch' AND s.heading = 'Rental potential' AND s.body LIKE '%**$142 an hour**%') THEN
    RAISE EXCEPTION 'mini pitch: going rate not added';
  END IF;
END $$;
COMMIT;

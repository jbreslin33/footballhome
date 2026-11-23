-- 🏟 Erie Avenue turf proposal: the Sixers Youth Foundation is not a funder
-- or a contact (James 11/23 "we would not try to get funding for turf from
-- them lol they would not like that. i assume they wouldn't even know about
-- it"). Their row leaves Funding, the "talk to" step leaves the Timeline, and
-- the open question becomes an in-house check of The Light House's own 2019
-- paperwork. The site note (they list the court as renovated in 2019) stays.

BEGIN;

UPDATE proposal_sections s SET body = replace(s.body,
  E'|[Sixers Youth Foundation](https://sixersyouthfoundation.org/renovated-courts-and-play-spaces/)|Court renovations; did this court in 2019|Partner, not a grant: they don''t take unsolicited proposals. A roll-up option keeps their court|info@sixersyouthfoundation.org, 215-952-7000\n', '')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 6;

UPDATE proposal_sections s SET body = replace(s.body, ' talk to the Sixers Youth Foundation (roll-up turf, hoops);', '')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 9;

UPDATE proposal_sections s SET body = replace(s.body,
  '- Does the 2019 Sixers court deal allow covering it?',
  '- Does The Light House''s own paperwork from the 2019 court renovation say it must stay a basketball court? An in-house check; the Sixers are not asked.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;

DO $$
DECLARE n int;
BEGIN
  SELECT count(*) INTO n FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
   WHERE p.code = 'erie-avenue-turf' AND s.body ILIKE '%sixers%';
  -- left on purpose: the site note (section 2) and the in-house check (section 10)
  IF n <> 2 THEN RAISE EXCEPTION 'turf proposal: % sections mention the Sixers, expected 2', n; END IF;
END $$;

COMMIT;

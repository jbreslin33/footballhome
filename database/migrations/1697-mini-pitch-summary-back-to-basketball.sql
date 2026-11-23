-- 🏟 Turf Mini Pitch: the summary says plainly that the court can go back to
-- basketball (James 11/23 "the summary for mini pitch should be clear that if
-- rolled optojn is used the court can be made back to basketball by grounds
-- crew if desited"). Every package is roll-up turf since mig 1691.
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'The court''s tiles lift off and are kept in storage on site. Under them is a flat concrete slab,',
  E'Because the turf rolls up, the grounds crew can turn the court back into a basketball court whenever that is wanted: roll up the turf and lay the tiles back. The hoops stay up throughout.\nThe court''s tiles lift off and are kept in storage on site. Under them is a flat concrete slab,')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1
                    AND s.body LIKE '%the grounds crew can turn the court back into a basketball court%') THEN
    RAISE EXCEPTION 'mini pitch: summary line not added';
  END IF;
END $$;
COMMIT;

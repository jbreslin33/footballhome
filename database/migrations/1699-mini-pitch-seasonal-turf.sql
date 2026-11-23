-- 🏟 Turf Mini Pitch: the turf is seasonal (James 11/23 "turf could be put
-- away during times of year of nice weather so court could be used for
-- basketball"). The summary says so: turf down for late fall, winter and
-- early spring, put away in good weather so the court is used for basketball.
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'Because the turf rolls up, the grounds crew can turn the court back into a basketball court whenever that is wanted: roll up the turf and lay the tiles back.',
  'The turf can be seasonal. It goes down for late fall, winter and early spring, and in the months of good weather the grounds crew can put it away so the court is used for basketball: roll up the turf and lay the tiles back.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%The turf can be seasonal.%') THEN
    RAISE EXCEPTION 'mini pitch: seasonal line not added';
  END IF;
END $$;
COMMIT;

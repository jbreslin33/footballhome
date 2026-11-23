-- 🏟 Erie Avenue turf proposal: drop the open question about The Light
-- House's 2019 court paperwork (James 11/23 "i doubt they locked themselves
-- in").
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  E'- Does The Light House''s own paperwork from the 2019 court renovation say it must stay a basketball court? An in-house check; the Sixers are not asked.\n', '')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 10;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
              WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 10 AND s.body ILIKE '%2019%') THEN
    RAISE EXCEPTION 'turf proposal: 2019 paperwork question still there';
  END IF;
END $$;
COMMIT;

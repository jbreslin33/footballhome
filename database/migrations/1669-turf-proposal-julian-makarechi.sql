-- 🏟 Erie Avenue turf proposal: the Deputy Director's full name (James 11/23
-- "Makarechi julian last name").
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body, 'Julian, Deputy Director,', 'Julian Makarechi, Deputy Director,')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%Julian Makarechi, Deputy Director%') THEN
    RAISE EXCEPTION 'turf proposal: name not replaced';
  END IF;
END $$;
COMMIT;

-- 🏟 Erie Avenue turf proposal: the grant writer by name (James 11/23
-- "anita.lyndaker is grant writer").
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'To Edwin Desamour, Executive Director, Julian Makarechi, Deputy Director, and the grant writers at Lighthouse.',
  'To Edwin Desamour, Executive Director, Julian Makarechi, Deputy Director, and Anita Lyndaker, Grant Writer, at Lighthouse.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%Anita Lyndaker, Grant Writer%') THEN
    RAISE EXCEPTION 'turf proposal: addressee line not replaced';
  END IF;
END $$;
COMMIT;

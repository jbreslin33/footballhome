-- 🏟 Erie Avenue turf proposal: addressed by name (James 11/23 "Excuttive
-- director Edwin Desamour. Deputy director Julian").
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'From James Breslin, for the director and grant writers at Lighthouse.',
  'From James Breslin. To Edwin Desamour, Executive Director, Julian, Deputy Director, and the grant writers at Lighthouse.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%Edwin Desamour, Executive Director%') THEN
    RAISE EXCEPTION 'turf proposal: addressee line not replaced';
  END IF;
END $$;
COMMIT;

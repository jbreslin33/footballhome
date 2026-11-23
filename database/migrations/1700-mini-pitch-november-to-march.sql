-- 🏟 Turf Mini Pitch: why the seasons fit (James 11/23 "basketball would
-- generayll not be played outside in november to march but soccer is").
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'The turf can be seasonal. It goes down for late fall, winter and early spring, and in the months of good weather the grounds crew can put it away so the court is used for basketball:',
  'The turf can be seasonal. Basketball is generally not played outside from November to March, but soccer is. So the turf goes down for those months, when the court would mostly sit empty, and in the months of good weather the grounds crew can put it away so the court is used for basketball:')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'erie-avenue-turf' AND s.sort_order = 1 AND s.body LIKE '%not played outside from November to March, but soccer is.%') THEN
    RAISE EXCEPTION 'mini pitch: November to March line not added';
  END IF;
END $$;
COMMIT;

-- 🏟 Turf Mini Pitch summary: the turf goes down for those months "if
-- desired" (James 11/23).
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body,
  'so the turf goes down for those months. In good weather', 'so the turf goes down for those months if desired. In good weather')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'turf-mini-pitch' AND s.sort_order = 1 AND s.body LIKE '%for those months if desired.%') THEN
    RAISE EXCEPTION 'mini pitch: if desired not added';
  END IF;
END $$;
COMMIT;

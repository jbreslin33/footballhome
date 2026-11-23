-- 🏟 Turf Mini Pitch: no "Add benches" row (James 11/23 "we already hvae
-- benches").
BEGIN;
UPDATE proposal_sections s SET body = replace(s.body, E'\n|**Add benches**|price when bid|price when bid|price when bid', '')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'erie-avenue-turf' AND s.sort_order = 4;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
              WHERE p.code = 'erie-avenue-turf' AND s.body ILIKE '%bench%') THEN
    RAISE EXCEPTION 'mini pitch: benches still mentioned';
  END IF;
END $$;
COMMIT;

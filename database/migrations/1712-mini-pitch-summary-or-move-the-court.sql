-- 🏟 Turf Mini Pitch summary: the other way to keep basketball (James 11/23
-- "or the turf stays up all year round and court is moved"): the turf stays
-- down all year and the basketball court moves elsewhere.
BEGIN;
UPDATE proposal_sections s SET body = replace(replace(s.body,
  '- **The basketball court stays.** The turf rolls up.', '- **Basketball is not lost.** The turf rolls up.'),
  'and the court is used for basketball again. The hoops stay up throughout.',
  'and the court is used for basketball again; the hoops stay up throughout. Or the turf stays down all year and the basketball court is moved somewhere else.')
FROM proposals p WHERE p.id = s.proposal_id AND p.code = 'turf-mini-pitch' AND s.sort_order = 1;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM proposal_sections s JOIN proposals p ON p.id = s.proposal_id
                  WHERE p.code = 'turf-mini-pitch' AND s.sort_order = 1
                    AND s.body LIKE '%**Basketball is not lost.**%' AND s.body LIKE '%the basketball court is moved somewhere else.%') THEN
    RAISE EXCEPTION 'mini pitch: move-the-court option not added';
  END IF;
END $$;
COMMIT;

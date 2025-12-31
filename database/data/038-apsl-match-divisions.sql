-- APSL Match-Division associations
-- All APSL matches belong to division 1

INSERT INTO match_divisions (match_id, division_id, counts_for_standings)
SELECT id, 1, true
FROM matches
WHERE source_system_id = 1  -- APSL matches only
ON CONFLICT (match_id, division_id) DO NOTHING;

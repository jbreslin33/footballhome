-- 1070: Anastasiya Bembischew (22719) ACTIVE on fall U8 (912) (owner
-- 2026-11-05: "anastasiya should be in active for u8 on teams page").  She
-- sat at Needs Docs, which does not count as On Roster, so the Team pill
-- kept her out of ACTIVE.  On Roster by hand, as migs 1048/1050/1062;
-- she is on the U8 file list already.  Ranks re-set.

BEGIN;

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id = 912 AND removed_at IS NULL AND person_id = 22719;

WITH s AS (
  SELECT tp.id,
         row_number() OVER (ORDER BY COALESCE(rs.counts_as_on_roster, false) DESC, count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC, p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id = 912
   GROUP BY tp.id, rs.counts_as_on_roster, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;

-- 1063: everyone on the winter teams ACTIVE, ranked by RSVP totals (owner
-- 2026-11-04: "put everyone active just rank them by rsvp totals").
-- Winter U10 (942), U11 (946), U12 (940), U13 (947): every row that is not
-- 💤 Inactive gets On Roster (full spot; no winter league list).  Inactive
-- (Yousef Mouneeb, Maya Rodriguez, Ava Smalley) stays.  Rank =
-- all-time RSVPs, then the last 14 days.  U10 goes over its 12 max — the
-- board shows it.

BEGIN;

UPDATE team_persons tp SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE tp.team_id IN (940, 942, 946, 947) AND tp.removed_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM squad_statuses ss WHERE ss.id = tp.squad_status_id AND ss.code = 'inactive');

WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           (tp.squad_status_id IS NOT NULL) ,  -- Inactive last
           count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC,
           p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id IN (940, 942, 946, 947)
   GROUP BY tp.id, tp.team_id, tp.squad_status_id, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;

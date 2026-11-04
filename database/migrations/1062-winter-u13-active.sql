-- 1062: winter U13 (947) ACTIVE — Ashten Griffin-Tull (22465) and Zane Stone
-- (22664) (owner 2026-11-04: "add ashten and zane to u13 active").  On
-- Roster by hand (no winter league list), as migs 1048/1050.  Ranks re-set.

BEGIN;

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id = 947 AND removed_at IS NULL AND person_id IN (22465, 22664);

WITH s AS (
  SELECT tp.id,
         row_number() OVER (ORDER BY COALESCE(rs.counts_as_on_roster, false) DESC, count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC, p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id = 947
   GROUP BY tp.id, rs.counts_as_on_roster, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;

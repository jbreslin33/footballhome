-- 1057: winter teams take their own age only (owner 2026-11-04: "actually
-- lets put u12 only players on u12 and u11 only on u11. and u10 only on
-- u10").
--   • teams.age_exact: a team that takes exactly its age group.  Set on
--     winter U10 (942), U11 (946), U12 (940).  fh_youth_fit_team now picks
--     an exact team for an exact age; age-band teams (fall U8/U10/U12)
--     work as before (youngest at or above, else the oldest band).  A kid
--     whose age has no exact team and no band team that term gets no team.
--   • Off winter: the six U13s (U12) and the 29 kids aged 9 and under
--     (U10) — no winter team for their age.
--   • U10 ACTIVE back to 12 U10s: the four U9/U8 kids who left (ethan
--     almonte, Jamauri Bradham, Tyreece Woods, Suhaylah Jones) are replaced
--     by the next U10s by availability — Carmelo Passineau, Jalil Sapp,
--     Alex Bassett, Jordan Grier-lomax.  Carter Bates (never answered)
--     stays Practice Squad.  Ranks re-set by availability.

BEGIN;

ALTER TABLE teams ADD COLUMN IF NOT EXISTS age_exact boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN teams.age_exact IS
  'mig 1057: the team takes exactly its age group (winter PPR Indoor U10/U11/U12); false = an age band (youngest team at or above the age).';
UPDATE teams SET age_exact = true WHERE id IN (940, 942, 946);

CREATE OR REPLACE FUNCTION fh_youth_fit_team(p_age integer, p_term text) RETURNS integer
LANGUAGE sql STABLE AS $$
    WITH c AS (
        SELECT t.id, fh_team_age(t.id) AS a, t.age_exact
          FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = p_term
         WHERE t.is_active AND t.games_need_roster
           AND t.gender_category IN ('boys', 'girls') AND t.name ~ '^U[0-9]+$')
    SELECT id FROM (
        SELECT id, 1 AS pri, a FROM c WHERE age_exact AND a = p_age
        UNION ALL SELECT id, 2, a FROM c WHERE NOT age_exact AND a >= p_age
        UNION ALL SELECT id, 3, -a FROM c WHERE NOT age_exact
    ) x ORDER BY pri, a, id LIMIT 1
$$;

-- Off winter: the age has no team now.
UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('mig', 1057, 'why', 'no winter team for this age')
  FROM persons p
 WHERE p.id = tp.person_id AND tp.removed_at IS NULL AND tp.team_id IN (940, 942, 946)
   AND fh_youth_us_age(p.birth_date) <> fh_team_age(tp.team_id);

-- U10 ACTIVE fill.
UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id = 942 AND removed_at IS NULL AND person_id IN (22380, 22282, 22342, 22600);

WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           COALESCE(rs.counts_as_on_roster, false) DESC,
           count(r.id) FILTER (WHERE r.response = 'yes' AND r.responded_at >= now() - interval '28 days') DESC,
           count(r.id) FILTER (WHERE r.response = 'yes') DESC,
           count(r.id) DESC, p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id IN (940, 942, 946)
   GROUP BY tp.id, tp.team_id, rs.counts_as_on_roster, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;

-- Owner (same day): "just rank them by rsvp" — rank = all-time RSVPs, then
-- the last 14 days, ACTIVE first.
WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           COALESCE(rs.counts_as_on_roster, false) DESC,
           count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC,
           p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id IN (940, 942, 946)
   GROUP BY tp.id, tp.team_id, rs.counts_as_on_roster, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

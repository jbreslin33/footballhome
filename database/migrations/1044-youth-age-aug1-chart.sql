-- 1044: youth age = the US Club Soccer 2026-27 chart (owner 2026-11-04:
-- "everything should use the birth year chart …
-- usclubsoccer.org/registration-player-age-groups … ignore middle col that
-- is last year").  From 2026-27 the chart is Aug 1 – Jul 31 again
-- (U-8 = born Aug 1, 2018 – Jul 31, 2019).  Mig 1043 wrongly used plain
-- birth year (last season's Jan–Dec column); this puts the Aug 1 cohort
-- back and moves its 11 kids back.
--   fh_youth_us_age = season end year − cohort year, cohort = birth year,
--   +1 when born Aug–Dec.  fh_youth_place (mig 1043) uses it unchanged.

BEGIN;

CREATE OR REPLACE FUNCTION fh_youth_us_age(p_birth date) RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT extract(year FROM now() AT TIME ZONE 'America/New_York')::int
           + CASE WHEN extract(month FROM now() AT TIME ZONE 'America/New_York') >= 6 THEN 1 ELSE 0 END
           - (extract(year FROM p_birth)::int + CASE WHEN extract(month FROM p_birth) >= 8 THEN 1 ELSE 0 END)
$$;
COMMENT ON FUNCTION fh_youth_us_age(date) IS
  'mig 1043/1044: US Club Soccer age for the current season per the 2026-27 chart — season end year (June cutover) minus the Aug 1 – Jul 31 cohort year.';

CREATE TEMP TABLE youth_moves ON COMMIT DROP AS
SELECT tp.id AS tp_id, tp.person_id, tp.roster_status_id, tt.term,
       fh_youth_fit_team(fh_youth_us_age(p.birth_date), tt.term) AS to_team
  FROM team_persons tp
  JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.games_need_roster
  JOIN team_terms tt ON tt.team_id = t.id AND tt.term IN ('fall', 'winter')
  JOIN persons p ON p.id = tp.person_id AND p.birth_date IS NOT NULL
  LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
 WHERE tp.removed_at IS NULL
   AND NOT COALESCE(rs.counts_as_on_roster, false)
   AND NOT EXISTS (SELECT 1 FROM official_roster_names n JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active
                    WHERE s.team_id = t.id AND n.person_id = tp.person_id);
DELETE FROM youth_moves m USING team_persons tp WHERE tp.id = m.tp_id AND (m.to_team IS NULL OR m.to_team = tp.team_id);

UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1044, 'why', 'US Club Soccer 2026-27 chart (Aug 1)')
  FROM youth_moves m WHERE tp.id = m.tp_id;

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT m.to_team, m.person_id, m.roster_status_id FROM youth_moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);

COMMIT;

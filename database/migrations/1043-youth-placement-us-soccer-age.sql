-- 1043: youth not on a league list are placed by US Soccer age — birth
-- year only (owner 2026-11-04: "so why is u9 still 'NOT ON ROSTER' under
-- u8 lol instead of under u10").  The card chip went to birth year the
-- same day; placement now matches it.  A kid on a team's official list
-- stays where the league has him.
--   US Soccer age = season end year − birth year (2018 = U9 in 2026-27).
--   fh_youth_place (migs 902/1034) picks the youngest game team at or
--   above that age, else the oldest; now by birth year, not the Aug 1
--   cutoff.
--   Moved today (not on the team's list, wrong team for their birth year):
--   fall U8 → U10: Anthony Gonzalez, Milo Williams, Yasmeen Turner (her
--   Needs Docs status travels); winter U12 → U15: Grace Breslin, Joseph
--   Bradham, Josiah Gaye, Muhammad Idris; winter U9 → U12: Jamauri
--   Bradham, Joshua Almaraz, Tyreece Woods, ethan almonte.

BEGIN;

CREATE OR REPLACE FUNCTION fh_youth_us_age(p_birth date) RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT extract(year FROM now() AT TIME ZONE 'America/New_York')::int
           + CASE WHEN extract(month FROM now() AT TIME ZONE 'America/New_York') >= 6 THEN 1 ELSE 0 END
           - extract(year FROM p_birth)::int
$$;
COMMENT ON FUNCTION fh_youth_us_age(date) IS
  'mig 1043: US Soccer age for the current season (season end year, June cutover, minus birth year).';

-- The best game team per term for a US Soccer age.
CREATE OR REPLACE FUNCTION fh_youth_fit_team(p_age integer, p_term text) RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT t.id FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = p_term
     WHERE t.is_active AND t.games_need_roster
       AND t.gender_category IN ('boys', 'girls') AND t.name ~ '^U[0-9]+$'
     ORDER BY (fh_team_age(t.id) >= p_age) DESC,
              CASE WHEN fh_team_age(t.id) >= p_age THEN fh_team_age(t.id) ELSE -fh_team_age(t.id) END,
              t.id
     LIMIT 1
$$;

CREATE OR REPLACE FUNCTION fh_youth_place(p_person_id integer) RETURNS void
LANGUAGE sql AS $$
    INSERT INTO team_persons (team_id, person_id)
    SELECT DISTINCT fh_youth_fit_team(fh_youth_us_age(p.birth_date), season.term), p.id
      FROM persons p
      CROSS JOIN (VALUES ('fall'), ('winter')) AS season(term)
     WHERE p.id = p_person_id AND p.birth_date IS NOT NULL
       AND fh_youth_fit_team(fh_youth_us_age(p.birth_date), season.term) IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM team_persons x
                         JOIN teams xt ON xt.id = x.team_id
                         JOIN team_terms xtt ON xtt.team_id = xt.id AND xtt.term = season.term
                        WHERE x.person_id = p.id AND x.removed_at IS NULL AND xt.is_active
                          AND xt.gender_category IN ('boys', 'girls'));
$$;

-- Today's moves.
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
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1042, 'why', 'US Soccer age')
  FROM youth_moves m WHERE tp.id = m.tp_id;

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT m.to_team, m.person_id, m.roster_status_id FROM youth_moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);

COMMIT;

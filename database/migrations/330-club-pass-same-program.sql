-- Club pass, same-program only (owner 2026-09-05, follow-up to 329).
--
-- First run of fh_event_callups pulled every Intramural roster into the
-- Travel games (20 U6/U8 Intramural kids for the 9/13 U8 Travel game).
-- The point of the club pass is to stop wasting parents' time, so a
-- call-up must come from the SAME PROGRAM as the event's team: "Travel"
-- games pull from "Travel" teams, "Intramural" from "Intramural".  The
-- program is the team name with the leading U<n> stripped, lower-cased.
-- Loosen by editing this one predicate if the club ever wants cross-
-- program call-ups.
CREATE OR REPLACE FUNCTION fh_team_program(p_team_id int) RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT lower(btrim(regexp_replace(t.name, '^u\s*\d+\s*', '', 'i')))
    FROM teams t WHERE t.id = p_team_id
$$;

CREATE OR REPLACE FUNCTION fh_event_callups(p_fh_event_id bigint)
RETURNS TABLE (person_id int, from_team_id int, from_team_name text, single_age int)
LANGUAGE sql STABLE AS $$
  WITH ev AS (
    SELECT fe.id,
           fh_event_age(fe.id)                                      AS event_age,
           fh_season_end_year(COALESCE(fe.start_at, ge.starts_at))  AS season,
           (SELECT t.club_id FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
             WHERE fet.fh_event_id = fe.id AND t.gender_category IN ('boys','girls')
             ORDER BY fh_team_age(t.id) DESC NULLS LAST, t.id LIMIT 1) AS club_id,
           (SELECT fh_team_program(t.id) FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
             WHERE fet.fh_event_id = fe.id AND t.gender_category IN ('boys','girls')
             ORDER BY fh_team_age(t.id) DESC NULLS LAST, t.id LIMIT 1) AS program
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE fe.id = p_fh_event_id
  ),
  rule AS (
    SELECT ev.*, c.club_pass_years_up AS years_up
      FROM ev JOIN clubs c ON c.id = ev.club_id
     WHERE ev.event_age IS NOT NULL AND c.club_pass_years_up > 0
  ),
  cand AS (
    SELECT DISTINCT ON (p.id)
           p.id AS person_id, t.id AS team_id, t.name AS team_name,
           fh_youth_single_age(p.birth_date, r.season) AS age,
           r.event_age, r.years_up
      FROM rule r
      JOIN teams t        ON t.club_id = r.club_id
                         AND t.gender_category IN ('boys','girls')
                         AND t.is_active AND t.board_archived_at IS NULL
                         AND fh_team_program(t.id) = r.program          -- same program only
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL
      JOIN persons p       ON p.id = tp.person_id
     ORDER BY p.id, fh_team_age(t.id) DESC NULLS LAST, t.id
  )
  SELECT c.person_id, c.team_id, c.team_name, c.age
    FROM cand c
   WHERE c.age IS NOT NULL
     AND c.age BETWEEN c.event_age - c.years_up AND c.event_age
     AND NOT EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                       ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                     WHERE fet.fh_event_id = p_fh_event_id AND tp.person_id = c.person_id)
     AND NOT EXISTS (SELECT 1 FROM team_persons tp
                     WHERE tp.person_id = c.person_id AND tp.removed_at IS NULL
                       AND fh_team_age(tp.team_id) > c.event_age)
     AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s
                     WHERE s.person_id = c.person_id
                       AND s.starts_at <= now() AND (s.ends_at IS NULL OR s.ends_at > now()))
$$;

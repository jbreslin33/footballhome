-- 505 (2026-09-30) — A weekday game widens the starter window for the whole
-- men's section, not just the team that plays it.
--
-- Owner: "why is liga 1 not taking into account weekday game for apsl like
-- apsl does? this rule applies to liga 1 if apsl game during the week. if
-- there is liga 1 game during the week we will still might have apsl
-- practice but we will extend the days for everyone apsl and liga 1."
--
-- fh_starter_window (mig 456) looked for the week's weekday game only among
-- the game's own teams, so Sunday's Liga 1 game (team 120) never saw
-- Wednesday's APSL game (teams 35 + 938) and kept the plain last-5 window
-- while the APSL's own Sunday game got the wide one.
--
-- A policy can now belong to a club section and say the weekday game of ANY
-- team in that section counts.  The men's section gets such a row; every
-- other team keeps the system default (its own games only).

ALTER TABLE eligibility_policies
  ADD COLUMN IF NOT EXISTS club_section_id INT REFERENCES club_sections(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS weekday_game_section_wide BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN eligibility_policies.club_section_id IS
  'Scope: every team of this section (within club_id when set).  Ranks below a team row and above a club row (mig 505).';
COMMENT ON COLUMN eligibility_policies.weekday_game_section_wide IS
  'true: a weekday game of any team in the same club section lends its cutoff to the following weekend''s games, not only a game of the same teams (mig 505).';

-- Most specific wins: match, team, section, club, system default.
CREATE OR REPLACE FUNCTION public.fh_starter_policy(p_team_ids integer[], p_match_id integer)
 RETURNS eligibility_policies
 LANGUAGE sql
 STABLE
AS $function$
  SELECT p.* FROM eligibility_policies p
   WHERE (p_match_id IS NOT NULL AND p.match_id = p_match_id)
      OR (p.match_id IS NULL AND p.team_id = ANY(p_team_ids))
      OR (p.match_id IS NULL AND p.team_id IS NULL AND p.club_section_id IS NOT NULL
          AND EXISTS (SELECT 1 FROM teams t WHERE t.id = ANY(p_team_ids)
                         AND t.club_section_id = p.club_section_id
                         AND (p.club_id IS NULL OR t.club_id = p.club_id)))
      OR (p.match_id IS NULL AND p.team_id IS NULL AND p.club_section_id IS NULL
          AND p.club_id IN (SELECT t.club_id FROM teams t WHERE t.id = ANY(p_team_ids)))
      OR (p.match_id IS NULL AND p.team_id IS NULL AND p.club_section_id IS NULL AND p.club_id IS NULL)
   ORDER BY (p.match_id IS NOT NULL) DESC, (p.team_id IS NOT NULL) DESC, (p.club_section_id IS NOT NULL) DESC,
            (p.club_id IS NOT NULL) DESC, p.id
   LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.fh_starter_window(p_team_ids integer[], p_kickoff timestamp with time zone, p_match_id integer)
 RETURNS TABLE(fh_event_id bigint, kind text, starts_at timestamp with time zone, extended boolean, cutoff timestamp with time zone)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  pol      eligibility_policies;
  v_dow    INT;
  v_cutoff TIMESTAMPTZ := NULL;
  v_wk     TIMESTAMPTZ;
  v_game_teams INT[] := p_team_ids;   -- whose weekday game widens the window
BEGIN
  pol := fh_starter_policy(p_team_ids, p_match_id);
  IF pol.id IS NULL THEN
    pol.lookback_count := 5; pol.pickup_counts_as_session := true; pol.game_counts_as_session := false;
    pol.weekday_game_extends_window := true; pol.week_cutoff_dow := 6; pol.weekday_game_section_wide := false;
  END IF;

  IF pol.weekday_game_extends_window THEN
    v_dow := EXTRACT(DOW FROM p_kickoff AT TIME ZONE 'America/New_York')::int;
    IF v_dow BETWEEN 1 AND 5 THEN
      v_cutoff := fh_week_cutoff(p_kickoff, pol.week_cutoff_dow);
    ELSE
      -- Weekend game: the most recent weekday game within the past 7 days
      -- lends its cutoff — a game of these teams, or (section-wide policy,
      -- mig 505) of any team in their club section.
      IF pol.weekday_game_section_wide THEN
        SELECT COALESCE(array_agg(DISTINCT s.id), p_team_ids) INTO v_game_teams
          FROM teams t
          JOIN teams s ON s.club_id = t.club_id AND s.club_section_id = t.club_section_id
         WHERE t.id = ANY(p_team_ids);
      END IF;
      SELECT ge.starts_at INTO v_wk
        FROM fh_events fe
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
       WHERE fe.kind = 'match' AND ge.deleted_at IS NULL
         AND ge.starts_at > p_kickoff - INTERVAL '7 days' AND ge.starts_at < p_kickoff
         AND EXTRACT(DOW FROM ge.starts_at AT TIME ZONE 'America/New_York')::int BETWEEN 1 AND 5
         AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = ANY(v_game_teams))
       ORDER BY ge.starts_at DESC LIMIT 1;
      IF v_wk IS NOT NULL THEN v_cutoff := fh_week_cutoff(v_wk, pol.week_cutoff_dow); END IF;
    END IF;
  END IF;

  RETURN QUERY
  WITH sessions AS (
    SELECT DISTINCT fe.id AS fh_event_id, fe.kind::text AS kind, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
      JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
     WHERE fet.team_id = ANY(p_team_ids)
       AND ge.deleted_at IS NULL
       AND ge.starts_at < p_kickoff
       AND (fe.kind IN ('practice', 'barn night')
            OR (fe.kind = 'pickup' AND pol.pickup_counts_as_session)
            OR (fe.kind = 'match'  AND pol.game_counts_as_session))
  ),
  picked AS (
    SELECT s.* FROM (
      SELECT s.* FROM sessions s
       WHERE v_cutoff IS NULL OR s.starts_at < v_cutoff
       ORDER BY s.starts_at DESC
       LIMIT pol.lookback_count
    ) s
    UNION
    SELECT s.* FROM sessions s WHERE v_cutoff IS NOT NULL AND s.starts_at >= v_cutoff
  )
  SELECT p.fh_event_id, p.kind, p.starts_at, (v_cutoff IS NOT NULL), v_cutoff
    FROM picked p ORDER BY p.starts_at;
END;
$function$;

-- The men's section (APSL, APSL Reserves, Liga 1): same numbers as the
-- system default, but one team's weekday game widens the window for all.
-- (The id sequence was never advanced past the seeded default row.)
SELECT setval(pg_get_serial_sequence('eligibility_policies', 'id'), (SELECT MAX(id) FROM eligibility_policies));
INSERT INTO eligibility_policies (club_id, club_section_id, lookback_count, min_sessions_to_start, priority_starter_sessions,
                                  priority_starter_slots, game_counts_as_session, pickup_counts_as_session,
                                  weekday_game_extends_window, week_cutoff_dow, weekday_game_section_wide, notes)
SELECT 134, cs.id, d.lookback_count, d.min_sessions_to_start, d.priority_starter_sessions,
       d.priority_starter_slots, d.game_counts_as_session, d.pickup_counts_as_session,
       d.weekday_game_extends_window, d.week_cutoff_dow, true,
       'Men''s section (mig 505): the system default, plus a weekday game of any men''s team (APSL, Reserves, Liga 1) widens the window for every men''s team that week.'
  FROM club_sections cs
  JOIN eligibility_policies d ON d.match_id IS NULL AND d.team_id IS NULL AND d.club_id IS NULL AND d.club_section_id IS NULL
 WHERE cs.name = 'Mens'
   AND NOT EXISTS (SELECT 1 FROM eligibility_policies x WHERE x.club_section_id = cs.id AND x.team_id IS NULL AND x.match_id IS NULL);

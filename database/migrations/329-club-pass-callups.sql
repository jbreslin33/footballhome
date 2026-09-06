-- Club pass: youth call-ups by age (owner 2026-09-05).
--
-- "A player who is on a roster for a team at the club and is within the
-- range of playing two years up" is eligible to be called up to an older
-- team's game.  U10 game → U8, U9, U10 may see + RSVP; U12 game → U10,
-- U11, U12.  Replaces tagging the younger team on the event, which
-- dragged along every U7 on U8 Travel (5 households on 9/13) and every U9
-- on U10 Travel (6 households) for games they cannot play.
--
-- Youth only (teams.gender_category IN ('boys','girls')).  Mens/womens
-- keep team-tag visibility; APSL games list Liga 1 as a second Team:.
--
-- Everything is DERIVED — nothing new is keyed in:
--   * player single-year age  ← persons.birth_date + the Aug 1 cutoff the
--     youth_age_groups buckets already use (age N for a season ending in
--     year Y = born (Y-N-1)-08-01 .. (Y-N)-07-31)
--   * team age                ← teams.name 'U<n> ...'
--   * event age               ← max team age over fh_event_teams
--   * years up                ← clubs.club_pass_years_up (2 for Lighthouse)
--
-- The team's own roster is unaffected (a U7 on U8 Travel still sees U8
-- games — that is their team).  Call-ups are STRICTLY upward: anyone
-- already rostered on a team older than the event is not a call-up for
-- it.  Suspended players are excluded the same way `eligible` excludes
-- them.  Consumers: CalendarController (eligible / guardian_targets /
-- rsvps_json / my_rsvp_eligible / resolveRsvpTarget / attendance).

ALTER TABLE clubs ADD COLUMN IF NOT EXISTS club_pass_years_up smallint NOT NULL DEFAULT 0;
COMMENT ON COLUMN clubs.club_pass_years_up IS
  'Youth call-up window: a rostered youth player may be called up to a game whose team age is up to this many years above their single-year age. 0 = no club pass.';
UPDATE clubs SET club_pass_years_up = 2 WHERE id = 134 AND club_pass_years_up <> 2;  -- Lighthouse 1893 SC

-- Season-end year for a moment in time, Aug 1 cutoff in club-local time.
CREATE OR REPLACE FUNCTION fh_season_end_year(at_ts timestamptz) RETURNS int
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN EXTRACT(MONTH FROM (at_ts AT TIME ZONE 'America/New_York')) >= 8
              THEN EXTRACT(YEAR FROM (at_ts AT TIME ZONE 'America/New_York'))::int + 1
              ELSE EXTRACT(YEAR FROM (at_ts AT TIME ZONE 'America/New_York'))::int END
$$;

-- Single-year age (the N in "U<N>") for a birth date in a given season.
-- born 2019-08-17 → season 2027 → 7 (U7); born 2019-06-27 → 8 (U8).
CREATE OR REPLACE FUNCTION fh_youth_single_age(birth date, season_end_year int) RETURNS int
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN birth IS NULL THEN NULL
              ELSE season_end_year - EXTRACT(YEAR FROM (birth + INTERVAL '5 months'))::int END
$$;

-- Team age parsed from the name, youth teams only ('U10 Travel' → 10).
CREATE OR REPLACE FUNCTION fh_team_age(p_team_id int) RETURNS int
LANGUAGE sql STABLE AS $$
  SELECT CASE WHEN t.gender_category IN ('boys','girls') AND t.name ~* '^u\s*\d+'
              THEN (regexp_match(t.name, '^u\s*(\d+)', 'i'))[1]::int END
    FROM teams t WHERE t.id = p_team_id
$$;

-- Event age = oldest youth team tagged on it (NULL for adult / untagged).
CREATE OR REPLACE FUNCTION fh_event_age(p_fh_event_id bigint) RETURNS int
LANGUAGE sql STABLE AS $$
  SELECT MAX(fh_team_age(fet.team_id)) FROM fh_event_teams fet WHERE fet.fh_event_id = p_fh_event_id
$$;

-- Who may be CALLED UP to this event: one row per eligible player with the
-- (oldest) team they are rostered on and their single-year age.  Empty for
-- adult events, for clubs with club_pass_years_up = 0, and for players
-- already on a tagged team (they are roster, not call-ups).
CREATE OR REPLACE FUNCTION fh_event_callups(p_fh_event_id bigint)
RETURNS TABLE (person_id int, from_team_id int, from_team_name text, single_age int)
LANGUAGE sql STABLE AS $$
  WITH ev AS (
    SELECT fe.id,
           fh_event_age(fe.id)                                   AS event_age,
           fh_season_end_year(COALESCE(fe.start_at, ge.starts_at)) AS season,
           (SELECT t.club_id FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
             WHERE fet.fh_event_id = fe.id AND t.gender_category IN ('boys','girls')
             ORDER BY t.id LIMIT 1)                             AS club_id
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
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL
      JOIN persons p       ON p.id = tp.person_id
     ORDER BY p.id, fh_team_age(t.id) DESC NULLS LAST, t.id
  )
  SELECT c.person_id, c.team_id, c.team_name, c.age
    FROM cand c
   WHERE c.age IS NOT NULL
     AND c.age BETWEEN c.event_age - c.years_up AND c.event_age
     -- not already roster on a tagged team
     AND NOT EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                       ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                     WHERE fet.fh_event_id = p_fh_event_id AND tp.person_id = c.person_id)
     -- strictly upward: nobody rostered on a team OLDER than the event
     AND NOT EXISTS (SELECT 1 FROM team_persons tp
                     WHERE tp.person_id = c.person_id AND tp.removed_at IS NULL
                       AND fh_team_age(tp.team_id) > c.event_age)
     -- same suspension rule as `eligible`
     AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s
                     WHERE s.person_id = c.person_id
                       AND s.starts_at <= now() AND (s.ends_at IS NULL OR s.ends_at > now()))
$$;

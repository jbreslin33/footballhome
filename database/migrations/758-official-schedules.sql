-- 758: every team's official league schedule in the database, checked
-- against the calendar.
--
-- Owner 2026-10-27: "show me table of all games for all teams and any
-- issues and show that timestamp of when you got the latest schedule from
-- official source not our db … but put it in db. including deleting games
-- that don't exist anymore in official source."
--
-- APSL (TeamPass iCal) and CASA (SportsEngine) were already league_fixtures
-- sources pulled by the server.  The youth (PPR on GotSport) and the women
-- (Tri County on TeamSnap) turn the server away — GotSport's CloudFront 403s
-- it, TeamSnap needs a login — so those are read in Chrome and loaded by
-- scripts/official-schedule-load.js with the time they were read.  The
-- server's LeagueFixtureSync skips systems 'gotsport' and 'teamsnap'.
--
-- league_fixture_sources.last_fetched_at = when the league's own site was
-- last read; a game gone from that read gets league_fixtures.removed_at.
--
-- team_id ties a source to our team; our_name_pattern picks our games out
-- of a division-wide feed (CASA lists every club's games).
-- fh_official_schedule_check(from) lines the official games up against the
-- team's calendar games:  ok · time_differs · missing_on_calendar ·
-- cancelled_officially · not_in_official.

ALTER TABLE league_fixture_sources
    ADD COLUMN IF NOT EXISTS team_id INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS our_name_pattern TEXT,
    ADD COLUMN IF NOT EXISTS schedule_url TEXT;

UPDATE league_fixture_sources SET team_id = 120, our_name_pattern = 'Lighthouse%',
       schedule_url = 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9496152'
 WHERE id = 1;
UPDATE league_fixture_sources SET team_id = 35, our_name_pattern = 'Lighthouse%',
       schedule_url = 'https://app.teampass.com/APSL/Team/165430'
 WHERE id = 2;

INSERT INTO league_fixture_sources (league_id, league_label, season, system, program_id, label, team_id, our_name_pattern, schedule_url)
VALUES
  (8, 'PPR',   '2026/27', 'gotsport', '57473/4408462', 'PPR U8 Boys Red (GotSport)',   912, 'Lighthouse%', 'https://system.gotsport.com/org_event/events/57473/schedules?team=4408462'),
  (8, 'PPR',   '2026/27', 'gotsport', '57473/4411988', 'PPR U10 Boys Blue (GotSport)', 913, 'Lighthouse%', 'https://system.gotsport.com/org_event/events/57473/schedules?team=4411988'),
  (8, 'PPR',   '2026/27', 'gotsport', '57473/4411989', 'PPR U12 Boys (GotSport)',      914, 'Lighthouse%', 'https://system.gotsport.com/org_event/events/57473/schedules?team=4411989'),
  (7, 'TCWSL', '2026/27', 'teamsnap', '10717331',      'Tri County Women (TeamSnap)',  901, 'Lighthouse%', 'https://go.teamsnap.com/10717331/schedule?mode=list&pageSize=30')
ON CONFLICT (league_label, season, program_id) DO NOTHING;

CREATE OR REPLACE FUNCTION fh_official_schedule_check(p_from TIMESTAMPTZ DEFAULT now() - interval '3 hours')
RETURNS TABLE (
    team_id            INTEGER,
    team               TEXT,
    state              TEXT,
    official_at        TIMESTAMPTZ,
    official_status    TEXT,
    official_home      TEXT,
    official_away      TEXT,
    official_venue     TEXT,
    calendar_at        TIMESTAMPTZ,
    calendar_title     TEXT,
    calendar_location  TEXT,
    gcal_event_id      BIGINT,
    fixture_id         INTEGER,
    source_id          INTEGER,
    source_read_at     TIMESTAMPTZ
) LANGUAGE sql STABLE AS $$
WITH src AS (
    SELECT s.* FROM league_fixture_sources s
     WHERE s.is_active AND s.team_id IS NOT NULL
),
official AS (
    SELECT s.team_id, s.id AS source_id, s.last_fetched_at, f.id AS fixture_id, f.starts_at,
           f.status, f.home_name, f.away_name,
           NULLIF(concat_ws(' — ', f.venue_name, f.venue_detail), '') AS venue,
           (f.status ~* '^(cancel|postpon)') AS is_off
      FROM src s JOIN league_fixtures f ON f.source_id = s.id
     WHERE f.removed_at IS NULL AND f.starts_at >= p_from
       AND (f.home_name ILIKE s.our_name_pattern OR f.away_name ILIKE s.our_name_pattern)
),
cal AS (
    SELECT DISTINCT et.team_id, g.id AS gcal_event_id, g.starts_at, g.summary, g.location
      FROM gcal_events g
      JOIN fh_events fe ON fe.gcal_event_id = g.id AND fe.kind = 'match'
      JOIN fh_event_teams et ON et.fh_event_id = fe.id
     WHERE g.deleted_at IS NULL AND g.status <> 'cancelled' AND g.starts_at >= p_from
       AND et.team_id IN (SELECT team_id FROM src)
),
exact AS (          -- same team, same kickoff
    SELECT o.fixture_id, c.gcal_event_id
      FROM official o JOIN cal c ON c.team_id = o.team_id AND c.starts_at = o.starts_at
),
same_day AS (       -- same team, same day, kickoff moved (closest one wins)
    SELECT DISTINCT ON (o.fixture_id) o.fixture_id, c.gcal_event_id
      FROM official o JOIN cal c ON c.team_id = o.team_id
       AND (c.starts_at AT TIME ZONE 'America/New_York')::date = (o.starts_at AT TIME ZONE 'America/New_York')::date
     WHERE o.fixture_id NOT IN (SELECT fixture_id FROM exact)
       AND c.gcal_event_id NOT IN (SELECT gcal_event_id FROM exact)
     ORDER BY o.fixture_id, abs(extract(epoch FROM c.starts_at - o.starts_at))
),
paired AS (SELECT * FROM exact UNION ALL SELECT * FROM same_day)
SELECT o.team_id, t.name,
       CASE WHEN o.is_off AND c.gcal_event_id IS NOT NULL THEN 'cancelled_officially'
            WHEN o.is_off THEN 'cancelled_ok'
            WHEN c.gcal_event_id IS NULL THEN 'missing_on_calendar'
            WHEN c.starts_at <> o.starts_at THEN 'time_differs'
            ELSE 'ok' END,
       o.starts_at, o.status, o.home_name, o.away_name, o.venue,
       c.starts_at, c.summary, c.location, c.gcal_event_id, o.fixture_id, o.source_id, o.last_fetched_at
  FROM official o
  JOIN teams t ON t.id = o.team_id
  LEFT JOIN paired p ON p.fixture_id = o.fixture_id
  LEFT JOIN cal c ON c.gcal_event_id = p.gcal_event_id AND c.team_id = o.team_id
UNION ALL
SELECT c.team_id, t.name, 'not_in_official',
       NULL, NULL, NULL, NULL, NULL,
       c.starts_at, c.summary, c.location, c.gcal_event_id, NULL, s.id, s.last_fetched_at
  FROM cal c
  JOIN teams t ON t.id = c.team_id
  JOIN src s ON s.team_id = c.team_id
 WHERE c.gcal_event_id NOT IN (SELECT p.gcal_event_id FROM paired p
                                 JOIN official o ON o.fixture_id = p.fixture_id AND o.team_id = c.team_id)
$$;

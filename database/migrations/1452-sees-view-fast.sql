-- fh_event_invites (mig 1450) computed fast. Standing call-downs are
-- GAMES only (a call-down is for the lower team's games; SEES already
-- said "practices no") — the 10k recurring practices never enter. The
-- list rule is written out (not via fh_roster_game_grants()) so a
-- reader's "this game" filter reaches the indexes: whole view ~3 ms, a
-- per-game lookup ~0.03 ms (calendar, RSVP board call it per event).
CREATE OR REPLACE VIEW fh_event_invites AS
WITH rule AS (
  -- sees yes = standing call-down: every GAME of the team while open
  SELECT fet.fh_event_id, s.person_id, s.from_team_id, s.created_at, 'standing call-down'::text AS note, 0 AS pref
    FROM fh_event_teams fet
    JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
    JOIN person_team_sees s ON s.team_id = fet.team_id AND s.sees
     AND ge.starts_at >= s.created_at AND (s.ended_at IS NULL OR ge.starts_at < s.ended_at)
  UNION ALL
  -- on the list → the games team's games since the list began giving
  -- them, unless sees says no or his own team row decides
  SELECT fet.fh_event_id, n.person_id, src.team_id, src.games_from, 'official league list',
         CASE WHEN src.team_id = src.games_team_id THEN 1 ELSE 2 END
    FROM fh_event_teams fet
    JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
    JOIN official_roster_sources src ON src.games_team_id = fet.team_id AND src.is_active AND ge.starts_at >= src.games_from
    JOIN official_roster_names n ON n.source_id = src.id AND n.person_id IS NOT NULL
   WHERE fh_in_leagueapps(n.person_id)
     AND NOT EXISTS (SELECT 1 FROM person_team_sees r WHERE r.person_id = n.person_id AND r.team_id = fet.team_id
                        AND NOT r.sees AND r.ended_at IS NULL)
     AND NOT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = n.person_id
                        AND tp.team_id = fet.team_id AND tp.removed_at IS NULL)
), one_rule AS (
  SELECT DISTINCT ON (fh_event_id, person_id) * FROM rule ORDER BY fh_event_id, person_id, pref, created_at
)
SELECT o.id, o.fh_event_id, o.person_id, o.from_team_id, o.recipient_person_id,
       o.set_by_user_id AS invited_by_user_id, o.channel, o.contact, o.note, o.created_at,
       NULL::timestamptz AS revoked_at, NULL::integer AS revoked_by_user_id
  FROM event_person_sees o
 WHERE o.sees
UNION ALL
SELECT NULL::bigint, r.fh_event_id, r.person_id, r.from_team_id, r.person_id,
       NULL::integer, NULL::text, NULL::text, r.note, r.created_at,
       NULL::timestamptz, NULL::integer
  FROM one_rule r
 WHERE NOT EXISTS (SELECT 1 FROM event_person_sees o WHERE o.fh_event_id = r.fh_event_id AND o.person_id = r.person_id);

-- fh_event_invited(event, person) answered directly from the three facts
-- (mig 1450), not through the whole fh_event_invites view: the calendar
-- calls it once per event, 10k+ practices a screen. One-game sees wins;
-- else a standing call-down (sees yes) or the list gives him a GAME.
CREATE OR REPLACE FUNCTION fh_event_invited(p_fh_event_id bigint, p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE(
    (SELECT o.sees FROM event_person_sees o WHERE o.fh_event_id = p_fh_event_id AND o.person_id = p_person_id),
    EXISTS (
      SELECT 1 FROM fh_events fe
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
        JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
       WHERE fe.id = p_fh_event_id AND fe.kind = 'match'
         AND (EXISTS (SELECT 1 FROM person_team_sees s
                       WHERE s.person_id = p_person_id AND s.team_id = fet.team_id AND s.sees
                         AND ge.starts_at >= s.created_at AND (s.ended_at IS NULL OR ge.starts_at < s.ended_at))
              OR EXISTS (SELECT 1 FROM official_roster_names n
                           JOIN official_roster_sources src ON src.id = n.source_id AND src.is_active
                                AND src.games_team_id = fet.team_id AND ge.starts_at >= src.games_from
                          WHERE n.person_id = p_person_id
                            AND fh_in_leagueapps(p_person_id)
                            AND NOT EXISTS (SELECT 1 FROM person_team_sees r WHERE r.person_id = p_person_id
                                               AND r.team_id = fet.team_id AND NOT r.sees AND r.ended_at IS NULL)
                            AND NOT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = p_person_id
                                               AND tp.team_id = fet.team_id AND tp.removed_at IS NULL)))))
$$;

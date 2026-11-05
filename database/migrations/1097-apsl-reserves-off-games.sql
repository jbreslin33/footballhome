-- 1097: APSL Reserves (team 938) comes off games — owner 2026-11-05: "apsl
-- reserves should not exist as a 'team' only on roster page right?" →
-- "yes take it off games, keep call-up pool column".
--
-- Reserves is the league's Reserve LIST (its own TeamPass source and
-- roster statuses on #teams' Roster pill) and the APSL call-up pool column
-- on the Team pill.  It was also tagged on every APSL game ("Team: APSL,
-- APSL Reserves"), which put the whole pool on the game as squad.
--
--  1. The gcal tag spellings "apsl reserves" / "reserves" now resolve to
--     APSL (35); the calendar text is untouched, and the classifier's
--     rebuild drops 938 from every game.  Removed here too, so it is gone
--     before the next sync.
--  2. team_callup_policies.pool_for_team_id names whose pool a call-up-only
--     team is (938 → 35).  fh_event_list_team_ids(event) = the game's teams
--     plus their pools: the league-list check (fh_event_league_list,
--     fh_event_registration_gaps' list) still reads the Reserve list, so a
--     called-up Reserve player stays "on the league list"; Game Center's
--     lineup still loads the pool into its 🎟 Call-up pool fold (mig 1096).
--  Call-up candidates already come from every men's team not on the game
--  (fh_event_invite_candidates' adult branch), Reserves included.

BEGIN;

ALTER TABLE team_callup_policies ADD COLUMN IF NOT EXISTS pool_for_team_id integer REFERENCES teams(id);
COMMENT ON COLUMN team_callup_policies.pool_for_team_id IS
  'mig 1097: the team this call-up-only team is the pool for (APSL Reserves 938 → APSL 35). Its list counts for that team''s games; it is never tagged on them.';
UPDATE team_callup_policies SET pool_for_team_id = 35 WHERE team_id = 938 AND pool_for_team_id IS NULL;

CREATE OR REPLACE FUNCTION fh_event_list_team_ids(p_fh_event_id bigint)
RETURNS SETOF integer LANGUAGE sql STABLE AS $$
  SELECT fet.team_id FROM fh_event_teams fet WHERE fet.fh_event_id = p_fh_event_id
  UNION
  SELECT g.team_id FROM team_callup_policies g
    JOIN fh_event_teams fet ON fet.team_id = g.pool_for_team_id AND fet.fh_event_id = p_fh_event_id
$$;
COMMENT ON FUNCTION fh_event_list_team_ids(bigint) IS
  'mig 1097: a game''s teams plus the call-up pools that serve them (team_callup_policies.pool_for_team_id).';

-- League lists for a game: every list team's online source.
CREATE OR REPLACE FUNCTION public.fh_event_league_list(p_fh_event_id bigint)
 RETURNS TABLE(source_id integer, team_id integer, league_label text, system text, last_fetched_at timestamp with time zone, last_fetch_ok boolean, last_fetch_note text, names_pulled_at timestamp with time zone, names integer, matched integer)
 LANGUAGE sql
 STABLE
AS $function$
    SELECT s.id, s.team_id, s.league_label, s.system, s.last_fetched_at, s.last_fetch_ok, s.last_fetch_note,
           (SELECT max(n.pulled_at) FROM official_roster_names n WHERE n.source_id = s.id),
           (SELECT count(*)::int FROM official_roster_names n WHERE n.source_id = s.id),
           (SELECT count(n.person_id)::int FROM official_roster_names n WHERE n.source_id = s.id)
      FROM fh_events e
      JOIN league_registration_forms lrf ON lrf.league_label = e.league AND lrf.checks_league_list
      JOIN official_roster_sources s ON s.is_active AND s.system <> 'club_file'
                                    AND s.team_id IN (SELECT fh_event_list_team_ids(e.id))
     WHERE e.id = p_fh_event_id
     ORDER BY s.id
$function$;

-- Registration gaps: the `list` CTE reads the list teams (pool included).
CREATE OR REPLACE FUNCTION public.fh_event_registration_gaps(p_fh_event_id bigint, p_club_id integer)
 RETURNS TABLE(person_id integer, first_name text, last_name text, status_code text, status_label text, player_done boolean, phone text, email text, form_label text, subject text, body text, reason text)
 LANGUAGE sql
 STABLE
AS $function$
    WITH ev AS (
        SELECT e.id, e.match_id, lrf.checks_league_list, m.label, m.subject, m.body
          FROM fh_events e
          JOIN league_registration_forms lrf ON lrf.league_label = e.league
          JOIN message_templates m ON m.id = lrf.message_template_id AND m.is_active
         WHERE e.id = p_fh_event_id
    ),
    -- The league's lists for this game: every list team's online source
    -- (APSL = Active + Reserve, mig 1011/1097; on either one = eligible).
    list AS (
        SELECT s.id FROM official_roster_sources s
         WHERE s.team_id IN (SELECT fh_event_list_team_ids(p_fh_event_id))
           AND s.is_active AND s.system <> 'club_file'
    ),
    caps AS (
        SELECT c.from_team_id, c.max_per_event,
               (SELECT count(*) FROM ev
                  JOIN match_lineups ml ON ml.match_id = ev.match_id AND ml.zone IN ('starter', 'bench')
                  JOIN players pl ON pl.id = ml.player_id
                 WHERE EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = pl.person_id
                                  AND tp.team_id = c.from_team_id AND tp.removed_at IS NULL)
                   AND NOT EXISTS (SELECT 1 FROM team_persons tp2
                                     JOIN fh_event_teams f2 ON f2.team_id = tp2.team_id AND f2.fh_event_id = p_fh_event_id
                                    WHERE tp2.person_id = pl.person_id AND tp2.removed_at IS NULL)) AS used
          FROM team_invite_caps c
         WHERE EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = p_fh_event_id AND fet.team_id = c.to_team_id)
    ),
    going AS (
        SELECT p.*,
               EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
                        WHERE fet.fh_event_id = p_fh_event_id) AS rostered,
               EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = p_fh_event_id
                          AND i.person_id = p.id AND i.revoked_at IS NULL) AS invited
          FROM fh_event_rsvps r JOIN persons p ON p.id = r.person_id
         WHERE r.fh_event_id = p_fh_event_id AND r.response = 'yes'
    ),
    judged AS (
        SELECT g.*, rs.code AS rs_code, rs.display_name AS rs_label, COALESCE(rs.player_done, false) AS rs_done,
               EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = g.id AND tp.removed_at IS NULL
                       JOIN roster_statuses rs3 ON rs3.id = tp.roster_status_id AND rs3.counts_as_on_roster
                        WHERE fet.fh_event_id = p_fh_event_id) AS status_on,
               EXISTS (SELECT 1 FROM list JOIN official_roster_names n ON n.source_id = list.id
                        WHERE n.person_id = g.id) AS on_list,
               (SELECT c.max_per_event > c.used
                       OR EXISTS (SELECT 1 FROM ev JOIN match_lineups ml ON ml.match_id = ev.match_id
                                    AND ml.zone IN ('starter', 'bench')
                                  JOIN players pl ON pl.id = ml.player_id AND pl.person_id = g.id)
                  FROM caps c
                 WHERE NOT g.rostered
                   AND EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = g.id
                                  AND tp.team_id = c.from_team_id AND tp.removed_at IS NULL)
                 ORDER BY c.max_per_event > c.used DESC LIMIT 1) AS calldown_ok
          FROM going g
          LEFT JOIN LATERAL (
              SELECT rs2.* FROM fh_event_teams fet
                JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.person_id = g.id AND tp.removed_at IS NULL
                LEFT JOIN roster_statuses rs2 ON rs2.id = tp.roster_status_id
               WHERE fet.fh_event_id = p_fh_event_id
               ORDER BY rs2.sort_order DESC NULLS LAST LIMIT 1) rs ON true
    )
    SELECT j.id, j.first_name::text, j.last_name::text, j.rs_code::text, j.rs_label::text, j.rs_done,
           (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = j.id AND ph.can_receive_sms
             ORDER BY ph.is_primary DESC, ph.id LIMIT 1)::text,
           (SELECT em.email FROM person_emails em WHERE em.person_id = j.id
             ORDER BY em.is_primary DESC, em.id LIMIT 1)::text,
           ev.label::text, COALESCE(fh_fill_form_links(ev.subject, p_club_id), ''), fh_fill_form_links(ev.body, p_club_id),
           CASE WHEN j.calldown_ok IS NOT NULL THEN 'calldown_cap_full'
                WHEN ev.checks_league_list AND EXISTS (SELECT 1 FROM list) THEN 'not_on_list'
                ELSE 'not_on_roster' END
      FROM judged j CROSS JOIN ev
     WHERE (NOT j.status_on
            OR (ev.checks_league_list AND EXISTS (SELECT 1 FROM list JOIN official_roster_names n ON n.source_id = list.id)))
       AND CASE WHEN ev.checks_league_list
                THEN (j.rostered OR j.invited)
                     AND NOT j.on_list
                     AND COALESCE(NOT j.calldown_ok, true)
                ELSE j.rostered END
     ORDER BY j.rs_done, j.last_name, j.first_name
$function$;

-- 1. The tag spellings resolve to APSL; Reserves off every game now.
UPDATE gcal_team_aliases
   SET team_id = 35,
       notes = COALESCE(notes, '') || ' → APSL (mig 1097: Reserves is a list + call-up pool, never on a game)'
 WHERE team_id = 938;

DELETE FROM fh_event_teams a
 WHERE a.team_id = 938
   AND EXISTS (SELECT 1 FROM fh_event_teams b WHERE b.fh_event_id = a.fh_event_id AND b.team_id = 35);

COMMIT;

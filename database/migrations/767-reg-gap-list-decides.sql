-- 767 (2026-10-27) — Game Center ⚠ registration gap: the CASA list decides.
--
-- Owner: "why is marco delgado not also showing that he is not on liga 1
-- roster and have the link? … it should show dues owed and the no roster
-- warning with remedies for both to message".  Marco is Going, starting,
-- owes dues (💰 chip showed) but sits only on the APSL list — his Liga 1
-- roster status was set to "on roster" by hand, and the gap check let that
-- status win over the CASA list (mig 645 meant the list to decide).  For a
-- league with checks_league_list and a pulled list, the status no longer
-- hides a player who is missing from the list; other leagues are unchanged.

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
    -- The league's list for this game: the game team's online source.
    list AS (
        SELECT s.id FROM official_roster_sources s
          JOIN fh_event_teams fet ON fet.team_id = s.team_id AND fet.fh_event_id = p_fh_event_id
         WHERE s.is_active AND s.system <> 'club_file'
         ORDER BY s.id LIMIT 1
    ),
    -- Call-down caps on this game and how many squad spots they use (the
    -- same count as the 🎟 panel, migs 616/618).
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
               -- An APSL call-down: rostered on a capped from-team, not on the game's team.
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
     -- A list-checked league (CASA) with a list pulled: the list decides,
     -- not a hand-set "on roster" status (mig 767 — Marco Delgado was
     -- marked on_roster for Liga 1 but is only on the APSL list).
     WHERE (NOT j.status_on
            OR (ev.checks_league_list AND EXISTS (SELECT 1 FROM list JOIN official_roster_names n ON n.source_id = list.id)))
       AND CASE WHEN ev.checks_league_list
                THEN (j.rostered OR j.invited)
                     AND NOT j.on_list
                     AND COALESCE(NOT j.calldown_ok, true)
                ELSE j.rostered END
     ORDER BY j.rs_done, j.last_name, j.first_name
$function$;

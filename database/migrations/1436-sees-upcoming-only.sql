-- 👁 SEES counts only events still AHEAD (was: last 90 days or ahead).
-- Owner 11/17: "usasa cup needs to go anyway as the competition is over".
-- A team whose games are all played (Cup 939, last game 10/18) asks
-- nobody about anything, so it leaves the SEES block. Checked 11/17:
-- the Cup is the only board team this drops.
CREATE OR REPLACE FUNCTION fh_person_sees(p_ids int[])
RETURNS TABLE (person_id int, sees jsonb, suspended boolean, injured boolean)
LANGUAGE sql STABLE AS $$
  WITH board_all AS (
    SELECT t.id, t.club_id, t.club_section_id, t.games_need_roster,
           COALESCE(NULLIF(t.short_label, ''), NULLIF(t.label, ''), t.name) AS team,
           t.board_sort_order,
           fh_team_callup_only(t.id) AS callup_only,
           -- A team with no practices on the calendar (the Cup) never says
           -- "practices" — only events still ahead.
           EXISTS (SELECT 1 FROM fh_event_teams fet JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'practice'
                     JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fet.team_id = t.id AND ge.deleted_at IS NULL AND ge.starts_at > now()) AS has_practices,
           EXISTS (SELECT 1 FROM fh_event_teams fet JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind IN ('match','intrasquad')
                     JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fet.team_id = t.id AND ge.deleted_at IS NULL AND ge.starts_at > now()) AS has_games
      FROM teams t
     WHERE t.is_active AND (t.board_sort_order IS NOT NULL OR t.rsvp_board)
  ), board AS (
    -- A team with no events of its own is a ROSTER, not a schedule (APSL
    -- Reserves = the APSL Reserve Roster; its men play APSL's games —
    -- owner 11/17 "there are no reserve games or reserve practices") —
    -- it shows under 📋 ROSTERS, never under 👁 SEES.
    SELECT * FROM board_all WHERE has_games OR has_practices
  ), standing AS (
    SELECT a.person_id, a.team_id FROM team_auto_invites a
     WHERE a.active AND a.person_id = ANY(p_ids)
  ), player AS (
    SELECT tp.person_id, b.id AS team_id, b.team, b.board_sort_order, 'player'::text AS role,
           ss.code AS squad, b.has_practices, b.has_games,
           -- owes nothing at all here
           (ss.code = 'inactive' OR (ss.id IS NULL AND tp.invite_only AND NOT b.games_need_roster)) AS idle,
           tp.invite_only AS practice_only, b.callup_only,
           EXISTS (SELECT 1 FROM standing s WHERE s.person_id = tp.person_id AND s.team_id = b.id) AS standing
      FROM team_persons tp
      JOIN board b ON b.id = tp.team_id
      LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
     WHERE tp.removed_at IS NULL AND tp.person_id = ANY(p_ids)
  ), rows AS (
    SELECT p.person_id, p.team_id, p.team, p.board_sort_order, p.role,
           CASE WHEN p.standing THEN 'invite'
                WHEN p.idle THEN 'no'
                WHEN p.practice_only THEN 'no'
                WHEN NOT p.has_games THEN 'no'
                WHEN p.callup_only THEN 'callup'
                ELSE 'yes' END AS games,
           CASE WHEN p.idle OR NOT p.has_practices THEN 'no' ELSE 'yes' END AS practices,
           NULL::int[] AS days,
           CASE WHEN p.idle THEN 'inactive'
                WHEN p.squad = 'practice_squad' THEN 'practice_squad'
                WHEN p.practice_only THEN 'not_on_roster'
                WHEN p.standing THEN 'standing_invite'
                WHEN p.callup_only THEN 'callup_only' END AS note
      FROM player p
    UNION ALL
    -- ⭐ standing invite where he has no roster row
    SELECT s.person_id, b.id, b.team, b.board_sort_order, 'player', 'invite', 'no', NULL, 'standing_invite'
      FROM standing s JOIN board b ON b.id = s.team_id
     WHERE NOT EXISTS (SELECT 1 FROM player p WHERE p.person_id = s.person_id AND p.team_id = s.team_id)
    UNION ALL
    SELECT c.person_id, b.id, b.team, b.board_sort_order, 'coach',
           CASE WHEN cs.practices_only OR NOT b.has_games THEN 'no' ELSE 'yes' END,
           CASE WHEN NOT b.has_practices THEN 'no'
                WHEN cs.id IS NULL THEN 'yes'
                WHEN EXISTS (SELECT 1 FROM coach_schedule_days d WHERE d.coach_schedule_id = cs.id) THEN 'days'
                ELSE 'no' END,
           (SELECT array_agg(d.isodow::int ORDER BY d.isodow) FROM coach_schedule_days d WHERE d.coach_schedule_id = cs.id),
           CASE WHEN cs.practices_only THEN 'volunteer' END
      FROM team_coaches tc
      JOIN coaches c ON c.id = tc.coach_id
      JOIN board b ON b.id = tc.team_id
      LEFT JOIN coach_schedules cs ON cs.coach_id = c.id AND cs.club_section_id = b.club_section_id
     WHERE tc.ended_at IS NULL AND c.person_id = ANY(p_ids)
    UNION ALL
    SELECT DISTINCT cst.person_id, NULL::int, NULL::text, -1, 'staff', 'yes', 'yes', NULL::int[], NULL::text
      FROM club_staff cst
     WHERE cst.ended_at IS NULL AND cst.person_id = ANY(p_ids)
  )
  SELECT pid AS person_id,
         COALESCE((SELECT jsonb_agg(jsonb_build_object(
                     'team_id', r.team_id, 'team', r.team, 'role', r.role, 'games', r.games,
                     'practices', r.practices, 'days', to_jsonb(r.days), 'note', r.note)
                   ORDER BY r.board_sort_order NULLS LAST, r.team, r.role)
                     FROM rows r WHERE r.person_id = pid), '[]'::jsonb) AS sees,
         EXISTS (SELECT 1 FROM rsvp_suspensions s WHERE s.person_id = pid
                  AND s.starts_at <= now() AND (s.ends_at IS NULL OR s.ends_at > now())) AS suspended,
         EXISTS (SELECT 1 FROM person_injuries i JOIN health_statuses h ON h.id = i.health_status_id AND h.is_injured
                  WHERE i.person_id = pid AND i.starts_at <= now() AND (i.ends_at IS NULL OR i.ends_at > now())) AS injured
    FROM unnest(p_ids) AS pid
$$;


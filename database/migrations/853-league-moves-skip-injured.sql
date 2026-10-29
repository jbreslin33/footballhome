-- 853 (2026-10-29) — the roster-moves email never asks to add a hurt player;
-- Mars Milligan (22445) back to APSL only.
--
-- Owner: "mars is just hurt and will be added to just apsl when healthy".
-- Mig 838 had moved his proposed add to Reserves — undone: the Reserves row
-- ends, his APSL card is Needs Docs again.  He is 🩹 Long-term injury
-- (person_injuries, mig 715), so fh_league_moves leaves out the add while
-- an injury is open; ending it puts him in the email by itself.

UPDATE team_persons SET removed_at = now()
 WHERE team_id = 938 AND person_id = 22445 AND removed_at IS NULL;
UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_docs')
 WHERE team_id = 35 AND person_id = 22445 AND removed_at IS NULL
   AND roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'not_on_roster');

CREATE OR REPLACE FUNCTION fh_league_moves()
RETURNS TABLE (source_id integer, team_id integer, person_id integer, full_name text,
               official_no integer, move text, reason text, requested_at timestamptz)
LANGUAGE sql STABLE AS $$
  WITH src AS (
    SELECT s.id, s.team_id FROM official_roster_sources s
     WHERE s.is_active AND s.request_contact_id IS NOT NULL
  ), list AS (
    SELECT DISTINCT ON (s.id, n.person_id) s.id AS source_id, s.team_id, n.person_id, n.full_name,
           (row_number() OVER (PARTITION BY s.id ORDER BY n.sort_order, n.id))::int AS official_no
      FROM src s JOIN official_roster_names n ON n.source_id = s.id
     ORDER BY s.id, n.person_id, n.sort_order
  ), live AS (
    SELECT tp.team_id, tp.person_id, tp.invite_only, tp.call_in, rs.code, rs.board_section, rs.league_request
      FROM team_persons tp LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
     WHERE tp.removed_at IS NULL
  ), on_list AS (   -- every mirrored league list, any team
    SELECT s.team_id, n.person_id FROM official_roster_sources s
      JOIN official_roster_names n ON n.source_id = s.id
     WHERE s.is_active AND n.person_id IS NOT NULL
  ), moves AS (
    SELECT l.source_id, l.team_id, l.person_id, l.full_name, l.official_no, 'drop'::text AS move,
           CASE WHEN v.league_request = 'drop' THEN 'drop' ELSE 'cut' END AS reason,
           v.board_section = 'pending_drop' AS asked
      FROM list l LEFT JOIN live v ON v.team_id = l.team_id AND v.person_id = l.person_id
     WHERE l.person_id IS NOT NULL
       AND (v.league_request = 'drop' OR v.board_section = 'pending_drop' OR NOT fh_in_leagueapps(l.person_id))
    UNION ALL
    SELECT s.id, s.team_id, v.person_id,
           trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')), NULL, 'add',
           CASE WHEN v.code IS NULL THEN 'needs_add' ELSE 'proposed' END, false
      FROM src s JOIN live v ON v.team_id = s.team_id
      JOIN persons p ON p.id = v.person_id
     WHERE NOT EXISTS (SELECT 1 FROM on_list o WHERE o.team_id = s.team_id AND o.person_id = v.person_id)
       -- never while hurt (mig 853): he goes on the list when he's healthy
       AND NOT EXISTS (SELECT 1 FROM person_injuries i JOIN health_statuses h ON h.id = i.health_status_id
                        WHERE i.person_id = v.person_id AND h.is_injured
                          AND i.starts_at <= now() AND (i.ends_at IS NULL OR i.ends_at > now()))
       AND (v.league_request = 'add'
            OR (v.code IS NULL AND NOT (v.invite_only AND v.call_in)
                -- requires: on one of those teams' lists
                AND (NOT EXISTS (SELECT 1 FROM roster_team_rules r WHERE r.team_id = s.team_id AND r.rule = 'requires')
                     OR EXISTS (SELECT 1 FROM roster_team_rules r JOIN on_list o ON o.team_id = r.other_team_id
                                 WHERE r.team_id = s.team_id AND r.rule = 'requires' AND o.person_id = v.person_id))
                -- excludes (either way): not on that list, not headed to it
                AND NOT EXISTS (
                  SELECT 1 FROM roster_team_rules r
                   CROSS JOIN LATERAL (SELECT CASE WHEN r.team_id = s.team_id THEN r.other_team_id ELSE r.team_id END AS tid) x
                   WHERE r.rule = 'excludes' AND s.team_id IN (r.team_id, r.other_team_id)
                     AND (EXISTS (SELECT 1 FROM on_list o WHERE o.team_id = x.tid AND o.person_id = v.person_id)
                          OR EXISTS (SELECT 1 FROM live w WHERE w.team_id = x.tid AND w.person_id = v.person_id
                                        AND w.board_section IN ('proposed', 'pending_add'))))))
  )
  SELECT m.source_id, m.team_id, m.person_id, m.full_name, m.official_no, m.move, m.reason,
         COALESCE((SELECT max(r.requested_at) FROM league_move_requests r
                    WHERE r.source_id = m.source_id AND r.person_id = m.person_id AND r.move = m.move),
                  CASE WHEN m.asked THEN now() END)
    FROM moves m
   ORDER BY m.source_id, m.move DESC, m.official_no NULLS LAST, m.full_name;
$$;

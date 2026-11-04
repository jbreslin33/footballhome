-- 1024: Event Center call-up chip names the direction (owner 2026-11-04:
-- "if we invite a player then we put him in no response with the others
-- and we just flag his card as call up … if he is not with the others i
-- will forget about him").
--
-- An invited player with no answer already sits in – No response with
-- the team (and in Remind all); his card carried a generic 🎟 INVITED.
-- Now it reads the way the #teams Team pill does (mig 1013): ⭐ CALL-UP ·
-- Liga 1 when he comes from a team lower on the board, ⭐ CALL-DOWN · APSL
-- from higher up.  Teams off the board order (youth club-pass invites)
-- keep the plain 🎟 INVITED · <team>.  Copy lives in message_templates.

BEGIN;

-- Direction of a person's open invite to an event: his invite's
-- from-team against the highest event team on the board (lowest
-- board_sort_order, APSL 4 → Reserves 5 → Liga 1 6).  dir is NULL when
-- either side has no board order.  from = the team's label without its
-- leading emoji ("⚽ Liga 1" → "Liga 1").
CREATE OR REPLACE FUNCTION fh_event_invite_badge(p_event_id bigint, p_person_id integer)
RETURNS jsonb LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
             'dir',  CASE WHEN ft.board_sort_order IS NULL OR ev.top IS NULL THEN NULL
                          WHEN ft.board_sort_order > ev.top THEN 'up'
                          WHEN ft.board_sort_order < ev.top THEN 'down' END,
             'from', NULLIF(regexp_replace(COALESCE(ft.label, ft.name, ''), '^[^[:alnum:]]+\s*', ''), ''))
      FROM fh_event_invites i
      LEFT JOIN teams ft ON ft.id = i.from_team_id
      CROSS JOIN (SELECT min(t.board_sort_order) AS top
                    FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
                   WHERE fet.fh_event_id = p_event_id) ev
     WHERE i.fh_event_id = p_event_id AND i.person_id = p_person_id AND i.revoked_at IS NULL
     ORDER BY i.id DESC
     LIMIT 1
$$;
COMMENT ON FUNCTION fh_event_invite_badge(bigint, integer) IS
  'mig 1024: {dir: up|down|null, from: team label} for a person''s open invite to an event — the Event Center card chip.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.category, v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event Center', 'Player card chip — invited from a lower team',  'chip_callup_up',   '⭐ CALL-UP[[ · {from}]]',   1024),
    ('Event Center', 'Player card chip — invited from a higher team', 'chip_callup_down', '⭐ CALL-DOWN[[ · {from}]]', 1025),
    ('Event Center', 'Player card chip — invited, no board direction', 'chip_invited',    '🎟 INVITED[[ · {from}]]',  1026)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

COMMIT;

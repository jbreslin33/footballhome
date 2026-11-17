-- 1435 (2026-11-17) — 👁 SEES + 📋 ROSTERS on every #teams card (Team and
-- Roster pills, Men / Women / Youth).  Owner: "for rosters and teams i need
-- a 'sees' section. i need to know what team events they see by default for
-- rsvps. for men and youth and women. it should be its own section on the
-- player card" + "i also need a ROSTERS section to show what official
-- rosters they are on. this would replace the on roster pill" ("the pill on
-- front of card", "on team and rosters screens").
--
-- fh_person_sees(person_ids) — per person, per board team, what that team's
-- events ask them about BY DEFAULT (no per-game invite), the same rules the
-- RSVP board's expected rows follow (RsvpBoard kBaseCtes):
--   player row  practices unless 💤 Inactive (or an old invite-only row on a
--               team whose games don't need a roster = owes nothing);
--               games unless the row is practice-only (Practice Squad,
--               youth not on the roster yet), or the team is call-up only
--               (mig 605) — then games come only by call-up, or by a ⭐
--               standing invite (team_auto_invites).
--   ⭐ standing invite on a team he is not on: games there.
--   coach       games (none when the schedule is practices only, mig 1224);
--               practices = every one, or only the schedule's days (mig 955).
--   club staff  every team of the club — one row, team NULL.
-- A team with no practices on the calendar (last 90 days or ahead) never
-- says practices, none with no games never says games, and a team with
-- neither (APSL Reserves — a roster, not a schedule) is not in SEES at all.
-- Overlays: ⛔ suspended (sees games, can't answer — mig 1077), 🩹 injured
-- (owes nothing while it lasts — mig 510).
-- Each row: {team_id, team, role, games, practices, days, note}
--   games     'yes' | 'invite' (⭐ standing) | 'callup' (only if called up) | 'no'
--   practices 'yes' | 'days' (coach schedule, days = [isodow…]) | 'no'
--   note      'inactive' | 'practice_squad' | 'not_on_roster' | 'callup_only'
--             | 'standing_invite' | 'volunteer' | null
--
-- fh_person_rosters(person_ids) — the official league lists each person is
-- matched on (official_roster_names, pulled from CASA / APSL / club files
-- on every #teams load): {source_id, team_id, league, list, team}.

CREATE OR REPLACE FUNCTION fh_person_sees(p_ids int[])
RETURNS TABLE (person_id int, sees jsonb, suspended boolean, injured boolean)
LANGUAGE sql STABLE AS $$
  WITH board_all AS (
    SELECT t.id, t.club_id, t.club_section_id, t.games_need_roster,
           COALESCE(NULLIF(t.short_label, ''), NULLIF(t.label, ''), t.name) AS team,
           t.board_sort_order,
           fh_team_callup_only(t.id) AS callup_only,
           -- A team with no practices on the calendar (the Cup) never says
           -- "practices" — last 90 days or anything ahead.
           EXISTS (SELECT 1 FROM fh_event_teams fet JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'practice'
                     JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fet.team_id = t.id AND ge.deleted_at IS NULL AND ge.starts_at > now() - interval '90 days') AS has_practices,
           EXISTS (SELECT 1 FROM fh_event_teams fet JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind IN ('match','intrasquad')
                     JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fet.team_id = t.id AND ge.deleted_at IS NULL AND ge.starts_at > now() - interval '90 days') AS has_games
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

CREATE OR REPLACE FUNCTION fh_person_rosters(p_ids int[])
RETURNS TABLE (person_id int, rosters jsonb)
LANGUAGE sql STABLE AS $$
  SELECT n.person_id,
         jsonb_agg(DISTINCT jsonb_build_object(
           'source_id', s.id, 'team_id', s.team_id, 'league', s.league_label, 'list', s.section_label,
           'team', COALESCE(NULLIF(t.short_label, ''), NULLIF(t.label, ''), t.name)))
    FROM official_roster_names n
    JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active
    JOIN teams t ON t.id = s.team_id
   WHERE n.person_id = ANY(p_ids)
   GROUP BY n.person_id
$$;

-- Card words (roster_sheet, client-side).  Compact: the cards are one line.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Roster Sheet', v.label, 'roster_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('card_sees_h',            'Card — SEES section heading',                          '👁 SEES', 1500),
    ('card_sees_games',        'Card — SEES: asked about games',                       '⚽', 1501),
    ('card_sees_practices',    'Card — SEES: asked about practices',                   '🏃', 1502),
    ('card_sees_days',         'Card — SEES: practices on a coach''s days ({days})',   '🏃 {days}', 1503),
    ('card_sees_callup',       'Card — SEES: games only when called up',               '⚽ if called up', 1504),
    ('card_sees_invite',       'Card — SEES: ⭐ standing invite to games',             '⭐⚽', 1505),
    ('card_sees_nothing',      'Card — SEES: on the team, asked about nothing',        '—', 1506),
    ('card_sees_none',         'Card — SEES: no team events at all',                   'nothing', 1507),
    ('card_sees_staff',        'Card — SEES: club staff (every team)',                 '🛡 every team', 1508),
    ('card_sees_coach',        'Card — SEES: coach tag on a team',                     '🧢', 1509),
    ('card_sees_coach_many',   'Card — SEES: coach of many teams ({n})',               '🧢 {n} teams', 1510),
    ('card_sees_why_inactive', 'Card — SEES: why nothing — inactive',                  '💤', 1511),
    ('card_sees_why_practice_squad', 'Card — SEES: practice squad (practices only)',   'practice squad', 1512),
    ('card_sees_why_not_on_roster',  'Card — SEES: youth not on the roster (practices only)', 'not on roster', 1513),
    ('card_sees_suspended',    'Card — SEES: suspended overlay',                       '⛔ suspended — sees games, can''t answer', 1514),
    ('card_sees_injured',      'Card — SEES: injured overlay',                         '🩹 not asked while injured', 1515),
    ('card_sees_tip',          'Card — SEES tooltip',                                  'What each team''s events ask him about by default (no per-game invite): ⚽ games · 🏃 practices', 1516),
    ('card_rosters_h',         'Card — ROSTERS section heading',                       '📋 ROSTERS', 1517),
    ('card_rosters_none',      'Card — ROSTERS: on no official list',                  'none', 1518),
    ('card_rosters_tip',       'Card — ROSTERS tooltip',                               'Official league rosters he is on — pulled from the league sites on every load', 1519)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'roster_sheet' AND t.tier = v.tier);

-- The old 👀⚽ card chip (card_sees_games) folds into SEES: its row now
-- reads as SEES' games mark.
UPDATE message_templates SET body = '⚽', label = 'Card — SEES: asked about games'
 WHERE kind = 'roster_sheet' AND tier = 'card_sees_games';

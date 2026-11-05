-- 1077: ⛔ Suspended SEES his games but cannot answer them (owner
-- 2026-11-05: "suspended can see games? let them know what they are
-- missing but they can't rsvp?" → "build it").  Games only — practices
-- are normal (seen, answered, reminded, fined).
--
-- Two kinds, one rule:
--   league — Roster status "Suspended" on a team the game is tagged with
--            (a red-card ban).  Before: no effect on #my, but the #rsvps
--            board and fines dropped him from EVERY event.
--   club   — an rsvp_suspensions row covering the game's start (whole
--            club, or a tagged team).  Before: hid every event.
-- fh_event_suspension(event, person) → 'league' | 'club' | NULL is the one
-- truth; #my shows the game with a ⛔ line instead of Go / No, the write
-- gate refuses an answer, Event Center and Game Center list him under
-- ⛔ Suspended (out of No Response and Remind all, not lineup-able), the
-- #rsvps board does not ask, fines do not count it.  Words: kind
-- 'suspended'.  On a youth games-need-roster team a league-suspended kid
-- stays a player (not auto Practice Squad) so the ban shows.

BEGIN;

CREATE OR REPLACE FUNCTION fh_event_suspension(p_fh_event_id bigint, p_person_id integer)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT CASE
           WHEN fe.kind <> 'match' THEN NULL
           WHEN EXISTS (SELECT 1 FROM fh_event_teams fet
                          JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                          JOIN roster_statuses rs ON rs.id = tp.roster_status_id AND rs.code = 'suspended'
                         WHERE fet.fh_event_id = fe.id AND tp.person_id = p_person_id) THEN 'league'
           WHEN EXISTS (SELECT 1 FROM rsvp_suspensions s
                         WHERE s.person_id = p_person_id
                           AND s.starts_at <= ge.starts_at
                           AND (s.ends_at IS NULL OR s.ends_at > ge.starts_at)
                           AND (s.team_id IS NULL OR EXISTS (SELECT 1 FROM fh_event_teams fet
                                                              WHERE fet.fh_event_id = fe.id AND fet.team_id = s.team_id))) THEN 'club'
         END
    FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
   WHERE fe.id = p_fh_event_id
$$;

-- The club suspension's last day, for the #my line ("until Sat 11/14"); NULL
-- for a league ban or an open-ended one.
CREATE OR REPLACE FUNCTION fh_event_suspension_until(p_fh_event_id bigint, p_person_id integer)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT to_char(max(s.ends_at) AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD')
    FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
    JOIN rsvp_suspensions s ON s.person_id = p_person_id
                           AND s.starts_at <= ge.starts_at
                           AND s.ends_at IS NOT NULL AND s.ends_at > ge.starts_at
   WHERE fe.id = p_fh_event_id AND fe.kind = 'match'
     AND fh_event_suspension(p_fh_event_id, p_person_id) = 'club'
$$;

CREATE OR REPLACE FUNCTION fh_event_suspended(p_fh_event_id bigint, p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT fh_event_suspension(p_fh_event_id, p_person_id) IS NOT NULL
$$;

CREATE OR REPLACE FUNCTION fh_person_fines_all(p_person_ids integer[], p_from timestamp with time zone)
  RETURNS TABLE(person_id integer, fh_event_id bigint, team_id integer, starts_at timestamp with time zone, event_kind text, opponent text, fine_kind text, amount_usd numeric, response text, attendance text)
  LANGUAGE sql
  STABLE
 AS $fn$
   WITH owed AS (
     SELECT DISTINCT ON (tp.person_id, fe.id)
            tp.person_id, fe.id AS fh_event_id, t.id AS team_id, t.club_id, t.club_section_id,
            ge.starts_at, fe.kind, fe.opponent,
            rv.response, rv.responded_at, att.status AS attendance
       FROM team_persons tp
       JOIN teams t              ON t.id = tp.team_id AND t.is_active
       LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
       JOIN fh_event_teams fet   ON fet.team_id = t.id
       JOIN fh_events fe         ON fe.id = fet.fh_event_id
                                AND fe.kind IN ('practice', 'match', 'intrasquad')
       JOIN gcal_events ge       ON ge.id = fe.gcal_event_id
       LEFT JOIN fh_event_rsvps rv       ON rv.fh_event_id = fe.id  AND rv.person_id  = tp.person_id
       LEFT JOIN fh_event_attendance att ON att.fh_event_id = fe.id AND att.person_id = tp.person_id
      WHERE tp.person_id = ANY (p_person_ids)
        AND tp.removed_at IS NULL
        -- Call-up-gated team (mig 603): being on the roster creates no
        -- expectation, so no fine. Invited call-ups are deliberately not
        -- fined either (youth semantics).
        AND NOT fh_team_callup_only(tp.team_id)
        AND NOT tp.invite_only  -- mig 619: paper spots owe nothing
        AND t.club_section_id IS NOT NULL
        AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
        AND ge.starts_at >= GREATEST(tp.joined_at, p_from)
        AND ge.starts_at <  now()
        -- ⛔ Suspended for this GAME (mig 1077): could not answer, no fine.
        -- Practices are normal for a suspended player.
        AND NOT fh_event_suspended(fe.id, tp.person_id)
        -- Blocked from answering by dues on the event day: no fine (mig 461).
        AND fh_dues_eligible_at(tp.person_id, t.club_id, ge.starts_at)
        -- Coaches are not fined; regular players are (mig 693).
        AND NOT fh_fine_exempt(tp.person_id)
        -- Injured on the event day: no fine (mig 510).
        AND NOT fh_person_injured_at(tp.person_id, ge.starts_at)
      ORDER BY tp.person_id, fe.id, t.id
   ), judged AS (
     SELECT o.*,
            CASE
              WHEN o.response IS NULL OR o.responded_at >= o.starts_at
                THEN CASE WHEN o.kind = 'practice' THEN 'missed_rsvp_practice' ELSE 'missed_rsvp_game' END
              WHEN o.response = 'yes' AND o.attendance = 'absent'
                THEN CASE WHEN o.kind = 'practice' THEN 'no_show_practice' ELSE 'no_show_game' END
            END AS fine_kind
       FROM owed o
   )
   SELECT j.person_id, j.fh_event_id, j.team_id, j.starts_at, j.kind, j.opponent,
          j.fine_kind, amt.amount_usd, j.response, j.attendance
     FROM judged j
     CROSS JOIN LATERAL (
       SELECT fh_fine_amount_usd(j.club_id, j.club_section_id, j.fine_kind,
                                 (j.starts_at AT TIME ZONE 'America/New_York')::date) AS amount_usd
     ) amt
    WHERE j.fine_kind IS NOT NULL AND amt.amount_usd IS NOT NULL AND amt.amount_usd > 0
 $fn$;

-- A league-suspended youth player stays a player on a games-need-roster
-- team, so his ban shows on the game instead of hiding it.
CREATE OR REPLACE FUNCTION fh_team_persons_games_need_roster()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE plays boolean; ps integer; sec boolean;
BEGIN
    IF (SELECT games_need_roster FROM teams WHERE id = NEW.team_id) THEN
        plays := COALESCE((SELECT counts_as_on_roster OR board_section IN ('proposed', 'pending_add', 'no_room')
                                  OR code = 'suspended'
                             FROM roster_statuses WHERE id = NEW.roster_status_id), false)
              OR EXISTS (SELECT 1 FROM official_roster_names n
                           JOIN official_roster_sources s ON s.id = n.source_id
                          WHERE s.team_id = NEW.team_id AND s.is_active AND n.person_id = NEW.person_id);
        SELECT id INTO ps FROM squad_statuses WHERE code = 'practice_squad';
        sec := NEW.squad_status_id IS NOT NULL
               AND NOT COALESCE((SELECT per_team FROM squad_statuses WHERE id = NEW.squad_status_id), false);
        IF NOT sec THEN
            NEW.squad_status_id := CASE WHEN plays THEN NULL ELSE ps END;
        END IF;
        NEW.invite_only := NEW.squad_status_id IS NOT NULL;
        NEW.call_in     := false;
    END IF;
    RETURN NEW;
END $$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'RSVP', v.l, 'suspended', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Suspended — #my game line, adult (league ban)', 'my_league',
     '⛔ Suspended by the league — you can''t play this game. Come support the team!', 1),
    ('Suspended — #my game line, adult (club)', 'my_club',
     '⛔ You''re suspended[[ until {until}]] — you can''t answer or play this game.', 2),
    ('Suspended — #my game line, parent (league ban)', 'parent_league',
     '⛔ {child} is suspended by the league — can''t play this game.', 3),
    ('Suspended — #my game line, parent (club)', 'parent_club',
     '⛔ {child} is suspended[[ until {until}]] — can''t answer or play this game.', 4),
    ('Suspended — answer refused', 'refused',
     'Suspended for this game — no answer needed, and you can''t play it.', 5),
    ('Suspended — Event Center / Game Center section', 'section', '⛔ Suspended', 6),
    ('Suspended — card chip', 'chip', '⛔ SUSPENDED', 7)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'suspended' AND m.tier = v.t);

COMMIT;

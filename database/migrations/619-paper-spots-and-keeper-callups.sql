-- 619 (2026-10-20) — 📄 Paper spots (invite-only roster rows) + the two
-- keepers' standing APSL call-ups.
--
-- Owner: "benzig, Figueroa, Masi are really on apsl roster to fill min
-- spots … allow them to stay on roster but to not get auto invite to
-- apsl … otherwise having them look like apsl is clutter. and not fair
-- to them. but we don't want to lose them by turning them 'off' without
-- knowing they are 'off'."  And: "both keepers need permanent invite to
-- apsl … Evan Watson and Issaac Modesto-Anderson. we have them on liga 1
-- and reserves so they can do both."
--
-- A paper spot keeps the team_persons row (the roster, kit, dues and the
-- league's minimum count all still see them) but grants NOTHING on games:
-- no #my visibility, no RSVP expectation or reminder, no fine, not in the
-- lineup pool or message-everyone — the same semantics a call-up-gated
-- TEAM (mig 605) gives every member, per player.  They stay one tap away:
-- the 🎟 panel lists them as candidates of their own team (basis 'paper'),
-- and the flag is a loud 📄 label on the roster card so nobody is
-- forgotten silently.

ALTER TABLE team_persons
  ADD COLUMN IF NOT EXISTS invite_only boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN team_persons.invite_only IS
  'mig 619: 📄 paper spot — the row holds the roster place but grants nothing on games (no visibility/RSVP/reminder/fine/lineup pool); the player takes part only when invited (fh_event_invites), like a member of a call-up-gated team (mig 605).';

-- The three APSL roster-fillers.
UPDATE team_persons SET invite_only = true
 WHERE team_id = 35 AND person_id IN (22241, 22299, 3500) AND removed_at IS NULL;

-- The keepers ride every APSL game by default (team_auto_invites, mig
-- 617): Evan Watson and Isaac Anderson, up from Liga 1.
INSERT INTO team_auto_invites (team_id, person_id, from_team_id)
VALUES (35, 22589, 120), (35, 22228, 120)
ON CONFLICT (team_id, person_id) DO UPDATE SET active = true;

-- Back-fill every active standing invite onto upcoming games (generic —
-- covers the keepers' APSL fixtures).
INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
SELECT fet.fh_event_id, a.person_id, a.from_team_id, a.person_id, 'auto'
  FROM team_auto_invites a
  JOIN fh_event_teams fet ON fet.team_id = a.team_id
  JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()
 WHERE a.active
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                    WHERE i.fh_event_id = fet.fh_event_id
                      AND i.person_id = a.person_id AND i.revoked_at IS NULL);

-- Candidates: paper-spot members of a tagged team join the pickable list
-- (basis 'paper', from their own team); the adult branch ignores
-- invite_only rows when deciding who is "already rostered here".
CREATE OR REPLACE FUNCTION public.fh_event_invite_candidates(p_fh_event_id bigint)
 RETURNS TABLE(person_id integer, from_team_id integer, from_team_name text, single_age integer, basis text)
 LANGUAGE sql STABLE AS $function$
  WITH tagged AS (
    SELECT t.* FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
     WHERE fet.fh_event_id = p_fh_event_id
  ),
  youth AS (
    SELECT cu.person_id, cu.from_team_id, cu.from_team_name, cu.single_age, 'callup'::text AS basis
      FROM fh_event_callups(p_fh_event_id) cu
     WHERE EXISTS (SELECT 1 FROM tagged WHERE gender_category IN ('boys','girls'))
  ),
  -- Call-up-gated tagged teams (mig 603): roster membership grants no
  -- visibility, so the roster itself is the squad the coach picks from.
  gated AS (
    SELECT DISTINCT ON (p.id)
           p.id AS person_id, t.id AS from_team_id, t.name::text AS from_team_name,
           NULL::int AS single_age, 'squad'::text AS basis
      FROM tagged t
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL
      JOIN persons p ON p.id = tp.person_id
     WHERE fh_team_callup_only(t.id)
     ORDER BY p.id, t.id
  ),
  -- 📄 Paper spots (mig 619): invite-only members of a tagged team are
  -- pickable from their own squad.
  paper AS (
    SELECT DISTINCT ON (p.id)
           p.id AS person_id, t.id AS from_team_id, t.name::text AS from_team_name,
           NULL::int AS single_age, 'paper'::text AS basis
      FROM tagged t
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL AND tp.invite_only
      JOIN persons p ON p.id = tp.person_id
     WHERE NOT fh_team_callup_only(t.id)
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN tagged y ON y.id = x.team_id
                        WHERE x.person_id = p.id AND x.removed_at IS NULL
                          AND NOT x.invite_only AND NOT fh_team_callup_only(y.id))
     ORDER BY p.id, t.id
  ),
  adult AS (
    SELECT DISTINCT ON (p.id)
           p.id AS person_id, t.id AS from_team_id, t.name::text AS from_team_name,
           NULL::int AS single_age, 'squad'::text AS basis
      FROM tagged tg
      JOIN teams t ON t.club_id = tg.club_id
                  AND t.club_section_id = tg.club_section_id
                  AND t.gender_category = tg.gender_category
                  AND t.is_active AND NOT t.is_pool AND t.board_archived_at IS NULL
                  AND t.id NOT IN (SELECT id FROM tagged)
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL
      JOIN persons p ON p.id = tp.person_id
     WHERE tg.gender_category IN ('mens','womens')
       -- A paper spot on a tagged team does not make them "rostered here"
       -- (mig 619) — but the paper branch already lists them, so skip.
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN tagged y ON y.id = x.team_id
                        WHERE x.person_id = p.id AND x.removed_at IS NULL
                          AND NOT x.invite_only AND NOT fh_team_callup_only(y.id))
       AND NOT EXISTS (SELECT 1 FROM gated g WHERE g.person_id = p.id)
       AND NOT EXISTS (SELECT 1 FROM paper pp WHERE pp.person_id = p.id)
     ORDER BY p.id, t.id
  )
  SELECT c.* FROM (SELECT * FROM youth
                   UNION ALL SELECT * FROM gated
                   UNION ALL SELECT * FROM paper
                   UNION ALL SELECT * FROM adult) c
   WHERE NOT fh_event_invited(p_fh_event_id, c.person_id)
$function$;

-- Fines: a paper spot owes nothing (full definition below, one line added).
CREATE OR REPLACE FUNCTION public.fh_person_fines(p_person_ids integer[], p_from timestamp with time zone)
 RETURNS TABLE(person_id integer, fh_event_id bigint, team_id integer, starts_at timestamp with time zone, event_kind text, opponent text, fine_kind text, amount_usd numeric, response text, attendance text)
 LANGUAGE sql
 STABLE
AS $function$
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
       AND COALESCE(rs.show_in_rsvp, true)
       AND t.club_section_id IS NOT NULL
       AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
       AND ge.starts_at >= GREATEST(tp.joined_at, p_from)
       AND ge.starts_at <  now()
       AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s
                        WHERE s.person_id = tp.person_id
                          AND (s.team_id IS NULL OR s.team_id = t.id)
                          AND s.starts_at <= ge.starts_at
                          AND (s.ends_at IS NULL OR s.ends_at > ge.starts_at))
       -- Blocked from answering by dues on the event day: no fine (mig 461).
       AND fh_dues_eligible_at(tp.person_id, t.club_id, ge.starts_at)
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
$function$

;

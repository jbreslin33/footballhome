-- 605 (2026-10-19) — Call-up-gated teams: Reserves games are invite-only
-- for players.
--
-- Owner: "i think we should not confuse the reserves. I am thinking if a
-- player is on reserves I have to click call up for it to show on their
-- rsvp. thoughts? because a lot of the reservers will almost never if at
-- all be sleected." … "i like the way the youth call up functionality
-- works."
--
-- Most of the men's pool carries an APSL Reserves (938) row, so every
-- Reserves game landed on forty RSVP lists for a sixteen-man squad —
-- noise on #my, reminder nags for men never in the plans, and (worst)
-- fine liability via fh_person_fines for games they were never wanted at.
--
-- Model, copied from youth club-pass call-ups (migrations 329/355): for a
-- team listed in team_callup_policies, an active team_persons row grants
-- a player NOTHING on that team's games.  The only way a player sees,
-- RSVPs to, is reminded about, or is penalised over such a game is an
-- explicit fh_event_invites row (the coach's CALL UP click).  An invitee
-- who answers Going folds into the Game Center lineup exactly like a
-- youth call-up (🎟).  Coaches, club staff and admin tooling are
-- unaffected — the full Reserves roster stays visible to them everywhere,
-- and is now offered as the call-up candidate list.
--
-- The same-commit C++ adds `NOT fh_team_callup_only(...)` to every
-- player-side visibility/expectation leg (CalendarController, RsvpBoard,
-- MyController push reminders, WelcomeMessage, ReportsController,
-- GameMessageController recipients, CarpoolController) and adds invite
-- legs where call-ups were previously invisible (RSVP board expectation,
-- roll-call "me", push remind).
--
-- Deliberate (owner may revisit): invited players stay OUTSIDE
-- fh_person_fines — pure youth semantics.  A called-up reserve who says
-- Going and then no-shows is NOT fined; surfacing stays on the GHOST/
-- NO-SHOW pills.  Making call-ups no_show-finable is a small follow-up to
-- fh_person_fines if wanted.

BEGIN;

-- 1. The policy: which teams' games are call-up-only ─────────────────────
CREATE TABLE IF NOT EXISTS team_callup_policies (
    team_id    integer PRIMARY KEY REFERENCES teams(id) ON DELETE CASCADE,
    note       text NOT NULL DEFAULT '',
    created_at timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE team_callup_policies IS
    'Teams whose games are invite-only for players (mig 605): an active '
    'team_persons row on a listed team grants NO game visibility, RSVP, '
    'reminder or fine exposure — only an fh_event_invites row (CALL UP) '
    'does, exactly like youth club-pass call-ups. Coach/staff/admin '
    'surfaces are unaffected.';

INSERT INTO team_callup_policies (team_id, note)
SELECT t.id, 'APSL Reserves: big pool, most never selected — coach calls up a squad per game (owner 2026-10-19)'
  FROM teams t WHERE t.id = 938
ON CONFLICT (team_id) DO NOTHING;

CREATE OR REPLACE FUNCTION fh_team_callup_only(p_team_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM team_callup_policies g WHERE g.team_id = p_team_id)
$$;

-- 2. Fines: membership in a gated team creates no liability ──────────────
-- (fh_person_fines last defined in mig 510; only change is the
-- fh_team_callup_only guard in `owed`.)
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
       -- Call-up-gated team (mig 605): being on the roster creates no
       -- expectation, so no fine. Invited call-ups are deliberately not
       -- fined either (youth semantics).
       AND NOT fh_team_callup_only(tp.team_id)
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
$function$;

-- 3. Invite candidates: a gated team's own roster IS the call-up list ────
-- (last defined in mig 355. Changes: new `gated` branch offering the
-- gated tagged team's active roster; the adult branch's "already on a
-- tagged team" exclusions ignore gated tags, so a Reserves row no longer
-- blocks the invite.)
CREATE OR REPLACE FUNCTION public.fh_event_invite_candidates(p_fh_event_id bigint)
 RETURNS TABLE(person_id integer, from_team_id integer, from_team_name text, single_age integer, basis text)
 LANGUAGE sql
 STABLE
AS $function$
  WITH tagged AS (
    SELECT t.* FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
     WHERE fet.fh_event_id = p_fh_event_id
  ),
  youth AS (
    SELECT cu.person_id, cu.from_team_id, cu.from_team_name, cu.single_age, 'callup'::text AS basis
      FROM fh_event_callups(p_fh_event_id) cu
     WHERE EXISTS (SELECT 1 FROM tagged WHERE gender_category IN ('boys','girls'))
  ),
  -- Call-up-gated tagged teams (mig 605): roster membership grants no
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
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN tagged y ON y.id = x.team_id
                        WHERE x.person_id = p.id AND x.removed_at IS NULL
                          AND NOT fh_team_callup_only(y.id))
       AND NOT EXISTS (SELECT 1 FROM gated g WHERE g.person_id = p.id)
     ORDER BY p.id, t.id
  )
  SELECT c.* FROM (SELECT * FROM youth
                   UNION ALL SELECT * FROM gated
                   UNION ALL SELECT * FROM adult) c
   WHERE NOT fh_event_invited(p_fh_event_id, c.person_id)
$function$;

COMMIT;

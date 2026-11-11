-- 1250 (2026-11-11) — Working fines out: 2.8 s, not 18–38 s.
--
-- fh_person_fines_all checked dues eligibility on the event day, game
-- suspension, coach exemption and injury for EVERY player × past event row
-- (thousands), before knowing whether the row is a fine at all — only the
-- unanswered / said-yes-no-show rows are (162 in 6 months).  Those four
-- per-person checks now run only on rows that would be fined; the team-level
-- filters (call-up gated, paper spot) stay where they were.  Same rows out:
-- compared old v new over every rostered player, 6 months — 0 differ.
-- #fines answered 504 / ~17 s+; the Tuition card fine boxes and #my use it too.

CREATE OR REPLACE FUNCTION public.fh_person_fines_all(p_person_ids integer[], p_from timestamp with time zone)
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
        AND t.club_section_id IS NOT NULL
        AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
        AND ge.starts_at >= GREATEST(tp.joined_at, p_from)
        AND ge.starts_at <  now()
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
   ), fined AS MATERIALIZED (
     -- Only rows that would be fined go through the per-person checks
     -- below (mig 1249): they are the expensive part, and most event rows
     -- are answered in time.
     SELECT * FROM judged WHERE fine_kind IS NOT NULL
   ), kept AS (
     SELECT f.* FROM fined f
      WHERE NOT fh_event_suspended(f.fh_event_id, f.person_id)        -- ⛔ suspended for this game (mig 1077)
        AND fh_dues_eligible_at(f.person_id, f.club_id, f.starts_at)  -- dues blocked that day (mig 461)
        AND NOT fh_fine_exempt(f.person_id)                            -- coaches (mig 693)
        AND NOT fh_person_injured_at(f.person_id, f.starts_at)         -- injured that day (mig 510)
   )
   SELECT j.person_id, j.fh_event_id, j.team_id, j.starts_at, j.kind, j.opponent,
          j.fine_kind, amt.amount_usd, j.response, j.attendance
     FROM kept j
     CROSS JOIN LATERAL (
       SELECT fh_fine_amount_usd(j.club_id, j.club_section_id, j.fine_kind,
                                 (j.starts_at AT TIME ZONE 'America/New_York')::date) AS amount_usd
     ) amt
    WHERE amt.amount_usd IS NOT NULL AND amt.amount_usd > 0
 $function$

;

DROP FUNCTION IF EXISTS public.fh_person_fines_all_v2(integer[], timestamp with time zone);
